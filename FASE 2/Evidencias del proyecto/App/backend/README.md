# Mi Refugio Backend (NestJS)

Backend modular built with NestJS to power the Mi Refugio wellness application.  
The service exposes secured APIs for authentication, diary entries, resources, analytics, and more, and is prepared for local development, containerisation, and deployment to AWS.

---

## Table of contents
1. [Project structure](#project-structure)
2. [Prerequisites](#prerequisites)
3. [Environment configuration](#environment-configuration)
4. [Install and run locally](#install-and-run-locally)
5. [Available npm scripts](#available-npm-scripts)
6. [API modules and responsibilities](#api-modules-and-responsibilities)
7. [Security hardening](#security-hardening)
8. [Data model](#data-model)
9. [Integration with the Flutter app](#integration-with-the-flutter-app)
10. [Docker and Compose](#docker-and-compose)
11. [AWS deployment summary](#aws-deployment-summary)
12. [Troubleshooting](#troubleshooting)

---

## Project structure
```
src/
 ├─ core/                 # cross-cutting helpers (config, database, middlewares)
 ├─ features/             # domain modules
 │   ├─ auth/             # JWT auth, password recovery
 │   ├─ users/            # profile management
 │   ├─ diary/            # emotional diary CRUD
 │   ├─ resources/        # curated mental health resources
 │   ├─ chatbot/          # chatbot endpoint shell
 │   ├─ emotions/         # emotional analytics endpoints (placeholder)
 │   ├─ donations/        # donations feature shell
 │   └─ analytics/        # usage metrics shell
 ├─ assets/               # static assets (placeholders)
 └─ main.ts               # bootstrap entry point
```

Supporting files:
- `docker-compose.yml` lifts Postgres, Redis, and the API container for local runs.
- `Dockerfile` builds the production image (multi-stage).
- `docs/aws-deployment.md` contains step-by-step instructions to publish on AWS.
- `rds-combined-ca-bundle.pem` is the optional Amazon RDS CA bundle for SSL connections.

---

## Prerequisites
- Node.js **20** or newer and npm (ships with Node).
- Nest CLI (`npm install -g @nestjs/cli`) is optional but handy.
- Docker and Docker Compose if you plan to run the stack locally in containers.
- AWS CLI v2 configured with your credentials for deployment tasks.

---

## Environment configuration
1. Copy the example env file and adjust values:
   ```bash
   cp .env.example .env
   ```
2. Update the following keys:
   | Variable | Description |
   | --- | --- |
   | `PORT` | API port (defaults to `3000`). |
   | `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASS`, `DB_NAME` | Postgres connection parameters. |
   | `DB_SSL` | `true` for AWS RDS; `false` for local Postgres. |
   | `JWT_SECRET` | Secret used to sign access tokens. |
   | `JWT_EXPIRES_IN` | Token lifetime (example: `1d`). |
   | `CORS_ORIGIN` | Comma separated list of front-end origins. |

3. Place `rds-combined-ca-bundle.pem` in the project root if you must validate Amazon RDS certificates.

---

## Install and run locally
```bash
npm install          # Install dependencies
npm run start:dev    # Run in watch mode (hot reload)
```
The API is available at `http://localhost:3000` and exposes Swagger-like JSON responses (no UI yet).

### Using docker compose
```bash
docker-compose up --build
```
This spins up:
- Postgres 16 (port 5432)
- Redis 7 (port 6379)
- Nest API (port 3000)

Stop everything with `docker-compose down`.

---

## Available npm scripts
| Script | Purpose |
| --- | --- |
| `npm run start` | Start the API (no watch). |
| `npm run start:dev` | Start with live reload. |
| `npm run start:prod` | Run compiled JS from `dist/`. |
| `npm run build` | Compile Typescript to `dist/`. |
| `npm run lint` | Run ESLint on `src/**/*.ts`. |
| `npm run test` | (Placeholder) add unit tests here. |

---

## API modules and responsibilities
- **AuthModule**: Email/password registration, JWT login, password reset (token-based). Uses bcrypt, JWT, throttling, and Helmet.
- **UsersModule**: Exposes `GET /users/me` and `PATCH /users/me` for profile updates.
- **DiaryModule**: CRUD endpoints for diary entries, secured with JWT and linked to the authenticated user.
- **ResourcesModule**: Returns curated mental-health resources. Seeds default records if the table is empty and supports remote logos.
- **Emotions / Chatbot / Exercises / Donations / Analytics**: Currently provide health endpoints and scaffolding for future work.

---

## Security hardening
- `helmet` middleware adds common HTTP headers.
- Global `ValidationPipe` sanitises and enforces DTO contracts.
- `@nestjs/throttler` limits excessive requests (default 100 requests per minute across the API).
- JWT auth guard protects user-specific routes (`/diary`, `/users/me`).
- Password hashes stored with `bcrypt` (salted, 12 rounds).
- Password reset workflow generates short-lived tokens stored hashed in the database.

> Replace `synchronize: true` with TypeORM migrations before moving to production environments.

---

## Data model
Implemented entities (TypeORM):
- `User` (`users` table) with profile fields, password hash, optional avatar URL, and reset token metadata.
- `DiaryEntry` (`diary_entries` table) related to `User` with title, mood, body, location, and word count.
- `Resource` (`resources` table) used to seed mental health resources (title, subtitle, category, contact details).

---

## Integration with the Flutter app
- The mobile app uses `MI_REFUGIO_API` (see `lib/core/config/app_config.dart`) to target the API.
  ```bash
  flutter run --dart-define MI_REFUGIO_API=http://10.0.2.2:3000    # Android emulator
  flutter build apk --dart-define MI_REFUGIO_API=https://api.example.com
  ```
- Auth module returns `{ accessToken, user }`. Store the token in the app and send headers:
  ```http
  Authorization: Bearer <token>
  ```
- Diary routes:
  - `GET /diary` -> user entries (ordered by date desc)
  - `POST /diary` -> create entry (`title`, `body`, `mood`, `createdAt`, optional `location`)
  - `PATCH /diary/:id` -> update entry
  - `DELETE /diary/:id` -> remove entry (returns removed entry for undo UX)

---

## Docker and Compose
### Build the production image
```bash
docker build -t mirefugio-backend .
```
### Run image manually
```bash
docker run --rm -p 3000:3000 \
  -e PORT=3000 \
  -e DB_HOST=db \
  -e DB_PORT=5432 \
  -e DB_USER=postgres \
  -e DB_PASS=postgres \
  -e DB_NAME=mirefugio \
  -e DB_SSL=false \
  -e JWT_SECRET=change-me \
  mirefugio-backend
```

Refer to `docker-compose.yml` for a ready-to-use multi-container setup.

---

## AWS deployment summary
1. Build and test locally: `npm run build`.
2. Create an image and push to Amazon ECR (`docs/aws-deployment.md` contains exact commands).
3. Provision infrastructure (suggested): ECS Fargate service + Application Load Balancer + Amazon RDS Postgres + ElastiCache Redis.
4. Configure secrets (`DB_*`, `JWT_SECRET`, etc.) via AWS Secrets Manager or SSM Parameter Store.
5. Enable TLS (ACM certificate) at the load balancer level.
6. Monitor with CloudWatch metrics and alarms.

See `docs/aws-deployment.md` for the detailed checklist including IAM permissions, networking, and scaling considerations.

---

## Troubleshooting
| Symptom | Fix |
| --- | --- |
| `ECONNREFUSED` when connecting to Postgres | Confirm env vars and that the database is reachable (firewalls / security groups). |
| `LocaleDataException` from Flutter | Ensure the app is compiled with `--dart-define MI_REFUGIO_API` and the backend returns valid data. |
| `JWT` errors | Verify `JWT_SECRET` matches between environments and tokens are not expired (`JWT_EXPIRES_IN`). |
| API 500 during password reset | Check Redis/Postgres connectivity and confirm `.env` tokens are present. |
| TypeORM migrations pending | Currently using `synchronize=true` for development; swap to migrations before production. |

---

## Contributing
1. Fork and clone the repository.
2. Create a feature branch: `git checkout -b feature/my-feature`.
3. Install dependencies and run `npm run lint` before committing.
4. Submit a pull request describing the change, tests, and any migrations.

---

## License
Internal project for Mi Refugio. Redistribution outside the organisation is not permitted without explicit authorisation.
