# API Mobile - Mi Refugio Backend

## Base URL
```
Development: http://localhost:3001/api
Production: https://api.mirefugio.cl/api
```

## Autenticación

Todos los endpoints protegidos requieren un token JWT en el header:
```
Authorization: Bearer {token}
```

---

## Auth Module

### POST /auth/signup
Registro de nuevo usuario.

**Body:**
```json
{
  "email": "usuario@example.com",
  "password": "password123",
  "name": "Juan Pérez"
}
```

**Response:** `201 Created`
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "uuid",
    "email": "usuario@example.com",
    "name": "Juan Pérez",
    "role": "member"
  }
}
```

### POST /auth/login
Inicio de sesión.

**Body:**
```json
{
  "email": "usuario@example.com",
  "password": "password123"
}
```

**Response:** `200 OK`
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "uuid",
    "email": "usuario@example.com",
    "name": "Juan Pérez"
  }
}
```

---

## Refuges Module

### GET /refuges
Listar refugios.

**Query Parameters:**
- `region` (opcional): Filtrar por región (ej: "Metropolitana")
- `isActive` (opcional): Filtrar por estado activo (true/false)

**Response:** `200 OK`
```json
[
  {
    "id": "uuid",
    "name": "Refugio Esperanza",
    "description": "Refugio de animales en la región metropolitana",
    "address": "Av. Libertador 1234, Santiago",
    "phone": "+56912345678",
    "email": "contacto@esperanza.cl",
    "website": "https://esperanza.cl",
    "capacity": 50,
    "occupied": 35,
    "region": "Metropolitana",
    "commune": "Santiago",
    "latitude": -33.4489,
    "longitude": -70.6693,
    "services": ["veterinaria", "adopcion", "educacion"],
    "imageUrl": "https://...",
    "isActive": true,
    "createdAt": "2025-01-01T00:00:00.000Z",
    "updatedAt": "2025-01-01T00:00:00.000Z",
    "adoptions": [...]
  }
]
```

### GET /refuges/:id
Obtener detalle de un refugio.

**Response:** `200 OK`
```json
{
  "id": "uuid",
  "name": "Refugio Esperanza",
  "description": "...",
  "address": "...",
  "capacity": 50,
  "occupied": 35,
  "region": "Metropolitana",
  "services": ["veterinaria", "adopcion"],
  "adoptions": [
    {
      "id": "uuid",
      "petName": "Luna",
      "petType": "perro",
      "status": "available"
    }
  ]
}
```

### GET /refuges/:id/statistics
Obtener estadísticas de un refugio.

**Response:** `200 OK`
```json
{
  "refuge": {
    "id": "uuid",
    "name": "Refugio Esperanza",
    "capacity": 50,
    "occupied": 35
  },
  "adoptions": {
    "total": 120,
    "adopted": 100,
    "available": 20
  },
  "occupancyRate": 70.0
}
```

---

## Adoptions Module

### GET /adoptions
Listar adopciones.

**Query Parameters:**
- `refugeId` (opcional): Filtrar por refugio
- `status` (opcional): Filtrar por estado (available, pending, adopted, cancelled)
- `petType` (opcional): Filtrar por tipo (perro, gato, etc.)

**Response:** `200 OK`
```json
[
  {
    "id": "uuid",
    "petName": "Luna",
    "petType": "perro",
    "petBreed": "Labrador",
    "petAge": 3,
    "petGender": "hembra",
    "description": "Perrita muy cariñosa y juguetona",
    "imageUrl": "https://...",
    "status": "available",
    "adoptedBy": null,
    "adoptedAt": null,
    "refugeId": "uuid",
    "createdAt": "2025-01-01T00:00:00.000Z",
    "updatedAt": "2025-01-01T00:00:00.000Z",
    "refuge": {
      "id": "uuid",
      "name": "Refugio Esperanza",
      "region": "Metropolitana",
      "phone": "+56912345678",
      "email": "contacto@esperanza.cl"
    }
  }
]
```

### GET /adoptions/:id
Obtener detalle de una adopción.

