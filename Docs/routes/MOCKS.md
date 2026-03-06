#  Sistema de Mocks - BeEnergy

## 📋 Información General

### Propósito
Este documento define el sistema completo de mocks para el proyecto BeEnergy, permitiendo el desarrollo y testing de la aplicación con datos fake (simulados) o datos reales de la API, mediante un simple switch en tiempo de ejecución.

### Beneficios del Sistema de Mocks

#### Para Desarrollo:
- 🚀 **Desarrollo sin backend:** Trabajar en UI mientras se desarrolla API
- ⚡ **Testing rápido:** Probar flujos sin esperar respuestas de API
- 💾 **Datos consistentes:** Mismo conjunto de datos para pruebas reproducibles
- 🔌 **Offline development:** Trabajar sin conexión a internet
- 🎬 **Demo mode:** Mostrar app con datos realistas sin base de datos real

#### Para Testing:
- 🧪 **Unit tests:** Fácil crear mocks de repositorios
- 🔗 **Integration tests:** Probar flujos completos con fake data
- 📸 **Golden tests:** UI tests con datos consistentes
- ⚠️ **Edge cases:** Fácil crear escenarios específicos (errores, vacíos, etc.)

#### Para QA:
- 🔁 **Reproducibilidad:** Mismos datos = mismos resultados
- ✅ **Cobertura:** Probar todos los escenarios fácilmente
- 📊 **Performance:** Medir sin variabilidad de red
- 🐛 **Regression:** Detectar cambios inesperados en UI

---

## ⚙️ Configuración

### Variables de Entorno

**Archivo:** [.env](../../.env)

```env
# Mock Configuration
ENABLE_MOCKS=true  # true = usar fake data | false = usar API real
```

### Cómo Cambiar entre Mocks y API

1. Abrir archivo `.env` en la raíz del proyecto
2. Cambiar el valor de `ENABLE_MOCKS`:
   - `ENABLE_MOCKS=true` → Usa datos fake (desarrollo/testing)
   - `ENABLE_MOCKS=false` → Usa API real (producción)
3. Reiniciar la aplicación (hot reload funciona en algunos casos)
4. Verificar en logs: `[DataSourceConfig] Using: fake` o `api`

### Arquitectura del Sistema

```
┌─────────────────────┐
│   Screen/Widget     │
│                     │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ RepositoryFactory   │
│ (Decide qué usar)   │
└──────────┬──────────┘
           │
           ├──────────┬──────────┐
           ▼          ▼          ▼
    ┌──────────┐ ┌────────┐ ┌──────────┐
    │  Fake    │ │  API   │ │ Service  │
    │Repository│ │Repository│ │(Legacy) │
    └────┬─────┘ └────┬───┘ └────┬─────┘
         │            │           │
         ▼            ▼           ▼
    ┌──────────┐ ┌────────┐ ┌──────────┐
    │FakeData  │ │ApiClient│ │ApiClient │
    └──────────┘ └────────┘ └──────────┘
```

### Patrones de Código

#### Repository Pattern (Recomendado)
```dart
// 1. Interface abstracta
abstract class CommunityRepository {
  Future<Community> getCommunity();
  Future<List<CommunityMember>> getMembers();
  Future<CommunityStats> getStats({String? period});
}

// 2. Implementación Fake
class CommunityRepositoryFake implements CommunityRepository {
  @override
  Future<Community> getCommunity() async {
    await Future.delayed(Duration(milliseconds: 500)); // Simular delay
    return FakeData.community;
  }
}

// 3. Implementación API
class CommunityRepositoryApi implements CommunityRepository {
  final ApiClient _client = ApiClient.instance;

  @override
  Future<Community> getCommunity() async {
    final response = await _client.get(ApiEndpoints.community);
    return Community.fromJson(response.data);
  }
}

// 4. Factory para crear instancias
class RepositoryFactory {
  static CommunityRepository createCommunityRepository() {
    switch (DataSourceConfig.currentSource) {
      case DataSourceType.fake:
        return CommunityRepositoryFake();
      case DataSourceType.api:
        return CommunityRepositoryApi();
    }
  }
}

// 5. Uso en pantallas
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  late final CommunityRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = RepositoryFactory.createCommunityRepository();
    _loadData();
  }

  Future<void> _loadData() async {
    final community = await _repository.getCommunity();
    // ... usar datos
  }
}
```

---

## 📊 Estado Actual de Implementación

| Componente | Estado Actual | Estado Objetivo | Progreso |
|------------|---------------|-----------------|----------|
| Repository Pattern | ⚠️ Parcial (solo interfaces) | ✅ Completo (fake + API) | 40% |
| Fake Data | ✅ Completo y realista | ✅ Mantener actualizado | 100% |
| API Implementations | ❌ `UnimplementedError` | ✅ Implementado | 0% |
| Runtime Switching | ❌ Compile-time constant | ✅ Runtime desde `.env` | 0% |
| Documentación | 🔄 En progreso | ✅ MOCKS.md completo | 50% |
| Checklist | ✅ Creado | ✅ Actualizado | 10% |

---

## ✅ Checklist de Implementación

### Leyenda de Estado
- ✅ **Completo** - Funciona correctamente
- ⚠️ **Parcial** - Implementado pero incompleto
- ❌ **No implementado** - Pendiente de desarrollar
- 🔄 **En progreso** - Actualmente trabajando
- ⏸️ **Pendiente** - Planeado pero no iniciado
- 🚫 **No aplica** - No es necesario para esta pantalla

---

## 🔓 Flujos No Autenticados (Rutas Públicas)

### Tabla de Checklist

| Pantalla | Modelos | Fake Data | Endpoints API | API Impl | Repository | Estado |
|----------|---------|-----------|---------------|----------|------------|--------|
| **LoginScreen** | `MyUser`, `AuthUser` | ✅ | `/auth/log-in` | ⚠️ Service | ⚠️ Legacy | ⚠️ |
| **RegisterScreen** | `MyUser`, `AuthUser` | ✅ | `/auth/sign-up` | ⚠️ Service | ⚠️ Legacy | ⚠️ |
| **RecuperarContraseña** | - | 🚫 | `/auth/forgot-password` | ⚠️ Service | ⚠️ Legacy | ⚠️ |

### Detalles de Implementación

#### 🔑 LoginScreen
- **Archivo:** [lib/screens/main_screens/Login/login_screen.dart](../../lib/screens/main_screens/Login/login_screen.dart)
- **Modelos:**
  - `MyUser` → [lib/models/my_user.dart](../../lib/models/my_user.dart)
  - `AuthUser` → Definido en repository fake
- **Fake Data:** ✅ 15 usuarios disponibles en `fake_data.dart`
- **Endpoint:** `POST /auth/log-in`
- **Service Actual:** `AuthService.login()` (patrón legacy)
- **Pendiente:**
  - [ ] Crear `AuthRepository` interface
  - [ ] Crear `AuthRepositoryFake`
  - [ ] Crear `AuthRepositoryApi`
  - [ ] Migrar `LoginScreen` a usar Repository
  - [ ] Actualizar `RepositoryFactory`

#### 👤 RegisterScreen
- **Archivo:** [lib/screens/main_screens/Login/register_screen.dart](../../lib/screens/main_screens/Login/register_screen.dart)
- **Modelos:** `MyUser`, `AuthUser`
- **Fake Data:** ✅ Puede agregar usuarios a fake data
- **Endpoint:** `POST /auth/sign-up`
- **Service Actual:** `AuthService.signUp()`
- **Pendiente:**
  - [ ] Migrar a Repository pattern
  - [ ] Implementar registro en fake data (agregar a lista)
  - [ ] Implementar API version

