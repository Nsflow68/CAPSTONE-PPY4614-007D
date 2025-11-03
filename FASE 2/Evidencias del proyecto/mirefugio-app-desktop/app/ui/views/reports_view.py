from __future__ import annotations

from pathlib import Path
from typing import Callable, Dict, Optional

import pandas as pd
from PyQt5.QtCore import Qt, QAbstractTableModel, QVariant
from PyQt5.QtWidgets import (
    QAbstractItemView,
    QFileDialog,
    QGroupBox,
    QHBoxLayout,
    QLabel,
    QListWidget,
    QListWidgetItem,
    QMessageBox,
    QPushButton,
    QStackedWidget,
    QTableView,
    QVBoxLayout,
    QWidget,
)
from PyQt5.QtWidgets import QHeaderView

from app.config import DATA_DIR
from app.database.repositories.chatbot_repository import ChatbotRepository
from app.database.repositories.user_repository import UserRepository


class ReportsView(QWidget):
    def __init__(self) -> None:
        super().__init__()

        self._reports = self._build_reports()
        self._current_report_key: Optional[str] = None
        self._current_dataframe = pd.DataFrame()
        self._current_model: Optional[PandasModel] = None

        main_layout = QVBoxLayout(self)
        main_layout.setContentsMargins(0, 0, 0, 0)

        tabs_layout = QHBoxLayout()
        self.btn_generator = QPushButton("Generación de Reportes")
        self.btn_export = QPushButton("Exportación Masiva")
        button_style = """
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
        self.btn_generator.setStyleSheet(button_style)
        self.btn_export.setStyleSheet(button_style)
        self.btn_generator.setCheckable(True)
        self.btn_export.setCheckable(True)
        tabs_layout.addWidget(self.btn_generator)
        tabs_layout.addWidget(self.btn_export)
        tabs_layout.addStretch()
        main_layout.addLayout(tabs_layout)

        self.stacked_widget = QStackedWidget()
        main_layout.addWidget(self.stacked_widget)

        self.generator_view = self.create_generator_view()
        self.export_view = self.create_export_view()
        self.stacked_widget.addWidget(self.generator_view)
        self.stacked_widget.addWidget(self.export_view)

        self.btn_generator.clicked.connect(lambda: self.stacked_widget.setCurrentIndex(0))
        self.btn_export.clicked.connect(lambda: self.stacked_widget.setCurrentIndex(1))
        self.btn_generator.setChecked(True)
        if self.reports_list.count():
            self.reports_list.setCurrentRow(0)

    # ------------------------------------------------------------------ #
    # Generación individual
    # ------------------------------------------------------------------ #
    def create_generator_view(self) -> QWidget:
        view = QWidget()
        layout = QHBoxLayout(view)
        layout.setContentsMargins(10, 10, 10, 10)

        # Panel de selección
        self.reports_list = QListWidget()
        self.reports_list.setSelectionMode(QAbstractItemView.SingleSelection)
        for key, meta in self._reports.items():
            item = QListWidgetItem(meta["name"])
            item.setData(Qt.UserRole, key)
            item.setToolTip(meta["description"])
            self.reports_list.addItem(item)
        self.reports_list.currentItemChanged.connect(self._on_report_selected)
        layout.addWidget(self.reports_list, 1)

        # Panel de detalle
        detail_group = QGroupBox("Resumen del reporte")
        detail_layout = QVBoxLayout(detail_group)

        self.report_title_label = QLabel("Selecciona un reporte")
        self.report_title_label.setAlignment(Qt.AlignLeft | Qt.AlignVCenter)
        self.report_title_label.setTextInteractionFlags(Qt.TextSelectableByMouse)
        detail_layout.addWidget(self.report_title_label)

        self.report_description_label = QLabel()
        self.report_description_label.setWordWrap(True)
        self.report_description_label.setObjectName("ReportDescriptionLabel")
        detail_layout.addWidget(self.report_description_label)

        self.report_insight_label = QLabel()
        self.report_insight_label.setWordWrap(True)
        self.report_insight_label.setStyleSheet("color: #555;")
        detail_layout.addWidget(self.report_insight_label)

        self.report_status_label = QLabel("Selecciona un reporte para visualizar los datos.")
        detail_layout.addWidget(self.report_status_label)

        self.report_table = QTableView()
        self.report_table.setObjectName("ReportPreviewTable")
        self.report_table.horizontalHeader().setSectionResizeMode(QHeaderView.Stretch)
        self.report_table.verticalHeader().setVisible(False)
        detail_layout.addWidget(self.report_table, 1)

        buttons_layout = QHBoxLayout()
        self.refresh_report_button = QPushButton("Actualizar datos")
        self.export_csv_button = QPushButton("Exportar CSV")
        self.export_excel_button = QPushButton("Exportar Excel")
        self.export_csv_button.setEnabled(False)
        self.export_excel_button.setEnabled(False)
        buttons_layout.addStretch()
        buttons_layout.addWidget(self.refresh_report_button)
        buttons_layout.addWidget(self.export_csv_button)
        buttons_layout.addWidget(self.export_excel_button)
        detail_layout.addLayout(buttons_layout)

        self.refresh_report_button.clicked.connect(self._refresh_current_report)
        self.export_csv_button.clicked.connect(lambda: self._export_report("csv"))
        self.export_excel_button.clicked.connect(lambda: self._export_report("excel"))

        layout.addWidget(detail_group, 2)
        return view

    # ------------------------------------------------------------------ #
    # Exportación masiva
    # ------------------------------------------------------------------ #
    def create_export_view(self) -> QWidget:
        view = QWidget()
        layout = QVBoxLayout(view)
        layout.setContentsMargins(10, 10, 10, 10)

        intro_label = QLabel(
            "Selecciona uno o varios reportes para exportarlos de manera masiva. "
            "La aplicación reutiliza las mismas fuentes de datos de la sección de generación individual."
        )
        intro_label.setWordWrap(True)
        layout.addWidget(intro_label)

        self.bulk_reports_list = QListWidget()
        self.bulk_reports_list.setSelectionMode(QAbstractItemView.MultiSelection)
        for key, meta in self._reports.items():
            item = QListWidgetItem(meta["name"])
            item.setData(Qt.UserRole, key)
            item.setToolTip(meta["description"])
            self.bulk_reports_list.addItem(item)
        layout.addWidget(self.bulk_reports_list, 1)

        bulk_buttons = QHBoxLayout()
        self.bulk_csv_button = QPushButton("Exportar selección a CSV")
        self.bulk_excel_button = QPushButton("Exportar selección a Excel")
        bulk_buttons.addStretch()
        bulk_buttons.addWidget(self.bulk_csv_button)
        bulk_buttons.addWidget(self.bulk_excel_button)
        layout.addLayout(bulk_buttons)

        self.bulk_csv_button.clicked.connect(lambda: self._export_bulk("csv"))
        self.bulk_excel_button.clicked.connect(lambda: self._export_bulk("excel"))

        layout.addStretch()
        return view

    # ------------------------------------------------------------------ #
    # Acciones y helpers
    # ------------------------------------------------------------------ #
    def _on_report_selected(self, current: Optional[QListWidgetItem], previous: Optional[QListWidgetItem]) -> None:
        if current is None:
            self._current_report_key = None
            self._current_dataframe = pd.DataFrame()
            self._current_model = None
            self.report_table.setModel(None)
            self.export_csv_button.setEnabled(False)
            self.export_excel_button.setEnabled(False)
            self.report_title_label.setText("Selecciona un reporte")
            self.report_description_label.clear()
            self.report_insight_label.clear()
            self.report_status_label.setText("Selecciona un reporte para visualizar los datos.")
            return

        key = current.data(Qt.UserRole)
        if isinstance(key, str):
            self._load_report(key)

    def _refresh_current_report(self) -> None:
        if self._current_report_key:
            self._load_report(self._current_report_key)

    def _load_report(self, key: str) -> None:
        meta = self._reports.get(key)
        if not meta:
            return

        self.report_title_label.setText(f"<h2>{meta['name']}</h2>")
        self.report_description_label.setText(meta["description"])
        self.report_insight_label.setText(meta.get("insight", ""))
        self.report_status_label.setText("Generando datos…")

        try:
            dataframe = meta["generator"]()
        except Exception as exc:  # noqa: BLE001
            self._current_dataframe = pd.DataFrame()
            self._current_model = None
            self.report_table.setModel(None)
            self.report_status_label.setText(f"Ocurrió un error al generar el reporte: {exc}")
            self.export_csv_button.setEnabled(False)
            self.export_excel_button.setEnabled(False)
            return

        self._current_report_key = key
        self._current_dataframe = dataframe

        if dataframe.empty:
            self._current_model = None
            self.report_table.setModel(None)
            self.report_status_label.setText("No hay datos disponibles para los filtros actuales.")
            self.export_csv_button.setEnabled(False)
            self.export_excel_button.setEnabled(False)
            return

        self._current_model = PandasModel(dataframe)
        self.report_table.setModel(self._current_model)
        self.report_table.resizeColumnsToContents()
        self.report_status_label.setText(f"Filas disponibles: {len(dataframe)}")
        self.export_csv_button.setEnabled(True)
        self.export_excel_button.setEnabled(True)

    def _export_report(self, kind: str) -> None:
        if self._current_dataframe.empty or not self._current_report_key:
            QMessageBox.information(self, "Exportación", "Genera y selecciona un reporte antes de exportar.")
            return

        meta = self._reports[self._current_report_key]
        suggested_name = self._slugify(meta["name"])

        if kind == "csv":
            path, _ = QFileDialog.getSaveFileName(
                self,
                "Guardar reporte en CSV",
                f"{suggested_name}.csv",
                "Archivos CSV (*.csv)",
            )
            if not path:
                return
            self._current_dataframe.to_csv(path, index=False)
            QMessageBox.information(self, "Exportación CSV", f"Reporte guardado correctamente en:\n{path}")
            return

        path, _ = QFileDialog.getSaveFileName(
            self,
            "Guardar reporte en Excel",
            f"{suggested_name}.xlsx",
            "Archivos Excel (*.xlsx)",
        )
        if not path:
            return
        try:
            self._current_dataframe.to_excel(path, index=False)
        except ValueError:
            QMessageBox.critical(
                self,
                "Exportación Excel",
                "No se pudo exportar a Excel. Instala 'openpyxl' o 'xlsxwriter' para habilitar este formato.",
            )
            return
        QMessageBox.information(self, "Exportación Excel", f"Reporte guardado correctamente en:\n{path}")

    def _export_bulk(self, kind: str) -> None:
        selected_items = self.bulk_reports_list.selectedItems()
        if not selected_items:
            QMessageBox.information(self, "Exportación", "Selecciona al menos un reporte para exportar.")
            return

        directory = QFileDialog.getExistingDirectory(self, "Selecciona la carpeta de destino")
        if not directory:
            return

        successes: list[str] = []
        failures: list[str] = []
        destination = Path(directory)

        for item in selected_items:
            key = item.data(Qt.UserRole)
            if not isinstance(key, str):
                continue
            meta = self._reports.get(key)
            if not meta:
                continue
            try:
                dataframe = meta["generator"]()
            except Exception as exc:  # noqa: BLE001
                failures.append(f"{meta['name']}: {exc}")
                continue

            if dataframe.empty:
                failures.append(f"{meta['name']}: sin datos para exportar.")
                continue

            filename = destination / f"{self._slugify(meta['name'])}.{ 'csv' if kind == 'csv' else 'xlsx'}"
            try:
                if kind == "csv":
                    dataframe.to_csv(filename, index=False)
                else:
                    try:
                        dataframe.to_excel(filename, index=False)
                    except ValueError:
                        failures.append(
                            f"{meta['name']}: instala 'openpyxl' o 'xlsxwriter' para exportar en Excel."
                        )
                        continue
            except Exception as exc:  # noqa: BLE001
                failures.append(f"{meta['name']}: {exc}")
            else:
                successes.append(meta["name"])

        summary_lines: list[str] = []
        if successes:
            summary_lines.append("Exportaciones correctas:")
            summary_lines.append(", ".join(successes))
        if failures:
            summary_lines.append("Incidencias detectadas:")
            summary_lines.extend(failures)
        if not summary_lines:
            summary_lines.append("No hubo exportaciones.")

        QMessageBox.information(self, "Resultado de exportación", "\n".join(summary_lines))

    # ------------------------------------------------------------------ #
    # Generadores de datos
    # ------------------------------------------------------------------ #
    def _build_reports(self) -> Dict[str, Dict[str, Callable[[], pd.DataFrame]]]:
        return {
            "user_metrics": {
                "name": "Métricas de usuarios",
                "description": (
                    "Visión general del crecimiento y actividad de las cuentas registradas en la plataforma."
                ),
                "insight": "Monitorea el tamaño de la comunidad y comprueba que el onboarding esté funcionando.",
                "generator": self._generate_user_metrics,
            },
            "role_distribution": {
                "name": "Distribución de roles y permisos",
                "description": (
                    "Detalle del número de cuentas por rol junto con su peso porcentual respecto del total."
                ),
                "insight": "Permite asegurar un balance saludable de administradores, moderadores y usuarios finales.",
                "generator": self._generate_role_distribution,
            },
            "chatbot_activity": {
                "name": "Participación del chatbot",
                "description": (
                    "Cobertura de la base de conocimiento del chatbot y volumen de contenido disponible por entrada."
                ),
                "insight": "Útil para localizar respuestas extensas o keywords con poco contenido y priorizar mejoras.",
                "generator": self._generate_chatbot_activity,
            },
            "emotional_insights": {
                "name": "Insights emocionales",
                "description": (
                    "Resumen de emociones registradas en los datos históricos, con medias de edad y actividad."
                ),
                "insight": "Ayuda a detectar tendencias emocionales relevantes para programas de acompañamiento.",
                "generator": self._generate_emotional_insights,
            },
            "content_resources": {
                "name": "Contenido y recursos",
                "description": (
                    "Listado de materiales de apoyo disponibles (manuales, guías, multimedia) con uso estimado."
                ),
                "insight": "Facilita identificar recursos críticos y planificar nuevas piezas para la biblioteca.",
                "generator": self._generate_content_resources,
            },
            "operational_health": {
                "name": "Salud operativa y mantenimiento",
                "description": (
                    "Estado general de servicios clave del sistema, métricas de rendimiento y tareas programadas."
                ),
                "insight": "Permite anticipar ventanas de mantenimiento y validar niveles de servicio acordados.",
                "generator": self._generate_operational_health,
            },
            "compliance_export": {
                "name": "Exportes para cumplimiento",
                "description": (
                    "Dataset estructurado con la información mínima requerida para auditorías y reportes externos."
                ),
                "insight": "Usa estos datos para cumplir con solicitudes regulatorias o integraciones con terceros.",
                "generator": self._generate_compliance_export,
            },
        }

    def _generate_user_metrics(self) -> pd.DataFrame:
        repo = UserRepository()
        users = repo.list_users()
        total_users = len(users)
        admins = sum(1 for user in users if (user.role or "").lower() == "admin")
        other_roles = total_users - admins
        unique_roles = {((user.role or "Usuario")).strip().title() for user in users}

        data = [
            {
                "Indicador": "Usuarios totales",
                "Valor": total_users,
                "Notas": "Incluye todas las cuentas registradas.",
            },
            {
                "Indicador": "Administradores",
                "Valor": admins,
                "Notas": "Usuarios con privilegios completos.",
            },
            {
                "Indicador": "Otros roles",
                "Valor": max(other_roles, 0),
                "Notas": "Moderadores y cuentas estándar.",
            },
            {
                "Indicador": "Roles únicos",
                "Valor": len(unique_roles),
                "Notas": ", ".join(sorted(unique_roles)) if unique_roles else "N/D",
            },
        ]
        return pd.DataFrame(data)

    def _generate_role_distribution(self) -> pd.DataFrame:
        repo = UserRepository()
        users = repo.list_users()
        total_users = len(users)
        if total_users == 0:
            return pd.DataFrame(columns=["Rol", "Cantidad", "Porcentaje"])

        counts: Dict[str, int] = {}
        for user in users:
            role = (user.role or "Usuario").strip()
            human_role = role if role else "Usuario"
            counts[human_role.title()] = counts.get(human_role.title(), 0) + 1

        data = [
            {
                "Rol": role,
                "Cantidad": count,
                "Porcentaje": round((count / total_users) * 100, 2),
            }
            for role, count in sorted(counts.items(), key=lambda item: item[1], reverse=True)
        ]
        return pd.DataFrame(data)

    def _generate_chatbot_activity(self) -> pd.DataFrame:
        repository = ChatbotRepository()
        entries = repository.list_records()
        if not entries:
            return pd.DataFrame(columns=["ID", "Keyword", "Palabras", "Caracteres"])

        data = []
        for entry in entries:
            response_text = entry.response or ""
            data.append(
                {
                    "ID": entry.id or "-",
                    "Keyword": entry.keyword,
                    "Palabras": len(response_text.split()),
                    "Caracteres": len(response_text),
                }
            )
        return pd.DataFrame(data).sort_values("Palabras", ascending=False)

    def _generate_emotional_insights(self) -> pd.DataFrame:
        data_path = DATA_DIR / "emotion_data.csv"
        if not data_path.exists():
            return pd.DataFrame(
                [
                    {"Emoción": "Sin datos", "Registros": 0, "Edad promedio": 0, "Actividad promedio": 0},
                ]
            )

        df = pd.read_csv(data_path)
        if df.empty:
            return pd.DataFrame(columns=["Emoción", "Registros", "Edad promedio", "Actividad promedio"])

        df["timestamp"] = pd.to_datetime(df["timestamp"])
        summary = (
            df.groupby("emotion")
            .agg(
                Registros=("emotion", "count"),
                Edad_promedio=("age", "mean"),
                Actividad_promedio=("activity_level", "mean"),
            )
            .reset_index()
            .rename(
                columns={
                    "emotion": "Emoción",
                    "Edad_promedio": "Edad promedio",
                    "Actividad_promedio": "Actividad promedio",
                }
            )
        )
        summary["Edad promedio"] = summary["Edad promedio"].round(1)
        summary["Actividad promedio"] = summary["Actividad promedio"].round(1)
        return summary.sort_values("Registros", ascending=False)

    def _generate_content_resources(self) -> pd.DataFrame:
        data = [
            {
                "Recurso": "Manual_Usuario.pdf",
                "Tipo": "PDF",
                "Descargas estimadas": 240,
                "Última actualización": "2025-08-01",
            },
            {
                "Recurso": "Guia_Inicio.docx",
                "Tipo": "DOCX",
                "Descargas estimadas": 195,
                "Última actualización": "2025-07-18",
            },
            {
                "Recurso": "Video_Tutorial.mp4",
                "Tipo": "MP4",
                "Descargas estimadas": 410,
                "Última actualización": "2025-09-02",
            },
            {
                "Recurso": "Protocolo_Contencion.pdf",
                "Tipo": "PDF",
                "Descargas estimadas": 130,
                "Última actualización": "2025-08-25",
            },
        ]
        return pd.DataFrame(data)

    def _generate_operational_health(self) -> pd.DataFrame:
        data = [
            {
                "Componente": "API principal",
                "Estado": "Operativo",
                "Detalle": "Latencia promedio 220 ms",
                "SLA": "99.5%",
            },
            {
                "Componente": "Panel PyQt",
                "Estado": "Operativo",
                "Detalle": "Sin incidencias registradas",
                "SLA": "99.9%",
            },
            {
                "Componente": "Base de datos SQLite",
                "Estado": "En observación",
                "Detalle": "Fragmentación detectada en índices",
                "SLA": "98.7%",
            },
            {
                "Componente": "Módulo de notificaciones",
                "Estado": "Programado",
                "Detalle": "Mantenimiento planificado 2025-09-12",
                "SLA": "95.0%",
            },
        ]
        return pd.DataFrame(data)

    def _generate_compliance_export(self) -> pd.DataFrame:
        repo = UserRepository()
        users = repo.list_users()
        if not users:
            return pd.DataFrame(columns=["ID", "Usuario", "Nombre completo", "Rol"])

        data = []
        for user in users:
            data.append(
                {
                    "ID": user.id or "",
                    "Usuario": user.username,
                    "Nombre completo": user.full_name or "",
                    "Rol": (user.role or "Usuario").title(),
                }
            )
        return pd.DataFrame(data).sort_values("Usuario")

    def _slugify(self, value: str) -> str:
        sanitized = "".join(ch.lower() if ch.isalnum() else "_" for ch in value)
        sanitized = "_".join(filter(None, sanitized.split("_")))
        return sanitized or "reporte"


class PandasModel(QAbstractTableModel):
    """Modelo mínimo para mostrar DataFrames en QTableView."""

    def __init__(self, dataframe: pd.DataFrame) -> None:
        super().__init__()
        self._dataframe = dataframe

    def rowCount(self, parent=None):  # type: ignore[override]
        return self._dataframe.shape[0]

    def columnCount(self, parent=None):  # type: ignore[override]
        return self._dataframe.shape[1]

    def data(self, index, role=Qt.DisplayRole):  # type: ignore[override]
        if not index.isValid():
            return QVariant()
        if role == Qt.DisplayRole:
            value = self._dataframe.iat[index.row(), index.column()]
            return "" if pd.isna(value) else str(value)
        return QVariant()

    def headerData(self, section, orientation, role=Qt.DisplayRole):  # type: ignore[override]
        if role != Qt.DisplayRole:
            return QVariant()
        if orientation == Qt.Horizontal:
            return str(self._dataframe.columns[section])
        return str(self._dataframe.index[section])
