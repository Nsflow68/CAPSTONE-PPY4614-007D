# Guía de Instalación - Mi Refugio App (Windows)

Esta guía detalla cómo instalar y ejecutar Mi Refugio App en Windows desde cero.

## Requisitos del Sistema

- Windows 10 o superior (64-bit)
- Mínimo 8 GB RAM (recomendado 16 GB)
- 10 GB de espacio libre en disco
- Conexión a internet

---

## 1. Instalación de Herramientas Base

### 1.1 Git para Windows

**Descarga e Instalación:**
1. Descargar desde: https://git-scm.com/download/win
2. Ejecutar el instalador
3. Configuración recomendada:
   - Editor: Visual Studio Code (o el de tu preferencia)
   - PATH: "Git from the command line and also from 3rd-party software"
   - Line ending: "Checkout Windows-style, commit Unix-style"
   - Terminal: "Use Windows' default console window"

**Verificación:**
```powershell
git --version
# Debe mostrar: git version 2.x.x
```

**Configuración inicial:**
```powershell
git config --global user.name "Tu Nombre"
git config --global user.email "tu.email@example.com"
```

### 1.2 Flutter SDK

**Descarga:**
1. Ir a: https://docs.flutter.dev/get-started/install/windows
2. Descargar Flutter SDK (archivo .zip)
3. Extraer en `C:\src\flutter` (evitar rutas con espacios)

**Configuración del PATH:**
1. Buscar "Variables de entorno" en el menú Inicio
2. Click en "Variables de entorno"
3. En "Variables del sistema", seleccionar "Path" y click "Editar"
4. Click "Nuevo" y agregar: `C:\src\flutter\bin`
5. Click "Aceptar" en todas las ventanas

**Verificación:**
```powershell
flutter --version
# Debe mostrar la versión de Flutter

flutter doctor
# Revisar qué componentes faltan
```

### 1.3 Android Studio

**Instalación:**
1. Descargar desde: https://developer.android.com/studio
2. Ejecutar el instalador
3. Durante la instalación, asegurar que se instalen:
   - Android SDK
   - Android SDK Platform
   - Android Virtual Device

**Configuración del Android SDK:**
1. Abrir Android Studio
2. Ir a: File > Settings > Appearance & Behavior > System Settings > Android SDK
3. En "SDK Platforms", instalar:
   - Android 13.0 (API 33) o superior
4. En "SDK Tools", verificar que estén instalados:
   - Android SDK Build-Tools
   - Android SDK Command-line Tools
   - Android Emulator
   - Android SDK Platform-Tools

**Aceptar licencias:**
```powershell
flutter doctor --android-licenses
# Escribir 'y' para aceptar todas las licencias
```

**Crear Emulador:**
1. En Android Studio: Tools > Device Manager
2. Click "Create Device"
3. Seleccionar un dispositivo (ej: Pixel 5)
4. Seleccionar una imagen del sistema (ej: API 33, x86_64)
5. Click "Finish"

**Verificar emulador:**
```powershell
flutter devices
# Debe listar el emulador creado
```

### 1.4 Node.js y npm

**Instalación:**
1. Descargar LTS desde: https://nodejs.org/
2. Ejecutar el instalador
3. Aceptar configuración por defecto

**Verificación:**
```powershell
node --version
# Debe mostrar: v20.x.x o superior

npm --version
# Debe mostrar: 10.x.x o superior
```

---

## 2. Clonar el Repositorio

```powershell
# Navegar a la carpeta donde quieres el proyecto
cd C:\Users\TuUsuario\Documents

# Clonar el repositorio
git clone https://github.com/tu-usuario/CAPSTONE-PPY4614-007D.git

# Entrar al proyecto
cd CAPSTONE-PPY4614-007D

# Verificar rama actual
git branch
# Debe mostrar: * main

# Navegar a Mi Refugio App
cd "FASE 2\Evidencias del proyecto\Mi refugio APP"
```

---

## 3. Configuración del Backend (NestJS)

### 3.1 Instalar Dependencias

```powershell
cd backend_real
npm install
```

### 3.2 Configurar Variables de Entorno

Crear archivo `.env` en `backend_real/`:

```env
# Base de Datos PostgreSQL (AWS RDS)
DB_HOST=mirefugio.c9ie2ckqg3rt.us-east-2.rds.amazonaws.com
DB_PORT=5432
DB_USER=mirefugio_owner
DB_PASSWORD=Mirefugio2025!
DB_NAME=mirefugio

# Puerto del servidor
PORT=3001

# Ollama (LLM - opcional)
OLLAMA_BASE_URL=http://localhost:11434
OLLAMA_MODEL=llama3.2:3b-instruct-q4_K_M
```

**IMPORTANTE**: Este archivo `.env` NO debe subirse a Git (ya está en `.gitignore`)

### 3.3 Ejecutar el Backend

```powershell
npm run start:dev
```

**Salida esperada:**
```
[Nest] 12345  - 02/12/2025, 20:00:00     LOG [NestFactory] Starting Nest application...
[Nest] 12345  - 02/12/2025, 20:00:01     LOG [InstanceLoader] AppModule dependencies initialized
Application is running on: http://127.0.0.1:3001
```

**Verificar que funciona:**
Abrir navegador en: http://localhost:3001/api/health

Debe mostrar: `{"status":"ok"}`

---

## 4. Configuración de la App Flutter

### 4.1 Instalar Dependencias

```powershell
# Desde la raíz de Mi Refugio APP
cd flutter
flutter pub get
```

### 4.2 Configurar Conectividad con Backend

**Para Emulador Android:**

