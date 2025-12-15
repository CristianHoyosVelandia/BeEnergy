/// FASE 2: Fake Data para Sistema Transaccional P2P
/// Período: Diciembre 2025
/// Caso de prueba: 1 Prosumidor + 1 Consumidor + 1 Administrador
///
/// Este archivo contiene datos de ejemplo para demostrar el flujo completo
/// del proceso mensual P2P según CREG 101 072 de 2025.
library;

import '../models/community_models.dart';
import '../models/energy_models.dart';
import '../models/p2p_models.dart';
import '../models/p2p_offer.dart';
import '../models/regulatory_models.dart';

/// Clase que contiene todos los datos fake de Fase 2
class FakeDataPhase2 {
  // ============================================================================
  // VE (VALOR DE ENERGÍA) - DICIEMBRE 2025
  // ============================================================================

  /// VE para Diciembre 2025
  /// VE = CU + MC + PCN = 150 + 200 + 100 = 450 COP/kWh
  /// Rango permitido P2P: 405-495 COP/kWh (±10%)
  static final VECalculation veDecember2025 = VECalculation.calculate(
    period: '2025-12',
    cuComponent: 150, // Cargo por Uso de redes
    mcComponent: 200, // Costo de comercialización
    pcnComponent: 100, // Precio de energía en contratos
    source: 'manual',
  );

  // ============================================================================
  // USUARIOS - COMUNIDAD UAO
  // ============================================================================

  /// USUARIO 1: PROSUMIDOR - María García
  /// Genera y consume energía, tiene excedentes disponibles para P2P
  static final CommunityMember mariaGarcia = CommunityMember(
    id: 1,
    communityId: 1,
    userId: 24,
    userName: 'María',
    userLastName: 'García',
    role: 'prosumer',
    installedCapacity: 288.0, // kW
    pdeShare: 0.10, // 10% de participación en PDE
    isActive: true,
    niu: 'NIU-UAO-024-2025',
    documentType: 'CC',
    documentNumber: '1234567890',
    category: MemberCategory.prosumer,
    registrationDate: DateTime(2025, 1, 15),
  );

  /// USUARIO 2: CONSUMIDOR - Ana López
  /// Solo consume energía, no tiene generación propia
  static final CommunityMember anaLopez = CommunityMember(
    id: 2,
    communityId: 1,
    userId: 13,
    userName: 'Ana',
    userLastName: 'López',
    role: 'consumer',
    installedCapacity: 0.0, // No tiene generación
    pdeShare: 0.0,
    isActive: true,
    niu: 'NIU-UAO-013-2025',
    documentType: 'CC',
    documentNumber: '9876543210',
    category: MemberCategory.consumer,
    registrationDate: DateTime(2025, 1, 15),
  );

  /// USUARIO 3: ADMINISTRADOR - Admin UAO
  /// Gestiona la comunidad, asigna PDE, valida cumplimiento
  static final CommunityMember adminUAO = CommunityMember(
    id: 3,
    communityId: 1,
    userId: 1,
    userName: 'Admin',
    userLastName: 'UAO',
    role: 'consumer',
    installedCapacity: 0.0,
    pdeShare: 0.0,
    isActive: true,
    niu: 'NIU-UAO-001-2025',
    documentType: 'NIT',
    documentNumber: '890000000-1',
    category: MemberCategory.consumer,
    registrationDate: DateTime(2025, 1, 1),
  );

  // ============================================================================
  // REGISTROS DE ENERGÍA - DICIEMBRE 2025
  // ============================================================================

  /// Energía de María García - Diciembre 2025
  /// Generada: 320 kWh, Consumida: 180 kWh
  /// Excedente: 140 kWh → Tipo 1: 70 kWh, Tipo 2: 70 kWh (50/50)
  static final EnergyRecord mariaDec2025 = EnergyRecord(
    id: 1,
    userId: 24,
    userName: 'María García',
    communityId: 1,
    energyGenerated: 320.0, // kWh mes
    energyConsumed: 180.0, // kWh mes
    energyExported: 140.0, // kWh excedente total
    energyImported: 0.0,
    period: '2025-12',
    surplusType1: 70.0, // 50% - Autoconsumo compensado (NO vendible)
    surplusType2: 70.0, // 50% - Disponible para PDE y P2P
    classification: SurplusClassificationType.mixed,
  );

