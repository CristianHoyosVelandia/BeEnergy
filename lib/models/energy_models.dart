// Modelos para Registros Energéticos
// Basado en la tesis de Cristian Hoyos y Esteban Viveros

class EnergyRecord {
  final int id;
  final int userId;
  final String userName;
  final int communityId;
  final double energyGenerated; // kWh
  final double energyConsumed; // kWh
  final double energyExported; // kWh
  final double energyImported; // kWh
  final String period; // Formato: 'YYYY-MM' (ej: '2025-11')

  // ⭐ NUEVO: Clasificación CREG 101 072
  final double surplusType1; // kWh - Autoconsumo compensado (NO vendible)
  final double surplusType2; // kWh - Disponible para PDE y P2P
  final SurplusClassificationType classification;

  EnergyRecord({
    required this.id,
    required this.userId,
    required this.userName,
    required this.communityId,
    required this.energyGenerated,
    required this.energyConsumed,
    required this.energyExported,
    required this.energyImported,
    required this.period,
    this.surplusType1 = 0.0,
    this.surplusType2 = 0.0,
    this.classification = SurplusClassificationType.none,
  });

  double get netBalance => energyGenerated - energyConsumed;
  double get selfConsumption => energyGenerated - energyExported;
  double get totalSurplus => energyGenerated - energyConsumed;

  /// Verifica que la clasificación Tipo1 + Tipo2 = Total excedente
  bool get hasValidClassification {
    if (totalSurplus <= 0) return surplusType1 == 0 && surplusType2 == 0;
    return (surplusType1 + surplusType2 - totalSurplus).abs() < 0.01;
  }

  factory EnergyRecord.fromJson(Map<String, dynamic> json) {
    return EnergyRecord(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      userName: json['user_name'] as String,
      communityId: json['community_id'] as int,
      energyGenerated: (json['energy_generated'] as num).toDouble(),
      energyConsumed: (json['energy_consumed'] as num).toDouble(),
      energyExported: (json['energy_exported'] as num).toDouble(),
      energyImported: (json['energy_imported'] as num).toDouble(),
      period: json['period'] as String,
      surplusType1: (json['surplus_type1'] as num?)?.toDouble() ?? 0.0,
      surplusType2: (json['surplus_type2'] as num?)?.toDouble() ?? 0.0,
      classification: json['classification'] != null
          ? SurplusClassificationType.values.firstWhere(
              (e) => e.name == json['classification'],
              orElse: () => SurplusClassificationType.none,
            )
          : SurplusClassificationType.none,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'community_id': communityId,
      'energy_generated': energyGenerated,
      'energy_consumed': energyConsumed,
      'energy_exported': energyExported,
      'energy_imported': energyImported,
      'period': period,
      'surplus_type1': surplusType1,
      'surplus_type2': surplusType2,
      'classification': classification.name,
    };
  }
}

/// Tipo de clasificación de excedentes según CREG 101 072
enum SurplusClassificationType {
  /// Solo Tipo 1 (autoconsumo compensado)
  type1Only,

  /// Solo Tipo 2 (disponible para mercado)
  type2Only,

  /// Ambos tipos (mixto - caso normal 50/50)
  mixed,

  /// Sin excedentes
  none,
}

class PDEAllocation {
  final int id;
  final int userId;
  final String userName;
  final int communityId;
  final double excessEnergy; // Excedentes aportados al PDE
  final double allocatedEnergy; // Energía asignada del PDE
  final double sharePercentage; // Porcentaje de participación (0.0 - 1.0)
  final String allocationPeriod; // Formato: 'YYYY-MM'

  // ⭐ NUEVO: Campos regulatorios CREG 101 072
  final double surplusType2Only; // Solo Tipo 2 (base para calcular PDE)
  final bool isPDECompliant; // Cumple límite ≤10%
  final String regulationArticle; // Artículo CREG aplicable

  PDEAllocation({
    required this.id,
    required this.userId,
    required this.userName,
    required this.communityId,
    required this.excessEnergy,
    required this.allocatedEnergy,
    required this.sharePercentage,
    required this.allocationPeriod,
    this.surplusType2Only = 0.0,
    this.isPDECompliant = true,
    this.regulationArticle = 'CREG 101 072 Art 3.4',
  });

  /// Verifica si cumple límite regulatorio PDE ≤10%
  bool get meetsRegulatoryLimit => sharePercentage <= 0.10;

  factory PDEAllocation.fromJson(Map<String, dynamic> json) {
    return PDEAllocation(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      userName: json['user_name'] as String,
      communityId: json['community_id'] as int,
      excessEnergy: (json['excess_energy'] as num).toDouble(),
      allocatedEnergy: (json['allocated_energy'] as num).toDouble(),
      sharePercentage: (json['share_percentage'] as num).toDouble(),
      allocationPeriod: json['allocation_period'] as String,
      surplusType2Only: (json['surplus_type2_only'] as num?)?.toDouble() ?? 0.0,
      isPDECompliant: json['is_pde_compliant'] as bool? ?? true,
      regulationArticle: json['regulation_article'] as String? ?? 'CREG 101 072 Art 3.4',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'community_id': communityId,
      'excess_energy': excessEnergy,
      'allocated_energy': allocatedEnergy,
      'share_percentage': sharePercentage,
      'allocation_period': allocationPeriod,
      'surplus_type2_only': surplusType2Only,
      'is_pde_compliant': isPDECompliant,
      'regulation_article': regulationArticle,
    };
  }
}

/// Datos para gráficos de energía por hora
class HourlyEnergyData {
  final int hour;
  final double generation;
  final double consumption;

  HourlyEnergyData({
    required this.hour,
    required this.generation,
    required this.consumption,
  });
}

/// Datos para gráficos de energía por día
class DailyEnergyData {
  final int day;
  final double imported;
  final double exported;
  final double demand;

  DailyEnergyData({
    required this.day,
    required this.imported,
    required this.exported,
    required this.demand,
  });
}
