/// Motor de Liquidación Mensual
///
/// Calcula la facturación mensual de cada usuario considerando:
/// - PDE recibido (gratis)
/// - Compras P2P (precio acordado)
/// - Compras de la red (VE)
/// - Ventas P2P (ingresos)
/// - Ahorro vs tarifa tradicional
library;

import '../models/energy_models.dart';
import '../models/p2p_models.dart';
import '../models/regulatory_models.dart';

class SettlementEngine {
  /// Resultado de liquidación para un usuario
  static const double traditionalTariff = 500.0; // COP/kWh (tarifa regulada)

  /// Calcula la liquidación completa para un usuario en un período
  ///
  /// [userId]: ID del usuario
  /// [period]: Período 'YYYY-MM'
  /// [energyRecord]: Registro de energía del usuario
  /// [p2pContracts]: Contratos P2P del período (compras y ventas)
  /// [pdeAllocation]: Asignación PDE (si aplica)
  /// [ve]: Valor de energía del período
  ///
  /// Retorna un mapa con la liquidación detallada
  Map<String, dynamic> calculateUserSettlement({
    required int userId,
    required String period,
    required EnergyRecord energyRecord,
    required List<P2PContract> p2pContracts,
    PDEAllocation? pdeAllocation,
    required VECalculation ve,
  }) {
    // Separar contratos de compra y venta
    final purchases = p2pContracts.where((c) => c.buyerId == userId).toList();
    final sales = p2pContracts.where((c) => c.sellerId == userId).toList();

    // ========================================================================
    // CONSUMIDOR
    // ========================================================================

    if (energyRecord.energyGenerated == 0) {
      return _calculateConsumerSettlement(
        userId: userId,
        period: period,
        energyRecord: energyRecord,
        purchases: purchases,
        pdeReceived: pdeAllocation?.allocatedEnergy ?? 0.0,
        ve: ve,
      );
    }

    // ========================================================================
    // PROSUMIDOR
    // ========================================================================

    return _calculateProsumerSettlement(
      userId: userId,
      period: period,
      energyRecord: energyRecord,
      purchases: purchases,
      sales: sales,
      pdeContributed: pdeAllocation?.allocatedEnergy ?? 0.0,
      ve: ve,
    );
  }

  /// Calcula liquidación para consumidor puro (sin generación)
  Map<String, dynamic> _calculateConsumerSettlement({
    required int userId,
    required String period,
    required EnergyRecord energyRecord,
    required List<P2PContract> purchases,
    required double pdeReceived,
    required VECalculation ve,
  }) {
    final totalConsumption = energyRecord.energyConsumed;

    // Energía comprada P2P
    final p2pEnergy = purchases.fold(
      0.0,
      (sum, contract) => sum + contract.energyCommitted,
    );

    // Costo P2P
    final p2pCost = purchases.fold(
      0.0,
      (sum, contract) => sum + contract.totalValue,
    );

    // PDE recibido (gratis)
    final pdeCost = 0.0;

    // Energía de la red pública
    final gridEnergy = totalConsumption - p2pEnergy - pdeReceived;
    final gridCost = gridEnergy * ve.totalVE;

    // Total escenario P2P
    final totalCostP2P = p2pCost + gridCost + pdeCost;

    // Escenario tradicional (todo de la red a tarifa regulada)
    final traditionalCost = totalConsumption * traditionalTariff;

    // Ahorro
    final savings = traditionalCost - totalCostP2P;
    final savingsPercentage = traditionalCost > 0
        ? (savings / traditionalCost) * 100
        : 0.0;

    return {
      // Identificación
      'userId': userId,
      'userName': energyRecord.userName,
      'period': period,
      'userType': 'consumer',

      // Consumo total
      'totalConsumption': totalConsumption, // kWh

      // Desglose de compras
      'pdeReceived': pdeReceived, // kWh gratis
      'p2pPurchased': p2pEnergy, // kWh @ precio P2P
      'gridPurchased': gridEnergy, // kWh @ VE

      // Costos
      'pdeCost': pdeCost, // COP (siempre 0)
      'p2pCost': p2pCost, // COP
      'gridCost': gridCost, // COP
      'totalCostP2P': totalCostP2P, // COP

      // Comparación
      'traditionalCost': traditionalCost, // COP
      'savings': savings, // COP
      'savingsPercentage': savingsPercentage, // %

      // Detalles de contratos
      'p2pContracts': purchases.length,
      'p2pContractsDetails': purchases.map((c) => {
        'contractId': c.id,
        'seller': c.sellerName,
        'energy': c.energyCommitted,
        'price': c.agreedPrice,
        'total': c.totalValue,
      }).toList(),

      // Cumplimiento
      'isCompliant': true,
      'regulationArticle': 'CREG 101 072',
    };
  }

