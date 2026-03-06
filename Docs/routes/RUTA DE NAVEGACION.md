# 🗺️ Rutas de Navegación - BeEnergy

## 📱 Información General del Proyecto

**Tipo de Proyecto:** Aplicación Móvil Flutter
**Plataformas:** Android / iOS
**SDK Flutter:** >=2.19.4 <3.0.0
**Arquitectura de Navegación:** Rutas Nombradas + Bottom Navigation Bar
**Persistencia de Sesión:** SQLite Database (`beEnergy.db`)
**Autenticación:** JWT Token + Base de Datos Local

---

## 🏗️ Arquitectura de Navegación

### Punto de Entrada
- **Widget:** `Beenergy` (Splash Screen)
- **Archivo:** [lib/screens/main_screen.dart](../../lib/screens/main_screen.dart)
- **Función:** Verifica estado de autenticación mediante SQLite

### Sistema de Rutas
- **Definición:** [lib/main.dart](../../lib/main.dart) - MaterialApp.routes
- **Total de Rutas Nombradas:** 20+
- **Navegación Principal:** NavPages con Bottom Navigation (5 pantallas)
- **Protección:** Verificación de sesión en punto de entrada

---

## 🔄 Flujo Principal de Navegación

### 1️⃣ Inicio de Aplicación

```mermaid
graph LR
    A[🚀 Inicio App] --> B[💫 BeEnergy Splash]
    B --> C{🔐 Verificación Auth<br/>SQLite DB}
    C -->|✅ Usuario Encontrado<br/>idUser != 0| D[🏠 NavPages<br/>Navegación Principal]
    C -->|❌ Sin Usuario<br/>idUser == 0| E[🔑 Pantalla Login]

    style A fill:#e1f5ff
    style B fill:#fff4e6
    style C fill:#fff9c4
    style D fill:#c8e6c9
    style E fill:#ffccbc
```

**Descripción del Flujo:**
1. Usuario abre la aplicación
2. Se muestra splash screen `Beenergy`
3. Se ejecuta `BlocBeenergy.getUserFromDB()`
4. **Decisión:**
   - Si existe usuario en SQLite → Redirige a `NavPages` (estado autenticado)
   - Si NO existe usuario → Redirige a `LoginScreen` (estado no autenticado)

---

## 🔓 Flujos No Autenticados (Rutas Públicas)

### 2️⃣ Flujo de Autenticación Completo

```mermaid
graph LR
    A[🔑 Login Screen] --> B{⚡ Acción Usuario}

    B -->|📝 Botón Registrarse| C[👤 Register Screen]
    B -->|❓ Olvidé mi Contraseña| D[🔄 Recuperar Contraseña]
    B -->|✅ Login Exitoso| E[🏠 NavPages]

    C -->|✅ Registro Exitoso<br/>Auto-login| E
    D -->|📧 Email Enviado| A

    style A fill:#ffccbc
    style B fill:#fff9c4
    style C fill:#c5cae9
    style D fill:#f8bbd0
    style E fill:#c8e6c9
```

### 📋 Detalles de Pantallas Públicas

#### 🔑 Login Screen
- **Ruta:** `'login'`
- **Widget:** `LoginScreen()`
- **Archivo:** [lib/screens/main_screens/Login/login_screen.dart](../../lib/screens/main_screens/Login/login_screen.dart)
- **Funcionalidad:**
  - Autenticación con Email + Contraseña
  - Integración con API: `/auth/log-in`
  - Almacenamiento de JWT Token
  - Creación de sesión local en SQLite
- **Navegaciones posibles:**
  - ✅ Login exitoso → `NavPages`
  - 📝 "Registrarse" → `RegisterScreen`
  - ❓ "¿Olvidaste tu contraseña?" → `NoRecuerdomiclaveScreen`

#### 👤 Register Screen
- **Ruta:** `'register'`
- **Widget:** `RegisterScreen()`
- **Archivo:** [lib/screens/main_screens/Login/register_screen.dart](../../lib/screens/main_screens/Login/register_screen.dart)
- **Funcionalidad:**
  - Campos: Nombre, Email, Contraseña
  - Integración con API: `/auth/sign-up`
  - Auto-login después de registro exitoso
