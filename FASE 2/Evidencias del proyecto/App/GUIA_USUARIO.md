# Guía de usuario – Mi Refugio

Esta guía resume el nuevo recorrido visual (80 % más completo respecto a la versión anterior), describe cómo probar cada módulo y documenta el plan operativo para las próximas dos semanas.

## Recorrido sugerido
1. **Inicio:** mira el hero en video, revisa tu pulso emocional y usa los accesos rápidos a hábitos.
2. **Diario:** registra emociones, contexto y etiquetas. Obtén insights semanales y métricas de constancia.
3. **Chatbot Refu (Llama):** conversa para ejercicios de respiración, grounding o relajación guiada.
4. **Recursos y Mindfulness:** accede a meditaciones, hidratación inteligente y directorio profesional procesado vía ETL.
5. **Perfil y Recompensas:** ajusta notificaciones, activa modo oscuro y consulta logros acumulados.

## Nuevas mejoras visuales
- Hero con video incrustado (`assets/videos/pantalla_carga.mp4`) y chips interactivos.
- Banner de recorrido reutilizable con CTA hacia la guía interactiva.
- Tarjetas de momentos clave responsivas + animaciones suaves.
- Componentes consistentes con AppColors/AppGradients y sombras suaves.
- Guía en pantalla con pasos, timeline y sección de soporte contextual.
- Chatbot Refu con hero, prompts rápidos, burbujas animadas y prácticas sugeridas que funcionan aun sin backend gracias al servicio mock.
- Perfil con mosaico de insignias, contador de badges desbloqueados y botones para sincronizar/restablecer recompensas persistidas.

## Servicios de datos y ETL
- El directorio de salud y contenido educativo se normaliza mediante scripts en `backend/etl`.
- La app consume los JSON generados por Nest/FastAPI; al cambiar de backend solo se ajusta el feature flag `USE_NEST_BACKEND`.
- Para pruebas offline, los providers mockeados (hidratación, recompensas, diario) usan los mismos modelos que la API expone.

## Recompensas & Perfil
- El `rewardProvider` guarda el balance y las insignias en `FlutterSecureStorage`, de modo que los puntos y badges persisten entre sesiones.
- Desde **Perfil → Mis insignias** puedes:
  - Pulsar **Sincronizar** para recargar recompensas (vuelve a consultar storage y aplica las reglas actuales).
  - Pulsar **Restablecer** para reiniciar el balance a los objetivos predefinidos.
- Los campos de nombre, correo, teléfono, avatar y notificaciones también se almacenan en las llaves `mr:profile_*`, lo que permite reanudar la sesión sin depender de backend.

## Plan operativo (2 semanas, mínimo 2 h/día)
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

## Próximos hitos
- Ejecutar dos builds móviles (prod y beta) conectados a internet. Usa `flutter build apk --release` y `flutter build appbundle` tras validar QA.
- Migrar backend a NestJS en 2-3 semanas manteniendo compatibilidad con FastAPI mediante feature flags.
- Afinar el chatbot con prompts específicos para Llama y registrar la configuración en `backend/README.md`.
- Integrar calendario (Google Calendar) con el cronograma anterior mediante la API de Calendar o un bot en ChatGPT usando el prompt solicitado.

