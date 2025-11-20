# Mi Refugio - Guía de Trabajo

Este directorio contiene todo el material solicitado para la app **Mi Refugio** en la fase de evidencias. La idea es que cualquier colaborador pueda ponerse al día en minutos, ejecutar la app Flutter, levantar el backend (FastAPI o el nuevo NestJS) y seguir el plan de las próximas semanas.

---

## Documentos clave
- [GUIA_USUARIO.md](./GUIA_USUARIO.md): guía de usuario con recorrido, tareas diarias y plan bimensual.
- `flutter/README.md`: referencia técnica para desarrolladores (estructura, scripts y enlaces a backend/ETL).
- `flutter/backend/README.md`: pasos para ejecutar FastAPI y la migración a NestJS.

## Actualizaciones recientes
- **Home dinámico**
  - El header refleja la última emoción registrada en el diario (emoji, colores y textos cambian automáticamente).
  - Se añadió la tarjeta "Registro rápido" para abrir el formulario del diario y consultar el historial en un toque.
- **Mindfulness con audios verificados**
  - Sección con audios oficiales (10, 16 y 26 minutos) tomados de guías del MINSAL y Hospital Digital con enlaces a la fuente original.
- **Recompensas persistentes**
  - El `rewardProvider` guarda/busca balance e insignias en `FlutterSecureStorage`. La pantalla de Perfil permite sincronizar o restablecer el progreso.
- **Chatbot Refu (mock)**
  - Hero con indicadores de calma, prompts rápidos y prácticas sugeridas; si el backend no responde, usa el motor mock.

## Estructura actual

```
FASE 2/Evidencias del proyecto/App
+-- README.md              # Este documento
+-- GUIA_USUARIO.md        # Recorrido funcional + cronograma
+-- flutter/               # App Flutter + backend en transición
|   +-- lib/               # Código de la app (Riverpod + GoRouter)
|   +-- backend/           # fastapi/ (legacy) y nest/ (nuevo stack)
|   +-- docs/              # Implementación, prompts, setup de IA
+-- App/mi_refugio         # Versión histórica (sólo referencia)
+-- .venv / herramientas   # Entornos auxiliares
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

## Flujos clave para QA

- **Diario emocional**: desde Home registra una emoción, verifica el carrusel y revisa "Momentos clave".
- **Chatbot Refu**: ingresa a `/chatbot`, usa prompts rápidos y confirma que aparezcan prácticas sugeridas incluso sin backend.
- **Recompensas / Perfil**: edita nombre, correo, teléfono y avatar; usa "Sincronizar" y "Restablecer" en *Mis insignias* y reinicia la app para verificar persistencia.

---

## Backend y servicios de datos

- **FastAPI (legacy):** `flutter/backend` - ver `README.md` para levantar entorno, endpoints vigentes y seeds.
- **NestJS (migración):** `flutter/backend/nest`
  - `npm install`
  - `cp .env.example .env`
  - `npm run start:dev` (expone `http://localhost:4000/api`)
- **ETL:** `flutter/backend/etl` - scripts (`resources_etl.py`) y datasets publicados en `output/` que luego se copian a los módulos Nest.
- Endpoints listos en Nest: `health`, `auth`, `mindfulness`, `hydration`, `diary`, `resources`.

Más detalle operativo y checklist en `flutter/backend/MODERNIZATION_PROGRESS.md`.

---

## Plan de dos semanas (mínimo 2 h/día)

| Día | Objetivo | Resultado esperado |
| --- | --- | --- |
| 1 | Pulir UI Inicio + Guía | Hero en video, chips y recorrido documentado |
| 2 | Hidratación y Mindfulness | Gráficas FLChart y tarjetas responsivas |
| 3 | Diario y Emociones | Modelos completos + animaciones en carrusel |
| 4 | Chatbot Refu | Integración con Llama vía backend FastAPI/Nest bridge |
| 5 | Recompensas y perfil | Estado guardado en secure storage + badges |
| 6 | Recursos/ETL | Validar pipelines y cache local |
| 7 | QA móvil (build 1) | `flutter test`, `flutter run -d chrome` |
| 8 | Backend Nest etapa 1 | Autenticación y seed inicial |
| 9 | Backend Nest etapa 2 | Recursos y chatbot streaming |
|10 | Backend Nest etapa 3 | Observabilidad + pruebas e2e |
|11 | QA móvil (build 2) | Smoke test en dos dispositivos/emuladores |
|12 | Documentación | Actualizar README, grabar video demo |
|13 | Retroalimentación | Ajustes visuales finos, accesibilidad |
|14 | Publicación interna | Tag en GitHub, checklist de pruebas |

> Si un día no se logra cubrir el objetivo, se recupera en la siguiente sesión manteniendo el mínimo de 2 h.

---

## Cómo colaborar

1. Levanta frontend/backend siguiendo las instrucciones anteriores.
2. Documenta todo cambio funcional en este README y en `GUIA_USUARIO.md`.
3. Adjunta capturas/logs cuando modifiques home, chatbot, recompensas, NestJS o ETL.
4. Antes de `git push` ejecuta:
   ```bash
   flutter format .
   flutter analyze
   flutter test
   ```
5. Mantén sincronizados los scripts/datasets del directorio `backend/etl`.

## Próximos hitos

1. **Consolidar backend NestJS** (semanas 1-2): endpoints de hidratación, diario y recursos con datos mockeados + conexión a PostgreSQL.
2. **ETL + servicios de datos**: definir pipelines (CSV → clean → JSON) y exponerlos vía CDN o API interna.
3. **Integrar modelo Llama (Ollama)**: crear módulo Nest `chatbot` que proxee a Ollama, con métricas y fallback seguro.
4. **QA & despliegue dual**: mantener FastAPI operativo hasta que Nest logre paridad, luego activar feature flag en Flutter.

Mantén este README actualizado al cierre de cada semana para que el siguiente responsable tenga el contexto completo. ¡Vamos a por la última fase!