  /// Calcula liquidación para prosumidor (genera y consume)
  Map<String, dynamic> _calculateProsumerSettlement({
    required int userId,
    required String period,
    required EnergyRecord energyRecord,
    required List<P2PContract> purchases,
    required List<P2PContract> sales,
    required double pdeContributed,
    required VECalculation ve,
  }) {
    final totalGeneration = energyRecord.energyGenerated;
    final selfConsumption = energyRecord.energyConsumed;
    final totalSurplus = totalGeneration - selfConsumption;

    // Clasificación de excedentes
    final type1Surplus = energyRecord.surplusType1;
    final type2Surplus = energyRecord.surplusType2;

    // Energía vendida P2P
    final p2pSold = sales.fold(
      0.0,
      (sum, contract) => sum + contract.energyCommitted,
    );

    // Ingreso por ventas P2P
    final p2pRevenue = sales.fold(
      0.0,
      (sum, contract) => sum + contract.totalValue,
    );

    // Tipo 2 restante sin vender
    final type2Remaining = type2Surplus - pdeContributed - p2pSold;

    // Ahorro por autoconsumo (no tuvo que comprar de la red)
    final selfConsumptionSavings = selfConsumption * traditionalTariff;

    // Si el prosumidor también compra (raro, pero posible)
    final p2pPurchased = purchases.fold(
      0.0,
      (sum, contract) => sum + contract.energyCommitted,
    );

    final p2pCost = purchases.fold(
      0.0,
      (sum, contract) => sum + contract.totalValue,
    );

    // Balance neto (ingresos - gastos)
    final netBalance = p2pRevenue - p2pCost;

    return {
      // Identificación
      'userId': userId,
      'userName': energyRecord.userName,
      'period': period,
      'userType': 'prosumer',

      // Generación y consumo
      'totalGeneration': totalGeneration, // kWh
      'selfConsumption': selfConsumption, // kWh
      'totalSurplus': totalSurplus, // kWh

      // Clasificación excedentes
      'type1Surplus': type1Surplus, // kWh - NO vendible
      'type2Surplus': type2Surplus, // kWh - Vendible

      // Distribución Tipo 2
      'pdeContributed': pdeContributed, // kWh @ 0 (solidaridad)
      'p2pSold': p2pSold, // kWh @ precio P2P
      'type2Remaining': type2Remaining, // kWh sin vender

      // Ingresos
      'p2pRevenue': p2pRevenue, // COP
      'selfConsumptionSavings': selfConsumptionSavings, // COP ahorrados

      // Gastos (si compró algo)
      'p2pPurchased': p2pPurchased, // kWh
      'p2pCost': p2pCost, // COP

      // Balance
      'netBalance': netBalance, // COP (ingresos - gastos)

      // Detalles de contratos
      'salesContracts': sales.length,
      'salesContractsDetails': sales.map((c) => {
        'contractId': c.id,
        'buyer': c.buyerName,
        'energy': c.energyCommitted,
        'price': c.agreedPrice,
        'total': c.totalValue,
      }).toList(),

      'purchaseContracts': purchases.length,
      'purchaseContractsDetails': purchases.map((c) => {
        'contractId': c.id,
        'seller': c.sellerName,
        'energy': c.energyCommitted,
        'price': c.agreedPrice,
        'total': c.totalValue,
      }).toList(),

      // Cumplimiento
      'isCompliant': true,
      'pdeCompliant': pdeContributed <= (type2Surplus * 0.10),
      'regulationArticle': 'CREG 101 072',
    };
  }

