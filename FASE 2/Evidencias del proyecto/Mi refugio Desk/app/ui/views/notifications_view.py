from PyQt5.QtWidgets import (QWidget, QVBoxLayout, QHBoxLayout, QLabel, 
                             QTextEdit, QPushButton, QCheckBox, QGroupBox, 
                             QLineEdit, QStackedWidget, QRadioButton, QGridLayout,
                             QScrollArea, QListWidget)
from PyQt5.QtCore import Qt

class NotificationsView(QWidget):
    def __init__(self):
        super().__init__()
        
        main_layout = QVBoxLayout(self)
        main_layout.setContentsMargins(0, 0, 0, 0)
        
        # Pestañas de submenú (Mismo estilo)
        tabs_layout = QHBoxLayout()
        self.btn_notifications = QPushButton("Notificaciones")
        self.btn_status = QPushButton("Estado y Mantenimiento")
        self.btn_backup = QPushButton("Copias de Seguridad")
        
        # Estilo CSS para las pestañas
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
                border-top: 2px solid #A28FC9; /* Color violeta de ejemplo */
            }
        """
        self.btn_notifications.setStyleSheet(button_style)
        self.btn_status.setStyleSheet(button_style)
        self.btn_backup.setStyleSheet(button_style)
        
        self.btn_notifications.setCheckable(True)
        self.btn_status.setCheckable(True)
        self.btn_backup.setCheckable(True)

        tabs_layout.addWidget(self.btn_notifications)
        tabs_layout.addWidget(self.btn_status)
        tabs_layout.addWidget(self.btn_backup)
        tabs_layout.addStretch()
        
        main_layout.addLayout(tabs_layout)
        
        # Contenedor de paneles dinámicos
        self.stacked_widget = QStackedWidget()
        main_layout.addWidget(self.stacked_widget)
        
        # Vistas internas
        self.notifications_view = self.create_notifications_view()
        self.status_view = self.create_status_view()
        self.backup_view = self.create_backup_view()

        self.stacked_widget.addWidget(self.notifications_view)
        self.stacked_widget.addWidget(self.status_view)
        self.stacked_widget.addWidget(self.backup_view)
        
        # Conexiones de botones a los paneles
        self.btn_notifications.clicked.connect(lambda: self.stacked_widget.setCurrentIndex(0))
        self.btn_status.clicked.connect(lambda: self.stacked_widget.setCurrentIndex(1))
        self.btn_backup.clicked.connect(lambda: self.stacked_widget.setCurrentIndex(2))
        
        # Asegurarse de que el primer botón esté seleccionado al inicio
        self.btn_notifications.setChecked(True)

    # ----------------------------------------------------------------------
    # --- Panel 1: Notificaciones (Mejorado) ---
    # ----------------------------------------------------------------------
    def create_notifications_view(self):
        view = QWidget()
        layout = QHBoxLayout(view)
        layout.setContentsMargins(10, 10, 10, 10)
        
        # --- Columna Izquierda: Creación de Mensajes ---
        editor_group = QGroupBox("Redacción de Notificación Push")
        editor_layout = QVBoxLayout(editor_group)
        
        editor_layout.addWidget(QLabel("<strong>Tipo de Mensaje:</strong>"))
        self.msg_type_combo = QRadioButton("Alerta Urgente")
        self.msg_type_combo.setChecked(True)
        editor_layout.addWidget(self.msg_type_combo)

        editor_layout.addWidget(QLabel("<strong>Título (Máx. 50 Caracteres):</strong>"))
        title_input = QLineEdit()
        title_input.setPlaceholderText("Ej: ¡Nueva Actualización Disponible!")
        editor_layout.addWidget(title_input)
        
        editor_layout.addWidget(QLabel("<strong>Mensaje Detallado:</strong>"))
        message_input = QTextEdit()
        message_input.setPlaceholderText("Escribe el contenido completo del mensaje aquí...")
        message_input.setMinimumHeight(150)
        editor_layout.addWidget(message_input)
        
        layout.addWidget(editor_group, 2) # Ocupa 2/3 del espacio
        
        # --- Columna Derecha: Opciones de Envío y Segmentación ---
        target_group = QGroupBox("Opciones de Envío")
        target_layout = QVBoxLayout(target_group)
        
        target_layout.addWidget(QLabel("<strong>Segmentación de Destino:</strong>"))
        self.target_all = QRadioButton("Todos los Usuarios (Default)")
        self.target_admin = QRadioButton("Solo Administradores")
        self.target_specific = QRadioButton("Usuarios con Rol 'Moderador'")
        
        self.target_all.setChecked(True)
        
        target_layout.addWidget(self.target_all)
        target_layout.addWidget(self.target_admin)
        target_layout.addWidget(self.target_specific)
        
        target_layout.addStretch()
        
        send_button = QPushButton("🚀 Enviar Notificación Ahora")
        send_button.setStyleSheet("background-color: #A28FC9; color: white; padding: 10px;")
        target_layout.addWidget(send_button)
        
        layout.addWidget(target_group, 1) # Ocupa 1/3 del espacio
        
        return view

    # ----------------------------------------------------------------------
    # --- Panel 2: Estado y Mantenimiento (Mejorado) ---
    # ----------------------------------------------------------------------
    def create_status_view(self):
        view = QWidget()
        layout = QVBoxLayout(view)
        layout.setContentsMargins(10, 10, 10, 10)
        
        # --- Panel de Métricas (GridLayout) ---
        metrics_group = QGroupBox("Panel de Métricas del Sistema")
        metrics_layout = QGridLayout(metrics_group)
        
        # Métrica 1: Estado del Servidor
        metrics_layout.addWidget(QLabel("<strong>Estado del Servidor:</strong>"), 0, 0)
        metrics_layout.addWidget(QLabel("<span style='color: green; font-weight: bold;'>🟢 OPERATIVO</span>"), 0, 1)

        # Métrica 2: Rendimiento de la Base de Datos
        metrics_layout.addWidget(QLabel("<strong>Rendimiento DB:</strong>"), 1, 0)
        metrics_layout.addWidget(QLabel("<span style='color: orange;'>Medio (500 ms)</span>"), 1, 1)

        # Métrica 3: Uso de Almacenamiento
        metrics_layout.addWidget(QLabel("<strong>Uso de Almacenamiento:</strong>"), 2, 0)
        metrics_layout.addWidget(QLabel("50% (500 GB / 1 TB)"), 2, 1)

        # Métrica 4: Usuarios Activos
        metrics_layout.addWidget(QLabel("<strong>Usuarios Activos (24h):</strong>"), 3, 0)
        metrics_layout.addWidget(QLabel("1.250"), 3, 1)
        
        layout.addWidget(metrics_group)
        
        # --- Panel de Tareas de Mantenimiento ---
        maint_group = QGroupBox("Tareas de Mantenimiento Programado")
        maint_layout = QVBoxLayout(maint_group)
        
        maint_layout.addWidget(QLabel("<strong>Activar/Desactivar Modo Mantenimiento Global:</strong>"))
        
        maint_hbox = QHBoxLayout()
        self.maint_checkbox = QCheckBox("Activar Modo Mantenimiento")
        self.maint_checkbox.setStyleSheet("color: red;")
        maint_hbox.addWidget(self.maint_checkbox)
        maint_hbox.addStretch()
        maint_hbox.addWidget(QPushButton("Programar Mantenimiento"))
        maint_layout.addLayout(maint_hbox)
        
        maint_layout.addWidget(QLabel("<hr><strong>Optimización de Base de Datos:</strong>"))
        maint_layout.addWidget(QPushButton("Ejecutar Optimización DB"))

        layout.addWidget(maint_group)
        layout.addStretch()
        
        return view

    # ----------------------------------------------------------------------
    # --- Panel 3: Copias de Seguridad (Mejorado) ---
    # ----------------------------------------------------------------------
    def create_backup_view(self):
        view = QWidget()
        layout = QVBoxLayout(view)
        layout.setContentsMargins(10, 10, 10, 10)
        
        # --- Panel de Acciones Manuales ---
        manual_group = QGroupBox("Ejecución Manual de Copia de Seguridad")
        manual_layout = QVBoxLayout(manual_group)
        
        manual_layout.addWidget(QLabel("Presione para generar una copia de seguridad inmediata de la Base de Datos y Archivos del Sistema."))
        
        backup_button = QPushButton("Realizar Copia de Seguridad Ahora 💾")
        backup_button.setStyleSheet("background-color: #5cb85c; color: white; padding: 12px;") # Estilo Verde
        
        manual_layout.addWidget(backup_button)
        layout.addWidget(manual_group)

        # --- Panel de Restauración ---
        restore_group = QGroupBox("Restauración del Sistema")
        restore_layout = QVBoxLayout(restore_group)
        
        restore_layout.addWidget(QLabel("<strong>Seleccionar Copia de Seguridad:</strong>"))
        
        # Simulación de un listado de backups
        self.backup_list = QListWidget()
        self.backup_list.addItems([
            "DB_2025-10-08_10-00-00.zip (2.5 GB)",
            "DB_2025-10-07_03-00-00.zip (2.4 GB)",
            "DB_2025-10-06_03-00-00.zip (2.3 GB)"
        ])
        self.backup_list.setMaximumHeight(100)
        restore_layout.addWidget(self.backup_list)
        
        restore_layout.addWidget(QLabel("⚠️ <span style='color: red;'>¡ADVERTENCIA! La restauración sobrescribirá los datos actuales.</span>"))
        
        restore_button = QPushButton("Restaurar desde Copia de Seguridad ↩️")
        restore_button.setStyleSheet("background-color: #d9534f; color: white; padding: 12px;") # Estilo Rojo
        
        restore_layout.addWidget(restore_button)
        layout.addWidget(restore_group)
        
        layout.addStretch()
        
        return view

# Bloque de ejecución de prueba (opcional, para ejecutar el archivo solo)
if __name__ == '__main__':
    from PyQt5.QtWidgets import QApplication
    import sys
    
    app = QApplication(sys.argv)
    window = NotificationsView()
    window.setWindowTitle("Sistema de Operaciones y Mantenimiento")
    window.resize(800, 600)
    window.show()
    sys.exit(app.exec_())