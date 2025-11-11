# Mi Refugio API

Servicio backend que alimenta la app Flutter. Actualmente corre sobre **FastAPI + MySQL**, pero se encuentra en transición hacia **NestJS + PostgreSQL** para unificar el stack del equipo y mejorar la observabilidad. Este documento resume el estado actual y el plan de migración (2‑3 semanas), además de describir cómo se integra el chatbot basado en modelos Llama.

---

## Estado tecnológico

| Capa | Actual | Próximo (NestJS) |
|------|--------|------------------|
| Runtime | Python 3.11 | Node.js 20 |
| Framework | FastAPI + Uvicorn | NestJS 10 |
| ORM | SQLAlchemy 2 | Prisma |
| Base de datos | MySQL 8 (AWS RDS) | PostgreSQL 15 (RDS o Supabase) |
| Auth | JWT (HS256) | JWT + Guards + Passport |
| Chatbot | Ollama (Llama 3.2) vía HTTP | Módulo Nest que proxea a Ollama y expone métricas |

> Hasta completar la migración, FastAPI sigue siendo la fuente de verdad para la app Flutter. El feature flag `USE_NEST_BACKEND` controlará el cambio de endpoints cuando la paridad esté asegurada.

---

## Roadmap FastAPI → NestJS (2‑3 semanas)

| Semana | Actividades |
|--------|-------------|
| 1 | `nest new api`, configuración de ESLint/Prettier, módulos `health`, `auth`, `users`. Configurar Prisma con PostgreSQL y replicar esquema actual. |
| 2 | Portar casos de uso de mindfulness, hidratación, diario y recursos. Añadir pruebas con Jest/Supertest, exponer Swagger y consolidar DTOs compartidos. |
| 3 | Implementar módulo `chatbot` que proxee a Ollama, habilitar logging estructurado, preparar pipelines de CI/CD y ejecutar pruebas end‑to‑end con Flutter antes del switch definitivo. |

Durante todo el proceso:

- Cada endpoint portado debe documentarse en `MODERNIZATION_PROGRESS.md`.
- Se mantendrá compatibilidad con FastAPI para no bloquear QA ni las entregas semanales.

---

## Estructura actual (FastAPI)

```
backend/
├── app/
│   ├── main.py
│   ├── config.py
│   ├── database.py
│   ├── models.py
│   ├── schemas.py
│   └── routers/
│       ├── auth.py
│       ├── diary.py
│       ├── hydration.py
│       ├── mindfulness.py
│       └── resources.py
├── sql/schema.sql
├── tests/
│   └── test_auth.py
├── requirements.txt
├── .env.example
└── OLLAMA_SETUP.md
```

> La carpeta `nest/` se añadirá conforme avancemos con la migración. Cada módulo tendrá su propio `README` corto y pruebas unitarias.

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

- Documentación interactiva: `http://localhost:8000/docs`
- Pruebas: `pytest`
- Semillas de datos: `mysql -h <host> -u <user> -p < sql/schema.sql`

---

## Chatbot Refu (Modelo Llama)

- **Proveedor local:** [Ollama](https://ollama.ai) con `llama3.2:3b-instruct-q4_K_M` (cuantizado). Consultar `OLLAMA_SETUP.md`.
- **Endpoints FastAPI:**
  - `POST /chatbot/message`
  - `GET /chatbot/health`
- **Migración:** NestJS añadirá un módulo `chatbot` que reutiliza el prompt y fallback actual. Internamente usará `axios` para llamar a Ollama y expondrá métricas (latencia, estado) para dashboards.
- **Compatibilidad:** Flutter seguirá usando las mismas rutas; el switch será transparente gracias al feature flag mencionado.

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

# Autenticación
JWT_SECRET=<cámbialo>
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRES_MIN=60

# Ollama
OLLAMA_BASE_URL=http://localhost:11434
OLLAMA_MODEL=llama3.2:3b-instruct-q4_K_M
```

Al migrar a NestJS se añadirá un archivo `.env.sample` equivalente con variables `POSTGRES_*` y `REDIS_URL` (para rate limiting).

---

## Recomendaciones de despliegue

1. Empaquetar imagen Docker con `uvicorn` (FastAPI) o `node dist/main` (NestJS).
2. Usar AWS RDS con SSL + Secrets Manager para credenciales.
3. Registrar logs estructurados (JSON) y exportarlos a CloudWatch / Datadog.
4. Configurar GitHub Actions:
   - Lint + pruebas.
   - Build/push a ECR.
   - Deploy a ECS Fargate o Lambda (para NestJS se evaluará serverless).

---

## Tareas pendientes

- [ ] Crear rama `feature/nest-migration` y subir scaffold NestJS.
- [ ] Documentar estrategia de migración de datos MySQL → PostgreSQL (dump + import).
- [ ] Replicar endpoints `/mindfulness`, `/hydration`, `/diary`, `/resources` en NestJS.
- [ ] Añadir métricas y alertas para el módulo de chatbot (tanto en FastAPI como en NestJS).
- [ ] Diseñar prueba end‑to‑end (Flutter Driver o integration_test) que valide autenticación + flujo de chatbot contra NestJS antes del switch final.

---

**Última actualización:** 2025‑11‑11  
**Responsables:** Equipo Backend Mi Refugio (Grupo 6, sección 007D).
