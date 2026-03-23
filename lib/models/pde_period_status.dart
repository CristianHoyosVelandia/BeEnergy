/// Modelo para el estado de un periodo PDE.
///
/// Representa el estado actual de un periodo mensual de una comunidad energética,
/// determinando si se pueden crear ofertas PDE.
class PDEPeriodStatus {
  final int communityId;
  final String period;
  final int statusCode;
  final String statusName;
  final bool canCreateOffers;

  PDEPeriodStatus({
    required this.communityId,
    required this.period,
    required this.statusCode,
    required this.statusName,
    required this.canCreateOffers,
  });

  /// Constructor desde JSON (API response)
  factory PDEPeriodStatus.fromJson(Map<String, dynamic> json) {
    return PDEPeriodStatus(
      communityId: json['community_id'] as int,
      period: json['period'] as String,
      statusCode: json['status_code'] as int,
      statusName: json['status_name'] as String,
      canCreateOffers: json['can_create_offers'] as bool,
    );
  }

  /// Convierte el modelo a JSON
  Map<String, dynamic> toJson() {
    return {
      'community_id': communityId,
      'period': period,
      'status_code': statusCode,
      'status_name': statusName,
      'can_create_offers': canCreateOffers,
    };
  }

  /// Verifica si el PDE está disponible para crear ofertas
  /// (status_code == 1 && canCreateOffers == true)
  bool get isPDEAvailable => statusCode == 1 && canCreateOffers;

  /// Verifica si el periodo está cerrado
  bool get isClosed => statusCode >= 2;

  /// Obtiene un mensaje descriptivo del estado
  String getDisplayMessage() {
    switch (statusCode) {
      case 1:
        return '⚡ Nuevo PDE: disponible';
      case 2:
        return 'Periodo cerrado';
      case 3:
        return 'Ofertas finalizadas';
      case 4:
        return 'En conciliación';
      case 5:
        return 'Periodo histórico';
      default:
        return 'No disponible';
    }
  }

  @override
  String toString() {
    return 'PDEPeriodStatus(period: $period, status: $statusName, canCreateOffers: $canCreateOffers)';
  }
}
