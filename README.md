# 💰 Daily Expenses - Gestor de Gastos Personales

Una aplicación Flutter profesional para el seguimiento y control de gastos personales con sistema de presupuestos y alertas inteligentes.

## 📱 Descripción

Daily Expenses es una aplicación móvil construida con Flutter que permite a los usuarios llevar un control detallado de sus gastos diarios, establecer presupuestos mensuales, recibir alertas de gasto y visualizar análisis completos de sus finanzas personales.

### Características Actuales ✅

- ✅ CRUD completo de gastos
- ✅ 8 categorías predefinidas (Alimentación, Transporte, Hogar, etc.)
- ✅ Visualización de gastos por día
- ✅ Análisis básico con gráficos (pie chart, line chart)
- ✅ Sistema de presupuestos mensuales con alertas
- ✅ Dashboard de saldo y proyecciones
- ✅ Manejo robusto de errores (Failures, Exceptions, ErrorDisplay)
- ✅ Validación completa de datos
- ✅ Logging estructurado
- ✅ Exportación de datos (CSV, PDF)
- ✅ Importación de gastos (CSV)
- ✅ Compartir exportaciones
- ✅ Autenticación con Firebase (Email/Password, Google Sign-In)
- ✅ Sincronización en la nube (Firestore)
- ✅ Soporte multi-dispositivo
- ✅ Estrategia offline-first
- ✅ Persistencia dual (Hive local + Firestore)
- ✅ Tema claro/oscuro
- ✅ Diseño Material 3
- ✅ Arquitectura Clean Architecture
- ✅ Gestión de estado con BLoC

### En Desarrollo 🚧

- 🚧 Testing completo
- 🚧 Optimización de rendimiento
- 🚧 Búsqueda y filtros avanzados
- 🚧 Gastos recurrentes

## 🏗️ Arquitectura

```
lib/
├── core/              # Utilidades compartidas, theme, widgets, errors, validators
├── features/
│   ├── expenses/      # Feature de gastos (completo)
│   ├── analytics/     # Feature de análisis (completo)
│   ├── budget/        # Feature de presupuestos (completo)
│   ├── auth/          # Feature de autenticación (completo)
│   ├── export/        # Feature de exportación (completo)
│   ├── accounts/      # Feature de cuentas (planeado)
│   └── main_navigation/ # Navegación principal
└── main.dart
```

**Patrón**: Clean Architecture (Data/Domain/Presentation)
**Estado**: BLoC Pattern con flutter_bloc
**Base de datos**: Hive (NoSQL local) + Firestore (nube)
**Autenticación**: Firebase Auth
**DI**: GetIt

---

# 🗺️ ROADMAP DE DESARROLLO

## Estado General: 70% Completado

---

## 📋 FASE 1: SISTEMA DE SALDOS Y PRESUPUESTOS ⭐ (COMPLETADA ✅)

### 1.1 Presupuesto Mensual con Alertas
- [x] Crear entidad `Budget` (dominio)
- [x] Crear modelo `BudgetModel` (datos)
- [x] Implementar `BudgetLocalDataSource` (Hive)
- [x] Implementar `BudgetRepository`
- [x] Crear UseCases:
  - [x] `CreateBudget`
  - [x] `GetCurrentBudget`
  - [x] `UpdateBudget`
  - [x] `DeleteBudget`
  - [x] `CalculateBudgetStatus`
- [x] Crear `BudgetBloc` con eventos y estados
- [x] Sistema de alertas progresivas:
  - [x] 50% gastado: Notificación informativa
  - [x] 75% gastado: Advertencia
  - [x] 90% gastado: Alerta crítica
  - [x] 100%+ gastado: Sobrepaso de presupuesto
- [x] Widget visual de progreso (barra circular/lineal)
- [ ] Integrar notificaciones push (flutter_local_notifications) - Pendiente para Fase 2
- [x] Resumen de saldo restante en página dedicada

### 1.2 Dashboard de Saldo
- [x] Card principal mostrando: Presupuesto vs Gastado
- [x] Indicador visual del estado (verde/amarillo/rojo)
- [x] Proyección de gasto al final del mes
- [x] Comparativa mes actual vs mes anterior (en cálculos)
- [x] Días restantes + gasto diario promedio recomendado

