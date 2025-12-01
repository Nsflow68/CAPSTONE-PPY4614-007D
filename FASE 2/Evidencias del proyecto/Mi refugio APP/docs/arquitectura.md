# Arquitectura de Mi Refugio APP (Versión Móvil)

## Información General

- **Proyecto**: Mi Refugio - Aplicación Móvil Android
- **Stack Tecnológico**: Flutter + NestJS + PostgreSQL + LLM Local (Ollama)
- **Tipo**: Aplicación móvil de acompañamiento emocional con gestión de refugios y adopciones
- **Grupo**: Grupo 6 - Sección 007D
- **Fecha**: Noviembre 2025

## Arquitectura General

La aplicación Mi Refugio está construida siguiendo una arquitectura moderna de tres capas:

```
┌─────────────────────────────────────┐
│     Cliente Móvil (Flutter)         │
│  - Android APK                      │
│  - Arquitectura MVVM/Clean          │
│  - Riverpod (State Management)      │
└──────────────┬──────────────────────┘
               │ HTTP/REST
               │
┌──────────────▼──────────────────────┐
│     Backend API (NestJS)            │
│  - RESTful API                      │
│  - TypeScript                       │
│  - Prisma ORM                       │
│  - JWT Authentication               │
└──────────────┬──────────────────────┘
               │ PostgreSQL
               │
┌──────────────▼──────────────────────┐
│     Base de Datos (PostgreSQL)      │
│  - Schema: mobile                   │
│  - Modelos: User, Refuge, Adoption  │
│  - DiaryEntry, Resource, etc.       │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│     LLM Local (Ollama)              │
│  - Modelo: llama3.2:3b-instruct     │
│  - Servicio: Refu (chatbot)         │
│  - Endpoint HTTP local              │
└─────────────────────────────────────┘
```

## Módulos del Backend (NestJS)

### Módulos Core
1. **AuthModule**: Autenticación JWT, login, registro
2. **HealthModule**: Health checks del sistema
3. **DatabaseModule (Prisma)**: Conexión y ORM

### Módulos de Dominio
4. **RefugesModule**: Gestión de refugios de animales
   - Listar refugios por región
   - Detalle de refugio
   - Estadísticas de ocupación

5. **AdoptionsModule**: Gestión de mascotas en adopción
   - Listar adopciones disponibles
   - Filtrado por tipo de mascota
   - Marcar como adoptado

6. **ChatModule**: Chatbot Refu con LLM local
   - **LlmLocalService**: Integración con Ollama
   - **RefuService**: Lógica de conversación empática
   - Fallback responses

7. **DiaryModule**: Diario emocional del usuario
8. **HydrationModule**: Seguimiento de hidratación
9. **MindfulnessModule**: Sesiones de mindfulness
10. **ResourcesModule**: Recursos de salud mental

## Estructura del Proyecto

```
Mi refugio APP/
├── flutter/                    # Aplicación móvil Flutter
│   ├── lib/
│   │   ├── core/              # Servicios, config, router
│   │   ├── features/          # Módulos por feature
│   │   │   ├── auth/
│   │   │   ├── refuges/       # Refugios (nuevo)
│   │   │   ├── adoptions/     # Adopciones (nuevo)
│   │   │   ├── chatbot/       # Chat con Refu
│   │   │   ├── diary/
│   │   │   ├── home/
│   │   │   └── ...
│   │   └── shared/            # Widgets, constantes
│   ├── android/
│   ├── assets/
│   ├── pubspec.yaml
│   ├── .env.staging.example
│   └── .env.production.example
│
├── backend/
│   └── nest/                  # Backend NestJS
│       ├── src/
│       │   ├── auth/
│       │   ├── refuges/       # Módulo refugios (nuevo)
│       │   ├── adoptions/     # Módulo adopciones (nuevo)
│       │   ├── chat/          # Chat con Refu (reorganizado)
│       │   │   └── refu/
│       │   │       ├── llm-local.service.ts
│       │   │       └── refu.service.ts
│       │   ├── diary/
│       │   ├── health/
│       │   └── ...
│       ├── prisma/
│       │   └── schema.prisma  # Modelos de datos
│       ├── docker-compose.yml
│       ├── Dockerfile
│       ├── .env.staging.example
│       └── .env.production.example
│
├── docs/                      # Documentación (esta carpeta)
│   ├── arquitectura.md
│   ├── api_mobile.md
│   ├── guias_visual.md
│   └── testing_checklist.md
│
├── .github/
│   └── workflows/
│       ├── ci_cd_nest.yml
│       └── ci_cd_flutter_android.yml
│
└── README.md
```

## Decisiones de Arquitectura (DA)

### DA-001: Arquitectura Limpia en Flutter
**Decisión**: Implementar Clean Architecture con separación de capas (data, domain, presentation).