- **Navegación:**
  - ✅ Registro exitoso → Login automático → `NavPages`
  - ⬅️ Volver → `LoginScreen`

#### 🔄 Recuperar Contraseña
- **Ruta:** `'RecuerdoMiClave'`
- **Widget:** `NoRecuerdomiclaveScreen()`
- **Archivo:** [lib/screens/main_screens/Login/noRecuerdomiClave_screen.dart](../../lib/screens/main_screens/Login/noRecuerdomiClave_screen.dart)
- **Funcionalidad:**
  - Recuperación por email
  - Integración con API: `/auth/forgot-password`
- **Navegación:**
  - 📧 Email enviado → Volver a `LoginScreen`

---

## 🔐 Flujos Autenticados (Rutas Protegidas)

### 3️⃣ Navegación Principal - Bottom Navigation Bar

```mermaid
graph TB
    A[🏠 NavPages<br/>Bottom Navigation] --> B[🏡 Home<br/>Índice 0]
    A --> C[⚡ Energía<br/>Índice 1]
    A --> D[💱 Trading<br/>Índice 2 FAB]
    A --> E[🔔 Notificaciones<br/>Índice 3]
    A --> F[👤 Mi Cuenta<br/>Índice 4]

    F -->|🚪 Cerrar Sesión| G[💫 BeEnergy Splash<br/>Clear Stack]
    G --> H[🔑 Login Screen]

    style A fill:#4fc3f7
    style B fill:#81c784
    style C fill:#ffb74d
    style D fill:#9575cd
    style E fill:#f06292
    style F fill:#4dd0e1
    style G fill:#fff4e6
    style H fill:#ffccbc
```

### 📱 Estructura del Bottom Navigation

**Widget:** `NavPages`
**Archivo:** [lib/views/navigation.dart](../../lib/views/navigation.dart)
**Tipo:** StatefulWidget con PageStorage

| Índice | Icono | Pantalla | Widget | Tipo Botón |
|--------|-------|----------|--------|------------|
| 0 | 🏡 Home | HomeScreen | `HomeScreen()` | Bottom Nav |
| 1 | ⚡ Energy | EnergyScreen | `EnergyScreen()` | Bottom Nav |
| 2 | 💱 Trading | TradingScreen | `TradingScreen()` | FAB (Centro) |
| 3 | 🔔 Alerts | NotificacionesScreen | `NotificacionesScreen()` | Bottom Nav |
| 4 | 👤 Profile | MicuentaScreen | `MicuentaScreen()` | Bottom Nav |

**Características:**
- **BottomAppBar** con `CircularNotchedRectangle`
- **FloatingActionButton** central para Trading
- **PageStorage** para preservar posiciones de scroll
- 4 botones visibles + 1 FAB = 5 pantallas totales

---

## 🏡 Sub-Navegaciones desde Home

### 4️⃣ Flujos desde Home Screen

```mermaid
graph LR
    A[🏡 Home Screen<br/>Dashboard] --> B[👥 Gestión de Comunidad]
    A --> C[💱 Trading]
    A --> D[📊 Bolsa/Marketplace]
    A --> E[📄 Detalles de Transacción]
    A --> F[🛒 Marketplace Consumidor]
    A --> G[🔔 Notificaciones]

    style A fill:#81c784
    style B fill:#ba68c8
    style C fill:#9575cd
    style D fill:#4fc3f7
    style E fill:#ffb74d
    style F fill:#f06292
    style G fill:#ff8a65
```

### 📊 Home Screen - Características

**Archivo:** [lib/screens/main_screens/home/home_screen.dart](../../lib/screens/main_screens/home/home_screen.dart)

**Funcionalidades:**
- 📈 Dashboard de consumo energético
- 📅 Selector de período (datos históricos)
- 👔 Toggle vista Admin/Usuario
- 📊 Visualización de estadísticas (CircularChart)
- 📋 Lista de transacciones recientes
- ⚡ Botones de acción rápida

