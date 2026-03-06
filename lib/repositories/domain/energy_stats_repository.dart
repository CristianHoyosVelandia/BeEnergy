/// Repositorio para estadísticas de energía
/// Maneja datos de consumo, generación y distribución de energía
library;

import 'package:be_energy/models/home_data_models.dart';

/// Interfaz abstracta para el repositorio de estadísticas de energía
abstract class EnergyStatsRepository {
  /// Obtiene las estadísticas de energía para un período y usuario
  ///
  /// [period] - Período en formato 'YYYY-MM' (ej: '2026-01')
  /// [viewType] - Tipo de vista (admin: comunidad agregada, user: individual)
  /// [userId] - ID del usuario (usado en vista user)
  Future<EnergyStatistics> getStatistics({
    required String period,
    required ViewType viewType,
    required int userId,
  });

  /// Obtiene los datos del gráfico circular de energía
  ///
  /// Retorna puntos de datos para: Solar Directa, Red, P2P
  Future<List<ChartDataPoint>> getChartData({
    required String period,
    required ViewType viewType,
    required int userId,
  });

  /// Obtiene información del PDE (Programa de Distribución de Excedentes)
  ///
  /// Retorna null si no hay PDE disponible en el período
  /// [period] - Período en formato 'YYYY-MM'
  Future<PDEInfo?> getPDEInfo({
    required String period,
  });

  /// Obtiene los precios de referencia del mercado energético
  ///
  /// Solo disponible para vista admin
  /// [period] - Período en formato 'YYYY-MM'
  Future<List<PriceReference>?> getPriceReferences({
    required String period,
  });
}
