/// Implementación fake del repositorio de estadísticas de energía
library;

import 'package:be_energy/data/fake_data.dart';
import 'package:be_energy/data/fake_data_phase2.dart';
import 'package:be_energy/data/fake_data_january_2026.dart';
import 'package:be_energy/models/home_data_models.dart';
import 'package:be_energy/repositories/domain/energy_stats_repository.dart';

/// Implementación con fake data para estadísticas de energía
class EnergyStatsRepositoryFake implements EnergyStatsRepository {
  @override
  Future<EnergyStatistics> getStatistics({
    required String period,
    required ViewType viewType,
    required int userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    late dynamic stats;
    late int p2pEnergy;
    double? gridImportOverride;
    double? solarAutoconsumption;
    double? totalSurplus;

    switch (period) {
      case '2026-01': // Enero 2026
        stats = viewType == ViewType.admin
            ? FakeDataPhase2.communityStats
            : FakeDataPhase2.cristianIndividualStatsDec2025;

        // P2P: energía del contrato activo
        p2pEnergy = FakeDataPhase2.allContracts
            .fold<double>(0, (sum, c) => sum + c.energyCommitted)
            .toInt();

        // Prosumidor no importa de red (su 107.7 es autoconsumo solar)
        // Admin: solo el consumidor importa 120 kWh de red
        if (viewType == ViewType.admin) {
          gridImportOverride = 120.0;
        } else {
          gridImportOverride = 0.0;
          solarAutoconsumption = 107.7;
        }

        // Excedentes totales
        totalSurplus = FakeDataPhase2.pdeDec2025.excessEnergy;
        break;

      case '2025-12': // Diciembre 2025
        stats = viewType == ViewType.admin
            ? FakeData.communityStats
            : FakeData.cristianIndividualStatsNov2025;

        p2pEnergy = viewType == ViewType.admin ? 650 : 30;
        break;

      default: // Históricos anteriores
        stats = viewType == ViewType.admin
            ? FakeData.communityStats
            : FakeData.cristianIndividualStatsNov2025;

        p2pEnergy = viewType == ViewType.admin ? 650 : 30;
    }

    final costPerKwh = period == '2026-01'
        ? FakeDataPhase2.mc
        : FakeData.regulatedCosts.totalCostPerKwh;

    return EnergyStatistics(
      solarDirect: stats.totalEnergyGenerated.toDouble(),
      gridImport: gridImportOverride ?? stats.totalEnergyImported.toDouble(),
      p2pExchanges: p2pEnergy.toDouble(),
      totalImported: period == '2026-01'
          ? (viewType == ViewType.admin ? 120.0 : 107.7)
          : stats.totalEnergyImported.toDouble(),
      totalExported: stats.totalEnergyExported.toDouble(),
      costPerKwh: costPerKwh,
      solarAutoconsumption: solarAutoconsumption,
      totalSurplus: totalSurplus,
    );
  }

  @override
  Future<List<ChartDataPoint>> getChartData({
    required String period,
    required ViewType viewType,
    required int userId,
  }) async {
    final stats = await getStatistics(
      period: period,
      viewType: viewType,
      userId: userId,
    );

    return stats.chartData;
  }

  @override
  Future<PDEInfo?> getPDEInfo({required String period}) async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (period != '2026-01') {
      return null;
    }

    final minValue =
        FakeDataJanuary2026.pdeConstantsJan2026.mcmValorEnergiaPromedio * 1.1;
    final maxValue = (FakeDataJanuary2026.pdeConstantsJan2026.costoEnergia -
            FakeDataJanuary2026.pdeConstantsJan2026.costoComercializacion) *
        0.95;

    return PDEInfo(
      totalAvailable: FakeDataPhase2.pdeDec2025.excessEnergy,
      minPrice: minValue,
      maxPrice: maxValue,
      prosumerName:
          '${FakeDataPhase2.mariaGarcia.userName} ${FakeDataPhase2.mariaGarcia.userLastName}',
    );
  }

  @override
  Future<List<PriceReference>?> getPriceReferences({required String period}) async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (period != '2026-01') {
      return null;
    }

    return [
      PriceReference(
        label: 'Precio unitario de bolsa (MC)',
        value: FakeDataPhase2.mc,
      ),
      PriceReference(
        label: 'Costo unitario de venta (CUV)',
        value: FakeDataPhase2.cuv,
      ),
      PriceReference(
        label: 'Costo de comercialización',
        value: FakeDataPhase2.costoComercializacion,
      ),
      PriceReference(
        label: 'Precio de transacción P2P',
        value: FakeDataPhase2.precioP2P,
      ),
    ];
  }
}
