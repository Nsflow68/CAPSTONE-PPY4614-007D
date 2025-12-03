# Mi Refugio – Guia de trabajo (Fase 2)

Contexto rapido del repositorio de evidencias. Usa este archivo para arrancar backend y app, y saber que cambios ya estan listos.

## Que hay aqui
- `flutter/` app Flutter principal (Riverpod + GoRouter).
- `backend/nest/` Backend NestJS + Prisma + PostgreSQL (RDS).
- `GUIA_USUARIO.md` recorrido funcional y plan operativo.
- `docs/` Documentacion tecnica y de API.

## Cambios mas recientes (app)
- **Auth**: Login con Google funcional, Registro de usuarios con validacion, Login con credenciales. Redireccion automatica al Home.
- **Diary**: Estados con Result/Failure y vistas Empty/Error dedicadas. UI consumiendo el estado del notifier.
- **Chatbot**: Pantalla redisenada (burbujas, prompts rapidos, banner de error, lista de mensajes persiste).
- **Theming y branding**: Nuevo sistema de colores (AppColors), ThemeData armonizado, splash nativo.

## Estado de backend
- **NestJS (Principal)**: Corriendo en puerto 3001.
- **Modulos**: Auth (Google + Credenciales), Users, Diary, Chatbot (Ollama/Mock), Health.
- **Base de Datos**: PostgreSQL en AWS RDS.

## Como ejecutar

### Backend NestJS
```powershell
cd "FASE 2/Evidencias del proyecto/Mi refugio APP/backend/nest"
npm install
# Asegurate de tener el .env configurado
npm run start:dev      # expone http://localhost:3001/api
```

### App Flutter
```powershell
cd "FASE 2/Evidencias del proyecto/Mi refugio APP/flutter"
flutter pub get
flutter run -d emulator-5554
```
Nota: La app ya esta configurada para conectar a `http://10.0.2.2:3001/api` por defecto.

## Documentacion a consultar
- `docs/api_mobile.md` Documentacion de endpoints.
- `GUIA_USUARIO.md` recorrido funcional.

Mantener este README actualizado al cierre de cada entrega. 
