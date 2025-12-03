# CAPSTONE-PPY4614-007D - Portafolio de Título

Repositorio del proyecto de título del Grupo 6, Sección 007D, Sede Puente Alto.

**Proyecto Principal**: **Mi Refugio** - Aplicación móvil de bienestar emocional para estudiantes universitarios.

---

## Descripción del Proyecto

Mi Refugio es una aplicación móvil desarrollada en Flutter que proporciona herramientas de autocuidado y bienestar emocional, incluyendo:

- Diario emocional con seguimiento de estados de ánimo
- Módulos de bienestar (hidratación, nutrición, mindfulness)
- Sistema de recompensas gamificado
- Chatbot de apoyo emocional con IA
- Recursos de salud mental profesional

### Tecnologías Principales

- **Frontend**: Flutter 3.24+ (Dart)
- **Backend**: NestJS 10+ (TypeScript)
- **Base de Datos**: PostgreSQL (AWS RDS)
- **State Management**: Riverpod 2.0
- **IA**: Ollama (Llama 3.2)

---

## Estructura del Repositorio

```
CAPSTONE-PPY4614-007D/
│
├── FASE 1/                              # Primera fase del proyecto
│   ├── Evidencia Grupal/
│   ├── Evidencia Personal/
│   └── Presentación 1-Capstone.pptx
│
├── FASE 2/                              # Fase de desarrollo principal
│   ├── Evidencias Grupales/
│   ├── Evidencias Individuales/
│   └── Evidencias del proyecto/
│       └── Mi refugio APP/              ← PROYECTO PRINCIPAL
│           ├── flutter/                 # Aplicación móvil Flutter
│           ├── backend_real/            # Backend NestJS (ACTIVO)
│           ├── docs/                    # Documentación técnica
│           ├── README.md                # Guía del proyecto Mi Refugio
│           ├── INSTALL_WINDOWS.md       # Instalación en Windows
│           ├── CONTRIBUTING.md          # Guía para contribuidores
│           └── GUIA_USUARIO.md          # Guía de usuario
│
├── FASE 3/                              # Documentación final
│   ├── Documentacion Asignatura/
│   └── Documentacion del proyecto/
│
└── README.md                            # Este archivo
```

---

## Inicio Rápido

### Ubicación del Proyecto Principal

El código fuente de **Mi Refugio App** se encuentra en:

```
FASE 2/Evidencias del proyecto/Mi refugio APP/
```

### Requisitos Previos

- Flutter SDK 3.24 o superior
- Node.js 20 o superior
- Android Studio (para emulador)
- Git

### Instalación Rápida

```powershell
# 1. Clonar el repositorio
git clone https://github.com/tu-usuario/CAPSTONE-PPY4614-007D.git
cd CAPSTONE-PPY4614-007D

# 2. Navegar al proyecto principal
cd "FASE 2\Evidencias del proyecto\Mi refugio APP"

# 3. Backend NestJS
cd backend_real
npm install
# Configurar archivo .env (ver INSTALL_WINDOWS.md)
npm run start:dev

# 4. App Flutter (en otra terminal)
cd ..\flutter
flutter pub get
adb reverse tcp:3001 tcp:3001
flutter run
```

### Guía Completa de Instalación

Para instrucciones detalladas paso a paso en Windows, consultar:

**[FASE 2/Evidencias del proyecto/Mi refugio APP/INSTALL_WINDOWS.md](FASE%202/Evidencias%20del%20proyecto/Mi%20refugio%20APP/INSTALL_WINDOWS.md)**

---

## Documentación

### Documentación del Proyecto Mi Refugio

Toda la documentación específica de Mi Refugio App se encuentra en:

```
FASE 2/Evidencias del proyecto/Mi refugio APP/
```

**Documentos principales:**

- **[README.md](FASE%202/Evidencias%20del%20proyecto/Mi%20refugio%20APP/README.md)** - Descripción general del proyecto
- **[INSTALL_WINDOWS.md](FASE%202/Evidencias%20del%20proyecto/Mi%20refugio%20APP/INSTALL_WINDOWS.md)** - Guía de instalación para Windows
- **[CONTRIBUTING.md](FASE%202/Evidencias%20del%20proyecto/Mi%20refugio%20APP/CONTRIBUTING.md)** - Guía para contribuidores
- **[GUIA_USUARIO.md](FASE%202/Evidencias%20del%20proyecto/Mi%20refugio%20APP/GUIA_USUARIO.md)** - Manual de usuario
- **[docs/ARQUITECTURA.md](FASE%202/Evidencias%20del%20proyecto/Mi%20refugio%20APP/docs/ARQUITECTURA.md)** - Documentación técnica de arquitectura
- **[docs/API.md](FASE%202/Evidencias%20del%20proyecto/Mi%20refugio%20APP/docs/API.md)** - Documentación de API

### Documentación por Fases

#### FASE 1
Contiene evidencias iniciales del proyecto, presentaciones y documentación de la primera etapa.

#### FASE 2
Fase de desarrollo principal. Incluye:
- Evidencias grupales e individuales
- Código fuente completo de Mi Refugio App
- Documentación técnica
- Guías de instalación y contribución

#### FASE 3
Documentación final del proyecto y de la asignatura.

---

## Arquitectura del Sistema

