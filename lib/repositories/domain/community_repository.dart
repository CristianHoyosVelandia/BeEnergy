/// Repositorio para datos de la comunidad energética
/// Maneja miembros, períodos y perfil de usuario
library;

import 'package:be_energy/models/home_data_models.dart';

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
}
