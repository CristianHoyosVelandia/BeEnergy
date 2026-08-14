import 'package:be_energy/core/api/api_client.dart';
import 'package:be_energy/core/api/api_exceptions.dart';
import 'package:be_energy/core/constants/api_endpoints.dart';
import 'package:be_energy/models/pde_cobro_resumen.dart';

class PdeCobroService {
  final ApiClient _client;

  PdeCobroService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  Future<PdeCobroResumen> getResumen({
    required int communityId,
    required String period,
  }) async {
    try {
      final response = await _client.get(
        ApiEndpoints.pdeCobroResumen,
        queryParameters: {
          'community_id': communityId,
          'period': period,
        },
      );

      final body = response.data as Map<String, dynamic>;
      if (body['success'] == true) {
        return PdeCobroResumen.fromJson(body['data'] as Map<String, dynamic>);
      }

      throw ApiException(
        message: body['message'] as String? ?? 'Error obteniendo cobro PDE',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Error inesperado obteniendo cobro PDE: $e',
        statusCode: 500,
      );
    }
  }
}
