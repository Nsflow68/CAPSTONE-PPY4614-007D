# Mi Refugio API

Servicio backend que alimenta la app Flutter. Actualmente corre sobre **FastAPI + MySQL**, pero se encuentra en transiciÃ³n hacia **NestJS + PostgreSQL** para unificar el stack del equipo y mejorar la observabilidad. Este documento resume el estado actual y el plan de migraciÃ³n (2â€‘3 semanas), ademÃ¡s de describir cÃ³mo se integra el chatbot basado en modelos Llama.

---

## Estado tecnolÃ³gico

| Capa | Actual | PrÃ³ximo (NestJS) |
|------|--------|------------------|
| Runtime | Python 3.11 | Node.js 20 |
| Framework | FastAPI + Uvicorn | NestJS 10 |
| ORM | SQLAlchemy 2 | Prisma |
| Base de datos | MySQL 8 (AWS RDS) | PostgreSQL 15 (RDS o Supabase) |
| Auth | JWT (HS256) | JWT + Guards + Passport |
| Chatbot | Ollama (Llama 3.2) vÃ­a HTTP | MÃ³dulo Nest que proxea a Ollama y expone mÃ©tricas |

> Hasta completar la migraciÃ³n, FastAPI sigue siendo la fuente de verdad para la app Flutter. El feature flag `USE_NEST_BACKEND` controlarÃ¡ el cambio de endpoints cuando la paridad estÃ© asegurada.

---

## Roadmap FastAPI â†’ NestJS (2â€‘3 semanas)

| Semana | Actividades |
|--------|-------------|
| 1 | `nest new api`, configuraciÃ³n de ESLint/Prettier, mÃ³dulos `health`, `auth`, `users`. Configurar Prisma con PostgreSQL y replicar esquema actual. |
| 2 | Portar casos de uso de mindfulness, hidrataciÃ³n, diario y recursos. AÃ±adir pruebas con Jest/Supertest, exponer Swagger y consolidar DTOs compartidos. |
| 3 | Implementar mÃ³dulo `chatbot` que proxee a Ollama, habilitar logging estructurado, preparar pipelines de CI/CD y ejecutar pruebas endâ€‘toâ€‘end con Flutter antes del switch definitivo. |

Durante todo el proceso:

- Cada endpoint portado debe documentarse en `MODERNIZATION_PROGRESS.md`.
- Se mantendrÃ¡ compatibilidad con FastAPI para no bloquear QA ni las entregas semanales.

---

## Estructura actual

```
backend/
+-- app/                      # FastAPI (producción/staging)
¦   +-- main.py
¦   +-- config.py
¦   +-- database.py
¦   +-- models.py
¦   +-- routers/
¦       +-- auth.py
¦       +-- diary.py
¦       +-- hydration.py
¦       +-- mindfulness.py
¦       +-- resources.py
+-- nest/                     # Nuevo stack NestJS
¦   +-- package.json
¦   +-- tsconfig*.json
¦   +-- src/
¦   ¦   +-- app.module.ts
¦   ¦   +-- health/
¦   ¦   +-- auth/
¦   ¦   +-- mindfulness/
¦   +-- .env.example
+-- sql/schema.sql
+-- tests/
¦   +-- test_auth.py
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

- DocumentaciÃ³n interactiva: `http://localhost:8000/docs`
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

- API disponible en `http://localhost:4000/api`.
- Endpoints listos:
  - `GET /api/health`
  - `POST /api/auth/login`
  - `POST /api/auth/signup`
  - `GET /api/mindfulness/sessions`
  - `GET /api/mindfulness/highlights`
  - `GET /api/hydration/weekly`
  - `POST /api/hydration/register`
  - `GET /api/diary/entries`
  - `POST /api/diary/entries`
- Ejecutar pruebas: `npm run test`.

---
## Chatbot Refu (Modelo Llama)

- **Proveedor local:** [Ollama](https://ollama.ai) con `llama3.2:3b-instruct-q4_K_M` (cuantizado). Consultar `OLLAMA_SETUP.md`.
- **Endpoints FastAPI:**
  - `POST /chatbot/message`
  - `GET /chatbot/health`
- **MigraciÃ³n:** NestJS aÃ±adirÃ¡ un mÃ³dulo `chatbot` que reutiliza el prompt y fallback actual. Internamente usarÃ¡ `axios` para llamar a Ollama y expondrÃ¡ mÃ©tricas (latencia, estado) para dashboards.
- **Compatibilidad:** Flutter seguirÃ¡ usando las mismas rutas; el switch serÃ¡ transparente gracias al feature flag mencionado.

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

# AutenticaciÃ³n
JWT_SECRET=<cÃ¡mbialo>
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRES_MIN=60

# Ollama
OLLAMA_BASE_URL=http://localhost:11434
OLLAMA_MODEL=llama3.2:3b-instruct-q4_K_M
```

Al migrar a NestJS se aÃ±adirÃ¡ un archivo `.env.sample` equivalente con variables `POSTGRES_*` y `REDIS_URL` (para rate limiting).

---

## Recomendaciones de despliegue

1. Empaquetar imagen Docker con `uvicorn` (FastAPI) o `node dist/main` (NestJS).
2. Usar AWS RDS con SSL + Secrets Manager para credenciales.
3. Registrar logs estructurados (JSON) y exportarlos a CloudWatch / Datadog.
4. Configurar GitHub Actions:
   - Lint + pruebas.
   - Build/push a ECR.
   - Deploy a ECS Fargate o Lambda (para NestJS se evaluarÃ¡ serverless).

---

## Tareas pendientes

- [ ] Crear rama `feature/nest-migration` y subir scaffold NestJS.
- [ ] Documentar estrategia de migraciÃ³n de datos MySQL â†’ PostgreSQL (dump + import).
- [ ] Replicar endpoints `/mindfulness`, `/hydration`, `/diary`, `/resources` en NestJS.
- [ ] AÃ±adir mÃ©tricas y alertas para el mÃ³dulo de chatbot (tanto en FastAPI como en NestJS).
- [ ] DiseÃ±ar prueba endâ€‘toâ€‘end (Flutter Driver o integration_test) que valide autenticaciÃ³n + flujo de chatbot contra NestJS antes del switch final.

---

**Ãšltima actualizaciÃ³n:** 2025â€‘11â€‘11  
**Responsables:** Equipo Backend Mi Refugio (Grupo 6, secciÃ³n 007D).
\n### ETL y datasets\n- Scripts en \etl/\ generan JSON normalizados (p.ej. recursos profesionales).\n- Ejecuta \python resources_etl.py\ para actualizar \output/resources.json\ y luego sincroniza con \
est/src/resources/resources.data.json\.
