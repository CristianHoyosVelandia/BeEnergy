/// Sesión de liquidación mensual P2P (Enero 2026+)
///
/// El administrador crea una sesión para hacer el matching manual entre
/// ofertas de consumidores y energía disponible de prosumidores.
///
/// El proceso es:
/// 1. Admin crea sesión → calcula PDE disponible
/// 2. Admin ve ofertas de consumidores y energía de prosumidores
/// 3. Admin hace matching manual (puede ser parcial)
/// 4. Admin finaliza sesión → se generan contratos P2P
class LiquidationSession {
  final int id;
  final String period; // Formato: 'YYYY-MM'
  final int communityId;
  final int adminUserId;

  final LiquidationMode mode; // manual | automatic (futuro IA)
  final LiquidationStatus status;

  /// Snapshot de PDE total disponible al momento de crear la sesión (kWh)
  final double totalPDEAvailable;

  /// IDs de ofertas de consumidores consideradas en esta sesión
  final List<int> consumerOfferIds;

  /// Resultados del matching (matches creados)
  final List<LiquidationMatch> matches;

  final DateTime createdAt;
  final DateTime? completedAt;

  // Estadísticas de la sesión
  final int totalOffersProcessed;
  final int totalMatchesCreated;
  final double totalEnergyMatched; // kWh
  final double matchingEfficiency; // % de ofertas satisfechas (0.0-1.0)

  const LiquidationSession({
    required this.id,
    required this.period,
    required this.communityId,
    required this.adminUserId,
    required this.mode,
    required this.status,
    required this.totalPDEAvailable,
    required this.consumerOfferIds,
    required this.matches,
    required this.createdAt,
    this.completedAt,
    this.totalOffersProcessed = 0,
    this.totalMatchesCreated = 0,
    this.totalEnergyMatched = 0.0,
    this.matchingEfficiency = 0.0,
  });

  /// Verifica si la sesión puede finalizarse
  bool get canFinalize {
    return status == LiquidationStatus.inProgress && matches.isNotEmpty;
  }

  /// Verifica si la sesión está activa (puede recibir más matches)
  bool get isActive {
    return status == LiquidationStatus.draft ||
           status == LiquidationStatus.inProgress;
  }

  /// Obtiene el total de valor de los matches (COP)
  double get totalValue {
    return matches.fold(
      0.0,
      (sum, match) => sum + (match.energyKwh * match.pricePerKwh),
    );
  }

  /// Crea una copia de la sesión con campos modificados
  LiquidationSession copyWith({
    int? id,
    String? period,
    int? communityId,
    int? adminUserId,
    LiquidationMode? mode,
    LiquidationStatus? status,
    double? totalPDEAvailable,
    List<int>? consumerOfferIds,
    List<LiquidationMatch>? matches,
    DateTime? createdAt,
    DateTime? completedAt,
    int? totalOffersProcessed,
    int? totalMatchesCreated,
    double? totalEnergyMatched,
    double? matchingEfficiency,
  }) {
    return LiquidationSession(
      id: id ?? this.id,
      period: period ?? this.period,
      communityId: communityId ?? this.communityId,
      adminUserId: adminUserId ?? this.adminUserId,
      mode: mode ?? this.mode,
      status: status ?? this.status,
      totalPDEAvailable: totalPDEAvailable ?? this.totalPDEAvailable,
      consumerOfferIds: consumerOfferIds ?? this.consumerOfferIds,
      matches: matches ?? this.matches,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      totalOffersProcessed: totalOffersProcessed ?? this.totalOffersProcessed,
      totalMatchesCreated: totalMatchesCreated ?? this.totalMatchesCreated,
      totalEnergyMatched: totalEnergyMatched ?? this.totalEnergyMatched,
      matchingEfficiency: matchingEfficiency ?? this.matchingEfficiency,
    );
  }

