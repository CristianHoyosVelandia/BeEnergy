# Documentación: Estados del Periodo y Visualización en Pantalla

## Resumen

Este documento explica cómo están configurados los estados del Periodo cuando llegan del backend y qué se muestra en la pantalla Home para cada estado.

---

## 1. Tipos de Estados

### 1.1 Estados PDE (desde Backend)

El backend envía el estado del periodo a través del modelo `PDEPeriodStatus`:

| Status Code | Nombre del Estado | Descripción |
|-------------|------------------|-------------|
| **1** | PDE Disponible | El periodo está activo y se pueden crear ofertas |
| **2** | Periodo Cerrado | El periodo ha cerrado, no se aceptan más ofertas |
| **3** | Ofertas Finalizadas | Las ofertas han sido procesadas y liquidadas |
| **4** | En Conciliación | El periodo está esperando conciliación con el comercializador |
| **5** | Periodo Histórico | Periodo completamente cerrado y archivado |

### 1.2 Estados del Periodo (General)

Definidos en `PeriodStatus` (enum):

| Estado | Descripción |
|--------|-------------|
| **current** | Mes actual en curso |
| **historical** | Mes histórico con datos cerrados |
| **future** | Mes futuro (no disponible aún) |

---

## 2. Visualización en Pantalla por Estado

### Estado 1: PDE Disponible (statusCode = 1)

**Condición:** `statusCode == 1 && canCreateOffers == true`

**Se muestra:** Card destacado de PDE (`_buildPDEHighlightCard()`)

**Contenido para Usuario:**
- **Título:** "⚡ Nuevo PDE: disponible"
- **Subtítulo:** "[Mes] - Modelo de Ofertas"
- **Icono:** Rayo (⚡)
- **Información mostrada:**
  - Precio de Mercado (MC): Costo de energía del periodo
  - Rango de Precio permitido: Min-Max para ofertas
  - **Botón CTA:** "Crear Oferta de PDE" (navega a `ConsumerMarketplaceScreen`)

**Contenido para Admin:**
- **Título:** "Revisar Ofertas"
- **Subtítulo:** "[Mes] - Gestión Comunitaria"
- **Icono:** Lista
- **Información mostrada:**
  - Precio de Mercado
  - Rango de Precio
  - **Botón CTA:** "Revisar Ofertas Comunitarias" (navega a `AdminCommunityOffersScreen`)

