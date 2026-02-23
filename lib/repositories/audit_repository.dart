// ignore_for_file: avoid_print

import '../core/api/api_client.dart';
import '../core/api/api_response.dart';
import '../core/api/api_exceptions.dart';
import '../core/constants/api_endpoints.dart';
import '../core/constants/microservice_config.dart';

/// Repositorio de auditoría (consulta logs, reportes)
class AuditRepository {
  final ApiClient _apiClient = ApiClient.instance;

  /// Consulta de registros de auditoría
  Future<ApiResponse<Map<String, dynamic>>> queryLogs({
    int? userId,
    String? transactionId,
    DateTime? startDate,
    DateTime? endDate,
    String? action,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (userId != null) queryParams['user_id'] = userId;
      if (transactionId != null) queryParams['transaction_id'] = transactionId;
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
      if (action != null) queryParams['action'] = action;

      final response = await _apiClient.getFromService(
        Microservice.audit,
        ApiEndpoints.auditLogs,
        queryParameters: queryParams,
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (d) => d as Map<String, dynamic>,
      );
    } on ApiException catch (e) {
      print('Error consultando logs de auditoría: ${e.message}');
      rethrow;
    }
  }

  /// Generar reporte de auditoría
  Future<ApiResponse<Map<String, dynamic>>> generateReport({
    required DateTime startDate,
    required DateTime endDate,
    List<String>? eventTypes,
    List<int>? userIds,
    String format = 'json',
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'format': format,
      };
      if (eventTypes != null && eventTypes.isNotEmpty) {
        queryParams['event_types'] = eventTypes.join(',');
      }
      if (userIds != null && userIds.isNotEmpty) {
        queryParams['user_ids'] = userIds.join(',');
      }

      final response = await _apiClient.getFromService(
        Microservice.audit,
        ApiEndpoints.auditReports,
        queryParameters: queryParams,
      );
      final raw = response.data as Map<String, dynamic>;
      final report = raw['report'] ?? raw['data'] ?? raw;
      return ApiResponse.fromJson(
        {...raw, 'data': report, 'success': raw['success'] ?? true},
        (d) => d as Map<String, dynamic>,
      );
    } on ApiException catch (e) {
      print('Error generando reporte de auditoría: ${e.message}');
      rethrow;
    }
  }
}