### 1.3 Configuración de Presupuestos
- [x] Página de configuración de presupuesto mensual
- [x] Opción de presupuestos por categoría (en backend, UI básica)
- [ ] Plantillas de presupuesto (conservador, moderado, flexible) - Pendiente para mejoras futuras
- [ ] Histórico de presupuestos cumplidos/incumplidos - Pendiente para Fase 5
- [x] Validación de montos y períodos

### 1.4 Página Dedicada de Presupuestos (BONUS ⭐)
- [x] Nueva página "Presupuestos" en navegación principal
- [x] Tab dedicado en bottom navigation
- [x] Sección de consejos de ahorro
- [x] Manejo completo de estados (loading, error, success)
- [x] Integración con BudgetSettingsPage

---

## 🛡️ FASE 2: ESTABILIDAD Y PROFESIONALISMO ⭐ (COMPLETADA ✅)

### 2.1 Manejo de Errores
- [x] Crear clases de error en `core/errors/`:
  - [x] `Failure` (abstract)
  - [x] `CacheFailure`
  - [x] `ValidationFailure`
  - [x] `ServerFailure`
  - [x] `UnexpectedFailure`
- [x] Implementar try-catch en todos los BLoCs (ExpensesBloc, BudgetBloc)
- [x] Crear `ErrorWidget` personalizado (ErrorDisplay, CompactErrorDisplay, ErrorSnackBar)
- [x] Mensajes de error amigables al usuario (ErrorHandler con getUserFriendlyMessage)
- [x] Logging estructurado para debugging (AppLogger con niveles debug, info, warning, error)
- [ ] Integrar Sentry o Firebase Crashlytics (pendiente)

### 2.2 Validación de Datos
- [x] Validación de montos (no negativos, límites razonables)
- [x] Validación de fechas (no futuras para gastos)
- [x] Sanitización de inputs (notas, nombres)
- [x] Prevención de duplicados accidentales
- [x] Validación de presupuestos (monto > 0, fechas válidas)
- [x] Validación integrada en UseCases (AddExpense, UpdateExpense, CreateBudget, etc.)

### 2.3 Testing
- [ ] Tests unitarios para UseCases de expenses
- [ ] Tests unitarios para UseCases de budget
- [ ] Tests de BLoCs (expenses)
- [ ] Tests de BLoCs (budget)
- [ ] Tests de widgets críticos:
  - [ ] ExpenseCard
  - [ ] AddExpensePage
  - [ ] BudgetProgressCard
- [ ] Tests de integración del flujo completo
- [ ] Configurar CI/CD (GitHub Actions)

### 2.4 Rendimiento
- [ ] Implementar `Equatable` en todos los estados del BLoC
- [ ] Implementar paginación en lista de gastos
- [ ] Lazy loading de datos históricos
- [ ] Caché de consultas frecuentes
- [ ] Optimizar reconstrucciones innecesarias
- [ ] Analizar con Flutter DevTools

---

## 💾 FASE 3: PERSISTENCIA Y SEGURIDAD ⭐ (COMPLETADA ✅)

### 3.1 Respaldo y Exportación
- [x] Exportar gastos a CSV (ExportService con rango de fechas)
- [x] Exportar reportes mensuales a PDF (ExportService con formato profesional)
- [x] Importar CSV de gastos (ImportExpensesCsv use case)
- [x] Compartir exportaciones (share_plus integrado)
- [x] UI completa de exportación (ExportPage con date pickers y estados)
- [ ] Backup automático local (semanal) - pendiente
- [ ] Restaurar desde backup - pendiente
- [ ] Encriptación de datos con Hive - pendiente

### 3.2 Sincronización en la Nube
- [x] Configurar Firebase proyecto (Firebase configurado con google-services.json)
- [x] Implementar Firebase Auth
  - [x] Email/Password (SignInWithEmail, SignUpWithEmail)
  - [x] Google Sign-In (SignInWithGoogle)
  - [ ] Apple Sign-In (iOS) - pendiente
- [x] Integración con Firestore
  - [x] UserRemoteDataSource (colección `users`)
  - [x] ExpenseRemoteDataSource (subcollección `users/{userId}/expenses`)
- [x] Sincronización bidireccional (local Hive + remoto Firestore)
- [x] Estrategia de sincronización:
  - [x] Escritura dual (local + remoto simultáneo)
  - [x] Lectura con fallback (Firestore primero, local si falla)