#### 🔄 RecuperarContraseña
- **Archivo:** [lib/screens/main_screens/Login/noRecuerdomiClave_screen.dart](../../lib/screens/main_screens/Login/noRecuerdomiClave_screen.dart)
- **Modelos:** No requiere modelos (solo email)
- **Fake Data:** 🚫 No aplica (solo envía email)
- **Endpoint:** `POST /auth/forgot-password`
- **Service Actual:** `AuthService.forgotPassword()`
- **Pendiente:**
  - [ ] Migrar a Repository pattern
  - [ ] Fake version: simular envío exitoso
  - [ ] API version: llamar endpoint real

---

## 🔐 Navegación Principal (Bottom Navigation - 5 Pantallas)

### Tabla de Checklist

| Pantalla | Modelos | Fake Data | Endpoints API | API Impl | Repository | Estado |
|----------|---------|-----------|---------------|----------|------------|--------|
| **HomeScreen** | `User`, `EnergyRecord`, `Transaction`, `CommunityStats` | ✅ | Multiple | ❌ | ⏸️ | ⏸️ |
| **EnergyScreen** | `EnergyRecord`, `HourlyEnergyData`, `DailyEnergyData` | ✅ | `/energy/*` | ❌ | ⏸️ | ⏸️ |
| **TradingScreen** | `P2POffer`, `P2PContract`, `EnergyCredit` | ✅ | `/trading/*`, `/p2p/*` | ❌ | ⏸️ | ⏸️ |
| **NotificacionesScreen** | `Notification` | ❌ | `/notifications` | ❌ | ⏸️ | ⏸️ |
| **MiCuentaScreen** | `MyUser` | ✅ | `/user/profile` | ❌ | ⏸️ | ⏸️ |

### Detalles de Implementación

#### 🏡 HomeScreen (Dashboard)
- **Archivo:** [lib/screens/main_screens/home/home_screen.dart](../../lib/screens/main_screens/home/home_screen.dart)
- **Índice NavPages:** 0
- **Modelos Necesarios:**
  - `MyUser` → Usuario actual
  - `EnergyRecord` → Datos de energía
  - `Transaction` → Transacciones recientes
  - `CommunityStats` → Estadísticas generales
- **Fake Data:** ✅ Completo
- **Endpoints Necesarios:**
  - `GET /user/profile` → Datos del usuario
  - `GET /energy/stats?period={period}` → Estadísticas de energía
  - `GET /trading/transactions?userId={id}&limit=5` → Transacciones recientes
  - `GET /community/stats?period={period}` → Estadísticas de comunidad
- **Pendiente:**
  - [ ] Crear `HomeRepository` o usar múltiples repositorios
  - [ ] Implementar versiones fake y API
  - [ ] Agregar selector de período
  - [ ] Integrar toggle Admin/Usuario

#### ⚡ EnergyScreen (Monitoreo de Energía)
- **Archivo:** [lib/screens/main_screens/energy/energy_screen.dart](../../lib/screens/main_screens/energy/energy_screen.dart)
- **Índice NavPages:** 1
- **Modelos Necesarios:**
  - `EnergyRecord` → Registro de energía
  - `HourlyEnergyData` → Datos por hora
  - `DailyEnergyData` → Datos diarios
  - `PDEAllocation` → Asignación PDE
- **Fake Data:** ✅ Datos horarios y diarios disponibles
- **Endpoints Necesarios:**
  - `GET /energy/records?userId={id}&period={period}`
  - `GET /energy/hourly?userId={id}&date={date}`
  - `GET /energy/daily?userId={id}&month={month}`
  - `GET /pde/allocations?userId={id}&period={period}`
- **Pendiente:**
  - [ ] Crear `EnergyStatsRepository` (ya existe interface)
  - [ ] Implementar `EnergyStatsRepositoryApi`
  - [ ] Actualizar fake data si es necesario
  - [ ] Agregar gráficos de consumo/producción

#### 💱 TradingScreen (Centro de Trading)
- **Archivo:** [lib/screens/main_screens/Trading/trading_screen.dart](../../lib/screens/main_screens/Trading/trading_screen.dart)
- **Índice NavPages:** 2 (FAB - Floating Action Button)
- **Modelos Necesarios:**
  - `P2POffer` → Ofertas P2P
  - `P2PContract` → Contratos activos
  - `EnergyCredit` → Créditos de energía
  - `CreditTransaction` → Transacciones de créditos
- **Fake Data:** ✅ Ofertas, contratos y créditos disponibles
- **Endpoints Necesarios:**
  - `GET /p2p/offers?period={period}&status=available`
  - `GET /p2p/contracts?userId={id}&period={period}`
  - `GET /credits/balance?userId={id}`
  - `GET /credits/transactions?userId={id}&limit=10`
- **Sub-pantallas:**
  - `EnviaEnergyScreen` → Enviar energía
  - `IntercambiosEnergyScreen` → Intercambios
  - `EnviaRecordScreen` → Registros
- **Pendiente:**
  - [ ] Crear `TradingRepository`
  - [ ] Crear `P2PRepository` (o usar P2PService)
  - [ ] Crear `CreditsRepository`
  - [ ] Implementar versiones API
  - [ ] Migrar sub-pantallas

#### 🔔 NotificacionesScreen (Alertas y Notificaciones)
- **Archivo:** Archivo no localizado (referenciado en routes)
- **Índice NavPages:** 3
- **Modelos Necesarios:**
  - `Notification` → **❌ NO EXISTE - CREAR**
- **Fake Data:** ❌ No existe
- **Endpoints Necesarios:**
  - `GET /notifications?userId={id}`
  - `PUT /notifications/read/{id}`
  - `PUT /notifications/read-all`
- **Pendiente:**
  - [ ] **CREAR modelo `Notification`**
  - [ ] Crear fake data de notificaciones
  - [ ] Crear `NotificationRepository`
  - [ ] Implementar versiones fake y API
  - [ ] Implementar marcado como leído

**Estructura Sugerida del Modelo Notification:**
```dart
class Notification {
  final int id;
  final int userId;
  final String title;
  final String message;
  final NotificationType type; // info, warning, success, error
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata; // Datos adicionales opcionales

  // toJson, fromJson, etc.
}

enum NotificationType {
  info,
  warning,
  success,
  error,
  transaction,
  energyAlert,
  pdeAllocation,
  p2pOffer,
}
```

#### 👤 MiCuentaScreen (Perfil de Usuario)
- **Archivo:** [lib/screens/main_screens/miCuenta/miCuenta.dart](../../lib/screens/main_screens/miCuenta/miCuenta.dart)
- **Índice NavPages:** 4
- **Modelos Necesarios:**
  - `MyUser` → Datos del usuario
- **Fake Data:** ✅ Usuario actual disponible
- **Endpoints Necesarios:**
  - `GET /user/profile`
  - `PUT /user/update`
  - `POST /user/change-password`
  - `POST /auth/logout`
- **Sub-pantallas:**
  - `EditarPerfilScreen` → Editar datos
  - `CambiarClavePerfilScreen` → Cambiar contraseña
  - `CentroNotificacionesPerfilScreen` → Config notificaciones
  - `TutorialScreen` → Tutorial de uso
  - `AprendeScreen` → Recursos educativos
- **Pendiente:**
  - [ ] Crear `UserRepository`
  - [ ] Implementar versiones fake y API
  - [ ] Migrar sub-pantallas

---

## 👥 Gestión de Comunidad (7 Módulos)

### Tabla de Checklist