**Navegaciones disponibles desde Home:**
1. `TransactionDetailScreen` - Detalles de transacciones
2. `CommunityManagementScreen` - Gestión de comunidad
3. `TradingScreen` - Trading de energía
4. `BolsaScreen` - Bolsa/Marketplace
5. `NotificacionesScreen` - Notificaciones
6. `ConsumerMarketplaceScreen` - Marketplace de consumidor

---

## 💱 Sub-Navegaciones desde Trading

### 5️⃣ Flujos desde Trading Screen

```mermaid
graph LR
    A[💱 Trading Screen<br/>Centro de Trading] --> B[📤 Enviar Energía]
    A --> C[🔄 Intercambios de Energía]
    A --> D[📝 Registro de Envíos]
    A --> E[💰 Balance/Saldo]

    B --> F[✅ Confirmación de Envío]
    F --> G[📄 Redirección Post-Envío]

    style A fill:#9575cd
    style B fill:#66bb6a
    style C fill:#42a5f5
    style D fill:#ffa726
    style E fill:#ffee58
    style F fill:#c8e6c9
    style G fill:#b2dfdb
```

### 💱 Trading Screen - Características

**Archivo:** [lib/screens/main_screens/Trading/trading_screen.dart](../../lib/screens/main_screens/Trading/trading_screen.dart)

**Funcionalidades:**
- 💰 Visualización de balance/saldo
- ⚡ Interfaz de transferencia de energía
- 🎯 Speed dial para acciones rápidas

**Sub-pantallas de Trading:**

| Pantalla | Widget | Descripción |
|----------|--------|-------------|
| Enviar Energía | `EnviaEnergyScreen` | Formulario de envío de energía |
| Confirmación | `EnviarRedirectionScreen` | Redirección post-envío |
| Intercambios | `IntercambiosEnergyScreen` | Historial de intercambios |
| Registros | `EnviaRecordScreen` | Registros de transacciones |

---

## 👤 Sub-Navegaciones desde Mi Cuenta

### 6️⃣ Flujos desde Mi Cuenta (Perfil)

```mermaid
graph LR
    A[👤 Mi Cuenta<br/>Perfil Usuario] --> B[✏️ Editar Perfil]
    A --> C[🔐 Cambiar Contraseña]
    A --> D[🔔 Centro de Notificaciones]
    A --> E[📚 Tutorial]
    A --> F[🎓 Aprender]
    A --> G[🚪 Cerrar Sesión]

    G --> H[💫 BeEnergy Splash]
    H --> I[🔑 Login Screen]

    style A fill:#4dd0e1
    style B fill:#81c784
    style C fill:#ff8a65
    style D fill:#f06292
    style E fill:#4fc3f7
    style F fill:#ffb74d
    style G fill:#ef5350
    style H fill:#fff4e6
    style I fill:#ffccbc
```

### 👤 Mi Cuenta Screen - Características

**Archivo:** [lib/screens/main_screens/miCuenta/miCuenta.dart](../../lib/screens/main_screens/miCuenta/miCuenta.dart)

**Opciones del Menú:**

| Opción | Pantalla | Widget | Descripción |
|--------|----------|--------|-------------|
| ✏️ Editar Perfil | Editar Perfil | `EditarPerfilScreen` | Modificar datos personales |
| 🔐 Cambiar Contraseña | Cambiar Clave | `CambiarClavePerfilScreen` | Actualizar contraseña |
| 🔔 Notificaciones | Centro de Notificaciones | `CentroNotificacionesPerfilScreen` | Configurar alertas |
| 📚 Tutorial | Tutorial | `TutorialScreen` | Guía de uso de la app |
| 🎓 Aprende | Aprender | `AprendeScreen` | Recursos educativos |
| 🚪 Cerrar Sesión | Logout | - | Cierra sesión y limpia stack |

### 🚪 Flujo de Cierre de Sesión

