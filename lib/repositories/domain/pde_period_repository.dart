import '../../models/pde_period_status.dart';
import '../../models/user_period_history.dart';

/// Repositorio abstracto para operaciones de periodos PDE.
///
/// Define el contrato para obtener el estado de periodos PDE
/// desde el backend.
abstract class PDEPeriodRepository {
  /// Obtiene el estado de un periodo PDE para una comunidad.
  ///
  /// [communityId]: ID de la comunidad energética
  /// [period]: Periodo en formato YYYY-MM (opcional, default: mes actual en backend)
  ///
  /// Returns: [PDEPeriodStatus] con el estado del periodo
  Future<PDEPeriodStatus> getPeriodStatus({
    required int communityId,
    String? period,
  });

  /// Obtiene el historial de períodos disponibles para un usuario.
  ///
  /// Retorna los períodos donde el usuario tiene registros en energy_records,
  /// combinados con el estado PDE de cada período.
  ///
  /// [userId]: ID del usuario
  /// [communityId]: ID de la comunidad energética (default: 1)
  /// [limit]: Número máximo de períodos a retornar (default: 4)
  ///
  /// Returns: [UserPeriodHistory] con la lista de períodos del usuario
  Future<UserPeriodHistory> getUserPeriodHistory({
    required int userId,
    int communityId = 1,
    int limit = 4,
  });

  /// Actualiza el estado de un periodo PDE.
  ///
  /// [communityId]: ID de la comunidad energética
  /// [period]: Periodo en formato YYYY-MM
  /// [newStatusCode]: Nuevo código de estado (1-5)
  ///
  /// Returns: [PDEPeriodStatus] con el estado actualizado
  Future<PDEPeriodStatus> updatePeriodStatus({
    required int communityId,
    required String period,
    required int newStatusCode,
  });
}
