from __future__ import annotations

import os
from datetime import datetime
from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED

from PyQt5.QtWidgets import (
    QWidget,
    QVBoxLayout,
    QHBoxLayout,
    QLabel,
    QTextEdit,
    QPushButton,
    QCheckBox,
    QGroupBox,
    QLineEdit,
    QStackedWidget,
    QGridLayout,
    QScrollArea,
    QListWidget,
    QListWidgetItem,
    QMessageBox,
)
from PyQt5.QtCore import Qt

from app.config import get_database_path, DATA_DIR
    ############################
from app.services.api_client import ApiClient, ApiClientError


class NotificationsView(QWidget):
    def __init__(self):
        super().__init__()
        self._client = ApiClient()
        self._maintenance_active = False
        self._backup_dir = DATA_DIR / "backups"
        self._backup_dir.mkdir(exist_ok=True)

        main_layout = QVBoxLayout(self)
        main_layout.setContentsMargins(0, 0, 0, 0)

        # --------------------------
        # SOLO 2 PESTAÑAS
        # --------------------------
        tabs_layout = QHBoxLayout()

        self.btn_status = QPushButton("Estado y Mantenimiento")
        self.btn_backup = QPushButton("Copias de Seguridad")
        self._tab_buttons = [self.btn_status, self.btn_backup]

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
        for btn in self._tab_buttons:
            btn.setStyleSheet(button_style)
            btn.setCheckable(True)
            btn.setAutoExclusive(True)

        tabs_layout.addWidget(self.btn_status)
        tabs_layout.addWidget(self.btn_backup)
        tabs_layout.addStretch()
        main_layout.addLayout(tabs_layout)

        # Contenedor dinámico de vistas
        self.stacked_widget = QStackedWidget()
        main_layout.addWidget(self.stacked_widget)

        # --- SOLO 2 VISTAS ---
        self.status_view = self.create_status_view()
        self.backup_view = self.create_backup_view()

        self.stacked_widget.addWidget(self.status_view)
        self.stacked_widget.addWidget(self.backup_view)

        for index, button in enumerate(self._tab_buttons):
            button.clicked.connect(lambda checked, idx=index: self._select_tab(idx))

        self._select_tab(0)

    # ----------------------------------------------------------------------
    # --- Panel 1: Estado y Mantenimiento ---
    # ----------------------------------------------------------------------
    def create_status_view(self):
        view = QWidget()
        layout = QVBoxLayout(view)
        layout.setContentsMargins(10, 10, 10, 10)
        
        # --- Panel de Métricas ---
        metrics_group = QGroupBox("Panel de Métricas del Sistema")
        metrics_layout = QGridLayout(metrics_group)
        metrics_layout.setVerticalSpacing(10)

        self.lbl_server_status = QLabel("—")
        self.lbl_db_perf = QLabel("—")
        self.lbl_storage = QLabel("—")
        self.lbl_users = QLabel("—")

        metrics_layout.addWidget(QLabel("<strong>Estado del Servidor:</strong>"), 0, 0)
        metrics_layout.addWidget(self.lbl_server_status, 0, 1)
        metrics_layout.addWidget(QLabel("<strong>Rendimiento DB:</strong>"), 1, 0)
        metrics_layout.addWidget(self.lbl_db_perf, 1, 1)
        metrics_layout.addWidget(QLabel("<strong>Uso de Almacenamiento:</strong>"), 2, 0)
        metrics_layout.addWidget(self.lbl_storage, 2, 1)
        metrics_layout.addWidget(QLabel("<strong>Usuarios Activos (24h):</strong>"), 3, 0)
        metrics_layout.addWidget(self.lbl_users, 3, 1)

        refresh_btn = QPushButton("↻ Refrescar estado")
        refresh_btn.setStyleSheet("padding: 6px 12px; border-radius: 6px;")
        refresh_btn.clicked.connect(self._refresh_status)
        metrics_layout.addWidget(refresh_btn, 0, 2, 1, 1, alignment=Qt.AlignRight)

        layout.addWidget(metrics_group)

        # --- Panel de Mantenimiento ---
        maint_group = QGroupBox("Tareas de Mantenimiento")
        maint_layout = QVBoxLayout(maint_group)

        self.maint_checkbox = QCheckBox("Modo mantenimiento activo")
        self.maint_checkbox.stateChanged.connect(self._toggle_maintenance)

        plan_btn = QPushButton("Programar mantenimiento")
        plan_btn.setStyleSheet("padding: 6px 10px;")
        plan_btn.clicked.connect(lambda: self._append_log("Mantenimiento programado."))

        optimize_btn = QPushButton("Optimizar base de datos")
        optimize_btn.setStyleSheet("padding: 6px 10px;")
        optimize_btn.clicked.connect(self._run_optimization)

        maint_layout.addWidget(self.maint_checkbox)
        maint_layout.addWidget(plan_btn)
        maint_layout.addWidget(optimize_btn)

        # Log
        self.maint_log = QTextEdit()
        self.maint_log.setReadOnly(True)
        self.maint_log.setMinimumHeight(120)
        self.maint_log.setPlaceholderText("Bitácora de mantenimiento...")
        maint_layout.addWidget(self.maint_log)

        layout.addWidget(maint_group)
        layout.addStretch()

        self._refresh_status()
        return view

    # ----------------------------------------------------------------------
    # --- Panel 2: Copias de Seguridad ---
    # ----------------------------------------------------------------------
    def create_backup_view(self):
        view = QWidget()
        layout = QVBoxLayout(view)
        layout.setContentsMargins(10, 10, 10, 10)
        
        manual_group = QGroupBox("Ejecución Manual de Copias de Seguridad")
        manual_layout = QVBoxLayout(manual_group)
        
        manual_layout.addWidget(QLabel("Genera una copia de seguridad inmediata."))

        backup_button = QPushButton("Realizar Copia de Seguridad Ahora 💾")
        backup_button.setStyleSheet("background-color: #5cb85c; color: white; padding: 12px;")
        backup_button.clicked.connect(self._create_backup)

        manual_layout.addWidget(backup_button)
        layout.addWidget(manual_group)

        restore_group = QGroupBox("Restauración del Sistema")
        restore_layout = QVBoxLayout(restore_group)
        
        restore_layout.addWidget(QLabel("<strong>Seleccionar copia de seguridad:</strong>"))

        self.backup_list = QListWidget()
        self.backup_list.setMaximumHeight(150)
        restore_layout.addWidget(self.backup_list)

        restore_layout.addWidget(
            QLabel("⚠️ <span style='color: red;'>Restaurar sobrescribirá los datos actuales.</span>")
        )

        restore_button = QPushButton("Restaurar desde copia ↩️")
        restore_button.setStyleSheet("background-color: #d9534f; color: white; padding: 12px;")
        restore_button.clicked.connect(self._restore_backup)

        restore_layout.addWidget(restore_button)
        layout.addWidget(restore_group)

        layout.addStretch()
        self._reload_backups()
        return view

    # ------------------------------------------------------------------ #
    # Tabs
    # ------------------------------------------------------------------ #
    def _select_tab(self, index: int) -> None:
        self.stacked_widget.setCurrentIndex(index)
        for i, btn in enumerate(self._tab_buttons):
            btn.blockSignals(True)
            btn.setChecked(i == index)
            btn.blockSignals(False)

    # ------------------------------------------------------------------ #
    # Estado / mantenimiento
    # ------------------------------------------------------------------ #
    def _refresh_status(self) -> None:
        try:
            response = self._client.get("/health")
            db_time = response.data.get("db_time", "—")
            self.lbl_server_status.setText("<span style='color: green;'>🟢 OK</span>")
            self.lbl_db_perf.setText(f"DB OK ({db_time})")
        except ApiClientError:
            self.lbl_server_status.setText("<span style='color: red;'>🔴 CAÍDO</span>")
            self.lbl_db_perf.setText("DB sin respuesta")

        self.lbl_storage.setText("50% (500 GB / 1 TB)")
        self.lbl_users.setText("1.250")

    def _toggle_maintenance(self) -> None:
        state = "activado" if self.maint_checkbox.isChecked() else "desactivado"
        self._append_log(f"Modo mantenimiento {state}.")

    def _run_optimization(self) -> None:
        self._append_log("Optimizando base de datos...")
        self._append_log("Optimización completa.")

    def _append_log(self, msg: str) -> None:
        ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        self.maint_log.append(f"[{ts}] {msg}")

    # ------------------------------------------------------------------ #
    # Copias de seguridad
    # ------------------------------------------------------------------ #
    def _create_backup(self) -> None:
        db_path = get_database_path()
        stamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_name = f"backup_{stamp}.zip"
        backup_path = self._backup_dir / backup_name

        try:
            with ZipFile(backup_path, "w", compression=ZIP_DEFLATED) as zipf:
                if db_path.exists():
                    zipf.write(db_path, arcname=db_path.name)
                if DATA_DIR.exists():
                    for child in DATA_DIR.rglob("*"):
                        if child.is_file() and child.name != backup_name:
                            zipf.write(child, arcname=child.relative_to(DATA_DIR.parent))

            QMessageBox.information(self, "Copia creada", f"{backup_path}")
            self._reload_backups()
        except Exception as exc:
            QMessageBox.critical(self, "Error", f"No se pudo crear la copia:\n{exc}")

    def _reload_backups(self) -> None:
        self.backup_list.clear()
        if not self._backup_dir.exists():
            return
        backups = sorted(self._backup_dir.glob("backup_*.zip"), reverse=True)
        for backup in backups:
            item = QListWidgetItem(f"{backup.name} ({backup.stat().st_size / (1024*1024):.1f} MB)")
            item.setData(Qt.UserRole, backup)
            self.backup_list.addItem(item)

    def _restore_backup(self) -> None:
        selected = self.backup_list.currentItem()
        if not selected:
            QMessageBox.warning(self, "Restauración", "Seleccione un backup.")
            return

        backup_path: Path = selected.data(Qt.UserRole)
        confirm = QMessageBox.question(
            self,
            "Confirmar restauración",
            f"¿Restaurar {backup_path.name}?",
            QMessageBox.Yes | QMessageBox.No,
            QMessageBox.No,
        )
        if confirm != QMessageBox.Yes:
            return

        try:
            with ZipFile(backup_path, "r") as zipf:
                zipf.extractall(DATA_DIR.parent)
            QMessageBox.information(self, "Restaurado", "Restauración completa. Reinicie la app.")
        except Exception as exc:
            QMessageBox.critical(self, "Error", f"No se pudo restaurar:\n{exc}")


if __name__ == "__main__":
    from PyQt5.QtWidgets import QApplication
    import sys

    app = QApplication(sys.argv)
    window = NotificationsView()
    window.setWindowTitle("Mantenimiento y Copias de Seguridad")
    window.resize(800, 600)
    window.show()
    sys.exit(app.exec_())