```dart
1. Usuario toca "Cerrar Sesión"
2. Alert Dialog de confirmación
3. Si confirma:
   a. DatabaseHelper.deleteUserLocal() → Elimina sesión local
   b. Navigator.pushAndRemoveUntil() → Limpia stack de navegación
   c. Redirige a Beenergy (entry point)
   d. Beenergy detecta sin usuario → Redirige a LoginScreen
```

---

## 👥 Gestión de Comunidad (7 Módulos)

### 7️⃣ Flujos de Gestión de Comunidad

```mermaid
graph LR
    A[👥 Gestión de Comunidad<br/>Community Management] --> B[📊 Registros de Energía]
    A --> C[⚙️ Asignación PDE]
    A --> D[🤝 Mercado P2P]
    A --> E[💳 Créditos de Energía]
    A --> F[💰 Facturación Mensual]
    A --> G[📈 Reportes]
    A --> H[👤 Detalle de Usuario]

    style A fill:#ba68c8
    style B fill:#66bb6a
    style C fill:#42a5f5
    style D fill:#ffa726
    style E fill:#ab47bc
    style F fill:#26c6da
    style G fill:#ffca28
    style H fill:#ec407a
```

### 👥 Community Management Screen

**Archivo:** [lib/screens/main_screens/community/community_management_screen.dart](../../lib/screens/main_screens/community/community_management_screen.dart)

**Características:**
- 📋 Lista de miembros (15 miembros de UAO Community)
- 🔍 Filtro por rol (Prosumer/Consumer)
- 🔎 Funcionalidad de búsqueda
- 📊 Estadísticas de la comunidad
- 👤 Navegación a detalles de usuario

### 📊 Módulos de Gestión

| Módulo | Ruta | Widget | Descripción |
|--------|------|--------|-------------|
| 📊 Registros de Energía | `energyRecords` | `EnergyRecordsScreen` | Historial de producción/consumo |
| ⚙️ Asignación PDE | `pdeAllocation` | `PDEAllocationScreen` | Distribución de energía |
| 🤝 Mercado P2P | `p2pMarket` | `P2PMarketScreen` | Mercado entre pares |
| 💳 Créditos de Energía | `energyCredits` | `EnergyCreditsScreen` | Sistema de créditos |
| 💰 Facturación Mensual | `monthlyBilling` | `MonthlyBillingScreen` | Facturas mensuales |
| 📈 Reportes | `reports` | `ReportsScreen` | Reportes y análisis |

---

## 🛒 Flujos del Marketplace

### 8️⃣ Marketplace de Consumidor

```mermaid
graph LR
    A[🛒 Consumer Marketplace] --> B[➕ Crear Oferta]
    A --> C[📋 Lista de Ofertas]
    C --> D[👁️ Detalle de Oferta]
    D --> E[✅ Aceptar Oferta]

    style A fill:#f06292
    style B fill:#66bb6a
    style C fill:#42a5f5
    style D fill:#ffa726
    style E fill:#c8e6c9
```

**Pantallas del Marketplace:**
- `ConsumerMarketplaceScreen` - Marketplace principal
- `ConsumerCreateOfferScreen` - Crear nueva oferta
- `ConsumerOffersListScreen` - Listado de ofertas
- `OfferDetailAcceptanceScreen` - Detalle y aceptación

### 📊 Bolsa/Exchange

```mermaid
graph LR
    A[📊 Bolsa Screen] --> B[💱 Seleccionar Intercambio]
    B --> C[✅ Confirmar Bolsa]
    C --> D[✔️ Transacción Completada]

    style A fill:#4fc3f7
    style B fill:#ffb74d
    style C fill:#fff9c4
    style D fill:#c8e6c9
```

**Pantallas:**
- `BolsaScreen` - Marketplace/Exchange
- `ConfirmBolsaScreen` - Confirmación de intercambio

---

## 🔧 Pantallas Administrativas

### 9️⃣ Paneles de Administración