| Módulo | Modelos | Fake Data | Endpoints API | API Impl | Repository | Estado |
|--------|---------|-----------|---------------|----------|------------|--------|
| **Gestión Comunidad** | `Community`, `CommunityMember`, `CommunityStats` | ✅ | `/community/*` | ❌ | ⚠️ Interface | ⏸️ |
| **Registros Energía** | `EnergyRecord` | ✅ | `/energy/records` | ❌ | ⚠️ Interface | ⏸️ |
| **Asignación PDE** | `PDEAllocation` | ✅ | `/pde/*` | ❌ | ⏸️ | ⏸️ |
| **Mercado P2P** | `P2POffer`, `P2PContract` | ✅ | `/p2p/*` | ❌ | ⏸️ | ⏸️ |
| **Créditos Energía** | `EnergyCredit`, `CreditTransaction` | ✅ | `/credits/*` | ❌ | ⏸️ | ⏸️ |
| **Facturación Mensual** | `UserBilling`, `CommunitySavings`, `RegulatedCosts` | ✅ | `/billing/*` | ❌ | ⏸️ | ⏸️ |
| **Reportes** | Multiple | ✅ | `/reports/*` | ❌ | ⏸️ | ⏸️ |

### Detalles de Implementación

#### 👥 Community Management Screen
- **Archivo:** [lib/screens/main_screens/community/community_management_screen.dart](../../lib/screens/main_screens/community/community_management_screen.dart)
- **Ruta:** `'communityManagement'`
- **Modelos:**
  - `Community` → [lib/models/community_models.dart](../../lib/models/community_models.dart)
  - `CommunityMember` → [lib/models/community_models.dart](../../lib/models/community_models.dart)
  - `CommunityStats` → [lib/models/community_models.dart](../../lib/models/community_models.dart)
- **Fake Data:** ✅ 15 miembros de "Comunidad UAO"
- **Endpoints:**
  - `GET /community` → Datos de la comunidad
  - `GET /community/members` → Lista de miembros
  - `GET /community/stats?period={period}` → Estadísticas
  - `GET /community/member/{id}` → Detalle de miembro
- **Repository:** `CommunityRepository` (interface existe, fake existe)
- **Pendiente:**
  - [ ] Crear `CommunityRepositoryApi`
  - [ ] Actualizar `RepositoryFactory`
  - [ ] Implementar filtros (prosumer/consumer)
  - [ ] Implementar búsqueda

#### 📊 Energy Records Screen
- **Ruta:** `'energyRecords'`
- **Widget:** `EnergyRecordsScreen`
- **Modelos:** `EnergyRecord`
- **Fake Data:** ✅ Registros mensuales disponibles
- **Endpoints:**
  - `GET /energy/records?communityId={id}&period={period}`
  - `GET /energy/records/{userId}?period={period}`
- **Pendiente:**
  - [ ] Localizar archivo de pantalla
  - [ ] Usar `EnergyStatsRepository`
  - [ ] Implementar versión API
  - [ ] Agregar visualización de datos

#### ⚙️ PDE Allocation Screen
- **Ruta:** `'pdeAllocation'`
- **Widget:** `PDEAllocationScreen`
- **Modelos:** `PDEAllocation` → [lib/models/energy_models.dart](../../lib/models/energy_models.dart)
- **Fake Data:** ✅ Asignaciones PDE disponibles
- **Endpoints:**
  - `GET /pde/allocations?period={period}&communityId={id}`
  - `POST /pde/calculate` → Calcular asignación
  - `POST /admin/pde/assign` → Asignar manualmente (admin)
- **Características del Modelo:**
  - Soporte CREG 101 072
  - `surplusType2Only` → Solo excedentes tipo 2
  - `isPDECompliant` → Cumplimiento regulatorio
  - Liquidación mensual (desde enero 2026)
- **Pendiente:**
  - [ ] Crear `PDERepository`
  - [ ] Implementar fake y API
  - [ ] Implementar calculadora de PDE
  - [ ] Validación regulatoria

#### 🤝 P2P Market Screen
- **Ruta:** `'p2pMarket'`
- **Widget:** `P2PMarketScreen`
- **Modelos:**
  - `P2POffer` → [lib/models/p2p_offer.dart](../../lib/models/p2p_offer.dart)
  - `P2PContract` → [lib/models/p2p_models.dart](../../lib/models/p2p_models.dart)
- **Fake Data:** ✅ Ofertas y contratos disponibles
- **Service Actual:** `P2PService` (in-memory, no usa Repository pattern)
- **Endpoints:**
  - `GET /p2p/offers?period={period}`
  - `POST /p2p/offers/create`
  - `POST /p2p/offers/{id}/accept`
  - `DELETE /p2p/offers/{id}/cancel`
  - `GET /p2p/contracts?userId={id}&period={period}`
  - `GET /p2p/market-stats?period={period}`
- **Pendiente:**
  - [ ] Crear `P2PRepository`
  - [ ] Migrar `P2PService` a Repository pattern
  - [ ] Implementar versión API
  - [ ] Mantener validación de VE (Valor de Escasez)
  - [ ] Mantener audit logs regulatorios

#### 💳 Energy Credits Screen
- **Ruta:** `'energyCredits'`
- **Widget:** `EnergyCreditsScreen`
- **Modelos:**
  - `EnergyCredit` → [lib/models/p2p_models.dart](../../lib/models/p2p_models.dart)
  - `CreditTransaction` → [lib/models/p2p_models.dart](../../lib/models/p2p_models.dart)
- **Fake Data:** ✅ Balance y transacciones disponibles
- **Endpoints:**
  - `GET /credits/balance?userId={id}`
  - `GET /credits/transactions?userId={id}`
  - `POST /credits/transfer` → Transferir créditos
- **Pendiente:**
  - [ ] Crear `CreditsRepository`
  - [ ] Implementar versiones fake y API
  - [ ] Implementar transferencias

#### 💰 Monthly Billing Screen
- **Ruta:** `'monthlyBilling'`
- **Widget:** `MonthlyBillingScreen`
- **Modelos:**
  - `UserBilling` → [lib/models/billing_models.dart](../../lib/models/billing_models.dart)
  - `CommunitySavings` → [lib/models/billing_models.dart](../../lib/models/billing_models.dart)
  - `RegulatedCosts` → [lib/models/billing_models.dart](../../lib/models/billing_models.dart)
- **Fake Data:** ✅ Escenarios de facturación disponibles
- **Endpoints:**
  - `GET /billing/user/{userId}?period={period}`
  - `GET /billing/community?period={period}`
  - `GET /billing/costs` → Costos regulados (CU, MC, PCN)
  - `GET /billing/compare?userId={id}&period={period}` → Comparar escenarios
- **Características:**
  - Comparación de escenarios: Traditional, Credits, PDE, P2P
  - Cálculo de ahorros
  - Costos regulados actualizados
- **Pendiente:**
  - [ ] Crear `BillingRepository`
  - [ ] Implementar versiones fake y API
  - [ ] Implementar comparador de escenarios
  - [ ] Gráficos de ahorros

#### 📈 Reports Screen
- **Ruta:** `'reports'`
- **Widget:** `ReportsScreen`
- **Modelos:** Múltiples (depende del reporte)
- **Fake Data:** ✅ Datos disponibles para generar reportes
- **Endpoints:**
  - `GET /reports/energy?period={period}`
  - `GET /reports/trading?period={period}`
  - `GET /reports/community?period={period}`
  - `GET /reports/pde?period={period}`
  - `POST /reports/generate` → Generar reporte personalizado
  - `GET /reports/export/{id}?format={pdf|excel}`
- **Pendiente:**
  - [ ] Crear `ReportsRepository`
  - [ ] Implementar versiones fake y API
  - [ ] Implementar generación de PDFs
  - [ ] Implementar export a Excel

---

## 🛒 Marketplace

### Tabla de Checklist

| Pantalla | Modelos | Fake Data | Endpoints API | API Impl | Repository | Estado |
|----------|---------|-----------|---------------|----------|------------|--------|
| **Consumer Marketplace** | `ConsumerOffer` | ✅ | `/consumer-offers/*` | ❌ | ⏸️ | ⏸️ |
| **Bolsa/Exchange** | `P2POffer`, `P2PContract` | ✅ | `/exchange/*` | ❌ | ⏸️ | ⏸️ |

