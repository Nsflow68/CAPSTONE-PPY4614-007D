# Mi Refugio – App Flutter

Aplicación móvil de bienestar emocional para el proyecto CAPSTONE‑PPY4614‑007D. Implementa autenticación, diario emocional, mindfulness, seguimiento de hidratación, recursos oficiales y el chatbot **Refu** basado en modelos Llama.

## Características clave

- **Arquitectura modular:** `lib/` organizado por features (`auth`, `chatbot`, `diary`, `home`, `wellness`, etc.) usando Riverpod para el estado y GoRouter para la navegación.
- **Material 3 + theming dual:** soporte para tema claro/oscuro, tipografías personalizadas y componentes adaptativos.
- **Integración backend:** cliente `ApiClient` centralizado para consumir la API (actualmente FastAPI, en transición a NestJS).
- **Chatbot Refu:** UI dedicada que consume un endpoint propio apoyado por Ollama + modelos Llama.
- **Automatización:** scripts de auditoría (`audit/`), guías de integración y documentación de pruebas.

## Requisitos

- Flutter 3.24+
- Dart 3.5+
- Android Studio o VS Code + extensiones Flutter
- Backend activo (`FAST_API_BASE_URL` o `NEST_API_BASE_URL`)
- Servicio Ollama con el modelo `llama3.2:3b-instruct-q4_K_M` descargado

## Configuración rápida

```bash
cd "FASE 2/Evidencias del proyecto/App/flutter"
flutter pub get
flutter run \
  --dart-define=API_BASE_URL=http://10.0.2.2:8000 \
  --dart-define=CHATBOT_BASE_URL=http://10.0.2.2:8000
```

Cuando el backend NestJS esté listo, solo cambia `API_BASE_URL` al gateway correspondiente (`https://api.mi-refugio.dev`).

## Estructura principal

```
flutter/
├── assets/                 # Imágenes, audios y videos de bienestar
├── lib/
│   ├── core/               # Config, routing, services compartidos
│   ├── features/
│   │   ├── auth/           # Login, signup, recuperación
│   │   ├── chatbot/        # Lógica e interfaz de Refu
│   │   ├── diary/          # Diario emocional completo
│   │   ├── home/           # Dashboard principal
│   │   └── wellness/       # Mindfulness, hidratación, recordatorios
│   └── shared/             # Widgets y utilidades reutilizables
├── backend/                # API (FastAPI → NestJS) + documentación del bot
├── scripts/                # Herramientas de análisis/auditoría
├── CHATBOT_IMPLEMENTATION_SUMMARY.md
├── IMPLEMENTATION_SUMMARY.md
└── MODERNIZATION_PROGRESS.md
```

## Backend y migración a NestJS

- **Situación actual:** se consume FastAPI (`backend/app`). Está totalmente funcional y cubre auth, diario, mindfulness, hidratación, recursos y chatbot.
- **Migración planificada (2‑3 semanas):**
  1. Levantar base de NestJS (Módulos: Auth, Users, Wellness, Chatbot) y compartir DTOs vía Swagger.
  2. Portar repositorios y servicios críticos desde SQLAlchemy a Prisma (PostgreSQL) manteniendo compatibilidad con Flutter mediante feature‑flags.
  3. Publicar endpoints equivalentes (`/auth`, `/mindfulness`, `/hydration`, `/chatbot`) y ejecutar pruebas end‑to‑end antes del swap definitivo.
- **Seguimiento:** todos los detalles del backend se documentan en `backend/README.md` y en `MODERNIZATION_PROGRESS.md`.

## Chatbot Refu (modelo Llama)

- **Modelo actual:** `llama3.2:3b-instruct-q4_K_M` servido con Ollama.
- **Endpoints de referencia:**
  - `POST /chatbot/message`
  - `GET /chatbot/health`
- **Fallback local:** si la API no responde, la app utiliza respuestas empáticas predefinidas para no dejar al usuario sin acompañamiento.
- **Próximos pasos:** streaming de respuestas y persistencia de conversaciones una vez que NestJS exponga el microservicio definitivo.

## Scripts útiles

- `START_APP.bat`: inicia la app con variables predefinidas en Windows.
- `scripts/report_*.py`: generan reportes de auditoría y listas de archivos para evidencias.
- `fix_encoding.py`: normaliza archivos con problemas de codificación antes de subirlos a GitHub.

## Buenas prácticas para contribuciones

1. Ejecuta `flutter analyze` y `flutter test` antes de subir cambios.
2. Mantén las cadenas en español en `l10n/` y usa `Intl.message`.
3. Si tocas el chatbot, actualiza también `CHATBOT_IMPLEMENTATION_SUMMARY.md`.
4. Documenta cualquier ajuste mayor en este README y, si aplica, en el README del backend.

---

**Contacto y soporte:** consulta `IMPLEMENTATION_SUMMARY.md` para conocer responsables, métricas y el estado detallado de cada feature. Actualiza este documento cuando completes un hito relevante del frontend.
