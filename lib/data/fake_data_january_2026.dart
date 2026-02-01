/// FASE 3: Fake Data para Sistema de Ofertas de Consumidores P2P
/// Período: Enero 2026
/// Caso de prueba: Nuevo modelo donde consumidores crean ofertas basadas en % del PDE
///
/// Este archivo contiene datos de ejemplo para demostrar el nuevo flujo
/// de liquidación manual P2P según el modelo Enero 2026.
library;

import '../models/community_models.dart';
import '../models/energy_models.dart';
import '../models/p2p_models.dart';
import '../models/consumer_offer.dart';
import '../models/liquidation_session.dart';
import '../models/regulatory_models.dart';
import 'fake_data_phase2.dart';

/// Clase que contiene todos los datos fake de Enero 2026
class FakeDataJanuary2026 {
  // ============================================================================
  // CONSTANTES ECONÓMICAS - ENERO 2026
  // ============================================================================
  // Documentación completa en: DOCS/CONSTANTES_ECONOMICAS.md

  /// MC_m - Valor Energía / Precio Promedio de los Contratos
  /// Este es el precio promedio de los contratos de la simulación económica
  /// Valor base para cálculos de rango de precios P2P
  static const double mcmValorEnergiaPromedio = 300.0; // COP/kWh

  /// Costo de comercialización
  static const double costoComercializacion = 70.0; // COP/kWh

  /// Costo de energía (tarifa total)
  static const double costoEnergia = 800.0; // COP/kWh

  // ============================================================================
  // RANGO DE PRECIOS PARA CONSUMIDORES - ENERO 2026
  // ============================================================================
  // Fórmulas documentadas en: DOCS/CONSTANTES_ECONOMICAS.md

  /// Precio mínimo que puede ofertar un consumidor
  /// Fórmula: MC_m × 1.1 = 300.0 × 1.1 = 330.0 COP/kWh
  static const double precioMinimoConsumidor = 330.0;

  /// Precio máximo que puede ofertar un consumidor
  /// Fórmula: (Costo Energía - Costo Comercialización) × 0.95
  /// = (800.0 - 70.0) × 0.95 = 730.0 × 0.95 = 693.5 COP/kWh
  static const double precioMaximoConsumidor = 693.5;

  // ============================================================================
  // USUARIOS - COMUNIDAD UAO (Reutilizar de Diciembre 2025)
  // ============================================================================

  /// USUARIO 1: PROSUMIDOR - María García
  static final CommunityMember mariaGarcia = FakeDataPhase2.mariaGarcia;

  /// USUARIO 2: CONSUMIDOR - Ana López
  static final CommunityMember anaLopez = FakeDataPhase2.anaLopez;

  /// USUARIO 3: ADMINISTRADOR - Admin UAO
  static final CommunityMember adminUAO = FakeDataPhase2.adminUAO;

  // ============================================================================
  // REGISTROS DE ENERGÍA - ENERO 2026
  // ============================================================================
  static final PDEConstants pdeConstantsJan2026 = PDEConstants(
    mcmValorEnergiaPromedio: mcmValorEnergiaPromedio,
    costoComercializacion: costoComercializacion,
    costoEnergia: costoEnergia,
  );
  /// Energía de María García - Enero 2026
  /// Generada: 300 kWh, Consumida: 170 kWh
  /// Excedente: 130 kWh → Tipo 1: 65 kWh, Tipo 2: 65 kWh (50/50)
  static final EnergyRecord mariaJan2026 = EnergyRecord(
    id: 10,
    userId: 24,
    userName: 'María García',
    communityId: 1,
    energyGenerated: 300.0, // kWh mes
    energyConsumed: 170.0, // kWh mes
    energyExported: 130.0, // kWh excedente total
    energyImported: 0.0,
    period: '2026-01',
    surplusType1: 65.0, // 50% - Autoconsumo compensado (NO vendible)
    surplusType2: 65.0, // 50% - Disponible para PDE y P2P
    classification: SurplusClassificationType.mixed,
  );

  /// Energía de Ana López - Enero 2026
  /// Solo consumidora, no genera energía
  /// Consumo: 170 kWh (todo importado de red/P2P/PDE)
  static final EnergyRecord anaJan2026 = EnergyRecord(
    id: 11,
    userId: 13,
    userName: 'Ana López',
    communityId: 1,
    energyGenerated: 0.0,
    energyConsumed: 170.0, // kWh mes
    energyExported: 0.0,
    energyImported: 170.0, // Todo de la red, PDE o P2P
    period: '2026-01',
    surplusType1: 0.0,
    surplusType2: 0.0,
    classification: SurplusClassificationType.none,
  );

