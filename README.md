# Mi Refugio – CAPSTONE-PPY4614-007D

Repositorio del portafolio de título del grupo 6 (sección 007D, Sede Puente Alto). El entregable principal es **Mi Refugio**, una app móvil de bienestar emocional construida en Flutter, respaldada por servicios propios (FastAPI → NestJS) y un chatbot basado en modelos Llama.

> Toda la solución viva se encuentra bajo `FASE 2/Evidencias del proyecto/App/`. Dentro de esa carpeta encontrarás el código Flutter, el backend (FastAPI + NestJS), assets, documentación y scripts de ETL.

## Estado general (noviembre 2025)

| Capa | Estado actual | Próximo hito |
|------|---------------|--------------|
| **Frontend Flutter** | Material 3, Riverpod y GoRouter con módulos de inicio, diario, chatbot, mindfulness, recursos y perfil. Hero en video, carrusel emocional ligado al diario y recompensas persistentes. | Consumir endpoints NestJS mediante feature flag (`USE_NEST_BACKEND`) y ejecutar pruebas end-to-end. |
| **Backend FastAPI** | Fuente de verdad para la app en producción. Maneja auth, recursos, mindfulness, hidratación y chatbot (vía Ollama). | Mantener en paralelo hasta que Nest alcance paridad; exponer métricas para el bot. |
| **Backend NestJS** | Proyecto en `flutter/backend/nest`. Ya cuenta con módulos `auth`, `health`, `mindfulness`, `hydration`, `diary` y `resources` scaffoldeados. | Completar migración (Prisma + PostgreSQL) y portar chatbot/referrals en 2‑3 semanas. |
| **IA (Refu)** | Modelo `llama3.2` sirviéndose con Ollama. Flutter usa un servicio mock cuando el backend no responde para garantizar UX. | Publicar módulo `chatbot` en NestJS con métricas, logging y prompts auditables. |

## Estructura principal

```
FASE 2/
└─ Evidencias del proyecto/
   ├─ App/
   │  ├─ README.md            ← Guía operativa (frontend/backend)
   │  ├─ GUIA_USUARIO.md      ← Recorrido funcional + cronograma
   │  ├─ flutter/             ← Proyecto Flutter (app + backend en transición)
   │  │  ├─ lib/              ← Features, widgets, providers, temas
   │  │  ├─ assets/           ← Branding, audios y videos
   │  │  ├─ backend/          ← FastAPI (legacy) + NestJS (nuevo stack)
   │  │  └─ docs/*.md         ← Auditorías, guías de integración
   │  └─ .venv/               ← Entorno Python usado en evidencias previas
   └─ …                       ← Historial de fases anteriores
```

## Resumen funcional

- **Inicio:** hero en video con chips de hábitos, carrusel emocional ligado al diario y accesos rápidos a hidratación, mindfulness, recursos y chatbot.
- **Diario:** providers con datos persistentes; el resumen semanal alimenta el carrusel de Home.
- **Recompensas:** balance e insignias almacenadas en `FlutterSecureStorage`. Desde Perfil se puede sincronizar o restablecer el progreso.
- **Chatbot Refu:** pantalla renovada con indicadores de calma, prompts rápidos, prácticas sugeridas y motor mock cuando Nest/FastAPI no está disponible.
- **ETL/Recursos:** scripts en `flutter/backend/etl` normalizan fuentes MINSAL/OPS para mindfulness y directorio profesional.

## Roadmap de actualización (2‑3 semanas)

| Semana | Frontend | Backend | IA / DevOps |
|--------|----------|---------|-------------|
| 1 | Refactor de `ApiService` y almacenamiento seguro de preferencias. | Boilerplate NestJS (Auth, Users, Health) + Prisma/PostgreSQL | Contenerizar Ollama y documentar despliegue local. |
| 2 | Feature flag para apuntar a NestJS, badges persistentes y pruebas en emuladores. | Portar mindfulness, hidratación y diario a NestJS; feature flag en FastAPI | Servicio REST/gRPC en NestJS que proxee a Llama con métricas. |
| 3 | QA end-to-end (Flutter ↔ NestJS) + paquete de evidencias. | Pruebas Jest/Supertest, despliegue a staging y cut-over planificado. | Automatizar despliegues (GitHub Actions) y monitoreo (logging/dashboards). |

## Modelo Llama para el bot Refu

- **Proveedor local:** [Ollama](https://ollama.ai) (`llama3.2:3b-instruct-q4_K_M` y `llama3.1:8b`).
- **Integración actual:** FastAPI expone `/chatbot/message` y `/chatbot/health`; Flutter consume vía Riverpod y mantiene fallback mock.
- **Plan NestJS:** módulo `chatbot` reutiliza prompts, expone métricas y permite versionar la configuración.
- **Requisitos mínimos:** CPU con AVX, 16 GB RAM y 20 GB libres. Para entornos sin GPU se usa cuantización.

## Cómo trabajar con el repositorio

1. **Frontend**
   ```bash
   cd "FASE 2/Evidencias del proyecto/App/flutter"
   flutter pub get
   flutter test
   flutter run -d chrome   # o -d <emulador>
   ```
2. **Backend (FastAPI)**
   ```bash
   cd FASE\ 2/Evidencias\ del\ proyecto/App/flutter/backend
   uvicorn app.main:app --reload
   ```
3. **Backend (NestJS)**: seguir `flutter/backend/README.md` (`npm install`, `cp .env.example .env`, `npm run start:dev`).
4. **ETL / Recursos**: ver `flutter/backend/etl/README.md`.
5. **Chatbot / Llama**: guías `CHATBOT_IMPLEMENTATION_SUMMARY.md` y `OLLAMA_SETUP.md` dentro de `flutter/docs`.

### Recomendaciones para PRs

- Ejecuta linters/tests (`flutter format`, `flutter analyze`, `flutter test`, `ruff`, `pytest`, `npm run lint`).
- Documenta cambios relevantes en `README.md`, `GUIA_USUARIO.md` y en el historial de la carpeta afectada.
- Adjunta capturas/logs cuando modifiques chatbot, recompensas o integración con NestJS.

---

**Contacto / responsables:** revisa `flutter/docs/IMPLEMENTATION_SUMMARY.md` para conocer a los encargados actuales y puntos de contacto por módulo. Actualiza este README cada vez que se cierre un hito para mantener el estado visible en GitHub.
