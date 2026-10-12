import 'package:be_energy/core/api/api_client.dart';
import 'package:be_energy/core/api/api_exceptions.dart';
import 'package:be_energy/core/constants/api_endpoints.dart';
import 'package:be_energy/models/pde_assignment_summary.dart';

class PdeAssignmentSummaryService {
  final ApiClient _client;

  PdeAssignmentSummaryService({ApiClient? client})
      : _client = client ?? ApiClient.instance;

  Future<PdeAssignmentSummary> getSummary({
    required int communityId,
    required String period,
  }) async {
    try {
      final response = await _client.get(
        ApiEndpoints.pdeAsignacionResumen,
        queryParameters: {
          'community_id': communityId,
          'period': period,
        },
      );

      final body = response.data as Map<String, dynamic>;
      if (body['success'] == true) {
        return PdeAssignmentSummary.fromJson(
          body['data'] as Map<String, dynamic>,
        );
      }

      throw ApiException(
        message:
            body['message'] as String? ?? 'Error obteniendo asignación PDE',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Error inesperado obteniendo asignación PDE: $e',
        statusCode: 500,
      );
    }
  }
}
