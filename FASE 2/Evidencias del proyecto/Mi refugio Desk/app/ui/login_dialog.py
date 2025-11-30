from __future__ import annotations

from typing import Optional

from PyQt5.QtCore import Qt
from PyQt5.QtGui import QShowEvent
from PyQt5.QtWidgets import (
    QDialog,
    QFormLayout,
    QHBoxLayout,
    QLabel,
    QLineEdit,
    QPushButton,
    QVBoxLayout,
)

from app.models.user import UserRecord
from app.services.auth_service import AuthService


class LoginDialog(QDialog):
    """Cuadro de diálogo para iniciar sesión en el panel."""

    def __init__(self, auth_service: AuthService, parent=None) -> None:
        super().__init__(parent)
        self._auth_service = auth_service
        self.user: Optional[UserRecord] = None

        self.setWindowTitle("Iniciar sesión")
        self.setModal(True)
        self.setFixedWidth(380)

        self._username_input = QLineEdit()
        self._password_input = QLineEdit()
        self._password_input.setEchoMode(QLineEdit.Password)
        self._username_input.setPlaceholderText("Usuario")
        self._password_input.setPlaceholderText("Contraseña")
        self._username_input.returnPressed.connect(self._password_input.setFocus)
        self._password_input.returnPressed.connect(self._handle_login)

        self._status_label = QLabel()
        self._status_label.setWordWrap(True)
        self._status_label.setObjectName("LoginStatusLabel")
        self._status_label.setAlignment(Qt.AlignCenter)
        self._status_label.setStyleSheet("color: #c62828;")
        self._username_input.textChanged.connect(self._clear_status)
        self._password_input.textChanged.connect(self._clear_status)

        self._build_layout()

    def _build_layout(self) -> None:
        layout = QVBoxLayout(self)
        layout.setContentsMargins(32, 28, 32, 24)
        layout.setSpacing(18)
        layout.addWidget(QLabel("<h3>Mi Refugio</h3>", alignment=Qt.AlignCenter))

        form_layout = QFormLayout()
        form_layout.setLabelAlignment(Qt.AlignRight)
        form_layout.setHorizontalSpacing(14)
        form_layout.setVerticalSpacing(12)
        form_layout.addRow("Usuario:", self._username_input)
        form_layout.addRow("Contraseña:", self._password_input)

        form_container = QHBoxLayout()
        form_container.addStretch()         # espacio a la izquierda
        form_container.addLayout(form_layout)
        form_container.addStretch()         # espacio a la derecha

        layout.addLayout(form_container)
        layout.addWidget(self._status_label)


        buttons_layout = QHBoxLayout()
        login_button = QPushButton("Iniciar sesión")
        login_button.setDefault(True)
        login_button.clicked.connect(self._handle_login)
        buttons_layout.addStretch()
        buttons_layout.addWidget(login_button)
        buttons_layout.addStretch()
        layout.addLayout(buttons_layout)


    def showEvent(self, event: QShowEvent) -> None:
        super().showEvent(event)
        self._username_input.setFocus(Qt.OtherFocusReason)
        self._clear_status()

    # ------------------------------------------------------------------ #
    # Event handlers
    # ------------------------------------------------------------------ #
    def _handle_login(self) -> None:
        username = self._username_input.text().strip()
        password = self._password_input.text().strip()

        if not username or not password:
            self._status_label.setText("Ingrese usuario y contraseña.")
            return

        result = self._auth_service.authenticate(username, password)
        if not result.success or not result.user:
            self._status_label.setText(result.message or "Credenciales inválidas.")
            return

        self.user = result.user
        self.accept()

    def _clear_status(self) -> None:
        self._status_label.clear()
