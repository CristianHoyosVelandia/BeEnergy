// ignore_for_file: avoid_print

import '../core/api/api_client.dart';
import '../core/api/api_response.dart';
import '../core/api/api_exceptions.dart';
import '../core/constants/api_endpoints.dart';

/// Repositorio de ejemplo para manejar operaciones relacionadas con energía
/// Este es un patrón de diseño que separa la lógica de acceso a datos
class EnergyRepository {
  final ApiClient _apiClient = ApiClient.instance;

  /// Obtiene los datos de energía del usuario
  ///
  /// Retorna un [ApiResponse] con los datos de energía o un error
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// final repository = EnergyRepository();
  /// try {
  ///   final response = await repository.getEnergyData();
  ///   if (response.success) {
  ///     print('Datos de energía: ${response.data}');
  ///   }
  /// } on ApiException catch (e) {
  ///   print('Error: ${e.message}');
  /// }
  /// ```
  Future<ApiResponse<Map<String, dynamic>>> getEnergyData() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.energyData);

      return ApiResponse.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );
    } on ApiException catch (e) {
      print('Error obteniendo datos de energía: ${e.message}');
      rethrow;
    }
  }

  /// Obtiene el historial de energía del usuario
  ///
  /// [startDate] - Fecha de inicio (opcional)
  /// [endDate] - Fecha de fin (opcional)
  ///
  /// Retorna un [ApiResponse] con la lista del historial
  Future<ApiResponse<List<dynamic>>> getEnergyHistory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }

      final response = await _apiClient.get(
        ApiEndpoints.energyHistory,
        queryParameters: queryParams,
      );

      return ApiResponse.fromJsonList(
        response.data,
        (data) => data,
      );
    } on ApiException catch (e) {
      print('Error obteniendo historial de energía: ${e.message}');
      rethrow;
    }
  }

  /// Obtiene las estadísticas de energía del usuario
  ///
  /// [period] - Período de estadísticas ('day', 'week', 'month', 'year')
  ///
  /// Retorna un [ApiResponse] con las estadísticas
  Future<ApiResponse<Map<String, dynamic>>> getEnergyStats({
    String period = 'month',
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.energyStats,
        queryParameters: {'period': period},
      );

      return ApiResponse.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );
    } on ApiException catch (e) {
      print('Error obteniendo estadísticas de energía: ${e.message}');
      rethrow;
    }
  }
}
