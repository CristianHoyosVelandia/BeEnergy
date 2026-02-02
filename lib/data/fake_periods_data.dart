/// Sistema de Períodos Parametrizables
///
/// Define los períodos mensuales disponibles en la aplicación,
/// diferenciando entre mes actual (con excedentes calculables) e históricos.
library;

import 'package:flutter/material.dart';
import '../core/theme/app_tokens.dart';

/// Estado de un período mensual
enum PeriodStatus {
  current,    // Mes actual (excedentes calculables)
  historical, // Mes histórico (datos cerrados)
  future,     // Mes futuro (no disponible)
}

/// Modelo de datos para un período mensual
class MonthPeriod {
  final String period;        // Formato: 'YYYY-MM'
  final String displayName;   // Ej: 'Enero 2026'
  final PeriodStatus status;
  final bool hasData;         // ¿Tiene datos disponibles?

  const MonthPeriod({
    required this.period,
    required this.displayName,
    required this.status,
    required this.hasData,
  });

  /// Obtiene el color asociado al estado del período
  Color getStatusColor() {
    switch (status) {
      case PeriodStatus.current:
        return AppTokens.primaryRed;
      case PeriodStatus.historical:
        return AppTokens.energyGreen;
      case PeriodStatus.future:
        return Colors.grey;
    }
  }

  /// Obtiene el ícono asociado al estado del período
  IconData getStatusIcon() {
    switch (status) {
      case PeriodStatus.current:
        return Icons.auto_awesome;
      case PeriodStatus.historical:
        return Icons.autorenew_rounded;
      case PeriodStatus.future:
        return Icons.lock_outline;
    }
  }

  /// Obtiene el texto descriptivo del estado
  String getStatusText() {
    switch (status) {
      case PeriodStatus.current:
        return hasData ? 'NUEVO MODELO' : 'MES ACTUAL';
      case PeriodStatus.historical:
        return 'MES CERRADO';
      case PeriodStatus.future:
        return 'NO DISPONIBLE';
    }
  }

  /// Verifica si este período tiene datos de excedentes calculables
  bool get canCalculateExcedentes => status == PeriodStatus.current && hasData;

  /// Verifica si este período es histórico con datos cerrados
  bool get isHistorical => status == PeriodStatus.historical && hasData;
}

/// Clase que gestiona los períodos disponibles en la aplicación
class FakePeriodsData {
  /// Mes actual de la simulación (Enero 2026)
  static const String currentPeriod = '2026-01';

  /// Períodos disponibles (últimos 6 meses desde actual)
  /// Orden: más reciente primero
  static final List<MonthPeriod> availablePeriods = [
    // Mes actual: Enero 2026 (Nuevo modelo P2P con PDE)
    MonthPeriod(
      period: '2026-01',
      displayName: 'Enero 2026',
      status: PeriodStatus.current,
      hasData: true,
    ),

    // Mes -1: Diciembre 2025 (Modelo antiguo P2P)
    MonthPeriod(
      period: '2025-12',
      displayName: 'Diciembre 2025',
      status: PeriodStatus.historical,
      hasData: true,
    ),

    // Mes -2: Noviembre 2025 (Histórico sin datos)
    MonthPeriod(
      period: '2025-11',
      displayName: 'Noviembre 2025',
      status: PeriodStatus.historical,
      hasData: false,
    ),
  ];

  /// Obtiene un período por su clave (YYYY-MM)
  static MonthPeriod? getPeriodByKey(String period) {
    try {
      return availablePeriods.firstWhere((p) => p.period == period);
    } catch (e) {
      return null;
    }
  }

  /// Obtiene el período actual
  static MonthPeriod get currentPeriodData {
    return availablePeriods.firstWhere(
      (p) => p.period == currentPeriod,
      orElse: () => availablePeriods.first,
    );
  }

  /// Obtiene solo los períodos con datos disponibles
  static List<MonthPeriod> get periodsWithData {
    return availablePeriods.where((p) => p.hasData).toList();
  }

  /// Obtiene solo los períodos históricos
  static List<MonthPeriod> get historicalPeriods {
    return availablePeriods.where((p) => p.status == PeriodStatus.historical).toList();
  }

  /// Verifica si un período es el actual
  static bool isCurrentPeriod(String period) {
    return period == currentPeriod;
  }

  /// Verifica si un período tiene datos disponibles
  static bool periodHasData(String period) {
    final periodData = getPeriodByKey(period);
    return periodData?.hasData ?? false;
  }

  /// Obtiene el índice de un período (para selección en UI)
  static int getPeriodIndex(String period) {
    return availablePeriods.indexWhere((p) => p.period == period);
  }

  /// Metadata adicional para cada período (opcional)
  static final Map<String, Map<String, dynamic>> periodMetadata = {
    '2026-01': {
      'model': 'Consumidores ofertan % del PDE',
      'pdeModel': 'Pagado (precio ofertado)',
      'priceRange': 'MC_m×1.1 a (Energía-Comercialización)×0.95 (330-693.5)',
      'liquidation': 'Matching manual por admin',
      'description': 'Nuevo modelo de mercado P2P basado en ofertas de consumidores',
    },
    '2025-12': {
      'model': 'Prosumidores publican ofertas',
      'pdeModel': 'Gratis (0 COP)',
      'priceRange': 'VE+10% a Tarifa-Transporte (495-550)',
      'liquidation': 'Aceptación directa',
      'description': 'Modelo antiguo de mercado P2P con ofertas de prosumidores',
    },
    '2025-11': {
      'model': 'Sin datos',
      'description': 'Período histórico sin datos de transacciones',
    },
  };

  /// Obtiene la metadata de un período
  static Map<String, dynamic>? getPeriodMetadata(String period) {
    return periodMetadata[period];
  }
}