```mermaid
graph LR
    A[👔 Admin Panel] --> B[💰 Panel de Liquidación]
    A --> C[⚙️ Asignación PDE]

    style A fill:#ff6f00
    style B fill:#26c6da
    style C fill:#42a5f5
```

**Pantallas Admin:**
- `AdminLiquidationPanel` - Panel de liquidación
- `AdminPDEAssignmentScreen` - Asignación de PDE

### ⚡ Prosumer

```mermaid
graph LR
    A[⚡ Prosumer] --> B[➕ Crear Oferta]
    B --> C[📋 Lista de Ofertas]

    style A fill:#66bb6a
    style B fill:#81c784
    style C fill:#a5d6a7
```

**Pantallas:**
- `ProsumerCreateOfferScreen` - Crear oferta como prosumidor

---

## 💳 Gestión de Pagos

### 🔟 Tarjetas y Pagos

```mermaid
graph LR
    A[💳 Card Screen] --> B[⏸️ Pausar Tarjeta]
    B --> C[▶️ Reactivar]
    A --> D[➕ Agregar Nueva]

    style A fill:#ab47bc
    style B fill:#ffa726
    style C fill:#66bb6a
    style D fill:#42a5f5
```

**Pantallas:**
- `CardScreen` - Gestión de tarjetas de pago
- `PauseCardScreen` - Pausar/activar tarjeta

---

## 📍 Otras Funcionalidades

### 1️⃣1️⃣ Pantallas Adicionales

| Pantalla | Widget | Descripción |
|----------|--------|-------------|
| 🗺️ Mapas | `MapasScreen` | Visualización de ubicaciones |
| 📄 Detalle de Transacción | `TransactionDetailScreen` | Detalles completos de transacción |
| 📜 Historial | `HistorialScreen` | Historial de transacciones |
| ⚙️ Configuración | `ConfiguracionScreen` | Configuración de la app |

---

## 📋 Tabla de Referencia Completa de Rutas

### 🔓 Rutas Públicas (No Requieren Autenticación)

| Ruta | Widget | Archivo | Descripción |
|------|--------|---------|-------------|
| `'beEnergy'` | `Beenergy()` | [main_screen.dart](../../lib/screens/main_screen.dart) | 💫 Pantalla de entrada/splash con verificación de auth |
| `'login'` | `LoginScreen()` | [login_screen.dart](../../lib/screens/main_screens/Login/login_screen.dart) | 🔑 Inicio de sesión |
| `'register'` | `RegisterScreen()` | [register_screen.dart](../../lib/screens/main_screens/Login/register_screen.dart) | 👤 Registro de nuevo usuario |
| `'RecuerdoMiClave'` | `NoRecuerdomiclaveScreen()` | [noRecuerdomiClave_screen.dart](../../lib/screens/main_screens/Login/noRecuerdomiClave_screen.dart) | 🔄 Recuperación de contraseña |

### 🔐 Rutas Protegidas - Navegación Principal

| Ruta | Widget | Archivo | Índice NavPages | Descripción |
|------|--------|---------|-----------------|-------------|
| `'home'` | `HomeScreen()` | [home_screen.dart](../../lib/screens/main_screens/home/home_screen.dart) | 0 | 🏡 Dashboard principal |
| `'energy'` | `EnergyScreen()` | [energy_screen.dart](../../lib/screens/main_screens/energy/energy_screen.dart) | 1 | ⚡ Monitoreo de energía |
| `'trading'` | `TradingScreen()` | [trading_screen.dart](../../lib/screens/main_screens/Trading/trading_screen.dart) | 2 (FAB) | 💱 Trading de energía |
| `'notificaciones'` | `NotificacionesScreen()` | - | 3 | 🔔 Notificaciones |
| `'historial'` | `HistorialScreen()` | - | - | 📜 Historial de transacciones |
| `'configuration'` | `ConfiguracionScreen()` | - | - | ⚙️ Configuración |

### 🔐 Rutas Protegidas - Gestión de Comunidad

