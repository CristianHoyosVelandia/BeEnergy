/// Implementación fake del repositorio de comunidad
library;

import 'package:be_energy/data/fake_data_phase2.dart';
import 'package:be_energy/data/fake_periods_data.dart';
import 'package:be_energy/models/home_data_models.dart';
import 'package:be_energy/repositories/domain/community_repository.dart';

/// Implementación con fake data para comunidad
class CommunityRepositoryFake implements CommunityRepository {
  @override
  Future<UserProfile> getUserProfile({
    required int userId,
    required ViewType viewType,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));

    // En fake data, asumimos que el usuario por defecto es el prosumidor
    final member = userId == 24
        ? FakeDataPhase2.mariaGarcia
        : FakeDataPhase2.cristianHoyos;

    final totalMembers = viewType == ViewType.admin
        ? FakeDataPhase2.allMembers.length
        : 1;

    return UserProfile(
      userId: member.userId,
      userName: member.userName,
      userLastName: member.userLastName,
      role: member.role,
      totalMembers: totalMembers,
    );
  }

  @override
  Future<AvailablePeriods> getAvailablePeriods() async {
    await Future.delayed(const Duration(milliseconds: 100));

    final periods = FakePeriodsData.availablePeriods.map((p) {
      return PeriodInfo(
        period: p.period,
        displayName: p.displayName,
        isCurrent: p.status == PeriodStatus.current,
        hasData: p.hasData,
        status: p.status,
        description: FakePeriodsData.getPeriodMetadata(p.period)?['description'],
      );
    }).toList();

    return AvailablePeriods(
      periods: periods,
      currentPeriod: FakePeriodsData.currentPeriod,
    );
  }

  @override
  Future<String> getCurrentPeriod() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return FakePeriodsData.currentPeriod;
  }

  @override
  Future<PeriodInfo> getPeriodInfo({required String period}) async {
    await Future.delayed(const Duration(milliseconds: 50));

    final periodData = FakePeriodsData.getPeriodByKey(period) ??
        FakePeriodsData.currentPeriodData;

    return PeriodInfo(
      period: periodData.period,
      displayName: periodData.displayName,
      isCurrent: periodData.status == PeriodStatus.current,
      hasData: periodData.hasData,
      status: periodData.status,
      description: FakePeriodsData.getPeriodMetadata(period)?['description'],
    );
  }

  @override
  Future<int> getTotalMembers() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return FakeDataPhase2.allMembers.length;
  }

  @override
  Future<bool> isAdmin({required int userId}) async {
    await Future.delayed(const Duration(milliseconds: 50));
    // En fake data, consideramos admin al usuario con ID 1
    return userId == 1 || userId == 24; // Temporalmente ambos son admin
  }
}