```
┌─────────────────┐
│   Flutter App   │  (Móvil Android/iOS)
│   (Dart)        │
└────────┬────────┘
         │ HTTP/REST
         ▼
┌─────────────────┐
│  Backend NestJS │  (API REST)
│  (TypeScript)   │
└────────┬────────┘
         │
         ├─────────► PostgreSQL (AWS RDS)
         │
         └─────────► Ollama (LLM)
```

### Componentes Principales

**Frontend (Flutter)**
- Aplicación móvil multiplataforma
- State management con Riverpod
- Navegación con GoRouter
- Arquitectura limpia por features

**Backend (NestJS)**
- API REST con TypeScript
- ORM con TypeORM
- Autenticación y autorización
- Integración con LLM para chatbot

**Base de Datos**
- PostgreSQL en AWS RDS
- Schema: `app`
- Tablas: users, diary_entries, wellness_logs, etc.

---

## Funcionalidades Implementadas

### Autenticación
- ✅ Registro de usuarios con validación de RUT
- ✅ Login con credenciales
- ✅ Login con Google
- ✅ Gestión de sesiones

### Bienestar Emocional
- ✅ Diario emocional con registro diario
- ✅ Seguimiento de hidratación
- ✅ Registro de nutrición
- ✅ Ejercicios de mindfulness con audios

### Gamificación
- ✅ Sistema de puntos
- ✅ Mascotas virtuales desbloqueables
- ✅ Logros y recompensas

### Recursos
- ✅ Directorio de servicios de salud mental
- ✅ Información de contacto de emergencia
- ✅ Recursos educativos

### Chatbot
- ✅ Asistente virtual con IA (Llama 3.2)
- ✅ Respuestas contextuales
- ✅ Sugerencias de prácticas de bienestar

---

## Flujo de Trabajo para Contribuidores

### 1. Configurar Entorno

Seguir la guía completa en:
**[INSTALL_WINDOWS.md](FASE%202/Evidencias%20del%20proyecto/Mi%20refugio%20APP/INSTALL_WINDOWS.md)**

### 2. Crear Rama de Trabajo

```powershell
git checkout main
git pull origin main
git checkout -b feature/nombre-descriptivo
```

### 3. Hacer Cambios

Solo modificar archivos en:
- `FASE 2/Evidencias del proyecto/Mi refugio APP/flutter/`
- `FASE 2/Evidencias del proyecto/Mi refugio APP/backend_real/`
- `FASE 2/Evidencias del proyecto/Mi refugio APP/docs/`

### 4. Verificar Calidad

```powershell
# Flutter
flutter analyze
flutter test

# Backend
npm run lint
npm run build
```

### 5. Commit y Push

```powershell
git add <archivos>
git commit -m "tipo: descripción"
git push origin feature/nombre-descriptivo
```

### 6. Crear Pull Request

Crear PR en GitHub para revisión.

**Guía completa**: [CONTRIBUTING.md](FASE%202/Evidencias%20del%20proyecto/Mi%20refugio%20APP/CONTRIBUTING.md)

---

## Convenciones de Commits

Formato: `<tipo>: <descripción>`

**Tipos:**
- `feat`: Nueva funcionalidad
- `fix`: Corrección de bug
- `docs`: Cambios en documentación
- `style`: Formato de código
- `refactor`: Refactorización
- `test`: Tests
- `chore`: Mantenimiento

**Ejemplos:**
```
feat: agregar sistema de notificaciones
fix: resolver error en registro de usuarios
docs: actualizar guía de instalación
```

---

## Estado del Proyecto

### Última Actualización: Diciembre 2025

**Versión**: 1.0.0

**Estado**: En desarrollo activo

### Hitos Completados

- ✅ Arquitectura base de Flutter con Riverpod
- ✅ Backend NestJS con PostgreSQL
- ✅ Autenticación completa
- ✅ Módulos de bienestar implementados
- ✅ Sistema de recompensas funcional
- ✅ Integración con LLM para chatbot
- ✅ Documentación completa

### Próximos Pasos

- 🔄 Optimización de rendimiento
- 🔄 Tests end-to-end
- 🔄 Despliegue a producción
- 🔄 Análisis de patrones emocionales con IA

---

## Equipo

**Grupo 6 - Sección 007D**
Sede Puente Alto

### Contacto

Para consultas sobre el proyecto:
- Email: contacto@mirefugio.cl
- Issues: [GitHub Issues](https://github.com/tu-usuario/CAPSTONE-PPY4614-007D/issues)

---

## Licencia

Este proyecto es parte de un trabajo de titulación académica.

Todos los derechos reservados © 2025

---

## Enlaces Rápidos

- [Proyecto Mi Refugio App](FASE%202/Evidencias%20del%20proyecto/Mi%20refugio%20APP/)
- [Guía de Instalación Windows](FASE%202/Evidencias%20del%20proyecto/Mi%20refugio%20APP/INSTALL_WINDOWS.md)
- [Guía para Contribuidores](FASE%202/Evidencias%20del%20proyecto/Mi%20refugio%20APP/CONTRIBUTING.md)
- [Documentación de Arquitectura](FASE%202/Evidencias%20del%20proyecto/Mi%20refugio%20APP/docs/ARQUITECTURA.md)
- [Guía de Usuario](FASE%202/Evidencias%20del%20proyecto/Mi%20refugio%20APP/GUIA_USUARIO.md)

---

**Nota**: Este README proporciona una visión general del repositorio completo. Para información específica sobre Mi Refugio App, consultar la documentación en `FASE 2/Evidencias del proyecto/Mi refugio APP/`.
