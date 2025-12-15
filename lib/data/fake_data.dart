// Datos fake para MVP - Noviembre 2025
// Basado en la tesis de Cristian Hoyos y Esteban Viveros
// 15 usuarios: 10 consumidores (IDs 13-22) + 5 prosumidores (IDs 23-27)

import '../models/community_models.dart';
import '../models/energy_models.dart';
import '../models/p2p_models.dart';
import '../models/billing_models.dart';

class FakeData {
  // Comunidad única
  static final Community community = Community(
    id: 1,
    name: 'Comunidad UAO',
    description: 'Comunidad Energética Universidad Autónoma de Occidente',
    location: 'Cali, Valle del Cauca',
    createdAt: DateTime(2025, 10, 1),
  );

  // 15 miembros de la comunidad
  static final List<CommunityMember> members = [
    // CONSUMIDORES (IDs 13-22)
    CommunityMember(
      id: 1,
      communityId: 1,
      userId: 13,
      userName: 'Juan',
      userLastName: 'Pérez',
      role: 'consumer',
      installedCapacity: 0,
      pdeShare: 0,
    ),
    CommunityMember(
      id: 2,
      communityId: 1,
      userId: 14,
      userName: 'Ana',
      userLastName: 'García',
      role: 'consumer',
      installedCapacity: 0,
      pdeShare: 0,
    ),
    CommunityMember(
      id: 3,
      communityId: 1,
      userId: 15,
      userName: 'Carlos',
      userLastName: 'Rodríguez',
      role: 'consumer',
      installedCapacity: 0,
      pdeShare: 0,
    ),
    CommunityMember(
      id: 4,
      communityId: 1,
      userId: 16,
      userName: 'Laura',
      userLastName: 'Martínez',
      role: 'consumer',
      installedCapacity: 0,
      pdeShare: 0,
    ),
    CommunityMember(
      id: 5,
      communityId: 1,
      userId: 17,
      userName: 'Diego',
      userLastName: 'López',
      role: 'consumer',
      installedCapacity: 0,
      pdeShare: 0,
    ),
    CommunityMember(
      id: 6,
      communityId: 1,
      userId: 18,
      userName: 'Sofía',
      userLastName: 'Hernández',
      role: 'consumer',
      installedCapacity: 0,
      pdeShare: 0,
    ),
    CommunityMember(
      id: 7,
      communityId: 1,
      userId: 19,
      userName: 'Miguel',
      userLastName: 'González',
      role: 'consumer',
      installedCapacity: 0,
      pdeShare: 0,
    ),
    CommunityMember(
      id: 8,
      communityId: 1,
      userId: 20,
      userName: 'Valentina',
      userLastName: 'Díaz',
      role: 'consumer',
      installedCapacity: 0,
      pdeShare: 0,
    ),
    CommunityMember(
      id: 9,
      communityId: 1,
      userId: 21,
      userName: 'Andrés',
      userLastName: 'Torres',
      role: 'consumer',
      installedCapacity: 0,
      pdeShare: 0,
    ),
    CommunityMember(
      id: 10,
      communityId: 1,
      userId: 22,
      userName: 'Camila',
      userLastName: 'Ramírez',
      role: 'consumer',
      installedCapacity: 0,
      pdeShare: 0,
    ),
    // PROSUMIDORES (IDs 23-27)
    CommunityMember(
      id: 11,
      communityId: 1,
      userId: 23,
      userName: 'Roberto',
      userLastName: 'Silva',
      role: 'prosumer',
      installedCapacity: 60,
      pdeShare: 0.0,
    ),
    CommunityMember(
      id: 12,
      communityId: 1,
      userId: 24,
      userName: 'María',
      userLastName: 'García',
      role: 'prosumer',
      installedCapacity: 450,
      pdeShare: 0.417, // 41.7%
    ),
    CommunityMember(
      id: 13,
      communityId: 1,
      userId: 25,
      userName: 'Fernando',
      userLastName: 'Morales',
      role: 'prosumer',
      installedCapacity: 300,
      pdeShare: 0.20, // 20%
    ),
    CommunityMember(
      id: 14,
      communityId: 1,
      userId: 26,
      userName: 'Patricia',
      userLastName: 'Castro',
      role: 'prosumer',
      installedCapacity: 250,
      pdeShare: 0.133, // 13.3%
    ),
    CommunityMember(
      id: 15,
      communityId: 1,
      userId: 27,
      userName: 'Javier',
      userLastName: 'Mendoza',
      role: 'prosumer',
      installedCapacity: 350,
      pdeShare: 0.25, // 25%
    ),
  ];

