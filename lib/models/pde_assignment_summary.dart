class PdeAssignmentSummary {
  final int communityId;
  final int userId;
  final String period;
  final bool hasAssignmentDetail;
  final double pdeInicial;
  final double pdeCambio;
  final double pdeFinalAsignado;
  final double pdeFinalKwh;
  final double changedKwh;
  final String? source;

  const PdeAssignmentSummary({
    required this.communityId,
    required this.userId,
    required this.period,
    required this.hasAssignmentDetail,
    required this.pdeInicial,
    required this.pdeCambio,
    required this.pdeFinalAsignado,
    required this.pdeFinalKwh,
    required this.changedKwh,
    this.source,
  });

  factory PdeAssignmentSummary.fromJson(Map<String, dynamic> json) {
    return PdeAssignmentSummary(
      communityId: json['community_id'] as int,
      userId: json['user_id'] as int,
      period: json['period'] as String,
      hasAssignmentDetail: json['has_assignment_detail'] as bool? ?? false,
      pdeInicial: (json['pde_inicial'] as num? ?? 0).toDouble(),
      pdeCambio: (json['pde_cambio'] as num? ?? 0).toDouble(),
      pdeFinalAsignado: (json['pde_final_asignado'] as num? ?? 0).toDouble(),
      pdeFinalKwh: (json['pde_final_kwh'] as num? ?? 0).toDouble(),
      changedKwh: (json['changed_kwh'] as num? ?? 0).toDouble(),
      source: json['source'] as String?,
    );
  }

  bool get aportoPde => pdeCambio < 0;

  String get cambioLabel => aportoPde ? 'Total aportado' : 'Adicional asignado';

  double get cambioAbsoluto => pdeCambio.abs();
}