### Detalles de Implementación

#### 🛒 Consumer Marketplace
- **Pantallas:**
  - `ConsumerMarketplaceScreen` → Marketplace principal
  - `ConsumerCreateOfferScreen` → Crear oferta
  - `ConsumerOffersListScreen` → Listar ofertas
  - `OfferDetailAcceptanceScreen` → Detalle y aceptación
- **Modelos:**
  - `ConsumerOffer` → [lib/models/consumer_offer.dart](../../lib/models/consumer_offer.dart)
- **Fake Data:** ✅ Ofertas de consumidores disponibles
- **Endpoints:**
  - `GET /consumer-offers?period={period}&status={status}`
  - `POST /consumer-offers/create`
  - `PUT /consumer-offers/{id}/match` → Emparejar con prosumer
  - `DELETE /consumer-offers/{id}/cancel`
- **Características:**
  - Porcentaje de PDE solicitado
  - Precio por kWh
  - Estados: pending, matched, partiallyMatched, cancelled, expired
- **Pendiente:**
  - [ ] Crear `ConsumerOfferRepository`
  - [ ] Implementar versiones fake y API
  - [ ] Implementar matching algorithm
  - [ ] Integrar con liquidación

#### 📊 Bolsa/Exchange Screen
- **Pantallas:**
  - `BolsaScreen` → Bolsa/Marketplace
  - `ConfirmBolsaScreen` → Confirmación de intercambio
- **Modelos:**
  - `P2POffer`
  - `P2PContract`
- **Fake Data:** ✅ Ofertas y contratos disponibles
- **Endpoints:**
  - `GET /exchange/available?period={period}`
  - `POST /exchange/create`
  - `POST /exchange/{id}/accept`
  - `GET /exchange/my-exchanges?userId={id}`
- **Pendiente:**
  - [ ] Crear `ExchangeRepository` (o usar P2PRepository)
  - [ ] Implementar versiones fake y API
  - [ ] Implementar confirmación de intercambio

---

## 🔧 Administración

### Tabla de Checklist

| Pantalla | Modelos | Fake Data | Endpoints API | API Impl | Repository | Estado |
|----------|---------|-----------|---------------|----------|------------|--------|
| **Admin Liquidation Panel** | `LiquidationSession`, `LiquidationMatch` | ✅ | `/liquidation/*` | ❌ | ⏸️ | ⏸️ |
| **Admin PDE Assignment** | `PDEAllocation` | ✅ | `/admin/pde/*` | ❌ | ⏸️ | ⏸️ |
| **Prosumer Create Offer** | `P2POffer` | ✅ | `/prosumer/offers/*` | ❌ | ⏸️ | ⏸️ |

### Detalles de Implementación

#### 💰 Admin Liquidation Panel
- **Pantalla:** `AdminLiquidationPanel`
- **Modelos:**
  - `LiquidationSession` → [lib/models/liquidation_session.dart](../../lib/models/liquidation_session.dart)
  - `LiquidationMatch` → Definido en liquidation_session.dart
  - `ConsumerOffer`
  - `P2PContract`
- **Fake Data:** ✅ Sesiones de liquidación disponibles
- **Service Actual:** `LiquidationService` (in-memory)
- **Endpoints:**
  - `GET /liquidation/sessions?period={period}`
  - `POST /liquidation/create`
  - `POST /liquidation/{id}/manual-match`
  - `POST /liquidation/{id}/auto-match`
  - `POST /liquidation/{id}/finalize`
  - `GET /liquidation/{id}/pde-availability`
- **Características:**
  - Modo manual vs automático
  - Matching de ofertas de consumidores con PDE disponible
  - Validación regulatoria
  - Finalización y creación de contratos P2P
- **Pendiente:**
  - [ ] Crear `LiquidationRepository`
  - [ ] Migrar `LiquidationService` a Repository
  - [ ] Implementar versión API
  - [ ] Mantener lógica de matching
  - [ ] Mantener validaciones regulatorias

#### ⚙️ Admin PDE Assignment Screen
- **Pantalla:** `AdminPDEAssignmentScreen`
- **Modelos:** `PDEAllocation`
- **Fake Data:** ✅ Asignaciones disponibles
- **Endpoints:**
  - `POST /admin/pde/assign` → Asignar PDE manualmente
  - `POST /admin/pde/calculate` → Calcular automáticamente
  - `PUT /admin/pde/{id}/override` → Override asignación
- **Pendiente:**
  - [ ] Crear endpoints de admin
  - [ ] Implementar versión API
  - [ ] Validar permisos de admin

#### ⚡ Prosumer Create Offer Screen
- **Pantalla:** `ProsumerCreateOfferScreen`
- **Modelos:** `P2POffer`
- **Fake Data:** ✅ Puede crear ofertas
- **Endpoints:**
  - `POST /prosumer/offers/create`
  - `GET /prosumer/offers/my-offers?userId={id}`
  - `DELETE /prosumer/offers/{id}/cancel`
- **Pendiente:**
  - [ ] Usar `P2PRepository`
  - [ ] Implementar versión API
  - [ ] Validar energía disponible
  - [ ] Validar precio dentro de rangos VE

---

## 📦 Modelos del Proyecto

### Autenticación

| Modelo | Archivo | toJson | fromJson | Fake Data | Estado |
|--------|---------|--------|----------|-----------|--------|
| **MyUser** | [lib/models/my_user.dart](../../lib/models/my_user.dart) | ✅ | ✅ (toMap) | ✅ | ✅ |
| **AuthUser** | Repository fake | ✅ | ✅ | ✅ | ⚠️ |

**Nota:** `MyUser` es para almacenamiento local (SQLite), `AuthUser` es el modelo de respuesta de API de autenticación.

### Energía

| Modelo | Archivo | toJson | fromJson | Fake Data | Estado |
|--------|---------|--------|----------|-----------|--------|
| **EnergyRecord** | [lib/models/energy_models.dart](../../lib/models/energy_models.dart) | ✅ | ✅ | ✅ | ✅ |
| **PDEAllocation** | [lib/models/energy_models.dart](../../lib/models/energy_models.dart) | ✅ | ✅ | ✅ | ✅ |
| **HourlyEnergyData** | [lib/models/energy_models.dart](../../lib/models/energy_models.dart) | ✅ | ✅ | ✅ | ✅ |
| **HourlyAnalysisData** | [lib/models/energy_models.dart](../../lib/models/energy_models.dart) | ✅ | ✅ | ✅ | ✅ |
| **DailyEnergyData** | [lib/models/energy_models.dart](../../lib/models/energy_models.dart) | ✅ | ✅ | ✅ | ✅ |

**Características:**
- `EnergyRecord`: Clasificación CREG 101 072 (surplusType1, surplusType2)
- `PDEAllocation`: Compliance regulatorio, liquidación mensual
- Datos horarios y diarios para gráficos

### Comunidad

| Modelo | Archivo | toJson | fromJson | Fake Data | Estado |
|--------|---------|--------|----------|-----------|--------|
| **Community** | [lib/models/community_models.dart](../../lib/models/community_models.dart) | ✅ | ✅ | ✅ | ✅ |
| **CommunityMember** | [lib/models/community_models.dart](../../lib/models/community_models.dart) | ✅ | ✅ | ✅ | ✅ |
| **CommunityStats** | [lib/models/community_models.dart](../../lib/models/community_models.dart) | ✅ | ✅ | ✅ | ✅ |

**Características:**
- `CommunityMember`: Categoría (producer, consumer, prosumer), NIU, documentos
- `CommunityStats`: Estadísticas agregadas de la comunidad

### Trading P2P

