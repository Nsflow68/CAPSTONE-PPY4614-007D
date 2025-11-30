from __future__ import annotations

import os
from typing import Callable, Dict, List, Optional, Tuple

import pandas as pd
from PyQt5.QtCore import Qt
from PyQt5.QtWidgets import (
    QFileDialog,
    QGroupBox,
    QHBoxLayout,
    QLabel,
    QListWidget,
    QListWidgetItem,
    QMessageBox,
    QPushButton,
    QVBoxLayout,
    QWidget,
    QComboBox,
)

from app.services.api_client import ApiClientError
from app.services.chatbot_service import ChatbotService
from app.services.donation_service import DonationService
from app.services.resource_service import ResourceService
from app.services.user_service import USER_COLUMNS, UserService


ExportProvider = Callable[[], pd.DataFrame]


class ReportsView(QWidget):
    """Vista única para exportar datos en distintos formatos."""

    def __init__(
        self,
        user_service: Optional[UserService] = None,
        chatbot_service: Optional[ChatbotService] = None,
        resource_service: Optional[ResourceService] = None,
        donation_service: Optional[DonationService] = None,
    ) -> None:
        super().__init__()
        self._user_service = user_service or UserService()
        self._chatbot_service = chatbot_service or ChatbotService()
        self._resource_service = resource_service or ResourceService()
        self._donation_service = donation_service or DonationService()

        self._module_selector = QComboBox()
        self._format_selector = QComboBox()
        self._columns_list = QListWidget()
        self._status_label = QLabel()

        self._module_providers: Dict[str, Tuple[str, ExportProvider]] = {
            "Usuarios": ("usuarios", self._load_users_df),
            "Chatbot": ("chatbot", self._load_chatbot_df),
            "Donaciones": ("donaciones", self._load_donations_df),
            "Recursos": ("recursos", self._load_resources_df),
        }

        self._build_ui()
        self._refresh_columns()

    # ------------------------------------------------------------------ #
    # UI
    # ------------------------------------------------------------------ #
    def _build_ui(self) -> None:
        layout = QVBoxLayout(self)
        layout.setContentsMargins(12, 12, 12, 12)
        layout.setSpacing(14)

        title = QLabel("<h2>Exportación de Datos</h2>")
        title.setAlignment(Qt.AlignLeft)
        layout.addWidget(title)

        layout.addWidget(self._build_selection_box())
        layout.addWidget(self._build_columns_box())
        layout.addLayout(self._build_actions())
        layout.addWidget(self._status_label)
        layout.addStretch()

    def _build_selection_box(self) -> QWidget:
        box = QGroupBox("Origen y formato")
        box_layout = QHBoxLayout(box)
        box_layout.setContentsMargins(10, 8, 10, 8)
        box_layout.setSpacing(14)

        self._module_selector.addItems(self._module_providers.keys())
        self._module_selector.currentIndexChanged.connect(self._refresh_columns)
        self._module_selector.setMinimumWidth(200)

        self._format_selector.addItems(["CSV", "Excel (XLSX)", "JSON"])
        self._format_selector.setMinimumWidth(140)

        box_layout.addWidget(QLabel("Módulo:"))
        box_layout.addWidget(self._module_selector, 1)
        box_layout.addWidget(QLabel("Formato:"))
        box_layout.addWidget(self._format_selector, 1)
        box_layout.addStretch()
        return box

    def _build_columns_box(self) -> QWidget:
        box = QGroupBox("Columnas a exportar")
        box_layout = QVBoxLayout(box)
        box_layout.setContentsMargins(10, 8, 10, 8)
        box_layout.setSpacing(8)

        buttons_row = QHBoxLayout()
        select_all_btn = QPushButton("Seleccionar todo")
        clear_btn = QPushButton("Limpiar selección")
        btn_style = """
            QPushButton {
                padding: 6px 12px;
                border-radius: 6px;
                background-color: #f5f5f5;
            }
            QPushButton:hover {
                background-color: #e0dff7;
            }
        """
        select_all_btn.setStyleSheet(btn_style)
        clear_btn.setStyleSheet(btn_style)
        select_all_btn.clicked.connect(self._select_all_columns)
        clear_btn.clicked.connect(self._clear_columns)
        buttons_row.addWidget(select_all_btn)
        buttons_row.addWidget(clear_btn)
        buttons_row.addStretch()

        self._columns_list.setSelectionMode(QListWidget.MultiSelection)
        self._columns_list.setMinimumHeight(180)

        box_layout.addLayout(buttons_row)
        box_layout.addWidget(self._columns_list)
        return box

    def _build_actions(self) -> QHBoxLayout:
        actions = QHBoxLayout()
        actions.addStretch()
        export_btn = QPushButton("📤 Exportar")
        export_btn.setMinimumHeight(40)
        export_btn.setStyleSheet(
            """
            QPushButton {
                padding: 10px 18px;
                border-radius: 8px;
                background-color: #5bc0de;
                color: white;
                font-weight: 600;
            }
            QPushButton:hover { background-color: #31b0d5; }
            """
        )
        export_btn.clicked.connect(self._export)
        actions.addWidget(export_btn)
        return actions

    # ------------------------------------------------------------------ #
    # Data loading
    # ------------------------------------------------------------------ #
    def _refresh_columns(self) -> None:
        self._columns_list.clear()
        df = self._get_current_dataframe(sample_only=True)
        if df is None or df.empty:
            self._status_label.setText("Sin datos disponibles para este módulo.")
            return
        for col in df.columns:
            if col.lower() in {"contraseña", "password", "password_hash"}:
                continue
            item = QListWidgetItem(col)
            item.setSelected(True)
            self._columns_list.addItem(item)
        self._status_label.setText("")

    def _get_current_dataframe(self, sample_only: bool = False) -> Optional[pd.DataFrame]:
        module_name = self._module_selector.currentText()
        if module_name not in self._module_providers:
            return None
        provider = self._module_providers[module_name][1]
        try:
            df = provider()
            if df is None:
                return None
            if sample_only and df.shape[0] > 200:
                return df.head(200)
            return df
        except ApiClientError as exc:
            QMessageBox.critical(self, "Error al obtener datos", str(exc))
            return None
        except Exception as exc:  # pragma: no cover - visual feedback only
            QMessageBox.critical(self, "Error", f"No se pudieron cargar los datos: {exc}")
            return None

    def _load_users_df(self) -> pd.DataFrame:
        return self._user_service.list_users_dataframe()

    def _load_chatbot_df(self) -> pd.DataFrame:
        return self._chatbot_service.list_as_dataframe()

    def _load_resources_df(self) -> pd.DataFrame:
        return self._resource_service.list_resources()

    def _load_donations_df(self) -> pd.DataFrame:
        df, _ = self._donation_service.fetch_donations()
        return df

    # ------------------------------------------------------------------ #
    # Export logic
    # ------------------------------------------------------------------ #
    def _export(self) -> None:
        df = self._get_current_dataframe()
        if df is None or df.empty:
            QMessageBox.information(self, "Exportación", "No hay datos para exportar.")
            return

        selected_cols = [item.text() for item in self._columns_list.selectedItems()]
        if selected_cols:
            missing = [c for c in selected_cols if c not in df.columns]
            if missing:
                QMessageBox.warning(self, "Exportación", "Algunas columnas seleccionadas no existen en los datos.")
            else:
                df = df[selected_cols]

        fmt = self._format_selector.currentText()
        module_key = self._module_providers[self._module_selector.currentText()][0]
        suggested_name = f"export_{module_key}"

        if fmt.startswith("CSV"):
            default_filter = "CSV (*.csv)"
            default_ext = ".csv"
        elif fmt.startswith("Excel"):
            default_filter = "Excel (*.xlsx)"
            default_ext = ".xlsx"
        else:
            default_filter = "JSON (*.json)"
            default_ext = ".json"

        path, _ = QFileDialog.getSaveFileName(
            self,
            "Guardar exportación",
            suggested_name + default_ext,
            ";;".join(["CSV (*.csv)", "Excel (*.xlsx)", "JSON (*.json)"]),
            default_filter,
        )
        if not path:
            return
        if not os.path.splitext(path)[1]:
            path += default_ext

        try:
            if fmt.startswith("CSV"):
                df.to_csv(path, index=False)
            elif fmt.startswith("Excel"):
                df.to_excel(path, index=False)
            else:
                df.to_json(path, orient="records", force_ascii=False, indent=2)
        except Exception as exc:  # pragma: no cover - visual feedback only
            QMessageBox.critical(self, "Error al exportar", f"No se pudo guardar el archivo:\n{exc}")
            return

        QMessageBox.information(self, "Exportación completa", f"Archivo guardado en:\n{path}")

    # ------------------------------------------------------------------ #
    # Helpers
    # ------------------------------------------------------------------ #
    def _select_all_columns(self) -> None:
        for i in range(self._columns_list.count()):
            item = self._columns_list.item(i)
            item.setSelected(True)

    def _clear_columns(self) -> None:
        for i in range(self._columns_list.count()):
            item = self._columns_list.item(i)
            item.setSelected(False)


# Ejecución aislada para probar la vista
if __name__ == "__main__":  # pragma: no cover - manual test helper
    import sys
    from PyQt5.QtWidgets import QApplication

    app = QApplication(sys.argv)
    w = ReportsView()
    w.resize(640, 520)
    w.show()
    sys.exit(app.exec_())
