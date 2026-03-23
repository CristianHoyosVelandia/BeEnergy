/// Oferta P2P creada por consumidor (Enero 2026+)
///
/// A diferencia del modelo Diciembre 2025 donde prosumidores venden kWh fijos,
/// aquí los consumidores especifican qué % del PDE total quieren comprar.
///
/// Los kWh reales se calculan durante el proceso de liquidación cuando
/// el administrador hace el matching con la energía disponible de prosumidores.
class ConsumerOffer {
  final int id;
  final int buyerId;
  final String buyerName;
  final int communityId;
  final String period; // Formato: 'YYYY-MM'

  /// Porcentaje del PDE solicitado (0.0 - 1.0)
  /// Ejemplo: 0.15 = quiere el 15% del PDE total disponible
  final double pdePercentageRequested;

  /// Precio que está dispuesto a pagar (COP/kWh)
  /// Rango permitido: VE+10% a Tarifa-Transporte (495-550 COP/kWh para Ene 2026)
  final double pricePerKwh;

  /// Cantidad calculada en kWh (null hasta que se liquide)
  /// Se calcula como: pdePercentageRequested * totalPDEAvailable
  final double? energyKwhCalculated;

  final ConsumerOfferStatus status;
  final DateTime createdAt;
  final DateTime validUntil; // Último día del mes

  // Metadata de liquidación
  final int? liquidationSessionId; // null si no ha sido liquidada
  final DateTime? liquidatedAt;
  final int? matchedProsumerId; // A quién se le asignó finalmente

  // NIU del comprador (opcional)
  final String? buyerNIU;

  const ConsumerOffer({
    required this.id,
    required this.buyerId,
    required this.buyerName,
    required this.communityId,
    required this.period,
    required this.pdePercentageRequested,
    required this.pricePerKwh,
    required this.status,
    required this.createdAt,
    required this.validUntil,
    this.energyKwhCalculated,
    this.liquidationSessionId,
    this.liquidatedAt,
    this.matchedProsumerId,
    this.buyerNIU,
  });

  /// Calcula la energía en kWh basada en el PDE total disponible
  double calculateEnergyKwh(double totalPDEAvailable) {
    return pdePercentageRequested * totalPDEAvailable;
  }

  /// Verifica si el precio está en el rango válido para consumidores
  /// Rango: VE+10% (mínimo) hasta Tarifa-Transporte (máximo)
  bool isPriceValid(double minPrice, double maxPrice) {
    return pricePerKwh >= minPrice && pricePerKwh <= maxPrice;
  }

  /// Verifica si la oferta puede ser liquidada
  bool isLiquidatable() {
    return status == ConsumerOfferStatus.pending &&
           !isExpired &&
           liquidationSessionId == null;
  }

  /// Verifica si la oferta ha expirado
  bool get isExpired => DateTime.now().isAfter(validUntil);

  /// Calcula el costo estimado si se cumple el porcentaje completo
  double getEstimatedCost(double totalPDEAvailable) {
    final kwh = calculateEnergyKwh(totalPDEAvailable);
    return kwh * pricePerKwh;
  }

  /// Porcentaje cumplido (0.0 - 1.0)
  /// 1.0 = 100% satisfecho, 0.5 = 50% satisfecho
  double get fulfillmentPercentage {
    if (energyKwhCalculated == null) return 0.0;
    // El cálculo exacto dependerá del PDE total disponible
    // Por ahora retorna 1.0 si está matched, 0.0 si no
    return status == ConsumerOfferStatus.matched ? 1.0 : 0.0;
  }

  /// Crea una copia de la oferta con campos modificados
  ConsumerOffer copyWith({
    int? id,
    int? buyerId,
    String? buyerName,
    int? communityId,
    String? period,
    double? pdePercentageRequested,
    double? pricePerKwh,
    double? energyKwhCalculated,
    ConsumerOfferStatus? status,
    DateTime? createdAt,
    DateTime? validUntil,
    int? liquidationSessionId,
    DateTime? liquidatedAt,
    int? matchedProsumerId,
    String? buyerNIU,
  }) {
    return ConsumerOffer(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      buyerName: buyerName ?? this.buyerName,
      communityId: communityId ?? this.communityId,
      period: period ?? this.period,
      pdePercentageRequested: pdePercentageRequested ?? this.pdePercentageRequested,
      pricePerKwh: pricePerKwh ?? this.pricePerKwh,
      energyKwhCalculated: energyKwhCalculated ?? this.energyKwhCalculated,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      validUntil: validUntil ?? this.validUntil,
      liquidationSessionId: liquidationSessionId ?? this.liquidationSessionId,
      liquidatedAt: liquidatedAt ?? this.liquidatedAt,
      matchedProsumerId: matchedProsumerId ?? this.matchedProsumerId,
      buyerNIU: buyerNIU ?? this.buyerNIU,
    );
  }

