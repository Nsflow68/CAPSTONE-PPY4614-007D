# Arquitectura del Sistema

Este documento describe la estructura tecnica de **Mi Refugio App**.

## Diagrama de Componentes

```mermaid
graph TD
    User[Usuario Movil] -->|HTTPS| Flutter[App Flutter]
    Flutter -->|REST API| NestJS[Backend NestJS]
    NestJS -->|SQL| DB[(PostgreSQL)]
    NestJS -->|HTTP| Ollama[LLM Local (Ollama)]
```

## 1. Frontend (Flutter)

Ubicacion: `Mi refugio APP/flutter`

### Estructura de Carpetas (`lib/`)
- **`core/`**: Utilidades, configuracion, rutas y temas globales.
- **`features/`**: Modulos funcionales (Auth, Home, Diary, Chatbot, etc.). Cada feature sigue la arquitectura Clean:
    - `presentation/`: Widgets y Pages.
    - `application/`: State Management (Riverpod).
    - `data/`: Repositorios y Modelos.
    - `domain/`: Entidades y casos de uso (si aplica).
- **`shared/`**: Widgets y constantes reutilizables.

### Tecnologias Clave
- **State Management**: Riverpod.
- **Routing**: GoRouter.
- **HTTP Client**: Dio.

## 2. Backend (NestJS)

Ubicacion: `Mi refugio APP/flutter/backend/nest`

### Estructura
- **`src/`**: Codigo fuente principal.
    - **`auth/`**: Modulo de autenticacion (JWT, Guards).
    - **`users/`**: Gestion de usuarios.
    - **`chatbot/`**: Integracion con Ollama y logica de chat.
    - **`diary/`**: Entradas de diario emocional.
    - **`common/`**: Utilidades compartidas, validadores (RUT), filtros de excepcion.

### Integracion LLM
El modulo `Chatbot` se comunica con una instancia local de **Ollama** para generar respuestas empaticas.
- **Endpoint**: `/chatbot/message`
- **Modelo**: Llama 3 (configurable).

## 3. Base de Datos

- **Motor**: PostgreSQL (AWS RDS).
- **ORM**: Prisma.
- **Datos**: Usuarios, Entradas de Diario, Registros de Bienestar.