| Modelo | Archivo | toJson | fromJson | Fake Data | Estado |
|--------|---------|--------|----------|-----------|--------|
| **P2POffer** | [lib/models/p2p_offer.dart](../../lib/models/p2p_offer.dart) | ✅ | ✅ | ✅ | ✅ |
| **P2PContract** | [lib/models/p2p_models.dart](../../lib/models/p2p_models.dart) | ✅ | ✅ | ✅ | ✅ |
| **EnergyCredit** | [lib/models/p2p_models.dart](../../lib/models/p2p_models.dart) | ✅ | ✅ | ✅ | ✅ |
| **CreditTransaction** | [lib/models/p2p_models.dart](../../lib/models/p2p_models.dart) | ✅ | ✅ | ✅ | ✅ |

**Características:**
- `P2POffer`: Estados (available, partial, sold, cancelled, expired)
- `P2PContract`: Validación VE, compliance regulatorio
- Sistema de créditos energéticos

### Facturación

| Modelo | Archivo | toJson | fromJson | Fake Data | Estado |
|--------|---------|--------|----------|-----------|--------|
| **UserBilling** | [lib/models/billing_models.dart](../../lib/models/billing_models.dart) | ✅ | ✅ | ✅ | ✅ |
| **RegulatedCosts** | [lib/models/billing_models.dart](../../lib/models/billing_models.dart) | ✅ | ✅ | ✅ | ✅ |
| **CommunitySavings** | [lib/models/billing_models.dart](../../lib/models/billing_models.dart) | ✅ | ✅ | ✅ | ✅ |

**Características:**
- Comparación de escenarios (traditional, credits, PDE, P2P)
- Cálculo de ahorros
- Costos regulados (CU, MC, PCN)

### Regulatorio

| Modelo | Archivo | toJson | fromJson | Fake Data | Estado |
|--------|---------|--------|----------|-----------|--------|
| **ConsumerOffer** | [lib/models/consumer_offer.dart](../../lib/models/consumer_offer.dart) | ✅ | ✅ | ✅ | ✅ |
| **LiquidationSession** | [lib/models/liquidation_session.dart](../../lib/models/liquidation_session.dart) | ✅ | ✅ | ✅ | ✅ |
| **LiquidationMatch** | [lib/models/liquidation_session.dart](../../lib/models/liquidation_session.dart) | ✅ | ✅ | ✅ | ✅ |

**Características:**
- Sistema de liquidación manual/automático
- Matching de ofertas de consumidores
- Validación regulatoria

### Modelos Faltantes

| Modelo | Necesario Para | Prioridad | Estado |
|--------|----------------|-----------|--------|
| **Notification** | NotificacionesScreen | Alta | ❌ Crear |

---

## 🌐 Endpoints API

### Autenticación

| Endpoint | Método | Request | Response | Service | Repository | Estado |
|----------|--------|---------|----------|---------|------------|--------|
| `/auth/ping` | GET | - | `{status: string}` | ✅ | ⏸️ | ⚠️ |
| `/auth/log-in` | POST | `{email, password}` | `AuthUser` | ✅ | ⏸️ | ⚠️ |
| `/auth/sign-up` | POST | `{name, email, password}` | `AuthUser` | ✅ | ⏸️ | ⚠️ |
| `/auth/logout` | POST | - | `{success: bool}` | ✅ | ⏸️ | ⚠️ |
| `/auth/verify-token` | POST | `{token}` | `{valid: bool}` | ✅ | ⏸️ | ⚠️ |
| `/auth/forgot-password` | POST | `{email}` | `{sent: bool}` | ✅ | ⏸️ | ⚠️ |
| `/auth/reset-password` | POST | `{token, password}` | `{success: bool}` | ✅ | ⏸️ | ⚠️ |

### Usuario

| Endpoint | Método | Request | Response | Service | Repository | Estado |
|----------|--------|---------|----------|---------|------------|--------|
| `/user/profile` | GET | - | `User` | ❌ | ⏸️ | ❌ |
| `/user/update` | PUT | `User` | `User` | ❌ | ⏸️ | ❌ |
| `/user/change-password` | POST | `{old, new}` | `{success: bool}` | ❌ | ⏸️ | ❌ |

### Energía

| Endpoint | Método | Request | Response | Service | Repository | Estado |
|----------|--------|---------|----------|---------|------------|--------|
| `/energy/data` | GET | `?period={period}` | `EnergyRecord[]` | ❌ | ⚠️ | ❌ |
| `/energy/history` | GET | `?userId={id}&period={period}` | `EnergyRecord[]` | ❌ | ⚠️ | ❌ |
| `/energy/stats` | GET | `?period={period}` | `EnergyStats` | ❌ | ⚠️ | ❌ |
| `/energy/records` | GET | `?userId={id}&period={period}` | `EnergyRecord[]` | ❌ | ⚠️ | ❌ |
| `/energy/hourly` | GET | `?userId={id}&date={date}` | `HourlyEnergyData[]` | ❌ | ⚠️ | ❌ |
| `/energy/daily` | GET | `?userId={id}&month={month}` | `DailyEnergyData[]` | ❌ | ⚠️ | ❌ |

### Trading/Transacciones

| Endpoint | Método | Request | Response | Service | Repository | Estado |
|----------|--------|---------|----------|---------|------------|--------|
| `/trading/create` | POST | `Transaction` | `Transaction` | ❌ | ⚠️ | ❌ |
| `/trading/transactions` | GET | `?userId={id}` | `Transaction[]` | ❌ | ⚠️ | ❌ |
| `/trading/transaction/{id}` | GET | - | `Transaction` | ❌ | ⚠️ | ❌ |
| `/trading/cancel/{id}` | DELETE | - | `{success: bool}` | ❌ | ⚠️ | ❌ |

### P2P Market

| Endpoint | Método | Request | Response | Service | Repository | Estado |
|----------|--------|---------|----------|---------|------------|--------|
| `/p2p/offers` | GET | `?period={period}` | `P2POffer[]` | ⚠️ Memory | ⏸️ | ⚠️ |
| `/p2p/offers/create` | POST | `P2POffer` | `P2POffer` | ⚠️ Memory | ⏸️ | ⚠️ |
| `/p2p/offers/{id}/accept` | POST | `{buyerId, energyKwh}` | `P2PContract` | ⚠️ Memory | ⏸️ | ⚠️ |
| `/p2p/offers/{id}/cancel` | DELETE | `{reason}` | `{success: bool}` | ⚠️ Memory | ⏸️ | ⚠️ |
| `/p2p/contracts` | GET | `?userId={id}&period={period}` | `P2PContract[]` | ⚠️ Memory | ⏸️ | ⚠️ |
| `/p2p/market-stats` | GET | `?period={period}` | `MarketStats` | ⚠️ Memory | ⏸️ | ⚠️ |

### Community

| Endpoint | Método | Request | Response | Service | Repository | Estado |
|----------|--------|---------|----------|---------|------------|--------|
| `/community` | GET | - | `Community` | ❌ | ⚠️ | ❌ |
| `/community/members` | GET | - | `CommunityMember[]` | ❌ | ⚠️ | ❌ |
| `/community/stats` | GET | `?period={period}` | `CommunityStats` | ❌ | ⚠️ | ❌ |
| `/community/member/{id}` | GET | - | `CommunityMember` | ❌ | ⚠️ | ❌ |

### PDE

| Endpoint | Método | Request | Response | Service | Repository | Estado |
|----------|--------|---------|----------|---------|------------|--------|
| `/pde/allocations` | GET | `?period={period}` | `PDEAllocation[]` | ❌ | ⏸️ | ❌ |
| `/pde/calculate` | POST | `{period}` | `PDEAllocation[]` | ❌ | ⏸️ | ❌ |
| `/admin/pde/assign` | POST | `PDEAllocation` | `PDEAllocation` | ❌ | ⏸️ | ❌ |
| `/admin/pde/{id}/override` | PUT | `PDEAllocation` | `PDEAllocation` | ❌ | ⏸️ | ❌ |

