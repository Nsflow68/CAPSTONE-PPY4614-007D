# Guia de usuario - Mi Refugio

Recorrido actualizado y checklist de prueba rapida.

## Recorrido sugerido
1. **Inicio:** hero (video/splash nativo), accesos rapidos a habitos y registro rapido.
2. **Diario:** registra emociones, contexto y etiquetas; revisa estados Loaded/Empty/Error.
3. **Chatbot Refu (Llama):** prompts rapidos y practicas sugeridas; fallback si el backend no responde.
4. **Recursos y Mindfulness:** meditaciones, hidratacion y directorio profesional procesado via ETL.
5. **Perfil y Recompensas:** notificaciones, modo oscuro y logros persistentes.

## Nuevas pantallas de Auth
- **Login** con hero simplificado y CTA a la guia.
- **Crear cuenta**: nombre, correo, contrasena y confirmacion con validaciones locales.
- **Recuperar contrasena**: formulario de correo y SnackBar informativo (flujo real pendiente de backend).

## Mejoras visuales recientes
- Splash nativo y launcher icon personalizados con la paleta crema/lavanda.
- Componentes y tarjetas usando AppColors/AppGradients + sombras suaves.
- Chatbot Refu redisenado: prompts rapidos, burbujas claras y banner de error.
- Perfil con insignias, contador de badges y botones de sincronizar/restablecer.

## Servicios de datos y ETL
- Directorio de salud y contenido educativo normalizado en `flutter/backend/etl`.
- La app puede consumir FastAPI o Nest mediante el flag `USE_NEST_BACKEND`.
- Providers mock (hidratacion, recompensas, diario) siguen disponibles para pruebas offline.

## Plan operativo (2 semanas, minimo 2 h/dia)
| Dia | Objetivo | Resultado esperado |
| --- | --- | --- |
| 1 | Pulir UI Inicio + Guia | Hero en video/splash, CTA guia documentada |
| 2 | Hidratacion y Mindfulness | Graficas y tarjetas responsivas |
| 3 | Diario y Emociones | Modelos completos + animaciones |
| 4 | Chatbot Refu | Integracion Llama via FastAPI/Nest |
| 5 | Recompensas y perfil | Estado en secure storage + badges |
| 6 | Recursos/ETL | Validar pipelines y cache local |
| 7 | QA movil (build 1) | `flutter test`, `flutter run -d chrome` |
| 8 | Backend Nest etapa 1 | Autenticacion y seed inicial |
| 9 | Backend Nest etapa 2 | Recursos y chatbot streaming |
|10 | Backend Nest etapa 3 | Observabilidad + pruebas e2e |
|11 | QA movil (build 2) | Smoke test en dos dispositivos |
|12 | Documentacion | Actualizar README, grabar demo |
|13 | Retroalimentacion | Ajustes visuales finos, accesibilidad |
|14 | Publicacion interna | Tag, checklist de pruebas |

## Documentacion y seguimiento
- Actualiza este archivo y los README al cerrar cada hito.
- Guarda evidencias (capturas, logs, videos) en `flutter/docs/`.
- Registra avances de migracion en `flutter/backend/MODERNIZATION_PROGRESS.md`.
