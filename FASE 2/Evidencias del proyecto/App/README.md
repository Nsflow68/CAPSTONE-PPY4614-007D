# Mi Refugio — Guía de Trabajo

Este directorio contiene todo el material solicitado para la app **Mi Refugio** en la fase de evidencias. La idea es que cualquier colaborador pueda ponerse al día en minutos, ejecutar la app Flutter, levantar el backend (FastAPI o el nuevo NestJS) y seguir el plan de las próximas semanas.

---

## Documentos clave
- [GUIA_USUARIO.md](./GUIA_USUARIO.md): guía de usuario con recorrido, tareas diarias y plan bimensual.

## Estructura actual

```
FASE 2/Evidencias del proyecto/App
├── README.md              # Este documento
├── flutter/               # App Flutter + backend en transición
│   ├── lib/               # Código de la app (Riverpod + GoRouter)
│   ├── backend/           # fastapi/ (legacy) y nest/ (nuevo stack)
│   └── test/              # smoke tests de Flutter
├── App/mi_refugio         # Versión histórica (sólo referencia, no tocar)
└── .venv / herramientas   # Entornos auxiliares
```

- **Frontend:** `flutter/` (usa Dart 3.5, Flutter 3.24).
- **Backend actual:** `flutter/backend/app` (FastAPI).
- **Backend nuevo:** `flutter/backend/nest` (NestJS + Prisma, en curso).

---

## Cómo ejecutar la app Flutter

```bash
cd "FASE 2/Evidencias del proyecto/App/flutter"
flutter pub get
flutter test                          # smoke test (verifica arranque)
flutter run -d chrome                 # versión web
flutter run -d emulator-5554 --profile  # versión móvil (Android emu)
```

> Requisito del cliente: mantener **dos builds accesibles** (Chrome + emulador). Después de cada cambio relevante, valida ambos targets usando el backend FastAPI (`http://localhost:8000`) o Nest (`http://localhost:4000/api`) según el feature flag.

---

## Backend y servicios de datos

- **FastAPI (legacy):** `flutter/backend` — ver `README.md` para levantar entorno, endpoints vigentes y seeds.
- **NestJS (migración):** `flutter/backend/nest`
  - `npm install`
  - `cp .env.example .env`
  - `npm run start:dev` (expone `http://localhost:4000/api`)
- **ETL:** `flutter/backend/etl` — contiene scripts (`resources_etl.py`) y datasets publicados en `output/` que luego se copian a los módulos Nest.
- Endpoints listos en Nest: `health`, `auth`, `mindfulness`, `hydration`, `diary`, `resources`.
- **ETL / Data services:** el plan es consumir fuentes públicas (MINSAL, OPS, bibliotecas de mindfulness) y normalizarlas a colecciones JSON consumibles por Flutter. Los scripts de extracción vivirán en `flutter/backend/etl/` (pendiente en esta fase) y publicarán datasets a S3 o supabase storage.

Más detalle operativo y checklist en `flutter/backend/MODERNIZATION_PROGRESS.md`.

---

## Plan de dos semanas (mínimo 2 h diarias)

| Día | Objetivo (mínimo 2 h) | Entregable |
|-----|-----------------------|------------|
| 1 | Cerrar lint/tests, documentar estructura | Este README + smoke tests |
| 2 | Modernizar Nest: módulos Hydration & Diary | Endpoints `/hydration`, `/diary` |
| 3 | Diseñar ETL (schemas, fuentes, cron) | Documento ETL + scripts base |
| 4 | Portar recursos/guías a Nest + mocks Llama | `/resources` + prompt base |
| 5 | Integrar feature flag Flutter (FastAPI↔Nest) | Toggle en `app_config.dart` |
| 6 | Pruebas e2e (login + chatbot) contra ambos backends | Informe QA |
| 7 | Implementar almacenamiento local seguro (Flutter) | Persistencia Riverpod |
| 8 | Migrar autenticación Nest (JWT + guards) | `/auth` paridad completa |
| 9 | Crear pipeline ETL (ingesta → limpieza → publish) | Script + README |
| 10 | Integrar endpoints ETL en Flutter (recursos dinámicos) | UI consumiendo datasets |
| 11 | Afinar UX (animaciones/video inicial) | Splash + home actualizados |
| 12 | Validar dos builds móviles + Chrome con Nest | Registro en hoja de pruebas |
| 13 | Preparar documentación final (manual técnico + usuario) | Carpeta Evidencias actualizada |
| 14 | Buffer de riesgos / demo interna | Checklist de release |

> Si un día no se logra cubrir el objetivo, se recupera en la siguiente sesión manteniendo el mínimo de 2 h.

---

## Próximos hitos

1. **Consolidar backend NestJS** (semanas 1‑2): endpoints de hidratación, diario y recursos con datos mockeados + conexión a PostgreSQL.
2. **ETL + servicios de datos**: definir pipelines (CSV → clean → JSON) y exponerlos vía CDN o API interna.
3. **Integrar modelo Llama (Ollama)**: crear módulo Nest `chatbot` que proxee a Ollama, con métricas y fallback seguro.
4. **QA & despliegue dual**: mantener FastAPI operativo hasta que Nest logre paridad, luego activar feature flag en Flutter.

Mantén este README actualizado al cierre de cada semana para que el siguiente responsable tenga el contexto completo. ¡Vamos a por la última fase! 💪


