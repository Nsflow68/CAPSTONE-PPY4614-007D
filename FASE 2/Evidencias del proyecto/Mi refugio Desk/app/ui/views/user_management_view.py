from itertools import cycle, islice
from typing import Optional, Set

import pandas as pd
import seaborn as sns
from PyQt5.QtGui import QIcon
from PyQt5.QtWidgets import (
    QWidget,
    QVBoxLayout,
    QHBoxLayout,
    QPushButton,
    QLineEdit,
    QTableView,
    QHeaderView,
    QLabel,
    QStackedWidget,
    QMessageBox,
    QDialog,
    QFormLayout,
    QDialogButtonBox,
    QComboBox,
    QListWidget,
    QListWidgetItem,
    QGroupBox,
    QGridLayout,
    QInputDialog,
)
from PyQt5.QtWidgets import QAbstractItemView
from PyQt5.QtCore import Qt, QAbstractTableModel, QVariant
from matplotlib.backends.backend_qt5agg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.figure import Figure

from app.models.user import UserRecord
from app.services.api_client import ApiClientError
from app.services.user_service import USER_COLUMNS, UserService

# --- Clases de la Vista ---

class UserManagementView(QWidget):
    def __init__(self, current_user: Optional[UserRecord] = None, user_service: Optional[UserService] = None):
        super().__init__()
        self._current_user = current_user
        self._user_service = user_service or UserService()

        main_layout = QVBoxLayout(self)
        main_layout.setContentsMargins(0, 0, 0, 0)

        self.user_data = pd.DataFrame(columns=USER_COLUMNS)
        self.activity_data = pd.DataFrame()
        self.filtered_activity_data = pd.DataFrame()
        self._filtered_user_ids: Set[int] = set()

        self.role_data = pd.DataFrame({
            'Rol': ['Admin', 'Moderador', 'Usuario'],
            'Permiso: Edición': ['Sí', 'No', 'No'],
            'Permiso: Reportes': ['Sí', 'Sí', 'No'],
            'Descripción': ['Control total', 'Moderar contenido', 'Acceso básico']
        })

        # Pestañas de submenú
        tabs_layout = QHBoxLayout()
        self.btn_control = QPushButton("Control de Usuarios")
        self.btn_analisis = QPushButton("Análisis de Actividad")
        self._tab_buttons = [self.btn_control, self.btn_analisis]

        # Estilo de los botones (mismo violeta)
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

        tabs_layout.addWidget(self.btn_control)
        tabs_layout.addWidget(self.btn_analisis)
        tabs_layout.addStretch()

        main_layout.addLayout(tabs_layout)

        # Contenedor de paneles dinámicos
        self.stacked_widget = QStackedWidget()
        main_layout.addWidget(self.stacked_widget)

        # Vistas internas
        self.control_view = self.create_control_view()
        self.analisis_view = self.create_analisis_view()

        self.stacked_widget.addWidget(self.control_view)
        self.stacked_widget.addWidget(self.analisis_view)

        for index, button in enumerate(self._tab_buttons):
            button.clicked.connect(lambda checked, idx=index: self._select_tab(idx))

        self._select_tab(0)
        self._load_users_from_api(initial=True)

    def _select_tab(self, index: int) -> None:
        """Activa una pestaña y desmarca el resto."""
        self.stacked_widget.setCurrentIndex(index)
        for i, button in enumerate(self._tab_buttons):
            button.blockSignals(True)
            button.setChecked(i == index)
            button.blockSignals(False)

    # --- Panel 1: Control de Usuarios (CRUD Mejorado) ---
    def create_control_view(self):
        view = QWidget()
        layout = QVBoxLayout(view)

        # Búsqueda y Filtros
        search_filter_group = QGroupBox("Búsqueda y Filtros Rápidos")
        search_layout = QHBoxLayout(search_filter_group)
        self.search_bar = QLineEdit()
        self.search_bar.setPlaceholderText("Buscar por Usuario, Nombre, ID o Rol...")
        self.search_bar.textChanged.connect(self.filter_users)
        
        self.status_filter_combo = QComboBox()
        self.status_filter_combo.addItem("Todos los Estados")
        self.status_filter_combo.addItems(self.user_data['Estado'].unique())
        self.status_filter_combo.currentIndexChanged.connect(self.filter_users)
        
        search_layout.addWidget(self.search_bar)
        search_layout.addWidget(QLabel("Filtrar por Estado:"))
        search_layout.addWidget(self.status_filter_combo)
        layout.addWidget(search_filter_group)

        # Tabla de Usuarios
        self.table_view = QTableView()
        self.table_model = PandasModel(self.user_data)
        self.table_view.setModel(self.table_model)
        self.table_view.horizontalHeader().setSectionResizeMode(QHeaderView.Stretch)
        self.table_view.setSelectionBehavior(QAbstractItemView.SelectRows)
        self.table_view.setSelectionMode(QAbstractItemView.SingleSelection)
        layout.addWidget(self.table_view)

        # Botones de CRUD (Mejorados visualmente)
        crud_buttons_layout = QHBoxLayout()
        self.add_btn = QPushButton("➕ Agregar Usuario")        
        self.modify_btn = QPushButton("Modificar")
        self.delete_btn = QPushButton("Eliminar")
        self.modify_btn.setStyleSheet("""
            QPushButton {
                background-color: #f0f0f0; color: #333; padding: 10px 14px; border-radius: 6px;
            }
            QPushButton:disabled {
                background-color: #e0e0e0; color: #999;
            }
            QPushButton:hover:!disabled {
                background-color: #dcdcdc;
            }
        """)
        self.modify_btn.setMinimumWidth(120)
        self.add_btn.setStyleSheet("background-color: #4caf50; color: white; padding: 10px 14px; border-radius: 6px;")
        self.delete_btn.setStyleSheet("background-color: #e74c3c; color: white; padding: 10px 14px; border-radius: 6px;")
        self.modify_btn.setEnabled(False)
        self.delete_btn.setEnabled(False)
        
        self.add_btn.clicked.connect(self.add_user)
        self.modify_btn.clicked.connect(self.modify_user)
        self.delete_btn.clicked.connect(self.delete_user)

        crud_buttons_layout.addStretch()
        crud_buttons_layout.addWidget(self.add_btn)
        crud_buttons_layout.addWidget(self.modify_btn)
        crud_buttons_layout.addWidget(self.delete_btn)
        layout.addLayout(crud_buttons_layout)

        # Habilitamos botones según selección
        if self.table_view.selectionModel():
            self.table_view.selectionModel().selectionChanged.connect(self._on_table_selection_changed)

        return view

    def filter_users(self, *args):
        text = self.search_bar.text()
        status = self.status_filter_combo.currentText()
        
        filtered_df = self.user_data.copy()

        # Filtrar por texto (global)
        if text:
            filtered_df = filtered_df[filtered_df.apply(lambda row: row.astype(str).str.contains(text, case=False).any(), axis=1)]

        # Filtrar por estado
        if status != "Todos los Estados":
            filtered_df = filtered_df[filtered_df['Estado'] == status]
            
        self.table_model.set_data(filtered_df)

    def _load_users_from_api(self, initial: bool = False) -> None:
        try:
            df = self._user_service.list_users_dataframe()
        except ApiClientError as exc:
            title = "Error de conexión" if initial else "Error al actualizar usuarios"
            QMessageBox.critical(self, title, str(exc))
            return

        self.user_data = df if not df.empty else pd.DataFrame(columns=USER_COLUMNS)
        self._ensure_current_user_in_dataset()
        self._sync_user_views()

    def _sync_user_views(self) -> None:
        if hasattr(self, 'table_model'):
            self.table_model.set_data(self.user_data)

        if hasattr(self, 'user_list'):
            self.user_list.clear()
            if not self.user_data.empty and 'Nombre' in self.user_data:
                self.user_list.addItems(self.user_data['Nombre'])

        self._refresh_status_filter_options()
        self._rebuild_activity_dataset()
        self._populate_user_filter_list()
        self._apply_activity_filter(initial=True)

    def _refresh_status_filter_options(self) -> None:
        if not hasattr(self, 'status_filter_combo'):
            return
        current = self.status_filter_combo.currentText() if self.status_filter_combo.count() else "Todos los Estados"
        self.status_filter_combo.blockSignals(True)
        self.status_filter_combo.clear()
        self.status_filter_combo.addItem("Todos los Estados")
        if 'Estado' in self.user_data:
            for status in sorted({str(v) for v in self.user_data['Estado'].dropna().unique()}):
                self.status_filter_combo.addItem(status)
        index = self.status_filter_combo.findText(current)
        if index != -1:
            self.status_filter_combo.setCurrentIndex(index)
        self.status_filter_combo.blockSignals(False)

    def _rebuild_activity_dataset(self) -> None:
        if self.user_data.empty:
            self.activity_data = pd.DataFrame(columns=['user_id', 'login_count', 'chatbot_sessions'])
            self.filtered_activity_data = self.activity_data.copy()
            self._filtered_user_ids = set()
            return

        sample_login_counts = [50, 20, 100, 35, 78, 60, 42]
        sample_chatbot_sessions = [20, 5, 40, 15, 60, 30, 18]
        length = len(self.user_data)
        login_counts = list(islice(cycle(sample_login_counts), length))
        chatbot_sessions = list(islice(cycle(sample_chatbot_sessions), length))
        ids_series = self.user_data['ID'].fillna(0).astype(int)
        self.activity_data = pd.DataFrame({
            'user_id': ids_series,
            'login_count': login_counts,
            'chatbot_sessions': chatbot_sessions
        })
        self.filtered_activity_data = self.activity_data.copy()
        self._filtered_user_ids = set(ids_series.tolist())

    def _ensure_current_user_in_dataset(self) -> Optional[int]:
        if not self._current_user:
            return None
        username = self._current_user.username
        if 'Usuario' not in self.user_data.columns:
            return None
        if not self.user_data[self.user_data['Usuario'] == username].empty:
            return None

        existing_ids = self.user_data['ID'].dropna()
        new_id = int(existing_ids.max() + 1) if not existing_ids.empty else 1
        display_name = self._current_user.full_name or username
        raw_role = (self._current_user.role or '').strip().lower()
        if raw_role == 'admin':
            role_value = 'Admin'
        elif raw_role:
            role_value = raw_role.title()
        else:
            role_value = 'Admin'

        new_row = {
            'ID': new_id,
            'Usuario': username,
            'Nombre': display_name,
            'Género': 'No especificado',
            'Edad': pd.NA,
            'Rol': role_value,
            'Estado': 'Activo',
            'Contraseña': "********" if self._current_user.password_hash else "",
        }
        new_df = pd.DataFrame([new_row])[self.user_data.columns]
        self.user_data = pd.concat([self.user_data, new_df], ignore_index=True)

        if hasattr(self, '_filtered_user_ids'):
            self._filtered_user_ids.add(new_id)

        return new_id

    def set_current_user(self, user: Optional[UserRecord]) -> None:
        self._current_user = user
        self._load_users_from_api()

    def add_user(self):
        dialog = UserDialog(
            "Agregar Usuario",
            self.user_data.columns,
            roles=self.role_data['Rol'].tolist(),
            gender_options=['Masculino', 'Femenino', 'No binario'],
            require_password=True,
        )
        if dialog.exec_() == QDialog.Accepted:
            new_user_data = dialog.get_data()
            password_plain = new_user_data.pop("password_raw", None)
            if not password_plain:
                QMessageBox.warning(self, "Validación", "La contraseña es obligatoria.")
                return
            try:
                self._user_service.create_user(
                    username=new_user_data.get('Usuario', ''),
                    password=password_plain,
                    full_name=new_user_data.get('Nombre'),
                    role=new_user_data.get('Rol', 'Usuario'),
                )
            except ApiClientError as exc:
                QMessageBox.critical(self, "Error al crear usuario", str(exc))
                return

            QMessageBox.information(self, "Éxito", "Usuario agregado correctamente.")
            self._load_users_from_api()


    def modify_user(self):
        selected_index = self.table_view.currentIndex()
        if not selected_index.isValid():
            QMessageBox.warning(self, "Advertencia", "Seleccione un usuario para modificar.")
            return

        row = selected_index.row()
        current_data = self.table_model._data.iloc[row].to_dict()

        dialog = UserDialog(
            "Modificar Usuario",
            self.user_data.columns,
            current_data,
            self.role_data['Rol'].tolist(),
            ['Masculino', 'Femenino', 'No binario'],
        )

        if dialog.exec_() != QDialog.Accepted:
            return

        modified_data = dialog.get_data()
        password_plain = modified_data.pop("password_raw", None)

        summary = "\n".join(
            [
                f"Usuario: {modified_data.get('Usuario') or current_data.get('Usuario')}",
                f"Nombre: {modified_data.get('Nombre') or current_data.get('Nombre')}",
                f"Rol: {modified_data.get('Rol') or current_data.get('Rol')}",
            ]
        )

        msg = QMessageBox(self)
        msg.setIcon(QMessageBox.Question)
        msg.setWindowTitle("Aplicar cambios")
        msg.setText(f"¿Aplicar estos cambios?\n\n{summary}")
        msg.setStandardButtons(QMessageBox.Yes | QMessageBox.No)
        msg.button(QMessageBox.Yes).setText("Sí")
        msg.button(QMessageBox.No).setText("No")
        reply = msg.exec_()
        if reply != QMessageBox.Yes:
            return

        try:
            self._user_service.update_user(
                int(current_data['ID']),
                username=modified_data.get('Usuario'),
                full_name=modified_data.get('Nombre'),
                role=modified_data.get('Rol'),
                status=modified_data.get('Estado'),
                password=password_plain or None,
            )
        except ApiClientError as exc:
            QMessageBox.critical(self, "Error al modificar", str(exc))
            return

        QMessageBox.information(self, "Éxito", "Usuario modificado correctamente.")
        self._load_users_from_api()

            
    def delete_user(self):
        selected_index = self.table_view.currentIndex()
        if not selected_index.isValid():
            QMessageBox.warning(self, "Advertencia", "Seleccione un usuario para eliminar.")
            return
        msg = QMessageBox(self)
        msg.setIcon(QMessageBox.Question)
        msg.setWindowTitle("Confirmar eliminación")
        msg.setText("¿Está seguro que desea eliminar el usuario seleccionado?")
        msg.setStandardButtons(QMessageBox.Yes | QMessageBox.No)
        msg.button(QMessageBox.Yes).setText("Sí")
        msg.button(QMessageBox.No).setText("No")

        reply = msg.exec_()

        if reply == QMessageBox.Yes:
            row_index_in_filtered_df = selected_index.row()
            user_id_to_delete = self.table_model._data.iloc[row_index_in_filtered_df]['ID']
            try:
                self._user_service.delete_user(int(user_id_to_delete))
            except ApiClientError as exc:
                QMessageBox.critical(self, "Error al eliminar", str(exc))
                return

            QMessageBox.information(self, "Éxito", "Usuario eliminado correctamente.")
            self._load_users_from_api()


    # --- Panel 2: Gestión de Roles (Mejorado) ---
    def create_roles_view(self):
        view = QWidget()
        layout = QHBoxLayout(view)
        
        # --- Columna Izquierda: Definición de Roles y Permisos ---
        roles_group = QGroupBox("Definición de Roles y Permisos")
        roles_layout = QVBoxLayout(roles_group)

        self.roles_table_view = QTableView()
        self.roles_table_model = PandasModel(self.role_data)
        self.roles_table_view.setModel(self.roles_table_model)
        self.roles_table_view.horizontalHeader().setSectionResizeMode(QHeaderView.Stretch)
        roles_layout.addWidget(self.roles_table_view)

        roles_buttons = QHBoxLayout()
        add_role_btn = QPushButton("➕ Nuevo Rol")
        edit_permissions_btn = QPushButton("🛠️ Editar Permisos")
        add_role_btn.setStyleSheet("padding: 8px 12px; border-radius: 6px; background-color: #e8e3f5;")
        edit_permissions_btn.setStyleSheet("padding: 8px 12px; border-radius: 6px; background-color: #e8e3f5;")
        roles_buttons.addWidget(add_role_btn)
        roles_buttons.addWidget(edit_permissions_btn)
        roles_layout.addLayout(roles_buttons)
        
        add_role_btn.clicked.connect(self._add_role)
        edit_permissions_btn.clicked.connect(lambda: QMessageBox.information(self, "Permisos", "Define permisos en la API/DB según tu modelo."))

        layout.addWidget(roles_group, 2) # Ocupa 2/3

        # --- Columna Derecha: Asignación Rápida ---
        assign_group = QGroupBox("Asignación Rápida de Rol")
        assign_layout = QVBoxLayout(assign_group)
        
        assign_layout.addWidget(QLabel("<strong>1. Seleccionar Usuario:</strong>"))
        self.user_list = QListWidget()
        self.user_list.setSelectionMode(QAbstractItemView.SingleSelection)
        if not self.user_data.empty and 'Nombre' in self.user_data:
            self.user_list.addItems(self.user_data['Nombre'])
        assign_layout.addWidget(self.user_list)
        
        assign_layout.addWidget(QLabel("<strong>2. Seleccionar Rol:</strong>"))
        self.role_combo_assign = QComboBox()
        self.role_combo_assign.addItems(self.role_data['Rol'])
        assign_layout.addWidget(self.role_combo_assign)
        
        assign_btn = QPushButton("✔️ Asignar Rol")
        assign_btn.setStyleSheet("background-color: #A28FC9; color: white; padding: 10px;")
        assign_btn.clicked.connect(self.assign_role)
        assign_layout.addWidget(assign_btn)
        
        assign_layout.addStretch()

        layout.addWidget(assign_group, 1) # Ocupa 1/3
        return view

    def assign_role(self):
        selected_user_item = self.user_list.currentItem()
        selected_role = self.role_combo_assign.currentText()
        if selected_user_item:
            user_name = selected_user_item.text()
            row = self.user_data[self.user_data['Nombre'] == user_name]
            if row.empty or 'ID' not in row.columns:
                QMessageBox.warning(self, "Advertencia", "No se pudo determinar el usuario seleccionado.")
                return
            user_id = int(row.iloc[0]['ID'])
            try:
                self._user_service.update_user(user_id, role=selected_role)
            except ApiClientError as exc:
                QMessageBox.critical(self, "Error al actualizar rol", str(exc))
                return
            QMessageBox.information(self, "Éxito", f"Rol de '{user_name}' asignado a '{selected_role}'.")
            self._load_users_from_api()
        else:
            QMessageBox.warning(self, "Advertencia", "Seleccione un usuario de la lista para asignar el rol.")

    def _add_role(self) -> None:
        text, ok = QInputDialog.getText(self, "Nuevo rol", "Nombre del rol:")
        if not ok or not text.strip():
            return
        role_name = text.strip()
        if role_name in self.role_data['Rol'].values:
            QMessageBox.information(self, "Roles", "Ese rol ya existe.")
            return
        new_row = {
            'Rol': role_name,
            'Permiso: Edición': 'No',
            'Permiso: Reportes': 'No',
            'Descripción': '',
        }
        self.role_data = pd.concat([self.role_data, pd.DataFrame([new_row])], ignore_index=True)
        self.roles_table_model.set_data(self.role_data)
        self.role_combo_assign.addItem(role_name)
        QMessageBox.information(self, "Roles", f"Rol '{role_name}' añadido (gestiona permisos en la API/DB si aplica).")


    # --- Panel 3: Análisis de Actividad (Profundizado) ---
    def create_analisis_view(self):
        view = QWidget()
        layout = QVBoxLayout(view)

        self._rebuild_activity_dataset()

        filter_group = QGroupBox("Filtros de Usuarios")
        filter_layout = QVBoxLayout(filter_group)

        search_layout = QHBoxLayout()
        search_layout.addWidget(QLabel("Buscar:"))
        self.user_filter_search = QLineEdit()
        self.user_filter_search.setPlaceholderText("Nombre o ID...")
        self.user_filter_search.textChanged.connect(self._filter_user_list_widget)
        search_layout.addWidget(self.user_filter_search)
        filter_layout.addLayout(search_layout)

        self.user_filter_list = QListWidget()
        self.user_filter_list.setSelectionMode(QAbstractItemView.MultiSelection)
        self.user_filter_list.setMaximumHeight(140)
        self.user_filter_list.itemSelectionChanged.connect(self._apply_activity_filter)
        filter_layout.addWidget(self.user_filter_list)

        buttons_layout = QHBoxLayout()
        self._select_all_btn = QPushButton("Seleccionar todos")
        self._clear_selection_btn = QPushButton("Limpiar selección")
        hover_style = """
            QPushButton {
                padding: 6px 12px;
                border-radius: 6px;
                background-color: #f5f5f5;
            }
            QPushButton:hover {
                background-color: #e0dff7;
            }
        """
        self._select_all_btn.setStyleSheet(hover_style)
        self._clear_selection_btn.setStyleSheet(hover_style)
        self._select_all_btn.clicked.connect(self._select_all_users_filter)
        self._clear_selection_btn.clicked.connect(self._clear_user_filter_selection)
        buttons_layout.addWidget(self._select_all_btn)
        buttons_layout.addWidget(self._clear_selection_btn)
        buttons_layout.addStretch()
        filter_layout.addLayout(buttons_layout)

        layout.addWidget(filter_group)
        self._populate_user_filter_list()

        # --- Gráficos en dos columnas (GridLayout) ---
        charts_grid = QWidget()
        grid_layout = QGridLayout(charts_grid)

        self.login_canvas = self._create_chart_canvas((6, 4))
        self.feature_canvas = self._create_chart_canvas((6, 4))
        self.role_canvas = self._create_chart_canvas((10, 5))

        self.add_chart_widget(grid_layout, "Frecuencia de Uso", self.login_canvas, row=0, col=0)
        self.add_chart_widget(grid_layout, "Uso del Chatbot", self.feature_canvas, row=0, col=1)
        self.add_chart_widget(grid_layout, "Distribución de Usuarios por Rol", self.role_canvas, row=1, col=0, colspan=2)

        layout.addWidget(charts_grid)
        
        # Métrica Adicional (NUEVO)
        metrics_group = QGroupBox("Métricas Clave")
        metrics_layout = QHBoxLayout(metrics_group)
        self.total_users_label = QLabel()
        self.inactive_users_label = QLabel()
        self.avg_logins_label = QLabel()
        metrics_layout.addWidget(self.total_users_label)
        metrics_layout.addWidget(self.inactive_users_label)
        metrics_layout.addWidget(self.avg_logins_label)
        layout.addWidget(metrics_group)

        self._apply_activity_filter(initial=True)
        self._update_metrics()
        
        return view

    def add_chart_widget(self, layout, title, canvas, row, col, colspan=1):
        group_box = QGroupBox(title)
        group_layout = QVBoxLayout(group_box)
        group_layout.addWidget(canvas)
        layout.addWidget(group_box, row, col, 1, colspan)
        return canvas

    def _create_chart_canvas(self, size):
        fig = Figure(figsize=size)
        return FigureCanvas(fig)

    def _populate_user_filter_list(self) -> None:
        if not hasattr(self, 'user_filter_list'):
            return
        current_search = self.user_filter_search.text() if hasattr(self, 'user_filter_search') else ""
        selected_ids: Set[int] = set()
        if self.user_filter_list.count():
            for index in range(self.user_filter_list.count()):
                item = self.user_filter_list.item(index)
                if item.isSelected():
                    selected_ids.add(item.data(Qt.UserRole))

        self.user_filter_list.blockSignals(True)
        self.user_filter_list.clear()

        for _, row in self.user_data[['ID', 'Nombre']].sort_values('Nombre').iterrows():
            display = f"{row['Nombre']} (ID {row['ID']})"
            item = QListWidgetItem(display)
            item.setData(Qt.UserRole, int(row['ID']))
            if selected_ids:
                item.setSelected(row['ID'] in selected_ids)
            else:
                should_select = bool(getattr(self, '_filtered_user_ids', set(self.user_data['ID'])))
                item.setSelected(should_select)
            self.user_filter_list.addItem(item)

        self.user_filter_list.blockSignals(False)
        if current_search:
            self._filter_user_list_widget(current_search)

    def _filter_user_list_widget(self, text: str) -> None:
        if not hasattr(self, 'user_filter_list'):
            return
        text = text.lower().strip()
        for index in range(self.user_filter_list.count()):
            item = self.user_filter_list.item(index)
            item_text = item.text().lower()
            match = text in item_text if text else True
            item.setHidden(not match)

    def _select_all_users_filter(self) -> None:
        if not hasattr(self, 'user_filter_list'):
            return
        self.user_filter_list.blockSignals(True)
        for index in range(self.user_filter_list.count()):
            item = self.user_filter_list.item(index)
            if not item.isHidden():
                item.setSelected(True)
        self.user_filter_list.blockSignals(False)
        self._apply_activity_filter()

    def _clear_user_filter_selection(self) -> None:
        if not hasattr(self, 'user_filter_list'):
            return
        self.user_filter_list.blockSignals(True)
        for index in range(self.user_filter_list.count()):
            self.user_filter_list.item(index).setSelected(False)
        self.user_filter_list.blockSignals(False)
        self._apply_activity_filter()

    def _on_table_selection_changed(self, *args) -> None:
        has_selection = bool(self.table_view.selectionModel().hasSelection())
        self.modify_btn.setEnabled(has_selection)
        self.delete_btn.setEnabled(has_selection)

    def _apply_activity_filter(self, initial: bool = False) -> None:
        if not hasattr(self, 'user_filter_list'):
            return
        selected_items = self.user_filter_list.selectedItems()
        if not selected_items and not initial:
            self.filtered_activity_data = self.activity_data.iloc[0:0]
            self._filtered_user_ids = set()
        else:
            selected_ids = {item.data(Qt.UserRole) for item in selected_items}
            if not selected_ids:
                selected_ids = set(self.activity_data['user_id'])
            self.filtered_activity_data = self.activity_data[self.activity_data['user_id'].isin(selected_ids)]
            self._filtered_user_ids = selected_ids
        self._refresh_activity_charts()
        self._update_metrics()

    def _refresh_activity_charts(self) -> None:
        self._draw_login_chart()
        self._draw_feature_usage_chart()
        self._draw_role_distribution_chart()

    def _draw_login_chart(self) -> None:
        fig = self.login_canvas.figure
        fig.clear()
        ax = fig.add_subplot(111)
        data = self.filtered_activity_data.copy()
        if data.empty:
            ax.axis('off')
            ax.text(0.5, 0.5, "Sin datos para mostrar", ha='center', va='center', fontsize=12)
        else:
            merged = data.merge(self.user_data[['ID', 'Nombre']], left_on='user_id', right_on='ID', how='left')
            merged['Etiqueta'] = merged['Nombre'].fillna(merged['user_id'].astype(str))
            sns.barplot(x='Etiqueta', y='login_count', data=merged, ax=ax, palette='viridis')
            ax.set_title("Frecuencia de Inicio de Sesión")
            ax.set_xlabel("Usuario")
            ax.set_ylabel("Inicios de sesión")
            ax.tick_params(axis='x', rotation=35)
        fig.tight_layout()
        self.login_canvas.draw_idle()

    def _draw_feature_usage_chart(self) -> None:
        fig = self.feature_canvas.figure
        fig.clear()
        ax = fig.add_subplot(111)
        data = self.filtered_activity_data.copy()
        if data.empty:
            ax.axis('off')
            ax.text(0.5, 0.5, "Sin datos para mostrar", ha='center', va='center', fontsize=12)
        else:
            merged = data.merge(self.user_data[['ID', 'Nombre']], left_on='user_id', right_on='ID', how='left')
            merged['Etiqueta'] = merged['Nombre'].fillna(merged['user_id'].astype(str))
            sns.barplot(x='Etiqueta', y='chatbot_sessions', data=merged, ax=ax, palette='plasma')
            ax.set_title("Uso del Chatbot por Usuario")
            ax.set_xlabel("Usuario")
            ax.set_ylabel("Sesiones con chatbot")
            ax.tick_params(axis='x', rotation=35)
        fig.tight_layout()
        self.feature_canvas.draw_idle()

    def _draw_role_distribution_chart(self) -> None:
        fig = self.role_canvas.figure
        fig.clear()
        ax = fig.add_subplot(111)
        if not self._filtered_user_ids:
            ax.axis('off')
            ax.text(0.5, 0.5, "Sin usuarios seleccionados", ha='center', va='center', fontsize=12)
        else:
            filtered_users = self.user_data[self.user_data['ID'].isin(self._filtered_user_ids)]
            role_counts = filtered_users['Rol'].value_counts()
            if role_counts.empty:
                ax.axis('off')
                ax.text(0.5, 0.5, "Sin datos para mostrar", ha='center', va='center', fontsize=12)
            else:
                colors = sns.color_palette('pastel', role_counts.shape[0])
                ax.pie(role_counts, labels=role_counts.index, autopct='%1.1f%%', startangle=90, colors=colors)
                ax.set_title("Distribución de Usuarios por Rol")
                ax.axis('equal')
        fig.tight_layout()
        self.role_canvas.draw_idle()

    def _update_metrics(self) -> None:
        if not hasattr(self, 'total_users_label'):
            return
        if not self._filtered_user_ids:
            total_users = 0
            inactive_users = 0
            avg_logins = 0.0
        else:
            filtered_users = self.user_data[self.user_data['ID'].isin(self._filtered_user_ids)]
            total_users = len(filtered_users)
            inactive_users = len(filtered_users[filtered_users['Estado'] == 'Inactivo'])
            avg_logins = self.filtered_activity_data['login_count'].mean() if not self.filtered_activity_data.empty else 0.0

        self.total_users_label.setText(f"Total Usuarios: <strong>{total_users}</strong>")
        self.inactive_users_label.setText(f"Usuarios Inactivos: <strong>{inactive_users}</strong>")
        self.avg_logins_label.setText(f"Promedio de Inicios de Sesión: <strong>{avg_logins:.1f}</strong>")

    def _add_activity_record(self, user_id: int) -> None:
        default_row = {'user_id': user_id, 'login_count': 0, 'chatbot_sessions': 0}
        self.activity_data = pd.concat([self.activity_data, pd.DataFrame([default_row])], ignore_index=True)

    def _remove_activity_record(self, user_id: int) -> None:
        self.activity_data = self.activity_data[self.activity_data['user_id'] != user_id].reset_index(drop=True)

