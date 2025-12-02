# Arquitectura - Mi Refugio App

Documentación técnica de la arquitectura del sistema Mi Refugio.

## Visión General

Mi Refugio es una aplicación móvil multiplataforma (Android/iOS) construida con Flutter, respaldada por un backend REST API en NestJS con base de datos PostgreSQL.

### Diagrama de Alto Nivel

```
┌──────────────────────────────────────────────────────────┐
│                     CAPA DE PRESENTACIÓN                  │
│                                                           │
│  ┌─────────────────────────────────────────────────────┐ │
│  │           Flutter App (Android/iOS)                 │ │
│  │                                                     │ │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐         │ │
│  │  │  Pages   │  │ Widgets  │  │ Providers│         │ │
│  │  └──────────┘  └──────────┘  └──────────┘         │ │
│  │                                                     │ │
│  │  State Management: Riverpod                        │ │
│  │  Routing: GoRouter                                 │ │
│  └─────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────┘
                            │
                            │ HTTP/REST (JSON)
                            ▼
┌──────────────────────────────────────────────────────────┐
│                    CAPA DE APLICACIÓN                     │
│                                                           │
│  ┌─────────────────────────────────────────────────────┐ │
│  │              Backend NestJS                         │ │
│  │                                                     │ │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐         │ │
│  │  │Controllers│ │ Services │  │  Guards  │         │ │
│  │  └──────────┘  └──────────┘  └──────────┘         │ │
│  │                                                     │ │
│  │  Modules: Auth, Users, Diary, Wellness, etc.       │ │
│  └─────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────┘
                            │
                            │ TypeORM
                            ▼
┌──────────────────────────────────────────────────────────┐
│                    CAPA DE DATOS                          │
│                                                           │
│  ┌─────────────────────────────────────────────────────┐ │
│  │         PostgreSQL (AWS RDS)                        │ │
│  │                                                     │ │
│  │  Schema: app                                        │ │
│  │  Tables: users, diary_entries, wellness_logs, etc. │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                           │
│  ┌─────────────────────────────────────────────────────┐ │
│  │         Ollama (LLM - Opcional)                     │ │
│  │  Model: llama3.2:3b-instruct-q4_K_M                 │ │
│  └─────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────┘
```

---

## Arquitectura Frontend (Flutter)

### Estructura de Carpetas

```
flutter/lib/
├── core/                           # Configuración y servicios globales
│   ├── config/
│   │   └── app_config.dart        # Configuración de la app
│   ├── router/
│   │   └── app_router.dart        # Configuración de GoRouter
│   ├── services/
│   │   ├── api_service.dart       # Cliente HTTP
│   │   └── notification_service.dart
│   └── theme/
│       └── app_theme.dart         # Tema de la aplicación
│
├── features/                       # Módulos por funcionalidad
│   ├── auth/                      # Autenticación
│   │   ├── application/
│   │   │   ├── auth_provider.dart
│   │   │   └── auth_state.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── login_page.dart
│   │       │   └── signup_page.dart
│   │       └── widgets/
│   │
│   ├── diary/                     # Diario emocional
│   ├── wellness/                  # Bienestar
│   ├── rewards/                   # Recompensas
│   └── ...
│
├── shared/                        # Código compartido
│   ├── constants/
│   │   └── app_colors.dart       # Colores de la app
│   ├── models/                   # Modelos compartidos
│   ├── utils/                    # Utilidades
│   └── widgets/                  # Widgets reutilizables
│
└── main.dart                     # Entry point
```

### Patrón de Arquitectura

**Clean Architecture + Feature-First**

Cada feature sigue la estructura:

```
feature/
├── application/     # Lógica de negocio (Providers, State)
├── data/           # Acceso a datos (Repositories, Models)
└── presentation/   # UI (Pages, Widgets)
```

**Ventajas:**
- Separación de responsabilidades
- Testabilidad
- Escalabilidad
- Reutilización de código

### State Management (Riverpod)

**Providers:**
```dart
// Provider de estado
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

// Provider de repositorio
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(apiServiceProvider));
});
```

**Estados:**
```dart
sealed class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class Authenticated extends AuthState {
  final User user;
  Authenticated(this.user);
}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
```

### Navegación (GoRouter)

```dart
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
    // ...
  ],
  redirect: (context, state) {
    // Lógica de redirección basada en autenticación
  },
);
```

### Comunicación con Backend

**ApiService:**
```dart
class ApiService {
  final String baseUrl;
  final http.Client client;

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    final response = await client.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return jsonDecode(response.body);
  }
}
```

**Repository:**
```dart
class AuthRepository {
  final ApiService apiService;

  Future<User> register(RegisterDto dto) async {
    final response = await apiService.post('/auth/register', dto.toJson());
    return User.fromJson(response);
  }
}
```

---

## Arquitectura Backend (NestJS)

