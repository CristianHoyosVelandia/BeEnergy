/// Implementación API del repositorio de comunidad
/// Consume endpoints reales del backend
library;

import 'package:be_energy/core/api/api_client.dart';
import 'package:be_energy/core/constants/api_endpoints.dart';
import 'package:be_energy/models/home_data_models.dart';
import 'package:be_energy/repositories/domain/community_repository.dart';

/// Implementación con API real para comunidad
class CommunityRepositoryApi implements CommunityRepository {
  final ApiClient _client = ApiClient.instance;

  @override
  Future<UserProfile> getUserProfile({
    required int userId,
    required ViewType viewType,
  }) async {
    try {
      final response = await _client.get(
        ApiEndpoints.userProfile,
        queryParameters: {
          'user_id': userId,
          'view_type': viewType.name,
        },
      );

      return UserProfile.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AvailablePeriods> getAvailablePeriods() async {
    try {
      final response = await _client.get(
        '${ApiEndpoints.community}/periods',
      );

      return AvailablePeriods.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> getCurrentPeriod() async {
    try {
      final response = await _client.get(
        '${ApiEndpoints.community}/current-period',
      );

      return response.data['current_period'] as String;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PeriodInfo> getPeriodInfo({required String period}) async {
    try {
      final response = await _client.get(
        '${ApiEndpoints.community}/period/$period',
      );

      return PeriodInfo.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<int> getTotalMembers() async {
    try {
      final response = await _client.get(
        ApiEndpoints.communityMembers,
        queryParameters: {
          'count_only': true,
        },
      );

      return response.data['total'] as int;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> isAdmin({required int userId}) async {
    try {
      final response = await _client.get(
        '${ApiEndpoints.userProfile}/is-admin',
        queryParameters: {
          'user_id': userId,
        },
      );

      return response.data['is_admin'] as bool;
    } catch (e) {
      rethrow;
    }
  }
}
