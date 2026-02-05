/// FASE 2: Fake Data – Simulación administrativa
/// Período: 2026-01 (Enero 2026)
/// Comunidad energética de 2 usuarios: 1 Prosumidor + 1 Consumidor
///
/// Fuente: Caso de estudio de simulación administrativa
/// Los datos económicos se mantienen consistentes con los parámetros
/// del escenario (MC=300, CUV=800, Comercialización=70, P2P=400 COP/kWh)
library;

import '../models/community_models.dart';
import '../models/energy_models.dart';
import '../models/p2p_models.dart';
import '../models/p2p_offer.dart';
import '../models/regulatory_models.dart';

/// Clase que contiene todos los datos fake de la simulación (Enero 2026)
class FakeDataPhase2 {
  // ============================================================================
  // PARÁMETROS ECONÓMICOS DEL ESCENARIO
  // ============================================================================

  /// Precio unitario de bolsa (MC)
  static const double mc = 300.0; // COP/kWh

  /// Costo unitario de venta al usuario (CUV)
  static const double cuv = 800.0; // COP/kWh

  /// Costo de comercialización
  static const double costoComercializacion = 70.0; // COP/kWh

  /// Precio de transacción P2P del escenario
  static const double precioP2P = 400.0; // COP/kWh

  // ============================================================================
  // VE – VALOR DE ENERGÍA – ENERO 2026
  // ============================================================================

  /// VE para Enero 2026
  /// Rango permitido P2P consumidor: MC×1.1 a (CUV-Comercialización)×0.95
  /// = 330 a 693.5 COP/kWh
  static final VECalculation veDecember2025 = VECalculation.calculate(
    period: '2026-01',
    cuComponent: mc,                // 300 – se usa MC como base
    mcComponent: costoComercializacion, // 70
    pcnComponent: 0,
    source: 'manual',
  );

  // ============================================================================
  // USUARIOS – COMUNIDAD ENERGÉTICA
  // ============================================================================

  /// USUARIO 1 – PROSUMIDOR (l₁)
  /// Genera y consume energía; tiene excedentes disponibles para P2P
  static final CommunityMember mariaGarcia = CommunityMember(
    id: 1,
    communityId: 1,
    userId: 24,
    userName: 'María',
    userLastName: 'García',
    role: 'prosumer',
    installedCapacity: 288.0, // kW
    pdeShare: 0.10,
    isActive: true,
    niu: 'NIU-UAO-024-2026',
    documentType: 'CC',
    documentNumber: '1234567890',
    category: MemberCategory.prosumer,
    registrationDate: DateTime(2025, 1, 15),
  );

  /// USUARIO 2 – CONSUMIDOR (k₁)
  /// Solo consume energía; comprador en el mercado P2P
  static final CommunityMember cristianHoyos = CommunityMember(
    id: 2,
    communityId: 1,
    userId: 13,
    userName: 'Ana',
    userLastName: 'López',
    role: 'consumer',
    installedCapacity: 0.0,
    pdeShare: 0.0999, // 9.99% participación PDE
    isActive: true,
    niu: 'NIU-UAO-013-2026',
    documentType: 'CC',
    documentNumber: '9876543210',
    category: MemberCategory.consumer,
    registrationDate: DateTime(2025, 1, 15),
  );

