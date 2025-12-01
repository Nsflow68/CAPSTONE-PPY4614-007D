# Testing Checklist - Mi Refugio APP

## Backend (NestJS)

### Unit Tests

#### Auth Module
- [ ] AuthService.signup() crea usuario correctamente
- [ ] AuthService.signup() falla con email duplicado
- [ ] AuthService.login() retorna token con credenciales válidas
- [ ] AuthService.login() falla con credenciales inválidas
- [ ] JWT token contiene userId y email correcto

#### Refuges Module
- [ ] RefugesService.findAll() retorna lista de refugios
- [ ] RefugesService.findAll() filtra por región correctamente
- [ ] RefugesService.findOne() retorna refugio por ID
- [ ] RefugesService.findOne() lanza NotFoundException si no existe
- [ ] RefugesService.create() crea refugio con datos válidos
- [ ] RefugesService.update() actualiza refugio existente
- [ ] RefugesService.getStatistics() calcula ocupación correctamente

#### Adoptions Module
- [ ] AdoptionsService.findAll() retorna lista de adopciones
- [ ] AdoptionsService.findAll() filtra por refugeId
- [ ] AdoptionsService.findAll() filtra por status
- [ ] AdoptionsService.findAll() filtra por petType
- [ ] AdoptionsService.markAsAdopted() cambia status a adopted
- [ ] AdoptionsService.markAsAdopted() registra fecha de adopción

#### Chat Module (Refu)
- [ ] LlmLocalService.generate() retorna respuesta del LLM
- [ ] LlmLocalService.generate() usa prompt del sistema correcto
- [ ] LlmLocalService.checkHealth() detecta LLM disponible
- [ ] LlmLocalService.checkHealth() detecta LLM no disponible
- [ ] RefuService.sendMessage() retorna respuesta empática
- [ ] RefuService.sendMessage() usa fallback si LLM falla
- [ ] RefuService.sendMessage() construye contexto correctamente

#### Diary Module
- [ ] DiaryService.create() crea entrada de diario
- [ ] DiaryService.findAll() filtra por usuario
- [ ] DiaryService.findAll() filtra por mood
- [ ] DiaryService.findAll() filtra por fechas

### Integration Tests

#### API Endpoints
- [ ] POST /api/auth/signup retorna 201 con usuario válido
- [ ] POST /api/auth/login retorna 200 con token
- [ ] GET /api/refuges retorna 200 con lista
- [ ] GET /api/refuges/:id retorna 200 con detalle
- [ ] GET /api/refuges/:id retorna 404 si no existe
- [ ] GET /api/adoptions retorna 200 con lista
- [ ] POST /api/chat/refu retorna 200 con respuesta
- [ ] GET /api/health retorna 200 con status ok

#### Database Integration
- [ ] Prisma conecta correctamente a PostgreSQL
- [ ] Migraciones se ejecutan sin errores
- [ ] Seeds crean datos de prueba correctamente
- [ ] Relaciones entre modelos funcionan (Refuge ↔ Adoption)

#### External Services
- [ ] Conexión a Ollama funciona en desarrollo
- [ ] Timeout de Ollama se respeta
- [ ] Fallback se activa si Ollama no responde

### E2E Tests

- [ ] Flujo completo: registro → login → listar refugios
- [ ] Flujo completo: login → ver adopciones → marcar como adoptado
- [ ] Flujo completo: login → chat con Refu → recibir respuesta
- [ ] Autenticación JWT protege endpoints privados
- [ ] Refresh token funciona correctamente

---

## Frontend (Flutter)

### Unit Tests

#### Models
- [ ] RefugeModel.fromJson() parsea JSON correctamente
- [ ] RefugeModel.toJson() serializa correctamente
- [ ] RefugeModel.occupancyRate calcula porcentaje correcto
- [ ] AdoptionModel.fromJson() parsea JSON correctamente

#### Repositories
- [ ] RefugeRepository.getRefuges() retorna Success con lista
- [ ] RefugeRepository.getRefuges() retorna Failure en error de red
- [ ] RefugeRepository.getRefuge() retorna Success con refugio
- [ ] RefugeRepository.getRefuge() retorna NotFoundFailure si 404
- [ ] ChatbotRepository.sendMessage() retorna Success con respuesta

#### Providers (Riverpod)
- [ ] RefugeProvider carga refugios al inicializar
- [ ] RefugeProvider maneja estado de loading
- [ ] RefugeProvider maneja estado de error
- [ ] ChatbotProvider envía mensaje y actualiza estado

### Widget Tests

#### Componentes Compartidos
- [ ] EmotionalCard renderiza correctamente
- [ ] EmotionalCard aplica color según emoción
- [ ] EmpatheticButton ejecuta onPressed
- [ ] EmpatheticButton muestra loading state
- [ ] MoodSelector muestra 5 opciones
- [ ] MoodSelector actualiza selección

#### Pantallas
- [ ] LoginPage renderiza formulario
- [ ] LoginPage valida email inválido
- [ ] LoginPage valida contraseña vacía
- [ ] HomePage muestra saludo personalizado
- [ ] RefugesPage renderiza lista de refugios
- [ ] RefugeDetailPage muestra información completa
- [ ] AdoptionsPage renderiza grid de mascotas
- [ ] ChatbotPage renderiza mensajes
- [ ] ChatbotPage permite enviar mensajes

