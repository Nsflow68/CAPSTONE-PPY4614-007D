# Mi Refugio – App Flutter

Aplicación móvil de bienestar emocional para el proyecto CAPSTONE‑PPY4614‑007D. Implementa autenticación, diario emocional, mindfulness, seguimiento de hidratación, recursos oficiales y el chatbot **Refu** basado en modelos Llama.

## Características clave

- **Arquitectura modular:** `lib/` organizado por features (`auth`, `chatbot`, `diary`, `home`, `wellness`, etc.) usando Riverpod para el estado y GoRouter para la navegación.
- **Material 3 + theming dual:** soporte para tema claro/oscuro, tipografías personalizadas y componentes adaptativos.
- **Integración backend:** cliente `ApiService` centralizado para consumir FastAPI o NestJS (via feature flag `USE_NEST_BACKEND`).
- **Chatbot Refu:** UI dedicada con indicadores de calma, prompts rápidos y fallback mock cuando el backend no responde.
- **Recompensas persistentes:** balance e insignias almacenadas en `FlutterSecureStorage` y expuestas en Perfil.

## Requisitos

- Flutter 3.24+
- Dart 3.5+
- Android Studio o VS Code + extensiones Flutter
- Backend activo (`API_BASE_URL` → FastAPI, `NEST_API_BASE_URL` → NestJS)
- Servicio Ollama con el modelo `llama3.2:3b-instruct-q4_K_M` descargado

## Configuración rápida

```bash
cd "FASE 2/Evidencias del proyecto/App/flutter"
flutter pub get
flutter run \
  --dart-define=API_BASE_URL=http://10.0.2.2:8000 \
  --dart-define=CHATBOT_BASE_URL=http://10.0.2.2:8000

# Para probar con el backend NestJS:
flutter run \
  --dart-define=USE_NEST_BACKEND=true \
  --dart-define=NEST_API_BASE_URL=http://10.0.2.2:4000/api
```

## Estructura principal

```
flutter/
├─ assets/                 # Imágenes, audios y videos
├─ lib/
│  ├─ core/                # Config, routing, servicios compartidos
│  ├─ features/            # auth, chatbot, diary, home, wellness, etc.
│  └─ shared/              # Widgets, constants y helpers
├─ backend/                # FastAPI (legacy) + NestJS (nuevo stack)
├─ docs/                   # Implementación, prompts, setup de IA
└─ scripts/                # Herramientas de auditoría/automatización
```

## Backend y migración a NestJS

1. Se consume FastAPI (`backend/app`) como fuente principal.
2. NestJS (`backend/nest`) replica módulos con Prisma/PostgreSQL. Usa `npm run start:dev` para levantarlo.
3. El feature flag `USE_NEST_BACKEND` permite cambiar de API sin recompilar.
4. El progreso de la migración se documenta en `backend/MODERNIZATION_PROGRESS.md`.

## Chatbot Refu

- **Modelo actual:** `llama3.2:3b-instruct-q4_K_M` con Ollama.
- **Endpoints activos:** `POST /chatbot/message`, `GET /chatbot/health` (FastAPI).
- **Fallback:** si el servicio falla la app genera respuestas empáticas y prácticas sugeridas.
- **Pendientes:** streaming desde NestJS y persistencia de conversaciones.

## Scripts útiles

- `START_APP.bat`: inicia la app con variables por defecto en Windows.
- `scripts/report_*.py`: generan reportes de auditoría.
- `scripts/fix_encoding.py`: normaliza archivos antes de subirlos a GitHub.

## Buenas prácticas

1. Ejecuta `flutter analyze` y `flutter test` antes de subir cambios.
2. Mantén las cadenas en español utilizando `Intl.message` y actualiza `l10n/` cuando corresponda.
3. Si modificas el chatbot o prompts, documenta los cambios en `docs/CHATBOT_IMPLEMENTATION_SUMMARY.md`.
4. Actualiza este README y los de backend cuando cierres hitos relevantes.

---

**Contacto y soporte:** consulta `docs/IMPLEMENTATION_SUMMARY.md` para conocer responsables, métricas y el estado detallado de cada feature.