  /// USUARIO 3 – ADMINISTRADOR
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
    niu: 'NIU-UAO-001-2026',
    documentType: 'NIT',
    documentNumber: '890000000-1',
    category: MemberCategory.consumer,
    registrationDate: DateTime(2025, 1, 1),
  );

  // ============================================================================
  // REGISTROS DE ENERGÍA – ENERO 2026
  // ============================================================================

  /// Prosumidor (l₁) – Enero 2026
  /// Importada: 107.7 kWh | Exportada: 520.2 kWh
  /// Excedentes totales disponibles para la comunidad: 412.5 kWh
  /// Excedentes Tipo 1 (por PDE): 107.7 kWh
  /// Excedentes Tipo 2 (por PDE): 4.12 kWh
  ///
  /// Generación estimada = Exportada + Importada = 520.2 + 107.7 = 627.9 kWh
  /// Consumo estimado   = Importada                            = 107.7 kWh
  static final EnergyRecord mariaDec2025 = EnergyRecord(
    id: 1,
    userId: 24,
    userName: 'María García',
    communityId: 1,
    energyGenerated: 627.9,  // kWh mes
    energyConsumed: 107.7,   // kWh mes (= importada)
    energyExported: 520.2,   // kWh mes
    energyImported: 107.7,   // kWh mes
    period: '2026-01',
    surplusType1: 107.7,     // Excedentes Tipo 1 por PDE
    surplusType2: 4.12,      // Excedentes Tipo 2 por PDE
    classification: SurplusClassificationType.mixed,
  );

  /// Consumidor (k₁) – Enero 2026
  /// Importada: 120 kWh | Exportada: 0 kWh
  /// Energía asignada por PDE: 41.21 kWh
  /// Excedentes Tipo 1 por PDE: 41.21 kWh | Tipo 2: 0
  static final EnergyRecord crisDec2025 = EnergyRecord(
    id: 2,
    userId: 13,
    userName: 'Ana López',
    communityId: 1,
    energyGenerated: 0.0,
    energyConsumed: 120.0,   // kWh mes
    energyExported: 0.0,
    energyImported: 120.0,   // Todo de la red / P2P / PDE
    period: '2026-01',
    surplusType1: 41.21,     // Excedentes Tipo 1 por PDE (energía asignada)
    surplusType2: 0.0,
    classification: SurplusClassificationType.none,
  );

  // ============================================================================
  // CLASIFICACIÓN DE EXCEDENTES
  // ============================================================================

  /// Clasificación de excedentes del prosumidor
  /// Total disponibles para comunidad: 412.5 kWh
  static final SurplusClassification mariaClassification = SurplusClassification(
    period: '2026-01',
    userId: 24,
    totalSurplus: 412.5,
    type1Surplus: 107.7,  // Tipo 1 por PDE
    type2Surplus: 4.12,   // Tipo 2 por PDE
    classifiedAt: DateTime(2026, 1, 1, 0, 0),
  );

  // ============================================================================
  // ASIGNACIÓN PDE – ENERO 2026
  // ============================================================================

  /// PDE asignado por el administrador
  /// Energía asignada al consumidor: 41.21 kWh
  /// Excedentes totales disponibles de la comunidad: 412.5 kWh
  ///
  /// NOTA: La validación del 100% de asignación se obvia por ahora
  /// (escenario básico de 2 usuarios para entender la simulación)
  static final PDEAllocation pdeDec2025 = PDEAllocation(
    id: 1,
    userId: 24,            // Prosumidor aporta
    userName: 'María García',
    communityId: 1,
    excessEnergy: 412.5,    // Excedentes totales disponibles
    allocatedEnergy: 41.21, // Energía asignada por PDE al consumidor
    sharePercentage: 0.0999, // 9.99% – dentro del límite regulatorio ≤10%
    allocationPeriod: '2026-01',
    surplusType2Only: 412.5,
    isPDECompliant: true,
    regulationArticle: 'CREG 101 072 Art 3.4',
    pdeAllocatedToConsumers: 41.21,
    consumerDistribution: {13: 41.21}, // k₁ recibe 41.21 kWh
  );

  // ============================================================================
  // OFERTAS P2P – PROSUMIDOR (VENDEDOR)
  // ============================================================================

  /// Oferta publicada por el prosumidor
  /// Precio de transacción P2P: $400 COP/kWh
  /// Energía disponible para venta: excedentes totales comunidad = 412.5 kWh
  static final P2POffer mariaOffer = P2POffer(
    id: 1,
    sellerId: 24,
    sellerName: 'María García',
    communityId: 1,
    period: '2026-01',
    energyAvailable: 412.5,
    energyRemaining: 412.5,
    pricePerKwh: precioP2P, // 400 COP/kWh
    status: OfferStatus.available,
    createdAt: DateTime(2026, 1, 10, 10, 0),
    validUntil: DateTime(2026, 1, 31, 23, 59),
  );

  /// Oferta después de la transacción P2P
  /// Ingreso P2P mensual del prosumidor: $163,352
  /// → energía vendida = 163352 / 400 = 408.38 kWh
  static P2POffer get mariaOfferAfterSale => mariaOffer.copyWith(
        energyRemaining: 412.5 - 408.38, // 4.12 kWh restantes
        status: OfferStatus.partial,
      );

  // ============================================================================
  // CONTRATOS P2P
  // ============================================================================

  /// Contrato P2P: Prosumidor vende al consumidor
  /// Precio: $400 COP/kWh
  /// Energía vendida: 408.38 kWh (= Ingreso $163,352 / $400)
  /// Valor total: $163,352
  static final P2PContract contract1 = P2PContract(
    id: 201,
    sellerId: 24,
    sellerName: 'María García',
    buyerId: 13,
    buyerName: 'Ana López',
    communityId: 1,
    energyCommitted: 408.38,  // kWh
    agreedPrice: precioP2P,   // 400 COP/kWh
    status: 'active',
    createdAt: DateTime(2026, 1, 15, 14, 30),
    period: '2026-01',
    calculatedVE: mc,         // MC = 300
    priceWithinVERange: true, // 400 dentro del rango permitido
    completedAt: null,
  );

  // ============================================================================
  // LIQUIDACIÓN MENSUAL – ENERO 2026
  // ============================================================================

  /// Liquidación del consumidor (k₁)
  ///
  /// Costo P2P mensual:        –$16,484
  /// VE mensual:               –$65,916
  /// Valor Final del mes (VF): –$82,400
  ///
  /// Comparativo:
  ///   Factura tradicional (sin CE): –$96,000
  ///   Ahorro al participar en CE:    $13,600
  static Map<String, dynamic> get anaLiquidation => {
        'userId': 13,
        'userName': 'Ana López',
        'period': '2026-01',
        'totalConsumption': 120.0,            // kWh

        // Detalle
        'pdeReceived': 41.21,                 // kWh asignados por PDE
        'p2pPurchased': 408.38,               // kWh comprados P2P (contrato)
        'gridPurchased': 120.0 - 41.21,       // kWh de la red = 78.79 kWh

        // Costos
        'p2pCost': 16484.0,                   // Costo P2P mensual
        'veMensual': 65916.0,                 // VE mensual
        'valorFinal': -82400.0,               // VF = –(P2P + VE)

        // Comparativo
        'facturaTradicionaSinCE': 96000.0,    // Sin comunidad
        'ahorroAlParticipar': 13600.0,        // Ahorro por estar en CE

        // Cumplimiento
        'isCompliant': true,
        'regulationArticle': 'CREG 101 072',
      };

  /// Liquidación del prosumidor (l₁)
  ///
  /// Ingreso P2P mensual:      +$163,352
  /// VE mensual:               –$6,303
  /// Valor Final del mes (VF): +$157,049
  ///
  /// Comparativo:
  ///   Ingreso fuera de CE (AGPE): $116,210
  ///   Ganancia adicional en CE:    $40,839
  static Map<String, dynamic> get mariaLiquidation => {
        'userId': 24,
        'userName': 'María García',
        'period': '2026-01',
        'totalGeneration': 627.9,             // kWh
        'totalConsumption': 107.7,            // kWh
        'totalSurplus': 412.5,                // Excedentes disponibles comunidad

        // Excedentes por PDE
        'surplusType1ByPDE': 107.7,
        'surplusType2ByPDE': 4.12,

        // Ingresos
        'ingresoP2P': 163352.0,               // Ingreso P2P mensual
        'veMensual': -6303.0,                 // VE mensual
        'valorFinal': 157049.0,               // VF = Ingreso P2P + VE

        // Comparativo
        'ingresoFueraCE_AGPE': 116210.0,      // Sin comunidad
        'gananciAdicionalEnCE': 40839.0,      // Ganancia extra por estar en CE

        // Cumplimiento
        'isCompliant': true,
        'regulationArticle': 'CREG 101 072',
      };

  // ============================================================================
  // AUDITORÍA REGULATORIA
  // ============================================================================

  static final RegulatoryAuditLog auditSurplusClassification = RegulatoryAuditLog(
    id: 1,
    userId: 24,
    actionType: AuditAction.surplusClassified,
    resourceType: 'SurplusClassification',
    resourceId: 1,
    data: {
      'totalSurplus': 412.5,
      'type1ByPDE': 107.7,
      'type2ByPDE': 4.12,
    },
    regulationArticle: 'CREG 101 072 Art 3.2',
    complianceStatus: ComplianceStatus.compliant,
    createdAt: DateTime(2026, 1, 1, 0, 0),
  );

  static final RegulatoryAuditLog auditPDEAllocation = RegulatoryAuditLog(
    id: 2,
    userId: 1, // Admin
    actionType: AuditAction.pdeAllocated,
    resourceType: 'PDEAllocation',
    resourceId: 1,
    data: {
      'allocatedEnergy': 41.21,
      'totalExcedentes': 412.5,
      'consumidor': 'Ana López (k₁)',
    },
    regulationArticle: 'CREG 101 072 Art 3.4',
    complianceStatus: ComplianceStatus.compliant,
    createdAt: DateTime(2026, 1, 5, 10, 0),
  );

  static final RegulatoryAuditLog auditOfferCreated = RegulatoryAuditLog(
    id: 3,
    userId: 24,
    actionType: AuditAction.offerCreated,
    resourceType: 'P2POffer',
    resourceId: 1,
    data: {
      'energyKwh': 412.5,
      'pricePerKwh': precioP2P,
      'mc': mc,
    },
    regulationArticle: 'CREG 101 072 Art 4.2',
    complianceStatus: ComplianceStatus.compliant,
    createdAt: DateTime(2026, 1, 10, 10, 0),
  );

  static final RegulatoryAuditLog auditContractExecuted = RegulatoryAuditLog(
    id: 4,
    userId: 13,
    actionType: AuditAction.contractExecuted,
    resourceType: 'P2PContract',
    resourceId: 201,
    data: {
      'seller': 'María García',
      'buyer': 'Ana López',
      'energyKwh': 408.38,
      'price': precioP2P,
      'totalValue': 163352.0,
    },
    regulationArticle: 'CREG 101 072 Art 4.3',
    complianceStatus: ComplianceStatus.compliant,
    createdAt: DateTime(2026, 1, 15, 14, 30),
  );

  // ============================================================================
  // ESTADÍSTICAS DE COMUNIDAD – ENERO 2026
  // ============================================================================

  /// Estadísticas agregadas (Vista Administrador)
  /// Comunidad: 1 prosumidor + 1 consumidor = 2 miembros activos
  static CommunityStats get communityStats {
    return CommunityStats(
      totalMembers: 2,
      totalProsumers: 1,
      totalConsumers: 1,
      totalInstalledCapacity: 288.0,
      totalEnergyGenerated: 627.9,            // Solo el prosumidor genera
      totalEnergyImported: 107.7 + 120.0,     // Prosumidor + Consumidor = 227.7
      totalEnergyConsumed: 107.7 + 120.0,     // 227.7 kWh
      totalEnergyExported: 520.2,             // Solo el prosumidor exporta
      activeContracts: 1,
    );
  }

  /// Estadísticas individuales del prosumidor (Vista Usuario – l₁)
  static CommunityStats get cristianIndividualStatsDec2025 {
    return CommunityStats(
      totalMembers: 1,
      totalProsumers: 1,
      totalConsumers: 0,
      totalInstalledCapacity: 288.0,
      totalEnergyGenerated: 627.9,
      totalEnergyImported: 107.7,
      totalEnergyConsumed: 107.7,
      totalEnergyExported: 520.2,
      activeContracts: 1,
    );
  }

  // ============================================================================
  // LISTAS CONSOLIDADAS
  // ============================================================================

  static List<CommunityMember> get allMembers => [mariaGarcia, cristianHoyos];

  static List<EnergyRecord> get allEnergyRecords => [mariaDec2025, crisDec2025];

  static List<P2POffer> get allOffers => [mariaOffer];

  static List<P2PContract> get allContracts => [contract1];

  static List<PDEAllocation> get allPDEAllocations => [pdeDec2025];

  static List<RegulatoryAuditLog> get allAuditLogs => [
        auditSurplusClassification,
        auditPDEAllocation,
        auditOfferCreated,
        auditContractExecuted,
      ];

  // ============================================================================
  // MÉTODOS DE AYUDA
  // ============================================================================

  static CommunityMember? getMemberByUserId(int userId) {
    try {
      return allMembers.firstWhere((m) => m.userId == userId);
    } catch (e) {
      return null;
    }
  }

  static EnergyRecord? getEnergyRecord(int userId, String period) {
    try {
      return allEnergyRecords.firstWhere(
        (e) => e.userId == userId && e.period == period,
      );
    } catch (e) {
      return null;
    }
  }

  static List<P2POffer> getAvailableOffers(String period) {
    return allOffers
        .where((o) => o.period == period && o.isAvailable)
        .toList();
  }

  static List<P2PContract> getUserContracts(int userId, String period) {
    return allContracts
        .where((c) =>
            (c.buyerId == userId || c.sellerId == userId) &&
            c.period == period)
        .toList();
  }

  static bool isPriceInVERange(double price, String period) {
    if (period == '2026-01') {
      // Rango consumidor: MC×1.1 a (CUV-Comercialización)×0.95 = 330 a 693.5
      return price >= 330.0 && price <= 693.5;
    }
    return false;
  }
}