| Ruta | Widget | Descripción |
|------|--------|-------------|
| `'communityManagement'` | `CommunityManagementScreen()` | 👥 Gestión de miembros de la comunidad |
| `'energyRecords'` | `EnergyRecordsScreen()` | 📊 Registros de energía |
| `'pdeAllocation'` | `PDEAllocationScreen()` | ⚙️ Asignación de PDE |
| `'p2pMarket'` | `P2PMarketScreen()` | 🤝 Mercado peer-to-peer |
| `'energyCredits'` | `EnergyCreditsScreen()` | 💳 Sistema de créditos energéticos |
| `'monthlyBilling'` | `MonthlyBillingScreen()` | 💰 Facturación mensual |
| `'reports'` | `ReportsScreen()` | 📈 Reportes y análisis |

---

## 🔐 Sistema de Autenticación

### 🛡️ Mecanismo de Protección de Rutas

```mermaid
graph TB
    A[🚀 App Launch] --> B[💫 Beenergy Widget]
    B --> C[🔍 FutureBuilder]
    C --> D[📱 BlocBeenergy.getUserFromDB]
    D --> E{🔐 ¿Usuario Existe?<br/>idUser != 0}

    E -->|✅ SI| F[💾 Usuario en SQLite]
    E -->|❌ NO| G[❌ Sin Usuario]

    F --> H[🔓 Estado: AUTENTICADO]
    G --> I[🔒 Estado: NO AUTENTICADO]

    H --> J[🏠 NavPages]
    I --> K[🔑 LoginScreen]

    style A fill:#e1f5ff
    style B fill:#fff4e6
    style C fill:#f3e5f5
    style D fill:#e0f2f1
    style E fill:#fff9c4
    style F fill:#c8e6c9
    style G fill:#ffccbc
    style H fill:#a5d6a7
    style I fill:#ef9a9a
    style J fill:#81c784
    style K fill:#ffab91
```

### 🗄️ Persistencia de Sesión

**Base de Datos:** SQLite (`beEnergy.db`)
**Helper:** [database_Helper.dart](../../lib/data/database_Helper.dart)

#### Tablas:
- **`UsuarioLogIn`** - Almacena usuario actualmente autenticado
- **`Usuarios`** - Almacena todos los usuarios registrados

#### Métodos Clave:
```dart
// Obtener usuario autenticado
getUser() → Usuario actual o null

// Agregar usuario en login
addUser(User user) → Guarda sesión

// Eliminar usuario en logout
deleteUserLocal() → Limpia sesión
```

### 🔑 Servicio de Autenticación

**Archivo:** [auth_service.dart](../../lib/core/services/auth_service.dart)
**Cliente API:** Singleton con Dio

#### Endpoints:
| Endpoint | Método | Descripción |
|----------|--------|-------------|
| `/auth/ping` | GET | Verificar conexión |
| `/auth/log-in` | POST | Inicio de sesión |
| `/auth/sign-up` | POST | Registro de usuario |
| `/auth/logout` | POST | Cerrar sesión |
| `/auth/verify-token` | POST | Validar JWT |
| `/auth/forgot-password` | POST | Recuperar contraseña |
| `/auth/reset-password` | POST | Restablecer contraseña |

### 🎫 Gestión de Tokens

**JWT Token:**
- Almacenado en `ApiClient` singleton
- Adjuntado automáticamente a todas las peticiones autenticadas
- Limpiado al cerrar sesión

**Flujo de Token:**
```mermaid
graph LR
    A[🔑 Login] --> B[📨 API Request]
    B --> C[✅ Respuesta + JWT]
    C --> D[💾 ApiClient.setAuthToken]
    D --> E[🔐 Token en Headers]
    E --> F[📡 Requests Autenticados]

    G[🚪 Logout] --> H[🗑️ Clear Token]
    H --> I[❌ Sin Autenticación]

    style A fill:#81c784
    style C fill:#a5d6a7
    style D fill:#c8e6c9
    style E fill:#e8f5e9
    style F fill:#66bb6a
    style G fill:#ef5350
    style H fill:#e57373
    style I fill:#ffccbc
```