  // ============================================================================
  // CLASIFICACIÓN DE EXCEDENTES - ENERO 2026
  // ============================================================================

  /// Clasificación de excedentes de María
  /// Total: 130 kWh → Tipo 1: 65 kWh, Tipo 2: 65 kWh
  static final SurplusClassification mariaClassificationJan2026 =
      SurplusClassification(
    period: '2026-01',
    userId: 24,
    totalSurplus: 130.0,
    type1Surplus: 65.0, // Autoconsumo compensado
    type2Surplus: 65.0, // Disponible para mercado
    classifiedAt: DateTime(2026, 1, 1, 0, 0),
  );

  // ============================================================================
  // ASIGNACIÓN PDE - ENERO 2026
  // ============================================================================

  /// PDE asignado para Enero 2026
  /// María cede 6.5 kWh (10% de sus 65 kWh Tipo 2) para PDE
  ///
  /// IMPORTANTE: 6.5/65 = 10% ✅ CUMPLE límite regulatorio (≤10%)
  static final PDEAllocation pdeJan2026 = PDEAllocation(
    id: 10,
    userId: 24, // María cede
    userName: 'María García',
    communityId: 1,
    excessEnergy: 65.0, // Total Tipo 2 disponible
    allocatedEnergy: 6.5, // 10% cedido al PDE
    sharePercentage: 0.10, // 10% ✅ CUMPLE
    allocationPeriod: '2026-01',
    surplusType2Only: 65.0, // Base para calcular PDE
    isPDECompliant: true, // ✅ Cumple límite ≤10%
    regulationArticle: 'CREG 101 072 Art 3.4',
    pdeAllocatedToConsumers: 0.0, // Se actualizará tras liquidación
    consumerDistribution: {}, // Se llenará tras liquidación
  );

  // ============================================================================
  // OFERTAS DE CONSUMIDORES - ENERO 2026 (NUEVO MODELO)
  // ============================================================================

  /// Oferta de Ana López (Consumidora)
  ///
  /// Ana solicita el 100% del PDE disponible a 520 COP/kWh
  /// Nota: En Dic 2025 el PDE era gratis, ahora Ana PAGA por él
  ///
  /// Cálculo:
  /// - PDE total disponible: 6.5 kWh
  /// - Ana solicita: 100% = 6.5 kWh
  /// - Precio ofrecido: 520 COP/kWh (dentro del rango 330-693.5)
  /// - Costo estimado: 6.5 * 520 = 3,380 COP
  static final ConsumerOffer anaOfferJan2026 = ConsumerOffer(
    id: 1,
    buyerId: 13,
    buyerName: 'Ana López',
    communityId: 1,
    period: '2026-01',
    pdePercentageRequested: 1.0, // 100% del PDE
    pricePerKwh: 520.0, // COP/kWh (330-693.5 permitido)
    energyKwhCalculated: null, // Se calcula en liquidación
    status: ConsumerOfferStatus.pending,
    createdAt: DateTime(2026, 1, 5, 10, 0),
    validUntil: DateTime(2026, 1, 31, 23, 59),
    buyerNIU: 'NIU-UAO-013-2026',
  );

  // ============================================================================
  // SESIÓN DE LIQUIDACIÓN - ENERO 2026 (COMPLETADA)
  // ============================================================================

  /// Sesión de liquidación manual realizada por el admin
  ///
  /// Proceso:
  /// 1. Admin crea sesión (5 de enero)
  /// 2. Admin ve oferta de Ana (100% PDE a 520 COP/kWh)
  /// 3. Admin ve que María tiene 58.5 kWh disponibles para P2P
  /// 4. Admin decide asignar todo el PDE (6.5 kWh) a Ana desde María
  /// 5. Admin finaliza sesión → se genera contrato P2P
  static final LiquidationSession liquidationJan2026 = LiquidationSession(
    id: 1,
    period: '2026-01',
    communityId: 1,
    adminUserId: 1,
    mode: LiquidationMode.manual,
    status: LiquidationStatus.completed,
    totalPDEAvailable: 6.5, // kWh disponibles
    consumerOfferIds: [1], // anaOfferJan2026
    matches: [
      LiquidationMatch(
        consumerOfferId: 1,
        buyerId: 13,
        buyerName: 'Ana López',
        prosumerId: 24,
        prosumerName: 'María García',
        energyKwh: 6.5, // Se le dio todo lo solicitado
        pricePerKwh: 520.0,
        pdePercentageFulfilled: 1.0, // 100% satisfecha
        matchedAt: DateTime(2026, 1, 10, 14, 0),
      ),
    ],
    createdAt: DateTime(2026, 1, 10, 10, 0),
    completedAt: DateTime(2026, 1, 10, 15, 0),
    totalOffersProcessed: 1,
    totalMatchesCreated: 1,
    totalEnergyMatched: 6.5,
    matchingEfficiency: 1.0, // 100%
  );

