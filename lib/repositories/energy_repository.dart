// ignore_for_file: avoid_print

import '../core/api/api_client.dart';
import '../core/api/api_response.dart';
import '../core/api/api_exceptions.dart';
import '../core/constants/api_endpoints.dart';
import '../core/constants/microservice_config.dart';

/// Repositorio de energía - usa transaction_service para registros
/// Para saldo (kWh) usar CreditsRepository
class EnergyRepository {
  final ApiClient _apiClient = ApiClient.instance;

  /// Obtiene el historial de registros de energía del usuario
  /// Usa transaction_service POST /transactions/energy/query
  Future<ApiResponse<List<dynamic>>> getEnergyHistory({
    required int userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _apiClient.postFromService(
        Microservice.trading,
        ApiEndpoints.queryEnergyRecords,
        data: {
          'user_id': userId,
          'start': startDate.toIso8601String(),
          'end': endDate.toIso8601String(),
        },
      );
      final body = response.data as Map<String, dynamic>;
      final list = body['data'];
      if (list is List) {
        return ApiResponse.success(
          data: list,
          message: body['message'] ?? 'Historial obtenido',
        );
      }
      return ApiResponse.success(data: [], message: 'Sin historial');
    } on ApiException catch (e) {
      print('Error obteniendo historial de energía: ${e.message}');
      rethrow;
    }
  }
}
