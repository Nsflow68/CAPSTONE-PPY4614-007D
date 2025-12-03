# Guía de Instalación en Windows 🪟

Esta guía detalla paso a paso cómo configurar el entorno de desarrollo para **Mi Refugio App** en Windows.

## 1. Prerrequisitos

### Git
1.  Descargar e instalar [Git for Windows](https://git-scm.com/download/win).
2.  Durante la instalación, seleccionar "Use Git from the Windows Command Prompt".

### Flutter SDK
1.  Descargar [Flutter SDK](https://docs.flutter.dev/get-started/install/windows).
2.  Descomprimir en `C:\src\flutter` (evitar `Program Files`).
3.  Agregar `C:\src\flutter\bin` al **PATH** de Windows.
4.  Ejecutar en PowerShell: `flutter doctor`.

### Android Studio
1.  Descargar e instalar [Android Studio](https://developer.android.com/studio).
2.  Instalar **Android SDK Command-line Tools** desde el SDK Manager.
3.  Crear un dispositivo virtual (AVD) desde el Device Manager.

### Node.js (Backend)
1.  Descargar e instalar [Node.js (LTS)](https://nodejs.org/).
2.  Verificar instalación: `node -v` y `npm -v`.

---

## 2. Configuración del Proyecto

### Clonar Repositorio
Abrir PowerShell y ejecutar:
```powershell
git clone https://github.com/Nsflow68/CAPSTONE-PPY4614-007D.git
cd "CAPSTONE-PPY4614-007D/FASE 2/Evidencias del proyecto/Mi refugio APP"
```

> **IMPORTANTE**: Trabajar SIEMPRE dentro de la carpeta `Mi refugio APP`. No modificar carpetas hermanas como `Web` o `Desk`.

### Backend (NestJS)
1.  Entrar a la carpeta:
    ```powershell
    cd backend_real
    ```
2.  Instalar dependencias:
    ```powershell
    npm install
    ```
3.  Crear archivo `.env` (copiar de `.env.example` si existe) con:
    ```env
    PORT=3001
    DB_HOST=localhost
    DB_PORT=5432
    DB_USER=postgres
    DB_PASSWORD=password
    DB_NAME=mirefugio
    JWT_SECRET=secreto_super_seguro
    ```
4.  Iniciar servidor:
    ```powershell
    npm run start:dev
    ```

### Frontend (Flutter)
1.  Abrir una **nueva terminal** y entrar a la carpeta:
    ```powershell
    cd flutter
    ```
2.  Instalar dependencias:
    ```powershell
    flutter pub get
    ```
3.  Configurar API URL en `lib/core/config/app_config.dart` (si es necesario):
    - Para emulador Android: `http://10.0.2.2:3001/api/`
4.  Ejecutar App:
    ```powershell
    flutter run
    ```

---

## 3. Solución de Problemas Comunes

- **Puerto Ocupado**: Si el puerto 3001 está en uso, cambiarlo en `.env` y en `app_config.dart`.
- **Emulador no detectado**: Ejecutar `flutter devices` para verificar conexión.
- **Errores de Permisos**: Ejecutar PowerShell como Administrador si hay problemas de escritura.
