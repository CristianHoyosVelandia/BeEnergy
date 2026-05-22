class CommunityPriceReference {
  final int? id;
  final int? labelId;
  final String label;
  final String? code;
  final int? communityId;
  final String? period;
  final double value;
  final bool isActive;

  const CommunityPriceReference({
    this.id,
    this.labelId,
    required this.label,
    this.code,
    this.communityId,
    this.period,
    required this.value,
    required this.isActive,
  });

  factory CommunityPriceReference.fromJson(Map<String, dynamic> json) {
    return CommunityPriceReference(
      id: json['id'] as int?,
      labelId: json['label_id'] as int?,
      label: (json['label'] as String?) ?? '',
      code: json['code'] as String?,
      communityId: json['community_id'] as int?,
      period: json['period'] as String?,
      value: (json['value'] as num?)?.toDouble() ?? 0,
      isActive: (json['is_active'] as bool?) ?? false,
    );
  }
}
