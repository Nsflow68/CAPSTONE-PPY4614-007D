from __future__ import annotations

from collections import Counter

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
    QLabel,
    QPushButton,
    QScrollArea,
    QStackedWidget,
    QVBoxLayout,
    QWidget,
)
from matplotlib.backends.backend_qt5agg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.figure import Figure
from wordcloud import WordCloud

from app.config import DATA_DIR

# Se necesita esta línea si el DataFrame tiene variables no numéricas para el gráfico de correlación
pd.options.mode.chained_assignment = None  # default='warn'

class InsightsView(QWidget):
    def __init__(self):
        super().__init__()
        
        main_layout = QVBoxLayout(self)
        main_layout.setContentsMargins(0, 0, 0, 0)
        
        # --- Carga de Datos ---
        data_path = DATA_DIR / "emotion_data.csv"
        if not data_path.exists():
            main_layout.addWidget(
                QLabel("Error: Archivo 'emotion_data.csv' no encontrado.", alignment=Qt.AlignCenter)
            )
            self.df = None
            return

        self.df = pd.read_csv(data_path)
        self.df["timestamp"] = pd.to_datetime(self.df["timestamp"])

        # Pestañas de submenú (con el nuevo apartado)
        tabs_layout = QHBoxLayout()
        self.btn_emocional = QPushButton("Análisis Emocional")
        self.btn_temporal = QPushButton("Análisis Temporal") # NUEVA PESTAÑA
        self.btn_palabras = QPushButton("Palabras Clave")
        self.btn_correlacion = QPushButton("Correlación de Datos")
        
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
        self.btn_palabras.setStyleSheet(button_style)
        self.btn_correlacion.setStyleSheet(button_style)
        
        self.btn_emocional.setCheckable(True)
        self.btn_temporal.setCheckable(True)
        self.btn_palabras.setCheckable(True)
        self.btn_correlacion.setCheckable(True)

        tabs_layout.addWidget(self.btn_emocional)
        tabs_layout.addWidget(self.btn_temporal)
        tabs_layout.addWidget(self.btn_palabras)
        tabs_layout.addWidget(self.btn_correlacion)
        tabs_layout.addStretch()
        
        main_layout.addLayout(tabs_layout)

        # Contenido de las pestañas
        self.stacked_widget = QStackedWidget()
        main_layout.addWidget(self.stacked_widget)
        
        # Vistas internas
        self.stacked_widget.addWidget(self.create_emocional_view())
        self.stacked_widget.addWidget(self.create_temporal_view()) # NUEVA VISTA
        self.stacked_widget.addWidget(self.create_palabras_clave_view())
        self.stacked_widget.addWidget(self.create_correlacion_view())
        
        # Conectar botones a las vistas internas
        self.btn_emocional.clicked.connect(lambda: self.stacked_widget.setCurrentIndex(0))
        self.btn_temporal.clicked.connect(lambda: self.stacked_widget.setCurrentIndex(1))
        self.btn_palabras.clicked.connect(lambda: self.stacked_widget.setCurrentIndex(2))
        self.btn_correlacion.clicked.connect(lambda: self.stacked_widget.setCurrentIndex(3))
        
        self.btn_emocional.setChecked(True)

    # ----------------------------------------------------------------------
    # --- Panel 1: Análisis Emocional Global (Mejorado) ---
    # ----------------------------------------------------------------------
    def create_emocional_view(self):
        view = QWidget()
        layout = QHBoxLayout(view)
        
        # --- Columna Izquierda: Filtros (UX Mejorada) ---
        filters_group = QGroupBox("Filtros de Segmentación")
        filters_layout = QVBoxLayout(filters_group)
        filters_group.setMaximumWidth(250)
        
        filters_layout.addWidget(QLabel("<strong>Género:</strong>"))
        self.gender_filter = QComboBox()
        self.gender_filter.addItem("Todos los géneros")
        self.gender_filter.addItems(self.df['gender'].unique())
        filters_layout.addWidget(self.gender_filter)
        
        filters_layout.addWidget(QLabel("<strong>Edad:</strong>"))
        self.age_filter = QComboBox()
        self.age_filter.addItem("Todas las edades")
        self.age_filter.addItems(sorted(self.df['age'].unique().astype(str)))
        filters_layout.addWidget(self.age_filter)
        
        filters_layout.addStretch(1) # Relleno para que los filtros no se peguen arriba
        layout.addWidget(filters_group)

        # --- Columna Derecha: Gráficos (Scrollable) ---
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
    def create_palabras_clave_view(self):
        view = QWidget()
        layout = QHBoxLayout(view)
        
        # --- Columna Izquierda: Filtros ---
        filters_group = QGroupBox("Filtro por Emoción")
        filters_layout = QVBoxLayout(filters_group)
        filters_group.setMaximumWidth(250)

        filters_layout.addWidget(QLabel("<strong>Emoción a Analizar:</strong>"))
        self.emotion_filter = QComboBox()
        self.emotion_filter.addItem("Todas las emociones")
        self.emotion_filter.addItems(self.df['emotion'].unique())
        filters_layout.addWidget(self.emotion_filter)
        
        filters_layout.addStretch(1)
        layout.addWidget(filters_group)
        
        # --- Columna Derecha: Gráficos (Scrollable) ---
        self.charts_container_palabras = QWidget()
        self.charts_layout_palabras = QVBoxLayout(self.charts_container_palabras)
        
        scroll_area = QScrollArea()
        scroll_area.setWidgetResizable(True)
        scroll_area.setWidget(self.charts_container_palabras)
        layout.addWidget(scroll_area)
        
        self.emotion_filter.currentIndexChanged.connect(self.update_palabras_clave_charts)
        
        self.update_palabras_clave_charts()
        return view

    def update_palabras_clave_charts(self):
        # ... (Lógica de filtrado) ...
        for i in reversed(range(self.charts_layout_palabras.count())):
            widget = self.charts_layout_palabras.itemAt(i).widget()
            if widget: widget.setParent(None)

        filtered_df = self.df.copy()
        selected_emotion = self.emotion_filter.currentText()
        if selected_emotion != "Todas las emociones":
            filtered_df = filtered_df[filtered_df['emotion'] == selected_emotion]
            
        if filtered_df.empty:
            self.charts_layout_palabras.addWidget(QLabel("No hay datos para esta selección.", alignment=Qt.AlignCenter))
            return
        
        # Muestra la nube de palabras y el gráfico de barras uno al lado del otro
        charts_grid = QWidget()
        grid_layout = QGridLayout(charts_grid)
        
        self.add_chart_widget(grid_layout, "Frecuencia de Palabras Clave (Top 10)", self.create_keyword_bar_chart, filtered_df, row=0, col=0)
        self.add_chart_widget(grid_layout, f"Nube de Palabras para '{selected_emotion}'", self.create_word_cloud, filtered_df, row=0, col=1)

        self.charts_layout_palabras.addWidget(charts_grid)

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
        
        # Para evitar el error de plotear dos categóricas directamente
        if df[y_var].dtype in ['int64', 'float64']:
            sns.barplot(x=x_var, y=y_var, data=df, ax=ax)
            ax.set_ylabel(f'Promedio de {y_var.capitalize()}')
        else:
            # Gráfico de barras apilado (stacked bar chart) para dos categóricas
            pivot_table = pd.crosstab(df[x_var], df[y_var])
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