  // ============================================================================
  // CONTRATO P2P RESULTANTE DE LIQUIDACIÓN
  // ============================================================================

  /// Contrato P2P generado tras la liquidación
  ///
  /// Diferencia clave con Dic 2025:
  /// - En Dic 2025: Ana recibió 7 kWh de PDE GRATIS (0 COP)
  /// - En Ene 2026: Ana recibe 6.5 kWh de PDE PAGANDO 520 COP/kWh
  ///
  /// Validación:
  /// - Precio 520 está dentro del rango para consumidores (330-693.5) ✅
  /// - MC_m (300) × 1.1 = 330 ≤ 520 ≤ 693.5 ✅
  /// - Energía disponible: María tiene 58.5 kWh P2P ✅
  static final P2PContract contractFromLiquidationJan2026 = P2PContract(
    id: 300,
    sellerId: 24,
    sellerName: 'María García',
    buyerId: 13,
    buyerName: 'Ana López',
    communityId: 1,
    energyCommitted: 6.5, // kWh
    agreedPrice: 520.0, // COP/kWh
    status: 'active',
    createdAt: DateTime(2026, 1, 10, 15, 0),
    period: '2026-01',
    calculatedVE: 300.0, // MC_m del período
    priceWithinVERange: true, // 520 está dentro del rango 330-693.5
    completedAt: null, // Aún no completado
  );

  // ============================================================================
  // LIQUIDACIÓN MENSUAL - ENERO 2026
  // ============================================================================

  /// Liquidación de Ana López (Consumidora) - Enero 2026
  ///
  /// CAMBIO CLAVE: Ahora Ana PAGA por el PDE
  ///
  /// CONSUMO TOTAL: 170 kWh
  ///
  /// DESGLOSE:
  /// 1. PDE comprado: 6.5 kWh @ 520 COP = 3,380 COP (YA NO GRATIS)
  /// 2. P2P adicional: 0 kWh (no compró más)
  /// 3. Red pública: 170 - 6.5 = 163.5 kWh @ 450 COP = 73,575 COP
  ///
  /// TOTAL ENERO 2026: 3,380 + 73,575 = 76,955 COP
  ///
  /// COMPARACIÓN:
  /// - Tradicional: 170 kWh @ 550 COP = 93,500 COP
  /// - Enero 2026: 76,955 COP
  /// - AHORRO: 93,500 - 76,955 = 16,545 COP (17.7%) ✅
  ///
  /// vs Diciembre 2025:
  /// - Dic 2025: 79,100 COP (PDE gratis + 50 kWh P2P)
  /// - Ene 2026: 76,955 COP (PDE pagado + 0 kWh P2P)
  /// - Diferencia: Ana ahorra más en Ene 2026 pese a pagar el PDE
  static Map<String, dynamic> get anaLiquidationJan2026 => {
        'userId': 13,
        'userName': 'Ana López',
        'period': '2026-01',
        'totalConsumption': 170.0, // kWh

        // Detalle de compras
        'pdeReceived': 6.5, // kWh del PDE (YA NO GRATIS)
        'p2pPurchased': 0.0, // kWh adicional P2P
        'gridPurchased': 163.5, // kWh de la red

        // Costos
        'pdeCost': 3380.0, // 6.5 * 520 (PAGADO en Ene 2026)
        'p2pCost': 0.0, // Sin compras P2P adicionales
        'gridCost': 73575.0, // 163.5 * 450
        'totalCost': 76955.0, // PDE + Grid

        // Comparación
        'traditionalCost': 93500.0, // 170 * 550
        'savings': 16545.0, // COP
        'savingsPercentage': 17.7, // %

        // Comparación con Dic 2025
        'decemberCost': 79100.0,
        'savingsVsDecember': 2145.0, // Ahorra más en Ene 2026

        // Cumplimiento
        'isCompliant': true,
        'regulationArticle': 'CREG 101 072',
      };

