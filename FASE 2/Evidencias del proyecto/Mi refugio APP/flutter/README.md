# Mi Refugio - App Flutter

Aplicacion movil de bienestar emocional (CAPSTONE-PPY4614-007D). Incluye autenticacion, diario emocional, mindfulness, hidratacion, recursos oficiales y el chatbot **Refu** con soporte para Ollama.

## Caracteristicas clave
- Arquitectura modular por features (`auth`, `chatbot`, `diary`, `home`, `wellness`, etc.) con Riverpod y GoRouter.
- Theming y branding: AppColors/AppTheme, splash nativo personalizado y launcher icon generado con flutter_launcher_icons.
- Integracion backend: `ApiService` central; cambia entre FastAPI y Nest con el flag `USE_NEST_BACKEND`.
- Auth renovado: login con hero limpio, pantallas de crear cuenta y recuperar contrasena con validaciones locales (logica de estado se mantiene en AuthState/Result/Failure).
- Diario con Result/Failure y vistas Empty/Error dedicadas; la UI consume estados del notifier.
- Chatbot Refu redisenado: prompts rapidos, burbujas claras, banner de error y fallback local si no hay backend.

## Requisitos
- Flutter 3.24+
- Dart 3.5+
- Backend activo (`API_BASE_URL` para FastAPI o `NEST_API_BASE_URL` para NestJS)
- Servicio Ollama con modelo `llama3.2:3b-instruct-q4_K_M` descargado

## Configuracion rapida
```bash
cd "FASE 2/Evidencias del proyecto/App/flutter"
flutter pub get
# FastAPI
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000 --dart-define=CHATBOT_BASE_URL=http://10.0.2.2:8000
# NestJS
flutter run --dart-define=USE_NEST_BACKEND=true --dart-define=NEST_API_BASE_URL=http://10.0.2.2:4000/api
```

## Estructura principal
```
flutter/
├─ assets/                 # Imagenes, audios y videos (branding, mascot, splash)
├─ lib/
│  ├─ core/                # Config, routing, servicios compartidos
│  ├─ features/            # auth, chatbot, diary, home, wellness, etc.
│  └─ shared/              # Widgets, constants y helpers
├─ backend/                # FastAPI (legacy) + NestJS (nuevo stack)
├─ docs/                   # Implementacion, prompts, setup de IA
└─ scripts/                # Herramientas de auditoria/automatizacion
```

## Backend y migracion a NestJS
1. FastAPI (`backend/app`) sigue disponible como fuente principal.
2. NestJS (`backend/nest`) replica modulos con Prisma/PostgreSQL. `npm run start:dev` expone `http://localhost:4000/api`.
3. El flag `USE_NEST_BACKEND` permite cambiar de API sin recompilar.
4. Progreso de migracion documentado en `backend/MODERNIZATION_PROGRESS.md` (si aplica).

## Chatbot Refu
- Modelo actual: `llama3.2:3b-instruct-q4_K_M` via Ollama.
- Endpoints activos: `POST /chatbot/message`, `GET /chatbot/health` (FastAPI/Nest).
- Fallback: si el servicio falla, la app responde de forma empatica local.
- Pendientes: streaming desde NestJS y persistencia de conversaciones.

## Scripts utiles
- `START_APP.bat`: arranque rapido con variables por defecto.
- `scripts/report_*.py`: reportes de auditoria.
- `scripts/fix_encoding.py`: normaliza archivos antes de subir a GitHub.

## Buenas practicas
1. Ejecuta `flutter analyze` y `flutter test` antes de subir cambios.
2. Mantén las cadenas en espanol usando `Intl.message` y actualiza `l10n/` cuando aplique.
3. Documenta cambios en chatbot/prompts en `docs/CHATBOT_IMPLEMENTATION_SUMMARY.md`.
4. Actualiza este README y los de backend al cerrar hitos relevantes.
