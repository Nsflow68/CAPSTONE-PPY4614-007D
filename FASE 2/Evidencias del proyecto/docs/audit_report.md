# Auditoría Técnica y Plan de Refactorización - Mi Refugio

**Fecha:** 1 de Diciembre, 2025
**Objetivo:** Preparar el proyecto `CAPSTONE-PPY4614-007D` para defensa de tesis.
**Estado:** En Progreso 🟡

---

## 1. Inspección del Repositorio

### Estructura Actual vs. Esperada
*   **Frontend Real:** `FASE 2/Evidencias del proyecto/Mi refugio APP/flutter`
*   **Backend Real:** `FASE 2/Evidencias del proyecto/backend/nest` (Migrado)
*   **Legacy/ETL:** La carpeta `FASE 2/Evidencias del proyecto/App` y `Mi refugio API` (Express) deben ser eliminadas.

### Hallazgos de Código
*   [x] **Backend:** Migrado exitosamente a NestJS.
*   [x] **Frontend:** Estructura Flutter estándar, pero con problemas de navegación (Login Loop).

---

## 2. Auditoría del Entorno Local

### Verificaciones
*   **Flutter:** Funcionando.
*   **Backend:** NestJS corriendo en puerto 3001.
*   **Base de Datos:** AWS RDS (Conexión activa).

---

## 3. Autenticación y Navegación (Diagnóstico "Login Loop")

### Estado Actual
*   **Problema:** Loop infinito en pantalla de carga.
*   **Diagnóstico:** Desincronización entre `AuthNotifier` y `GoRouter`.
*   **Solución Pendiente:** Revisar lógica de redirección en `router.dart`.

---

## 4. Evaluación LLM / IA

### Integración Actual
*   Pendiente de migración al nuevo backend NestJS (`ChatbotModule`).

---

## 5. Estrategia de Migración a NestJS (Completada)

*   **DatabaseModule:** TypeORM configurado con schemas `app` y `web`.
*   **AuthModule:** Implementado con compatibilidad Django (`pbkdf2`).
*   **UsersModule:** Endpoints `/users` operativos.

---

## 6. Plan de Acción y Errores a Corregir (Deadline: Miércoles)

### 🚨 Errores Críticos (Must Fix)
1.  **Login Loop Infinito:**
    *   **Síntoma:** El usuario se autentica (Backend 200 OK), pero la App Móvil regresa al Login o se queda en Splash.
    *   **Causa:** Desincronización entre `AuthNotifier` (Riverpod) y `GoRouter`. El estado `AuthLoading` o una redirección circular en `SplashPage` está expulsando al usuario.
    *   **Solución:** Revisar `router.dart` y asegurar que `AuthAuthenticated` sea el único estado final tras un login exitoso.

2.  **Limpieza de Código Legacy:**
    *   **Síntoma:** Existencia de carpeta `App` (antigua) y scripts sueltos en `Mi refugio API`.
    *   **Acción:** Eliminar carpeta `App` y archivar el backend Express antiguo una vez estabilizado NestJS.

3.  **Configuración de Producción:**
    *   **Acción:** Asegurar que `.env` no se suba al repo público y que las credenciales de AWS RDS estén seguras.

### ✅ Avances Realizados
*   **Backend:** Migrado exitosamente a **NestJS** (Modular, TypeORM, Compatible con Django Hash).
*   **Infraestructura:** Servidor corriendo en puerto 3001 con prefijo `/api` y CORS habilitado.

---

## 7. Checklist de Entrega Final

- [x] Backend NestJS operativo.
- [ ] Login Móvil estable (Sin loops).
- [ ] Repositorio limpio (Estructura `frontend` / `backend`).
- [ ] Documentación `README.md` y `SETUP.md` completa.