---

## 🧭 Patrones de Navegación

### 📍 Tipos de Navegación Utilizados

#### 1. Rutas Nombradas
```dart
Navigator.pushNamed(context, 'routeName');
```
**Ejemplo:**
```dart
Navigator.pushNamed(context, 'home');
Navigator.pushNamed(context, 'trading');
```

#### 2. Navegación Directa (MaterialPageRoute)
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => ScreenWidget())
);
```

#### 3. Extensiones de Context (Custom)
**Archivo:** [context_extensions.dart](../../lib/core/extensions/context_extensions.dart)

```dart
context.push(Widget)           // Push nueva pantalla
context.pop()                  // Regresar
context.pushReplacement()      // Reemplazar actual
context.pushAndRemoveUntil()   // Limpiar stack
```

#### 4. Limpiar Stack (Logout/Login)
```dart
Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (_) => Beenergy()),
  (route) => false  // Elimina todas las rutas previas
);
```

**Uso:** Cerrar sesión, Login exitoso

---

## 📂 Archivos Clave de Navegación

### 🗃️ Estructura de Archivos

| Archivo | Ruta | Responsabilidad |
|---------|------|-----------------|
| **main.dart** | [lib/main.dart](../../lib/main.dart) | ⚙️ Configuración de app + Definición de rutas |
| **routes.dart** | [lib/routes.dart](../../lib/routes.dart) | 📦 Hub de exportación de pantallas |
| **main_screen.dart** | [lib/screens/main_screen.dart](../../lib/screens/main_screen.dart) | 💫 Punto de entrada (BeEnergy) |
| **navigation.dart** | [lib/views/navigation.dart](../../lib/views/navigation.dart) | 📱 Bottom Navigation (NavPages) |
| **context_extensions.dart** | [lib/core/extensions/context_extensions.dart](../../lib/core/extensions/context_extensions.dart) | 🔧 Helpers de navegación |
| **auth_service.dart** | [lib/core/services/auth_service.dart](../../lib/core/services/auth_service.dart) | 🔐 Servicio de autenticación |
| **database_Helper.dart** | [lib/data/database_Helper.dart](../../lib/data/database_Helper.dart) | 💾 Persistencia de sesión SQLite |

---

## 📊 Resumen de Navegación

### 📈 Estadísticas del Proyecto

- **Total de Rutas Nombradas:** 20+
- **Rutas Públicas:** 4
- **Rutas Protegidas Principales:** 6
- **Rutas de Gestión de Comunidad:** 7
- **Pantallas en Bottom Navigation:** 5 (4 visibles + 1 FAB)
- **Niveles de Navegación:** 3 niveles (Principal → Sub-pantallas → Detalles)

### 🎯 Flujo Completo Resumido

```mermaid
graph TB
    A[🚀 INICIO] --> B{🔐 Auth Check}

    B -->|❌ No Auth| C[🔓 FLUJO NO AUTENTICADO]
    B -->|✅ Auth OK| D[🔐 FLUJO AUTENTICADO]

    C --> C1[🔑 Login]
    C --> C2[👤 Register]
    C --> C3[🔄 Password Recovery]

    C1 --> D
    C2 --> D

    D --> D1[🏠 NavPages]

    D1 --> E1[🏡 Home]
    D1 --> E2[⚡ Energy]
    D1 --> E3[💱 Trading]
    D1 --> E4[🔔 Notifications]
    D1 --> E5[👤 Profile]

    E1 --> F1[👥 Community Management]
    E1 --> F2[📊 Marketplace]
    E1 --> F3[📄 Transaction Details]

    E3 --> G1[📤 Send Energy]
    E3 --> G2[🔄 Exchanges]
    E3 --> G3[📝 Records]

    E5 --> H1[✏️ Edit Profile]
    E5 --> H2[🔐 Change Password]
    E5 --> H3[🚪 Logout]

    H3 --> I[💫 Clear Session]
    I --> B

    F1 --> J1[📊 Energy Records]
    F1 --> J2[⚙️ PDE Allocation]
    F1 --> J3[🤝 P2P Market]
    F1 --> J4[💳 Energy Credits]
    F1 --> J5[💰 Monthly Billing]
    F1 --> J6[📈 Reports]

    style A fill:#e1f5ff
    style B fill:#fff9c4
    style C fill:#ffccbc
    style D fill:#c8e6c9
    style D1 fill:#4fc3f7
    style E1 fill:#81c784
    style E2 fill:#ffb74d
    style E3 fill:#9575cd
    style E4 fill:#f06292
    style E5 fill:#4dd0e1
    style F1 fill:#ba68c8
    style H3 fill:#ef5350
    style I fill:#fff4e6
