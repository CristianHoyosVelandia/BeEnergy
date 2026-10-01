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
  final double gridPricePerKwh;
  final double userConsumptionKwh;
  final double amount;
  final int? offerId;
  final int? renunciationId;
  final bool paymentGatewayAvailable;
  final bool communityRightEnabled;
  final int? technicalProsumerUserId;
  final double pdeBaseRightPct;
  final double pdeFinalPct;
  final double pdeFreeRightKwh;
  final double communityGenerationKwh;
  final double pdePurchasedPct;
  final double pdeContributedPct;
  final double pdePurchasedKwh;
  final double pdeContributedKwh;
  final double rightSavingsValue;
  final double payableValue;
  final double receivableValue;
  final double traditionalBillValue;
  final double platformBillValue;
  final double savingsWithoutPlatform;
  final double savingsWithPlatform;
  final double additionalPlatformSavings;
  final String netPosition;

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
    required this.gridPricePerKwh,
    required this.userConsumptionKwh,
    required this.amount,
    this.offerId,
    this.renunciationId,
    required this.paymentGatewayAvailable,
    required this.communityRightEnabled,
    this.technicalProsumerUserId,
    required this.pdeBaseRightPct,
    required this.pdeFinalPct,
    required this.pdeFreeRightKwh,
    required this.communityGenerationKwh,
    required this.pdePurchasedPct,
    required this.pdeContributedPct,
    required this.pdePurchasedKwh,
    required this.pdeContributedKwh,
    required this.rightSavingsValue,
    required this.payableValue,
    required this.receivableValue,
    required this.traditionalBillValue,
    required this.platformBillValue,
    required this.savingsWithoutPlatform,
    required this.savingsWithPlatform,
    required this.additionalPlatformSavings,
    required this.netPosition,
  });

  bool get isCharge => mode == 'charge';
  bool get isCredit => mode == 'credit';
  bool get hasMovement => mode != 'none' && amount > 0;
  bool get isCommunityManagement => topology == 3;
  bool get hasCommunityRight => communityRightEnabled && pdeBaseRightPct > 0;
  bool get shouldPay => netPosition == 'pay' && payableValue > 0;
  bool get shouldReceive => netPosition == 'receive' && receivableValue > 0;

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
      gridPricePerKwh: (json['grid_price_per_kwh'] as num?)?.toDouble() ?? 0,
      userConsumptionKwh:
          (json['user_consumption_kwh'] as num?)?.toDouble() ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      offerId: json['offer_id'] as int?,
      renunciationId: json['renunciation_id'] as int?,
      paymentGatewayAvailable:
          json['payment_gateway_available'] as bool? ?? false,
      communityRightEnabled: json['community_right_enabled'] as bool? ?? false,
      technicalProsumerUserId: json['technical_prosumer_user_id'] as int?,
      pdeBaseRightPct: (json['pde_base_right_pct'] as num?)?.toDouble() ?? 0,
      pdeFinalPct: (json['pde_final_pct'] as num?)?.toDouble() ?? 0,
      pdeFreeRightKwh: (json['pde_free_right_kwh'] as num?)?.toDouble() ?? 0,
      communityGenerationKwh:
          (json['community_generation_kwh'] as num?)?.toDouble() ?? 0,
      pdePurchasedPct: (json['pde_purchased_pct'] as num?)?.toDouble() ?? 0,
      pdeContributedPct: (json['pde_contributed_pct'] as num?)?.toDouble() ?? 0,
      pdePurchasedKwh: (json['pde_purchased_kwh'] as num?)?.toDouble() ?? 0,
      pdeContributedKwh: (json['pde_contributed_kwh'] as num?)?.toDouble() ?? 0,
      rightSavingsValue: (json['right_savings_value'] as num?)?.toDouble() ?? 0,
      payableValue: (json['payable_value'] as num?)?.toDouble() ?? 0,
      receivableValue: (json['receivable_value'] as num?)?.toDouble() ?? 0,
      traditionalBillValue:
          (json['traditional_bill_value'] as num?)?.toDouble() ?? 0,
      platformBillValue: (json['platform_bill_value'] as num?)?.toDouble() ?? 0,
      savingsWithoutPlatform:
          (json['savings_without_platform'] as num?)?.toDouble() ?? 0,
      savingsWithPlatform:
          (json['savings_with_platform'] as num?)?.toDouble() ?? 0,
      additionalPlatformSavings:
          (json['additional_platform_savings'] as num?)?.toDouble() ?? 0,
      netPosition: json['net_position'] as String? ?? 'neutral',
    );
  }
}