  // Registros energéticos noviembre 2025
  static final List<EnergyRecord> energyRecords = [
    // Consumidores
    EnergyRecord(id: 1, userId: 13, userName: 'Juan Pérez', communityId: 1, energyGenerated: 0, energyConsumed: 170, energyExported: 0, energyImported: 170, period: '2025-11'),
    EnergyRecord(id: 2, userId: 14, userName: 'Ana García', communityId: 1, energyGenerated: 0, energyConsumed: 250, energyExported: 0, energyImported: 250, period: '2025-11'),
    EnergyRecord(id: 3, userId: 15, userName: 'Carlos Rodríguez', communityId: 1, energyGenerated: 0, energyConsumed: 270, energyExported: 0, energyImported: 270, period: '2025-11'),
    EnergyRecord(id: 4, userId: 16, userName: 'Laura Martínez', communityId: 1, energyGenerated: 0, energyConsumed: 220, energyExported: 0, energyImported: 220, period: '2025-11'),
    EnergyRecord(id: 5, userId: 17, userName: 'Diego López', communityId: 1, energyGenerated: 0, energyConsumed: 230, energyExported: 0, energyImported: 230, period: '2025-11'),
    EnergyRecord(id: 6, userId: 18, userName: 'Sofía Hernández', communityId: 1, energyGenerated: 0, energyConsumed: 60, energyExported: 0, energyImported: 60, period: '2025-11'),
    EnergyRecord(id: 7, userId: 19, userName: 'Miguel González', communityId: 1, energyGenerated: 0, energyConsumed: 240, energyExported: 0, energyImported: 240, period: '2025-11'),
    EnergyRecord(id: 8, userId: 20, userName: 'Valentina Díaz', communityId: 1, energyGenerated: 0, energyConsumed: 250, energyExported: 0, energyImported: 250, period: '2025-11'),
    EnergyRecord(id: 9, userId: 21, userName: 'Andrés Torres', communityId: 1, energyGenerated: 0, energyConsumed: 280, energyExported: 0, energyImported: 280, period: '2025-11'),
    EnergyRecord(id: 10, userId: 22, userName: 'Camila Ramírez', communityId: 1, energyGenerated: 0, energyConsumed: 300, energyExported: 0, energyImported: 300, period: '2025-11'),
    // Prosumidores
    EnergyRecord(id: 11, userId: 23, userName: 'Roberto Silva', communityId: 1, energyGenerated: 60, energyConsumed: 150, energyExported: 0, energyImported: 90, period: '2025-11'),
    EnergyRecord(id: 12, userId: 24, userName: 'María García', communityId: 1, energyGenerated: 450, energyConsumed: 200, energyExported: 250, energyImported: 0, period: '2025-11'),
    EnergyRecord(id: 13, userId: 25, userName: 'Fernando Morales', communityId: 1, energyGenerated: 300, energyConsumed: 180, energyExported: 120, energyImported: 0, period: '2025-11'),
    EnergyRecord(id: 14, userId: 26, userName: 'Patricia Castro', communityId: 1, energyGenerated: 250, energyConsumed: 170, energyExported: 80, energyImported: 0, period: '2025-11'),
    EnergyRecord(id: 15, userId: 27, userName: 'Javier Mendoza', communityId: 1, energyGenerated: 350, energyConsumed: 130, energyExported: 220, energyImported: 0, period: '2025-11'),
  ];

