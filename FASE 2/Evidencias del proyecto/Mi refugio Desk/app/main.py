from __future__ import annotations

import sys
from pathlib import Path

from PyQt5.QtWidgets import QApplication, QDialog, QMessageBox

from app.services.auth_service import AuthService
from app.ui.login_dialog import LoginDialog
from app.ui.main_window import MainWindow


def run() -> int:
    """Inicializa la aplicación PyQt5."""
    app = QApplication(sys.argv)
    _apply_theme(app)
    auth_service = AuthService()
    login_dialog = LoginDialog(auth_service)

    if login_dialog.exec_() != QDialog.Accepted or not login_dialog.user:
        return 0

    window = MainWindow(current_user=login_dialog.user)
    window.logout_requested.connect(lambda: _handle_logout(window, auth_service))
    window.show()
    return app.exec_()


def main() -> None:
    sys.exit(run())


def _apply_theme(app: QApplication) -> None:
    """Carga el QSS principal si está disponible."""
    theme_path = Path(__file__).resolve().parent.parent / "styles" / "main_theme.qss"
    if not theme_path.exists():
        return
    try:
        with theme_path.open(encoding="utf-8") as file:
            app.setStyleSheet(file.read())
    except OSError:
        # Evitamos que un fallo en el estilo impida iniciar la app.
        pass


def _handle_logout(window: MainWindow, auth_service: AuthService) -> None:
    """Maneja el flujo de cierre y reapertura de sesión."""
    response = QMessageBox.question(
        window,
        "Confirmar cierre de sesión",
        "¿Deseas cerrar la sesión actual?",
        QMessageBox.Yes | QMessageBox.No,
        QMessageBox.No,
    )
    if response != QMessageBox.Yes:
        return
    window.hide()
    login_dialog = LoginDialog(auth_service, parent=window)
    if login_dialog.exec_() == QDialog.Accepted and login_dialog.user:
        window.set_current_user(login_dialog.user)
        window.show()
        window.activateWindow()
        return
    QApplication.instance().quit()