  /// Convierte el modelo a Map para persistencia
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'communityId': communityId,
      'period': period,
      'pdePercentageRequested': pdePercentageRequested,
      'pricePerKwh': pricePerKwh,
      'energyKwhCalculated': energyKwhCalculated,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'validUntil': validUntil.toIso8601String(),
      'liquidationSessionId': liquidationSessionId,
      'liquidatedAt': liquidatedAt?.toIso8601String(),
      'matchedProsumerId': matchedProsumerId,
      'buyerNIU': buyerNIU,
    };
  }

  /// Crea una instancia desde Map (almacenamiento local)
  factory ConsumerOffer.fromJson(Map<String, dynamic> json) {
    return ConsumerOffer(
      id: json['id'] as int,
      buyerId: json['buyerId'] as int,
      buyerName: json['buyerName'] as String,
      communityId: json['communityId'] as int,
      period: json['period'] as String,
      pdePercentageRequested: (json['pdePercentageRequested'] as num).toDouble(),
      pricePerKwh: (json['pricePerKwh'] as num).toDouble(),
      energyKwhCalculated: json['energyKwhCalculated'] != null
          ? (json['energyKwhCalculated'] as num).toDouble()
          : null,
      status: ConsumerOfferStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ConsumerOfferStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      validUntil: DateTime.parse(json['validUntil'] as String),
      liquidationSessionId: json['liquidationSessionId'] as int?,
      liquidatedAt: json['liquidatedAt'] != null
          ? DateTime.parse(json['liquidatedAt'] as String)
          : null,
      matchedProsumerId: json['matchedProsumerId'] as int?,
      buyerNIU: json['buyerNIU'] as String?,
    );
  }

  /// Crea una instancia desde respuesta del backend (snake_case)
  ///
  /// El backend retorna:
  /// - pde_percentage_requested como porcentaje (0.01-99.99)
  /// - status como int (0-4)
  /// - created_at en formato ISO 8601
  factory ConsumerOffer.fromBackendJson(Map<String, dynamic> json) {
    // Calcular validUntil basado en el período
    DateTime validUntil;
    try {
      final parts = (json['period'] as String).split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final lastDay = DateTime(year, month + 1, 0);
      validUntil = DateTime(year, month, lastDay.day, 23, 59, 59);
    } catch (e) {
      validUntil = DateTime.now();
    }

    return ConsumerOffer(
      id: json['id'] as int,
      buyerId: json['buyer_id'] as int,
      buyerName: 'Usuario ${json['buyer_id']}', // El backend no retorna nombre
      communityId: json['community_id'] as int,
      period: json['period'] as String,
      // Backend retorna como porcentaje (0.01-99.99), convertir a decimal (0.0001-0.9999)
      pdePercentageRequested: (json['pde_percentage_requested'] as num).toDouble() / 100,
      pricePerKwh: (json['price_per_kwh'] as num).toDouble(),
      energyKwhCalculated: null, // Backend no retorna este campo
      // Backend retorna status como int (0-4)
      status: ConsumerOfferStatus.values[(json['status'] as int).clamp(0, 4)],
      createdAt: DateTime.parse(json['created_at'] as String),
      validUntil: validUntil,
      liquidationSessionId: json['liquidation_session_id'] as int?,
      liquidatedAt: json['liquidated_at'] != null
          ? DateTime.parse(json['liquidated_at'] as String)
          : null,
      matchedProsumerId: null, // Backend no retorna este campo
      buyerNIU: null, // Backend no retorna este campo
    );
  }

  /// Convierte el modelo a formato backend (snake_case)
  Map<String, dynamic> toBackendJson() {
    return {
      'buyer_id': buyerId,
      'community_id': communityId,
      'period': period,
      // Convertir de decimal (0.0001-0.9999) a porcentaje (0.01-99.99)
      'pde_percentage_requested': pdePercentageRequested * 100,
      'price_per_kwh': pricePerKwh,
    };
  }

  @override
  String toString() {
    return 'ConsumerOffer(id: $id, buyer: $buyerName, pde: ${(pdePercentageRequested * 100).toStringAsFixed(1)}%, price: $pricePerKwh COP/kWh, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ConsumerOffer &&
        other.id == id &&
        other.buyerId == buyerId &&
        other.period == period;
  }

  @override
  int get hashCode => id.hashCode ^ buyerId.hashCode ^ period.hashCode;
}

/// Estados posibles de una oferta de consumidor
enum ConsumerOfferStatus {
  /// Pendiente de liquidación (creada, esperando matching)
  pending,

  /// Liquidada y emparejada con prosumidor (100% satisfecha)
  matched,

  /// Parcialmente satisfecha (solo se cumplió parte del %)
  partialMatch,

  /// Expirada sin ser liquidada (venció el período)
  expired,

  /// Cancelada por consumidor o admin
  cancelled,
}

extension ConsumerOfferStatusExtension on ConsumerOfferStatus {
  /// Texto descriptivo del estado
  String get displayName {
    switch (this) {
      case ConsumerOfferStatus.pending:
        return 'Pendiente';
      case ConsumerOfferStatus.matched:
        return 'Liquidada';
      case ConsumerOfferStatus.partialMatch:
        return 'Parcialmente satisfecha';
      case ConsumerOfferStatus.expired:
        return 'Expirada';
      case ConsumerOfferStatus.cancelled:
        return 'Cancelada';
    }
  }

  /// Ícono asociado al estado
  String get icon {
    switch (this) {
      case ConsumerOfferStatus.pending:
        return '⏳';
      case ConsumerOfferStatus.matched:
        return '✅';
      case ConsumerOfferStatus.partialMatch:
        return '⚡';
      case ConsumerOfferStatus.expired:
        return '⏰';
      case ConsumerOfferStatus.cancelled:
        return '❌';
    }
  }

  /// Color asociado al estado
  String get colorHex {
    switch (this) {
      case ConsumerOfferStatus.pending:
        return '#FFA500'; // Orange
      case ConsumerOfferStatus.matched:
        return '#00C853'; // Green
      case ConsumerOfferStatus.partialMatch:
        return '#2196F3'; // Blue
      case ConsumerOfferStatus.expired:
        return '#9E9E9E'; // Grey
      case ConsumerOfferStatus.cancelled:
        return '#F44336'; // Red
    }
  }
}