**Response:** `200 OK`
```json
{
  "id": "uuid",
  "petName": "Luna",
  "petType": "perro",
  "petBreed": "Labrador",
  "petAge": 3,
  "description": "...",
  "status": "available",
  "refuge": {
    "id": "uuid",
    "name": "Refugio Esperanza",
    "address": "...",
    "phone": "..."
  }
}
```

### PATCH /adoptions/:id/adopt
Marcar mascota como adoptada.

**Body:**
```json
{
  "adoptedBy": "Usuario XYZ"
}
```

**Response:** `200 OK`
```json
{
  "id": "uuid",
  "petName": "Luna",
  "status": "adopted",
  "adoptedBy": "Usuario XYZ",
  "adoptedAt": "2025-01-15T10:30:00.000Z"
}
```

---

## Chat Module (Refu)

### POST /chat/refu
Enviar mensaje al chatbot Refu.

**Body:**
```json
{
  "message": "Me siento ansioso",
  "context": [
    {
      "role": "user",
      "content": "Hola"
    },
    {
      "role": "assistant",
      "content": "Hola, ¿cómo estás?"
    }
  ]
}
```

**Response:** `200 OK`
```json
{
  "reply": "Entiendo que te sientas ansioso. Respiremos juntos...",
  "provider": "llm-local",
  "metrics": {
    "latencyMs": 1234,
    "provider": "llm-local",
    "model": "llama3.2:3b-instruct-q4_K_M",
    "timestamp": "2025-01-15T10:30:00.000Z"
  }
}
```

### POST /chat/message
Alias compatible con frontend legacy.

**Body:** Mismo que `/chat/refu`
**Response:** Mismo que `/chat/refu`

### GET /chat/health
Verificar estado del LLM local.

**Response:** `200 OK`
```json
{
  "status": "ok",
  "latencyMs": 45,
  "model": "llama3.2:3b-instruct-q4_K_M",
  "endpoint": "http://localhost:11434"
}
```

---

## Diary Module

### GET /diary
Listar entradas del diario del usuario autenticado.

**Query Parameters:**
- `mood` (opcional): Filtrar por estado de ánimo
- `startDate` (opcional): Fecha de inicio
- `endDate` (opcional): Fecha de fin

**Response:** `200 OK`
```json
[
  {
    "id": "uuid",
    "title": "Un día tranquilo",
    "content": "Hoy me sentí más calmado...",
    "mood": "calm",
    "score": 8,
    "date": "2025-01-15T00:00:00.000Z",
    "emotions": ["tranquilo", "feliz"],
    "tags": ["trabajo", "familia"]
  }
]
```

### POST /diary
Crear nueva entrada de diario.

**Body:**
```json
{
  "title": "Un día difícil",
  "content": "Hoy fue complicado...",
  "mood": "anxious",
  "score": 4,
  "date": "2025-01-15T00:00:00.000Z",
  "emotions": ["ansioso", "cansado"],
  "tags": ["trabajo"]
}
```

---

## Health Module

### GET /health
Health check del sistema.

**Response:** `200 OK`
```json
{
  "status": "ok",
  "info": {
    "database": {
      "status": "up"
    },
    "ollama": {
      "status": "up"
    }
  },
  "details": {
    "database": {
      "status": "up"
    },
    "ollama": {
      "status": "up",
      "latencyMs": 45,
      "model": "llama3.2:3b-instruct-q4_K_M"
    }
  }
}
```

---

## Códigos de Error

- `200 OK`: Operación exitosa
- `201 Created`: Recurso creado exitosamente
- `400 Bad Request`: Datos inválidos
- `401 Unauthorized`: No autenticado
- `403 Forbidden`: Sin permisos
- `404 Not Found`: Recurso no encontrado
- `500 Internal Server Error`: Error del servidor

**Formato de error:**
```json
{
  "statusCode": 400,
  "message": ["email must be an email"],
  "error": "Bad Request"
}
```

---

**Última actualización**: Noviembre 2025
**Versión**: 1.0.0