  /// Energía de Ana López - Diciembre 2025
  /// Solo consumidora, no genera energía
  /// Consumo: 180 kWh (todo importado de red/P2P)
  static final EnergyRecord anaDec2025 = EnergyRecord(
    id: 2,
    userId: 13,
    userName: 'Ana López',
    communityId: 1,
    energyGenerated: 0.0,
    energyConsumed: 180.0, // kWh mes
    energyExported: 0.0,
    energyImported: 180.0, // Todo de la red o P2P
    period: '2025-12',
    surplusType1: 0.0,
    surplusType2: 0.0,
    classification: SurplusClassificationType.none,
  );

  // ============================================================================
  // CLASIFICACIÓN DE EXCEDENTES
  // ============================================================================

  /// Clasificación de excedentes de María
  /// Total: 140 kWh → Tipo 1: 70 kWh, Tipo 2: 70 kWh
  static final SurplusClassification mariaClassification = SurplusClassification(
    period: '2025-12',
    userId: 24,
    totalSurplus: 140.0,
    type1Surplus: 70.0, // Autoconsumo compensado
    type2Surplus: 70.0, // Disponible para mercado
    classifiedAt: DateTime(2025, 12, 1, 0, 0),
  );

  // ============================================================================
  // ASIGNACIÓN PDE - ADMINISTRADOR
  // ============================================================================

  /// PDE asignado por el administrador
  /// María cede 7 kWh (10% de sus 70 kWh Tipo 2) para PDE solidario
  /// Ana recibe 7 kWh gratis del PDE
  ///
  /// IMPORTANTE: 7/70 = 10% ✅ CUMPLE límite regulatorio (≤10%)
  static final PDEAllocation pdeDec2025 = PDEAllocation(
    id: 1,
    userId: 24, // María cede
    userName: 'María García',
    communityId: 1,
    excessEnergy: 70.0, // Total Tipo 2 disponible
    allocatedEnergy: 7.0, // 10% cedido al PDE
    sharePercentage: 0.10, // 10% ✅ CUMPLE
    allocationPeriod: '2025-12',
    surplusType2Only: 70.0, // Base para calcular PDE
    isPDECompliant: true, // ✅ Cumple límite ≤10%
    regulationArticle: 'CREG 101 072 Art 3.4',
  );

  // ============================================================================
  // OFERTAS P2P - PROSUMIDOR
  // ============================================================================

  /// Oferta publicada por María García
  ///
  /// Disponibilidad:
  /// - Tipo 2 total: 70 kWh
  /// - PDE cedido: 7 kWh
  /// - Disponible P2P: 70 - 7 = 63 kWh
  ///
  /// María decide vender 60 kWh de los 63 disponibles
  /// Precio: 475 COP/kWh (dentro del rango VE: 405-495)
  static final P2POffer mariaOffer = P2POffer(
    id: 1,
    sellerId: 24,
    sellerName: 'María García',
    communityId: 1,
    period: '2025-12',
    energyAvailable: 60.0, // kWh ofertados
    energyRemaining: 60.0, // Aún sin vender (estado inicial)
    pricePerKwh: 475.0, // COP/kWh - Dentro de rango VE ✅
    status: OfferStatus.available,
    createdAt: DateTime(2025, 12, 10, 10, 0),
    validUntil: DateTime(2025, 12, 31, 23, 59), // Último día del mes
  );

  /// Oferta después de que Ana compra 50 kWh
  /// Quedan 10 kWh disponibles
  static P2POffer get mariaOfferAfterSale => mariaOffer.copyWith(
        energyRemaining: 10.0, // 60 - 50 = 10 kWh restantes
        status: OfferStatus.partial, // Parcialmente vendida
      );

  // ============================================================================
  // CONTRATOS P2P - ACEPTACIÓN
  // ============================================================================

  /// Contrato P2P cuando Ana acepta la oferta de María
  ///
  /// Ana compra 50 kWh @ 475 COP/kWh
  /// Total: 50 * 475 = 23,750 COP
  ///
  /// Validación:
  /// - Precio 475 está en rango VE (405-495) ✅
  /// - María tiene energía disponible (60 kWh) ✅
  /// - Ambos tienen NIU válido ✅
  static final P2PContract contract1 = P2PContract(
    id: 201,
    sellerId: 24,
    sellerName: 'María García',
    buyerId: 13,
    buyerName: 'Ana López',
    communityId: 1,
    energyCommitted: 50.0, // kWh
    agreedPrice: 475.0, // COP/kWh
    status: 'active',
    createdAt: DateTime(2025, 12, 15, 14, 30),
    period: '2025-12',
    calculatedVE: 450.0, // VE del período
    priceWithinVERange: true, // ✅ 475 en rango 405-495
    completedAt: null, // Aún no completado
  );