### Billing

| Endpoint | Método | Request | Response | Service | Repository | Estado |
|----------|--------|---------|----------|---------|------------|--------|
| `/billing/user/{userId}` | GET | `?period={period}` | `UserBilling` | ❌ | ⏸️ | ❌ |
| `/billing/community` | GET | `?period={period}` | `CommunitySavings` | ❌ | ⏸️ | ❌ |
| `/billing/costs` | GET | - | `RegulatedCosts` | ❌ | ⏸️ | ❌ |
| `/billing/compare` | GET | `?userId={id}&period={period}` | `BillingComparison` | ❌ | ⏸️ | ❌ |

### Liquidation (Admin)

| Endpoint | Método | Request | Response | Service | Repository | Estado |
|----------|--------|---------|----------|---------|------------|--------|
| `/liquidation/sessions` | GET | `?period={period}` | `LiquidationSession[]` | ⚠️ Memory | ⏸️ | ⚠️ |
| `/liquidation/create` | POST | `LiquidationSession` | `LiquidationSession` | ⚠️ Memory | ⏸️ | ⚠️ |
| `/liquidation/{id}/manual-match` | POST | `LiquidationMatch` | `LiquidationMatch` | ⚠️ Memory | ⏸️ | ⚠️ |
| `/liquidation/{id}/auto-match` | POST | - | `LiquidationMatch[]` | ⚠️ Memory | ⏸️ | ⚠️ |
| `/liquidation/{id}/finalize` | POST | - | `P2PContract[]` | ⚠️ Memory | ⏸️ | ⚠️ |
| `/liquidation/{id}/pde-availability` | GET | - | `PDEAvailabilitySnapshot` | ⚠️ Memory | ⏸️ | ⚠️ |

### Consumer Offers

| Endpoint | Método | Request | Response | Service | Repository | Estado |
|----------|--------|---------|----------|---------|------------|--------|
| `/consumer-offers` | GET | `?period={period}` | `ConsumerOffer[]` | ❌ | ⏸️ | ❌ |
| `/consumer-offers/create` | POST | `ConsumerOffer` | `ConsumerOffer` | ❌ | ⏸️ | ❌ |
| `/consumer-offers/{id}/match` | PUT | `{prosumerId, energyKwh}` | `ConsumerOffer` | ❌ | ⏸️ | ❌ |
| `/consumer-offers/{id}/cancel` | DELETE | - | `{success: bool}` | ❌ | ⏸️ | ❌ |

### Notifications

| Endpoint | Método | Request | Response | Service | Repository | Estado |
|----------|--------|---------|----------|---------|------------|--------|
| `/notifications` | GET | - | `Notification[]` | ❌ | ⏸️ | ❌ |
| `/notifications/read/{id}` | PUT | - | `{success: bool}` | ❌ | ⏸️ | ❌ |
| `/notifications/read-all` | PUT | - | `{success: bool}` | ❌ | ⏸️ | ❌ |

### Exchange

| Endpoint | Método | Request | Response | Service | Repository | Estado |
|----------|--------|---------|----------|---------|------------|--------|
| `/exchange/available` | GET | `?period={period}` | `Exchange[]` | ❌ | ⏸️ | ❌ |
| `/exchange/create` | POST | `Exchange` | `Exchange` | ❌ | ⏸️ | ❌ |
| `/exchange/{id}/accept` | POST | - | `P2PContract` | ❌ | ⏸️ | ❌ |
| `/exchange/my-exchanges` | GET | `?userId={id}` | `Exchange[]` | ❌ | ⏸️ | ❌ |

### Credits

| Endpoint | Método | Request | Response | Service | Repository | Estado |
|----------|--------|---------|----------|---------|------------|--------|
| `/credits/balance` | GET | `?userId={id}` | `EnergyCredit` | ❌ | ⏸️ | ❌ |
| `/credits/transactions` | GET | `?userId={id}` | `CreditTransaction[]` | ❌ | ⏸️ | ❌ |
| `/credits/transfer` | POST | `{fromId, toId, amount}` | `CreditTransaction` | ❌ | ⏸️ | ❌ |

### Reports

| Endpoint | Método | Request | Response | Service | Repository | Estado |
|----------|--------|---------|----------|---------|------------|--------|
| `/reports/energy` | GET | `?period={period}` | `EnergyReport` | ❌ | ⏸️ | ❌ |
| `/reports/trading` | GET | `?period={period}` | `TradingReport` | ❌ | ⏸️ | ❌ |
| `/reports/community` | GET | `?period={period}` | `CommunityReport` | ❌ | ⏸️ | ❌ |
| `/reports/pde` | GET | `?period={period}` | `PDEReport` | ❌ | ⏸️ | ❌ |
| `/reports/generate` | POST | `ReportConfig` | `Report` | ❌ | ⏸️ | ❌ |
| `/reports/export/{id}` | GET | `?format={pdf,excel}` | `File` | ❌ | ⏸️ | ❌ |

---

## 🎭 Fake Data

### Archivos de Fake Data

| Archivo | Descripción | Período | Líneas | Estado |
|---------|-------------|---------|--------|--------|
| [lib/data/fake_data.dart](../../lib/data/fake_data.dart) | Datos noviembre 2025 (15 usuarios) | 2025-11 | ~1500+ | ✅ |
| [lib/data/fake_data_phase2.dart](../../lib/data/fake_data_phase2.dart) | Datos enero 2026 (admin simulation) | 2026-01 | ~800+ | ✅ |
| [lib/data/fake_periods_data.dart](../../lib/data/fake_periods_data.dart) | Soporte multi-período | Multiple | ~300+ | ✅ |

### Contenido de fake_data.dart (Noviembre 2025)

**Comunidad:**
- ✅ 1 comunidad: "Comunidad UAO"
- ✅ 15 usuarios:
  - 10 consumers (usuarios 13-22)
  - 5 prosumers (usuarios 1-5)

**Datos Energéticos:**
- ✅ `EnergyRecord[]` → Producción/consumo mensual
- ✅ `PDEAllocation[]` → Asignaciones PDE
- ✅ `HourlyEnergyData[]` → Datos horarios (24 horas)
- ✅ `HourlyAnalysisData[]` → Análisis horario detallado
- ✅ `DailyEnergyData[]` → Datos diarios (30 días)

**Trading P2P:**
- ✅ `P2PContract[]` → 5 contratos de ejemplo
- ✅ `EnergyCredit[]` → Balance de créditos para cada usuario
- ✅ `CreditTransaction[]` → Historial de transacciones

**Facturación:**
- ✅ `UserBilling[]` → Facturación por usuario (4 escenarios)
- ✅ `RegulatedCosts` → Costos regulados (CU, MC, PCN)
- ✅ `CommunitySavings` → Ahorros de la comunidad

**Estadísticas:**
- ✅ `CommunityStats` → Estadísticas agregadas
- ✅ Métodos helper: `calculateStats()`, `getEnergyRecords()`, etc.

### Contenido de fake_data_phase2.dart (Enero 2026)

**Usuarios Admin Simulation:**
- ✅ 2 usuarios:
  - 1 prosumer (María González, 5kW instalados)
  - 1 consumer (Carlos Rodríguez)

**Datos Regulatorios:**
- ✅ VE (Valor de Escasez) calculations
- ✅ Clasificación de excedentes (Tipo 1 / Tipo 2)
- ✅ PDE allocation con regulatory compliance
- ✅ Liquidación mensual (desde enero 2026)

**P2P Market:**
- ✅ `P2POffer[]` → Ofertas activas
- ✅ `P2PContract[]` → Contratos con validación VE
- ✅ `RegulatoryAuditLog[]` → Logs de auditoría

