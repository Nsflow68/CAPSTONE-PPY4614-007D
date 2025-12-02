# Mi Refugio - App Móvil de Bienestar Emocional

Mi Refugio es una aplicación móvil diseñada para apoyar el bienestar emocional de estudiantes universitarios, proporcionando herramientas para el autocuidado, seguimiento emocional, y acceso a recursos de salud mental.

## Descripción

Mi Refugio combina funcionalidades de diario emocional, seguimiento de bienestar (hidratación, nutrición, mindfulness), sistema de recompensas gamificado, y acceso a recursos de salud mental, todo en una interfaz amigable y accesible.

### Características Principales

- **Autenticación**: Registro y login con credenciales o Google
- **Diario Emocional**: Registro diario de estados emocionales con análisis de patrones
- **Bienestar**:
  - Seguimiento de hidratación con recordatorios
  - Registro de nutrición con base de datos de alimentos
  - Ejercicios de mindfulness con audios guiados
- **Sistema de Recompensas**: Mascotas virtuales desbloqueables por puntos
- **Recursos de Salud Mental**: Directorio de servicios de apoyo profesional
- **Chatbot**: Asistente virtual para orientación y apoyo emocional

## Arquitectura

```
┌─────────────────┐
│   Flutter App   │  (Móvil Android/iOS)
│   (Dart/Riverpod)│
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
         └─────────► Ollama (LLM - Opcional)
```

### Tecnologías

**Frontend (Flutter)**
- Flutter 3.24+
- Riverpod 2.0 (State Management)
- GoRouter (Navegación)
- HTTP (API Client)

**Backend (NestJS)**
- NestJS 10+
- TypeORM (ORM)
- PostgreSQL (Base de Datos)
- Passport (Autenticación)

**Infraestructura**
- PostgreSQL en AWS RDS
- Ollama para LLM (opcional)

## Inicio Rápido

### Requisitos Previos

- Flutter SDK 3.24+
- Node.js 20+
- Android Studio (para emulador)
- Git

**Guía completa**: Ver [INSTALL_WINDOWS.md](INSTALL_WINDOWS.md)

### Instalación

```powershell
# Clonar repositorio
git clone https://github.com/tu-usuario/CAPSTONE-PPY4614-007D.git
cd CAPSTONE-PPY4614-007D
cd "FASE 2\Evidencias del proyecto\Mi refugio APP"

# Backend
cd backend_real
npm install
# Configurar .env (ver INSTALL_WINDOWS.md)
npm run start:dev

# Flutter (en otra terminal)
cd ../flutter
flutter pub get
adb reverse tcp:3001 tcp:3001
flutter run
```

### Verificación

1. Backend: http://localhost:3001/api/health
2. App: Debe mostrar pantalla de onboarding en emulador

## Estructura del Proyecto

```
Mi refugio APP/
├── flutter/                # App móvil Flutter
│   ├── lib/
│   │   ├── core/          # Configuración, servicios, theme
│   │   ├── features/      # Módulos por funcionalidad
│   │   └── shared/        # Código compartido
│   └── assets/            # Recursos (imágenes, audios)
│
├── backend_real/          # Backend NestJS
│   ├── src/
│   │   ├── modules/      # Módulos de negocio
│   │   └── config/       # Configuración
│   └── test/
│
├── docs/                  # Documentación técnica
│   ├── ARQUITECTURA.md
│   └── API.md
│
├── README.md              # Este archivo
├── INSTALL_WINDOWS.md     # Guía de instalación
└── CONTRIBUTING.md        # Guía para contribuidores
```

## Documentación

- [Guía de Instalación (Windows)](INSTALL_WINDOWS.md)
- [Guía de Contribución](CONTRIBUTING.md)
- [Arquitectura del Sistema](docs/ARQUITECTURA.md)
- [Documentación de API](docs/API.md)
- [Guía de Usuario](GUIA_USUARIO.md)

## Desarrollo

### Ejecutar en Modo Desarrollo

**Backend:**
```powershell
cd backend_real
npm run start:dev
```

**Flutter:**
```powershell
cd flutter
flutter run
```

### Análisis de Código

**Flutter:**
```powershell
flutter analyze
dart format lib/
```

**Backend:**
```powershell
npm run lint
npm run build
```

### Tests

**Flutter:**
```powershell
flutter test
```

**Backend:**
```powershell
npm test
```

## Flujo de Trabajo Git

1. Crear rama desde main: `git checkout -b feature/nombre`
2. Hacer cambios y commits: `git commit -m "feat: descripción"`
3. Subir rama: `git push origin feature/nombre`
4. Crear Pull Request en GitHub
5. Revisar y mergear

**Ver**: [CONTRIBUTING.md](CONTRIBUTING.md) para detalles completos

## Estado del Proyecto

### Funcionalidades Implementadas

- ✅ Autenticación (Credenciales + Google)
- ✅ Diario Emocional
- ✅ Seguimiento de Hidratación
- ✅ Registro de Nutrición
- ✅ Ejercicios de Mindfulness
- ✅ Sistema de Recompensas
- ✅ Recursos de Salud Mental
- ✅ Chatbot con LLM

### En Desarrollo

- 🔄 Análisis de patrones emocionales
- 🔄 Notificaciones push
- 🔄 Sincronización multi-dispositivo

## Problemas Conocidos

Ver [Issues en GitHub](https://github.com/tu-usuario/CAPSTONE-PPY4614-007D/issues)

## Contribuir

Las contribuciones son bienvenidas. Por favor lee [CONTRIBUTING.md](CONTRIBUTING.md) antes de enviar un Pull Request.

### Proceso

1. Fork del repositorio
2. Crear rama de trabajo
3. Hacer cambios
4. Ejecutar tests y análisis
5. Crear Pull Request

## Licencia

Este proyecto es parte de un trabajo de titulación académica.

## Contacto

Para preguntas o soporte:
- Email: contacto@mirefugio.cl
- Issues: GitHub Issues

---

**Última actualización**: Diciembre 2025
**Versión**: 1.0.0