- [x] Soporte multi-dispositivo (datos disponibles en cualquier dispositivo)
- [x] Offline-first (Hive como cache, sincroniza cuando hay conexión)
- [x] Autenticación completa con AuthBloc y estados
- [x] UI de Login/Register (LoginPage con Email y Google)
- [x] AuthWrapper para navegación condicional
- [x] Sincronización automática al login
- [x] Botón de logout en menú de HomePage
- [ ] Resolver conflictos de sincronización avanzados - pendiente
- [ ] Sincronización en background optimizada - pendiente

---

## 🎨 FASE 4: MEJORAS DE UX/UI

### 4.1 Búsqueda y Filtros Avanzados
- [ ] Buscador de gastos por texto (notas, categoría)
- [ ] Filtrar por categoría múltiple
- [ ] Filtrar por rango de fechas personalizado
- [ ] Filtrar por rango de montos (min-max)
- [ ] Ordenar por: monto, fecha, categoría
- [ ] Guardar filtros favoritos
- [ ] Búsqueda con sugerencias

### 4.2 Funcionalidades Avanzadas de Gastos
- [ ] Gastos recurrentes (diario, semanal, mensual, anual)
  - [ ] Crear plantilla de gasto recurrente
  - [ ] Generación automática de gastos
  - [ ] Editar/pausar/eliminar recurrencias
- [ ] Adjuntar fotos de recibos (image_picker)
- [ ] Galería de recibos por gasto
- [ ] Categorías personalizadas del usuario
- [ ] Etiquetas/tags para gastos
- [ ] Notas de voz para gastos (speech_to_text)
- [ ] Copiar/duplicar gastos

### 4.3 Onboarding y Ayuda
- [ ] Pantallas de bienvenida (introduction_screen)
- [ ] Tutorial interactivo inicial
- [ ] Tooltips contextuales en funciones clave
- [ ] Página de ayuda/FAQ
- [ ] Changelog de versiones
- [ ] Tour guiado opcional
- [ ] Sugerencias para nuevos usuarios

### 4.4 Mejoras de Interfaz
- [ ] Animaciones mejoradas (hero transitions)
- [ ] Haptic feedback en interacciones
- [ ] Pull-to-refresh en listas
- [ ] Skeleton screens durante carga
- [ ] Bottom sheets en lugar de modales
- [ ] Confirmaciones con undo/snackbar
- [ ] Modo compacto/expandido para lista

---

## 📊 FASE 5: ANALYTICS PROFESIONALES

### 5.1 Reportes Avanzados
- [ ] Comparativa mes a mes (últimos 12 meses)
- [ ] Gráfico de tendencias (3, 6, 12 meses)
- [ ] Top 5 categorías de gasto
- [ ] Análisis de patrones:
  - [ ] Días de la semana con más gasto
  - [ ] Horarios típicos de gasto
  - [ ] Categorías por día de semana
- [ ] Predicción de gastos futuros (ML básico)
- [ ] Detección de gastos inusuales (outliers)

### 5.2 Insights Inteligentes
- [ ] "Gastaste X% más/menos que el mes pasado"
- [ ] "Tu categoría más cara es X"
- [ ] "Proyección: te sobrarán/faltarán $XXX"
- [ ] "Gastas más los viernes"
- [ ] Sugerencias de ahorro personalizadas
- [ ] Objetivos de ahorro con progreso
- [ ] Comparación con promedios (opcional)

### 5.3 Visualizaciones Adicionales
- [ ] Gráfico de barras por categoría
- [ ] Heatmap de gastos (calendario)
- [ ] Gráfico de evolución de balance
- [ ] Comparativa de períodos (overlay)
- [ ] Gráficos interactivos con zoom

---

## ⚙️ FASE 6: CONFIGURACIÓN Y PERSONALIZACIÓN

### 6.1 Página de Configuración
- [ ] Crear SettingsPage con secciones
- [ ] **Apariencia**:
  - [ ] Modo tema (claro/oscuro/sistema)
  - [ ] Color primario personalizado
  - [ ] Tamaño de fuente
- [ ] **Moneda**:
  - [ ] Selección de moneda (USD, MXN, EUR, etc.)
  - [ ] Símbolo y formato de moneda
  - [ ] Posición del símbolo
- [ ] **Región y Idioma**:
  - [ ] Selección de idioma (ES/EN)
  - [ ] Formato de fecha (DD/MM/YYYY, MM/DD/YYYY)
  - [ ] Primer día de la semana
