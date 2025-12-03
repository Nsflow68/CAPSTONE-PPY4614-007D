from __future__ import annotations

from collections import Counter
from typing import Optional

import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns
from PyQt5.QtCore import Qt
from PyQt5.QtWidgets import (
    QComboBox,
    QFrame,
    QGridLayout,
    QGroupBox,
    QHBoxLayout,
    QDialog,
    QDialogButtonBox,
    QFormLayout,
    QLineEdit,
    QLabel,
    QPlainTextEdit,
    QPushButton,
    QScrollArea,
    QStackedWidget,
    QTableWidget,
    QTableWidgetItem,
    QVBoxLayout,
    QWidget,
)
from matplotlib.backends.backend_qt5agg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.figure import Figure
from wordcloud import WordCloud

from app.services.api_client import ApiClientError
from app.services.diary_service import DiaryService
from app.services.risk_service import RiskDetector
from app.database.repositories.risk_repository import RiskRepository

# Se necesita esta línea si el DataFrame tiene variables no numéricas para el gráfico de correlación
pd.options.mode.chained_assignment = None  # default='warn'

class InsightsView(QWidget):
    def __init__(self):
        super().__init__()
        
        main_layout = QVBoxLayout(self)
        main_layout.setContentsMargins(0, 0, 0, 0)
        
        # --- Carga de Datos desde API ---
        self.diary_service = DiaryService()
        self.risk_repo = RiskRepository()
        self.risk_detector = RiskDetector(self.risk_repo)
        try:
            self.df = self.diary_service.list_entries()
        except ApiClientError as exc:
            main_layout.addWidget(
                QLabel(f"Error al cargar datos del diario: {exc}", alignment=Qt.AlignCenter)
            )
            self.df = None
            return

        if self.df is None or self.df.empty:
            main_layout.addWidget(
                QLabel("No hay datos de diario disponibles.", alignment=Qt.AlignCenter)
            )
            return

        # Normalización de campos esperados por los gráficos
        self._normalize_dataframe()
        self._run_risk_detection()

        # Pestañas de submenú (con el nuevo apartado)
        tabs_layout = QHBoxLayout()
        self.btn_emocional = QPushButton("Análisis Emocional")
        self.btn_temporal = QPushButton("Análisis Temporal") # NUEVA PESTAÑA
        self.btn_riesgo = QPushButton("Alertas de Riesgo")
        self.btn_correlacion = QPushButton("Correlación de Datos")
        self._tab_buttons = [self.btn_emocional, self.btn_temporal, self.btn_riesgo, self.btn_correlacion]
        
        # Estilo de los botones de submenú
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
        self.btn_emocional.setStyleSheet(button_style)
        self.btn_temporal.setStyleSheet(button_style)
        self.btn_riesgo.setStyleSheet(button_style)
        self.btn_correlacion.setStyleSheet(button_style)
        
        self.btn_emocional.setCheckable(True)
        self.btn_temporal.setCheckable(True)
        self.btn_riesgo.setCheckable(True)
        self.btn_correlacion.setCheckable(True)
        for btn in self._tab_buttons:
            btn.setAutoExclusive(True)

        tabs_layout.addWidget(self.btn_emocional)
        tabs_layout.addWidget(self.btn_temporal)
        tabs_layout.addWidget(self.btn_riesgo)
        tabs_layout.addWidget(self.btn_correlacion)
        tabs_layout.addStretch()
        
        main_layout.addLayout(tabs_layout)

        # Contenido de las pestañas
        self.stacked_widget = QStackedWidget()
        main_layout.addWidget(self.stacked_widget)
        
        # Vistas internas
        self.stacked_widget.addWidget(self.create_emocional_view())
        self.stacked_widget.addWidget(self.create_temporal_view()) # NUEVA VISTA
        self.stacked_widget.addWidget(self.create_risk_alerts_view())
        self.stacked_widget.addWidget(self.create_correlacion_view())
        
        # Conectar botones a las vistas internas
        self.btn_emocional.clicked.connect(lambda: self._select_tab(0))
        self.btn_temporal.clicked.connect(lambda: self._select_tab(1))
        self.btn_riesgo.clicked.connect(lambda: self._select_tab(2))
        self.btn_correlacion.clicked.connect(lambda: self._select_tab(3))
        
        self._select_tab(0)

    def _select_tab(self, index: int) -> None:
        """Cambia la vista y marca sólo el botón activo."""
        self.stacked_widget.setCurrentIndex(index)
        for i, btn in enumerate(self._tab_buttons):
            btn.setChecked(i == index)

    def _extract_emotion(self, row):
        emotions = row.get("emotions")
        if isinstance(emotions, (list, tuple)) and emotions:
            return emotions[0]

        mood = row.get("mood")
        if isinstance(mood, str) and mood.strip():
            return mood

        mood_text = row.get("moodText")
        if isinstance(mood_text, str) and mood_text.strip():
            return mood_text

        return "Sin dato"

    def _normalize_dataframe(self):
        """Asegura columnas claves y valores por defecto para que los gráficos no fallen."""
        # Timestamp base
        self.df["timestamp"] = pd.to_datetime(
            self.df.get("date").fillna(self.df.get("createdAt")),
            errors="coerce"
        )
        self.df["timestamp"] = self.df["timestamp"].fillna(pd.Timestamp.now())

        # Texto y user_id (email preferente)
        self.df["text_entry"] = self.df.get("content", "").fillna("").astype(str)
        self.df["user_id"] = self.df.get("userEmail").fillna(self.df.get("userId")).astype(str)

        # Emoción principal
        self.df["emotion"] = self.df.apply(self._extract_emotion, axis=1)

        # Género
        if "gender" in self.df:
            gender_series = self.df["gender"]
        else:
            gender_series = pd.Series(["No especificado"] * len(self.df))
        self.df["gender"] = gender_series.fillna("No especificado").replace("", "No especificado").astype(str)

        # Edad (usa age directo o calcula desde birthdate/birthDate)
        age_series = pd.to_numeric(self.df.get("age"), errors="coerce") if "age" in self.df else pd.Series([pd.NA] * len(self.df))
        birthdate_series = pd.to_datetime(self.df.get("birthdate").fillna(self.df.get("birthDate")), errors="coerce") if ("birthdate" in self.df or "birthDate" in self.df) else pd.Series([pd.NaT] * len(self.df))
        missing_age_mask = age_series.isna() & birthdate_series.notna()
        if missing_age_mask.any():
            computed_age = (pd.Timestamp.now().normalize() - birthdate_series[missing_age_mask]).dt.days // 365
            age_series.loc[missing_age_mask] = computed_age
        age_series = age_series.fillna(pd.NA)
        # Mantener numérico donde existe, pero evitar -1; usar Int64 para permitir nulos
        self.df["age"] = age_series.astype("Int64")

        # Actividad (score)
        self.df["activity_level"] = pd.to_numeric(self.df.get("score"), errors="coerce").fillna(0)

        # Tags y emotions siempre como listas
        if "tags" not in self.df:
            self.df["tags"] = [[] for _ in range(len(self.df))]
        else:
            self.df["tags"] = self.df["tags"].apply(lambda v: v if isinstance(v, (list, tuple)) else [])
        if "emotions" not in self.df:
            self.df["emotions"] = [[] for _ in range(len(self.df))]
        else:
            self.df["emotions"] = self.df["emotions"].apply(lambda v: v if isinstance(v, (list, tuple)) else [])

    def _run_risk_detection(self):
        """Analiza todas las entradas con las palabras de riesgo locales."""
        try:
            self.alerts_df = self.risk_detector.analyze_entries(self.df)
        except Exception:
            self.alerts_df = pd.DataFrame()
        self.keywords_df = self.risk_detector.get_keywords()

    # ----------------------------------------------------------------------
    # --- Panel 1: Análisis Emocional Global (Mejorado) ---
    # ----------------------------------------------------------------------
    def create_emocional_view(self):
        view = QWidget()
        layout = QVBoxLayout(view)
        
        # --- Filtros en fila superior ---
        filters_group = QGroupBox("Filtros de Segmentación")
        filters_layout = QHBoxLayout(filters_group)
        
        filters_layout.addWidget(QLabel("<strong>Género:</strong>"))
        self.gender_filter = QComboBox()
        self.gender_filter.addItem("Todos los géneros")
        self.gender_filter.addItems(self.df['gender'].unique())
        filters_layout.addWidget(self.gender_filter)
        
        filters_layout.addWidget(QLabel("<strong>Edad:</strong>"))
        self.age_filter = QComboBox()
        self.age_filter.addItem("Todas las edades")
        age_values = [str(a) for a in sorted(self.df['age'].dropna().unique())]
        self.age_filter.addItems(age_values)
        filters_layout.addWidget(self.age_filter)

        filters_layout.addStretch()
        layout.addWidget(filters_group)

        # --- Gráficos con scroll ocupando el ancho ---
        self.charts_container_emocional = QWidget()
        self.charts_layout_emocional = QVBoxLayout(self.charts_container_emocional)
        
        scroll_area = QScrollArea()
        scroll_area.setWidgetResizable(True)
        scroll_area.setWidget(self.charts_container_emocional)
        layout.addWidget(scroll_area)

        # Conexión
        self.gender_filter.currentIndexChanged.connect(self.update_emocional_charts)
        self.age_filter.currentIndexChanged.connect(self.update_emocional_charts)

        self.update_emocional_charts()
        return view

    def update_emocional_charts(self):
        # ... (Lógica de filtrado) ...
        for i in reversed(range(self.charts_layout_emocional.count())):
            widget = self.charts_layout_emocional.itemAt(i).widget()
            if widget: widget.setParent(None)

        filtered_df = self.df.copy()
        selected_gender = self.gender_filter.currentText()
        if selected_gender != "Todos los géneros":
            filtered_df = filtered_df[filtered_df['gender'] == selected_gender]
        selected_age = self.age_filter.currentText()
        if selected_age != "Todas las edades":
            filtered_df = filtered_df[filtered_df['age'].astype(str) == selected_age]

        if filtered_df.empty:
            self.charts_layout_emocional.addWidget(QLabel("No hay datos para esta selección.", alignment=Qt.AlignCenter))
            return
        
        # Uso de QGridLayout para posicionar los gráficos de forma más limpia
        charts_grid = QWidget()
        grid_layout = QGridLayout(charts_grid)
        
        # Fila 1
        self.add_chart_widget(grid_layout, "Distribución de Emociones", self.create_emotion_pie_chart, filtered_df, row=0, col=0)
        self.add_chart_widget(grid_layout, "Emociones por Nivel de Actividad", self.create_activity_emotion_chart, filtered_df, row=0, col=1)
        
        # Fila 2
        self.add_chart_widget(grid_layout, "Tendencia de Emociones por Hora del Día", self.create_hourly_emotion_chart, filtered_df, row=1, col=0, colspan=2)
        
        self.charts_layout_emocional.addWidget(charts_grid)

    # ----------------------------------------------------------------------
    # --- Panel 2: Análisis Temporal (NUEVO APARTADO) ---
    # ----------------------------------------------------------------------
    def create_temporal_view(self):
        view = QWidget()
        layout = QVBoxLayout(view)
        
        # --- Controles de Tiempo ---
        controls_group = QGroupBox("Selección de Período")
        controls_layout = QHBoxLayout(controls_group)
        controls_layout.addWidget(QLabel("<strong>Unidad Temporal:</strong>"))
        
        self.time_unit_selector = QComboBox()
        self.time_unit_selector.addItems(["Día de la Semana", "Día del Mes", "Mes del Año"])
        controls_layout.addWidget(self.time_unit_selector)
        controls_layout.addStretch()
        layout.addWidget(controls_group)
        
        # --- Área de Gráficos (Scrollable) ---
        self.charts_container_temporal = QWidget()
        self.charts_layout_temporal = QVBoxLayout(self.charts_container_temporal)
        
        scroll_area = QScrollArea()
        scroll_area.setWidgetResizable(True)
        scroll_area.setWidget(self.charts_container_temporal)
        layout.addWidget(scroll_area)
        
        self.time_unit_selector.currentIndexChanged.connect(self.update_temporal_charts)
        self.update_temporal_charts()
        return view

    def update_temporal_charts(self):
        if self.df is None or self.df.empty:
            self.charts_layout_temporal.addWidget(QLabel("No hay datos para esta selección.", alignment=Qt.AlignCenter))
            return
        for i in reversed(range(self.charts_layout_temporal.count())):
            widget = self.charts_layout_temporal.itemAt(i).widget()
            if widget: widget.setParent(None)

        time_unit = self.time_unit_selector.currentText()
        
        self.add_chart_widget(self.charts_layout_temporal, 
                              f"Tendencia de Emociones por {time_unit}", 
                              self.create_temporal_emotion_trend, 
                              self.df, unit=time_unit)
        
        self.add_chart_widget(self.charts_layout_temporal, 
                              f"Volumen de Interacciones por {time_unit}", 
                              self.create_temporal_volume_trend, 
                              self.df, unit=time_unit)

    # ----------------------------------------------------------------------
    # --- Panel 3: Análisis de Sentimiento y Palabras Clave (Mejorado) ---
    # ----------------------------------------------------------------------
    def create_risk_alerts_view(self):
        view = QWidget()
        layout = QVBoxLayout(view)

        # Filtros y acciones
        filters_box = QGroupBox("Filtros y Acciones")
        filters_layout = QHBoxLayout(filters_box)

        self.level_filter = QComboBox()
        self.level_filter.addItem("Todos los niveles")
        self.level_filter.addItems(["Alto", "Medio"])
        self.level_filter.currentIndexChanged.connect(self._refresh_alerts_table)
        filters_layout.addWidget(QLabel("Nivel:"))
        filters_layout.addWidget(self.level_filter)

        self.user_filter = QLineEdit()
        self.user_filter.setPlaceholderText("Filtrar por usuario/email...")
        self.user_filter.textChanged.connect(self._refresh_alerts_table)
        filters_layout.addWidget(QLabel("Usuario/Email:"))
        filters_layout.addWidget(self.user_filter)

        self.reanalyze_btn = QPushButton("Actualizar análisis")
        self.reanalyze_btn.clicked.connect(self._on_reanalyze)
        filters_layout.addWidget(self.reanalyze_btn)

        self.view_text_btn = QPushButton("Ver texto completo")
        self.view_text_btn.clicked.connect(self._on_view_full_text)
        filters_layout.addWidget(self.view_text_btn)

        filters_layout.addStretch()
        layout.addWidget(filters_box)

        # Tabla de alertas
        self.alerts_table = QTableWidget()
        self.alerts_table.setColumnCount(6)
        self.alerts_table.setHorizontalHeaderLabels(["Usuario", "Email", "Palabra Detectada", "Nivel", "Fecha", "Vista previa"])
        self.alerts_table.setSortingEnabled(True)
        layout.addWidget(self.alerts_table)

        # Gestión de palabras clave
        keywords_box = QGroupBox("Palabras clave de riesgo")
        keywords_layout = QVBoxLayout(keywords_box)
        self.keywords_table = QTableWidget()
        self.keywords_table.setColumnCount(2)
        self.keywords_table.setHorizontalHeaderLabels(["Palabra/Frase", "Nivel"])
        keywords_layout.addWidget(self.keywords_table)

        buttons_layout = QHBoxLayout()
        self.add_keyword_btn = QPushButton("Agregar")
        self.edit_keyword_btn = QPushButton("Editar")
        self.delete_keyword_btn = QPushButton("Eliminar")
        self.add_keyword_btn.clicked.connect(self._on_add_keyword)
        self.edit_keyword_btn.clicked.connect(self._on_edit_keyword)
        self.delete_keyword_btn.clicked.connect(self._on_delete_keyword)
        buttons_layout.addWidget(self.add_keyword_btn)
        buttons_layout.addWidget(self.edit_keyword_btn)
        buttons_layout.addWidget(self.delete_keyword_btn)
        buttons_layout.addStretch()
        keywords_layout.addLayout(buttons_layout)

        layout.addWidget(keywords_box)

        self._refresh_keywords_table()
        self._refresh_alerts_table()
        return view

    def _filter_alerts_df(self) -> pd.DataFrame:
        df = self.alerts_df.copy() if hasattr(self, "alerts_df") else pd.DataFrame()
        if not df.empty:
            df["email"] = df["email"].fillna("").astype(str)
            df["usuario"] = df["usuario"].fillna("").astype(str)
        level = self.level_filter.currentText()
        if level != "Todos los niveles" and not df.empty:
            df = df[df["nivel"] == level]
        user_text = self.user_filter.text().strip().lower()
        if user_text and not df.empty:
            df = df[df["email"].str.lower().str.contains(user_text) | df["usuario"].str.lower().str.contains(user_text)]
        return df

    def _refresh_alerts_table(self):
        df = self._filter_alerts_df()
        self.alerts_table.setRowCount(0)
        if df.empty:
            return
        self.alerts_table.setRowCount(len(df))
        for row_idx, (_, row) in enumerate(df.iterrows()):
            values = [
                row.get("usuario", ""),
                row.get("email", ""),
                row.get("palabra", ""),
                row.get("nivel", ""),
                row.get("fecha", ""),
                row.get("preview", ""),
            ]
            for col_idx, value in enumerate(values):
                item = QTableWidgetItem(str(value))
                self.alerts_table.setItem(row_idx, col_idx, item)
        self.alerts_table.resizeColumnsToContents()

    def _refresh_keywords_table(self):
        self.keywords_df = self.risk_detector.get_keywords()
        df = self.keywords_df
        self.keywords_table.setRowCount(0)
        if df.empty:
            return
        self.keywords_table.setRowCount(len(df))
        for row_idx, (_, row) in enumerate(df.iterrows()):
            self.keywords_table.setItem(row_idx, 0, QTableWidgetItem(str(row["phrase"])))
            self.keywords_table.setItem(row_idx, 1, QTableWidgetItem(str(row["risk_level"])))
        self.keywords_table.resizeColumnsToContents()

    def _get_selected_keyword_id(self) -> Optional[int]:
        selected = self.keywords_table.currentRow()
        if selected < 0 or self.keywords_df.empty:
            return None
        try:
            return int(self.keywords_df.iloc[selected]["id"])
        except Exception:
            return None

    def _show_keyword_dialog(self, title: str, phrase: str = "", level: str = "Medio") -> Optional[tuple]:
        dialog = QDialog(self)
        dialog.setWindowTitle(title)
        form = QFormLayout(dialog)
        phrase_input = QLineEdit(phrase)
        level_combo = QComboBox()
        level_combo.addItems(["Alto", "Medio"])
        level_combo.setCurrentText(level)
        form.addRow("Palabra/Frase:", phrase_input)
        form.addRow("Nivel de Riesgo:", level_combo)

        buttons = QDialogButtonBox(QDialogButtonBox.Ok | QDialogButtonBox.Cancel)
        buttons.accepted.connect(dialog.accept)
        buttons.rejected.connect(dialog.reject)
        form.addWidget(buttons)
        if dialog.exec_() == QDialog.Accepted:
            return phrase_input.text().strip(), level_combo.currentText()
        return None

    def _on_add_keyword(self):
        result = self._show_keyword_dialog("Agregar palabra clave")
        if not result:
            return
        phrase, level = result
        if self.risk_detector.add_or_update_keyword(phrase, level):
            self._refresh_keywords_table()
            self._on_reanalyze()

    def _on_edit_keyword(self):
        keyword_id = self._get_selected_keyword_id()
        if keyword_id is None:
            return
        row = self.keywords_df[self.keywords_df["id"] == keyword_id].iloc[0]
        result = self._show_keyword_dialog("Editar palabra clave", phrase=row["phrase"], level=row["risk_level"])
        if not result:
            return
        phrase, level = result
        if self.risk_detector.add_or_update_keyword(phrase, level, keyword_id=keyword_id):
            self._refresh_keywords_table()
            self._on_reanalyze()

    def _on_delete_keyword(self):
        keyword_id = self._get_selected_keyword_id()
        if keyword_id is None:
            return
        if self.risk_detector.delete_keyword(keyword_id):
            self._refresh_keywords_table()
            self._on_reanalyze()

    def _on_reanalyze(self):
        self.risk_repo.clear_alerts()
        self._run_risk_detection()
        self._refresh_alerts_table()

    def _on_view_full_text(self):
        row_idx = self.alerts_table.currentRow()
        if row_idx < 0:
            return
        df = self._filter_alerts_df()
        if df.empty or row_idx >= len(df):
            return
        row = df.iloc[row_idx]
        dialog = QDialog(self)
        dialog.setWindowTitle("Texto completo de la entrada")
        layout = QVBoxLayout(dialog)
        layout.addWidget(QLabel(f"Usuario: {row.get('usuario', '')} | Email: {row.get('email', '')}"))
        text_area = QPlainTextEdit()
        text_area.setPlainText(row.get("texto", ""))
        text_area.setReadOnly(True)
        layout.addWidget(text_area)
        buttons = QDialogButtonBox(QDialogButtonBox.Close)
        buttons.rejected.connect(dialog.reject)
        buttons.accepted.connect(dialog.accept)
        layout.addWidget(buttons)
        dialog.resize(600, 400)
        dialog.exec_()

    # ----------------------------------------------------------------------
    # --- Panel 4: Correlación de Datos (Mejorado) ---
    # ----------------------------------------------------------------------
    def create_correlacion_view(self):
        view = QWidget()
        layout = QVBoxLayout(view)
        
        # Filtros para la selección de variables
        filters_container = QGroupBox("Selección de Variables")
        filters_layout = QHBoxLayout(filters_container)
        
        filters_layout.addWidget(QLabel("<strong>Eje X:</strong>"))
        self.x_axis_selector = QComboBox()
        self.x_axis_selector.addItems(['age', 'activity_level', 'gender', 'emotion', 'timestamp'])
        filters_layout.addWidget(self.x_axis_selector)
        
        filters_layout.addWidget(QLabel("<strong>Eje Y:</strong>"))
        self.y_axis_selector = QComboBox()
        self.y_axis_selector.addItems(['activity_level', 'age', 'gender', 'emotion', 'timestamp'])
        filters_layout.addWidget(self.y_axis_selector)

        self.generate_button = QPushButton("Generar Gráfico")
        self.generate_button.setStyleSheet("background-color: #A28FC9; color: white;")
        filters_layout.addWidget(self.generate_button)
        filters_layout.addStretch()
        layout.addWidget(filters_container)
        
        # Contenedor del gráfico (Scrollable)
        self.chart_area = QWidget()
        self.chart_layout = QVBoxLayout(self.chart_area)
        
        scroll_area = QScrollArea()
        scroll_area.setWidgetResizable(True)
        scroll_area.setWidget(self.chart_area)
        layout.addWidget(scroll_area)
        
        # Conectar el botón para generar el gráfico
        self.generate_button.clicked.connect(self.update_correlation_chart)

        # Gráfico por defecto
        self.chart_layout.addWidget(QLabel("Selecciona dos variables y presiona 'Generar Gráfico'."))
        
        return view

    # ----------------------------------------------------------------------
    # --- Lógica de Gráficos (Métodos Auxiliares) ---
    # ----------------------------------------------------------------------
    
    # --- Lógica de Correlación (Mejorada) ---
    def update_correlation_chart(self):
        if self.df is None or self.df.empty:
            self.chart_layout.addWidget(QLabel("No hay datos para correlacionar."))
            return
        # Limpiar el área del gráfico
        for i in reversed(range(self.chart_layout.count())):
            widget = self.chart_layout.itemAt(i).widget()
            if widget: widget.setParent(None)
        
        x_var = self.x_axis_selector.currentText()
        y_var = self.y_axis_selector.currentText()

        # Evitar correlación de la variable consigo misma
        if x_var == y_var:
            self.chart_layout.addWidget(QLabel("Por favor, selecciona dos variables diferentes."))
            return
            
        # Determinar el tipo de gráfico basado en las variables
        df_corr = self.df.copy()
        
        # Intentar determinar los tipos de columna con cuidado
        x_type = df_corr[x_var].dtype
        y_type = df_corr[y_var].dtype
        
        # Si alguna es timestamp, forzarla a numérico (solo si la otra es numérica) para Scatter, o a categórico para Tendencia
        if x_var == 'timestamp' and y_var in ['age', 'activity_level']:
            # Time Series Scatter/Line Plot
            chart_canvas = self.create_time_series_plot(x_var, y_var, df_corr)
        elif y_var == 'timestamp' and x_var in ['age', 'activity_level']:
            # Time Series Scatter/Line Plot (ejes invertidos, pero la lógica de Matplotlib lo maneja)
            chart_canvas = self.create_time_series_plot(x_var, y_var, df_corr)
        elif x_type in ['int64', 'float64'] and y_type in ['int64', 'float64']:
            chart_canvas = self.create_scatter_plot_view(x_var, y_var, df_corr)
        elif x_type in ['object', 'category'] or y_type in ['object', 'category']:
            chart_canvas = self.create_bar_plot_view(x_var, y_var, df_corr)
        else:
            self.chart_layout.addWidget(QLabel("Tipo de gráfico no soportado para las variables seleccionadas."))
            return
            
        self.chart_layout.addWidget(chart_canvas)
        
    def create_scatter_plot_view(self, x_var, y_var, df):
        fig = Figure(figsize=(10, 8))
        ax = fig.add_subplot(111)
        sns.scatterplot(x=x_var, y=y_var, hue='gender', data=df, ax=ax, palette='deep', s=100)
        ax.set_title(f'Correlación entre {x_var.capitalize()} y {y_var.capitalize()}')
        ax.set_xlabel(x_var.capitalize())
        ax.set_ylabel(y_var.capitalize())
        ax.grid(True)
        fig.tight_layout()
        return FigureCanvas(fig)

    def create_bar_plot_view(self, x_var, y_var, df):
        fig = Figure(figsize=(10, 8))
        ax = fig.add_subplot(111)
        df_clean = df.dropna(subset=[x_var, y_var]).copy()

        from pandas.api.types import is_numeric_dtype

        x_is_num = is_numeric_dtype(df_clean[x_var])
        y_is_num = is_numeric_dtype(df_clean[y_var])

        if y_is_num and not x_is_num:
            # Promedio de y por categoría x
            pivot = df_clean.groupby(x_var)[y_var].mean()
            pivot.plot(kind='bar', ax=ax, color="#7aa6c2", legend=False)
            ax.set_ylabel(f'Promedio de {y_var.capitalize()}')
        elif x_is_num and not y_is_num:
            # Promedio de x por categoría y
            pivot = df_clean.groupby(y_var)[x_var].mean()
            pivot.plot(kind='bar', ax=ax, color="#7aa6c2", legend=False)
            ax.set_ylabel(f'Promedio de {x_var.capitalize()}')
            ax.set_xlabel(y_var.capitalize())
        elif x_is_num and y_is_num:
            # Ambos numéricos: usar barplot directo
            sns.barplot(x=x_var, y=y_var, data=df_clean, ax=ax)
            ax.set_ylabel(f'Promedio de {y_var.capitalize()}')
        else:
            # Ambas categóricas: conteo apilado
            pivot_table = pd.crosstab(df_clean[x_var], df_clean[y_var])
            pivot_table = pivot_table.apply(pd.to_numeric, errors="coerce").fillna(0)
            pivot_table.plot(kind='bar', stacked=True, ax=ax, colormap='Spectral')
            ax.set_ylabel('Conteo')

        ax.set_title(f'Distribución de {y_var.capitalize()} por {x_var.capitalize()}')
        ax.set_xlabel(x_var.capitalize())
        ax.tick_params(axis='x', rotation=45)
        fig.tight_layout()
        return FigureCanvas(fig)
        
    def create_time_series_plot(self, x_var, y_var, df):
        fig = Figure(figsize=(12, 6))
        ax = fig.add_subplot(111)
        
        # Forzar 'timestamp' a ser la variable x para una serie temporal clara
        x_col = 'timestamp' if x_var == 'timestamp' else 'timestamp'
        y_col = y_var if x_var == 'timestamp' else x_var # La otra variable es la numérica
        
        # Calcular el promedio por día
        daily_data = df.set_index('timestamp').resample('D')[y_col].mean().reset_index()
        
        sns.lineplot(x='timestamp', y=y_col, data=daily_data, ax=ax, marker='o')
        
        ax.set_title(f'Tendencia Diaria de {y_col.capitalize()} a lo Largo del Tiempo')
        ax.set_xlabel("Fecha")
        ax.set_ylabel(y_col.capitalize())
        ax.grid(True)
        fig.tight_layout()
        return FigureCanvas(fig)
    
    # --- Lógica de Gráficos Emocionales y Palabras Clave ---
    def add_chart_widget(self, layout, title, chart_function, df, **kwargs):
        """Método unificado para agregar QGroupBox con gráficos, soporta GridLayout."""
        group_box = QGroupBox(title)
        group_layout = QVBoxLayout(group_box)
        
        # Maneja la diferencia entre QGridLayout y QVBoxLayout
        row = kwargs.get('row', -1)
        col = kwargs.get('col', -1)
        colspan = kwargs.get('colspan', 1)
        
        # Llamada a la función del gráfico
        # Se pasan argumentos específicos si son necesarios (e.g., unit para Temporal)
        chart_args = {k: v for k, v in kwargs.items() if k in ['unit']}
        canvas = chart_function(df, **chart_args)
        
        group_layout.addWidget(canvas)

        if isinstance(layout, QGridLayout):
            layout.addWidget(group_box, row, col, 1, colspan)
        else:
            layout.addWidget(group_box)

    def create_emotion_pie_chart(self, df, **kwargs):
        emotion_counts = df['emotion'].value_counts()
        fig = Figure(figsize=(4, 4))
        ax = fig.add_subplot(111)
        ax.pie(emotion_counts, labels=emotion_counts.index, autopct='%1.1f%%', startangle=90, colors=sns.color_palette('pastel'))
        ax.axis('equal')
        return FigureCanvas(fig)

    def create_hourly_emotion_chart(self, df, **kwargs):
        df['hour'] = df['timestamp'].dt.hour
        hourly_emotion_counts = df.groupby(['hour', 'emotion']).size().unstack(fill_value=0)
        
        fig = Figure(figsize=(10, 5))
        ax = fig.add_subplot(111)
        hourly_emotion_counts.plot(kind='line', marker='o', ax=ax)
        ax.set_title("Tendencia de Emociones por Hora del Día")
        ax.set_xlabel("Hora del Día (0-23)")
        ax.set_ylabel("Número de Entradas")
        ax.grid(True)
        ax.legend(title='Emoción', bbox_to_anchor=(1.05, 1), loc='upper left')
        fig.tight_layout()
        return FigureCanvas(fig)

    def create_activity_emotion_chart(self, df, **kwargs):
        avg_activity = df.groupby('emotion')['activity_level'].mean().sort_values(ascending=False)
        
        fig = Figure(figsize=(6, 4))
        ax = fig.add_subplot(111)
        sns.barplot(x=avg_activity.index, y=avg_activity.values, ax=ax, palette='viridis', hue=avg_activity.index, legend=False)
        ax.set_title("Nivel de Actividad Promedio por Emoción")
        ax.set_ylabel("Nivel de Actividad Promedio")
        ax.set_xlabel("Emoción")
        ax.tick_params(axis='x', rotation=45)
        fig.tight_layout()
        return FigureCanvas(fig)
        
    # --- Lógica de Gráficos Temporales (Nuevos) ---
    def get_temporal_key(self, df, unit):
        if unit == "Día de la Semana":
            # 0=Lunes, 6=Domingo. Usar .day_name() para etiquetas legibles
            df['temporal_key'] = df['timestamp'].dt.dayofweek
            return 'temporal_key', df.sort_values('temporal_key'), {i: day for i, day in enumerate(['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'])}
        elif unit == "Día del Mes":
            df['temporal_key'] = df['timestamp'].dt.day
            return 'temporal_key', df.sort_values('temporal_key'), None
        elif unit == "Mes del Año":
            df['temporal_key'] = df['timestamp'].dt.month
            return 'temporal_key', df.sort_values('temporal_key'), {i: month for i, month in enumerate(['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'], start=1)}
        return None, df, None

    def create_temporal_emotion_trend(self, df, unit):
        key_col, df_sorted, labels = self.get_temporal_key(df.copy(), unit)
        
        if key_col is None: return FigureCanvas(Figure())

        # Calcular la moda (emoción más frecuente) por período
        trend = df_sorted.groupby(key_col)['emotion'].apply(lambda x: x.mode().iloc[0] if not x.mode().empty else 'N/A').reset_index()
        
        fig = Figure(figsize=(10, 6))
        ax = fig.add_subplot(111)
        sns.barplot(x=key_col, y='emotion', data=trend, ax=ax, hue='emotion', legend=False, palette='Spectral')
        
        ax.set_title(f"Emoción Dominante por {unit}")
        ax.set_xlabel(unit)
        ax.set_ylabel("Emoción Dominante")
        
        if labels:
            ax.set_xticks(list(labels.keys()))
            ax.set_xticklabels(list(labels.values()), rotation=45)
        
        fig.tight_layout()
        return FigureCanvas(fig)

    def create_temporal_volume_trend(self, df, unit):
        key_col, df_sorted, labels = self.get_temporal_key(df.copy(), unit)

        if key_col is None: return FigureCanvas(Figure())

        volume = df_sorted.groupby(key_col).size().reset_index(name='count')
        
        fig = Figure(figsize=(10, 6))
        ax = fig.add_subplot(111)
        sns.lineplot(x=key_col, y='count', data=volume, ax=ax, marker='o', color='#A28FC9') # Color violeta de la aplicación
        
        ax.set_title(f"Volumen de Interacciones por {unit}")
        ax.set_xlabel(unit)
        ax.set_ylabel("Total de Interacciones")
        ax.grid(True)
        
        if labels:
            ax.set_xticks(list(labels.keys()))
            ax.set_xticklabels(list(labels.values()), rotation=45)
            
        fig.tight_layout()
        return FigureCanvas(fig)

    # --- Lógica de Gráficos de Palabras Clave ---
    def create_keyword_bar_chart(self, df, **kwargs):
        all_text = " ".join(df["text_entry"].str.lower().replace(r"[^\w\s]", "", regex=True))
        words = all_text.split()
        word_counts = Counter(words)
        
        # Stop words comunes en español (extendida)
        common_words = {'y', 'un', 'una', 'la', 'el', 'de', 'con', 'en', 'hoy', 'me', 'por', 'a', 'del', 'los', 'las', 'se', 'mi', 'que', 'es', 'todo', 'lo', 'no', 'muy', 'pero', 'mas'}
        filtered_word_counts = {word: count for word, count in word_counts.items() if word not in common_words and len(word) > 2}
        
        top_words = pd.DataFrame(filtered_word_counts.items(), columns=['word', 'count']).sort_values('count', ascending=False).head(10)
        
        fig = Figure(figsize=(6, 4))
        ax = fig.add_subplot(111)
        sns.barplot(x='count', y='word', data=top_words, ax=ax, palette='mako', hue='word', legend=False)
        ax.set_title("Palabras Más Frecuentes (Filtradas)")
        ax.set_xlabel("Conteo")
        ax.set_ylabel("Palabra")
        fig.tight_layout()
        return FigureCanvas(fig)

    def create_word_cloud(self, df, **kwargs):
        all_text = " ".join(df['text_entry'].astype(str))
        
        # Stop words
        stop_words = {'y', 'un', 'una', 'el', 'la', 'de', 'con', 'en', 'los', 'las', 'que', 'es', 'mi', 'me', 'por', 'a', 'del', 'no', 'todo', 'muy', 'pero'}

        wordcloud = WordCloud(width=400, height=300, background_color='white', stopwords=stop_words).generate(all_text)
        
        fig = Figure(figsize=(6, 4))
        ax = fig.add_subplot(111)
        ax.imshow(wordcloud, interpolation='bilinear')
        ax.axis("off")
        fig.tight_layout()
        return FigureCanvas(fig)


