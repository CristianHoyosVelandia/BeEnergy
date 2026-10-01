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
  final bool autoOffer;
  final bool manualOfferEnabled;
  final bool automaticOfferFlow;

  PDEPeriodStatus({
    required this.communityId,
    required this.period,
    required this.statusCode,
    required this.statusName,
    required this.canCreateOffers,
    this.autoOffer = false,
    this.manualOfferEnabled = true,
    this.automaticOfferFlow = false,
  });

  /// Constructor desde JSON (API response)
  factory PDEPeriodStatus.fromJson(Map<String, dynamic> json) {
    return PDEPeriodStatus(
      communityId: json['community_id'] as int,
      period: json['period'] as String,
      statusCode: json['status_code'] as int,
      statusName: json['status_name'] as String,
      canCreateOffers: json['can_create_offers'] as bool,
      autoOffer: json['auto_offer'] as bool? ?? false,
      manualOfferEnabled: json['manual_offer_enabled'] as bool? ?? true,
      automaticOfferFlow: json['automatic_offer_flow'] as bool? ?? false,
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
      'auto_offer': autoOffer,
      'manual_offer_enabled': manualOfferEnabled,
      'automatic_offer_flow': automaticOfferFlow,
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
        return 'PDE disponible';
      case 2:
        return 'Periodo cerrado';
      case 3:
        return 'Ofertas finalizadas';
      case 4:
        return 'En conciliación';
      case 5:
        return 'Periodo histórico';
      case 6:
        return 'Aporte comunitario PDE';
      case 7:
        return 'Cobro del periodo';
      default:
        return 'No disponible';
    }
  }

  @override
  String toString() {
    return 'PDEPeriodStatus(period: $period, status: $statusName, canCreateOffers: $canCreateOffers)';
  }
}