  // ============================================================================
  // LIQUIDACIÓN MENSUAL - DICIEMBRE 2025
  // ============================================================================

  /// Liquidación de Ana López (Consumidora)
  ///
  /// CONSUMO TOTAL: 180 kWh
  ///
  /// DESGLOSE:
  /// 1. PDE recibido: 7 kWh @ 0 COP (gratis, solidaridad)
  /// 2. P2P comprado: 50 kWh @ 475 COP = 23,750 COP
  /// 3. Red pública: 180 - 7 - 50 = 123 kWh @ 450 COP = 55,350 COP
  ///
  /// TOTAL P2P: 23,750 + 55,350 = 79,100 COP
  ///
  /// COMPARACIÓN:
  /// - Tradicional: 180 kWh @ 500 COP = 90,000 COP
  /// - P2P: 79,100 COP
  /// - AHORRO: 90,000 - 79,100 = 10,900 COP (12.1%) ✅
  static Map<String, dynamic> get anaLiquidation => {
        'userId': 13,
        'userName': 'Ana López',
        'period': '2025-12',
        'totalConsumption': 180.0, // kWh

        // Detalle de compras
        'pdeReceived': 7.0, // kWh gratis
        'p2pPurchased': 50.0, // kWh @ 475
        'gridPurchased': 123.0, // kWh @ 450

        // Costos
        'pdeCost': 0.0, // Gratis
        'p2pCost': 23750.0, // 50 * 475
        'gridCost': 55350.0, // 123 * 450
        'totalCost': 79100.0, // P2P + Grid

        // Comparación
        'traditionalCost': 90000.0, // 180 * 500
        'savings': 10900.0, // COP
        'savingsPercentage': 12.1, // %

        // Cumplimiento
        'isCompliant': true,
        'regulationArticle': 'CREG 101 072',
      };

  /// Liquidación de María García (Prosumidora)
  ///
  /// GENERACIÓN: 320 kWh
  /// AUTOCONSUMO: 180 kWh
  /// EXCEDENTE: 140 kWh
  ///
  /// DESGLOSE EXCEDENTE:
  /// 1. Tipo 1 cedido: 70 kWh @ 0 COP (solidaridad pasiva)
  /// 2. PDE cedido: 7 kWh @ 0 COP (solidaridad activa)
  /// 3. P2P vendido: 50 kWh @ 475 COP = 23,750 COP
  /// 4. Tipo 2 restante: 13 kWh sin vender
  ///
  /// INGRESO P2P: +23,750 COP
  ///
  /// NOTA: María ahorra en su factura al autoconsumirse 180 kWh
  /// que no tuvo que comprar de la red @ 500 COP = 90,000 COP ahorrados
  static Map<String, dynamic> get mariaLiquidation => {
        'userId': 24,
        'userName': 'María García',
        'period': '2025-12',
        'totalGeneration': 320.0, // kWh
        'selfConsumption': 180.0, // kWh
        'totalSurplus': 140.0, // kWh

        // Clasificación excedentes
        'type1Surplus': 70.0, // NO vendible
        'type2Surplus': 70.0, // Vendible

        // Distribución Tipo 2
        'pdeContributed': 7.0, // kWh @ 0
        'p2pSold': 50.0, // kWh @ 475
        'type2Remaining': 13.0, // kWh sin vender

        // Ingresos
        'p2pRevenue': 23750.0, // 50 * 475 COP
        'selfConsumptionSavings': 90000.0, // 180 * 500 COP ahorrados

        // Cumplimiento
        'isCompliant': true,
        'pdeCompliant': true, // 7/70 = 10% ✅
        'veCompliant': true, // 475 en rango ✅
        'regulationArticle': 'CREG 101 072',
      };

  // ============================================================================
  // AUDITORÍA REGULATORIA
  // ============================================================================

  /// Registro de auditoría: Clasificación de excedentes
  static final RegulatoryAuditLog auditSurplusClassification = RegulatoryAuditLog(
    id: 1,
    userId: 24,
    actionType: AuditAction.surplusClassified,
    resourceType: 'SurplusClassification',
    resourceId: 1,
    data: {
      'totalSurplus': 140.0,
      'type1': 70.0,
      'type2': 70.0,
      'percentage': '50/50',
    },
    regulationArticle: 'CREG 101 072 Art 3.2',
    complianceStatus: ComplianceStatus.compliant,
    createdAt: DateTime(2025, 12, 1, 0, 0),
  );

