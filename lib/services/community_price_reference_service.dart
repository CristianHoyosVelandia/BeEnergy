import 'package:be_energy/core/api/api_client.dart';
import 'package:be_energy/models/community_price_reference.dart';

class CommunityPriceReferenceService {
  final ApiClient _client;

  CommunityPriceReferenceService({ApiClient? client})
      : _client = client ?? ApiClient.instance;

  Future<List<CommunityPriceReference>> getPriceReferences({
    required int communityId,
    required String period,
  }) async {
    final response = await _client.post(
      '/community/price-references',
      data: {
        'community_id': communityId,
        'period': period,
      },
    );

    final body = response.data as Map<String, dynamic>;
    if (body['success'] != true) {
      throw Exception(body['message'] ?? 'Error obteniendo precios');
    }

    final data = (body['data'] as List<dynamic>? ?? []);
    return data
        .map((item) => CommunityPriceReference.fromJson(
              item as Map<String, dynamic>,
            ))
        .toList();
  }
}
