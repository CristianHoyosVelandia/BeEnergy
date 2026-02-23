// ignore_for_file: avoid_print

import '../core/api/api_client.dart';
import '../core/api/api_response.dart';
import '../core/api/api_exceptions.dart';
import '../core/constants/api_endpoints.dart';
import '../core/constants/microservice_config.dart';

/// Repositorio de monitoreo (telemetría y alertas)
class MonitoringRepository {
  final ApiClient _apiClient = ApiClient.instance;

  /// Última medición (requiere auth de dispositivo)
  Future<ApiResponse<Map<String, dynamic>>> getLatestMeasurement({
    required String deviceId,
    required String deviceToken,
  }) async {
    try {
      final response = await _apiClient.get(
        MicroserviceConfig.buildUrl(Microservice.monitoring, ApiEndpoints.telemetryLatest),
        headers: {
          'X-Device-ID': deviceId,
          'Authorization': 'Device $deviceToken',
        },
      );
      final data = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(
        data is Map ? data : {'data': data},
        (d) => d as Map<String, dynamic>,
      );
    } on ApiException catch (e) {
      print('Error obteniendo última medición: ${e.message}');
      rethrow;
    }
  }

  /// Histórico de mediciones
  Future<ApiResponse<List<dynamic>>> getMeasurementHistory({
    required String deviceId,
    required String deviceToken,
    int limit = 100,
  }) async {
    try {
      final response = await _apiClient.get(
        MicroserviceConfig.buildUrl(Microservice.monitoring, ApiEndpoints.telemetryHistory),
        queryParameters: {'limit': limit},
        headers: {
          'X-Device-ID': deviceId,
          'Authorization': 'Device $deviceToken',
        },
      );
      final data = response.data;
      if (data is List) {
        return ApiResponse.success(data: data, message: 'Historial obtenido');
      }
      return ApiResponse.success(data: [], message: 'Sin datos');
    } on ApiException catch (e) {
      print('Error obteniendo historial: ${e.message}');
      rethrow;
    }
  }

  /// Listar reglas de alerta del usuario
  Future<ApiResponse<List<dynamic>>> getAlertRules({
    int? ownerUserId,
    String? deviceId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (ownerUserId != null) queryParams['owner_user_id'] = ownerUserId;
      if (deviceId != null) queryParams['device_id'] = deviceId;
      final url = MicroserviceConfig.buildUrl(Microservice.monitoring, ApiEndpoints.alertRules);
      final response = await _apiClient.get(url, queryParameters: queryParams.isEmpty ? null : queryParams);
      final data = response.data;
      if (data is List) {
        return ApiResponse.success(data: data, message: 'Reglas obtenidas');
      }
      return ApiResponse.success(data: [], message: 'Sin reglas');
    } on ApiException catch (e) {
      print('Error listando reglas de alerta: ${e.message}');
      rethrow;
    }
  }

  /// Listar alertas (histórico por rango de fechas)
  Future<ApiResponse<List<dynamic>>> getAlerts({
    int? ownerUserId,
    String? deviceId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (ownerUserId != null) queryParams['owner_user_id'] = ownerUserId;
      if (deviceId != null) queryParams['device_id'] = deviceId;
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
      final url = MicroserviceConfig.buildUrl(Microservice.monitoring, ApiEndpoints.alerts);
      final response = await _apiClient.get(url, queryParameters: queryParams.isEmpty ? null : queryParams);
      final data = response.data;
      if (data is List) {
        return ApiResponse.success(data: data, message: 'Alertas obtenidas');
      }
      return ApiResponse.success(data: [], message: 'Sin alertas');
    } on ApiException catch (e) {
      print('Error listando alertas: ${e.message}');
      rethrow;
    }
  }

  /// Crear regla de alerta (umbral)
  Future<ApiResponse<Map<String, dynamic>>> createAlertRule({
    required int ownerUserId,
    required String deviceId,
    required String metric,
    required String operator,
    required double threshold,
    int windowSeconds = 0,
    String severity = 'medium',
  }) async {
    try {
      final url = MicroserviceConfig.buildUrl(Microservice.monitoring, ApiEndpoints.createAlertRule);
      final response = await _apiClient.post(
        url,
        data: {
          'owner_user_id': ownerUserId,
          'device_id': deviceId,
          'metric': metric,
          'operator': operator,
          'threshold': threshold,
          'window_seconds': windowSeconds,
          'severity': severity,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(
        data is Map ? data : {'data': data},
        (d) => d as Map<String, dynamic>,
      );
    } on ApiException catch (e) {
      print('Error creando regla de alerta: ${e.message}');
      rethrow;
    }
  }
}
