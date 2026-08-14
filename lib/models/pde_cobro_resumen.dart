class PdeCobroResumen {
  final int communityId;
  final String period;
  final int topology;
  final int statusCode;
  final String mode;
  final String source;
  final double pdeAppliedPct;
  final double pdeTransactedPct;
  final double energyKwh;
  final double pricePerKwh;
  final double referencePricePerKwh;
  final double amount;
  final int? offerId;
  final int? renunciationId;
  final bool paymentGatewayAvailable;

  const PdeCobroResumen({
    required this.communityId,
    required this.period,
    required this.topology,
    required this.statusCode,
    required this.mode,
    required this.source,
    required this.pdeAppliedPct,
    required this.pdeTransactedPct,
    required this.energyKwh,
    required this.pricePerKwh,
    required this.referencePricePerKwh,
    required this.amount,
    this.offerId,
    this.renunciationId,
    required this.paymentGatewayAvailable,
  });

  bool get isCharge => mode == 'charge';
  bool get isCredit => mode == 'credit';
  bool get hasMovement => mode != 'none' && amount > 0;
  bool get isCommunityManagement => topology == 3;

  factory PdeCobroResumen.fromJson(Map<String, dynamic> json) {
    return PdeCobroResumen(
      communityId: json['community_id'] as int,
      period: json['period'] as String,
      topology: json['topology'] as int? ?? 0,
      statusCode: json['status_code'] as int? ?? 0,
      mode: json['mode'] as String? ?? 'none',
      source: json['source'] as String? ?? 'sin_movimiento',
      pdeAppliedPct: (json['pde_applied_pct'] as num?)?.toDouble() ?? 0,
      pdeTransactedPct: (json['pde_transacted_pct'] as num?)?.toDouble() ?? 0,
      energyKwh: (json['energy_kwh'] as num?)?.toDouble() ?? 0,
      pricePerKwh: (json['price_per_kwh'] as num?)?.toDouble() ?? 0,
      referencePricePerKwh:
          (json['reference_price_per_kwh'] as num?)?.toDouble() ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      offerId: json['offer_id'] as int?,
      renunciationId: json['renunciation_id'] as int?,
      paymentGatewayAvailable:
          json['payment_gateway_available'] as bool? ?? false,
    );
  }
}
