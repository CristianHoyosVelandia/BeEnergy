# 📱 Pantallas de Comunidad Energética - MVP

Implementación completa del sistema de gestión de comunidades energéticas basado en la tesis de **Cristian Hoyos y Esteban Viveros**.

## 🗂️ Estructura de Archivos

```
lib/screens/main_screens/community/
├── community_management_screen.dart  # Pantalla principal con acceso rápido
├── user_detail_screen.dart           # Detalle individual de miembro
├── energy_records_screen.dart        # Registro energético mensual
├── pde_allocation_screen.dart        # Distribución PDE
├── p2p_market_screen.dart            # Mercado P2P
├── energy_credits_screen.dart        # Créditos energéticos
├── monthly_billing_screen.dart       # Liquidación mensual
├── reports_screen.dart               # Reportes y análisis
└── community_screens.dart            # Exportación centralizada
```

## 🚀 Navegación Implementada

### Rutas Registradas en `main.dart`:

```dart
// Community Routes (nuevas pantallas):
'communityManagement' : (context) => const CommunityManagementScreen(),
'energyRecords'       : (context) => const EnergyRecordsScreen(),
'pdeAllocation'       : (context) => const PDEAllocationScreen(),
'p2pMarket'           : (context) => const P2PMarketScreen(),
'energyCredits'       : (context) => const EnergyCreditsScreen(),
'monthlyBilling'      : (context) => const MonthlyBillingScreen(),
'reports'             : (context) => const ReportsScreen(),
```

### Flujo de Navegación:

```
Home Screen
  └─ Botón "Gestión de la Comunidad" (ya implementado)
      └─ Community Management Screen
          ├─ Menú de Acceso Rápido (6 botones)
          │   ├─ Registro Energético
          │   ├─ PDE
          │   ├─ Mercado P2P
          │   ├─ Créditos
          │   ├─ Liquidación
          │   └─ Reportes
          │
          └─ Lista de Miembros (15 usuarios)
              └─ Click en miembro → User Detail Screen
```

## 📊 Pantallas Implementadas

### 1️⃣ Community Management Screen
**Ruta:** `'communityManagement'`

**Características:**
- ✅ Header con estadísticas de la comunidad
- ✅ **Menú de Acceso Rápido** (6 cards con navegación)
- ✅ Barra de búsqueda
- ✅ Filtros: Todos / Prosumidores / Consumidores
- ✅ Lista de 15 miembros con métricas
- ✅ Navegación a detalle de usuario

**Datos mostrados:**
- 15 miembros total
- 5 prosumidores
- Capacidad: 1,410 kW

---

### 2️⃣ Energy Records Screen
**Ruta:** `'energyRecords'`