**Ubicación:**
- Archivo: [home_screen.dart:1462-1699](home_screen.dart#L1462-L1699)
- Método: `_buildPDEHighlightCard()`

---

### Estado 2: Periodo Cerrado (statusCode = 2)

**Condición:** `statusCode == 2`

**Se muestra:** Card de periodo cerrado (`_buildPDEPeriodoCerradoCard()`)

**Contenido para Admin:**
- **Título:** "Periodo Cerrado"
- **Subtítulo:** Nombre del mes
- **Icono:** `Icons.assignment_turned_in`
- **Color:** Púrpura (`AppTokens.primaryPurple`)
- **Información mostrada:**
  - Mensaje informativo: "El periodo de ofertas ha cerrado. Puede proceder a realizar la asignación de PDE."
- **Botón CTA:** "Realizar Asignación de PDE" (navega a `AdminCommunityOffersScreen`)
- **Acción:** Permite al admin revisar ofertas y realizar la asignación manual de PDE

**Contenido para Usuario (con oferta):**
- **Título:** "Periodo Cerrado"
- **Subtítulo:** Nombre del mes
- **Icono:** `Icons.timer`
- **Color:** Púrpura (`AppTokens.primaryPurple`)
- **Información mostrada:**
  - **PDE Solicitado:** Porcentaje que solicitó el usuario (ej: "50%")
  - **Precio Ofertado:** Precio por kWh que ofertó (ej: "400 COP/kWh")
- **Mensaje de notificación:**
  > "Se te notificará cuando se realice la asignación de PDE"
- **Estado:** Solo lectura, esperando asignación del admin

**Contenido para Usuario (sin oferta):**
- **Título:** "Periodo Cerrado"
- **Icono:** `Icons.lock_clock`
- **Color:** Gris neutro (`surfaceContainerHighest`)
- **Mensaje:** "No realizaste ninguna oferta para este periodo."
- **Estado:** Informativo, sin acciones disponibles

**Datos obtenidos desde:**
- API: `ConsumerOfferApiService.getBuyerOfferForPeriod()`
- Modelo: `ConsumerOffer`
- Campos: `pdePercentageRequested`, `pricePerKwh`

**Ubicación:**
- Archivo: [home_screen.dart:1706-2003](home_screen.dart#L1706-L2003)
- Métodos: `_buildPDEPeriodoCerradoCard()`, `_buildPDEPeriodoCerradoAdminCard()`, `_buildPDEPeriodoCerradoUsuarioCard()`

---

### Estado 3: Ofertas Finalizadas (statusCode = 3)

**Condición:** `statusCode == 3`

**Se muestra:** Card de ofertas finalizadas (`_buildPDEFinalizadoCard()`)

**Contenido para Admin:**
- **Título:** "Ofertas Finalizadas"
- **Subtítulo:** Nombre del mes
- **Icono:** `Icons.check_circle`
- **Color:** Verde (`AppTokens.energyGreen`)
- **Información mostrada:**
  - Mensaje informativo: "Las ofertas han sido liquidadas. Puede proceder a cambiar el estado a 'En Conciliación'."
- **Botón CTA:** "Pasar a Conciliación" (abre modal de confirmación)
- **Acción:** Al confirmar, actualiza el estado del periodo a 4 (En Conciliación) mediante API
- **Modal de confirmación:**
  - Pregunta: "¿Desea pasar el periodo [Mes] a estado 'En Conciliación'?"
  - Nota: "Los usuarios serán notificados y podrán ver su PDE asignado."
  - Botones: "Cancelar" / "Confirmar"

**Contenido para Usuario:**
- **Título:** "Ofertas Finalizadas"
- **Subtítulo:** Nombre del mes
- **Icono:** `Icons.check_circle_outline`
- **Color:** Rojo (`AppTokens.primaryRed`)
- **Información mostrada:**
  - **PDE Solicitado:** Porcentaje solicitado por el usuario (ej: "50%")
  - **PDE Asignado:** Porcentaje realmente asignado (ej: "45%")
  - **Precio:** Precio por kWh acordado (ej: "400 COP/kWh")
  - **Valor Total:** Costo total calculado (energía asignada × precio)
  - **Fecha de Liquidación:** Cuando se liquidó la oferta
- **Mensaje informativo:**
  > "Apenas se concilie con el comercializador podrá ver el ahorro real en su tarifa energética"

**Datos obtenidos desde:**
- API Usuario: `ConsumerOfferApiService.getBuyerOfferForPeriod()`
- Modelo: `ConsumerOffer`
- Campos: `pdePercentageRequested`, `pdePercentageAssigned`, `pricePerKwh`, `energyKwhCalculated`, `liquidatedAt`

**API de actualización de estado (Admin):**
- Endpoint: `PUT /community/pde-period-status`
- Body: `{ community_id, period, status_code: 4 }`
- Respuesta: `PDEPeriodStatus` actualizado

**Ubicación:**
- Archivo: [home_screen.dart:2110-2400](home_screen.dart#L2110-L2400)
- Métodos: `_buildPDEFinalizadoCard()`, `_buildPDEFinalizadoAdminCard()`, `_showConfirmacionConciliacionModal()`, `_actualizarEstadoPeriodo()`

---

### Estado 4: En Conciliación (statusCode = 4)

**Condición:** `statusCode == 4`

**Se muestra:** Card de conciliación (`_buildPDEEnConciliacionCard()`)

**Contenido para Admin:**
- **Título:** "En Conciliación"
- **Subtítulo:** Nombre del mes
- **Icono:** `Icons.sync`
- **Color:** Rojo (`AppTokens.primaryRed`)
- **Información mostrada:**
  - Mensaje informativo: "Esperando conciliación con el comercializador"
- **Tipo:** Card informativo (solo lectura, sin acciones)
- **Propósito:** Indicar al admin que el periodo está en proceso de conciliación con el comercializador

**Contenido para Usuario:**
- **Título:** "En Conciliación"
- **Subtítulo:** Nombre del mes
- **Icono:** `Icons.hourglass_empty`
- **Color:** Rojo (`AppTokens.primaryRed`)
- **Información mostrada:**
  - **PDE Asignado:** ÚNICAMENTE el porcentaje asignado (ej: "45%")
- **Mensaje informativo:**
  > "A la espera de conciliación con el comercializador"
- **Nota:** Se muestra solo el PDE asignado, sin precio ni valor total, ya que está pendiente de conciliación.

**Datos obtenidos desde (Usuario):**
- API: `ConsumerOfferApiService.getBuyerOfferForPeriod()`
- Modelo: `ConsumerOffer`
- Campo: `pdePercentageAssigned`

**Ubicación:**
- Archivo: [home_screen.dart:2682-2900](home_screen.dart#L2682-L2900)
- Métodos: `_buildPDEEnConciliacionCard()`, `_buildPDEEnConciliacionAdminCard()`, `_buildPDEEnConciliacionUsuarioCard()`

---

### Estado 5: Periodo Histórico (statusCode = 5)

**Condición:** `statusCode == 5`

**Se muestra:**
- **NO se muestra ningún card especial de PDE**
- Solo se muestra el indicador de estado mensual con:
  - Color: Verde (`AppTokens.energyGreen`)
  - Texto: "MES CERRADO"
  - Icono: `Icons.autorenew_rounded`

**Ubicación:**
- Archivo: [home_screen.dart:612-667](home_screen.dart#L612-L667)
- Método: `_buildMonthlyStatusIndicator()`

---

### Sin Estado (pdePeriodStatus == null)

**Condición:** `_pdePeriodStatus == null` (error al cargar o periodo sin configurar)

**Se muestra:**
- **NO se muestra ningún card de PDE**
- El método `_buildPDEHighlightCard()` retorna `SizedBox.shrink()`

**Ubicación:**
- Archivo: [home_screen.dart:1472-1475](home_screen.dart#L1472-L1475)

---

## 3. Indicador de Estado Mensual

Todos los periodos muestran un indicador visual en la parte superior de la pantalla Home.

### Indicador para Periodo Actual (status = "current")

- **Color:** Rojo (`AppTokens.primaryRed`)
- **Indicador:** Círculo pulsante rojo
- **Texto:** "NUEVO MODELO"
- **Periodo:** Nombre del mes (ej: "Enero 2026")

### Indicador para Periodo Histórico (status = "historical")

- **Color:** Verde (`AppTokens.energyGreen`)
- **Icono:** `Icons.autorenew_rounded`
- **Texto:** "MES CERRADO"
- **Periodo:** Nombre del mes (ej: "Diciembre 2025")

**Ubicación:**
- Archivo: [home_screen.dart:612-791](home_screen.dart#L612-L791)
- Método: `_buildMonthlyStatusIndicator()`

---

## 4. Flujo de Carga de Datos

### Inicialización

1. **initState()** llama a `_initializeData()`
2. **Paso 1:** Se carga el historial de periodos (`_loadUserPeriods()`)
   - Endpoint: `GET /api/user-period-history`
   - Se obtiene `currentPeriod` del sistema
3. **Paso 2:** Se carga el estado PDE del periodo actual (`_loadPDEPeriodStatus()`)
   - Endpoint: `GET /api/pde-period-status`
   - Se obtiene `statusCode`, `statusName`, `canCreateOffers`

### Cambio de Periodo

Cuando el usuario selecciona un periodo diferente:
1. Se actualiza `_selectedPeriod`
2. Se recarga el estado PDE para el nuevo periodo (`_loadPDEPeriodStatus()`)
3. Se actualiza la UI según el nuevo estado

**Ubicación:**
- Archivo: [home_screen.dart:44-113](home_screen.dart#L44-L113)
- Métodos: `_initializeData()`, `_loadUserPeriods()`, `_loadPDEPeriodStatus()`

---

## 5. Resumen Visual

### Tabla Comparativa de Estados

| Status Code | Card Usuario | Card Admin | Información Mostrada Usuario | Información Mostrada Admin | Acción Usuario | Acción Admin |
|-------------|--------------|------------|------------------------------|---------------------------|----------------|--------------|
| **1** - PDE Disponible | ✅ Card PDE Destacado (Rojo) | ✅ Card PDE Destacado (Rojo) | • Título: "⚡ Nuevo PDE: disponible"<br>• Precio Mercado (MC)<br>• Rango de Precio (Min-Max)<br>• Icono: Rayo | • Título: "Revisar Ofertas"<br>• Precio Mercado (MC)<br>• Rango de Precio (Min-Max)<br>• Icono: Lista | **Crear Oferta de PDE**<br>(→ ConsumerMarketplaceScreen) | **Revisar Ofertas Comunitarias**<br>(→ AdminCommunityOffersScreen) |
| **2** - Periodo Cerrado | ✅ Card Periodo Cerrado (Púrpura)<br>*Si tiene oferta* | ✅ Card Periodo Cerrado (Púrpura) | • Título: "Periodo Cerrado"<br>• PDE Solicitado (%)<br>• Precio Ofertado (COP/kWh)<br>• Mensaje: Se te notificará cuando se asigne<br>• Icono: Timer | • Título: "Periodo Cerrado"<br>• Mensaje: Puede proceder a asignar PDE<br>• Icono: Assignment | **Esperar notificación** 🔔<br>(solo lectura) | **Realizar Asignación de PDE**<br>(→ AdminCommunityOffersScreen) |
| | ℹ️ Card Informativo (Gris)<br>*Si NO tiene oferta* | | • Título: "Periodo Cerrado"<br>• Mensaje: No realizaste oferta<br>• Icono: Lock Clock | | - | |
| **3** - Ofertas Finalizadas | ✅ Card Ofertas Finalizadas (Rojo) | ✅ Card Ofertas Finalizadas (Verde) | • Título: "Ofertas Finalizadas"<br>• PDE Solicitado (%)<br>• PDE Asignado (%)<br>• Precio (COP/kWh)<br>• Valor Total (COP)<br>• Fecha de Liquidación<br>• Mensaje: Esperar conciliación final | • Título: "Ofertas Finalizadas"<br>• Mensaje: Puede proceder a cambiar estado<br>• Icono: Check Circle | **Ver detalles** (solo lectura) | **Pasar a Conciliación**<br>(Modal → API PUT) |
| **4** - En Conciliación | ✅ Card En Conciliación (Rojo) | ✅ Card Informativo (Rojo) | • Título: "En Conciliación"<br>• PDE Asignado (%) - único dato<br>• Mensaje: "A la espera de conciliación con el comercializador"<br>• Icono: Reloj de arena | • Título: "En Conciliación"<br>• Mensaje: "Esperando conciliación con el comercializador"<br>• Icono: Sync | **Esperar** ⏳ (solo lectura) | **Esperar** ⏳ (solo lectura) |
| **5** - Periodo Histórico | ❌ Ningún card | ❌ Ningún card | Solo indicador: "MES CERRADO" (verde) | Solo indicador: "MES CERRADO" (verde) | - | - |
| **null** - Sin Estado | ❌ Ningún card | ❌ Ningún card | - | - | - | - |

### Notas de la Tabla:
- **✅** = Se muestra el card
- **❌** = No se muestra card
- **ℹ️** = Card informativo (sin acciones)
- **Cards en rojo**: Usan gradiente de `AppTokens.primaryRed`
- **Cards en púrpura**: Usan gradiente de `AppTokens.primaryPurple`
- **Indicadores verdes**: Usan color `AppTokens.energyGreen`
- **Estado 2**: Comportamiento diferente para usuario con/sin oferta
- **Estado 3**: Card diferente para admin (verde con acción) vs usuario (rojo informativo)
- **Estado 4**: Ambos roles ven card informativo rojo, sin acciones disponibles

### Tabla Resumen Simplificada

| Status Code | Usuario | Admin | Acción Clave |
|-------------|---------|-------|--------------|
| **1** | ✅ Crear oferta | ✅ Revisar ofertas | 🟢 Activo |
| **2** | ✅ Esperar asignación | ✅ Asignar PDE | 🟣 En proceso |
| **3** | ✅ Ver liquidación | ✅ Pasar a conciliación | 🟢 Finalizado |
| **4** | ✅ Ver asignación | ✅ Ver estado | 🟡 Pendiente |
| **5** | ❌ | ❌ | ⚫ Histórico |

---

## 6. Archivos Relevantes

| Archivo | Descripción |
|---------|-------------|
| [models/pde_period_status.dart](../lib/models/pde_period_status.dart) | Modelo del estado PDE desde backend |
| [models/user_period_history.dart](../lib/models/user_period_history.dart) | Historial de periodos del usuario |
| [data/fake_periods_data.dart](../lib/data/fake_periods_data.dart) | Datos mock de periodos (modo desarrollo) |
| [screens/main_screens/home/home_screen.dart](../lib/screens/main_screens/home/home_screen.dart) | Pantalla principal con visualización de estados |
| [repositories/domain/pde_period_repository.dart](../lib/repositories/domain/pde_period_repository.dart) | Contrato del repositorio PDE |
| [repositories/impl/pde_period_repository_api.dart](../lib/repositories/impl/pde_period_repository_api.dart) | Implementación API del repositorio |

---

## 7. Notas Importantes

1. **Vista Admin vs Usuario:** Los cards de PDE se muestran de forma diferente según el rol:
   - **Estado 1 (PDE Disponible):** Ambos ven card, pero con acciones diferentes
     - Admin: Revisar ofertas comunitarias
     - Usuario: Crear ofertas de PDE
   - **Estado 2 (Periodo Cerrado):** Ambos ven card, pero con contenido diferente
     - Admin: Puede realizar asignación de PDE
     - Usuario: Ver su oferta y esperar asignación
   - **Estado 3 (Ofertas Finalizadas):** Ambos ven card, pero con diferentes opciones
     - Admin: Card verde con botón para pasar a conciliación
     - Usuario: Card rojo informativo con detalles de liquidación
   - **Estado 4 (En Conciliación):** Ambos ven card informativo rojo
     - Admin: Mensaje "Esperando conciliación con el comercializador" (solo lectura)
     - Usuario: Muestra PDE asignado y mensaje de espera (solo lectura)

2. **Estado 2 - Comportamiento dual para usuarios:**
   - **Con oferta:** Se muestra card púrpura con datos de su oferta (PDE solicitado, precio) y mensaje de espera
   - **Sin oferta:** Se muestra card informativo gris indicando que no realizó oferta

3. **Estado 3 - Ofertas Finalizadas:**
   - **Admin:** Puede cambiar el estado a "En Conciliación" (estado 4) mediante modal de confirmación
   - **Usuario:** Solo ve detalles de su oferta liquidada

4. **Estado 4 - En Conciliación:**
   - **Admin:** Card informativo rojo sin acciones, indicando espera de conciliación
   - **Usuario:** Card informativo rojo mostrando PDE asignado y mensaje de espera

5. **Carga de datos diferida:** Los datos de ofertas (estados 2, 3, 4) se cargan mediante `FutureBuilder` cuando se renderiza el card, no al inicializar la pantalla. Esto optimiza el rendimiento y reduce llamadas innecesarias al backend.

6. **Actualización de estado del periodo (Admin):**
   - El admin puede cambiar el estado del periodo desde el Estado 3 (Ofertas Finalizadas) al Estado 4 (En Conciliación)
   - Se muestra modal de confirmación antes de ejecutar el cambio
   - La actualización se realiza mediante endpoint `PUT /community/pde-period-status`
   - Al confirmar, la vista se actualiza automáticamente mostrando el nuevo estado

7. **Modo Mock vs Real:** La aplicación soporta dos modos:
   - `DataSourceConfig.isFake = true`: Usa datos mock de `FakePeriodsData`
   - `DataSourceConfig.isFake = false`: Usa datos del backend via API

---

**Última actualización:** 2026-04-09
**Autor:** Claude Code
**Versión:** 1.0