if __name__ == '__main__':
    from PyQt5.QtWidgets import QApplication
    import sys
    
    app = QApplication(sys.argv)
    # Crear un DataFrame de ejemplo si no existe el archivo real (para pruebas)
    try:
        pd.read_csv('emotion_data.csv')
    except FileNotFoundError:
        import numpy as np
        data = {
            'user_id': [f'user_{i%5 + 1}' for i in range(100)],
            'timestamp': pd.date_range(start='8/1/2025', periods=100, freq='H'),
            'emotion': np.random.choice(['Felicidad', 'Tristeza', 'Enojo', 'Calma', 'Ansiedad'], 100),
            'text_entry': np.random.choice(['Me ascendieron en el trabajo.', 'No puedo dormir bien.', 'Todo salió bien en el examen.', 'Esto es frustrante.', 'Todo está en orden.'], 100),
            'gender': np.random.choice(['Masculino', 'Femenino', 'No binario'], 100),
            'age': np.random.randint(18, 50, 100),
            'activity_level': np.random.randint(10, 90, 100)
        }
        df_test = pd.DataFrame(data)
        df_test.to_csv('emotion_data.csv', index=False)
        
    window = InsightsView()
    window.setWindowTitle("Análisis y Perspectivas de Datos")
    window.resize(1200, 800)
    window.show()
    sys.exit(app.exec_())