**Justificación**:
- Testabilidad y mantenibilidad
- Separación de responsabilidades
- Independencia del framework

### DA-002: Riverpod para State Management
**Decisión**: Usar Riverpod como solución de gestión de estado.

**Justificación**:
- Type-safe y compile-time safe
- Mejor rendimiento que Provider
- Integración con go_router

### DA-003: NestJS como Backend Framework
**Decisión**: Usar NestJS con TypeScript para el backend.

**Justificación**:
- Arquitectura modular por defecto
- Soporte nativo para TypeScript
- Ecosystem robusto (Prisma, Passport, etc.)

### DA-004: PostgreSQL como Base de Datos
**Decisión**: PostgreSQL con schema `mobile` dedicado.

**Justificación**:
- Relacional, robusto, open-source
- Soporte para schemas múltiples
- Compatibilidad con Prisma ORM

### DA-005: Prisma como ORM
**Decisión**: Prisma ORM para acceso a datos.

**Justificación**:
- Type-safe queries
- Migraciones automáticas
- Excelente developer experience

### DA-006: LLM Local (Ollama) para Chatbot
**Decisión**: Integración con modelo LLM local vía Ollama.

**Justificación**:
- Sin dependencia de APIs externas (OpenAI, Google)
- Control total sobre el modelo
- Privacidad de datos del usuario
- Costos operativos reducidos

### DA-007: JWT para Autenticación
**Decisión**: JSON Web Tokens para autenticación stateless.

**Justificación**:
- Stateless, escalable
- Compatible con aplicaciones móviles
- Estándar de la industria

### DA-008: Docker para Infraestructura
**Decisión**: Docker y Docker Compose para desarrollo y deploy.

**Justificación**:
- Entornos reproducibles
- Fácil setup para desarrollo
- Portable entre ambientes

## Flujo de Datos

### Ejemplo: Listar Refugios

1. **Usuario** abre la pantalla de refugios en Flutter
2. **RefugeProvider** (Riverpod) solicita datos al **RefugeRepository**
3. **RefugeRepository** hace request HTTP a `/api/refuges`
4. **NestJS RefugesController** recibe la petición
5. **RefugesService** consulta la base de datos vía **Prisma**
6. **PostgreSQL** retorna los datos
7. Los datos fluyen de vuelta hasta el **UI** en Flutter
8. La interfaz se actualiza reactivamente gracias a Riverpod

### Ejemplo: Chat con Refu

1. **Usuario** envía mensaje en ChatbotPage
2. **ChatbotProvider** llama a **ChatbotRepository**
3. Request POST a `/api/chat/refu` con el mensaje
4. **ChatController** → **RefuService**
5. **RefuService** → **LlmLocalService**
6. **LlmLocalService** hace request HTTP a Ollama (`http://localhost:11434`)
7. **Ollama** genera respuesta con el modelo llama3.2
8. Respuesta fluye de vuelta al usuario en la UI

## Seguridad

- **Autenticación**: JWT con tokens de 1 hora
- **Validación**: DTOs con class-validator en NestJS
- **CORS**: Configurado en NestJS
- **HTTPS**: Recomendado en producción
- **Secrets**: Variables de entorno (.env)
- **Rate Limiting**: Opcional (configurar en producción)

## Escalabilidad

- **Backend**: Stateless, horizontal scaling posible
- **Base de Datos**: PostgreSQL soporta replicación
- **LLM**: Puede moverse a servidor dedicado si es necesario
- **Cache**: Redis puede agregarse para mejorar rendimiento

## Tecnologías Clave

### Frontend (Flutter)
- **flutter_riverpod**: State management
- **go_router**: Navegación declarativa
- **http**: Cliente HTTP
- **google_fonts**, **flutter_svg**: UI

### Backend (NestJS)
- **@nestjs/core**, **@nestjs/common**: Core framework
- **@prisma/client**: ORM
- **@nestjs/jwt**, **passport**: Autenticación
- **@nestjs/axios**: HTTP client para Ollama
- **class-validator**, **class-transformer**: Validación

### Infraestructura
- **PostgreSQL 15**: Base de datos
- **Docker & Docker Compose**: Contenedores
- **Ollama**: Runtime para LLM local

## Próximos Pasos (Post-Presentación)

1. Implementar pantallas completas de refugios y adopciones en Flutter
2. Agregar tests unitarios y de integración
3. Configurar monitoreo (logging, métricas)
4. Implementar CI/CD completo con deploy automático
5. Optimizar rendimiento del LLM
6. Agregar notificaciones push
7. Implementar analytics

---

**Documento alineado al DAS (Documento de Arquitectura de Software)**
Creado por Claude Code - Noviembre 2025
