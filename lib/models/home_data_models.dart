/// Modelos tipo-seguro para Home Screen
/// Encapsula todos los datos necesarios para el home screen
/// Facilita el cambio entre fake data y web services

import 'package:be_energy/models/community_models.dart';
import 'package:be_energy/models/p2p_models.dart';

/// Datos completos para renderizar el home screen
class HomeScreenData {
  final String selectedPeriod;
  final PeriodInfo periodInfo;
  final ViewType viewType;
  final UserProfile userProfile;
  final EnergyStatistics energyStats;
  final List<TransactionItem> recentTransactions;
  final List<PriceReference>? priceReferences;
  final PDEInfo? pdeInfo;

  HomeScreenData({
    required this.selectedPeriod,
    required this.periodInfo,
    required this.viewType,
    required this.userProfile,
    required this.energyStats,
    required this.recentTransactions,
    this.priceReferences,
    this.pdeInfo,
  });

  /// Indica si es el período actual
  bool get isCurrentPeriod => periodInfo.isCurrent;

  /// Indica si es vista de administrador
  bool get isAdminView => viewType == ViewType.admin;

  factory HomeScreenData.fromJson(Map<String, dynamic> json) {
    return HomeScreenData(
      selectedPeriod: json['selected_period'] as String,
      periodInfo: PeriodInfo.fromJson(json['period_info'] as Map<String, dynamic>),
      viewType: ViewType.values.firstWhere(
        (e) => e.name == json['view_type'],
        orElse: () => ViewType.user,
      ),
      userProfile: UserProfile.fromJson(json['user_profile'] as Map<String, dynamic>),
      energyStats: EnergyStatistics.fromJson(json['energy_stats'] as Map<String, dynamic>),
      recentTransactions: (json['recent_transactions'] as List<dynamic>)
          .map((e) => TransactionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      priceReferences: json['price_references'] != null
          ? (json['price_references'] as List<dynamic>)
              .map((e) => PriceReference.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      pdeInfo: json['pde_info'] != null
          ? PDEInfo.fromJson(json['pde_info'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selected_period': selectedPeriod,
      'period_info': periodInfo.toJson(),
      'view_type': viewType.name,
      'user_profile': userProfile.toJson(),
      'energy_stats': energyStats.toJson(),
      'recent_transactions': recentTransactions.map((e) => e.toJson()).toList(),
      'price_references': priceReferences?.map((e) => e.toJson()).toList(),
      'pde_info': pdeInfo?.toJson(),
    };
  }
}

/// Tipo de vista: Admin o Usuario
enum ViewType {
  admin,
  user,
}

/// Información del período seleccionado
class PeriodInfo {
  final String period; // 'YYYY-MM'
  final String displayName; // 'Enero 2026'
  final bool isCurrent;
  final bool hasData;
  final PeriodStatus status;
  final String? description;

  PeriodInfo({
    required this.period,
    required this.displayName,
    required this.isCurrent,
    required this.hasData,
    required this.status,
    this.description,
  });

  factory PeriodInfo.fromJson(Map<String, dynamic> json) {
    return PeriodInfo(
      period: json['period'] as String,
      displayName: json['display_name'] as String,
      isCurrent: json['is_current'] as bool,
      hasData: json['has_data'] as bool,
      status: PeriodStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PeriodStatus.historical,
      ),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'display_name': displayName,
      'is_current': isCurrent,
      'has_data': hasData,
      'status': status.name,
      'description': description,
    };
  }
}

/// Estado del período
enum PeriodStatus {
  current,
  historical,
  future,
}

/// Perfil del usuario
class UserProfile {
  final int userId;
  final String userName;
  final String userLastName;
  final String role; // 'consumer', 'prosumer', 'admin'
  final int totalMembers; // Para vista admin: total de miembros

  UserProfile({
    required this.userId,
    required this.userName,
    required this.userLastName,
    required this.role,
    required this.totalMembers,
  });

  String get fullName => '$userName $userLastName';

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'] as int,
      userName: json['user_name'] as String,
      userLastName: json['user_last_name'] as String,
      role: json['role'] as String,
      totalMembers: json['total_members'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'user_last_name': userLastName,
      'role': role,
      'total_members': totalMembers,
    };
  }
}

/// Estadísticas de energía para el gráfico circular
class EnergyStatistics {
  final double solarDirect; // kWh generación solar directa
  final double gridImport; // kWh importación de red
  final double p2pExchanges; // kWh intercambios P2P
  final double totalImported; // kWh total importado (para tarjeta)
  final double totalExported; // kWh total exportado (para tarjeta)
  final double? solarAutoconsumption; // kWh autoconsumo solar (opcional)
  final double? totalSurplus; // kWh excedentes totales (opcional)
  final double costPerKwh; // COP/kWh

  EnergyStatistics({
    required this.solarDirect,
    required this.gridImport,
    required this.p2pExchanges,
    required this.totalImported,
    required this.totalExported,
    required this.costPerKwh,
    this.solarAutoconsumption,
    this.totalSurplus,
  });

  /// Datos para el gráfico circular
  List<ChartDataPoint> get chartData => [
        ChartDataPoint(label: 'Directa Solar', value: solarDirect),
        ChartDataPoint(label: 'Red', value: gridImport),
        ChartDataPoint(label: 'Intercambios P2P', value: p2pExchanges),
      ];

  factory EnergyStatistics.fromJson(Map<String, dynamic> json) {
    return EnergyStatistics(
      solarDirect: (json['solar_direct'] as num).toDouble(),
      gridImport: (json['grid_import'] as num).toDouble(),
      p2pExchanges: (json['p2p_exchanges'] as num).toDouble(),
      totalImported: (json['total_imported'] as num).toDouble(),
      totalExported: (json['total_exported'] as num).toDouble(),
      costPerKwh: (json['cost_per_kwh'] as num).toDouble(),
      solarAutoconsumption: json['solar_autoconsumption'] != null
          ? (json['solar_autoconsumption'] as num).toDouble()
          : null,
      totalSurplus: json['total_surplus'] != null
          ? (json['total_surplus'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'solar_direct': solarDirect,
      'grid_import': gridImport,
      'p2p_exchanges': p2pExchanges,
      'total_imported': totalImported,
      'total_exported': totalExported,
      'cost_per_kwh': costPerKwh,
      'solar_autoconsumption': solarAutoconsumption,
      'total_surplus': totalSurplus,
    };
  }
}

/// Punto de datos para el gráfico circular
class ChartDataPoint {
  final String label;
  final double value;

  ChartDataPoint({
    required this.label,
    required this.value,
  });
}

/// Item de transacción para el listado
class TransactionItem {
  final int id;
  final bool isIncome; // true = ingreso, false = egreso
  final String counterpartyName; // Nombre de la contraparte
  final double amount; // COP
  final double energy; // kWh
  final String date; // Fecha formateada
  final TransactionSource source; // P2P o PDE

  TransactionItem({
    required this.id,
    required this.isIncome,
    required this.counterpartyName,
    required this.amount,
    required this.energy,
    required this.date,
    required this.source,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json['id'] as int,
      isIncome: json['is_income'] as bool,
      counterpartyName: json['counterparty_name'] as String,
      amount: (json['amount'] as num).toDouble(),
      energy: (json['energy'] as num).toDouble(),
      date: json['date'] as String,
      source: TransactionSource.values.firstWhere(
        (e) => e.name == json['source'],
        orElse: () => TransactionSource.p2p,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'is_income': isIncome,
      'counterparty_name': counterpartyName,
      'amount': amount,
      'energy': energy,
      'date': date,
      'source': source.name,
    };
  }
}

/// Fuente de la transacción
enum TransactionSource {
  p2p,
  pde,
}

/// Referencia de precio (solo para admin)
class PriceReference {
  final String label;
  final double value; // COP/kWh

  PriceReference({
    required this.label,
    required this.value,
  });

  factory PriceReference.fromJson(Map<String, dynamic> json) {
    return PriceReference(
      label: json['label'] as String,
      value: (json['value'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
    };
  }
}

/// Información del PDE (Programa de Distribución de Excedentes)
class PDEInfo {
  final double totalAvailable; // kWh disponibles
  final double minPrice; // COP/kWh
  final double maxPrice; // COP/kWh
  final String prosumerName;

  PDEInfo({
    required this.totalAvailable,
    required this.minPrice,
    required this.maxPrice,
    required this.prosumerName,
  });

  factory PDEInfo.fromJson(Map<String, dynamic> json) {
    return PDEInfo(
      totalAvailable: (json['total_available'] as num).toDouble(),
      minPrice: (json['min_price'] as num).toDouble(),
      maxPrice: (json['max_price'] as num).toDouble(),
      prosumerName: json['prosumer_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_available': totalAvailable,
      'min_price': minPrice,
      'max_price': maxPrice,
      'prosumer_name': prosumerName,
    };
  }
}

/// Lista de períodos disponibles
class AvailablePeriods {
  final List<PeriodInfo> periods;
  final String currentPeriod;

  AvailablePeriods({
    required this.periods,
    required this.currentPeriod,
  });

  factory AvailablePeriods.fromJson(Map<String, dynamic> json) {
    return AvailablePeriods(
      periods: (json['periods'] as List<dynamic>)
          .map((e) => PeriodInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPeriod: json['current_period'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'periods': periods.map((e) => e.toJson()).toList(),
      'current_period': currentPeriod,
    };
  }
}
