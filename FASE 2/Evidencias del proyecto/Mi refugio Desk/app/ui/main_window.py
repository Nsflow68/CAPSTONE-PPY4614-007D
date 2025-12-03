from __future__ import annotations

from typing import Optional

from PyQt5.QtCore import Qt, pyqtSignal
from PyQt5.QtWidgets import (
    QHBoxLayout,
    QLabel,
    QMainWindow,
    QFrame,
    QPushButton,
    QStackedWidget,
    QVBoxLayout,
    QWidget,
)

from app.models.user import UserRecord
from app.ui.views.donations_view import DonationsView
from app.ui.views.insights_view import InsightsView
from app.ui.views.notifications_view import NotificationsView
from app.ui.views.reports_view import ReportsView
from app.ui.views.user_management_view import UserManagementView

SIDEBAR_BUTTON_STYLE = """
    QPushButton {
        background-color: transparent;
        border: none;
        font-size: 15px;
        text-align: left;
        padding: 14px 24px;
        color: white;
        border-radius: 8px;
    }
    QPushButton:hover {
        background-color: rgba(255, 255, 255, 0.12);
    }
    QPushButton:checked {
        background-color: rgba(0, 0, 0, 0.18);
        font-weight: 600;
    }
"""


class MainWindow(QMainWindow):
    logout_requested = pyqtSignal()

    def __init__(self, current_user: Optional[UserRecord] = None) -> None:
        super().__init__()
        self._current_user = current_user
        self._buttons: list[QPushButton] = []
        self._stack = QStackedWidget()
        self._welcome_label = QLabel()
        self._role_display: Optional[QLabel] = None
        self._user_management_view: Optional[UserManagementView] = None

        self._configure_window()
        self._build_layout()
        self._populate_stack()
        self._connect_signals()
        self._select_button(self._buttons[0])
        self._update_welcome_label()
        self._update_role_label()

    def _configure_window(self) -> None:
        self.setWindowTitle("Mi Refugio - Panel Administrativo")
        self.setGeometry(100, 100, 1200, 800)

    def _build_layout(self) -> None:
        container = QWidget()
        container.setObjectName("MainContainer")
        outer_layout = QHBoxLayout(container)
        outer_layout.setContentsMargins(0, 0, 0, 0)

        sidebar = self._build_sidebar()
        outer_layout.addWidget(sidebar)
        outer_layout.addWidget(self._stack)

        self.setCentralWidget(container)

    def _build_sidebar(self) -> QWidget:
        sidebar_widget = QWidget()
        sidebar_widget.setObjectName("SidebarWidget")
        sidebar_widget.setFixedWidth(320)

        sidebar_layout = QVBoxLayout(sidebar_widget)
        sidebar_layout.setContentsMargins(0, 24, 0, 24)
        sidebar_layout.setSpacing(10)

        self._welcome_label.setStyleSheet(
            "color: white; font-size: 18px; font-weight: bold; padding: 0 20px 5px 20px;"
        )
        sidebar_layout.addWidget(self._welcome_label)
        sidebar_layout.addWidget(self._build_divider())
        divider_bottom = self._build_divider()
        divider_bottom.setStyleSheet("color: rgba(255, 255, 255, 0.15); margin: 0 20px;")
        sidebar_layout.addWidget(divider_bottom)

        button_texts = (
            "Gestión de Usuarios",
            "Insights y Estadísticas",
            "Donaciones",
            "Mantenimiento",
            "Exportación de Datos",
        )
        for text in button_texts:
            button = QPushButton(text)
            button.setCheckable(True)
            button.setStyleSheet(SIDEBAR_BUTTON_STYLE)
            sidebar_layout.addWidget(button)
            self._buttons.append(button)

        sidebar_layout.addStretch()
        divider_top = self._build_divider()
        divider_top.setStyleSheet("color: rgba(255, 255, 255, 0.25); margin: 0 20px;")
        sidebar_layout.addWidget(divider_top)
        sidebar_layout.addWidget(self._build_logout_button(), alignment=Qt.AlignBottom)
        return sidebar_widget

    def _populate_stack(self) -> None:
        self._user_management_view = UserManagementView(current_user=self._current_user)
        self._stack.addWidget(self._user_management_view)
        self._stack.addWidget(InsightsView())
        self._stack.addWidget(DonationsView())
        self._stack.addWidget(NotificationsView())
        self._stack.addWidget(ReportsView())

    def _connect_signals(self) -> None:
        for index, button in enumerate(self._buttons):
            button.clicked.connect(lambda checked, idx=index: self._on_menu_selected(idx))

    def _on_menu_selected(self, index: int) -> None:
        self._stack.setCurrentIndex(index)
        self._select_button(self._buttons[index])

    def _select_button(self, selected: QPushButton) -> None:
        for btn in self._buttons:
            btn.setChecked(btn is selected)

    def set_current_user(self, user: Optional[UserRecord]) -> None:
        self._current_user = user
        self._update_welcome_label()
        self._update_role_label()
        if self._user_management_view:
            self._user_management_view.set_current_user(user)

    def _update_welcome_label(self) -> None:
        if self._current_user:
            display_name = self._current_user.full_name or self._current_user.username
            self._welcome_label.setText(f"Hola, {display_name}")
        else:
            self._welcome_label.setText("Mi Refugio")

    def _build_divider(self) -> QWidget:
        line = QFrame()
        line.setObjectName("SidebarDivider")
        line.setFrameShape(QFrame.HLine)
        line.setFrameShadow(QFrame.Sunken)
        return line

    def _build_logout_button(self) -> QPushButton:
        button = QPushButton("Cerrar sesión")
        button.setObjectName("SidebarLogoutButton")
        button.setCursor(Qt.PointingHandCursor)
        button.setToolTip("Cerrar la sesión actual")
        button.clicked.connect(self.logout_requested.emit)
        return button

    def _update_role_label(self) -> None:
        if not self._role_display:
            return
        if not self._current_user:
            self._role_display.setText("Invitado")
            return

        raw_role = getattr(self._current_user, "role", "") or "Usuario"
        if raw_role.lower() == "admin":
            role_text = "Administrador"
        else:
            role_text = raw_role.replace("_", " ").title()
        self._role_display.setText(role_text)
