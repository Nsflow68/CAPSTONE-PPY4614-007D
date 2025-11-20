# Mi Refugio API

Servicio backend que alimenta la app Flutter. Actualmente corre sobre **FastAPI + MySQL**, pero se encuentra en transici????n hacia **NestJS + PostgreSQL** para unificar el stack del equipo y mejorar la observabilidad. Este documento resume el estado actual y el plan de migraci????n (2????????3 semanas), adem????s de describir c????mo se integra el chatbot basado en modelos Llama.

---

## Estado tecnol????gico

| Capa | Actual | Pr????ximo (NestJS) |
|------|--------|------------------|
| Runtime | Python 3.11 | Node.js 20 |
| Framework | FastAPI + Uvicorn | NestJS 10 |
| ORM | SQLAlchemy 2 | Prisma |
| Base de datos | MySQL 8 (AWS RDS) | PostgreSQL 15 (RDS o Supabase) |
| Auth | JWT (HS256) | JWT + Guards + Passport |
| Chatbot | Ollama (Llama 3.2) v????a HTTP | M????dulo Nest que proxea a Ollama y expone m????tricas |

> Hasta completar la migraci????n, FastAPI sigue siendo la fuente de verdad para la app Flutter. El feature flag `USE_NEST_BACKEND` controlar???? el cambio de endpoints cuando la paridad est???? asegurada.

---

## Roadmap FastAPI ???????? NestJS (2????????3 semanas)

| Semana | Actividades |
|--------|-------------|
| 1 | `nest new api`, configuraci????n de ESLint/Prettier, m????dulos `health`, `auth`, `users`. Configurar Prisma con PostgreSQL y replicar esquema actual. |
| 2 | Portar casos de uso de mindfulness, hidrataci????n, diario y recursos. A????adir pruebas con Jest/Supertest, exponer Swagger y consolidar DTOs compartidos. |
| 3 | Implementar m????dulo `chatbot` que proxee a Ollama, habilitar logging estructurado, preparar pipelines de CI/CD y ejecutar pruebas end????????to????????end con Flutter antes del switch definitivo. |

Durante todo el proceso:

- Cada endpoint portado debe documentarse en `MODERNIZATION_PROGRESS.md`.
- Se mantendr???? compatibilidad con FastAPI para no bloquear QA ni las entregas semanales.

---

## Estructura actual

```
backend/
+-- app/                      # FastAPI (producci??n/staging)
??   +-- main.py
??   +-- config.py
??   +-- database.py
??   +-- models.py
??   +-- routers/
??       +-- auth.py
??       +-- diary.py
??       +-- hydration.py
??       +-- mindfulness.py
??       +-- resources.py
+-- nest/                     # Nuevo stack NestJS
??   +-- package.json
??   +-- tsconfig*.json
??   +-- src/
??   ??   +-- app.module.ts
??   ??   +-- health/
??   ??   +-- auth/
??   ??   +-- mindfulness/
??   +-- .env.example
+-- sql/schema.sql
+-- tests/
??   +-- test_auth.py
+-- requirements.txt
+-- .env.example
+-- OLLAMA_SETUP.md
```

---

## Puesta en marcha (FastAPI)

```bash
cd "FASE 2/Evidencias del proyecto/App/flutter/backend"
python -m venv .venv
.venv\Scripts\activate            # Linux/Mac: source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env              # Ajustar credenciales AWS RDS y JWT
uvicorn app.main:app --reload --port 8000
```

- Documentaci????n interactiva: `http://localhost:8000/docs`
- Pruebas: `pytest`
- Semillas de datos: `mysql -h <host> -u <user> -p < sql/schema.sql`

---

## Puesta en marcha (NestJS)

```
cd "FASE 2/Evidencias del proyecto/App/flutter/backend/nest"
npm install
cp .env.example .env
npm run start:dev
```

- Configurar Prisma/PostgreSQL:
  1. Define `DATABASE_URL`, `DEMO_USER_EMAIL`, `JWT_SECRET` y `JWT_EXPIRES_IN` en el `.env`.
  2. Ejecuta `npm run prisma:generate` para generar el cliente.
  3. Crea el esquema inicial con `npm run prisma:migrate`.
  4. Pobla datos base (usuario demo + recursos) con `npm run prisma:seed`.
- Los m??????dulos `auth`, `diary`, `hydration` y `resources` usan Prisma cuando la conexi??????n est?????? disponible y vuelven a los mocks en memoria si la base de datos no responde.