  // Asignación PDE (modelo homogéneo)
  static final List<PDEAllocation> pdeAllocations = [
    PDEAllocation(id: 1, userId: 24, userName: 'María García', communityId: 1, excessEnergy: 300, allocatedEnergy: 300, sharePercentage: 0.417, allocationPeriod: '2025-11'),
    PDEAllocation(id: 2, userId: 25, userName: 'Fernando Morales', communityId: 1, excessEnergy: 144, allocatedEnergy: 144, sharePercentage: 0.20, allocationPeriod: '2025-11'),
    PDEAllocation(id: 3, userId: 26, userName: 'Patricia Castro', communityId: 1, excessEnergy: 96, allocatedEnergy: 96, sharePercentage: 0.133, allocationPeriod: '2025-11'),
    PDEAllocation(id: 4, userId: 27, userName: 'Javier Mendoza', communityId: 1, excessEnergy: 180, allocatedEnergy: 180, sharePercentage: 0.25, allocationPeriod: '2025-11'),
  ];

  // Contratos P2P
  static final List<P2PContract> p2pContracts = [
    P2PContract(id: 1, sellerId: 24, sellerName: 'María García', buyerId: 13, buyerName: 'Juan Pérez', communityId: 1, energyCommitted: 150, agreedPrice: 500, status: 'active', createdAt: DateTime(2025, 11, 5)),
    P2PContract(id: 2, sellerId: 25, sellerName: 'Fernando Morales', buyerId: 14, buyerName: 'Ana García', communityId: 1, energyCommitted: 100, agreedPrice: 500, status: 'active', createdAt: DateTime(2025, 11, 8)),
    P2PContract(id: 3, sellerId: 26, sellerName: 'Patricia Castro', buyerId: 15, buyerName: 'Carlos Rodríguez', communityId: 1, energyCommitted: 80, agreedPrice: 500, status: 'active', createdAt: DateTime(2025, 11, 12)),
    P2PContract(id: 4, sellerId: 27, sellerName: 'Javier Mendoza', buyerId: 16, buyerName: 'Laura Martínez', communityId: 1, energyCommitted: 120, agreedPrice: 500, status: 'active', createdAt: DateTime(2025, 11, 15)),
    P2PContract(id: 5, sellerId: 24, sellerName: 'María García', buyerId: 17, buyerName: 'Diego López', communityId: 1, energyCommitted: 200, agreedPrice: 500, status: 'active', createdAt: DateTime(2025, 11, 20)),
  ];

  // Créditos energéticos
  static final List<EnergyCredit> energyCredits = [
    EnergyCredit(id: 1, userId: 24, userName: 'María García', balance: 75000, createdAt: DateTime(2025, 11, 1), updatedAt: DateTime(2025, 11, 30)),
    EnergyCredit(id: 2, userId: 25, userName: 'Fernando Morales', balance: 36000, createdAt: DateTime(2025, 11, 1), updatedAt: DateTime(2025, 11, 30)),
    EnergyCredit(id: 3, userId: 26, userName: 'Patricia Castro', balance: 24000, createdAt: DateTime(2025, 11, 1), updatedAt: DateTime(2025, 11, 30)),
    EnergyCredit(id: 4, userId: 27, userName: 'Javier Mendoza', balance: 66000, createdAt: DateTime(2025, 11, 1), updatedAt: DateTime(2025, 11, 30)),
  ];

  // Transacciones de créditos (historial fake)
  static final List<CreditTransaction> creditTransactions = [
    CreditTransaction(id: 1, userId: 24, userName: 'María García', amount: 75000, type: 'credit', description: 'Venta de excedentes P2P', transactionDate: DateTime(2025, 11, 25)),
    CreditTransaction(id: 2, userId: 25, userName: 'Fernando Morales', amount: 50000, type: 'credit', description: 'Venta de excedentes P2P', transactionDate: DateTime(2025, 11, 18)),
    CreditTransaction(id: 3, userId: 25, userName: 'Fernando Morales', amount: 14000, type: 'debit', description: 'Compra de energía red', transactionDate: DateTime(2025, 11, 20)),
    CreditTransaction(id: 4, userId: 26, userName: 'Patricia Castro', amount: 40000, type: 'credit', description: 'Venta de excedentes P2P', transactionDate: DateTime(2025, 11, 22)),
    CreditTransaction(id: 5, userId: 26, userName: 'Patricia Castro', amount: 16000, type: 'debit', description: 'Compra de energía red', transactionDate: DateTime(2025, 11, 23)),
    CreditTransaction(id: 6, userId: 27, userName: 'Javier Mendoza', amount: 60000, type: 'credit', description: 'Venta de excedentes P2P', transactionDate: DateTime(2025, 11, 28)),
    CreditTransaction(id: 7, userId: 13, userName: 'Juan Pérez', amount: 75000, type: 'debit', description: 'Compra energía P2P', transactionDate: DateTime(2025, 11, 5)),
    CreditTransaction(id: 8, userId: 14, userName: 'Ana García', amount: 50000, type: 'debit', description: 'Compra energía P2P', transactionDate: DateTime(2025, 11, 8)),
  ];