### Estructura de Carpetas

```
backend_real/src/
├── modules/                        # Módulos de negocio
│   ├── auth/
│   │   ├── dto/
│   │   │   ├── login.dto.ts
│   │   │   └── register.dto.ts
│   │   ├── auth.controller.ts
│   │   ├── auth.service.ts
│   │   └── auth.module.ts
│   │
│   ├── users/
│   │   ├── entities/
│   │   │   └── user.entity.ts
│   │   ├── users.controller.ts
│   │   ├── users.service.ts
│   │   └── users.module.ts
│   │
│   ├── diary/
│   ├── wellness/
│   └── ...
│
├── config/                        # Configuración
│   └── typeorm.config.ts
│
├── common/                        # Código compartido
│   ├── filters/
│   │   └── all-exceptions.filter.ts
│   └── utils/
│
└── main.ts                       # Entry point
```

### Patrón de Arquitectura

**Modular Architecture + Dependency Injection**

Cada módulo encapsula:
- **Controller**: Manejo de requests HTTP
- **Service**: Lógica de negocio
- **Repository**: Acceso a datos (TypeORM)
- **DTO**: Data Transfer Objects
- **Entity**: Modelos de base de datos

### Módulos Principales

#### Auth Module
```typescript
@Module({
  imports: [UsersModule],
  controllers: [AuthController],
  providers: [AuthService],
})
export class AuthModule {}
```

**Responsabilidades:**
- Registro de usuarios
- Login con credenciales
- Login con Google
- Generación de tokens

#### Users Module
```typescript
@Module({
  imports: [TypeOrmModule.forFeature([User])],
  controllers: [UsersController],
  providers: [UsersService],
  exports: [UsersService],
})
export class UsersModule {}
```

**Responsabilidades:**
- CRUD de usuarios
- Validación de RUT
- Gestión de perfiles

#### Diary Module
**Responsabilidades:**
- Registro de entradas emocionales
- Consulta de historial
- Análisis de patrones

#### Wellness Module
**Responsabilidades:**
- Seguimiento de hidratación
- Registro de nutrición
- Gestión de ejercicios de mindfulness

### Base de Datos (PostgreSQL)

**Schema:** `app`

**Tablas Principales:**

```sql
-- Usuarios
CREATE TABLE app.users (
  id TEXT PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  username VARCHAR(255) UNIQUE,
  name VARCHAR(255),
  password TEXT NOT NULL,
  rut VARCHAR(20) UNIQUE NOT NULL,
  birthdate DATE,
  gender VARCHAR(50),
  role VARCHAR(50) DEFAULT 'user',
  "createdAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Entradas de diario
CREATE TABLE app.diary_entries (
  id SERIAL PRIMARY KEY,
  user_id TEXT REFERENCES app.users(id),
  mood VARCHAR(50),
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Logs de bienestar
CREATE TABLE app.wellness_logs (
  id SERIAL PRIMARY KEY,
  user_id TEXT REFERENCES app.users(id),
  type VARCHAR(50), -- 'hydration', 'nutrition', 'mindfulness'
  value JSONB,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### TypeORM Entities

```typescript
@Entity({ schema: 'app', name: 'users' })
export class User {
  @PrimaryColumn('text')
  id: string;

  @Column({ unique: true })
  email: string;

  @Column({ unique: true })
  rut: string;

  @Column({ select: false })
  password: string;

  @Column({ type: 'timestamp', nullable: true })
  createdAt: Date;

  @BeforeInsert()
  setTimestamps() {
    const now = new Date();
    this.createdAt = now;
    this.updatedAt = now;
  }
}
```

---

## Flujo de Datos

### Registro de Usuario

```
┌─────────┐     1. POST /auth/register      ┌────────────┐
│ Flutter │ ──────────────────────────────► │  NestJS    │
│   App   │                                 │  Backend   │
└─────────┘                                 └────────────┘
     │                                            │
     │                                            │ 2. Validate DTO
     │                                            │
     │                                            ▼
     │                                      ┌────────────┐
     │                                      │   Auth     │
     │                                      │  Service   │
     │                                      └────────────┘
     │                                            │
     │                                            │ 3. Generate UUID
     │                                            │ 4. Hash password (removed)
     │                                            │
     │                                            ▼
     │                                      ┌────────────┐
     │                                      │   Users    │
     │                                      │  Service   │
     │                                      └────────────┘
     │                                            │
     │                                            │ 5. Validate RUT
     │                                            │ 6. Check duplicates
     │                                            │
     │                                            ▼
     │                                      ┌────────────┐
     │                                      │ PostgreSQL │
     │                                      │    (RDS)   │
     │                                      └────────────┘
     │                                            │
     │                                            │ 7. INSERT user
     │                                            │
     │      8. Return user data                   │
     │ ◄──────────────────────────────────────────┘
     │
     │ 9. Update state (Authenticated)
     │ 10. Navigate to /home
     ▼
