# Mi Refugio – Guia de trabajo (Fase 2)

Contexto rapido del repositorio de evidencias. Usa este archivo para arrancar backend y app, y saber que cambios ya estan listos.

## Que hay aqui
- `flutter/` app Flutter principal (Riverpod + GoRouter). Incluye backend FastAPI legacy y NestJS en migracion.
- `GUIA_USUARIO.md` recorrido funcional y plan operativo.
- `backend/` (dentro de `flutter/`) FastAPI (legacy) y `backend/nest/` (NestJS + Prisma).
- `assets` (en Flutter) con branding, mascota, audios y video de splash.

## Cambios mas recientes (app)
- **Auth**: Login con panel hero limpio y CTA a la guia, nuevas pantallas de Crear cuenta y Recuperar contrasena (formularios validados, SnackBar informativo). Se mantiene la logica de estado AuthState/Result/Failure.
- **Diary**: Estados con Result/Failure y vistas Empty/Error dedicadas. UI consumiendo el estado del notifier.
- **Chatbot**: Pantalla redisenada (burbujas, prompts rapidos, banner de error, lista de mensajes persiste). Sigue usando ChatbotState/Result.
- **Theming y branding**: Nuevo sistema de colores (AppColors), ThemeData armonizado, splash nativo con logo y launcher icon personalizado generado con flutter_launcher_icons.
- **Recursos visuales**: Se incorporaron imagenes/mascotas de `assets/images/` y video `assets/videos/pantalla_carga.mp4` para el arranque Flutter (fallback nativo presente).

## Estado de backend
- **FastAPI (legacy)** operativo en `flutter/backend/app`.
- **NestJS (nuevo)** en `flutter/backend/nest` con modulos auth, diary/emotions, hydration, mindfulness/resources, chatbot (con fallback a Ollama/local), health. Usa Prisma + PostgreSQL (RDS/GCP).

## Como ejecutar
### Backend NestJS
```powershell
cd "FASE 2/Evidencias del proyecto/App/flutter/backend/nest"
npm install
cp .env.example .env   # ajusta credenciales RDS/CloudSQL y OLLAMA_BASE_URL
npm run start:dev      # expone http://localhost:4000/api
```

### App Flutter
```powershell
cd "FASE 2/Evidencias del proyecto/App/flutter"
flutter pub get
flutter run -d emulator-5554 ^
  --dart-define=USE_NEST_BACKEND=true ^
  --dart-define=NEST_API_BASE_URL=http://10.0.2.2:4000/api
```
- Para FastAPI usa `--dart-define=API_BASE_URL=http://10.0.2.2:8000`.
- Requerido: un dispositivo/emulador Android activo.

## Flujos a revisar (QA)
- **Auth**: login, crear cuenta, recuperar contrasena. Botones se deshabilitan en loading y muestran SnackBar de error/exito.
- **Diary**: carga lista (Loaded/Empty/Error), crear entrada, reintentar en error.
- **Chatbot**: prompts rapidos, mensajes muestran fallback si Ollama/backend no responde.
- **Home/Wellness**: tarjetas responsivas y gradientes consistentes con AppColors.

## Documentacion a consultar
- `flutter/README.md` detalles tecnicos de arquitectura Flutter.
- `GUIA_USUARIO.md` recorrido funcional y plan de 2 semanas.
- `flutter/backend/MODERNIZATION_PROGRESS.md` (si existe) seguimiento de migracion Nest.

Mantener este README actualizado al cierre de cada entrega para que el siguiente responsable tenga el contexto completo. 
