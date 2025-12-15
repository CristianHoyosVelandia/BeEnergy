# Guía de Implementación CREG 101 072 de 2025
## BeEnergy - Plataforma de Comunidad Energética UAO

**Versión:** 1.0
**Fecha:** Enero 2025
**Estado:** Documento de Referencia Técnica y Regulatoria

---

## 📋 TABLA DE CONTENIDOS

1. [Resumen Ejecutivo](#resumen-ejecutivo)
2. [Contexto de la Tesis UAO](#contexto-de-la-tesis-uao)
3. [Arquitectura de Dos Fases](#arquitectura-de-dos-fases)
4. [Clasificación de Excedentes](#clasificación-de-excedentes)
5. [Programa de Distribución de Excedentes (PDE)](#programa-pde)
6. [Valor de Energía (VE)](#valor-de-energía-ve)
7. [Número de Identificación Única (NIU)](#número-de-identificación-única-niu)
8. [Proceso Mensual P2P Detallado](#proceso-mensual-p2p)
9. [Auditoría y Cumplimiento](#auditoría-y-cumplimiento)
10. [Checklist de Cumplimiento](#checklist-de-cumplimiento)

---

## 1. RESUMEN EJECUTIVO

### ¿Qué es CREG 101 072 de 2025?

La **Resolución CREG 101 072 de 2025** es el marco regulatorio colombiano que establece las reglas para el funcionamiento de **comunidades energéticas** con generación distribuida y esquemas de **intercambio peer-to-peer (P2P)** de energía eléctrica.

**Organismo Emisor:** Comisión de Regulación de Energía y Gas (CREG)
**Vigencia:** Desde enero 2025
**Alcance:** Nacional - Colombia

**Objetivos Principales:**
1. Fomentar la autogeneración con fuentes renovables
2. Permitir intercambios P2P entre prosumidores y consumidores
3. Establecer un programa de solidaridad energética (PDE)
4. Garantizar precios justos basados en el Valor de Energía (VE)
5. Asegurar trazabilidad y cumplimiento regulatorio

### Aplicabilidad a BeEnergy

BeEnergy es una plataforma digital que implementa **100% de los requisitos** de CREG 101 072 de 2025 para la comunidad energética de la Universidad Autónoma de Occidente (UAO) en Cali, Colombia.

**Nivel de Cumplimiento:**
- **Actual (Fase 1 - Histórico):** 8.75%
- **Objetivo (Fase 2 - Transaccional):** 100%

| Requisito | Fase 1 | Fase 2 | Gap |
|-----------|--------|--------|-----|
| Clasificación Excedentes Tipo 1/2 | ❌ | ✅ | CRÍTICO |
| Validación PDE ≤10% | ❌ (41.7%) | ✅ | CRÍTICO |
| NIU por usuario | ❌ | ✅ | CRÍTICO |
| Ofertas P2P manuales | ❌ | ✅ | CRÍTICO |
| Validación VE ±10% | ❌ | ✅ | CRÍTICO |
| Auditoría completa | ❌ | ✅ | MAYOR |

---

## 2. CONTEXTO DE LA TESIS UAO

### Universidad Autónoma de Occidente

**Proyecto de Investigación:** "Viabilidad Técnica y Económica de Comunidades Energéticas P2P bajo Marco Regulatorio CREG 101 072 en Colombia"

**Nivel Académico:** Maestría en Energías Renovables
**Institución:** Universidad Autónoma de Occidente, Cali, Colombia
**Período de Análisis:** Noviembre 2025 (datos reales de generación/consumo)

### Comunidad Energética UAO

**Descripción:**
La comunidad energética UAO está conformada por 15 usuarios del campus universitario que participan en un esquema de generación distribuida con paneles solares fotovoltaicos y consumo eléctrico.

**Características Técnicas:**
- 📍 **Ubicación:** Campus UAO, Cali, Valle del Cauca, Colombia
- 👥 **Miembros:** 15 usuarios (prosumidores y consumidores)
- ⚡ **Capacidad Instalada:** ~5 kW promedio por prosumidor
- 🔆 **Tecnología:** Paneles solares fotovoltaicos
- 📊 **Medición:** Medidores bidireccionales (AMI)
- 🌐 **Conectividad:** Red eléctrica del campus

**Composición de Usuarios:**
- **Prosumidores (8 usuarios):** Generan y consumen energía
- **Consumidores (7 usuarios):** Solo consumen energía

### Datos de la Tesis

**Período Base - Noviembre 2025:**
- Total generado: 2,400 kWh
- Total consumido: 2,100 kWh
- Total excedentes: 300 kWh
- PDE asignado: 125 kWh (41.7% ❌ - DEBE CORREGIRSE A ≤10%)
- Contratos P2P: 8 contratos (datos históricos)
- Ahorro promedio: 12% vs tarifa regulada

**Período de Implementación - Diciembre 2025:**
Este será el primer mes con el sistema transaccional completo implementado, usando fake data para demostrar el flujo completo.

### Objetivos de la Investigación

1. **Objetivo General:**
   - Demostrar la viabilidad técnica, económica y regulatoria de comunidades energéticas P2P en Colombia bajo CREG 101 072.

2. **Objetivos Específicos:**
   - Implementar clasificación de excedentes Tipo 1 y Tipo 2
   - Validar cumplimiento del límite PDE ≤10%
   - Desarrollar sistema de ofertas P2P con validación VE
   - Calcular ahorros económicos vs tarifa regulada
   - Generar reportes de cumplimiento para CREG

3. **Hipótesis:**
   - Los usuarios pueden ahorrar entre 10-15% en costos de energía mediante intercambios P2P
   - El sistema P2P es técnicamente viable con la infraestructura actual
   - El cumplimiento regulatorio CREG 101 072 es alcanzable

---

## 3. ARQUITECTURA DE DOS FASES

BeEnergy se divide en dos fases complementarias: **Histórico** y **Transaccional**.

### FASE 1: HISTÓRICO (100% Implementado)

**Naturaleza:** Visualización retrospectiva de datos mensuales.

**Propósito:**
- Revisar transacciones pasadas
- Analizar consumo y generación histórica
- Comparar escenarios económicos
- Generar reportes mensuales

**Pantallas (8 total):**

1. **Community Management**
   - Dashboard principal de la comunidad
   - KPIs: Total generado, consumido, ahorros
   - Acceso a todas las secciones

2. **Energy Records**
   - Registros mensuales de energía
   - Tabla con generación, consumo, excedentes
   - Filtros por usuario, período
   - Exportación a CSV

3. **PDE Allocation**
   - Asignación histórica de PDE
   - Gráfico de distribución
   - Porcentajes por usuario

4. **P2P Market**
   - Contratos P2P históricos del mes
   - Detalles de vendedor, comprador, precio
   - Estado de contratos

5. **Monthly Billing**
   - Facturación mensual
   - Comparación de escenarios:
     - Tradicional (tarifa regulada)
     - P2P
     - PDE
   - Cálculo de ahorros

6. **User Detail**
   - Perfil de usuario individual
   - Historial de energía
   - Contratos P2P

7. **Energy Analytics**
   - Análisis de tendencias
   - Gráficos de generación/consumo
   - Predicciones

8. **Community Insights**
   - Insights de la comunidad
   - Comparativas entre usuarios
   - Ranking de prosumidores

**Datos Históricos:**
- **Mes:** Noviembre 2025 (cerrado, completo)
- **Contratos P2P:** Pre-definidos en fake_data
- **PDE:** Asignación fija histórica
- **Facturación:** Calculada para el mes completo

**Características:**
- ✅ **Solo lectura** (no se crean nuevos datos)
- ✅ **Agrupación mensual**
- ✅ **Visualización de tendencias**
- ✅ **Reportes exportables**

---

### FASE 2: TRANSACCIONAL (A Implementar)

**Naturaleza:** Sistema transaccional para crear nuevas asignaciones P2P mensualmente.

**Propósito:**
- Clasificar excedentes Tipo 1/2 automáticamente
- Administrador asigna PDE (≤10%)
- Prosumidores publican ofertas
- Consumidores aceptan ofertas
- Crear contratos bilaterales
- Liquidar mensualmente

**Pantallas Nuevas (4 total):**

1. **Admin PDE Assignment** (Administrador)
   - Ver Tipo 2 disponible total
   - Asignar PDE ≤10%
   - Distribución homogénea entre consumidores
   - Validación en tiempo real

2. **Prosumer Create Offer** (Prosumidor)
   - Ver disponibilidad P2P (Tipo 2 - PDE)
   - Definir energía a vender
   - Fijar precio (validado con VE ±10%)
   - Publicar oferta

3. **Consumer Marketplace** (Consumidor)
   - Ver ofertas disponibles
   - Filtrar por precio, energía
   - Comparar con tarifa regulada
   - Ver perfil de vendedor

4. **Offer Detail & Acceptance** (Consumidor)
   - Detalle completo de oferta
   - Cumplimiento regulatorio (VE)
   - Cantidad a comprar
   - Confirmación de compra
   - Creación de contrato

**Pantallas Modificadas (2 total):**

5. **Energy Records** (Modificada)
   - ✅ Agregar columnas: Tipo 1, Tipo 2, Clasificación
   - ✅ Badge de clasificación

6. **PDE Allocation** (Modificada)
   - ✅ Validación visual ≤10%
   - ✅ Banner de alerta si >10%

**Datos Transaccionales:**
- **Mes:** Diciembre 2025 (activo, transaccional)
- **Contratos P2P:** Se crean dinámicamente al aceptar ofertas
- **PDE:** Asignado por administrador cada mes
- **Facturación:** Calculada al cerrar mes

**Características:**
- ✅ **Lectura y escritura** (creación de ofertas/contratos)
- ✅ **Proceso mensual**
- ✅ **Validaciones regulatorias**
- ✅ **Auditoría completa**

---

### Ciclo de Vida: Transaccional → Histórico

```
┌──────────────────────────────────────────┐
│  DICIEMBRE 2025 (Transaccional - Activo) │
│  • Clasificar excedentes Tipo 1/2        │
│  • Asignar PDE ≤10%                      │
│  • Publicar ofertas                      │
│  • Aceptar ofertas                       │
│  • Crear contratos P2P                   │
│  • Liquidar al cierre                    │
└─────────────────┬────────────────────────┘
                  │
                  │ Mes cierra el 31/12
                  ▼
┌──────────────────────────────────────────┐
│  DICIEMBRE 2025 (Histórico - Cerrado)    │
│  • Datos inmutables                      │
│  • Visualización en pantallas Fase 1     │
│  • Reportes exportables                  │
│  • Base para análisis futuro             │
└──────────────────────────────────────────┘
```

**Diferencias Clave:**

| Aspecto | Fase 1 (Histórico) | Fase 2 (Transaccional) |
|---------|-------------------|------------------------|
| **Propósito** | Visualizar pasado | Crear nuevo mes |
| **Operaciones** | Solo lectura | Lectura y escritura |
| **Datos** | Inmutables | Mutables (hasta cierre) |
| **Usuarios** | Todos (ver) | Roles específicos (crear) |
| **Pantallas** | 8 pantallas | 4 pantallas nuevas |
| **Período** | Meses cerrados | Mes actual activo |

---

## 4. CLASIFICACIÓN DE EXCEDENTES

### Marco Regulatorio

**Artículo Aplicable:** CREG 101 072 de 2025, Art. 2 - Clasificación de Excedentes

Todo prosumidor que genere excedentes de energía (Generación > Consumo) debe clasificarlos en dos tipos:

### Tipo 1: Autoconsumo Compensado

**Definición:**
Energía excedente destinada al **autoconsumo compensado**, NO disponible para venta o intercambio P2P.

**Características:**
- ✅ Solidaridad energética pasiva
- ✅ No genera ingresos económicos
- ❌ NO se puede vender
- ❌ NO se incluye en PDE
- ❌ NO se intercambia P2P

**Ejemplo:**
María genera 300 kWh y consume 200 kWh en un mes.
- Excedente total: 100 kWh
- Tipo 1: 50 kWh (50% del excedente)
- Destino: Reserva para autoconsumo compensado

---

### Tipo 2: Disponible para Mercado

**Definición:**
Energía excedente disponible para **Programa de Distribución de Excedentes (PDE)** e **intercambios P2P**.

**Características:**
- ✅ Disponible para PDE (solidaridad activa)
- ✅ Disponible para P2P (venta a otros usuarios)
- ✅ Genera ingresos económicos
- ⚖️ Precio regulado por VE ±10%

**Flujo de Uso:**
```
Tipo 2 Total
     ↓
     ├→ PDE (máximo 10% del Tipo 2 total de la comunidad)
     │  → Asignado gratuitamente a consumidores sin generación
     │
     └→ Disponible P2P = Tipo 2 - PDE cedido
        → Publicable como oferta en el marketplace
```

**Ejemplo:**
María genera 300 kWh y consume 200 kWh.
- Excedente total: 100 kWh
- Tipo 2: 50 kWh (50% del excedente)
- PDE cedido: 5 kWh (10% del Tipo 2 total de la comunidad)
- Disponible P2P: 45 kWh (María puede ofertar hasta 45 kWh)

---

### Algoritmo de Clasificación 50/50

**Implementación en BeEnergy:**

```dart
class SurplusClassifier {
  Map<String, double> classify(EnergyRecord record) {
    final totalSurplus = record.energyGenerated - record.energyConsumed;

    if (totalSurplus <= 0) {
      return {'type1': 0.0, 'type2': 0.0};
    }

    // Algoritmo 50/50 según CREG 101 072
    final type1 = totalSurplus * 0.5;  // Autoconsumo compensado
    final type2 = totalSurplus * 0.5;  // Disponible mercado

    return {'type1': type1, 'type2': type2};
  }
}
```

**Validación:**
- ✅ `Tipo 1 + Tipo 2 = Excedente Total`
- ✅ `Tipo 1 ≥ 0`
- ✅ `Tipo 2 ≥ 0`

**Clasificación Final:**

```dart
enum SurplusClassification {
  type1Only,    // Solo Tipo 1 (caso raro)
  type2Only,    // Solo Tipo 2 (caso raro)
  mixed,        // Ambos tipos (caso normal)
  none          // Sin excedentes (consumidor puro)
}
```

---

### Ejemplos con Datos UAO (Noviembre 2025)

**Caso 1: Prosumidor María García**
```
Energía Generada:  300 kWh
Energía Consumida: 200 kWh
Excedente Total:   100 kWh

Clasificación:
├─ Tipo 1: 50 kWh (50%)
├─ Tipo 2: 50 kWh (50%)
└─ Clasificación: MIXED
```

**Caso 2: Prosumidor Carlos Pérez**
```
Energía Generada:  280 kWh
Energía Consumida: 220 kWh
Excedente Total:    60 kWh

Clasificación:
├─ Tipo 1: 30 kWh (50%)
├─ Tipo 2: 30 kWh (50%)
└─ Clasificación: MIXED
```

**Caso 3: Consumidor Ana López**
```
Energía Generada:    0 kWh
Energía Consumida: 180 kWh
Excedente Total:     0 kWh

Clasificación:
├─ Tipo 1: 0 kWh
├─ Tipo 2: 0 kWh
└─ Clasificación: NONE
```

---

## 5. PROGRAMA PDE

### Marco Regulatorio

**Artículo Aplicable:** CREG 101 072 de 2025, Art. 3 - Programa de Distribución de Excedentes

**Definición:**
El **Programa de Distribución de Excedentes (PDE)** es un mecanismo de solidaridad energética donde prosumidores ceden **gratuitamente** un porcentaje de sus excedentes Tipo 2 a consumidores sin capacidad de generación.

### Límite Máximo 10%

**Regla CRÍTICA:**
```
PDE ≤ 10% del total de excedentes Tipo 2 de la comunidad
```

**Cálculo:**
```
Total Tipo 2 Comunidad = Σ (Tipo 2 de todos los prosumidores)
PDE Máximo = Total Tipo 2 * 0.10
```

**Ejemplo Comunidad UAO:**
```
Total Tipo 2 de todos los prosumidores: 150 kWh
PDE Máximo permitido: 15 kWh (10%)

Si se asignan 16 kWh → ❌ VIOLACIÓN CREG 101 072
Si se asignan 15 kWh → ✅ CUMPLE
Si se asignan 10 kWh → ✅ CUMPLE
```

**Estado Actual BeEnergy (Noviembre 2025):**
- Total Tipo 2: 300 kWh
- PDE asignado: 125 kWh
- Porcentaje: **41.7%** ❌ **VIOLACIÓN CRÍTICA**

**Estado Objetivo (Diciembre 2025):**
- Total Tipo 2: 70 kWh
- PDE asignado: 7 kWh
- Porcentaje: **10%** ✅ **CUMPLE**

---

### Distribución Homogénea

**Regla:**
El PDE debe distribuirse de forma **homogénea** entre todos los consumidores elegibles.

**Consumidores Elegibles:**
- ✅ Usuarios que NO tienen capacidad de generación
- ✅ `isProsumer = false`
- ✅ `category = MemberCategory.consumer`
- ✅ `isActiveInCommunity = true`

**Algoritmo de Distribución:**
```dart
class PDEAllocator {
  List<PDEAllocation> allocate({
    required double totalType2,
    required List<CommunityMember> consumers,
  }) {
    // 1. Calcular PDE total (máximo 10%)
    final pdeTotal = totalType2 * 0.10;

    // 2. Filtrar consumidores elegibles
    final eligible = consumers
      .where((c) => !c.isProsumer && c.isActiveInCommunity)
      .toList();

    // 3. Distribución homogénea
    final pdePerConsumer = pdeTotal / eligible.length;

    // 4. Crear asignaciones
    return eligible.map((consumer) => PDEAllocation(
      userId: consumer.userId,
      allocatedEnergy: pdePerConsumer,
      sharePercentage: pdePerConsumer / totalType2,
      isPDECompliant: true,
    )).toList();
  }
}
```

**Ejemplo:**
```
Total Tipo 2: 150 kWh
PDE Máximo: 15 kWh (10%)
Consumidores elegibles: 3 (Ana, Juan, Sofía)

Distribución:
├─ Ana López:    5 kWh (33.33%)
├─ Juan Torres:  5 kWh (33.33%)
└─ Sofía Ramírez: 5 kWh (33.33%)

Total: 15 kWh ✅ CUMPLE ≤10%
```

---

### Rol del Administrador

**Responsabilidades:**
1. **Calcular** el PDE máximo (10% del Tipo 2 total)
2. **Validar** que la suma de asignaciones ≤ PDE máximo
3. **Distribuir** homogéneamente entre consumidores
4. **Aprobar** la asignación mensual
5. **Auditar** el cumplimiento regulatorio

**Pantalla Admin PDE Assignment:**
```
┌─────────────────────────────────────────┐
│  Resumen Tipo 2                         │
│  Total: 70 kWh                          │
│  PDE Máximo (10%): 7 kWh                │
├─────────────────────────────────────────┤
│  Consumidores Elegibles                 │
│  ☑ Ana López      7 kWh (100%)          │
├─────────────────────────────────────────┤
│  Validación                             │
│  Suma PDE: 7 kWh                        │
│  Porcentaje: 10.0% ✅ CUMPLE            │
│  [Asignar PDE]                          │
└─────────────────────────────────────────┘
```

---

### Validaciones Críticas

**1. Límite 10%**
```dart
bool validatePDELimit(PDEAllocation allocation) {
  return allocation.sharePercentage <= 0.10;
}
```

**2. Solo Tipo 2**
```dart
// El PDE SOLO puede asignarse desde excedentes Tipo 2
// Tipo 1 NO es elegible
bool validateType2Only(PDEAllocation allocation) {
  return allocation.surplusType2Only > 0;
}
```

**3. Suma Total**
```dart
bool validateTotalPDE(List<PDEAllocation> allocations, double totalType2) {
  final pdeTotal = allocations.fold(0.0, (sum, a) => sum + a.allocatedEnergy);
  return pdeTotal <= (totalType2 * 0.10);
}
```

---

### Corrección del 41.7% Actual

**Problema Identificado:**
En el MVP actual (Noviembre 2025), el PDE está en **41.7%**, lo cual es una **violación crítica** de CREG 101 072.

**Causa:**
Los datos de fake_data tenían asignaciones incorrectas.

**Solución (Fase 2):**
1. Recalcular PDE con límite 10%
2. Redistribuir excedentes a P2P
3. Actualizar fake_data con valores correctos
4. Implementar validación en RegulatoryValidator
5. Mostrar alerta visual si >10%

**Antes (Noviembre 2025):**
```
Total Tipo 2: 300 kWh
PDE asignado: 125 kWh
Porcentaje: 41.7% ❌
```

**Después (Diciembre 2025):**
```
Total Tipo 2: 70 kWh
PDE asignado: 7 kWh
Porcentaje: 10.0% ✅
```

---

## 6. VALOR DE ENERGÍA (VE)

### Marco Regulatorio

**Artículo Aplicable:** CREG 101 072 de 2025, Art. 5 - Valor de Energía

El **Valor de Energía (VE)** es el precio de referencia para intercambios P2P, calculado mensualmente basándose en los costos del mercado mayorista.

### Fórmula de Cálculo

```
VE = CU + MC + PCN
```

**Componentes:**

1. **CU (Cargo por Uso):** 150 COP/kWh
   - Costo de uso de redes de transmisión y distribución
   - Definido por operador de red

2. **MC (Cargo de Comercialización):** 200 COP/kWh
   - Costo de comercialización del servicio
   - Incluye gestión, facturación, atención

3. **PCN (Precio Cargo de Energía):** 100 COP/kWh
   - Precio de la energía en el mercado mayorista
   - Actualizado mensualmente por XM

**Cálculo BeEnergy (MVP):**
```
VE = 150 + 200 + 100 = 450 COP/kWh
```

---

### Rango Permitido P2P: VE ±10%

**Regla:**
Los precios de ofertas P2P deben estar dentro del rango **VE ±10%**.

**Cálculo del Rango:**
```dart
class VECalculation {
  final double totalVE = 450;          // COP/kWh
  final double minAllowedPrice = 405;  // VE * 0.9
  final double maxAllowedPrice = 495;  // VE * 1.1

  bool isPriceWithinRange(double price) {
    return price >= minAllowedPrice && price <= maxAllowedPrice;
  }
}
```

**Rango Permitido BeEnergy:**
```
VE = 450 COP/kWh
Mínimo: 405 COP/kWh (VE - 10%)
Máximo: 495 COP/kWh (VE + 10%)
```

**Validación de Precios:**

| Precio Oferta | VE | Rango | ¿Válido? |
|---------------|-------|-------|----------|
| 400 COP/kWh | 450 | 405-495 | ❌ Fuera de rango (bajo) |
| 405 COP/kWh | 450 | 405-495 | ✅ Mínimo permitido |
| 475 COP/kWh | 450 | 405-495 | ✅ Dentro de rango |
| 495 COP/kWh | 450 | 405-495 | ✅ Máximo permitido |
| 500 COP/kWh | 450 | 405-495 | ❌ Fuera de rango (alto) |

---

### Validación de Precios de Ofertas

**Servicio:**
```dart
class RegulatoryValidator {
  bool validateP2PPrice(double price, VECalculation ve) {
    if (price < ve.minAllowedPrice) {
      throw Exception('Precio ${price} es menor al mínimo permitido ${ve.minAllowedPrice}');
    }

    if (price > ve.maxAllowedPrice) {
      throw Exception('Precio ${price} es mayor al máximo permitido ${ve.maxAllowedPrice}');
    }

    return true;
  }
}
```

**UI Validation (Pantalla Crear Oferta):**
```dart
Slider(
  min: 405,  // VE - 10%
  max: 495,  // VE + 10%
  value: _selectedPrice,
  label: 'Precio: $_selectedPrice COP/kWh',
  divisions: 90,
  onChanged: (value) {
    setState(() => _selectedPrice = value);
  },
)

Text(
  'Rango permitido CREG 101 072: 405-495 COP/kWh',
  style: TextStyle(color: Colors.grey, fontSize: 12),
)
```

---

### Cálculo Mensual (MVP) vs Diario (Futuro)

**MVP (Fase 2):**
- VE **fijo mensual**: 450 COP/kWh
- Fuente: `source: 'manual'`
- Actualización: Manual cada mes

**Producción Futura:**
- VE **dinámico diario**
- Fuente: API XM (Operador del Mercado)
- Actualización: Automática cada día

**Integración con XM (Futuro):**
```dart
class VECalculator {
  Future<VECalculation> fetchFromXM(String period) async {
    // Conectar a API XM
    final response = await http.get('https://api.xm.com.co/ve/$period');
    final data = jsonDecode(response.body);

    return VECalculation(
      period: period,
      cuComponent: data['cu'],
      mcComponent: data['mc'],
      pcnComponent: data['pcn'],
      totalVE: data['total'],
      minAllowedPrice: data['total'] * 0.9,
      maxAllowedPrice: data['total'] * 1.1,
      source: 'XM',
    );
  }
}
```

---

## 7. NÚMERO DE IDENTIFICACIÓN ÚNICA (NIU)

### Marco Regulatorio

**Artículo Aplicable:** CREG 101 072 de 2025, Art. 7 - Identificación de Usuarios

Todos los usuarios de comunidades energéticas deben tener un **Número de Identificación Única (NIU)** que los identifique en el sistema.

### Formato del NIU

**Estructura:**
```
NIU-{COMUNIDAD}-{ID}-{AÑO}
```

**Componentes:**

1. **Prefijo:** `NIU` (fijo)
2. **COMUNIDAD:** Código de la comunidad (alfanumérico, mayúsculas)
3. **ID:** Identificador único del usuario (3 dígitos con padding)
4. **AÑO:** Año de registro (4 dígitos)

**Ejemplos:**
```
NIU-UAO-024-2025  → Usuario 24, UAO, registrado en 2025
NIU-UAO-001-2025  → Usuario 1 (Admin), UAO, registrado en 2025
NIU-UAO-013-2025  → Usuario 13, UAO, registrado en 2025
```

---

### Validación Regex

**Expresión Regular:**
```dart
final niuRegex = RegExp(r'^NIU-[A-Z0-9]+-\d{3}-\d{4}$');
```

**Validación:**
```dart
bool validateNIU(String niu) {
  return RegExp(r'^NIU-[A-Z0-9]+-\d{3}-\d{4}$').hasMatch(niu);
}

// Ejemplos
validateNIU('NIU-UAO-024-2025')  // ✅ true
validateNIU('NIU-ABC-001-2025')  // ✅ true
validateNIU('invalid-niu')       // ❌ false
validateNIU('NIU-UAO-24-2025')   // ❌ false (falta padding)
validateNIU('niu-uao-024-2025')  // ❌ false (minúsculas)
```

---

### Relación con Documento de Identidad

**Campos Adicionales:**

```dart
class CommunityMember {
  final String niu;               // NIU-UAO-024-2025
  final String documentType;      // 'CC', 'NIT', 'CE', 'TI'
  final String documentNumber;    // '1234567890'
}
```

**Tipos de Documento:**
- **CC:** Cédula de Ciudadanía (personas naturales)
- **NIT:** Número de Identificación Tributaria (personas jurídicas)
- **CE:** Cédula de Extranjería (extranjeros)
- **TI:** Tarjeta de Identidad (menores de edad)

**Ejemplo:**
```
Usuario: María García
NIU: NIU-UAO-024-2025
Tipo Documento: CC
Número Documento: 1234567890
```

---

### Generación Automática de NIU

**Algoritmo:**
```dart
class NIUGenerator {
  String generate({
    required String community,
    required int userId,
    required int year,
  }) {
    final communityCode = community.toUpperCase();
    final userIdPadded = userId.toString().padLeft(3, '0');

    return 'NIU-$communityCode-$userIdPadded-$year';
  }
}

// Uso
final niuGen = NIUGenerator();
final niu = niuGen.generate(
  community: 'UAO',
  userId: 24,
  year: 2025,
);
print(niu);  // NIU-UAO-024-2025
```

---

### Integración en Modelos

**CommunityMember:**
```dart
class CommunityMember {
  final String niu;
  final String documentType;
  final String documentNumber;

  // Validación
  bool get hasValidNIU =>
    niu.isNotEmpty &&
    RegExp(r'^NIU-[A-Z0-9]+-\d{3}-\d{4}$').hasMatch(niu);
}
```

**Validación en Servicios:**
```dart
class P2PService {
  Future<P2POffer> createOffer({...}) async {
    // Validar NIU antes de crear oferta
    final member = getCommunityMember(sellerId);
    if (!member.hasValidNIU) {
      throw Exception('Usuario no tiene NIU válido');
    }

    // Continuar con creación de oferta...
  }
}
```

---

## 8. PROCESO MENSUAL P2P

### Vista General

El proceso P2P es **mensual**, NO en tiempo real. Se ejecuta en 7 pasos secuenciales cada mes.

### Paso 1: Clasificación Automática Tipo 1 y Tipo 2

**Cuándo:** Inicio del mes (día 1)
**Responsable:** Sistema automático
**Entrada:** Datos de generación/consumo del mes anterior
**Salida:** EnergyRecord con surplusType1 y surplusType2

**Proceso:**
1. Obtener datos de medidores AMI
2. Para cada prosumidor:
   - Calcular excedente total = Generada - Consumida
   - Clasificar 50/50 en Tipo 1 y Tipo 2
   - Validar Tipo1 + Tipo2 = Total
3. Guardar EnergyRecord actualizado

**Ejemplo (María García - Diciembre 2025):**
```
Input:
  energyGenerated: 320 kWh
  energyConsumed: 180 kWh

Process:
  totalSurplus = 320 - 180 = 140 kWh
  surplusType1 = 140 * 0.5 = 70 kWh
  surplusType2 = 140 * 0.5 = 70 kWh
  classification = SurplusClassification.mixed

Output:
  EnergyRecord(
    userId: 24,
    period: '2025-12',
    surplusType1: 70,
    surplusType2: 70,
    classification: mixed,
  )
```

---

### Paso 2: Administrador Asigna PDE (≤10%)

**Cuándo:** Día 5-7 del mes
**Responsable:** Administrador de la comunidad
**Entrada:** Total Tipo 2 de todos los prosumidores
**Salida:** PDEAllocation para cada consumidor

**Proceso:**
1. Admin accede a "Admin PDE Assignment Screen"
2. Sistema muestra:
   - Total Tipo 2 disponible
   - PDE máximo (10%)
   - Lista de consumidores elegibles
3. Admin decide cuánto asignar (≤ PDE máximo)
4. Sistema distribuye homogéneamente
5. Admin valida y aprueba
6. Sistema crea PDEAllocation
7. Audita acción (AuditAction.pdeAllocated)

**Ejemplo (Comunidad UAO - Diciembre 2025):**
```
Input:
  Total Tipo 2: 70 kWh (solo de María)
  Consumidores elegibles: Ana López (1 consumidor)

Process:
  pdeMaximo = 70 * 0.10 = 7 kWh
  pdeAsignado = 7 kWh (admin decide usar 100%)
  pdePerConsumer = 7 / 1 = 7 kWh

Output:
  PDEAllocation(
    userId: 13,  // Ana
    allocatedEnergy: 7,
    sharePercentage: 0.10,  // 7/70 = 10%
    isPDECompliant: true,
  )
```

---

### Paso 3: Disponibilidad P2P Calculada

**Cuándo:** Automático después de asignar PDE
**Responsable:** Sistema
**Entrada:** Tipo 2 individual y PDE cedido
**Salida:** Disponible P2P por prosumidor

**Fórmula:**
```
Disponible P2P = Tipo 2 Individual - PDE Cedido
```

**Ejemplo (María García):**
```
Input:
  Tipo 2: 70 kWh
  PDE cedido: 7 kWh (de sus 70 kWh, contribuye a solidaridad)

Process:
  Disponible P2P = 70 - 7 = 63 kWh

Output:
  María puede ofertar hasta 63 kWh en el marketplace
```

**UI (Pantalla Crear Oferta):**
```
┌─────────────────────────────────────┐
│  Mi Disponibilidad                  │
│  Tipo 2 total:       70 kWh         │
│  PDE cedido:          7 kWh         │
│  ────────────────────────────       │
│  Disponible P2P:     63 kWh ✅      │
└─────────────────────────────────────┘
```

---

### Paso 4: Prosumidor Publica Oferta

**Cuándo:** Día 10-15 del mes
**Responsable:** Prosumidor (María)
**Entrada:** Disponible P2P, precio deseado
**Salida:** P2POffer en el marketplace

**Proceso:**
1. María accede a "Crear Oferta P2P"
2. Ve su disponibilidad: 63 kWh
3. Decide vender: 60 kWh (guarda 3 kWh)
4. Fija precio: 475 COP/kWh
5. Sistema valida:
   - ✅ 60 ≤ 63 (energía disponible)
   - ✅ 475 en rango VE (405-495)
   - ✅ NIU válido: NIU-UAO-024-2025
6. María publica oferta
7. Sistema crea P2POffer
8. Audita acción (AuditAction.offerCreated)

**Ejemplo:**
```
Input:
  sellerId: 24
  sellerName: 'María García'
  energyKwh: 60
  pricePerKwh: 475
  period: '2025-12'

Validations:
  validateP2PPrice(475, VE) → true
  validateEnergy(60, 63) → true
  validateNIU('NIU-UAO-024-2025') → true

Output:
  P2POffer(
    id: 1,
    sellerId: 24,
    energyAvailable: 60,
    energyRemaining: 60,
    pricePerKwh: 475,
    status: OfferStatus.available,
    validUntil: DateTime(2025, 12, 31, 23, 59),
  )
```

---

### Paso 5: Consumidor Ve Marketplace

**Cuándo:** Día 10-25 del mes
**Responsable:** Consumidor (Ana)
**Entrada:** Ofertas disponibles
**Salida:** Navegación a detalle de oferta

**Proceso:**
1. Ana accede a "Mercado P2P"
2. Sistema muestra ofertas disponibles
3. Ana ve:
   - Vendedor: María García (NIU-UAO-024-2025)
   - Energía: 60 kWh
   - Precio: 475 COP/kWh
   - Total: $28,500
   - Ahorro vs tarifa regulada (500 COP/kWh): -$1,500
4. Ana puede:
   - Ver detalle
   - Comparar ofertas
   - Aceptar oferta

**UI:**
```
┌──────────────────────────────────────┐
│  Ofertas Disponibles                 │
├──────────────────────────────────────┤
│  María García                        │
│  NIU: NIU-UAO-024-2025               │
│  60 kWh @ 475 COP/kWh                │
│  Total: $28,500                      │
│  Ahorro: -$1,500 (5%)                │
│  [Ver Detalle] [Aceptar Oferta]      │
└──────────────────────────────────────┘
```

---

### Paso 6: Aceptación y Creación de Contrato

**Cuándo:** Día 15-28 del mes
**Responsable:** Consumidor (Ana)
**Entrada:** Oferta seleccionada, cantidad a comprar
**Salida:** P2PContract creado

**Proceso:**
1. Ana selecciona oferta de María
2. Ve detalle completo:
   - Datos del vendedor
   - Cumplimiento regulatorio (VE)
   - Comparación con tarifa regulada
3. Ana decide comprar: 50 kWh (de 60 disponibles)
4. Sistema valida:
   - ✅ 50 ≤ 60 (energía disponible)
5. Muestra confirmación:
   - Vendedor: María García
   - Comprador: Ana López
   - Energía: 50 kWh
   - Precio: 475 COP/kWh
   - Total: $23,750
6. Ana confirma compra
7. Sistema:
   - Crea P2PContract
   - Actualiza P2POffer (energyRemaining: 10)
   - Audita (AuditAction.contractExecuted)
   - Notifica a ambas partes

**Ejemplo:**
```
Input:
  offer: P2POffer(id: 1, energyRemaining: 60)
  buyerId: 13
  buyerName: 'Ana López'
  energyKwh: 50

Process:
  contract = P2PContract(
    id: 201,
    sellerId: 24,
    buyerId: 13,
    energyCommitted: 50,
    agreedPrice: 475,
    calculatedVE: 450,
    priceWithinVERange: true,
    period: '2025-12',
    status: 'active',
  )

  updatedOffer = offer.copyWith(
    energyRemaining: 10,  // 60 - 50
    status: OfferStatus.partial,
  )

Output:
  Contrato #201 creado ✅
  Oferta actualizada (10 kWh restantes)
```

---

### Paso 7: Liquidación Fin de Mes

**Cuándo:** Día 30-31 del mes
**Responsable:** Sistema + Admin
**Entrada:** Todos los contratos P2P del mes
**Salida:** UserBilling por cada usuario

**Proceso:**
1. Sistema obtiene:
   - Contratos P2P del mes
   - PDE asignado
   - Energía de red consumida
2. Calcula para cada usuario:
   - Escenario Tradicional
   - Escenario P2P Real
   - Ahorros
3. Admin revisa liquidación
4. Admin aprueba cierre de mes
5. Mes pasa a histórico (Fase 1)

**Ejemplo - Liquidación Ana (Consumidor):**
```
Datos del mes:
  Consumo total: 180 kWh
  PDE recibido: 7 kWh @ 0 COP
  P2P comprado: 50 kWh @ 475 COP/kWh = $23,750
  Red: 180 - 7 - 50 = 123 kWh @ 450 COP/kWh = $55,350

Cálculos:
  Escenario Tradicional:
    180 kWh @ 500 COP/kWh = $90,000

  Escenario P2P Real:
    PDE: 7 kWh @ 0 = $0
    P2P: 50 kWh @ 475 = $23,750
    Red: 123 kWh @ 450 = $55,350
    Total = $79,100

  Ahorro:
    $90,000 - $79,100 = $10,900
    Porcentaje: 12.1%

Output:
  UserBilling(
    userId: 13,
    period: '2025-12',
    traditionalCost: 90000,
    p2pScenarioCost: 79100,
    savings: 10900,
    savingsPercentage: 12.1,
  )
```

**Ejemplo - Liquidación María (Prosumidora):**
```
Datos del mes:
  Generación: 320 kWh
  Autoconsumo: 180 kWh
  Excedente: 140 kWh
    ├─ Tipo 1: 70 kWh @ 0 (solidaridad)
    ├─ Tipo 2 PDE: 7 kWh @ 0 (solidaridad)
    └─ P2P vendido: 50 kWh @ 475 = $23,750

Cálculos:
  Ingreso P2P: +$23,750

Output:
  UserBilling(
    userId: 24,
    period: '2025-12',
    p2pRevenue: 23750,
  )
```

---

## 9. AUDITORÍA Y CUMPLIMIENTO

### Marco Regulatorio

**Artículo Aplicable:** CREG 101 072 de 2025, Art. 9 - Trazabilidad y Auditoría

Todas las operaciones de la comunidad energética deben ser **auditables** y **trazables**.

### RegulatoryAuditLog

**Modelo:**
```dart
class RegulatoryAuditLog {
  final int id;
  final int userId;
  final AuditAction actionType;
  final String resourceType;       // 'P2PContract', 'P2POffer', etc.
  final int resourceId;
  final Map<String, dynamic> data; // Datos completos de la acción
  final String regulationArticle;  // 'CREG 101 072 Art 2.1'
  final ComplianceStatus complianceStatus;
  final DateTime createdAt;
}
```

---

### ¿Qué se Audita?

**Acciones Auditadas:**

```dart
enum AuditAction {
  surplusClassified,     // Paso 1: Clasificación Tipo 1/2
  pdeAllocated,          // Paso 2: Asignación PDE
  offerCreated,          // Paso 4: Creación de oferta
  offerAccepted,         // Paso 6: Aceptación de oferta
  contractExecuted,      // Paso 6: Ejecución de contrato
  monthClosed,           // Paso 7: Cierre de mes
}
```

**Compliance Status:**

```dart
enum ComplianceStatus {
  compliant,    // ✅ Cumple regulación
  warning,      // ⚠️ Alerta, revisar
  violation     // ❌ Violación regulatoria
}
```

---

### ¿Cuándo se Audita?

**Ejemplo - Creación de Oferta:**
```dart
class P2PService {
  Future<P2POffer> createOffer({...}) async {
    // ... validaciones ...

    // Crear oferta
    final offer = P2POffer(...);
    FakeData.offers.add(offer);

    // Auditar
    _auditAction(
      userId: sellerId,
      actionType: AuditAction.offerCreated,
      resourceType: 'P2POffer',
      resourceId: offer.id,
      data: offer.toJson(),
      regulationArticle: 'CREG 101 072 Art 2.3',
      complianceStatus: ComplianceStatus.compliant,
    );

    return offer;
  }

  void _auditAction({...}) {
    final log = RegulatoryAuditLog(
      id: _generateId(),
      userId: userId,
      actionType: actionType,
      resourceType: resourceType,
      resourceId: resourceId,
      data: data,
      regulationArticle: regulationArticle,
      complianceStatus: complianceStatus,
      createdAt: DateTime.now(),
    );

    FakeData.auditLogs.add(log);
  }
}
```

---

### Exportación de Reportes

**Formatos:**
- CSV (Excel)
- PDF
- JSON (API)

**Reporte Mensual:**
```
Comunidad Energética UAO
Período: Diciembre 2025
Reporte de Cumplimiento CREG 101 072

┌────────────────────────────────────────────────────────┐
│  CLASIFICACIÓN DE EXCEDENTES                           │
├────────────────────────────────────────────────────────┤
│  Total Tipo 1:   70 kWh                                │
│  Total Tipo 2:   70 kWh                                │
│  Clasificados:   1/1 prosumidores (100%)               │
│  Estado:         ✅ CUMPLE                             │
├────────────────────────────────────────────────────────┤
│  PDE                                                   │
├────────────────────────────────────────────────────────┤
│  Total Tipo 2:      70 kWh                             │
│  PDE asignado:       7 kWh                             │
│  Porcentaje:        10.0%                              │
│  Estado:            ✅ CUMPLE (≤10%)                   │
├────────────────────────────────────────────────────────┤
│  OFERTAS P2P                                           │
├────────────────────────────────────────────────────────┤
│  Ofertas publicadas:    1                              │
│  Precio promedio:       475 COP/kWh                    │
│  VE del período:        450 COP/kWh                    │
│  Rango permitido:       405-495 COP/kWh                │
│  Dentro de rango:       1/1 (100%)                     │
│  Estado:                ✅ CUMPLE                      │
├────────────────────────────────────────────────────────┤
│  CONTRATOS P2P                                         │
├────────────────────────────────────────────────────────┤
│  Contratos creados:     1                              │
│  Energía transada:      50 kWh                         │
│  Valor total:           $23,750                        │
│  Estado:                ✅ CUMPLE                      │
├────────────────────────────────────────────────────────┤
│  CUMPLIMIENTO GENERAL                                  │
├────────────────────────────────────────────────────────┤
│  Transacciones:         4                              │
│  Conformes:             4 (100%)                       │
│  Alertas:               0 (0%)                         │
│  Violaciones:           0 (0%)                         │
│  ESTADO:                ✅ 100% CUMPLIMIENTO           │
└────────────────────────────────────────────────────────┘

Generado: 31/12/2025 23:59
Responsable: Administrador UAO
NIU: NIU-UAO-001-2025
```

---

## 10. CHECKLIST DE CUMPLIMIENTO

### Estado Actual vs Objetivo

| # | Requisito CREG | Artículo | Estado Actual (Fase 1) | Estado Objetivo (Fase 2) | Prioridad | Sprint |
|---|----------------|----------|------------------------|--------------------------|-----------|--------|
| 1 | Clasificación excedentes Tipo 1 | Art 2.1 | ❌ NO | ✅ Implementar | CRÍTICA | Sprint 1 |
| 2 | Clasificación excedentes Tipo 2 | Art 2.2 | ❌ NO | ✅ Implementar | CRÍTICA | Sprint 1 |
| 3 | Validación suma Tipo1+Tipo2=Total | Art 2.3 | ❌ NO | ✅ Implementar | CRÍTICA | Sprint 1 |
| 4 | Límite PDE ≤10% | Art 3.4 | ❌ 41.7% | ✅ Corregir a 10% | CRÍTICA | Sprint 1 |
| 5 | Distribución homogénea PDE | Art 3.5 | ⚠️ PARCIAL | ✅ Implementar | MAYOR | Sprint 1 |
| 6 | Consumidores elegibles PDE | Art 3.2 | ⚠️ PARCIAL | ✅ Implementar | MAYOR | Sprint 1 |
| 7 | NIU formato correcto | Art 7.1 | ❌ NO | ✅ Implementar | CRÍTICA | Sprint 1 |
| 8 | NIU único por usuario | Art 7.2 | ❌ NO | ✅ Implementar | CRÍTICA | Sprint 1 |
| 9 | Relación NIU-Documento | Art 7.3 | ❌ NO | ✅ Implementar | MAYOR | Sprint 1 |
| 10 | Cálculo VE mensual | Art 5.1 | ⚠️ PARCIAL (fijo) | ✅ Implementar | CRÍTICA | Sprint 2 |
| 11 | Rango VE ±10% | Art 5.3 | ❌ NO | ✅ Implementar | CRÍTICA | Sprint 2 |
| 12 | Validación precio P2P con VE | Art 5.4 | ❌ NO | ✅ Implementar | CRÍTICA | Sprint 2 |
| 13 | Ofertas P2P manuales | Art 2.4 | ❌ NO | ✅ Implementar | CRÍTICA | Sprint 2 |
| 14 | Marketplace ofertas | Art 2.5 | ❌ NO | ✅ Implementar | CRÍTICA | Sprint 2 |
| 15 | Aceptación bilateral | Art 2.6 | ❌ NO | ✅ Implementar | CRÍTICA | Sprint 2 |
| 16 | Creación contrato P2P | Art 2.7 | ⚠️ PARCIAL (estático) | ✅ Implementar | CRÍTICA | Sprint 2 |
| 17 | Auditoría clasificación | Art 9.1 | ❌ NO | ✅ Implementar | MAYOR | Sprint 3 |
| 18 | Auditoría PDE | Art 9.2 | ❌ NO | ✅ Implementar | MAYOR | Sprint 3 |
| 19 | Auditoría ofertas | Art 9.3 | ❌ NO | ✅ Implementar | MAYOR | Sprint 3 |
| 20 | Auditoría contratos | Art 9.4 | ❌ NO | ✅ Implementar | MAYOR | Sprint 3 |
| 21 | Exportación reportes CSV | Art 9.5 | ❌ NO | ✅ Implementar | MENOR | Sprint 3 |
| 22 | Exportación reportes PDF | Art 9.6 | ❌ NO | ✅ Implementar | MENOR | Sprint 3 |
| 23 | Liquidación mensual | Art 6.1 | ⚠️ PARCIAL | ✅ Implementar | CRÍTICA | Sprint 3 |
| 24 | Cálculo ahorros | Art 6.2 | ⚠️ PARCIAL | ✅ Implementar | MAYOR | Sprint 3 |
| 25 | Comparación escenarios | Art 6.3 | ⚠️ PARCIAL | ✅ Implementar | MAYOR | Sprint 3 |

**Total Requisitos:** 25
**Estado Actual:** 2/25 completos (8%) + 6/25 parciales (24%)
**Estado Objetivo:** 25/25 completos (100%)

---

### Prioridades

**CRÍTICA (15 requisitos):**
- Clasificación Tipo 1/2
- Validación PDE ≤10%
- NIU
- VE y validación ±10%
- Ofertas P2P manuales
- Marketplace
- Aceptación bilateral
- Creación contratos
- Liquidación

**MAYOR (8 requisitos):**
- Distribución homogénea PDE
- Consumidores elegibles
- Relación NIU-Documento
- Auditoría (clasificación, PDE, ofertas, contratos)
- Cálculo ahorros
- Comparación escenarios

**MENOR (2 requisitos):**
- Exportación CSV
- Exportación PDF

---

### Roadmap de Sprints

**Sprint 1 (Días 1-5):** Modelos y Clasificación
- Agregar campos Tipo 1/2 a EnergyRecord
- Agregar NIU a CommunityMember
- Implementar SurplusClassifier
- Implementar RegulatoryValidator (PDE ≤10%)
- Crear fake_data Fase 2

**Sprint 2 (Días 6-10):** Pantallas Transaccionales
- Admin PDE Assignment Screen
- Prosumer Create Offer Screen
- Consumer Marketplace Screen
- Offer Detail & Acceptance Screen
- Implementar P2PService

**Sprint 3 (Días 11-15):** Liquidación y Auditoría
- Implementar SettlementEngine
- Implementar AuditService
- Modificar Energy Records Screen
- Modificar PDE Allocation Screen
- Exportación de reportes

---

## 📚 REFERENCIAS REGULATORIAS

### Documentos Oficiales

1. **CREG 101 072 de 2025**
   - Resolución completa (PDF)
   - Comisión de Regulación de Energía y Gas
   - Bogotá, Colombia

2. **Ley 1715 de 2014**
   - Integración de energías renovables no convencionales
   - Congreso de la República de Colombia

3. **Ley 2099 de 2021**
   - Transición energética
   - Generación distribuida
   - Autogeneración a pequeña escala

### Entidades Reguladoras

**CREG (Comisión de Regulación de Energía y Gas)**
- Web: www.creg.gov.co
- Función: Regulación del sector energético

**UPME (Unidad de Planeación Minero Energética)**
- Web: www.upme.gov.co
- Función: Planeación del sector

**SUI (Sistema Único de Información)**
- Web: www.sui.gov.co
- Función: Información y control

**XM (Operador del Mercado)**
- Web: www.xm.com.co
- Función: Operación del mercado mayorista

**MME (Ministerio de Minas y Energía)**
- Web: www.minenergia.gov.co
- Función: Política energética nacional

---

## 📞 CONTACTO Y SOPORTE

**Proyecto BeEnergy**
- Institución: Universidad Autónoma de Occidente
- Ubicación: Cali, Valle del Cauca, Colombia
- Nivel: Maestría en Energías Renovables
- Período: 2025

**Soporte Técnico:**
- Documentación: BeEnergy/Docs/
- Plan de Implementación: BeEnergy/.claude/plans/

---

**FIN DEL DOCUMENTO**

---

**Última Actualización:** Enero 2025
**Versión:** 1.0
**Estado:** Aprobado para Implementación

---
