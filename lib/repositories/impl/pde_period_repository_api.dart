import '../../core/api/api_client.dart';
import '../../models/pde_period_status.dart';
import '../domain/pde_period_repository.dart';

/// Implementación del repositorio de periodos PDE usando API REST.
///
/// Se conecta al endpoint GET /community/pde-period-status del backend.
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
}