```

### Consulta de Diario

```
┌─────────┐     1. GET /diary?userId=xxx    ┌────────────┐
│ Flutter │ ──────────────────────────────► │  NestJS    │
│   App   │                                 │  Backend   │
└─────────┘                                 └────────────┘
     │                                            │
     │                                            │ 2. Verify auth
     │                                            │
     │                                            ▼
     │                                      ┌────────────┐
     │                                      │   Diary    │
     │                                      │  Service   │
     │                                      └────────────┘
     │                                            │
     │                                            │ 3. Query DB
     │                                            │
     │                                            ▼
     │                                      ┌────────────┐
     │                                      │ PostgreSQL │
     │                                      └────────────┘
     │                                            │
     │      4. Return entries                     │
     │ ◄──────────────────────────────────────────┘
     │
     │ 5. Update state (DiaryLoaded)
     │ 6. Render UI
     ▼
```

---

## Seguridad

### Autenticación

**Método actual**: Token simple (Base64 del user ID)

**Mejora recomendada**: JWT (JSON Web Tokens)

```typescript
// Generar JWT
const token = jwt.sign(
  { userId: user.id, email: user.email },
  process.env.JWT_SECRET,
  { expiresIn: '7d' }
);

// Verificar JWT
const decoded = jwt.verify(token, process.env.JWT_SECRET);
```

### Validación de Datos

**Backend (NestJS):**
```typescript
// DTO con class-validator
export class RegisterDto {
  @IsEmail()
  email: string;

  @MinLength(6)
  password: string;

  @Matches(/^\d{7,8}-[\dkK]$/)
  rut: string;
}
```

**Frontend (Flutter):**
```dart
// Validación en formularios
validator: (value) {
  if (value == null || value.isEmpty) {
    return 'Campo requerido';
  }
  if (!RutValidator.validate(value)) {
    return 'RUT inválido';
  }
  return null;
}
```

### Protección de Rutas

```typescript
@Controller('users')
@UseGuards(AuthGuard)
export class UsersController {
  @Get('profile')
  getProfile(@Request() req) {
    return req.user;
  }
}
```

---

## Despliegue

### Backend (NestJS)

**Producción:**
```powershell
npm run build
npm run start:prod
```

**Variables de entorno requeridas:**
- `DB_HOST`
- `DB_PORT`
- `DB_USER`
- `DB_PASSWORD`
- `DB_NAME`
- `PORT`

**Recomendaciones:**
- Usar PM2 para gestión de procesos
- Configurar HTTPS con certificado SSL
- Implementar rate limiting
- Configurar CORS apropiadamente

### Flutter App

**Android:**
```powershell
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

**iOS:**
```powershell
flutter build ios --release
```

**Configuración de producción:**
- Actualizar `apiBaseUrl` en `app_config.dart`
- Configurar signing keys
- Generar iconos y splash screens
- Configurar permisos en AndroidManifest.xml / Info.plist

---

## Escalabilidad

### Consideraciones

**Backend:**
- Implementar caché (Redis)
- Separar servicios en microservicios si crece
- Usar load balancer
- Implementar message queue (RabbitMQ/Kafka)

**Base de Datos:**
- Índices en columnas frecuentemente consultadas
- Particionamiento de tablas grandes
- Read replicas para consultas
- Connection pooling

**Frontend:**
- Lazy loading de features
- Caché de imágenes
- Paginación de listas largas
- Optimización de builds

---

## Monitoreo y Logs

### Backend

```typescript
// Logger de NestJS
private readonly logger = new Logger(AuthService.name);

this.logger.log('User registered successfully');
this.logger.error('Failed to register user', error.stack);
```

### Frontend

```dart
// Logging en Flutter
print('[AuthProvider] Login attempt for ${email}');
debugPrint('[ERROR] ${error.toString()}');
```

**Recomendaciones:**
- Implementar Sentry para error tracking
- Usar Winston/Bunyan para logs estructurados
- Configurar log levels (debug, info, warn, error)
- Almacenar logs en servicio centralizado

---

## Testing

### Backend

```typescript
// Unit test
describe('AuthService', () => {
  it('should register a new user', async () => {
    const dto = { email: 'test@test.com', password: '123456', ... };
    const result = await service.register(dto);
    expect(result).toBeDefined();
    expect(result.email).toBe(dto.email);
  });
});
```

### Frontend

```dart
// Widget test
testWidgets('Login page shows email and password fields', (tester) async {
  await tester.pumpWidget(const MaterialApp(home: LoginPage()));
  
  expect(find.byType(TextField), findsNWidgets(2));
  expect(find.text('Email'), findsOneWidget);
  expect(find.text('Contraseña'), findsOneWidget);
});
```

---

**Última actualización**: Diciembre 2025
