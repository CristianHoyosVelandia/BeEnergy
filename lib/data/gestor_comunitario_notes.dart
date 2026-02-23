// =============================================================================
// NOTAS PARA IMPLEMENTACIÓN DEL GESTOR COMUNITARIO
// Archivo de referencia – NO se importa en ningún lugar del código.
// Actualizado: 2026-01-05 | Caso de estudio: 2 usuarios, período 2026-01
// =============================================================================
//
// 1. USUARIOS DEL CASO DE ESTUDIO
// ---------------------------------------------------------------------------
//   Prosumidor (l₁) – mariaGarcia  (userId: 1)
//   Consumidor (k₁) – cristianHoyos (userId: 13)
//   Administrador    – adminUAO     (userId: 100)  [solo lectura]
//
// 2. PARÁMETROS ECONÓMICOS (constantes en FakeDataPhase2)
// ---------------------------------------------------------------------------
//   MC                  = 300  COP/kWh   (Marginal Cost)
//   CUV                 = 800  COP/kWh   (Costo Unitario de Venta)
//   Comercialización    =  70  COP/kWh
//   Precio P2P negociado = 400 COP/kWh
//
//   Rango VE consumidor: MC×1.1 … (CUV – Comercialización)×0.95
//                       = 330 … 693.5 COP/kWh
//
// 3. DATOS ENERGÉTICOS – PROSUMIDOR (l₁) | Período 2026-01
// ---------------------------------------------------------------------------
//   Energía generada     627.9 kWh
//   Energía consumida    107.7 kWh   (= autoconsumo = importada)
//   Energía exportada    520.2 kWh
//   Excedentes totales   412.5 kWh   (= generada – consumida – PDE Tipo 1)
//   Exc. Tipo 1 por PDE  107.7 kWh   (autoconsumo compensado, no vendible)
//   Exc. Tipo 2 por PDE    4.12 kWh  (cedido al PDE)
//
// 4. DATOS ENERGÉTICOS – CONSUMIDOR (k₁) | Período 2026-01
// ---------------------------------------------------------------------------
//   Energía consumida    120.0 kWh
//   Energía importada    120.0 kWh
//   Exportada              0.0 kWh
//   PDE participación      9.99 %
//   PDE asignado          41.21 kWh  (= 412.5 × 0.0999 ≈ 41.21)
//   Exc. Tipo 1 por PDE   41.21 kWh
//   Exc. Tipo 2 por PDE    0.0  kWh
//
// 5. PDE (Programa de Distribución de Excedentes)
// ---------------------------------------------------------------------------
//   Base de cálculo      412.5 kWh  (excedentes totales del prosumidor)
//   Límite regulatorio   ≤ 10 %     (CREG 101 072 Art 3.4)
//   Asignado al consumidor 41.21 kWh
//   consumerDistribution: { 13 → 41.21 }
//   isPDECompliant       true
//
// 6. P2P – OFERTA Y CONTRATO
// ---------------------------------------------------------------------------
//   Oferta (mariaOffer)
//     energyAvailable  412.5 kWh
//     pricePerKwh      400   COP/kWh
//     período          2026-01
//
//   Contrato (contract1)
//     energyCommitted  408.38 kWh   (= 163 352 / 400)
//     agreedPrice      400   COP/kWh
//     ingreso P2P prosumidor  163 352 COP
//     costo  P2P consumidor  –16 484 COP
//
// 7. LIQUIDACIÓN ECONÓMICA
// ---------------------------------------------------------------------------
//   Prosumidor (l₁)
//     VE (Valor de Energía)          –  6 303 COP
//     VF (Valor Final)              157 049 COP
//     Ingreso fuera CE (AGPE)       116 210 COP
//     Ganancia adicional en CE       40 839 COP
//
//   Consumidor (k₁)
//     VE (Valor de Energía)         – 65 916 COP
//     VF (Valor Final)              – 82 400 COP
//     Factura tradicional (sin CE)  – 96 000 COP
//     Ahorro por participar en CE    13 600 COP
//
// 8. QUÉ DEBE HACER EL GESTOR COMUNITARIO (pendiente)
// ---------------------------------------------------------------------------
//   a) Mostrar resumen de la comunidad: 2 miembros, 1 prosumidor, 1 consumidor.
//   b) Pantalla de asignación PDE: base = excessEnergy del PDEAllocation (412.5),
//      no surplusType2 del EnergyRecord.  Límite 10 %.
//   c) Pantalla de liquidación por miembro: usar mapas
//      anaLiquidation / mariaLiquidation de FakeDataPhase2.
//   d) Validación de asignación: por ahora se omite la validación del 100 %
//      (los datos del caso de estudio no suman exactamente al total).
//   e) Datos fuente: FakeDataPhase2 en lib/data/fake_data_phase2.dart.
//      Los nombres de las variables NO han cambiado; solo los valores.
//
// =============================================================================