  /// Convierte el modelo a Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'period': period,
      'communityId': communityId,
      'adminUserId': adminUserId,
      'mode': mode.name,
      'status': status.name,
      'totalPDEAvailable': totalPDEAvailable,
      'consumerOfferIds': consumerOfferIds,
      'matches': matches.map((m) => m.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'totalOffersProcessed': totalOffersProcessed,
      'totalMatchesCreated': totalMatchesCreated,
      'totalEnergyMatched': totalEnergyMatched,
      'matchingEfficiency': matchingEfficiency,
    };
  }

  /// Crea una instancia desde Map
  factory LiquidationSession.fromJson(Map<String, dynamic> json) {
    return LiquidationSession(
      id: json['id'] as int,
      period: json['period'] as String,
      communityId: json['communityId'] as int,
      adminUserId: json['adminUserId'] as int,
      mode: LiquidationMode.values.firstWhere(
        (e) => e.name == json['mode'],
        orElse: () => LiquidationMode.manual,
      ),
      status: LiquidationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => LiquidationStatus.draft,
      ),
      totalPDEAvailable: (json['totalPDEAvailable'] as num).toDouble(),
      consumerOfferIds: List<int>.from(json['consumerOfferIds'] as List),
      matches: (json['matches'] as List)
          .map((m) => LiquidationMatch.fromJson(m as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      totalOffersProcessed: json['totalOffersProcessed'] as int? ?? 0,
      totalMatchesCreated: json['totalMatchesCreated'] as int? ?? 0,
      totalEnergyMatched: (json['totalEnergyMatched'] as num?)?.toDouble() ?? 0.0,
      matchingEfficiency: (json['matchingEfficiency'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  String toString() {
    return 'LiquidationSession(id: $id, period: $period, status: $status, matches: ${matches.length})';
  }
}

/// Modo de liquidación
enum LiquidationMode {
  /// Matching manual por administrador (Enero 2026)
  manual,

  /// Matching automático por IA (FUTURO)
  automatic,
}

/// Estados de una sesión de liquidación
enum LiquidationStatus {
  /// Sesión creada pero no iniciada
  draft,

  /// Admin está haciendo matching activamente
  inProgress,

  /// Finalizada - contratos generados
  completed,

  /// Cancelada sin completar
  cancelled,
}

extension LiquidationStatusExtension on LiquidationStatus {
  String get displayName {
    switch (this) {
      case LiquidationStatus.draft:
        return 'Borrador';
      case LiquidationStatus.inProgress:
        return 'En Progreso';
      case LiquidationStatus.completed:
        return 'Completada';
      case LiquidationStatus.cancelled:
        return 'Cancelada';
    }
  }

  String get icon {
    switch (this) {
      case LiquidationStatus.draft:
        return '📝';
      case LiquidationStatus.inProgress:
        return '⚙️';
      case LiquidationStatus.completed:
        return '✅';
      case LiquidationStatus.cancelled:
        return '❌';
    }
  }
}

/// Representa un emparejamiento individual entre oferta de consumidor y prosumidor
class LiquidationMatch {
  final int consumerOfferId;
  final int buyerId;
  final String buyerName;

  final int prosumerId;
  final String prosumerName;

  /// Energía asignada en kWh (puede ser menor a la solicitada)
  final double energyKwh;

  /// Precio acordado (viene de la oferta del consumidor)
  final double pricePerKwh;

  /// Porcentaje del PDE que se cumplió (0.0-1.0)
  /// 1.0 = 100% satisfecho, 0.5 = 50% satisfecho
  final double pdePercentageFulfilled;

  final DateTime matchedAt;

  const LiquidationMatch({
    required this.consumerOfferId,
    required this.buyerId,
    required this.buyerName,
    required this.prosumerId,
    required this.prosumerName,
    required this.energyKwh,
    required this.pricePerKwh,
    required this.pdePercentageFulfilled,
    required this.matchedAt,
  });

  /// Valor total del match (COP)
  double get totalValue => energyKwh * pricePerKwh;

  /// Convierte el modelo a Map
  Map<String, dynamic> toJson() {
    return {
      'consumerOfferId': consumerOfferId,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'prosumerId': prosumerId,
      'prosumerName': prosumerName,
      'energyKwh': energyKwh,
      'pricePerKwh': pricePerKwh,
      'pdePercentageFulfilled': pdePercentageFulfilled,
      'matchedAt': matchedAt.toIso8601String(),
    };
  }

  /// Crea una instancia desde Map
  factory LiquidationMatch.fromJson(Map<String, dynamic> json) {
    return LiquidationMatch(
      consumerOfferId: json['consumerOfferId'] as int,
      buyerId: json['buyerId'] as int,
      buyerName: json['buyerName'] as String,
      prosumerId: json['prosumerId'] as int,
      prosumerName: json['prosumerName'] as String,
      energyKwh: (json['energyKwh'] as num).toDouble(),
      pricePerKwh: (json['pricePerKwh'] as num).toDouble(),
      pdePercentageFulfilled: (json['pdePercentageFulfilled'] as num).toDouble(),
      matchedAt: DateTime.parse(json['matchedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'LiquidationMatch($buyerName ← $prosumerName: ${energyKwh.toStringAsFixed(2)} kWh @ $pricePerKwh COP/kWh)';
  }
}

/// Snapshot de disponibilidad de PDE para un período
class PDEAvailabilitySnapshot {
  final String period;
  final double totalType2; // kWh Tipo 2 totales
  final double pdeMaxAllowed; // 10% del Tipo 2
  final double pdeAlreadyAllocated; // Ya asignado en períodos anteriores
  final double pdeAvailableForLiquidation; // Disponible ahora

  /// Contribuciones de prosumidores al PDE
  final Map<int, double> prosumerContributions; // userId → kWh

  const PDEAvailabilitySnapshot({
    required this.period,
    required this.totalType2,
    required this.pdeMaxAllowed,
    required this.pdeAlreadyAllocated,
    required this.pdeAvailableForLiquidation,
    required this.prosumerContributions,
  });

  /// Porcentaje del PDE máximo que está disponible (0.0-1.0)
  double get availabilityPercentage {
    if (pdeMaxAllowed == 0) return 0.0;
    return pdeAvailableForLiquidation / pdeMaxAllowed;
  }

  /// Verifica si cumple el límite regulatorio (≤10%)
  bool get isCompliant {
    if (totalType2 == 0) return true;
    return (pdeMaxAllowed / totalType2) <= 0.10;
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'totalType2': totalType2,
      'pdeMaxAllowed': pdeMaxAllowed,
      'pdeAlreadyAllocated': pdeAlreadyAllocated,
      'pdeAvailableForLiquidation': pdeAvailableForLiquidation,
      'prosumerContributions': prosumerContributions,
    };
  }

  factory PDEAvailabilitySnapshot.fromJson(Map<String, dynamic> json) {
    return PDEAvailabilitySnapshot(
      period: json['period'] as String,
      totalType2: (json['totalType2'] as num).toDouble(),
      pdeMaxAllowed: (json['pdeMaxAllowed'] as num).toDouble(),
      pdeAlreadyAllocated: (json['pdeAlreadyAllocated'] as num).toDouble(),
      pdeAvailableForLiquidation: (json['pdeAvailableForLiquidation'] as num).toDouble(),
      prosumerContributions: Map<int, double>.from(
        (json['prosumerContributions'] as Map).map(
          (k, v) => MapEntry(int.parse(k.toString()), (v as num).toDouble()),
        ),
      ),
    );
  }
}
