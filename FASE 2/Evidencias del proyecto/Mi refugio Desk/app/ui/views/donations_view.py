from __future__ import annotations

from typing import Optional

import pandas as pd
from PyQt5.QtCore import QAbstractTableModel, Qt, QVariant
from PyQt5.QtWidgets import (
    QHBoxLayout,
    QLabel,
    QMessageBox,
    QPushButton,
    QTableView,
    QVBoxLayout,
    QWidget,
    QHeaderView,
    QGroupBox,
    QFrame,
)

from app.services.donation_service import DonationService
from app.services.api_client import ApiClientError


class DonationsView(QWidget):
    def __init__(self, donation_service: Optional[DonationService] = None) -> None:
        super().__init__()
        self._service = donation_service or DonationService()
        self._table_model = PandasModel(pd.DataFrame())

        self._total_label = QLabel()
        self._count_label = QLabel()
        self._currency_label = QLabel()
        self._title_label = QLabel("<h2>Donaciones</h2>")
        self._table_view = QTableView()

        self._build_ui()
        self._load_data()

    def _build_ui(self) -> None:
        layout = QVBoxLayout(self)
        layout.setContentsMargins(10, 10, 10, 10)
        layout.setSpacing(14)

        self._title_label.setStyleSheet("margin: 0 0 6px 2px; color: #2e2e2e;")
        layout.addWidget(self._title_label)

        layout.addWidget(self._build_summary_box())

        self._table_view.setModel(self._table_model)
        self._table_view.horizontalHeader().setSectionResizeMode(QHeaderView.Stretch)
        self._table_view.verticalHeader().setVisible(False)
        self._table_view.setAlternatingRowColors(True)
        self._table_view.setStyleSheet(
            """
            QTableView {
                background: #fafafa;
                alternate-background-color: #f2f2f7;
                border: 1px solid #e0e0e0;
                gridline-color: #e0e0e0;
            }
            QHeaderView::section {
                background: #ededed;
                padding: 6px;
                border: 1px solid #d4d4d4;
                font-weight: 600;
            }
            """
        )
        layout.addWidget(self._table_view)

    def _build_summary_box(self) -> QWidget:
        group = QGroupBox("Resumen")
        group.setStyleSheet(
            """
            QGroupBox {
                font-weight: 600;
                border: 1px solid #d9d9d9;
                border-radius: 8px;
                padding: 8px 10px 10px 10px;
                margin-top: 6px;
                background: #fefefe;
            }
            """
        )
        group_layout = QHBoxLayout(group)
        group_layout.setContentsMargins(10, 4, 10, 4)
        group_layout.setSpacing(18)

        for label in (self._total_label, self._count_label, self._currency_label):
            label.setStyleSheet("font-size: 14px; color: #333;")
            group_layout.addWidget(label)

        group_layout.addStretch()

        refresh_btn = QPushButton("↻ Actualizar")
        refresh_btn.setToolTip("Recargar donaciones desde la API")
        refresh_btn.setStyleSheet(
            """
            QPushButton {
                padding: 6px 12px;
                border-radius: 6px;
                background-color: #5c6bc0;
                color: white;
                font-weight: 600;
            }
            QPushButton:hover { background-color: #3f51b5; }
            """
        )
        refresh_btn.clicked.connect(self._load_data)
        group_layout.addWidget(refresh_btn)
        return group

    def _load_data(self) -> None:
        try:
            df, summary = self._service.fetch_donations()
        except ApiClientError as exc:
            QMessageBox.critical(self, "Error al cargar donaciones", str(exc))
            return

        df = self._format_dataframe(df, summary.get("currency"))
        if df.empty:
            # Aseguramos una tabla con al menos una columna para mostrar estado vacío.
            df = pd.DataFrame(columns=["Sin datos"])

        self._table_model.set_data(df)

        total_amount = summary.get("total_amount")
        currency = summary.get("currency") or ""
        total_records = int(summary.get("total_records") or len(df.index))

        amount_text = (
            f"{float(total_amount):,.2f}{(' ' + currency) if currency else ''}"
            if isinstance(total_amount, (int, float))
            else "N/D"
        )


        self._total_label.setText(f"Total recaudado: <strong>{amount_text}</strong>")
        self._count_label.setText(f"Total donaciones: <strong>{total_records}</strong>")
        if currency:
            self._currency_label.setText(f"Moneda: <strong>{currency}</strong>")
        else:
            self._currency_label.setText("Moneda: N/D")

    @staticmethod
    def _format_dataframe(df: pd.DataFrame, currency: Optional[str]) -> pd.DataFrame:
        if df.empty:
            return df

        formatted = df.copy()

        # Reordenamos a un orden lógico.
        desired_order = [col for col in ["ID", "Fecha", "Monto", "Moneda", "Donante", "Email", "Mensaje"] if col in formatted.columns]
        formatted = formatted[[col for col in desired_order]]

        if "Monto" in formatted.columns:
            formatted["Monto"] = formatted["Monto"].apply(
    lambda x: f"{float(x):,.2f} {currency}" if pd.notna(x) and currency else f"{float(x):,.2f}"
)

        if "Fecha" in formatted.columns:
            formatted["Fecha"] = formatted["Fecha"].apply(
                lambda x: pd.to_datetime(x).strftime("%d/%m/%Y %H:%M") if pd.notna(x) else ""
            )
        return formatted


class PandasModel(QAbstractTableModel):
    """Modelo simple para renderizar DataFrames en un QTableView."""

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