# --- Clases Auxiliares ---

class PandasModel(QAbstractTableModel):
    # ... (Clase PandasModel sin cambios, se reutiliza) ...
    def __init__(self, data):
        super().__init__()
        self._data = data

    def rowCount(self, parent=None):
        return self._data.shape[0]

    def columnCount(self, parent=None):
        return self._data.shape[1]

    def data(self, index, role=Qt.DisplayRole):
        if not index.isValid():
            return QVariant()
        if role == Qt.DisplayRole:
            return str(self._data.iloc[index.row(), index.column()])
        return QVariant()

    def headerData(self, section, orientation, role=Qt.DisplayRole):
        if role == Qt.DisplayRole:
            if orientation == Qt.Horizontal:
                return str(self._data.columns[section])
            if orientation == Qt.Vertical:
                return str(self._data.index[section])
        return QVariant()

    def set_data(self, data):
        self._data = data
        self.layoutChanged.emit()

class UserDialog(QDialog):
    def __init__(
        self,
        title,
        headers,
        data=None,
        roles=None,
        gender_options=None,
        require_password: bool = False,
    ):
        super().__init__()
        self.setWindowTitle(title)
        base_data = data.copy() if data else {h: '' for h in headers if h not in {'ID', 'Estado'}}
        if 'Contraseña' in base_data:
            base_data['Contraseña'] = ''
        self.data = base_data
        self.inputs = {}
        self._password_input: Optional[QLineEdit] = None
        self._require_password = require_password

        if not data:
            self.data['Rol'] = roles[0] if roles else ''
            self.data['Género'] = gender_options[0] if gender_options else ''
            self.data['Estado'] = 'Activo'

        form_layout = QFormLayout()

        for header in headers:
            if header == 'ID':
                continue

            label = QLabel(header)
            input_widget = QLineEdit(str(self.data.get(header, '')))

            if header == 'Rol' and roles:
                input_widget = QComboBox()
                input_widget.addItems(roles)
                current_role = str(self.data.get(header, roles[0]))
                input_widget.setCurrentText(current_role)
            elif header == 'Género' and gender_options:
                input_widget = QComboBox()
                input_widget.addItems(gender_options)
                current_gender = str(self.data.get(header, gender_options[0]))
                input_widget.setCurrentText(current_gender)
            elif header == 'Estado':
                input_widget = QComboBox()
                input_widget.addItems(['Activo', 'Inactivo'])
                current_status = str(self.data.get(header, 'Activo'))
                input_widget.setCurrentText(current_status)
            elif header == 'Contraseña':
                input_widget = QLineEdit()
                input_widget.setEchoMode(QLineEdit.Password)
                placeholder = "Contraseña (requerida)" if self._require_password else "Nueva contraseña (opcional)"
                input_widget.setPlaceholderText(placeholder)
                self._password_input = input_widget

            self.inputs[header] = input_widget
            form_layout.addRow(label, input_widget)

        self.buttons = QDialogButtonBox(QDialogButtonBox.Ok | QDialogButtonBox.Cancel)
        self.buttons.accepted.connect(self.accept)
        self.buttons.rejected.connect(self.reject)

        layout = QVBoxLayout(self)
        layout.addLayout(form_layout)
        layout.addWidget(self.buttons)

    def accept(self) -> None:
        if self._require_password and self._password_input and not self._password_input.text().strip():
            QMessageBox.warning(self, "Validación", "La contraseña es obligatoria.")
            return
        super().accept()

    def get_data(self):
        data = {}
        for header, input_widget in self.inputs.items():
            if isinstance(input_widget, QLineEdit):
                value = input_widget.text()
                if header == 'Contraseña':
                    value = value.strip()
                    data['password_raw'] = value or None
                    data[header] = "********" if value else ""
                else:
                    data[header] = value
            elif isinstance(input_widget, QComboBox):
                data[header] = input_widget.currentText()
        return data