  /// Calcula liquidación de toda la comunidad para un período
  ///
  /// Retorna estadísticas agregadas y liquidaciones individuales
  Map<String, dynamic> calculateCommunitySettlement({
    required String period,
    required List<EnergyRecord> energyRecords,
    required List<P2PContract> p2pContracts,
    required List<PDEAllocation> pdeAllocations,
    required VECalculation ve,
  }) {
    final userSettlements = <Map<String, dynamic>>[];

    double totalSavings = 0.0;
    double totalP2PRevenue = 0.0;
    double totalP2PEnergy = 0.0;

    // Calcular liquidación de cada usuario
    for (final record in energyRecords) {
      final userContracts = p2pContracts
          .where((c) => c.buyerId == record.userId || c.sellerId == record.userId)
          .toList();

      final userPDE = pdeAllocations.firstWhere(
        (pde) => pde.userId == record.userId,
        orElse: () => PDEAllocation(
          id: 0,
          userId: record.userId,
          userName: record.userName,
          communityId: record.communityId,
          excessEnergy: 0,
          allocatedEnergy: 0,
          sharePercentage: 0,
          allocationPeriod: period,
        ),
      );

      final settlement = calculateUserSettlement(
        userId: record.userId,
        period: period,
        energyRecord: record,
        p2pContracts: userContracts,
        pdeAllocation: userPDE,
        ve: ve,
      );

      userSettlements.add(settlement);

      // Acumular estadísticas
      if (settlement['userType'] == 'consumer') {
        totalSavings += settlement['savings'] as double;
      } else {
        totalP2PRevenue += settlement['p2pRevenue'] as double;
      }

      totalP2PEnergy += (settlement['p2pSold'] ?? 0.0) as double;
    }

    // Estadísticas de comunidad
    final totalContracts = p2pContracts.length;
    final totalPDE = pdeAllocations.fold(
      0.0,
      (sum, pde) => sum + pde.allocatedEnergy,
    );

    return {
      'period': period,
      'totalUsers': energyRecords.length,
      'totalContracts': totalContracts,
      'totalP2PEnergy': totalP2PEnergy, // kWh
      'totalP2PRevenue': totalP2PRevenue, // COP
      'totalPDE': totalPDE, // kWh
      'totalSavings': totalSavings, // COP
      'averageSavings': energyRecords.isNotEmpty
          ? totalSavings / energyRecords.length
          : 0.0,
      'userSettlements': userSettlements,
      'generatedAt': DateTime.now().toIso8601String(),
      'regulationArticle': 'CREG 101 072',
    };
  }

  /// Genera un resumen de liquidación para exportar
  Map<String, dynamic> generateSettlementSummary({
    required String period,
    required List<Map<String, dynamic>> userSettlements,
  }) {
    final consumers = userSettlements
        .where((s) => s['userType'] == 'consumer')
        .toList();

    final prosumers = userSettlements
        .where((s) => s['userType'] == 'prosumer')
        .toList();

    final totalSavings = userSettlements.fold(
      0.0,
      (sum, s) => sum + ((s['savings'] ?? 0.0) as double),
    );

    final totalRevenue = userSettlements.fold(
      0.0,
      (sum, s) => sum + ((s['p2pRevenue'] ?? 0.0) as double),
    );

    return {
      'period': period,
      'summary': {
        'totalUsers': userSettlements.length,
        'consumers': consumers.length,
        'prosumers': prosumers.length,
        'totalSavings': totalSavings,
        'totalRevenue': totalRevenue,
        'averageSavingsPerUser': userSettlements.isNotEmpty
            ? totalSavings / userSettlements.length
            : 0.0,
      },
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }
}
