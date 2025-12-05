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
  });

  double get netBalance => energyGenerated - energyConsumed;
  double get selfConsumption => energyGenerated - energyExported;

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
    };
  }
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

  PDEAllocation({
    required this.id,
    required this.userId,
    required this.userName,
    required this.communityId,
    required this.excessEnergy,
    required this.allocatedEnergy,
    required this.sharePercentage,
    required this.allocationPeriod,
  });

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