### Integration Tests

#### Flujos de Usuario
- [ ] Usuario puede registrarse
- [ ] Usuario puede iniciar sesión
- [ ] Usuario puede ver lista de refugios
- [ ] Usuario puede filtrar refugios por región
- [ ] Usuario puede ver detalle de refugio
- [ ] Usuario puede ver lista de adopciones
- [ ] Usuario puede ver detalle de mascota
- [ ] Usuario puede chatear con Refu
- [ ] Usuario puede crear entrada de diario
- [ ] Usuario puede cerrar sesión

#### Navegación
- [ ] go_router navega correctamente entre pantallas
- [ ] Back button funciona en todas las pantallas
- [ ] Deep links funcionan correctamente
- [ ] Navegación protegida requiere autenticación

### UI/UX Tests

- [ ] Todos los botones tienen área táctil ≥ 48dp
- [ ] Contraste de texto cumple WCAG AA
- [ ] Animaciones son fluidas (60fps)
- [ ] Loading states son visibles
- [ ] Error states muestran mensaje claro
- [ ] Empty states muestran mensaje adecuado
- [ ] Pull to refresh funciona correctamente
- [ ] Scroll es suave en listas largas

---

## Infraestructura

### Docker
- [ ] docker-compose up levanta todos los servicios
- [ ] PostgreSQL está accesible en puerto 5432
- [ ] NestJS está accesible en puerto 3001
- [ ] Health check de NestJS funciona
- [ ] Health check de PostgreSQL funciona
- [ ] Volúmenes persisten datos correctamente

### CI/CD
- [ ] Workflow de NestJS ejecuta lint sin errores
- [ ] Workflow de NestJS ejecuta tests sin errores
- [ ] Workflow de NestJS construye aplicación
- [ ] Workflow de Flutter ejecuta analyze sin errores
- [ ] Workflow de Flutter ejecuta tests sin errores
- [ ] Workflow de Flutter construye APK (solo en main)

### Environment
- [ ] .env.example contiene todas las variables necesarias
- [ ] Variables de entorno se cargan correctamente
- [ ] Secrets no están en el repositorio
- [ ] .gitignore incluye archivos sensibles

---

## Performance

### Backend
- [ ] Endpoint /api/refuges responde en < 200ms
- [ ] Endpoint /api/adoptions responde en < 200ms
- [ ] Endpoint /api/chat/refu responde en < 2s
- [ ] Queries a DB están optimizadas (uso de índices)
- [ ] No hay N+1 queries

### Frontend
- [ ] Tiempo de carga inicial < 3s
- [ ] Navegación entre pantallas < 300ms
- [ ] Imágenes se cargan de forma lazy
- [ ] Caché de API funciona correctamente
- [ ] App no consume > 100MB de RAM en idle

---

## Security

### Backend
- [ ] Passwords se hashean con bcrypt
- [ ] JWT secrets están en variables de entorno
- [ ] CORS está configurado correctamente
- [ ] Input validation funciona en todos los DTOs
- [ ] SQL injection no es posible (Prisma ORM)
- [ ] Rate limiting está configurado (producción)

### Frontend
- [ ] Tokens se almacenan en secure storage
- [ ] HTTPS se usa en producción
- [ ] Datos sensibles no se loguean
- [ ] Validación de inputs en formularios

---

## Accessibility

- [ ] Screen reader puede navegar la app
- [ ] Labels semánticos en todos los widgets
- [ ] Focus order es lógico
- [ ] Colores tienen contraste adecuado
- [ ] Textos pueden escalar hasta 200%
- [ ] Botones tienen tamaño táctil adecuado

---

## Acceptance Criteria

### Must Have (MVP)
- [ ] Usuario puede registrarse e iniciar sesión
- [ ] Usuario puede ver lista de refugios
- [ ] Usuario puede ver detalle de refugio
- [ ] Usuario puede ver lista de adopciones
- [ ] Usuario puede chatear con Refu
- [ ] Usuario puede crear entradas de diario
- [ ] Backend está desplegado y accesible
- [ ] App móvil funciona en Android

### Should Have
- [ ] Filtros funcionan en refugios y adopciones
- [ ] Estadísticas de refugios se muestran
- [ ] Chat mantiene historial de conversación
- [ ] Gráficos de estado de ánimo en diario

### Nice to Have
- [ ] Notificaciones push
- [ ] Modo oscuro
- [ ] Compartir adopciones en redes sociales
- [ ] Mapa de refugios
- [ ] Analytics

---

## Comando para ejecutar tests

### Backend
```bash
cd backend/nest
npm run test          # Unit tests
npm run test:e2e      # E2E tests
npm run test:cov      # Coverage
```

### Frontend
```bash
cd flutter
flutter test                    # Unit tests
flutter test integration_test/  # Integration tests
```

---

**Última actualización**: Noviembre 2025
**Estado**: Checklist preliminar para presentación académica
