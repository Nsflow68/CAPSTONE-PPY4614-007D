from PyQt5.QtWidgets import (QWidget, QVBoxLayout, QHBoxLayout, QLabel, 
                             QComboBox, QPushButton, QStackedWidget, QListWidget, 
                             QGroupBox, QCheckBox, QGridLayout, QScrollArea)
from PyQt5.QtCore import Qt, QDate

class ReportsView(QWidget):
    def __init__(self):
        super().__init__()
        
        main_layout = QVBoxLayout(self)
        main_layout.setContentsMargins(0, 0, 0, 0)
        
        # Pestañas de submenú (Mismo estilo)
        tabs_layout = QHBoxLayout()
        self.btn_generator = QPushButton("Generación de Reportes")
        self.btn_export = QPushButton("Gestión de Exportaciones")
        
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
        self.btn_generator.setStyleSheet(button_style)
        self.btn_export.setStyleSheet(button_style)
        
        self.btn_generator.setCheckable(True)
        self.btn_export.setCheckable(True)

        tabs_layout.addWidget(self.btn_generator)
        tabs_layout.addWidget(self.btn_export)
        tabs_layout.addStretch()
        
        main_layout.addLayout(tabs_layout)
        
        # Contenedor de paneles dinámicos
        self.stacked_widget = QStackedWidget()
        main_layout.addWidget(self.stacked_widget)
        
        # Vistas internas
        self.generator_view = self.create_generator_view()
        self.export_view = self.create_export_view()

        self.stacked_widget.addWidget(self.generator_view)
        self.stacked_widget.addWidget(self.export_view)
        
        # Conexiones de botones a los paneles
        self.btn_generator.clicked.connect(lambda: self.stacked_widget.setCurrentIndex(0))
        self.btn_export.clicked.connect(lambda: self.stacked_widget.setCurrentIndex(1))
        
        # Asegurarse de que el primer botón esté seleccionado al inicio
        self.btn_generator.setChecked(True)

    # ----------------------------------------------------------------------
    # --- Panel 1: Generación de Reportes (Personalización y Lista) ---
    # ----------------------------------------------------------------------
    def create_generator_view(self):
        view = QWidget()
        layout = QHBoxLayout(view)
        layout.setContentsMargins(10, 10, 10, 10)
        
        # --- Columna Izquierda: Opciones de Generación ---
        generator_group = QGroupBox("Opciones de Reporte Personalizado")
        generator_layout = QVBoxLayout(generator_group)

        # 1. Selector de Tipo
        generator_layout.addWidget(QLabel("<strong>Tipo de Métrica:</strong>"))
        self.report_selector = QComboBox()
        self.report_selector.addItems(["Crecimiento de Usuarios", "Distribución de Roles", "Actividad del Chatbot", "Métricas de Contenido"])
        generator_layout.addWidget(self.report_selector)
        
        # 2. Selector de Período (Fechas)
        generator_layout.addWidget(QLabel("<hr><strong>Período de Análisis:</strong>"))
        period_layout = QGridLayout()
        
        period_layout.addWidget(QLabel("Fecha Inicio:"), 0, 0)
        # En una implementación real, usarías QDateEdit o QCalendarWidget
        period_layout.addWidget(QLabel(QDate.currentDate().addMonths(-1).toString(Qt.ISODate)), 0, 1) # Simulación de selector de fecha

        period_layout.addWidget(QLabel("Fecha Fin:"), 1, 0)
        period_layout.addWidget(QLabel(QDate.currentDate().toString(Qt.ISODate)), 1, 1) # Simulación de selector de fecha
        
        generator_layout.addLayout(period_layout)
        
        # 3. Opciones Avanzadas (Filtros)
        generator_layout.addWidget(QLabel("<hr><strong>Filtros Adicionales:</strong>"))
        self.filter_checkbox1 = QCheckBox("Incluir datos de administradores")
        self.filter_checkbox2 = QCheckBox("Agrupar por género")
        generator_layout.addWidget(self.filter_checkbox1)
        generator_layout.addWidget(self.filter_checkbox2)
        
        generator_layout.addStretch()
        
        # Botón de acción
        self.generate_button = QPushButton("✨ Generar y Visualizar Informe")
        self.generate_button.setStyleSheet("background-color: #A28FC9; color: white; padding: 10px; font-weight: bold;")
        generator_layout.addWidget(self.generate_button)
        
        layout.addWidget(generator_group, 1)

        # --- Columna Derecha: Lista de Informes Recientes ---
        list_group = QGroupBox("Informes Generados Recientemente")
        list_layout = QVBoxLayout(list_group)
        
        self.generated_reports_list = QListWidget()
        self.generated_reports_list.addItems([
            "Crecimiento - Octubre 2025.pdf",
            "Actividad Chatbot - Últimos 7 Días.pdf",
            "Distribución de Roles - Q3 2025.csv",
            "Métricas de Contenido - Septiembre.xlsx",
        ])
        
        list_layout.addWidget(self.generated_reports_list)
        
        list_buttons = QHBoxLayout()
        self.open_report_btn = QPushButton("Abrir 📂")
        self.download_report_btn = QPushButton("Descargar ⬇️")
        list_buttons.addWidget(self.open_report_btn)
        list_buttons.addWidget(self.download_report_btn)
        list_layout.addLayout(list_buttons)
        
        layout.addWidget(list_group, 2)
        
        return view

    # ----------------------------------------------------------------------
    # --- Panel 2: Gestión de Exportaciones (Exportación Masiva) ---
    # ----------------------------------------------------------------------
    def create_export_view(self):
        view = QWidget()
        layout = QVBoxLayout(view)
        layout.setContentsMargins(10, 10, 10, 10)
        
        # --- Panel de Selección de Datos ---
        data_selection_group = QGroupBox("Selección de Datos a Exportar")
        data_selection_layout = QGridLayout(data_selection_group)

        data_selection_layout.addWidget(QLabel("<strong>Módulo:</strong>"), 0, 0)
        self.data_module_selector = QComboBox()
        self.data_module_selector.addItems(["Usuarios", "Interacciones del Chatbot", "Contenido y Recursos", "Logs del Sistema"])
        data_selection_layout.addWidget(self.data_module_selector, 0, 1)

        data_selection_layout.addWidget(QLabel("<strong>Formato de Salida:</strong>"), 1, 0)
        self.format_selector = QComboBox()
        self.format_selector.addItems(["CSV (Datos Crudos)", "JSON (API)", "Excel (Análisis)"])
        data_selection_layout.addWidget(self.format_selector, 1, 1)
        
        layout.addWidget(data_selection_group)

        # --- Panel de Opciones Avanzadas ---
        advanced_options_group = QGroupBox("Opciones de Filtro y Exportación")
        advanced_options_layout = QVBoxLayout(advanced_options_group)
        
        advanced_options_layout.addWidget(QLabel("<strong>Columnas a Incluir:</strong>"))
        
        scroll_area = QScrollArea()
        scroll_content = QWidget()
        scroll_layout = QVBoxLayout(scroll_content)
        
        # Simulación de opciones de columna
        scroll_layout.addWidget(QCheckBox("Nombre de Usuario"))
        scroll_layout.addWidget(QCheckBox("ID"))
        scroll_layout.addWidget(QCheckBox("Fecha de Creación"))
        scroll_layout.addWidget(QCheckBox("Último Login"))
        scroll_layout.addWidget(QCheckBox("Rol Asignado"))
        
        scroll_area.setWidgetResizable(True)
        scroll_area.setWidget(scroll_content)
        scroll_area.setMaximumHeight(120)
        advanced_options_layout.addWidget(scroll_area)
        
        layout.addWidget(advanced_options_group)
        
        # --- Botón de Acción Final ---
        self.export_button = QPushButton("📤 Iniciar Exportación Masiva")
        self.export_button.setStyleSheet("background-color: #5bc0de; color: white; padding: 15px; font-size: 16px;") # Estilo Azul para Exportar
        
        layout.addWidget(self.export_button)
        layout.addStretch()
        
        return view

# Bloque de ejecución de prueba (opcional, para ejecutar el archivo solo)
if __name__ == '__main__':
    from PyQt5.QtWidgets import QApplication
    import sys
    
    app = QApplication(sys.argv)
    window = ReportsView()
    window.setWindowTitle("Reportes y Exportación de Datos")
    window.resize(900, 600)
    window.show()
    sys.exit(app.exec_())