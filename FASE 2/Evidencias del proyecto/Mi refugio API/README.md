# Mi Refugio API

API Backend para el ecosistema Mi Refugio, construida con Node.js, Express y TypeScript.

## Requisitos

- Node.js (v18 o superior)
- PostgreSQL
- Archivo `.env` configurado

## Instalación

1. Instalar dependencias:
```bash
npm install
```

2. Configurar variables de entorno en `.env`:
```env
PORT=3001
DB_USER=tu_usuario
DB_HOST=tu_host
DB_NAME=mirefugio
DB_PASSWORD=tu_password
DB_PORT=5432
```

## Ejecución

### Desarrollo
```bash
npm run dev
```
El servidor se iniciará en `http://localhost:3001` (o el puerto configurado).

### Producción
```bash
npm run build
npm start
```

## Estructura de Endpoints

La API expone los siguientes recursos bajo el prefijo `/api`:

### Auth (`/api/auth`)
- `POST /login`: Autenticación de usuarios (valida contra `web.auth_user`).

### Users (`/api/users`)
- `GET /`: Listar usuarios.
- `POST /`: Crear usuario.
- `PUT /:id`: Actualizar usuario.
- `DELETE /:id`: Eliminar usuario.
**Nota**: Los usuarios se gestionan en el esquema `web` tabla `auth_user` (compartido con Django).

### Chatbot (`/api/chatbot`)
- `GET /`: Listar respuestas.
- `POST /`: Crear respuesta.
- `PUT /:id`: Actualizar respuesta.
- `DELETE /:id`: Eliminar respuesta.

### Resources (`/api/resources`)
- `GET /`: Listar recursos (desde esquema `app`).

## Base de Datos

La API interactúa principalmente con dos esquemas de la base de datos:
- **web**: Para autenticación y usuarios (`web.auth_user`).
- **app**: Para recursos y datos de la aplicación móvil.
