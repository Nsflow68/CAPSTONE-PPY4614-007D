# Mi Refugio – CAPSTONE-PPY4614-007D

Repositorio del portafolio de título del grupo 6 (sección 007D, Sede Puente Alto). El entregable principal es **Mi Refugio**, una app móvil de bienestar emocional construida en Flutter, respaldada por un backend propio y un chatbot basado en modelos Llama.

## Estado general (noviembre 2025)

- **Frontend:** Flutter 3 (Material 3, Riverpod, GoRouter).
- **Backend actual:** FastAPI + SQLAlchemy sobre AWS RDS (MySQL).
- **Migración en curso:** transición de FastAPI a **NestJS** (Node.js) durante las próximas 2‑3 semanas.
- **IA conversacional:** modelo `llama3.2` servido mediante Ollama para el bot “Refu”.

> Toda la solución viva se encuentra bajo `FASE 2/Evidencias del proyecto/App/`. El resto de carpetas conservan historial de fases anteriores.

## Estructura principal

```
FASE 2/
└── Evidencias del proyecto/
    └── App/
        ├── flutter/          # Código completo de la app y documentación asociada
        │   ├── lib/          # Features, widgets, providers, temas
        │   ├── assets/       # Recursos gráficos y multimedia
        │   ├── backend/      # API FastAPI (en migración a NestJS)
        │   ├── docs/*.md     # Auditorías, guías de integración y progreso
        │   └── README.md     # Guía rápida para ejecutar la app
        └── .venv/            # Entorno Python usado en evidencias previas
```

## Roadmap de actualización (2‑3 semanas)

| Semana | Frontend | Backend | IA / DevOps |
|--------|----------|---------|-------------|
| 1 | Refactor de consumo de API para aislar capa `ApiClient`. | Generar boilerplate NestJS (Auth, Users, Health) con Prisma + PostgreSQL. | Contenerizar servicio de Ollama y documentar despliegue local. |
| 2 | Ajustar servicios Flutter para apuntar al gateway NestJS (feature flags para cambiar de FastAPI). | Portar módulos de mindfulness, hidratación y diario al dominio NestJS. | Implementar servicio gRPC/REST en NestJS que proxee a Llama y exponga métricas. |
| 3 | QA end‑to‑end (Flutter ↔ NestJS). | Cierre de endpoints pendientes + pruebas con Jest/Supertest y despliegue en staging. | Automatizar despliegues (GitHub Actions) y monitoreo de bot (logging + dashboards). |

## Modelo Llama para el bot Refu

- **Proveedor local:** [Ollama](https://ollama.ai) con modelos `llama3.2:3b-instruct-q4_K_M` y `llama3.1:8b`.
- **Integración actual:** FastAPI expone `/chatbot/message` y `/chatbot/health`; Flutter consume mediante Riverpod.
- **Durante la migración:** los endpoints se replicarán en NestJS dentro de un módulo `chatbot` que reutiliza el mismo prompt y fallback de respuestas para asegurar continuidad.
- **Requisitos mínimos:** CPU con AVX, 16 GB RAM y 20 GB libres para modelos locales; en servidores sin GPU se recomienda modo cuantizado.

## Cómo trabajar con el repositorio

1. **Frontend:** `cd FASE 2/Evidencias del proyecto/App/flutter && flutter pub get && flutter run`.
2. **Backend (actual):** `cd .../backend && uvicorn app.main:app --reload`.
3. **Backend (migración):** documentado en `FASE 2/Evidencias del proyecto/App/flutter/backend/README.md` con el plan FastAPI → NestJS.
4. **Chatbot / Llama:** sigue la guía `CHATBOT_IMPLEMENTATION_SUMMARY.md` y `OLLAMA_SETUP.md`.

Antes de abrir PRs:

- Asegura formato (`flutter format`, `ruff`, `eslint` para Nest cuando esté disponible).
- Describe claramente si el cambio afecta al roadmap de migración.
- Adjunta evidencias (capturas/logs) cuando actualices el bot o el backend.

---

**Contacto:** revisar el archivo `IMPLEMENTATION_SUMMARY.md` dentro de la carpeta `flutter` para más contexto técnico y responsables activos. Actualiza este README en cada hito mayor (al menos semanal) para mantener visible el estado en GitHub.
