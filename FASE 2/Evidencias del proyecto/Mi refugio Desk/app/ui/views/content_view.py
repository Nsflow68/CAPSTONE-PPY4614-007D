from __future__ import annotations

from typing import Optional

import pandas as pd
from PyQt5.QtCore import QAbstractTableModel, Qt, QVariant
from PyQt5.QtWidgets import (
    QAbstractItemView,
    QDialog,
    QDialogButtonBox,
    QFormLayout,
    QGroupBox,
    QHBoxLayout,
    QLabel,
    QLineEdit,
    QListWidget,
    QMessageBox,
    QPushButton,
    QStackedWidget,
    QHeaderView,
    QTableView,
    QTextEdit,
    QVBoxLayout,
    QWidget,
)

from app.services.chatbot_service import ChatbotService
from app.services.resource_service import RESOURCE_COLUMNS, ResourceService
from app.services.api_client import ApiClientError


class ContentView(QWidget):
    def __init__(self, chatbot_service: Optional[ChatbotService] = None, resource_service: Optional[ResourceService] = None) -> None:
        super().__init__()
        self._chatbot_service = chatbot_service or ChatbotService()
        self._resource_service = resource_service or ResourceService()

        self._chatbot_df = pd.DataFrame()
        self._resource_df = pd.DataFrame(columns=RESOURCE_COLUMNS)

        self._tab_buttons: list[QPushButton] = []
        self._stack = QStackedWidget()

        self._chatbot_list = QListWidget()
        self._keyword_input = QLineEdit()
        self._response_input = QTextEdit()
        self._current_chatbot_id: Optional[int] = None

        self._resource_table_model = PandasModel(self._resource_df)
        self._resource_table_view = QTableView()
        self._resource_search = QLineEdit()

        self._build_ui()
        self._load_chatbot_entries()
        self._load_resources()

    # ------------------------------------------------------------------ #
    # UI construction helpers
    # ------------------------------------------------------------------ #
    def _build_ui(self) -> None:
        layout = QVBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)

        layout.addLayout(self._build_tabs())
        layout.addWidget(self._stack)

        self._stack.addWidget(self._build_chatbot_view())
        self._stack.addWidget(self._build_resources_view())

        self._tab_buttons[0].setChecked(True)
        self._stack.setCurrentIndex(0)

    def _build_tabs(self) -> QHBoxLayout:
        tabs_layout = QHBoxLayout()
        tab_names = ("Gestión de Chatbot", "Biblioteca de Recursos")
        for index, name in enumerate(tab_names):
            button = QPushButton(name)
            button.setCheckable(True)
            button.setStyleSheet(
                """
                QPushButton {
                    font-size: 14px;
                    padding: 10px;
                    border: 1px solid #ccc;
                    border-bottom: none;
                    background-color: #E6E6E6;
                }
                QPushButton:checked {
                    background-color: #fff;
                    border-top: 2px solid #A28FC9;
                }
                """
            )
            button.clicked.connect(lambda checked, idx=index: self._on_tab_selected(idx))
            tabs_layout.addWidget(button)
            self._tab_buttons.append(button)

        tabs_layout.addStretch()
        return tabs_layout

    def _build_chatbot_view(self) -> QWidget:
        view = QWidget()
        layout = QHBoxLayout(view)
        layout.setContentsMargins(10, 10, 10, 10)

        layout.addWidget(self._build_chatbot_list_panel())
        layout.addWidget(self._build_chatbot_editor_panel())
        return view

    def _build_chatbot_list_panel(self) -> QWidget:
        group = QGroupBox("Preguntas y Keywords")
        group_layout = QVBoxLayout(group)

        self._chatbot_list.setMinimumWidth(250)
        self._chatbot_list.setMaximumWidth(350)
        self._chatbot_list.currentRowChanged.connect(self._on_chatbot_selection_changed)
        group_layout.addWidget(self._chatbot_list)

        buttons_layout = QHBoxLayout()
        add_button = QPushButton("➕ Nuevo")
        delete_button = QPushButton("🗑️ Eliminar")
        add_button.clicked.connect(self._prepare_new_chatbot_entry)
        delete_button.clicked.connect(self._delete_chatbot_entry)
        buttons_layout.addWidget(add_button)
        buttons_layout.addWidget(delete_button)
        group_layout.addLayout(buttons_layout)
        return group

    def _build_chatbot_editor_panel(self) -> QWidget:
        group = QGroupBox("Detalle de Respuesta")
        layout = QVBoxLayout(group)

        layout.addWidget(QLabel("<strong>Pregunta / Keyword:</strong>"))
        self._keyword_input.setPlaceholderText("Ej: Horario de atención")
        layout.addWidget(self._keyword_input)

        layout.addWidget(QLabel("<strong>Respuesta del Chatbot:</strong>"))
        self._response_input.setPlaceholderText("Escribe la respuesta del chatbot aquí...")
        layout.addWidget(self._response_input)

        buttons_layout = QHBoxLayout()
        save_button = QPushButton("💾 Guardar Cambios")
        cancel_button = QPushButton("↩️ Limpiar/Cancelar")
        save_button.setStyleSheet("background-color: #A28FC9; color: white;")

        save_button.clicked.connect(self._save_chatbot_entry)
        cancel_button.clicked.connect(self._clear_chatbot_editor)

        buttons_layout.addStretch()
        buttons_layout.addWidget(save_button)
        buttons_layout.addWidget(cancel_button)

        layout.addLayout(buttons_layout)
        return group

    def _build_resources_view(self) -> QWidget:
        view = QWidget()
        layout = QVBoxLayout(view)
        layout.setContentsMargins(10, 10, 10, 10)

        search_layout = QHBoxLayout()
        self._resource_search.setPlaceholderText("Buscar recurso por nombre o tipo...")
        self._resource_search.textChanged.connect(self._filter_resources)
        search_layout.addWidget(self._resource_search)
        search_layout.addStretch()
        layout.addLayout(search_layout)

        self._resource_table_view.setModel(self._resource_table_model)
        self._resource_table_view.horizontalHeader().setSectionResizeMode(QHeaderView.Stretch)
        self._resource_table_view.setSelectionBehavior(QAbstractItemView.SelectRows)
        layout.addWidget(self._resource_table_view)

        buttons_layout = QHBoxLayout()
        view_button = QPushButton("👁️ Ver/Descargar")
        add_button = QPushButton("📂 Subir Recurso")
        delete_button = QPushButton("❌ Eliminar Recurso")

        view_button.clicked.connect(self._view_resource)
        add_button.clicked.connect(self._add_resource)
        delete_button.clicked.connect(self._delete_resource)

        buttons_layout.addStretch()
        buttons_layout.addWidget(view_button)
        buttons_layout.addWidget(add_button)
        buttons_layout.addWidget(delete_button)
        layout.addLayout(buttons_layout)

        return view

    # ------------------------------------------------------------------ #
    # Chatbot logic
    # ------------------------------------------------------------------ #
    def _load_chatbot_entries(self) -> None:
        try:
            self._chatbot_df = self._chatbot_service.list_as_dataframe()
        except ApiClientError as exc:
            QMessageBox.critical(self, "Error al cargar chatbot", str(exc))
            self._chatbot_df = pd.DataFrame(columns=["ID", "Pregunta/Keyword", "Respuesta"])
        self._chatbot_list.clear()
        if not self._chatbot_df.empty:
            self._chatbot_list.addItems(self._chatbot_df["Pregunta/Keyword"].tolist())
        self._clear_chatbot_editor(update_list=False)

    def _prepare_new_chatbot_entry(self) -> None:
        self._clear_chatbot_editor()
        self._keyword_input.setFocus()
        QMessageBox.information(
            self,
            "Nuevo Item",
            "Ingrese la 'Pregunta/Keyword' y la 'Respuesta', luego presione 'Guardar Cambios'.",
        )

    def _save_chatbot_entry(self) -> None:
        keyword = self._keyword_input.text().strip()
        response = self._response_input.toPlainText().strip()

        if not keyword or not response:
            QMessageBox.warning(self, "Advertencia", "Debe ingresar tanto la pregunta como la respuesta.")
            return

        try:
            if self._current_chatbot_id is None:
                self._chatbot_service.create_entry(keyword, response)
                QMessageBox.information(self, "Éxito", "Elemento agregado correctamente.")
            else:
                reply = QMessageBox.question(
                    self,
                    "Confirmar Modificación",
                    "¿Desea actualizar el elemento seleccionado?",
                    QMessageBox.Yes | QMessageBox.No,
                    QMessageBox.No,
                )
                if reply == QMessageBox.Yes:
                    self._chatbot_service.update_entry(self._current_chatbot_id, keyword, response)
                    QMessageBox.information(self, "Éxito", "Elemento actualizado correctamente.")
                else:
                    return
        except ApiClientError as exc:
            QMessageBox.critical(self, "Error", str(exc))
            return

        self._load_chatbot_entries()

    def _delete_chatbot_entry(self) -> None:
        if self._current_chatbot_id is None:
            QMessageBox.warning(self, "Advertencia", "Seleccione un elemento para eliminar.")
            return

        reply = QMessageBox.question(
            self,
            "Confirmar Eliminación",
            "¿Está seguro que desea eliminar el elemento seleccionado?",
            QMessageBox.Yes | QMessageBox.No,
            QMessageBox.No,
        )
        if reply == QMessageBox.Yes:
            try:
                self._chatbot_service.delete_entry(self._current_chatbot_id)
            except ApiClientError as exc:
                QMessageBox.critical(self, "Error", str(exc))
                return
            self._load_chatbot_entries()
            QMessageBox.information(self, "Éxito", "Elemento eliminado correctamente.")

    def _clear_chatbot_editor(self, update_list: bool = True) -> None:
        self._current_chatbot_id = None
        self._keyword_input.clear()
        self._response_input.clear()
        if update_list:
            self._chatbot_list.setCurrentRow(-1)

    def _on_chatbot_selection_changed(self, row: int) -> None:
        if row < 0 or self._chatbot_df.empty:
            self._clear_chatbot_editor(update_list=False)
            return

        data = self._chatbot_df.iloc[row]
        self._current_chatbot_id = int(data["ID"])
        self._keyword_input.setText(str(data["Pregunta/Keyword"]))
        self._response_input.setText(str(data["Respuesta"]))

    # ------------------------------------------------------------------ #
    # Resource logic (mocked data)
    # ------------------------------------------------------------------ #
    def _load_resources(self) -> None:
        try:
            self._resource_df = self._resource_service.list_resources()
        except ApiClientError as exc:
            QMessageBox.critical(self, "Error al cargar recursos", str(exc))
            if self._resource_df.empty:
                self._resource_df = self._build_default_resources()
        self._resource_table_model.set_data(self._resource_df)
        if hasattr(self, "_resource_search"):
            self._filter_resources(self._resource_search.text())

    def _filter_resources(self, text: str) -> None:
        if text:
            filtered = self._resource_df[
                self._resource_df.apply(
                    lambda row: row.astype(str).str.contains(text, case=False).any(),
                    axis=1,
                )
            ]
        else:
            filtered = self._resource_df
        self._resource_table_model.set_data(filtered)

    def _add_resource(self) -> None:
        QMessageBox.information(
            self,
            "No disponible",
            "La API actual solo expone la lista de recursos (GET /resources). "
            "Para crear o eliminar recursos se requiere habilitar esos endpoints en el backend.",
        )

    def _delete_resource(self) -> None:
        QMessageBox.information(
            self,
            "No disponible",
            "La eliminación de recursos no está implementada en la API.",
        )

    def _view_resource(self) -> None:
        selection = self._resource_table_view.currentIndex()
        if not selection.isValid():
            QMessageBox.information(self, "Recurso", "Seleccione un recurso para ver el detalle.")
            return
        row = self._resource_df.iloc[selection.row()]
        details = f"Nombre: {row.get('Nombre Archivo', '')}\nTipo: {row.get('Tipo', '')}"
        if row.get("URL"):
            details += f"\nURL: {row.get('URL')}"
        QMessageBox.information(self, "Recurso", details if details.strip() else "Sin datos disponibles.")

    # ------------------------------------------------------------------ #
    # Misc helpers
    # ------------------------------------------------------------------ #
    def _on_tab_selected(self, index: int) -> None:
        self._stack.setCurrentIndex(index)
        for idx, button in enumerate(self._tab_buttons):
            button.setChecked(idx == index)

    @staticmethod
    def _build_default_resources() -> pd.DataFrame:
        return pd.DataFrame(
            {
                "ID": [101, 102, 103],
                "Nombre Archivo": ["Manual_Usuario.pdf", "Guia_Inicio.docx", "Video_Tutorial.mp4"],
                "Tipo": ["PDF", "DOCX", "MP4"],
                "Tamaño (KB)": [1500, 450, 12000],
                "URL": ["", "", ""],
            }
        )