**Características:**
- ✅ Registro de todos los miembros (Noviembre 2025)
- ✅ Ordenamiento: Balance / Generación / Consumo
- ✅ Toggle ascendente/descendente
- ✅ Ranking con badges (#1, #2, #3)
- ✅ Cards detalladas con 6 métricas

**Métricas por usuario:**
- Generación / Consumo
- Exportado / Importado
- Balance neto
- Autoconsumo (prosumidores)

---

### 3️⃣ PDE Allocation Screen
**Ruta:** `'pdeAllocation'`

**Características:**
- ✅ Distribución homogénea de excedentes
- ✅ Pie chart interactivo (FL Chart)
- ✅ 4 prosumidores con porcentajes
- ✅ Cards de asignación individual
- ✅ Barras de progreso de distribución

**Datos PDE:**
- Total excedente: 720 kWh
- María García: 41.7% (300 kWh)
- Javier Mendoza: 25% (180 kWh)
- Fernando Morales: 20% (144 kWh)
- Patricia Castro: 13.3% (96 kWh)

---

### 4️⃣ P2P Market Screen
**Ruta:** `'p2pMarket'`

**Características:**
- ✅ 5 contratos P2P (650 kWh total)
- ✅ Top 3 vendedores con rankings
- ✅ Filtros: Todos / Activos / Completados
- ✅ Cards detalladas vendedor → comprador
- ✅ Precio preferencial: 500 COP/kWh

**Contratos P2P:**
1. María García → Ana López (200 kWh)
2. María García → Carlos Ruiz (150 kWh)
3. Javier Mendoza → Diana Torres (120 kWh)
4. Fernando Morales → Elena Vargas (100 kWh)
5. Patricia Castro → Felipe Gómez (80 kWh)

---

### 5️⃣ Energy Credits Screen
**Ruta:** `'energyCredits'`

**Características:**
- ✅ Balance financiero de prosumidores
- ✅ Total ingresos y gastos
- ✅ Historial de transacciones
- ✅ Filtros: Todas / Ingresos / Gastos
- ✅ Cards con indicadores de tendencia

**Créditos totales:**
- María García: +87,500 COP
- Javier Mendoza: +30,000 COP
- Fernando Morales: +25,000 COP
- Patricia Castro: +20,000 COP

---

### 6️⃣ Monthly Billing Screen
**Ruta:** `'monthlyBilling'`

**Características:**
- ✅ **4 escenarios de facturación comparables**
- ✅ Selector de escenarios (Tradicional / Créditos / PDE / P2P)
- ✅ Cálculo automático de ahorros
- ✅ Filtros por tipo de usuario
- ✅ Cards individuales con métricas

**Escenarios:**
1. **Tradicional:** 450 COP/kWh (todo de red)
2. **Créditos:** Autoconsumo + red regulada
3. **PDE:** Distribución homogénea
4. **P2P:** 500 COP/kWh + red (ahorro óptimo)

---

### 7️⃣ Reports Screen
**Ruta:** `'reports'`

**Características:**
- ✅ Gráfico de barras: Balance energético
- ✅ Comparación de escenarios con barras
- ✅ 4 métricas clave en cards
- ✅ Top 3 contribuidores P2P
- ✅ Visualizaciones con FL Chart

**Métricas clave:**
- Autosuficiencia: 62.1% (1410/2270)
- Energía P2P: 650 kWh
- Prosumidores: 5/15
- Capacidad total: 1,410 kW

---

### 8️⃣ User Detail Screen
**Navegación:** Click en miembro desde Community Management

**Características:**
- ✅ Header expandible con avatar
- ✅ 4 métricas energéticas
- ✅ Información PDE (solo prosumidores)
- ✅ Sección de créditos energéticos
- ✅ Lista de contratos P2P del usuario

---

## 📈 Datos Implementados

### Archivo: `lib/data/fake_data.dart`

**Nuevos datos agregados:**
```dart
// Facturación con 4 escenarios
static final List<UserBilling> userBillings = [...]

// Ahorros comunitarios agregados
static CommunitySavings get communitySavings => [...]
```

**Datos existentes (sesiones anteriores):**
- `members` - 15 miembros (IDs 13-27)
- `energyRecords` - Registros energéticos
- `pdeAllocations` - Asignaciones PDE
- `p2pContracts` - 5 contratos P2P
- `energyCredits` - Créditos de prosumidores
- `creditTransactions` - Historial de transacciones
- `sellerRankings` - Top vendedores
- `regulatedCosts` - Costos regulados (CU, MC, PCN)
- `communityStats` - Estadísticas agregadas
- `hourlyGeneration` - Datos horarios para gráficos
- `dailyEnergyData` - Datos diarios para gráficos

---

## 🎨 Sistema de Diseño

Todas las pantallas usan **Material Design 3** con:

- ✅ `AppTokens` para spacing, colores, tipografía
- ✅ `context.colors` / `context.textStyles` para acceso a tema
- ✅ Gradientes temáticos por pantalla
- ✅ Cards con shadows y borders sutiles
- ✅ Filtros y chips interactivos
- ✅ Color coding consistente

**Paleta de colores:**
- 🔴 Community Management: `AppTokens.primaryRed`
- 🔵 Energy Records: `AppTokens.primaryRed`
- 🟠 PDE: `Colors.orange`
- 🟢 P2P Market: `Colors.green`
- 🟣 Energy Credits: `Colors.purple`
- 🔵 Monthly Billing: `Colors.teal`
- 🟦 Reports: `Colors.indigo`

---

## 🧪 Cómo Probar

### Desde Home Screen:

1. Ejecutar la app: `flutter run`
2. Navegar a **Home Screen**
3. Hacer click en el botón **"Gestión de la Comunidad"**
4. Explorar el menú de **Acceso Rápido** (6 cards)
5. Navegar a cada pantalla

### Navegación directa por rutas:

```dart
// Desde cualquier pantalla con contexto
Navigator.pushNamed(context, 'communityManagement');
Navigator.pushNamed(context, 'energyRecords');
Navigator.pushNamed(context, 'pdeAllocation');
Navigator.pushNamed(context, 'p2pMarket');
Navigator.pushNamed(context, 'energyCredits');
Navigator.pushNamed(context, 'monthlyBilling');
Navigator.pushNamed(context, 'reports');
```

### Navegación programática:

```dart
// Usando context.push (extension method)
context.push(const CommunityManagementScreen());
context.push(const EnergyRecordsScreen());
context.push(const PDEAllocationScreen());
```

---

## 📦 Dependencias Utilizadas

```yaml
dependencies:
  fl_chart: ^0.69.2              # Gráficos (líneas, barras, pie)
  syncfusion_flutter_charts: ^28.1.33  # Gráficos circulares
```

Estas dependencias ya estaban en el proyecto.

---

## ✅ Checklist de Integración

- ✅ 8 pantallas creadas y funcionales
- ✅ Rutas registradas en `main.dart`
- ✅ Exports agregados en `routes.dart`
- ✅ Navegación desde Home Screen implementada
- ✅ Menú de acceso rápido en Community Management
- ✅ Datos de tesis en `fake_data.dart`
- ✅ Sistema de diseño consistente
- ✅ Documentación completa

---

## 🎯 Datos de la Tesis

### Comunidad UAO - Noviembre 2025

**Miembros:**
- Total: 15 usuarios (IDs 13-27)
- Consumidores: 10 (IDs 13-22)
- Prosumidores: 5 (IDs 23-27)

**Prosumidores:**
1. **Andrea Martínez** (ID 23) - 600 kW
2. **María García** (ID 24) - 288 kW
3. **Fernando Morales** (ID 25) - 192 kW
4. **Patricia Castro** (ID 26) - 96 kW
5. **Javier Mendoza** (ID 27) - 234 kW

**Energía:**
- Generación solar total: 1,410 kWh
- Consumo total: 2,270 kWh
- Energía P2P: 650 kWh
- Autosuficiencia: 62.1%

**Costos:**
- CU (Cargo por Uso): 150 COP/kWh
- MC (Cargo Comercialización): 200 COP/kWh
- PCN (Precio Energía): 100 COP/kWh
- **Total regulado:** 450 COP/kWh
- **Precio P2P:** 500 COP/kWh

---

## 📝 Notas Importantes

1. **UserDetailScreen no tiene ruta nombrada** porque se navega programáticamente pasando el objeto `member`:
   ```dart
   context.push(UserDetailScreen(member: member));
   ```

2. **Todos los datos son estáticos** para el MVP. En producción, estos vendrían de una API.

3. **Las pantallas son independientes** y pueden ser accedidas desde múltiples puntos.

4. **El menú de acceso rápido** en Community Management facilita la navegación sin necesidad de regresar al Home.

---

## 🚀 Siguientes Pasos Sugeridos

1. **Testing exhaustivo** en dispositivos Android/iOS
2. **Validación de datos** con los autores de la tesis
3. **Integración con API real** (cuando esté disponible)
4. **Optimización de rendimiento** si es necesario
5. **Agregar animaciones** entre transiciones
6. **Implementar deep linking** para compartir pantallas

---

## 📞 Soporte

Para dudas o mejoras, revisar:
- Código fuente en `lib/screens/main_screens/community/`
- Datos en `lib/data/fake_data.dart`
- Modelos en `lib/models/`

---

**Desarrollado con ❤️ para el MVP de Comunidades Energéticas**
*Basado en la tesis de Cristian Hoyos y Esteban Viveros - 2025*
