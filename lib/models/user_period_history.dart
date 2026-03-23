import 'package:flutter/material.dart';
import '../core/theme/app_tokens.dart';

/// Resumen de datos energéticos de un período
class EnergyRecordSummary {
  final double energyGenerated;
  final double energyConsumed;
  final double energyExported;
  final double energyImported;

  EnergyRecordSummary({
    required this.energyGenerated,
    required this.energyConsumed,
    required this.energyExported,
    required this.energyImported,
  });

  factory EnergyRecordSummary.fromJson(Map<String, dynamic> json) {
    return EnergyRecordSummary(
      energyGenerated: (json['energy_generated'] as num).toDouble(),
      energyConsumed: (json['energy_consumed'] as num).toDouble(),
      energyExported: (json['energy_exported'] as num).toDouble(),
      energyImported: (json['energy_imported'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'energy_generated': energyGenerated,
      'energy_consumed': energyConsumed,
      'energy_exported': energyExported,
      'energy_imported': energyImported,
    };
  }
}

/// Item individual de un período en el historial del usuario
class UserPeriodItem {
  final String period;
  final String displayName;
  final String status;              // "current" | "historical"
  final bool hasData;
  final int pdeStatusCode;
  final bool pdeAvailable;
  final EnergyRecordSummary energyRecord;

  UserPeriodItem({
    required this.period,
    required this.displayName,
    required this.status,
    required this.hasData,
    required this.pdeStatusCode,
    required this.pdeAvailable,
    required this.energyRecord,
  });

  factory UserPeriodItem.fromJson(Map<String, dynamic> json) {
    return UserPeriodItem(
      period: json['period'],
      displayName: json['display_name'],
      status: json['status'],
      hasData: json['has_data'],
      pdeStatusCode: json['pde_status_code'],
      pdeAvailable: json['pde_available'],
      energyRecord: EnergyRecordSummary.fromJson(json['energy_record']),
    );
  }

  /// Métodos de compatibilidad con MonthPeriod de FakePeriodsData
  bool get isCurrentPeriod => status == 'current';
  bool get isPDEAvailable => pdeAvailable;

  /// Obtiene el color asociado al estado del período
  Color getStatusColor() {
    return isCurrentPeriod ? AppTokens.primaryRed : AppTokens.energyGreen;
  }

  /// Obtiene el ícono asociado al estado del período
  IconData getStatusIcon() {
    return isCurrentPeriod ? Icons.auto_awesome : Icons.autorenew_rounded;
  }

  /// Obtiene el badge asociado al estado
  String getStatusBadge() {
    return isCurrentPeriod ? '✨' : '🔄';
  }

  /// Obtiene el texto descriptivo del estado
  String getStatusText() {
    return isCurrentPeriod ? 'NUEVO MODELO' : 'MES CERRADO';
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'display_name': displayName,
      'status': status,
      'has_data': hasData,
      'pde_status_code': pdeStatusCode,
      'pde_available': pdeAvailable,
      'energy_record': energyRecord.toJson(),
    };
  }
}

/// Historial de períodos del usuario
class UserPeriodHistory {
  final String currentPeriod;
  final List<UserPeriodItem> periods;
  final int totalPeriods;

  UserPeriodHistory({
    required this.currentPeriod,
    required this.periods,
    required this.totalPeriods,
  });

  factory UserPeriodHistory.fromJson(Map<String, dynamic> json) {
    return UserPeriodHistory(
      currentPeriod: json['current_period'],
      periods: (json['periods'] as List)
          .map((item) => UserPeriodItem.fromJson(item))
          .toList(),
      totalPeriods: json['total_periods'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_period': currentPeriod,
      'periods': periods.map((p) => p.toJson()).toList(),
      'total_periods': totalPeriods,
    };
  }

  /// Obtiene un período por su clave (YYYY-MM)
  UserPeriodItem? getPeriodByKey(String period) {
    try {
      return periods.firstWhere((p) => p.period == period);
    } catch (e) {
      return null;
    }
  }
}