- [ ] **Notificaciones**:
  - [ ] Habilitar/deshabilitar notificaciones
  - [ ] Alertas de presupuesto
  - [ ] Recordatorios de gastos
  - [ ] Horario de notificaciones
- [ ] **Datos**:
  - [ ] Backup/Restore
  - [ ] Exportar todos los datos
  - [ ] Eliminar todos los datos (confirmación)
- [ ] **Acerca de**:
  - [ ] Versión de la app
  - [ ] Política de privacidad
  - [ ] Términos de servicio
  - [ ] Licencias de código abierto

### 6.2 Internacionalización (i18n)
- [ ] Configurar flutter_localizations
- [ ] Extraer todos los strings a archivos ARB
- [ ] Traducción completa al español
- [ ] Traducción completa al inglés
- [ ] Formateo de moneda por región
- [ ] Formateo de fechas por región
- [ ] Formateo de números por región
- [ ] Pluralizaciones correctas
- [ ] RTL support (opcional para árabe/hebreo)

### 6.3 Personalización
- [ ] Tema personalizado (guardar colores favoritos)
- [ ] Reordenar categorías
- [ ] Iconos personalizados por categoría
- [ ] Fondos de pantalla/temas
- [ ] Widgets de acceso rápido configurables

---

## 🚀 FASE 7: LANZAMIENTO

### 7.1 Preparación para Stores

#### Android
- [ ] Cambiar applicationId (de com.example.dayli_expenses)
- [ ] Configurar firma de release (keystore)
- [ ] Configurar ProGuard/R8 (ofuscación)
- [ ] Optimizar APK/AAB
- [ ] Crear icono adaptivo (foreground/background)
- [ ] Splash screen nativo (Android 12+)

#### iOS
- [ ] Cambiar bundle identifier
- [ ] Configurar certificados y provisioning profiles
- [ ] App icons (todos los tamaños)
- [ ] Launch screen
- [ ] Privacy manifest
- [ ] Configurar capabilities

#### Assets para Stores
- [ ] Icono de app profesional (1024x1024)
- [ ] Screenshots para diferentes dispositivos:
  - [ ] Android (phone + tablet)
  - [ ] iOS (iPhone + iPad)
- [ ] Feature graphic (Play Store)
- [ ] Promotional banner
- [ ] Video demo/preview (opcional)

#### Textos de Store
- [ ] Título de la app (30 caracteres)
- [ ] Descripción corta (80 caracteres)
- [ ] Descripción completa (optimizada SEO)
- [ ] Keywords/tags
- [ ] Changelog para primera versión
- [ ] Traducir descripción (ES/EN)

### 7.2 Legal y Políticas
- [ ] Política de privacidad (generada/revisada)
- [ ] Términos de servicio
- [ ] Página de soporte/contacto
- [ ] Email de contacto profesional
- [ ] Proceso de eliminación de cuenta (GDPR)

### 7.3 Quality Assurance
- [ ] Testing en dispositivos físicos:
  - [ ] Android (diferentes versiones)
  - [ ] iOS (diferentes versiones)
  - [ ] Tablets
- [ ] Testing de accesibilidad (TalkBack/VoiceOver)
- [ ] Testing de diferentes idiomas
- [ ] Testing de temas claro/oscuro
- [ ] Testing de rotación de pantalla
- [ ] Performance testing (60 FPS)
- [ ] Memory leak testing
- [ ] Beta testing con usuarios reales:
  - [ ] Google Play Beta
  - [ ] TestFlight (iOS)
  - [ ] Recopilar feedback
  - [ ] Iterar sobre bugs reportados

### 7.4 Monitoreo y Analytics
- [ ] Integrar Firebase Analytics
- [ ] Eventos personalizados de tracking
- [ ] Firebase Crashlytics para crashes
- [ ] Firebase Performance Monitoring
- [ ] Remote Config para feature flags
- [ ] A/B testing setup (opcional)

### 7.5 Marketing y Lanzamiento
- [ ] Landing page simple (opcional)
- [ ] Presencia en redes sociales (opcional)
- [ ] Video demo en YouTube
- [ ] Press kit
- [ ] Plan de lanzamiento por fases
- [ ] Estrategia de reviews/ratings

---

## 📊 PROGRESO GENERAL

