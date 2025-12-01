# Guía Visual - Mi Refugio APP

## Paleta de Colores

### Colores Principales
```dart
// Colores cálidos y acogedores
Color primary = Color(0xFF6B4E71);        // Púrpura suave
Color secondary = Color(0xFFD4A5A5);      // Rosa empolvado
Color accent = Color(0xFF9B7EBD);         // Lavanda

// Neutros
Color background = Color(0xFFF7F0E7);     // Beige claro
Color surface = Color(0xFFFFFFFF);        // Blanco
Color textPrimary = Color(0xFF2D2D2D);    // Gris oscuro
Color textSecondary = Color(0xFF757575);  // Gris medio
```

### Colores de Estado Emocional
```dart
// Estados de ánimo
Color joyful = Color(0xFFFFC857);         // Amarillo alegre
Color calm = Color(0xFF90C8E8);           // Azul calmo
Color anxious = Color(0xFFFFB6A3);        // Coral suave
Color sad = Color(0xFFB8B8D1);            // Lila grisáceo
Color angry = Color(0xFFE57373);          // Rojo suave
```

## Tipografía

### Fuente Principal
**Google Fonts: Nunito**

```dart
// Títulos
TextStyle headline1 = GoogleFonts.nunito(
  fontSize: 32,
  fontWeight: FontWeight.w700,
  color: textPrimary,
);

TextStyle headline2 = GoogleFonts.nunito(
  fontSize: 24,
  fontWeight: FontWeight.w600,
  color: textPrimary,
);

// Cuerpo
TextStyle bodyText1 = GoogleFonts.nunito(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  color: textPrimary,
);

TextStyle bodyText2 = GoogleFonts.nunito(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  color: textSecondary,
);

// Botones
TextStyle button = GoogleFonts.nunito(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.5,
);
```

## Componentes Visuales

### EmotionalCard
Tarjeta con gradiente suave para mostrar contenido emocional.

**Uso:**
```dart
EmotionalCard(
  color: AppColors.calm,
  child: Text('Contenido de la tarjeta'),
)
```

**Características:**
- Bordes redondeados (16px)
- Sombra suave
- Gradiente de color según emoción
- Padding interno consistente

### EmpatheticButton
Botón con diseño cálido y accesible.

**Uso:**
```dart
EmpatheticButton(
  label: 'Continuar',
  onPressed: () {},
  variant: ButtonVariant.primary,
)
```

**Variantes:**
- **Primary**: Fondo púrpura, texto blanco
- **Secondary**: Borde púrpura, texto púrpura
- **Outlined**: Borde sutil, fondo transparente

### MoodSelector
Selector visual de estados de ánimo.

**Características:**
- 5 emociones básicas
- Iconos expresivos
- Animación al seleccionar
- Feedback visual

## Pantallas Principales

### 1. Splash Screen
- Logo centrado
- Gradiente de fondo
- Transición suave

### 2. Login / Registro
- Formularios limpios
- Validación en tiempo real
- Opción de Google Sign-In
- Transición entre modos

### 3. Home
- Saludo personalizado
- Selector de estado de ánimo
- Accesos rápidos a funciones
- Bottom navigation bar

### 4. Refugios (Nueva)
**Lista de Refugios:**
- Cards con imagen, nombre, región
- Indicador de capacidad
- Filtros por región
- Pull to refresh

**Detalle de Refugio:**
- Hero image
- Información de contacto
- Mapa (si hay coordenadas)
- Lista de mascotas disponibles
- Estadísticas

### 5. Adopciones (Nueva)
**Lista de Adopciones:**
- Grid de mascotas
- Foto, nombre, tipo
- Estado (disponible/adoptado)
- Filtros por tipo

**Detalle de Adopción:**
- Galería de fotos
- Información de la mascota
- Datos del refugio
- Botón de contacto
- Compartir

### 6. Chat con Refu
- Interfaz de mensajería
- Burbujas de chat diferenciadas
- Avatar de Refu (mascota)
- Indicador de escritura
- Historial de conversación

### 7. Diario Emocional
- Timeline de entradas
- Selector de ánimo visual
- Editor de texto enriquecido
- Tags y emociones
- Gráficos de tendencias

