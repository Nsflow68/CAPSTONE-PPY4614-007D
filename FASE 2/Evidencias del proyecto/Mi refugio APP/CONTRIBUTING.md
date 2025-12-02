# Guía de Contribución - Mi Refugio App

Gracias por tu interés en contribuir a Mi Refugio App. Este documento describe cómo preparar tu entorno, el flujo de trabajo Git, y las convenciones del proyecto.

## Tabla de Contenidos

1. [Preparación del Entorno](#preparación-del-entorno)
2. [Flujo de Trabajo Git](#flujo-de-trabajo-git)
3. [Convenciones de Código](#convenciones-de-código)
4. [Proceso de Pull Request](#proceso-de-pull-request)
5. [Estructura del Proyecto](#estructura-del-proyecto)

---

## Preparación del Entorno

### Requisitos Previos

Antes de contribuir, asegúrate de tener instalado:

- Git
- Flutter SDK (3.24 o superior)
- Android Studio + Android SDK
- Node.js (20.x o superior)
- Un editor de código (VS Code recomendado)

**Guía completa**: Ver `INSTALL_WINDOWS.md`

### Configuración Inicial

```powershell
# 1. Fork del repositorio en GitHub

# 2. Clonar tu fork
git clone https://github.com/TU-USUARIO/CAPSTONE-PPY4614-007D.git
cd CAPSTONE-PPY4614-007D

# 3. Agregar repositorio original como upstream
git remote add upstream https://github.com/USUARIO-ORIGINAL/CAPSTONE-PPY4614-007D.git

# 4. Navegar a Mi Refugio App
cd "FASE 2\Evidencias del proyecto\Mi refugio APP"

# 5. Instalar dependencias
cd backend_real
npm install

cd ../flutter
flutter pub get
```

---

## Flujo de Trabajo Git

### Antes de Empezar

**SIEMPRE** verificar el estado antes de hacer cambios:

```powershell
# Ver rama actual
git branch

# Ver estado del repositorio
git status

# Actualizar desde upstream
git fetch upstream
git merge upstream/main
```

### Crear una Rama de Trabajo

```powershell
# Asegurarse de estar en main
git checkout main

# Actualizar main
git pull upstream main

# Crear rama descriptiva
git checkout -b feature/nombre-descriptivo

# Ejemplos de nombres de rama:
# feature/add-meditation-timer
# fix/registration-error-500
# docs/update-installation-guide
# refactor/auth-module-structure
```

### Hacer Cambios

```powershell
# 1. Hacer cambios SOLO en:
#    - flutter/ (app móvil)
#    - backend_real/ (backend NestJS)
#    - docs/ (documentación)

# 2. Verificar qué cambió
git status

# 3. Ver diferencias
git diff <archivo>

# 4. Añadir cambios selectivamente
git add flutter/lib/features/auth/...
git add backend_real/src/modules/...

# NUNCA hacer git add . sin revisar git status primero
```

### Hacer Commits

**Formato de mensaje**: `<tipo>: <descripción>`

**Tipos válidos:**
- `feat`: Nueva funcionalidad
- `fix`: Corrección de bug
- `docs`: Cambios en documentación
- `style`: Formato (no afecta funcionalidad)
- `refactor`: Refactorización
- `test`: Tests
- `chore`: Mantenimiento (dependencias, config)
- `perf`: Mejoras de rendimiento

**Ejemplos:**
```powershell
git commit -m "feat: agregar temporizador de meditación"
git commit -m "fix: resolver error 500 en registro de usuarios"
git commit -m "docs: actualizar guía de instalación para Windows"
git commit -m "refactor: migrar auth provider a Riverpod 2.0"
git commit -m "test: agregar tests unitarios para AuthService"
git commit -m "chore: actualizar dependencias de Flutter a 3.24"
```

**Commits deben ser:**
- Atómicos (un cambio lógico por commit)
- Descriptivos (explicar QUÉ y POR QUÉ, no CÓMO)
- En español
- Sin emojis

### Subir Cambios

```powershell
# Subir rama a tu fork
git push origin feature/nombre-descriptivo

# Si necesitas actualizar la rama después de cambios
git push --force-with-lease origin feature/nombre-descriptivo
```

---

## Convenciones de Código

### Flutter (Dart)

#### Análisis Estático

Antes de cada commit:

```powershell
cd flutter
flutter analyze
# Debe mostrar: "No issues found!"
```

#### Formato de Código

```powershell
# Formatear código automáticamente
dart format lib/

# Verificar formato
dart format --set-exit-if-changed lib/
```

#### Convenciones

- Usar `const` siempre que sea posible
- Nombres de clases en PascalCase: `AuthProvider`
- Nombres de archivos en snake_case: `auth_provider.dart`
- Nombres de variables en camelCase: `userName`
- Constantes en lowerCamelCase: `apiBaseUrl`

**Estructura de Features:**
```
lib/features/nombre_feature/
├── application/        # Providers, state management
├── data/              # Repositories, models, data sources
└── presentation/      # Pages, widgets
```

#### Imports

Orden de imports:
```dart
// 1. Dart core
import 'dart:async';

// 2. Flutter
import 'package:flutter/material.dart';

// 3. Paquetes externos
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 4. Imports internos
import 'package:mi_refugio_app/core/...';
import 'package:mi_refugio_app/features/...';
```

### Backend (NestJS/TypeScript)

#### Linting

```powershell
cd backend_real
npm run lint
```

#### Convenciones

- Nombres de clases en PascalCase: `AuthService`
- Nombres de archivos en kebab-case: `auth.service.ts`
- Nombres de variables en camelCase: `userName`
- Interfaces con prefijo I: `IUser`

**Estructura de Módulos:**
```
src/modules/nombre_modulo/
├── dto/               # Data Transfer Objects
├── entities/          # TypeORM entities
├── nombre.controller.ts
├── nombre.service.ts
└── nombre.module.ts
```

---

## Proceso de Pull Request

### Antes de Crear el PR

**Checklist:**

- [ ] Código formateado (`dart format` / `npm run lint`)
- [ ] Análisis estático sin errores (`flutter analyze`)
- [ ] Tests pasan (si existen)
- [ ] Backend compila (`npm run build`)
- [ ] App Flutter compila (`flutter build apk --debug`)
- [ ] Funcionalidad probada manualmente
- [ ] Commits siguen convención
- [ ] Rama actualizada con main

```powershell
# Actualizar rama con main
git checkout main
git pull upstream main
git checkout feature/tu-rama
git rebase main

# Si hay conflictos, resolverlos y continuar
git add <archivos-resueltos>
git rebase --continue
```

### Crear Pull Request

1. Ir a GitHub (tu fork)
2. Click en "Compare & pull request"
3. Seleccionar:
   - Base repository: `USUARIO-ORIGINAL/CAPSTONE-PPY4614-007D`
   - Base branch: `main`
   - Head repository: `TU-USUARIO/CAPSTONE-PPY4614-007D`
   - Compare branch: `feature/tu-rama`

4. Título descriptivo:
   ```
   feat: Agregar temporizador de meditación
   ```

5. Descripción detallada:
   ```markdown
   ## Descripción
   Implementa un temporizador configurable para sesiones de meditación.

   ## Cambios
   - Nuevo widget `MeditationTimer` en `features/wellness`
   - Servicio de notificaciones para alertas
   - Persistencia de configuración en SharedPreferences

   ## Testing
   - Probado en emulador Android API 33
   - Verificado que las notificaciones funcionan
   - Confirmado que la configuración persiste

   ## Screenshots
   [Adjuntar capturas si aplica]

   ## Checklist
   - [x] Código formateado
   - [x] flutter analyze sin errores
   - [x] Probado manualmente
   - [x] Documentación actualizada
   ```

### Revisión de Código

- Responder a comentarios de revisión
- Hacer cambios solicitados en la misma rama
- Push automáticamente actualiza el PR

```powershell
# Hacer cambios solicitados
git add <archivos>
git commit -m "fix: aplicar sugerencias de code review"
git push origin feature/tu-rama
```

### Después del Merge

```powershell
# Actualizar main local
git checkout main
git pull upstream main

# Eliminar rama local
git branch -d feature/tu-rama

# Eliminar rama remota
git push origin --delete feature/tu-rama
```

---

## Estructura del Proyecto

### Flutter App

```
flutter/
├── lib/
│   ├── core/                  # Configuración global
│   │   ├── config/           # App config, environment
│   │   ├── router/           # GoRouter configuration
│   │   ├── services/         # API service, notifications
│   │   └── theme/            # Theme data, colors
│   │
│   ├── features/             # Módulos por funcionalidad
│   │   ├── auth/            # Autenticación
│   │   ├── diary/           # Diario emocional
│   │   ├── wellness/        # Bienestar (hidratación, nutrición, mindfulness)
│   │   ├── rewards/         # Sistema de recompensas
│   │   └── ...
│   │
│   ├── shared/              # Código compartido
│   │   ├── constants/       # Constantes (colors, strings)
│   │   ├── models/          # Modelos de datos
│   │   ├── utils/           # Utilidades
│   │   └── widgets/         # Widgets reutilizables
│   │
│   └── main.dart            # Entry point
│
├── assets/                  # Recursos (imágenes, audios)
├── test/                    # Tests
└── pubspec.yaml             # Dependencias
```

### Backend NestJS

```
backend_real/
├── src/
│   ├── modules/             # Módulos de negocio
│   │   ├── auth/           # Autenticación
│   │   ├── users/          # Usuarios
│   │   ├── diary/          # Diario
│   │   └── ...
│   │
│   ├── config/             # Configuración (TypeORM, etc)
│   ├── common/             # Utilidades compartidas
│   └── main.ts             # Entry point
│
├── test/                   # Tests
└── package.json            # Dependencias
```

---

## Convenciones Específicas del Proyecto

### Features en Flutter

Cada feature debe seguir esta estructura:

```
features/nombre_feature/
├── application/
│   ├── nombre_provider.dart       # Riverpod provider
│   └── nombre_state.dart          # Estados (loading, success, error)
│
├── data/
│   ├── models/
│   │   └── nombre_model.dart      # Modelos de datos
│   └── repositories/
│       └── nombre_repository.dart  # Lógica de datos
│
└── presentation/
    ├── pages/
    │   └── nombre_page.dart        # Pantallas
    └── widgets/
        └── nombre_widget.dart      # Widgets específicos
```

### Módulos en NestJS

Cada módulo debe tener:

```typescript
// nombre.module.ts
@Module({
  imports: [TypeOrmModule.forFeature([Entity])],
  controllers: [NombreController],
  providers: [NombreService],
  exports: [NombreService],
})
export class NombreModule {}
```

---

## Preguntas Frecuentes

**¿Puedo trabajar directamente en main?**
No. Siempre crear una rama de trabajo.

**¿Cuántos commits debe tener un PR?**
Los necesarios. Preferir commits atómicos pero no fragmentar excesivamente.

**¿Qué hago si mi rama está desactualizada?**
```powershell
git checkout main
git pull upstream main
git checkout feature/tu-rama
git rebase main
```

**¿Puedo modificar carpetas fuera de Mi Refugio App?**
No. Solo modificar `flutter/`, `backend_real/` y `docs/`.

**¿Cómo pruebo mis cambios?**
1. Backend: `npm run start:dev`
2. Flutter: `flutter run`
3. Probar manualmente en emulador

---

## Recursos Adicionales

- [Flutter Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [NestJS Documentation](https://docs.nestjs.com/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Git Best Practices](https://git-scm.com/book/en/v2)

---

**Última actualización**: Diciembre 2025
