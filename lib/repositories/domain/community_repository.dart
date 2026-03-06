/// Repositorio para datos de la comunidad energética
/// Maneja miembros, períodos y perfil de usuario
library;

import 'package:be_energy/models/home_data_models.dart';
import 'package:be_energy/models/community_models.dart';
import 'package:be_energy/models/energy_models.dart';

/// Interfaz abstracta para el repositorio de comunidad
abstract class CommunityRepository {
  /// Obtiene el perfil de un usuario
  ///
  /// [userId] - ID del usuario
  /// [viewType] - Tipo de vista (para calcular totalMembers)
  Future<UserProfile> getUserProfile({
    required int userId,
    required ViewType viewType,
  });

  /// Obtiene la lista de períodos disponibles
  Future<AvailablePeriods> getAvailablePeriods();

  /// Obtiene el período actual (más reciente con datos)
  Future<String> getCurrentPeriod();

  /// Obtiene información de un período específico
  ///
  /// [period] - Período en formato 'YYYY-MM'
  Future<PeriodInfo> getPeriodInfo({
    required String period,
  });

  /// Obtiene el total de miembros de la comunidad
  Future<int> getTotalMembers();

  /// Verifica si un usuario tiene rol de administrador
  ///
  /// [userId] - ID del usuario
  Future<bool> isAdmin({
    required int userId,
  });

  /// Obtiene los miembros de la comunidad con sus registros de energía
  ///
  /// [communityId] - ID de la comunidad (default: 1)
  /// [period] - Período en formato 'YYYY-MM' (opcional)
  /// Retorna una lista de miembros con sus energy records
  Future<List<CommunityMember>> getCommunityMembers({
    int communityId = 1,
    String? period,
  });

  /// Obtiene los registros de energía para un período
  ///
  /// [communityId] - ID de la comunidad
  /// [period] - Período en formato 'YYYY-MM' (opcional)
  Future<List<EnergyRecord>> getEnergyRecords({
    int communityId = 1,
    String? period,
  });
}