### 8. Perfil
- Avatar del usuario
- Información personal
- Configuraciones
- Modo oscuro toggle
- Cerrar sesión

## Espaciado y Layout

### Sistema de Espaciado
```dart
// Espaciado consistente
const double spacing4 = 4.0;
const double spacing8 = 8.0;
const double spacing12 = 12.0;
const double spacing16 = 16.0;
const double spacing24 = 24.0;
const double spacing32 = 32.0;
const double spacing48 = 48.0;
```

### Border Radius
```dart
const double radiusSmall = 8.0;
const double radiusMedium = 12.0;
const double radiusLarge = 16.0;
const double radiusXLarge = 24.0;
```

### Sombras
```dart
BoxShadow shadowSmall = BoxShadow(
  color: Colors.black.withOpacity(0.05),
  blurRadius: 4,
  offset: Offset(0, 2),
);

BoxShadow shadowMedium = BoxShadow(
  color: Colors.black.withOpacity(0.1),
  blurRadius: 8,
  offset: Offset(0, 4),
);

BoxShadow shadowLarge = BoxShadow(
  color: Colors.black.withOpacity(0.15),
  blurRadius: 16,
  offset: Offset(0, 8),
);
```

## Iconografía

### Fuente de Iconos
- **Material Icons** (por defecto)
- **Custom SVG Icons** para funciones específicas

### Iconos Principales
```dart
// Navegación
home: Icons.home_rounded
diary: Icons.book_rounded
chat: Icons.chat_bubble_rounded
profile: Icons.person_rounded
resources: Icons.favorite_rounded

// Refugios y Adopciones
refuge: Icons.home_work_rounded
pet: Icons.pets_rounded
location: Icons.location_on_rounded
phone: Icons.phone_rounded
email: Icons.email_rounded
website: Icons.language_rounded

// Estados de ánimo
joyful: Icons.sentiment_very_satisfied_rounded
calm: Icons.sentiment_satisfied_rounded
neutral: Icons.sentiment_neutral_rounded
anxious: Icons.sentiment_dissatisfied_rounded
sad: Icons.sentiment_very_dissatisfied_rounded
```

## Animaciones

### Transiciones de Página
- **Duración**: 300ms
- **Curva**: Curves.easeInOut
- **Tipo**: Fade + Slide

### Micro-interacciones
- **Botones**: Scale down al presionar (0.95)
- **Cards**: Elevation al hover
- **Inputs**: Border color al focus

### Loading States
- **Shimmer effect** para skeleton screens
- **Circular progress** centrado
- **Pull to refresh** con animación personalizada

## Accesibilidad

### Contraste
- Todos los textos cumplen WCAG AA (mínimo 4.5:1)
- Botones e interacciones cumplen WCAG AAA

### Tamaños Táctiles
- Mínimo 48x48 dp para elementos interactivos
- Espaciado mínimo de 8dp entre elementos

### Semántica
- Labels descriptivos en todos los widgets
- Soporte para screen readers
- Navegación por teclado (web)

## Assets

### Estructura de Carpetas
```
assets/
├── images/
│   ├── branding/
│   │   ├── logo_primary.png
│   │   └── logo_white.png
│   ├── mascot/
│   │   └── refu_avatar.png
│   ├── icons/
│   └── illustrations/
├── audio/
│   └── mindfulness/
└── videos/
    └── tutorials/
```

### Formato de Imágenes
- **PNG** para logos y transparencias
- **WebP** para fotos (mejor compresión)
- **SVG** para iconos vectoriales

## Modo Oscuro

### Paleta Oscura
```dart
Color primaryDark = Color(0xFF9B7EBD);
Color backgroundDark = Color(0xFF1A1A1A);
Color surfaceDark = Color(0xFF2D2D2D);
Color textPrimaryDark = Color(0xFFE0E0E0);
Color textSecondaryDark = Color(0xFFB0B0B0);
```

### Adaptación
- Colores de estado se mantienen reconocibles
- Contraste adecuado en todos los componentes
- Sombras reemplazadas por bordes sutiles

---

**Nota**: Esta guía debe ser consultada por desarrolladores y diseñadores al crear nuevos componentes o pantallas.

**Última actualización**: Noviembre 2025
