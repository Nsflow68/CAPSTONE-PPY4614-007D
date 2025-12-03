# Arquitectura del Sistema 🏗️

Este documento describe la estructura técnica de **Mi Refugio App**.

## Diagrama de Componentes

```mermaid
graph TD
    User[Usuario Móvil] -->|HTTPS| Flutter[App Flutter]
    Flutter -->|REST API| NestJS[Backend NestJS]
    NestJS -->|SQL| DB[(PostgreSQL)]
    NestJS -->|HTTP| Ollama[LLM Local (Ollama)]
```

## 1. Frontend (Flutter)

Ubicación: `Mi refugio APP/flutter`

### Estructura de Carpetas (`lib/`)
- **`core/`**: Utilidades, configuración, rutas y temas globales.
- **`features/`**: Módulos funcionales (Auth, Home, Diary, Chatbot, etc.). Cada feature sigue la arquitectura Clean:
    - `presentation/`: Widgets y Pages.
    - `application/`: State Management (Riverpod).
    - `data/`: Repositorios y Modelos.
    - `domain/`: Entidades y casos de uso (si aplica).
- **`shared/`**: Widgets y constantes reutilizables.

### Tecnologías Clave
- **State Management**: Riverpod.
- **Routing**: GoRouter.
- **HTTP Client**: Dio.

## 2. Backend (NestJS)

Ubicación: `Mi refugio APP/backend_real`

### Estructura
- **`src/modules/`**: Módulos de negocio (Users, Auth, Chatbot).
- **`src/common/`**: Guards, Decorators, Filters.

### Integración LLM
El módulo `Chatbot` se comunica con una instancia local de **Ollama** para generar respuestas empáticas.
- **Endpoint**: `/api/chatbot/messages`
- **Modelo**: Llama 3 (configurable).

## 3. Base de Datos

- **Motor**: PostgreSQL.
- **ORM**: TypeORM / Prisma (según implementación).
- **Datos**: Usuarios, Entradas de Diario, Registros de Bienestar.
