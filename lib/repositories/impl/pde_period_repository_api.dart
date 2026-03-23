import '../../core/api/api_client.dart';
import '../../models/pde_period_status.dart';
import '../../models/user_period_history.dart';
import '../domain/pde_period_repository.dart';

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

      print('📡 [PDEPeriodRepositoryApi] Respuesta recibida:');
      print('   Status code: ${response.statusCode}');
      print('   Success: ${response.data['success']}');
      print('   Data: ${response.data['data']}');

      // Validar respuesta exitosa
      if (response.statusCode == 200 && response.data['success'] == true) {
        final pdeStatus = PDEPeriodStatus.fromJson(response.data['data']);
        print('✅ [PDEPeriodRepositoryApi] PDEPeriodStatus parseado correctamente');
        return pdeStatus;
      } else {
        throw Exception(
          'Error obteniendo estado PDE: ${response.statusMessage ?? "Error desconocido"}'
        );
      }
    } catch (e) {
      print('❌ [PDEPeriodRepositoryApi] Error: $e');
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

      print('🌐 [PDEPeriodRepositoryApi] Llamando GET /community/pde-historial-period');
      print('   Query params: $queryParams');

      // Llamada HTTP GET al endpoint
      final response = await ApiClient.instance.get(
        '/community/pde-historial-period',
        queryParameters: queryParams,
      );

      print('📡 [PDEPeriodRepositoryApi] Respuesta historial recibida:');
      print('   Status code: ${response.statusCode}');
      print('   Success: ${response.data['success']}');
      print('   Total periods: ${response.data['data']['total_periods']}');

      // Validar respuesta exitosa
      if (response.statusCode == 200 && response.data['success'] == true) {
        final history = UserPeriodHistory.fromJson(response.data['data']);
        print('✅ [PDEPeriodRepositoryApi] UserPeriodHistory parseado correctamente');
        return history;
      } else {
        throw Exception(
          'Error obteniendo historial: ${response.statusMessage ?? "Error desconocido"}'
        );
      }
    } catch (e) {
      print('❌ [PDEPeriodRepositoryApi] Error obteniendo historial: $e');
      throw Exception('Error obteniendo historial de períodos: $e');
    }
  }
}