- API disponible en `http://localhost:4000/api`.
- Endpoints listos:
  - `GET /api/health`
  - `POST /api/auth/login`
  - `POST /api/auth/signup`
  - `GET /api/auth/me` (necesita `Authorization: Bearer <token>`)
  - `GET /api/mindfulness/sessions`
  - `GET /api/mindfulness/highlights`
  - `GET /api/hydration/weekly`
  - `POST /api/hydration/register`
  - `GET /api/diary/entries`
  - `POST /api/diary/entries`
  - `GET /api/chatbot/health`
  - `POST /api/chatbot/message`
- Ejecutar pruebas: `npm run test`.

---
## Chatbot Refu (Modelo Llama)

- **Proveedor local:** [Ollama](https://ollama.ai) con `llama3.2:3b-instruct-q4_K_M` (cuantizado). Consultar `OLLAMA_SETUP.md`.
- **Endpoints FastAPI:**
  - `POST /chatbot/message`
  - `GET /chatbot/health`
- **Migraci????n:** NestJS a????adir???? un m????dulo `chatbot` que reutiliza el prompt y fallback actual. Internamente usar???? `axios` para llamar a Ollama y expondr???? m????tricas (latencia, estado) para dashboards.
- **Compatibilidad:** Flutter seguir???? usando las mismas rutas; el switch ser???? transparente gracias al feature flag mencionado.

---

## Config variables relevantes

```env
# Base de datos
MYSQL_HOST=mirefugio.c9ie2ckqg3rt.us-east-2.rds.amazonaws.com
MYSQL_PORT=3306
MYSQL_DATABASE=mirefugio
MYSQL_USER=mirefugio_owner
MYSQL_PASSWORD=<secreto>
MYSQL_SSL_CA=./certs/rds-combined-ca-bundle.pem

# Autenticaci????n
JWT_SECRET=<c????mbialo>
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRES_MIN=60

# Ollama
OLLAMA_BASE_URL=http://localhost:11434
OLLAMA_MODEL=llama3.2:3b-instruct-q4_K_M
```

Al migrar a NestJS se a????adir???? un archivo `.env.sample` equivalente con variables `POSTGRES_*` y `REDIS_URL` (para rate limiting).

---

## Recomendaciones de despliegue

1. Empaquetar imagen Docker con `uvicorn` (FastAPI) o `node dist/main` (NestJS).
2. Usar AWS RDS con SSL + Secrets Manager para credenciales.
3. Registrar logs estructurados (JSON) y exportarlos a CloudWatch / Datadog.
4. Configurar GitHub Actions:
   - Lint + pruebas.
   - Build/push a ECR.
   - Deploy a ECS Fargate o Lambda (para NestJS se evaluar???? serverless).

---

## Tareas pendientes

- [x] Crear rama `feature/nest-migration` y subir scaffold NestJS.
- [x] Documentar estrategia de migracion de datos MySQL -> PostgreSQL (dump + import).
- [x] Replicar endpoints `/mindfulness`, `/hydration`, `/diary`, `/resources`, `/chatbot` en NestJS (ahora expuestos con Prisma/Ollama y fallback).
- [ ] Anadir metricas y alertas adicionales para el modulo de chatbot (tanto en FastAPI como en NestJS).
- [ ] Disenar prueba end-to-end (Flutter Driver o integration_test) que valide autenticacion + flujo de chatbot contra NestJS antes del switch final.

---



**Ultima actualizacion:** 2025-11-19  
**Responsables:** Equipo Backend Mi Refugio (Grupo 6, seccion 007D).

### ETL y datasets
- Scripts en `etl/` generan JSON normalizados (por ejemplo recursos profesionales).
- Ejecuta `python resources_etl.py` para actualizar `output/resources.json` y sincronizarlo con `src/resources/resources.data.json`.
- Ejecuta `node hydration_etl.js` para producir `output/hydration_reference.json` y copiarlo a `src/hydration/hydration.reference.json` (fallback utilizado por `HydrationService`).
- Ejecuta `node diary_etl.js` para generar `output/diary_reference.json` y sincronizarlo con `src/diary/diary.reference.json`.
- Ejecuta `node mindfulness_etl.js` para generar `output/mindfulness_sessions.json` y sincronizarlo con `src/mindfulness/mindfulness.reference.json`.


