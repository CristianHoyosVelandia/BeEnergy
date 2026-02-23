// ignore_for_file: avoid_print

import '../core/api/api_client.dart';
import '../core/api/api_response.dart';
import '../core/api/api_exceptions.dart';
import '../core/constants/api_endpoints.dart';
import '../core/constants/microservice_config.dart';

/// Repositorio de créditos energéticos (saldo en kWh)
class CreditsRepository {
  final ApiClient _apiClient = ApiClient.instance;

  /// Consulta de saldo energético del usuario
  Future<ApiResponse<Map<String, dynamic>>> getBalance(int userId) async {
    try {
      final response = await _apiClient.getFromService(
        Microservice.credits,
        ApiEndpoints.creditsBalance(userId),
      );

      final body = response.data as Map<String, dynamic>;
      final data = body['data'] ?? body;
      return ApiResponse.fromJson(
        body,
        (_) => data is Map<String, dynamic> ? data : {'user_id': userId, 'balance': data ?? 0.0},
      );
    } on ApiException catch (e) {
      print('Error obteniendo saldo: ${e.message}');
      rethrow;
    }
  }
}
