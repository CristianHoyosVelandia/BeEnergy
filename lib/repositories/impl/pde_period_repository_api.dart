import '../../core/api/api_client.dart';
import '../../core/utils/logger.dart';
import '../../models/pde_period_status.dart';
import '../../models/user_period_history.dart';
import '../domain/pde_period_repository.dart';

const String _tag = 'PDEPeriodRepo';

/// Implementación del repositorio de periodos PDE usando API REST.
///
/// Se conecta a los endpoints:
/// - GET /community/pde-period-status (estado PDE)
/// - GET /community/pde-historial-period (historial de períodos)
class PDEPeriodRepositoryApi implements PDEPeriodRepository {
  @override
  Future<PDEPeriodStatus> getPeriodStatus({
    required int communityId,
    String? period,
  }) async {
    try {
      // Construir query parameters
      final queryParams = <String, dynamic>{
        'community_id': communityId,
      };
      
      if (period != null) {
        queryParams['period'] = period;
      }

      // Llamada HTTP GET al endpoint
      final response = await ApiClient.instance.get(
        '/community/pde-period-status',
        queryParameters: queryParams,
      );

      // Validar respuesta exitosa
      if (response.statusCode == 200 && response.data['success'] == true) {
        final pdeStatus = PDEPeriodStatus.fromJson(response.data['data']);
        // print('✅ [PDEPeriodRepositoryApi] PDEPeriodStatus parseado correctamente');
        return pdeStatus;
      } else {
        throw Exception(
          'Error obteniendo estado PDE: ${response.statusMessage ?? "Error desconocido"}'
        );
      }
    } catch (e) {
      AppLogger.error('Error obteniendo estado PDE', tag: _tag, error: e);
      // Re-lanzar con mensaje más descriptivo
      throw Exception('Error obteniendo estado PDE: $e');
    }
  }

  @override
  Future<UserPeriodHistory> getUserPeriodHistory({
    required int userId,
    int communityId = 1,
    int limit = 4,
  }) async {
    try {
      // Construir query parameters
      final queryParams = <String, dynamic>{
        'user_id': userId,
        'community_id': communityId,
        'limit': limit,
      };

      AppLogger.debug('GET /community/pde-historial-period params=$queryParams', tag: _tag);

      // Llamada HTTP GET al endpoint
      final response = await ApiClient.instance.get(
        '/community/pde-historial-period',
        queryParameters: queryParams,
      );

      AppLogger.debug('Response: status=${response.statusCode}, periods=${response.data['data']['total_periods']}', tag: _tag);

      // Validar respuesta exitosa
      if (response.statusCode == 200 && response.data['success'] == true) {
        final history = UserPeriodHistory.fromJson(response.data['data']);
        AppLogger.info('UserPeriodHistory parseado correctamente', tag: _tag);
        return history;
      } else {
        throw Exception(
          'Error obteniendo historial: ${response.statusMessage ?? "Error desconocido"}'
        );
      }
    } catch (e) {
      AppLogger.error('Error obteniendo historial', tag: _tag, error: e);
      throw Exception('Error obteniendo historial de períodos: $e');
    }
  }
}
