import '../../models/pde_period_status.dart';

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
}
