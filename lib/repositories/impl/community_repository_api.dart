/// Implementación API del repositorio de comunidad
/// Consume endpoints reales del backend
library;

import 'package:be_energy/core/api/api_client.dart';
import 'package:be_energy/core/constants/api_endpoints.dart';
import 'package:be_energy/models/home_data_models.dart';
import 'package:be_energy/models/community_models.dart';
import 'package:be_energy/models/energy_models.dart';
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

  @override
  Future<List<CommunityMember>> getCommunityMembers({
    int communityId = 1,
    String? period,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'community_id': communityId,
      };

      if (period != null) {
        queryParams['period'] = period;
      }

      final response = await _client.get(
        ApiEndpoints.communityMembers,
        queryParameters: queryParams,
      );

      // Parsear respuesta del backend
      final data = response.data['data'] as Map<String, dynamic>;
      final membersData = data['members'] as List<dynamic>;

      return membersData.map((memberJson) {
        final member = memberJson as Map<String, dynamic>;

        // Convertir role numérico a string para el modelo
        final roleInt = member['role'] as int;
        final roleString = roleInt == 2 ? 'prosumer' : 'consumer';

        return CommunityMember(
          id: member['user_id'] as int,
          communityId: communityId,
          userId: member['user_id'] as int,
          userName: member['name'] as String,
          userLastName: member['lastname'] as String,
          role: roleString,
          installedCapacity: roleInt == 2 ? 100.0 : 0.0, // Temporal
          pdeShare: 0.0,
          isActive: member['is_active'] as bool? ?? true,
        );
      }).toList();
    } catch (e) {
      print('Error al obtener miembros de comunidad: $e');
      rethrow;
    }
  }

  @override
  Future<List<EnergyRecord>> getEnergyRecords({
    int communityId = 1,
    String? period,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'community_id': communityId,
      };

      if (period != null) {
        queryParams['period'] = period;
      }

      final response = await _client.get(
        ApiEndpoints.communityMembers,
        queryParameters: queryParams,
      );

      // Parsear respuesta del backend
      final data = response.data['data'] as Map<String, dynamic>;
      final membersData = data['members'] as List<dynamic>;

      // Extraer energy_records de cada miembro
      return membersData.map((memberJson) {
        final member = memberJson as Map<String, dynamic>;
        final energyRecordData = member['energy_record'] as Map<String, dynamic>?;

        if (energyRecordData != null) {
          return EnergyRecord(
            id: member['user_id'] as int,
            userId: member['user_id'] as int,
            userName: '${member['name']} ${member['lastname']}',
            communityId: communityId,
            energyGenerated: (energyRecordData['energy_generated'] as num).toDouble(),
            energyConsumed: (energyRecordData['energy_consumed'] as num).toDouble(),
            energyExported: (energyRecordData['energy_exported'] as num).toDouble(),
            energyImported: (energyRecordData['energy_imported'] as num).toDouble(),
            period: energyRecordData['period'] as String,
          );
        } else {
          // Si no hay energy_record, crear uno vacío
          return EnergyRecord(
            id: member['user_id'] as int,
            userId: member['user_id'] as int,
            userName: '${member['name']} ${member['lastname']}',
            communityId: communityId,
            energyGenerated: 0.0,
            energyConsumed: 0.0,
            energyExported: 0.0,
            energyImported: 0.0,
            period: period ?? '',
          );
        }
      }).toList();
    } catch (e) {
      print('Error al obtener energy records: $e');
      rethrow;
    }
  }
}
