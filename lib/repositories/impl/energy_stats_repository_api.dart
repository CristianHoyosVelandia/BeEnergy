/// Implementación API del repositorio de estadísticas de energía
/// Consume endpoints reales del backend
library;

import 'package:be_energy/core/api/api_client.dart';
import 'package:be_energy/core/constants/api_endpoints.dart';
import 'package:be_energy/models/home_data_models.dart';
import 'package:be_energy/repositories/domain/energy_stats_repository.dart';

/// Implementación con API real para estadísticas de energía
class EnergyStatsRepositoryApi implements EnergyStatsRepository {
  final ApiClient _client = ApiClient.instance;

  @override
  Future<EnergyStatistics> getStatistics({
    required String period,
    required ViewType viewType,
    required int userId,
  }) async {
    try {
      final response = await _client.get(
        ApiEndpoints.energyStats,
        queryParameters: {
          'period': period,
          'view_type': viewType.name,
          'user_id': userId,
        },
      );

      return EnergyStatistics.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ChartDataPoint>> getChartData({
    required String period,
    required ViewType viewType,
    required int userId,
  }) async {
    try {
      // Obtener las estadísticas completas y extraer chart data
      final stats = await getStatistics(
        period: period,
        viewType: viewType,
        userId: userId,
      );

      return stats.chartData;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PDEInfo?> getPDEInfo({required String period}) async {
    try {
      final response = await _client.get(
        '${ApiEndpoints.pdeAllocations}/info',
        queryParameters: {
          'period': period,
        },
      );

      if (response.data == null) {
        return null;
      }

      return PDEInfo.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      // Si no hay PDE disponible, retornar null
      return null;
    }
  }

  @override
  Future<List<PriceReference>?> getPriceReferences({
    required String period,
  }) async {
    try {
      final response = await _client.get(
        '${ApiEndpoints.energyData}/price-references',
        queryParameters: {
          'period': period,
        },
      );

      if (response.data == null) {
        return null;
      }

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => PriceReference.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Si no hay referencias disponibles, retornar null
      return null;
    }
  }
}