  /// Registro de auditoría: Asignación PDE
  static final RegulatoryAuditLog auditPDEAllocation = RegulatoryAuditLog(
    id: 2,
    userId: 1, // Admin
    actionType: AuditAction.pdeAllocated,
    resourceType: 'PDEAllocation',
    resourceId: 1,
    data: {
      'allocatedEnergy': 7.0,
      'totalType2': 70.0,
      'percentage': 10.0,
      'limit': 10.0,
    },
    regulationArticle: 'CREG 101 072 Art 3.4',
    complianceStatus: ComplianceStatus.compliant,
    createdAt: DateTime(2025, 12, 5, 10, 0),
  );

  /// Registro de auditoría: Creación de oferta
  static final RegulatoryAuditLog auditOfferCreated = RegulatoryAuditLog(
    id: 3,
    userId: 24,
    actionType: AuditAction.offerCreated,
    resourceType: 'P2POffer',
    resourceId: 1,
    data: {
      'energyKwh': 60.0,
      'pricePerKwh': 475.0,
      've': 450.0,
      'minPrice': 405.0,
      'maxPrice': 495.0,
    },
    regulationArticle: 'CREG 101 072 Art 4.2',
    complianceStatus: ComplianceStatus.compliant,
    createdAt: DateTime(2025, 12, 10, 10, 0),
  );

  /// Registro de auditoría: Contrato ejecutado
  static final RegulatoryAuditLog auditContractExecuted = RegulatoryAuditLog(
    id: 4,
    userId: 13,
    actionType: AuditAction.contractExecuted,
    resourceType: 'P2PContract',
    resourceId: 201,
    data: {
      'seller': 'María García',
      'buyer': 'Ana López',
      'energyKwh': 50.0,
      'price': 475.0,
      've': 450.0,
      'withinRange': true,
    },
    regulationArticle: 'CREG 101 072 Art 4.3',
    complianceStatus: ComplianceStatus.compliant,
    createdAt: DateTime(2025, 12, 15, 14, 30),
  );

  // ============================================================================
  // LISTAS CONSOLIDADAS
  // ============================================================================

  /// Todos los miembros de la comunidad (Fase 2)
  static List<CommunityMember> get allMembers => [
        mariaGarcia,
        anaLopez,
        adminUAO,
      ];

  /// Todos los registros de energía (Diciembre 2025)
  static List<EnergyRecord> get allEnergyRecords => [
        mariaDec2025,
        anaDec2025,
      ];

  /// Todas las ofertas P2P
  static List<P2POffer> get allOffers => [
        mariaOffer,
      ];

  /// Todos los contratos P2P
  static List<P2PContract> get allContracts => [
        contract1,
      ];

  /// Todas las asignaciones PDE
  static List<PDEAllocation> get allPDEAllocations => [
        pdeDec2025,
      ];

  /// Todos los registros de auditoría
  static List<RegulatoryAuditLog> get allAuditLogs => [
        auditSurplusClassification,
        auditPDEAllocation,
        auditOfferCreated,
        auditContractExecuted,
      ];

  // ============================================================================
  // MÉTODOS DE AYUDA
  // ============================================================================

  /// Obtiene un miembro por userId
  static CommunityMember? getMemberByUserId(int userId) {
    try {
      return allMembers.firstWhere((m) => m.userId == userId);
    } catch (e) {
      return null;
    }
  }

  /// Obtiene el registro de energía por userId y período
  static EnergyRecord? getEnergyRecord(int userId, String period) {
    try {
      return allEnergyRecords.firstWhere(
        (e) => e.userId == userId && e.period == period,
      );
    } catch (e) {
      return null;
    }
  }

  /// Obtiene ofertas disponibles para un período
  static List<P2POffer> getAvailableOffers(String period) {
    return allOffers
        .where((o) => o.period == period && o.isAvailable)
        .toList();
  }

  /// Obtiene contratos de un usuario (comprador o vendedor)
  static List<P2PContract> getUserContracts(int userId, String period) {
    return allContracts
        .where((c) =>
            (c.buyerId == userId || c.sellerId == userId) &&
            c.period == period)
        .toList();
  }

  /// Verifica si un precio está en rango VE para un período
  static bool isPriceInVERange(double price, String period) {
    if (period == '2025-12') {
      return veDecember2025.isPriceWithinRange(price);
    }
    return false;
  }
}
