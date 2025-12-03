# Guía de Contribución 🤝

Gracias por tu interés en contribuir a **Mi Refugio App**. Sigue estas normas para mantener el proyecto ordenado y seguro.

## 1. Flujo de Trabajo en Git

### Ramas
- **Rama Principal**: `main` (o la rama actual de desarrollo).
- **Feature Branches**: Crea ramas para nuevas funcionalidades:
    ```powershell
    git checkout -b feature/nueva-funcionalidad
    ```

### Commits
- Usa mensajes claros y descriptivos en español o inglés.
- Formato recomendado (Conventional Commits):
    - `feat: agregar login con google`
    - `fix: corregir error en validación de rut`
    - `docs: actualizar readme`
    - `chore: limpieza de archivos`
    - `refactor: mejorar estructura de carpetas`

### Git Status (¡CRÍTICO!)
Antes de cada commit, ejecuta SIEMPRE:
```powershell
git status
```
Verifica que solo estás subiendo los archivos que modificaste intencionalmente.

---

## 2. Estándares de Código

- **Flutter**: Seguir las reglas de `flutter_lints`.
- **Formato**: Ejecutar `dart format .` antes de subir cambios.
- **Análisis**: Ejecutar `flutter analyze` y corregir cualquier error (rojo) o advertencia (azul/amarillo) antes de hacer push.

---

## 3. Pull Requests

1.  Sube tu rama al repositorio remoto:
    ```powershell
    git push origin feature/nueva-funcionalidad
    ```
2.  Abre un Pull Request en GitHub apuntando a la rama `main`.
3.  Describe tus cambios y adjunta capturas de pantalla si es un cambio visual.