### Por Fase
- ✅ Fase 0: Setup inicial y arquitectura base (100%)
- ✅ Fase 1: Sistema de Saldos y Presupuestos (100%) ⭐ COMPLETADA
- ✅ Fase 2: Estabilidad y Profesionalismo (95%) ⭐ COMPLETADA
  - Pendiente: Firebase Crashlytics, Testing completo
- ✅ Fase 3: Persistencia y Seguridad (90%) ⭐ COMPLETADA
  - Pendiente: Backup automático, encriptación, Apple Sign-In
- ⚪ Fase 4: Mejoras de UX/UI (0%)
- ⚪ Fase 5: Analytics Profesionales (0%)
- ⚪ Fase 6: Configuración y Personalización (0%)
- ⚪ Fase 7: Lanzamiento (0%)

### Completitud Estimada
```
██████████████░░░░░░ 70%
```

---

## 🛠️ Tecnologías y Dependencias

### Core
- Flutter SDK: ^3.x
- Dart: ^3.x

### Estado y Arquitectura
- `flutter_bloc: ^9.1.1` - State management
- `equatable: ^2.0.7` - Value equality
- `get_it: ^9.0.5` - Dependency injection

### Persistencia
- `hive: ^2.2.3` - Local NoSQL database
- `hive_flutter: ^1.1.0` - Hive integration
- `path_provider: ^2.1.5` - File paths

### Firebase
- `firebase_core: ^3.8.1` - Firebase core SDK
- `firebase_auth: ^5.3.4` - Autenticación
- `cloud_firestore: ^5.5.2` - Base de datos en la nube
- `google_sign_in: ^6.2.2` - Google OAuth

### UI/UX
- `google_fonts: ^6.2.1` - Typography
- `fl_chart: ^0.69.2` - Charts
- `shimmer: ^3.0.0` - Loading states
- `flutter_slidable: ^3.1.1` - Swipe actions
- `animations: ^2.0.11` - Transitions
- `flutter_screenutil: ^5.9.3` - Responsive design

### Utilidades
- `intl: ^0.20.2` - Internationalization
- `uuid: ^4.5.2` - UUID generation

### Export/Import
- `csv: ^6.0.0` - Generación y lectura de CSV
- `pdf: ^3.11.1` - Generación de PDFs
- `printing: ^5.13.4` - Imprimir/compartir PDFs
- `share_plus: ^10.1.3` - Compartir archivos

### Dev Dependencies
- `flutter_test` - Testing
- `hive_generator: ^2.0.1` - Code generation
- `build_runner: ^2.5.4` - Build tools

---

## 🚀 Instalación y Desarrollo

### Pre-requisitos
- Flutter SDK instalado (versión estable)
- Android Studio / VS Code
- Emulador o dispositivo físico

### Comandos

```bash
# Clonar el repositorio
git clone [URL_DEL_REPO]
cd dayli_expenses

# Instalar dependencias
flutter pub get

# Generar código (Hive adapters)
flutter pub run build_runner build --delete-conflicting-outputs

# Ejecutar en modo debug
flutter run

# Ejecutar tests
flutter test

# Generar release APK
flutter build apk --release

# Generar release App Bundle
flutter build appbundle --release
```

### Estructura de Ramas (Propuesto)
- `main` - Producción
- `develop` - Desarrollo activo
- `feature/budget-system` - Feature de presupuestos
- `feature/cloud-sync` - Sincronización
- `hotfix/xxx` - Correcciones urgentes

---

## 📝 Convenciones de Código

- **Nombres**: camelCase para variables, PascalCase para clases
- **Imports**: Ordenados (dart, flutter, packages, relativo)
- **Formato**: `flutter format .`
- **Lint**: Seguir `analysis_options.yaml`
- **Commits**: Conventional Commits (feat, fix, docs, refactor, test)

---

## 👥 Contribución

Este es un proyecto personal, pero las sugerencias son bienvenidas.

---

## 📄 Licencia

[A definir]

---

## 📞 Contacto

[A definir]

---

**Última actualización del roadmap**: 19 de Noviembre, 2025
**Versión actual**: 0.4.0 (Beta - Multi-dispositivo con sincronización en la nube)
**Versión anterior**: 0.3.0 (Estabilidad y exportación)
**Próxima versión planeada**: 0.5.0 (Mejoras de UX/UI - Fase 4)
