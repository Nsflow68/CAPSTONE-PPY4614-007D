# Modernizacion FastAPI -> NestJS

Tablero vivo para saber que modulos ya fueron portados, que datasets requiere la capa ETL y que pruebas quedan pendientes antes de cambiar el flag hacia NestJS en produccion.

## Estado por funcionalidad

| Dominio | FastAPI | NestJS | Notas |
|---------|---------|--------|-------|
| Health | listo | listo | `/health` responde en ambos |
| Auth / Users | listo (JWT HS256) | listo (Prisma + JWT/Passport) | Login/Signup emiten JWT reales (`/auth/login`, `/auth/me`) respaldados por Prisma |
| Mindfulness | listo | listo | Listado + highlights con datos mock |
| Hidratacion | listo | listo (Prisma + fallback) | `GET /hydration/weekly` y `POST /hydration/register` leen Prisma; si no hay DB vuelven al dataset en memoria |
| Diario emocional | listo | listo (Prisma + fallback) | Persistencia real con Prisma y `DemoUserService`; soporta filtros |
| Recursos/Guias | listo | listo (Prisma + dataset) | Se consume `resources.data.json` y se siembra automaticamente |
| Recompensas | Front-only | pendiente | Dependera de gamificacion + Prisma |
| Chatbot (Llama/Ollama) | listo | listo (Ollama + fallback) | `POST /chatbot/message` proxea a Ollama con m\u0000e0dtrica de latencia y fallback emp\u0000e1tico |

## Checklist de migracion

- [x] Config global (`ConfigModule`, `ValidationPipe`, prefix `/api`)
- [x] Modulo Mindfulness (sessions + highlights)
- [x] Documentar roadmap en `backend/README.md`
- [x] Modulos Hydration y Diary mockeados
- [x] Modulo Resources + dataset ETL
- [x] Prisma + PostgreSQL (esquema inicial)
- [x] Guards de autenticacion (JWT + Passport)
- [ ] Refresh tokens y rotacion
- [x] Persistencia real para recursos/hidratacion/diario (con fallback in-memory)
- [x] Chatbot module con telemetria b\u0000e1sica (latencia + fallback)
- [ ] CI (lint + Jest) y despliegue a ECS/Fargate

## ETL & servicios de data

| Fuente | Tipo | Transformacion | Consumidor | Estado |
|--------|------|----------------|------------|--------|
| MINSAL hidratacion diaria | CSV | Normalizar a ml/dia; agregar etiquetas `mujer/hombre` | `/hydration/weekly` | ✅ `hydration_etl.js` genera `hydration.reference.json` |
| OPS mindfulness | CSV | Normalizar sesiones < 15 min, traducir textos | `/mindfulness/sessions` | ✅ `mindfulness_etl.js` genera fallback `mindfulness.reference.json` |
| Directorio de salud mental | CSV/XLSX | Parsear + categorizacion + hashes ID | `/resources` y Flutter | script `resources_etl.py` listo |
| Diario emocional (telemetria app) | CSV/Supabase | Agregar sentimiento + agregaciones | `/diary/entries` | ✅ `diary_etl.js` alimenta fallback `diary.reference.json`; Prisma sigue siendo la fuente principal |

Proximos pasos ETL:

1. Anadir scripts pendientes para diario (`diary_etl.py`) y mindfulness (`mindfulness_etl.py`).
2. Publicar los nuevos datasets en `output/` y sincronizarlos con `src/**/data.json`.
3. Automatizar con GitHub Actions nocturno -> S3/Supabase Storage.

## Validacion requerida antes del flag switch

- [ ] `npm run test` (Nest) y `pytest` (FastAPI).
- [ ] `flutter test` + smoke manual (Chrome + emulador).
- [ ] Prueba manual de chatbot (FastAPI y Nest).
- [ ] Documentacion actualizada (README + changelog).

> Actualiza este archivo cada vez que cierres un modulo o agregues una fuente ETL nueva. Mantener visibilidad es clave para la ultima fase.