**Liquidation:**
- ✅ `LiquidationSession[]` → Sesiones de liquidación
- ✅ `LiquidationMatch[]` → Matches manual/automático
- ✅ `ConsumerOffer[]` → Ofertas de consumidores
- ✅ `PDEAvailabilitySnapshot` → Snapshot de PDE disponible

### Contenido de fake_periods_data.dart

**Soporte Multi-Período:**
- ✅ Generación de datos para múltiples períodos
- ✅ Helpers para obtener datos por período
- ✅ Compatibilidad con cambios de período en UI

### Uso de Fake Data en Repositorios

**Ejemplo de Uso:**
```dart
// lib/repositories/impl/community_repository_fake.dart
import '../../data/fake_data.dart';

class CommunityRepositoryFake implements CommunityRepository {
  @override
  Future<Community> getCommunity() async {
    await Future.delayed(Duration(milliseconds: 500));
    return FakeData.community;
  }

  @override
  Future<List<CommunityMember>> getMembers() async {
    await Future.delayed(Duration(milliseconds: 300));
    return FakeData.members;
  }

  @override
  Future<CommunityStats> getStats({String? period}) async {
    await Future.delayed(Duration(milliseconds: 400));

    // Si se especifica período, filtrar por período
    if (period != null) {
      return FakeData.getStatsByPeriod(period);
    }

    // Calcular stats actuales
    return FakeData.calculateStats();
  }
}
```

**Características de Fake Data:**
- ⏱️ **Delays simulados:** Para imitar latencia de red (300-500ms)
- 📊 **Datos realistas:** Basados en casos de uso reales
- 🔄 **Datos variables:** Algunos métodos devuelven datos diferentes cada vez
- ⚠️ **Edge cases:** Incluye casos límite (usuarios sin energía, ofertas expiradas, etc.)
- 🎯 **Completo:** Cubre todos los modelos del sistema

---

## 🛠️ Implementación de Repositorios

### Repositorios Existentes

| Repository | Interface | Fake Impl | API Impl | Factory | Estado |
|------------|-----------|-----------|----------|---------|--------|
| **AuthRepository** | ❌ | ❌ | ❌ | ❌ | ⏸️ Crear |
| **CommunityRepository** | ✅ | ✅ | ❌ | ✅ | ⚠️ Implementar API |
| **TransactionRepository** | ✅ | ✅ | ❌ | ✅ | ⚠️ Implementar API |
| **EnergyStatsRepository** | ✅ | ✅ | ❌ | ✅ | ⚠️ Implementar API |

### Repositorios Pendientes de Crear

| Repository | Pantallas | Modelos | Prioridad | Estado |
|------------|-----------|---------|-----------|--------|
| **UserRepository** | MiCuentaScreen, HomeScreen | MyUser | Alta | ⏸️ |
| **P2PRepository** | TradingScreen, P2PMarketScreen | P2POffer, P2PContract | Alta | ⏸️ |
| **PDERepository** | PDEAllocationScreen | PDEAllocation | Media | ⏸️ |
| **BillingRepository** | MonthlyBillingScreen | UserBilling, CommunitySavings | Media | ⏸️ |
| **CreditsRepository** | EnergyCreditsScreen | EnergyCredit, CreditTransaction | Media | ⏸️ |
| **LiquidationRepository** | AdminLiquidationPanel | LiquidationSession | Baja | ⏸️ |
| **ConsumerOfferRepository** | ConsumerMarketplace | ConsumerOffer | Baja | ⏸️ |
| **NotificationRepository** | NotificacionesScreen | Notification | Media | ⏸️ |
| **ReportsRepository** | ReportsScreen | Multiple | Baja | ⏸️ |

### Archivos a Crear para API Implementations

| Archivo | Repository | Prioridad | Estado |
|---------|------------|-----------|--------|
| `lib/repositories/impl/auth_repository_api.dart` | AuthRepository | Alta | ⏸️ |
| `lib/repositories/impl/community_repository_api.dart` | CommunityRepository | Alta | ⏸️ |
| `lib/repositories/impl/transaction_repository_api.dart` | TransactionRepository | Alta | ⏸️ |
| `lib/repositories/impl/energy_stats_repository_api.dart` | EnergyStatsRepository | Alta | ⏸️ |
| `lib/repositories/impl/user_repository_api.dart` | UserRepository | Alta | ⏸️ |
| `lib/repositories/impl/p2p_repository_api.dart` | P2PRepository | Alta | ⏸️ |
| `lib/repositories/impl/pde_repository_api.dart` | PDERepository | Media | ⏸️ |
| `lib/repositories/impl/billing_repository_api.dart` | BillingRepository | Media | ⏸️ |
| `lib/repositories/impl/credits_repository_api.dart` | CreditsRepository | Media | ⏸️ |
| `lib/repositories/impl/liquidation_repository_api.dart` | LiquidationRepository | Baja | ⏸️ |
| `lib/repositories/impl/consumer_offer_repository_api.dart` | ConsumerOfferRepository | Baja | ⏸️ |
| `lib/repositories/impl/notification_repository_api.dart` | NotificationRepository | Media | ⏸️ |
| `lib/repositories/impl/reports_repository_api.dart` | ReportsRepository | Baja | ⏸️ |

---

## 📝 Notas de Implementación

### Diferencia entre Repository y Service Pattern

**Repository Pattern (Recomendado):**
```dart
// Abstracción clara
abstract class AuthRepository {
  Future<AuthResult> login(LoginCredentials credentials);
  Future<AuthResult> register(RegisterData data);
}

// Factory automático según ENABLE_MOCKS
final repo = RepositoryFactory.createAuthRepository();
```

**Service Pattern (Legacy):**
```dart
// Llama directamente a API, no tiene fake version
class AuthService {
  Future<Map<String, dynamic>> login({email, password}) async {
    final response = await _client.post(ApiEndpoints.login, ...);
    return response.data;
  }
}
```

**Decisión:** Migrar todo a Repository Pattern para consistencia

### Servicios In-Memory a Migrar

| Service | Modelos | Usado En | Migrar a Repository | Prioridad |
|---------|---------|----------|---------------------|-----------|
| **P2PService** | P2POffer, P2PContract | P2PMarketScreen, TradingScreen | P2PRepository | Alta |
| **LiquidationService** | LiquidationSession, LiquidationMatch | AdminLiquidationPanel | LiquidationRepository | Media |
| **ConsumerOfferService** | ConsumerOffer | ConsumerMarketplace | ConsumerOfferRepository | Media |

### Validaciones a Mantener

Al implementar versiones API, **mantener las validaciones existentes:**

1. **P2P Market:**
   - Precio dentro de rangos VE (Valor de Escasez)
   - Energía disponible del prosumer
   - Validación regulatoria CREG 101 072

2. **PDE Allocation:**
   - Solo excedentes Tipo 2
   - Compliance regulatorio (`isPDECompliant`)
   - Validación de artículos regulatorios

3. **Liquidation:**
   - Matching algorithm (manual/automático)
   - Validación de PDE disponible
   - Audit logs regulatorios

4. **Billing:**
   - Cálculo de costos regulados (CU, MC, PCN)
   - Escenarios de comparación
   - Cálculo de ahorros

### Manejo de Errores

**Fake Repositories:**
- Simular delays de red (300-500ms)
- Ocasionalmente retornar errores simulados (10% de probabilidad) para testing
- Usar `Future.error()` para simular errores de API

**API Repositories:**
- Usar `ApiClient` con manejo de excepciones
- Capturar excepciones de Dio y convertir a excepciones custom:
  - `BadRequestException` (400)
  - `UnauthorizedException` (401)
  - `NotFoundException` (404)
  - `InternalServerException` (500)
- Loggear errores con contexto

### Testing

