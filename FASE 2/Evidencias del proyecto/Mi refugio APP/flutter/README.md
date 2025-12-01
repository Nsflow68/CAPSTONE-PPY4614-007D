# Mi Refugio APP - Aplicacion Movil Android

**Stack**: Flutter + NestJS + PostgreSQL + Ollama (LLM Local)
**Grupo**: Grupo 6 - Seccion 007D - Duoc UC
**Fecha**: Noviembre 2025

---

## Descripcion

Aplicacion movil Android para acompanamiento emocional con gestion de refugios y adopciones de mascotas.

**Funcionalidades:**
- Chatbot empatico "Refu" con IA local (Ollama)
- Gestion de refugios de animales
- Sistema de adopciones de mascotas
- Diario emocional personal
- Recursos de salud mental

---

## Inicio Rapido

### 1. Configurar Ollama (LLM Local)

```bash
# Instalar desde https://ollama.ai
ollama pull llama3.2:3b-instruct-q4_K_M
curl http://localhost:11434/api/tags
```

### 2. Levantar Backend

```bash
cd flutter/backend/nest
cp .env.example .env
npm install --legacy-peer-deps
npx prisma generate
docker-compose up -d
```

Verificar: http://localhost:3001/api/health

### 3. Ejecutar App Flutter

```bash
cd flutter
flutter pub get
flutter run
```

---

## Estructura

```
Mi refugio APP/
├── flutter/
│   ├── lib/features/
│   │   ├── refuges/      (NUEVO)
│   │   ├── adoptions/    (NUEVO)
│   │   ├── chatbot/      (Chat Refu)
│   │   ├── auth/
│   │   └── diary/
│   └── backend/nest/
│       └── src/
│           ├── refuges/      (NUEVO)
│           ├── adoptions/    (NUEVO)
│           └── chat/refu/    (NUEVO)
├── docs/
│   ├── arquitectura.md
│   ├── api_mobile.md
│   └── guias_visual.md
└── .github/workflows/
```

---

## API Principales

**Base**: http://localhost:3001/api

```
GET    /refuges              # Listar refugios
GET    /adoptions            # Listar adopciones
POST   /chat/refu            # Chat con Refu
GET    /health               # Health check
```

Ver: [docs/api_mobile.md](docs/api_mobile.md)

---

## Comandos Utiles

### Backend
```bash
cd flutter/backend/nest
npm run start:dev          # Hot reload
npx prisma studio          # GUI DB
docker-compose logs -f
```

### Flutter
```bash
flutter run                # Ejecutar
flutter test               # Tests
flutter build apk          # APK
```

---

## Tecnologias

- Flutter 3.24, Riverpod, GoRouter
- NestJS 10, Prisma, PostgreSQL
- Ollama (llama3.2)
- Docker, GitHub Actions

---

## Documentacion

- [Arquitectura](docs/arquitectura.md)
- [API](docs/api_mobile.md)
- [UI/UX](docs/guias_visual.md)
- [Testing](docs/testing_checklist.md)

---

## Notas

1. Ollama debe estar en localhost:11434
2. PostgreSQL via docker-compose
3. Issue conocido: axios/@nestjs/axios (usar npm run start:dev)

---

**Grupo 6 - Seccion 007D - Duoc UC 2025**
