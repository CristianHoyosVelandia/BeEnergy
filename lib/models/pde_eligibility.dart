class PdeEligibility {
  final int userId;
  final int communityId;
  final String period;
  final int topologic;
  final int statusCode;
  final String phase;
  final String decision;
  final bool allowed;
  final bool manualEnabled;
  final double referenceKwh;
  final double consumptionKwh;
  final double generatedKwh;
  final double exportedKwh;
  final double importedKwh;
  final double deltaKwh;
  final double maxFinalPdePercentage;
  final bool hasContribution;
  final bool hasOffer;
  final String message;

  const PdeEligibility({
    required this.userId,
    required this.communityId,
    required this.period,
    required this.topologic,
    required this.statusCode,
    required this.phase,
    required this.decision,
    required this.allowed,
    required this.manualEnabled,
    required this.referenceKwh,
    required this.consumptionKwh,
    required this.generatedKwh,
    required this.exportedKwh,
    required this.importedKwh,
    required this.deltaKwh,
    required this.maxFinalPdePercentage,
    required this.hasContribution,
    required this.hasOffer,
    required this.message,
  });

  factory PdeEligibility.fromJson(Map<String, dynamic> json) {
    return PdeEligibility(
      userId: json['user_id'] as int? ?? 0,
      communityId: json['community_id'] as int? ?? 0,
      period: json['period'] as String? ?? '',
      topologic: json['topologic'] as int? ?? 0,
      statusCode: json['status_code'] as int? ?? 0,
      phase: json['phase'] as String? ?? '',
      decision: json['decision'] as String? ?? '',
      allowed: json['allowed'] as bool? ?? true,
      manualEnabled: json['manual_enabled'] as bool? ?? true,
      referenceKwh: (json['reference_kwh'] as num?)?.toDouble() ?? 0,
      consumptionKwh: (json['consumption_kwh'] as num?)?.toDouble() ?? 0,
      generatedKwh: (json['generated_kwh'] as num?)?.toDouble() ?? 0,
      exportedKwh: (json['exported_kwh'] as num?)?.toDouble() ?? 0,
      importedKwh: (json['imported_kwh'] as num?)?.toDouble() ?? 0,
      deltaKwh: (json['delta_kwh'] as num?)?.toDouble() ?? 0,
      maxFinalPdePercentage:
          (json['max_final_pde_percentage'] as num?)?.toDouble() ?? 9.99,
      hasContribution: json['has_contribution'] as bool? ?? false,
      hasOffer: json['has_offer'] as bool? ?? false,
      message: json['message'] as String? ?? '',
    );
  }
}