class PandasModel(QAbstractTableModel):
    """Modelo sencillo para mostrar DataFrames en QTableView."""

    def __init__(self, data: pd.DataFrame) -> None:
        super().__init__()
        self._data = data

    def rowCount(self, parent=None):  # type: ignore[override]
        return self._data.shape[0]

    def columnCount(self, parent=None):  # type: ignore[override]
        return self._data.shape[1]

    def data(self, index, role=Qt.DisplayRole):  # type: ignore[override]
        if not index.isValid():
            return QVariant()
        if role == Qt.DisplayRole:
            return str(self._data.iloc[index.row(), index.column()])
        return QVariant()

    def headerData(self, section, orientation, role=Qt.DisplayRole):  # type: ignore[override]
        if role == Qt.DisplayRole:
            if orientation == Qt.Horizontal:
                return str(self._data.columns[section])
            if orientation == Qt.Vertical:
                return str(self._data.index[section])
        return QVariant()

    def set_data(self, data: pd.DataFrame) -> None:
        self.beginResetModel()
        self._data = data
        self.endResetModel()


class ResourceDialog(QDialog):
    """Diálogo para capturar información básica de recursos."""

    def __init__(self) -> None:
        super().__init__()
        self.setWindowTitle("Subir Nuevo Recurso")
        self._inputs: dict[str, QLineEdit] = {}
        self._build_form()

    def _build_form(self) -> None:
        form_layout = QFormLayout()
        for field in ("Nombre Archivo", "Tipo", "Tamaño (KB)"):
            line_edit = QLineEdit()
            form_layout.addRow(QLabel(f"{field}:"), line_edit)
            self._inputs[field] = line_edit

        buttons = QDialogButtonBox(QDialogButtonBox.Ok | QDialogButtonBox.Cancel)
        buttons.accepted.connect(self.accept)
        buttons.rejected.connect(self.reject)

        main_layout = QVBoxLayout(self)
        main_layout.addLayout(form_layout)
        main_layout.addWidget(buttons)

    def get_data(self) -> dict[str, str]:
        return {field: line.text() for field, line in self._inputs.items()}
