# Modernización FastAPI → NestJS

Tablero vivo para saber qué módulos ya fueron portados, qué datasets requiere la capa ETL y qué pruebas quedan pendientes antes de cambiar el flag hacia NestJS en producción.

## Estado por funcionalidad

| Dominio | FastAPI | NestJS | Notas |
|---------|---------|--------|-------|
| Health | ✅ listo | ✅ listo | `/health` responde en ambos |
| Auth / Users | ✅ (JWT HS256) | ⚠️ stub (login/signup mock) | Falta conectar con BD + Passport |
| Mindfulness | ✅ | ✅ | Listado + highlights con datos mock |
| Hidratación | ✅ | ✅ **nuevo** | `GET /hydration/weekly`, `POST /hydration/register` en memoria |
| Diario emocional | ✅ | ✅ **nuevo** | `GET /diary/entries` (filtros) y `POST /diary/entries` |
| Recursos/Guías | ✅ | ✅ **nuevo** | Usa dataset generado por ETL (`resources.data.json`) |
| Recompensas | Front-only | ⏳ pendiente | Dependerá de gamificación + Prisma |
| Chatbot (Llama/Ollama) | ✅ | ⏳ pendiente | Crear módulo `chatbot` con métricas |

## Checklist de migración

- [x] Config global (`ConfigModule`, `ValidationPipe`, prefix `/api`)
- [x] Módulo Mindfulness (sessions + highlights)
- [x] Documentar roadmap en `backend/README.md`
- [x] Módulos Hydration y Diary mockeados
- [x] Módulo Resources + dataset ETL
- [ ] Prisma + PostgreSQL (esquema inicial)
- [ ] Guards de autenticación + refresh tokens
- [ ] Persistencia real para recursos/hidratación/diario
- [ ] Chatbot module con telemetría
- [ ] CI (lint + Jest) y despliegue a ECS/Fargate

## ETL & servicios de data

| Fuente | Tipo | Transformación | Consumidor | Estado |
|--------|------|----------------|------------|--------|
| MINSAL hidratación diaria | CSV | Normalizar a ml/día; agregar etiquetas `mujer/hombre` | `/hydration/weekly` | ⏳ diseño |
| OPS mindfulness | JSON | Seleccionar prácticas < 15 min, traducir textos | `/mindfulness/sessions` | ✅ mock (pendiente ETL) |
| Directorio de salud mental | CSV/XLSX | Parsear + categorización + hashes ID | `/resources` y Flutter | ✅ script `resources_etl.py` |
| Diario emocional (telemetría app) | Supabase | Agregar sentimiento + agregaciones | `/diary/entries` | 🔄 en memoria |

Próximos pasos ETL:

1. Añadir scripts para hidratación y diario (`hydration_etl.py`, `diary_etl.py`).
2. Publicar datasets en `output/` y sincronizarlos con `src/**/data.json`.
3. Automatizar con GitHub Actions nocturno → S3/Supabase Storage.

## Validación requerida antes del flag switch

- [ ] `npm run test` (Nest) y `pytest` (FastAPI).
- [ ] `flutter test` + smoke manual (Chrome + emulador).
- [ ] Prueba manual de chatbot (FastAPI y Nest).
- [ ] Documentación actualizada (README + changelog).

> Actualiza este archivo cada vez que cierres un módulo o agregues una fuente ETL nueva. Mantener visibilidad es clave para la última fase. 💡