**Para cada Repository:**
1. **Unit Tests:**
   - Test fake implementation
   - Test API implementation (con mock de ApiClient)
   - Verificar misma firma de métodos

2. **Integration Tests:**
   - Probar switch entre fake y API
   - Verificar `RepositoryFactory` funciona correctamente

3. **Widget Tests:**
   - Probar pantallas con fake repositories
   - Verificar UI con diferentes estados de datos

---

## ⚠️ Riesgos y Mitigaciones

### Riesgo 1: Fake data desactualizado
**Síntoma:** Modelos cambian pero fake data no se actualiza
**Mitigación:**
- ✅ Revisar fake data cuando se modifiquen modelos
- ✅ Incluir en code review: "¿Se actualizó fake data?"
- ✅ Unit tests que validen fake data cumple con modelos

### Riesgo 2: Divergencia entre fake y API
**Síntoma:** Fake funciona pero API falla, o viceversa
**Mitigación:**
- ✅ Misma firma de métodos en ambas implementaciones
- ✅ Tests que validen ambas versiones
- ✅ Contract testing (asegurar mismo comportamiento)

### Riesgo 3: Olvidar cambiar a modo API en producción
**Síntoma:** App en producción usa fake data
**Mitigación:**
- ✅ Default en builds de producción: `ENABLE_MOCKS=false`
- ✅ CI/CD verifica variable de entorno
- ✅ Logs claros: `[DataSourceConfig] Using: fake` o `api`
- ✅ Pantalla de debug muestra modo actual

### Riesgo 4: Fake data demasiado simple
**Síntoma:** Testing con fake no detecta bugs reales
**Mitigación:**
- ✅ Usar datos realistas de casos reales
- ✅ Incluir edge cases en fake data
- ✅ Validar fake data con mismas reglas que API
- ✅ Agregar casos de error simulados

### Riesgo 5: Performance de fake data
**Síntoma:** Fake data muy lento o muy rápido vs API real
**Mitigación:**
- ✅ Delays simulados realistas (300-500ms)
- ✅ Simular operaciones costosas con delays mayores
- ✅ Medir latencia de API real para ajustar delays

---

## 📊 Progreso de Implementación

### Resumen Global

| Categoría | Total | Completo | En Progreso | Pendiente | % Completo |
|-----------|-------|----------|-------------|-----------|------------|
| **Modelos** | 20 | 19 | 0 | 1 (Notification) | 95% |
| **Fake Data** | 20 | 19 | 0 | 1 (Notification) | 95% |
| **Repository Interfaces** | 13 | 4 | 0 | 9 | 31% |
| **Fake Implementations** | 13 | 4 | 0 | 9 | 31% |
| **API Implementations** | 13 | 0 | 0 | 13 | 0% |
| **Endpoints Definidos** | ~80 | ~10 | 0 | ~70 | 12% |
| **Pantallas Migradas** | ~30 | 0 | 3 | ~27 | 0% |

### Próximas Tareas (Por Prioridad)

#### Prioridad Alta (Semana 1-2)
1. ✅ Crear documento MOCKS.md (Este documento)
2. ⏸️ Agregar `ENABLE_MOCKS` a `.env`
3. ⏸️ Actualizar `DataSourceConfig` para runtime switching
4. ⏸️ Actualizar `main.dart` para inicializar config
5. ⏸️ Crear modelo `Notification` + fake data
6. ⏸️ Crear `AuthRepository` (interface + fake + API)
7. ⏸️ Implementar `CommunityRepositoryApi`
8. ⏸️ Implementar `EnergyStatsRepositoryApi`
9. ⏸️ Implementar `TransactionRepositoryApi`

#### Prioridad Media (Semana 3-4)
10. ⏸️ Crear `UserRepository` (interface + fake + API)
11. ⏸️ Crear `P2PRepository` (migrar P2PService)
12. ⏸️ Crear `NotificationRepository`
13. ⏸️ Crear `PDERepository`
14. ⏸️ Crear `BillingRepository`
15. ⏸️ Crear `CreditsRepository`

#### Prioridad Baja (Semana 5+)
16. ⏸️ Crear `LiquidationRepository` (migrar LiquidationService)
17. ⏸️ Crear `ConsumerOfferRepository`
18. ⏸️ Crear `ReportsRepository`
19. ⏸️ Migrar pantallas a usar repositories
20. ⏸️ Testing completo de todos los repositorios

---

## 📚 Referencias

### Archivos de Configuración
- [.env](../../.env) - Variables de entorno
- [lib/core/config/data_source_config.dart](../../lib/core/config/data_source_config.dart) - Configuración de data source
- [lib/core/config/repository_factory.dart](../../lib/core/config/repository_factory.dart) - Factory de repositorios
- [lib/main.dart](../../lib/main.dart) - Entry point de la aplicación

### Archivos de Modelos
- [lib/models/my_user.dart](../../lib/models/my_user.dart)
- [lib/models/energy_models.dart](../../lib/models/energy_models.dart)
- [lib/models/community_models.dart](../../lib/models/community_models.dart)
- [lib/models/p2p_offer.dart](../../lib/models/p2p_offer.dart)
- [lib/models/p2p_models.dart](../../lib/models/p2p_models.dart)
- [lib/models/billing_models.dart](../../lib/models/billing_models.dart)
- [lib/models/consumer_offer.dart](../../lib/models/consumer_offer.dart)
- [lib/models/liquidation_session.dart](../../lib/models/liquidation_session.dart)

### Archivos de Fake Data
- [lib/data/fake_data.dart](../../lib/data/fake_data.dart)
- [lib/data/fake_data_phase2.dart](../../lib/data/fake_data_phase2.dart)
- [lib/data/fake_periods_data.dart](../../lib/data/fake_periods_data.dart)

### Archivos de API
- [lib/core/api/api_client.dart](../../lib/core/api/api_client.dart)
- [lib/core/constants/api_endpoints.dart](../../lib/core/constants/api_endpoints.dart)
- [lib/core/api/api_response.dart](../../lib/core/api/api_response.dart)
- [lib/core/api/api_exceptions.dart](../../lib/core/api/api_exceptions.dart)
- [lib/core/network/api_interceptor.dart](../../lib/core/network/api_interceptor.dart)

### Repositorios Existentes (Ejemplos)
- [lib/repositories/impl/auth_repository_fake.dart](../../lib/repositories/impl/auth_repository_fake.dart)
- [lib/repositories/impl/community_repository_fake.dart](../../lib/repositories/impl/community_repository_fake.dart)
- [lib/repositories/impl/transaction_repository_fake.dart](../../lib/repositories/impl/transaction_repository_fake.dart)
- [lib/repositories/impl/energy_stats_repository_fake.dart](../../lib/repositories/impl/energy_stats_repository_fake.dart)

### Servicios Legacy (A Migrar)
- [lib/core/services/auth_service.dart](../../lib/core/services/auth_service.dart)
- [lib/services/p2p_service.dart](../../lib/services/p2p_service.dart)
- [lib/services/liquidation_service.dart](../../lib/services/liquidation_service.dart)

### Documentos Relacionados
- [RUTA DE NAVEGACION.md](./RUTA%20DE%20NAVEGACION.md) - Documentación de rutas de navegación

---

## 🔄 Actualización del Documento

**Última actualización:** 2026-02-28
**Versión:** 1.0.0
**Actualizado por:** Claude Code - Anthropic

Este documento debe actualizarse cada vez que:
- ✅ Se complete un repositorio (marcar como ✅ en checklist)
- ✅ Se agregue un nuevo endpoint
- ✅ Se cree un nuevo modelo
- ✅ Se actualice fake data
- ✅ Se migre una pantalla a usar repositories
- ✅ Se cambie la arquitectura del sistema de mocks

---

*Fin del documento MOCKS.md*