  // Costos regulados (fake pero consistentes con tesis)
  static final RegulatedCosts regulatedCosts = RegulatedCosts(
    cu: 150, // COP/kWh
    mc: 200, // COP/kWh
    pcn: 100, // COP/kWh
  );

  // Ranking de vendedores
  static final List<SellerRanking> sellerRankings = [
    SellerRanking(userId: 24, userName: 'María García', totalEnergySold: 350, totalRevenue: 175000, contractsCompleted: 2),
    SellerRanking(userId: 27, userName: 'Javier Mendoza', totalEnergySold: 120, totalRevenue: 60000, contractsCompleted: 1),
    SellerRanking(userId: 25, userName: 'Fernando Morales', totalEnergySold: 100, totalRevenue: 50000, contractsCompleted: 1),
    SellerRanking(userId: 26, userName: 'Patricia Castro', totalEnergySold: 80, totalRevenue: 40000, contractsCompleted: 1),
  ];

  // Estadísticas de la comunidad (Vista Administrador)
  static CommunityStats get communityStats {
    final totalGenerated = energyRecords.fold<double>(0, (sum, record) => sum + record.energyGenerated);
    final totalConsumed = energyRecords.fold<double>(0, (sum, record) => sum + record.energyConsumed);
    final totalExported = energyRecords.fold<double>(0, (sum, record) => sum + record.energyExported);
    final totalImported = energyRecords.fold<double>(0, (sum, record) => sum + record.energyImported);

    return CommunityStats(
      totalMembers: 15,
      totalProsumers: 5,
      totalConsumers: 10,
      totalInstalledCapacity: 1410, // Sum of prosumer capacities
      totalEnergyGenerated: totalGenerated,
      totalEnergyImported: totalImported,
      totalEnergyConsumed: totalConsumed,
      totalEnergyExported: totalExported,
      activeContracts: p2pContracts.where((c) => c.isActive).length,
    );
  }

  /// Estadísticas individuales de Cristian Hoyos para Noviembre 2025 (Vista Usuario)
  /// Datos de un solo prosumidor (peer individual)
  static CommunityStats get cristianIndividualStatsNov2025 {
    // Encontrar el registro de Cristian (userId: 24) en Noviembre
    final cristianRecord = energyRecords.firstWhere(
      (record) => record.userId == 24,
      orElse: () => energyRecords.first, // Usar el primero si no existe
    );

    return CommunityStats(
      totalMembers: 1, // Solo Cristian
      totalProsumers: 1, // Cristian es prosumidor
      totalConsumers: 0,
      totalInstalledCapacity: 288, // kW de capacidad instalada de Cristian
      totalEnergyGenerated: cristianRecord.energyGenerated,
      totalEnergyImported: cristianRecord.energyImported,
      totalEnergyConsumed: cristianRecord.energyConsumed,
      totalEnergyExported: cristianRecord.energyExported,
      activeContracts: p2pContracts.where((c) =>
        c.sellerId == 24 || c.buyerId == 24
      ).length, // Solo contratos de Cristian
    );
  }

