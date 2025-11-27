from itertools import cycle, islice
from typing import Optional, Set

import pandas as pd
import seaborn as sns
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
)
from PyQt5.QtWidgets import QAbstractItemView
from PyQt5.QtCore import Qt, QAbstractTableModel, QVariant
from matplotlib.backends.backend_qt5agg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.figure import Figure

from app.database.repositories.user_repository import UserRecord
from app.utils.security import hash_password

# --- Clases de la Vista ---

class UserManagementView(QWidget):
    def __init__(self, current_user: Optional[UserRecord] = None):
        super().__init__()
        self._current_user = current_user

        main_layout = QVBoxLayout(self)
        main_layout.setContentsMargins(0, 0, 0, 0)
        
        # Cargar datos de ejemplo (Movido al __init__ para accesibilidad global)
        self.user_data = pd.DataFrame({
            'ID': [1, 2, 3, 4, 5, 6, 7],
            'Usuario': ['matias', 'ana', 'carlos', 'sofia', 'pedro', 'laura', 'david'],
            'Nombre': ['Matias', 'Ana', 'Carlos', 'Sofia', 'Pedro', 'Laura', 'David'],
            'Género': ['Masculino', 'Femenino', 'Masculino', 'Femenino', 'Masculino', 'Femenino', 'Masculino'],
            'Edad': [25, 30, 22, 28, 45, 33, 19],
            'Rol': ['Admin', 'Usuario', 'Usuario', 'Moderador', 'Usuario', 'Admin', 'Usuario'],
            'Estado': ['Activo', 'Activo', 'Inactivo', 'Activo', 'Activo', 'Inactivo', 'Activo'],
        })
        sample_passwords = ["matias123", "ana2024", "carlos22", "sofiaSecure", "pedro45", "lauraKey", "davidSafe"]
        self.user_data['Contraseña'] = [hash_password(pw) for pw in sample_passwords]
        self._ensure_current_user_in_dataset()
        
        self.role_data = pd.DataFrame({
            'Rol': ['Admin', 'Moderador', 'Usuario'],
            'Permiso: Edición': ['Sí', 'No', 'No'],
            'Permiso: Reportes': ['Sí', 'Sí', 'No'],
            'Descripción': ['Control total', 'Moderar contenido', 'Acceso básico']
        })
        
        # Pestañas de submenú
        tabs_layout = QHBoxLayout()
        self.btn_control = QPushButton("Control de Usuarios")
        self.btn_roles = QPushButton("Gestión de Roles")
        self.btn_analisis = QPushButton("Análisis de Actividad")
        
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
        self.btn_control.setStyleSheet(button_style)
        self.btn_roles.setStyleSheet(button_style)
        self.btn_analisis.setStyleSheet(button_style)
        
        self.btn_control.setCheckable(True)
        self.btn_roles.setCheckable(True)
        self.btn_analisis.setCheckable(True)

        tabs_layout.addWidget(self.btn_control)
        tabs_layout.addWidget(self.btn_roles)
        tabs_layout.addWidget(self.btn_analisis)
        tabs_layout.addStretch()
        
        main_layout.addLayout(tabs_layout)
        
        # Contenedor de paneles dinámicos
        self.stacked_widget = QStackedWidget()
        main_layout.addWidget(self.stacked_widget)
        
        # Vistas internas
        self.control_view = self.create_control_view()
        self.roles_view = self.create_roles_view()
        self.analisis_view = self.create_analisis_view()

        self.stacked_widget.addWidget(self.control_view)
        self.stacked_widget.addWidget(self.roles_view)
        self.stacked_widget.addWidget(self.analisis_view)
        
        self.btn_control.clicked.connect(lambda: self.stacked_widget.setCurrentIndex(0))
        self.btn_roles.clicked.connect(lambda: self.stacked_widget.setCurrentIndex(1))
        self.btn_analisis.clicked.connect(lambda: self.stacked_widget.setCurrentIndex(2))
        
        self.btn_control.setChecked(True)

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
        layout.addWidget(self.table_view)

        # Botones de CRUD (Mejorados visualmente)
        crud_buttons_layout = QHBoxLayout()
        self.add_btn = QPushButton("➕ Agregar Usuario")
        self.modify_btn = QPushButton("✏️ Modificar Seleccionado")
        self.delete_btn = QPushButton("🗑️ Eliminar")
        self.add_btn.setStyleSheet("background-color: #5cb85c; color: white;")
        self.delete_btn.setStyleSheet("background-color: #d9534f; color: white;")
        
        self.add_btn.clicked.connect(self.add_user)
        self.modify_btn.clicked.connect(self.modify_user)
        self.delete_btn.clicked.connect(self.delete_user)

        crud_buttons_layout.addStretch()
        crud_buttons_layout.addWidget(self.add_btn)
        crud_buttons_layout.addWidget(self.modify_btn)
        crud_buttons_layout.addWidget(self.delete_btn)
        layout.addLayout(crud_buttons_layout)

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

    def _ensure_current_user_in_dataset(self) -> Optional[int]:
        if not self._current_user:
            return None
        username = self._current_user.username
        if 'Usuario' not in self.user_data.columns:
            self.user_data['Usuario'] = ''
        if not self.user_data[self.user_data['Usuario'] == username].empty:
            return None

        new_id = int(self.user_data['ID'].max() + 1) if not self.user_data.empty else 1
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
            'Contraseña': self._current_user.password_hash,
        }
        new_df = pd.DataFrame([new_row])[self.user_data.columns]
        self.user_data = pd.concat([self.user_data, new_df], ignore_index=True)

        if hasattr(self, '_filtered_user_ids'):
            self._filtered_user_ids.add(new_id)

        return new_id

    def set_current_user(self, user: Optional[UserRecord]) -> None:
        self._current_user = user
        previous_selection: Set[int] = set()
        if hasattr(self, 'user_filter_list'):
            previous_selection = {item.data(Qt.UserRole) for item in self.user_filter_list.selectedItems()}

        new_id = self._ensure_current_user_in_dataset()
        if new_id is not None:
            previous_selection.add(new_id)

        if hasattr(self, 'table_model'):
            self.table_model.set_data(self.user_data)

        if hasattr(self, 'user_list'):
            self.user_list.clear()
            self.user_list.addItems(self.user_data['Nombre'])

        if hasattr(self, 'activity_data'):
            if new_id is not None and new_id not in set(self.activity_data['user_id']):
                self._add_activity_record(new_id)
            self._populate_user_filter_list()
            if hasattr(self, 'user_filter_list'):
                if previous_selection:
                    self.user_filter_list.blockSignals(True)
                    for index in range(self.user_filter_list.count()):
                        item = self.user_filter_list.item(index)
                        item.setSelected(item.data(Qt.UserRole) in previous_selection)
                    self.user_filter_list.blockSignals(False)
                    self._apply_activity_filter()
                else:
                    self._select_all_users_filter()

    def add_user(self):
        # Pasar los datos de roles y opciones al diálogo
        dialog = UserDialog(
            "Agregar Usuario",
            self.user_data.columns,
            roles=self.role_data['Rol'].tolist(),
            gender_options=self.user_data['Género'].unique().tolist(),
            require_password=True,
        )
        if dialog.exec_() == QDialog.Accepted:
            new_user_data = dialog.get_data()
            new_id = self.user_data['ID'].max() + 1 if not self.user_data.empty else 1
            new_user_data['ID'] = new_id
            new_user_df = pd.DataFrame([new_user_data])[self.user_data.columns]
            self.user_data = pd.concat([self.user_data, new_user_df], ignore_index=True)
            self.table_model.set_data(self.user_data)
            QMessageBox.information(self, "Éxito", "Usuario agregado correctamente.")
            # Refrescar la lista de usuarios en la vista de roles
            if hasattr(self, 'user_list'):
                self.user_list.clear()
                self.user_list.addItems(self.user_data['Nombre'])
            self._add_activity_record(new_id)
            self._populate_user_filter_list()
            self._apply_activity_filter()


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
            self.user_data['Género'].unique().tolist(),
            existing_password=current_data.get('Contraseña'),
        )
        
        if dialog.exec_() == QDialog.Accepted:
            modified_data = dialog.get_data()
            # Encontrar el índice original en el DataFrame principal
            original_index = self.user_data[self.user_data['ID'] == current_data['ID']].index[0]
            
            for key, value in modified_data.items():
                self.user_data.at[original_index, key] = value
            self.table_model.set_data(self.user_data)
            QMessageBox.information(self, "Éxito", "Usuario modificado correctamente.")
            # Refrescar la lista de usuarios en la vista de roles
            if hasattr(self, 'user_list'):
                self.user_list.clear()
                self.user_list.addItems(self.user_data['Nombre'])
            self._populate_user_filter_list()
            self._apply_activity_filter()
            
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
            # Obtener el índice de la fila seleccionada en el DataFrame filtrado actual
            row_index_in_filtered_df = selected_index.row()
            
            # Obtener el ID del usuario
            user_id_to_delete = self.table_model._data.iloc[row_index_in_filtered_df]['ID']
            
            # Eliminar la fila del DataFrame principal
            self.user_data = self.user_data[self.user_data['ID'] != user_id_to_delete].reset_index(drop=True)
            
            # Refrescar la vista de la tabla (usando la función filter_users para aplicar los filtros actuales)
            self.filter_users()
            QMessageBox.information(self, "Éxito", "Usuario eliminado correctamente.")
            # Refrescar la lista de usuarios en la vista de roles
            if hasattr(self, 'user_list'):
                self.user_list.clear()
                self.user_list.addItems(self.user_data['Nombre'])
            self._remove_activity_record(user_id_to_delete)
            self._populate_user_filter_list()
            self._apply_activity_filter()


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
        roles_buttons.addWidget(add_role_btn)
        roles_buttons.addWidget(edit_permissions_btn)
        roles_layout.addLayout(roles_buttons)
        
        # Conexiones (simulación)
        edit_permissions_btn.clicked.connect(lambda: QMessageBox.information(self, "Permisos", "Simulación de diálogo de edición de permisos."))
        add_role_btn.clicked.connect(lambda: QMessageBox.information(self, "Nuevo Rol", "Simulación de añadir un nuevo rol a la tabla."))

        layout.addWidget(roles_group, 2) # Ocupa 2/3

        # --- Columna Derecha: Asignación Rápida ---
        assign_group = QGroupBox("Asignación Rápida de Rol")
        assign_layout = QVBoxLayout(assign_group)
        
        assign_layout.addWidget(QLabel("<strong>1. Seleccionar Usuario:</strong>"))
        self.user_list = QListWidget()
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
            # Encontrar el índice original en el DataFrame principal
            self.user_data.loc[self.user_data['Nombre'] == user_name, 'Rol'] = selected_role
            QMessageBox.information(self, "Éxito", f"Rol de '{user_name}' asignado a '{selected_role}'.")
            
            # Actualizar tabla de control por si está visible
            self.filter_users()
        else:
            QMessageBox.warning(self, "Advertencia", "Seleccione un usuario de la lista para asignar el rol.")


    # --- Panel 3: Análisis de Actividad (Profundizado) ---
    def create_analisis_view(self):
        view = QWidget()
        layout = QVBoxLayout(view)
        
        # Cargar datos de actividad (ejemplo)
        sample_login_counts = [50, 20, 100, 35, 78, 60, 42]
        sample_chatbot_sessions = [20, 5, 40, 15, 60, 30, 18]
        length = len(self.user_data)
        login_counts = list(islice(cycle(sample_login_counts), length))
        chatbot_sessions = list(islice(cycle(sample_chatbot_sessions), length))
        self.activity_data = pd.DataFrame({
            'user_id': self.user_data['ID'],
            'login_count': login_counts,
            'chatbot_sessions': chatbot_sessions
        })
        self.filtered_activity_data = self.activity_data.copy()
        self._filtered_user_ids = set(self.user_data['ID'])

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
        self._select_all_btn.clicked.connect(self._select_all_users_filter)
        self._clear_selection_btn = QPushButton("Limpiar selección")
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
        existing_password: Optional[str] = None,
        require_password: bool = False,
    ):
        super().__init__()
        self.setWindowTitle(title)
        base_data = data.copy() if data else {h: '' for h in headers if h not in {'ID', 'Estado'}}
        self._existing_password = existing_password or (base_data.get('Contraseña') if base_data else None)
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
                    if value:
                        data[header] = hash_password(value)
                    elif self._existing_password:
                        data[header] = self._existing_password
                    else:
                        data[header] = ''
                else:
                    data[header] = value
            elif isinstance(input_widget, QComboBox):
                data[header] = input_widget.currentText()
        return data
