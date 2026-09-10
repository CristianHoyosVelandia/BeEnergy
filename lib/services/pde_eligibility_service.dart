import 'package:be_energy/core/api/api_client.dart';
import 'package:be_energy/core/constants/api_endpoints.dart';
import 'package:be_energy/models/pde_eligibility.dart';

class PdeEligibilityService {
  final ApiClient _client;

  PdeEligibilityService({ApiClient? client})
      : _client = client ?? ApiClient.instance;

  Future<PdeEligibility> getEligibility({
    required int communityId,
    required String period,
    String? phase,
  }) async {
    final response = await _client.get(
      ApiEndpoints.pdeEligibility,
      queryParameters: {
        'community_id': communityId,
        'period': period,
        if (phase != null) 'phase': phase,
      },
    );

    final body = response.data as Map<String, dynamic>;
    if (body['success'] != true) {
      throw Exception(body['message'] ?? 'Error obteniendo elegibilidad PDE');
    }

    return PdeEligibility.fromJson(body['data'] as Map<String, dynamic>);
  }
}