El archivo `lib/core/config/app_config.dart` ya está configurado para usar `localhost:3001`.

**Configurar Port Forwarding:**
```powershell
adb reverse tcp:3001 tcp:3001
```

Este comando permite que el emulador acceda al backend en tu máquina local.

### 4.3 Ejecutar la App

**Iniciar Emulador:**
```powershell
# Listar emuladores disponibles
flutter emulators

# Iniciar un emulador específico
flutter emulators --launch <emulator-id>

# O desde Android Studio: Tools > Device Manager > Play
```

**Ejecutar la App:**
```powershell
flutter run
```

**Salida esperada:**
```
Launching lib\main.dart on sdk gphone64 x86 64 in debug mode...
Running Gradle task 'assembleDebug'...
✓ Built build\app\outputs\flutter-apk\app-debug.apk.
Installing build\app\outputs\flutter-apk\app.apk...
Syncing files to device sdk gphone64 x86 64...
Flutter run key commands.
r Hot reload.
R Hot restart.
h List all available interactive commands.
d Detach (terminate "flutter run" but leave application running).
c Clear the screen
q Quit (terminate the application on the device).
```

---

## 5. Verificación de la Instalación

### 5.1 Checklist de Verificación

- [ ] Backend corriendo en http://localhost:3001
- [ ] Endpoint de health responde: http://localhost:3001/api/health
- [ ] Emulador Android iniciado
- [ ] `adb reverse` configurado
- [ ] App Flutter instalada en emulador
- [ ] Pantalla de onboarding visible

### 5.2 Prueba de Funcionalidad

1. **Registro de Usuario:**
   - Abrir app en emulador
   - Click en "Crear cuenta"
   - Completar formulario
   - Verificar que se crea el usuario

2. **Login:**
   - Cerrar sesión
   - Iniciar sesión con credenciales creadas
   - Verificar redirección a Home

3. **Funcionalidades Básicas:**
   - Navegar por las diferentes secciones
   - Verificar que carga datos del backend

---

## 6. Problemas Comunes y Soluciones

### 6.1 Flutter Doctor Muestra Errores

**Problema**: `flutter doctor` muestra errores en Android toolchain

**Solución**:
```powershell
flutter doctor --android-licenses
# Aceptar todas las licencias
```

### 6.2 Emulador No Aparece

**Problema**: `flutter devices` no muestra el emulador

**Solución**:
1. Verificar que el emulador está corriendo en Android Studio
2. Reiniciar adb:
```powershell
adb kill-server
adb start-server
flutter devices
```

### 6.3 Backend No Inicia

**Problema**: Error al ejecutar `npm run start:dev`

**Soluciones**:
- Verificar que Node.js está instalado: `node --version`
- Eliminar `node_modules` y reinstalar:
```powershell
Remove-Item -Recurse -Force node_modules
npm install
```
- Verificar que el archivo `.env` existe y tiene las variables correctas

### 6.4 App No Se Conecta al Backend

**Problema**: "El servicio no respondió" en la app

**Soluciones**:
1. Verificar que el backend está corriendo
2. Configurar port forwarding:
```powershell
adb reverse tcp:3001 tcp:3001
```
3. Verificar firewall de Windows:
   - Buscar "Firewall de Windows Defender"
   - Permitir Node.js en redes privadas

### 6.5 Error de Compilación en Flutter

**Problema**: Errores al ejecutar `flutter run`

**Soluciones**:
```powershell
# Limpiar build
flutter clean

# Obtener dependencias nuevamente
flutter pub get

# Intentar de nuevo
flutter run
```

### 6.6 Rutas con Espacios

**Problema**: Errores relacionados con rutas que contienen espacios

**Solución**:
- Usar comillas en PowerShell:
```powershell
cd "FASE 2\Evidencias del proyecto\Mi refugio APP"
```
- O evitar espacios en nombres de carpetas al clonar

---

## 7. Comandos Útiles

### Flutter
```powershell
flutter doctor          # Verificar instalación
flutter devices         # Listar dispositivos
flutter clean           # Limpiar build
flutter pub get         # Instalar dependencias
flutter run             # Ejecutar app
flutter analyze         # Análisis estático
flutter test            # Ejecutar tests
```

### Backend
```powershell
npm install             # Instalar dependencias
npm run start:dev       # Modo desarrollo
npm run build           # Compilar
npm run start:prod      # Modo producción
npm test                # Ejecutar tests
```

### Git
```powershell
git status              # Ver estado
git pull                # Actualizar desde remoto
git add <archivo>       # Añadir cambios
git commit -m "mensaje" # Hacer commit
git push                # Subir cambios
```

### ADB
```powershell
adb devices             # Listar dispositivos
adb reverse tcp:3001 tcp:3001  # Port forwarding
adb kill-server         # Reiniciar adb
adb start-server
```

---

## 8. Próximos Pasos

Después de la instalación exitosa:

1. Leer `CONTRIBUTING.md` para entender el flujo de trabajo
2. Revisar `docs/ARQUITECTURA.md` para entender la estructura del proyecto
3. Explorar el código en `flutter/lib/features/` para ver las funcionalidades
4. Revisar `docs/API.md` para entender los endpoints del backend

---

## Soporte

Si encuentras problemas no cubiertos en esta guía:

1. Revisar logs del backend en la terminal
2. Revisar logs de Flutter en la terminal
3. Ejecutar `flutter doctor -v` para diagnóstico detallado
4. Consultar documentación oficial:
   - Flutter: https://docs.flutter.dev/
   - NestJS: https://docs.nestjs.com/
   - Android Studio: https://developer.android.com/studio/intro

---

**Última actualización**: Diciembre 2025
