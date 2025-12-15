/// Oferta P2P mensual publicada por prosumidor
///
/// Representa una oferta de venta de energía excedente Tipo 2 en el mercado P2P.
/// Las ofertas son válidas durante el mes en curso y deben cumplir con el rango
/// de precios VE ±10% según CREG 101 072 de 2025.
class P2POffer {
  final int id;
  final int sellerId;
  final String sellerName;
  final int communityId;
  final String period; // Formato: 'YYYY-MM'

  final double energyAvailable; // kWh totales ofertados inicialmente
  final double energyRemaining; // kWh aún disponibles sin vender
  final double pricePerKwh; // COP/kWh - debe estar en rango VE ±10%

  final OfferStatus status;
  final DateTime createdAt;
  final DateTime validUntil; // Último día del mes

  const P2POffer({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.communityId,
    required this.period,
    required this.energyAvailable,
    required this.energyRemaining,
    required this.pricePerKwh,
    required this.status,
    required this.createdAt,
    required this.validUntil,
  });

  /// Valor total de la energía disponible
  double get totalValue => energyAvailable * pricePerKwh;

  /// Porcentaje de energía ya vendida (0.0 - 1.0)
  double get soldPercentage {
    if (energyAvailable == 0) return 0.0;
    return 1.0 - (energyRemaining / energyAvailable);
  }

  /// Verifica si la oferta ha expirado
  bool get isExpired => DateTime.now().isAfter(validUntil);

  /// Verifica si la oferta está completamente vendida
  bool get isFullySold => energyRemaining == 0;

  /// Verifica si la oferta está disponible para compra
  bool get isAvailable =>
      status == OfferStatus.available &&
      !isExpired &&
      energyRemaining > 0;

  /// Crea una copia de la oferta con campos modificados
  P2POffer copyWith({
    int? id,
    int? sellerId,
    String? sellerName,
    int? communityId,
    String? period,
    double? energyAvailable,
    double? energyRemaining,
    double? pricePerKwh,
    OfferStatus? status,
    DateTime? createdAt,
    DateTime? validUntil,
  }) {
    return P2POffer(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      communityId: communityId ?? this.communityId,
      period: period ?? this.period,
      energyAvailable: energyAvailable ?? this.energyAvailable,
      energyRemaining: energyRemaining ?? this.energyRemaining,
      pricePerKwh: pricePerKwh ?? this.pricePerKwh,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      validUntil: validUntil ?? this.validUntil,
    );
  }

  /// Convierte el modelo a Map para persistencia
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'communityId': communityId,
      'period': period,
      'energyAvailable': energyAvailable,
      'energyRemaining': energyRemaining,
      'pricePerKwh': pricePerKwh,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'validUntil': validUntil.toIso8601String(),
    };
  }

  /// Crea una instancia desde Map
  factory P2POffer.fromJson(Map<String, dynamic> json) {
    return P2POffer(
      id: json['id'] as int,
      sellerId: json['sellerId'] as int,
      sellerName: json['sellerName'] as String,
      communityId: json['communityId'] as int,
      period: json['period'] as String,
      energyAvailable: (json['energyAvailable'] as num).toDouble(),
      energyRemaining: (json['energyRemaining'] as num).toDouble(),
      pricePerKwh: (json['pricePerKwh'] as num).toDouble(),
      status: OfferStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OfferStatus.available,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      validUntil: DateTime.parse(json['validUntil'] as String),
    );
  }

  @override
  String toString() {
    return 'P2POffer(id: $id, seller: $sellerName, energy: $energyRemaining/$energyAvailable kWh, price: $pricePerKwh COP/kWh, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is P2POffer &&
        other.id == id &&
        other.sellerId == sellerId &&
        other.period == period;
  }

  @override
  int get hashCode => id.hashCode ^ sellerId.hashCode ^ period.hashCode;
}

/// Estados posibles de una oferta P2P
enum OfferStatus {
  /// Disponible para compra (energía restante > 0, no expirada)
  available,

  /// Parcialmente vendida (0 < energía restante < energía total)
  partial,

  /// Totalmente vendida (energía restante = 0)
  sold,

  /// Expirada (fecha de validez superada)
  expired,

  /// Cancelada por el prosumidor
  cancelled,
}

extension OfferStatusExtension on OfferStatus {
  /// Texto descriptivo del estado
  String get displayName {
    switch (this) {
      case OfferStatus.available:
        return 'Disponible';
      case OfferStatus.partial:
        return 'Parcialmente vendida';
      case OfferStatus.sold:
        return 'Vendida';
      case OfferStatus.expired:
        return 'Expirada';
      case OfferStatus.cancelled:
        return 'Cancelada';
    }
  }

  /// Ícono asociado al estado
  String get icon {
    switch (this) {
      case OfferStatus.available:
        return '✅';
      case OfferStatus.partial:
        return '⏳';
      case OfferStatus.sold:
        return '✔️';
      case OfferStatus.expired:
        return '⏰';
      case OfferStatus.cancelled:
        return '❌';
    }
  }
}