```

---

## 🔍 Leyenda de Símbolos

| Símbolo | Significado |
|---------|-------------|
| 🔓 | Ruta Pública (No requiere autenticación) |
| 🔐 | Ruta Protegida (Requiere autenticación) |
| 🏠 | Bottom Navigation (Navegación principal) |
| 💫 | Punto de entrada / Splash |
| ⚡ | Acción rápida / FAB |
| 🚪 | Cerrar sesión / Logout |
| 📊 | Datos / Reportes |
| 👥 | Gestión de usuarios / Comunidad |
| 💱 | Trading / Intercambio |
| 🔔 | Notificaciones |
| ⚙️ | Configuración / Settings |

---

## 📝 Notas Importantes

### ⚠️ Puntos Clave

1. **Verificación de Autenticación:**
   - Se realiza UNA SOLA VEZ en el punto de entrada (`Beenergy`)
   - NO hay guards de ruta explícitos en navegaciones internas
   - La sesión persiste mientras el usuario no cierre sesión

2. **Persistencia de Estado:**
   - `PageStorage` mantiene posiciones de scroll en Bottom Navigation
   - SQLite mantiene sesión entre cierres de app
   - JWT token se mantiene en memoria durante la sesión

3. **Cierre de Sesión:**
   - Limpia base de datos local
   - Limpia stack de navegación completo
   - Redirige a punto de entrada (BeEnergy)
   - Usuario debe volver a autenticarse

4. **Bottom Navigation:**
   - NO recrea widgets al cambiar de tab
   - Preserva estado de cada pantalla
   - FAB central para acción principal (Trading)

5. **Navegación Jerárquica:**
   - Nivel 1: Bottom Navigation (5 pantallas principales)
   - Nivel 2: Sub-pantallas accesibles desde principales
   - Nivel 3: Pantallas de detalle o formularios

---

## 🚀 Inicio Rápido

### Para Usuarios No Autenticados:
```
1. Abrir App → BeEnergy Splash
2. No hay usuario → LoginScreen
3. Opciones:
   - Login con credenciales existentes → NavPages
   - Registrarse → RegisterScreen → NavPages
   - Recuperar contraseña → NoRecuerdomiclaveScreen
```

### Para Usuarios Autenticados:
```
1. Abrir App → BeEnergy Splash
2. Usuario encontrado en SQLite → NavPages (Bottom Nav)
3. Navegar entre 5 pantallas principales con Bottom Navigation
4. Acceder a sub-funcionalidades desde cada pantalla
5. Cerrar sesión desde Perfil → Volver a LoginScreen
```

---

## 📅 Última Actualización

**Fecha:** 2025
**Versión de la App:** Según package.json
**Documentado por:** Claude Code - Anthropic
**Basado en:** Análisis del código fuente de BeEnergy Flutter App

---

## 📞 Referencias

- **Repositorio:** `d:\Repositorios\Autonoma\BeEnergy`
- **Plataforma:** Flutter (Android/iOS)
- **Arquitectura:** Clean Architecture con BLoC pattern
- **Base de Datos:** SQLite
- **API:** RESTful con autenticación JWT

---

*Este documento mapea toda la estructura de navegación de BeEnergy. Para detalles de implementación específica de cada pantalla, consultar los archivos fuente referenciados.*