  /// Liquidación de María García (Prosumidora) - Enero 2026
  ///
  /// GENERACIÓN: 300 kWh
  /// AUTOCONSUMO: 170 kWh
  /// EXCEDENTE: 130 kWh
  ///
  /// DESGLOSE EXCEDENTE:
  /// 1. Tipo 1 cedido: 65 kWh @ 0 COP (solidaridad pasiva)
  /// 2. PDE cedido: 6.5 kWh @ 0 COP (solidaridad activa - María no cobra)
  /// 3. PDE vendido vía liquidación: 6.5 kWh @ 520 COP = 3,380 COP
  ///    (Este es el ingreso que María recibe por el PDE vendido a Ana)
  /// 4. Tipo 2 restante: 52 kWh sin vender
  ///
  /// INGRESO ENERO 2026: +3,380 COP
  ///
  /// Nota: María gana MENOS en Ene 2026 que en Dic 2025:
  /// - Dic 2025: 23,750 COP (50 kWh @ 475)
  /// - Ene 2026: 3,380 COP (6.5 kWh @ 520)
  /// - Diferencia: -20,370 COP
  ///
  /// Pero María ahorra en autoconsumo: 170 kWh @ 550 = 93,500 COP
  static Map<String, dynamic> get mariaLiquidationJan2026 => {
        'userId': 24,
        'userName': 'María García',
        'period': '2026-01',
        'totalGeneration': 300.0, // kWh
        'totalConsumption': 170.0, // kWh
        'totalSurplus': 130.0, // kWh

        // Clasificación excedentes
        'type1Surplus': 65.0, // Autoconsumo compensado (NO vendible)
        'type2Surplus': 65.0, // Disponible para PDE y P2P

        // PDE
        'pdeCeded': 6.5, // 10% solidaridad (María no cobra por esto)
        'pdeSoldViaLiquidation': 6.5, // Vendido a Ana vía liquidación
        'pdeIncome': 3380.0, // 6.5 * 520

        // P2P
        'p2pSold': 0.0, // Sin ventas P2P adicionales
        'p2pIncome': 0.0,

        // Disponibilidad restante
        'type2Remaining': 52.0, // 65 - 6.5 - 6.5 = 52 kWh sin vender

        // Ingresos totales
        'totalIncome': 3380.0, // Solo del PDE vendido

        // Ahorro en autoconsumo
        'selfConsumptionSavings': 93500.0, // 170 @ 550 no comprados

        // Comparación con Dic 2025
        'decemberIncome': 23750.0,
        'incomeChange': -20370.0, // Ganó menos en Ene 2026

        // Cumplimiento
        'isCompliant': true,
        'regulationArticle': 'CREG 101 072',
      };

  // ============================================================================
  // RESUMEN COMPARATIVO: DICIEMBRE 2025 vs ENERO 2026
  // ============================================================================

  /// Comparación de los dos modelos
  static Map<String, dynamic> get modelComparison => {
        'december2025': {
          'model': 'Prosumidores venden kWh fijos',
          'pdeModel': 'Gratis (solidaridad)',
          'priceRange': 'VE ±10% (405-495)',
          'liquidation': 'Aceptación directa',
          'anaReceived': 7.0, // kWh PDE gratis
          'anaPaid': 0.0, // Por el PDE
          'anaTotalCost': 79100.0,
          'mariaSold': 50.0, // kWh P2P
          'mariaIncome': 23750.0,
        },
        'january2026': {
          'model': 'Consumidores ofertan % del PDE',
          'pdeModel': 'Pagado (precio ofertado)',
          'priceRange': 'MC_m×1.1 a (Energía-Comercialización)×0.95 (330-693.5)',
          'liquidation': 'Matching manual por admin',
          'anaReceived': 6.5, // kWh PDE comprado
          'anaPaid': 3380.0, // Por el PDE
          'anaTotalCost': 76955.0,
          'mariaSold': 6.5, // kWh vía liquidación
          'mariaIncome': 3380.0,
        },
        'changes': {
          'anaSavings': -2145.0, // Ana ahorra MÁS en Ene 2026
          'mariaIncome': -20370.0, // María gana MENOS en Ene 2026
          'pdeIsFree': false, // Cambio fundamental
          'liquidationRequired': true, // Nuevo proceso requerido
        },
      };
}

class PDEConstants {
  final double mcmValorEnergiaPromedio;
  final double costoComercializacion;
  final double costoEnergia;

  PDEConstants({
    required this.mcmValorEnergiaPromedio,
    required this.costoComercializacion,
    required this.costoEnergia,
  });
}