  // Datos para gráficos - Generación solar por hora (promedio prosumidor típico)
  static final List<HourlyEnergyData> hourlyGeneration = [
    HourlyEnergyData(hour: 6, generation: 0, consumption: 0.5),
    HourlyEnergyData(hour: 7, generation: 0.3, consumption: 0.8),
    HourlyEnergyData(hour: 8, generation: 1.2, consumption: 1.0),
    HourlyEnergyData(hour: 9, generation: 2.0, consumption: 1.2),
    HourlyEnergyData(hour: 10, generation: 2.8, consumption: 1.5),
    HourlyEnergyData(hour: 11, generation: 3.2, consumption: 1.8),
    HourlyEnergyData(hour: 12, generation: 3.5, consumption: 2.0),
    HourlyEnergyData(hour: 13, generation: 3.3, consumption: 2.2),
    HourlyEnergyData(hour: 14, generation: 3.0, consumption: 2.0),
    HourlyEnergyData(hour: 15, generation: 2.5, consumption: 1.8),
    HourlyEnergyData(hour: 16, generation: 2.0, consumption: 1.5),
    HourlyEnergyData(hour: 17, generation: 1.8, consumption: 1.2),
    HourlyEnergyData(hour: 18, generation: 0.5, consumption: 1.0),
    HourlyEnergyData(hour: 19, generation: 0, consumption: 1.5),
    HourlyEnergyData(hour: 20, generation: 0, consumption: 1.2),
  ];

  // Datos para gráfico de importación/exportación diaria (diciembre 2025)
  static final List<DailyEnergyData> dailyEnergyData = List.generate(30, (index) {
    final day = index + 1;
    // Patrón realista de consumo/generación
    final imported = 60 + (day % 7) * 10 + (day % 3) * 5;
    final exported = 15 + (day % 5) * 8 + (day % 4) * 3;
    final demand = 80 + (day % 6) * 12;

    return DailyEnergyData(
      day: day,
      imported: imported.toDouble(),
      exported: exported.toDouble(),
      demand: demand.toDouble(),
    );
  });

  // Datos de facturación (Liquidación Mensual - Noviembre 2025)
  // Basado en costos regulados: CU=150, MC=200, PCN=100 COP/kWh (total=450)
  // P2P price: 500 COP/kWh
  static final List<UserBilling> userBillings = energyRecords.map((record) {
    final member = members.firstWhere((m) => m.userId == record.userId);
    final regulatedRate = regulatedCosts.totalCostPerKwh; // 450 COP/kWh
    final p2pRate = 500.0; // COP/kWh

    // Costo tradicional (todo de la red a tarifa regulada)
    final traditionalCost = record.energyConsumed * regulatedRate;

    // Escenario con créditos (autoconsumo + red regulada)
    final gridEnergy = member.isProsumer ? record.energyImported : record.energyConsumed;
    final creditsCost = gridEnergy * regulatedRate;

    // Escenario PDE (similar a créditos para simplificar)
    final pdeCost = creditsCost;

    // Escenario P2P (energía P2P a precio preferencial + red regulada)
    // Obtener contratos P2P del usuario
    final userP2PEnergy = p2pContracts
        .where((c) => c.buyerId == record.userId)
        .fold<double>(0, (sum, c) => sum + c.energyCommitted);
    final p2pCost = userP2PEnergy * p2pRate +
                    (record.energyConsumed - userP2PEnergy) * regulatedRate;

    return UserBilling(
      userId: record.userId,
      userName: record.userName,
      period: '2025-11',
      traditionalCost: traditionalCost,
      creditsScenarioCost: creditsCost,
      pdeScenarioCost: pdeCost,
      p2pScenarioCost: p2pCost,
      energyConsumed: record.energyConsumed,
      energyGenerated: record.energyGenerated,
    );
  }).toList();

  // Ahorro comunitario agregado
  static CommunitySavings get communitySavings {
    final totalTraditional = userBillings.fold<double>(0, (sum, b) => sum + b.traditionalCost);
    final totalCredits = userBillings.fold<double>(0, (sum, b) => sum + b.creditsScenarioCost);
    final totalPDE = userBillings.fold<double>(0, (sum, b) => sum + b.pdeScenarioCost);
    final totalP2P = userBillings.fold<double>(0, (sum, b) => sum + b.p2pScenarioCost);

    return CommunitySavings(
      period: '2025-11',
      totalTraditionalCost: totalTraditional,
      totalWithCredits: totalCredits,
      totalWithPDE: totalPDE,
      totalWithP2P: totalP2P,
    );
  }
}
