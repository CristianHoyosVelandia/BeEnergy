/// Servicio de Clasificación de Excedentes según CREG 101 072
///
/// Clasifica los excedentes energéticos en:
/// - Tipo 1: Autoconsumo compensado (NO vendible, solidaridad pasiva)
/// - Tipo 2: Disponible para PDE y P2P (vendible)
///
/// Algoritmo: División 50/50 del excedente total
library;

import '../models/energy_models.dart';
import '../models/regulatory_models.dart';

class SurplusClassifier {
  /// Clasifica los excedentes de un registro de energía
  ///
  /// Retorna un mapa con las claves:
  /// - 'type1': kWh de Tipo 1 (autoconsumo compensado)
  /// - 'type2': kWh de Tipo 2 (disponible para mercado)
  /// - 'total': kWh totales de excedente
  /// - 'classification': Tipo de clasificación (enum)
  Map<String, dynamic> classify(EnergyRecord record) {
    final totalSurplus = record.energyGenerated - record.energyConsumed;

    // Sin excedentes
    if (totalSurplus <= 0) {
      return {
        'type1': 0.0,
        'type2': 0.0,
        'total': 0.0,
        'classification': SurplusClassificationType.none,
      };
    }

    // Algoritmo 50/50 según CREG 101 072
    final type1 = totalSurplus * 0.5; // Autoconsumo compensado
    final type2 = totalSurplus * 0.5; // Disponible para mercado

    return {
      'type1': type1,
      'type2': type2,
      'total': totalSurplus,
      'classification': SurplusClassificationType.mixed,
    };
  }

  /// Clasifica excedentes desde valores directos
  ///
  /// [generated]: Energía generada en kWh
  /// [consumed]: Energía consumida en kWh
  Map<String, dynamic> classifyFromValues({
    required double generated,
    required double consumed,
  }) {
    final totalSurplus = generated - consumed;

    if (totalSurplus <= 0) {
      return {
        'type1': 0.0,
        'type2': 0.0,
        'total': 0.0,
        'classification': SurplusClassificationType.none,
      };
    }

    final type1 = totalSurplus * 0.5;
    final type2 = totalSurplus * 0.5;

    return {
      'type1': type1,
      'type2': type2,
      'total': totalSurplus,
      'classification': SurplusClassificationType.mixed,
    };
  }

  /// Crea un objeto SurplusClassification completo
  ///
  /// [userId]: ID del usuario
  /// [period]: Período en formato 'YYYY-MM'
  /// [generated]: Energía generada en kWh
  /// [consumed]: Energía consumida en kWh
  SurplusClassification createClassification({
    required int userId,
    required String period,
    required double generated,
    required double consumed,
  }) {
    final result = classifyFromValues(
      generated: generated,
      consumed: consumed,
    );

    return SurplusClassification(
      period: period,
      userId: userId,
      totalSurplus: result['total'] as double,
      type1Surplus: result['type1'] as double,
      type2Surplus: result['type2'] as double,
      classifiedAt: DateTime.now(),
    );
  }

  /// Valida que una clasificación sea correcta
  ///
  /// Verifica que: Tipo1 + Tipo2 = Total excedente
  ValidationResult validateClassification(SurplusClassification classification) {
    if (!classification.isValidClassification) {
      return ValidationResult.violation(
        message: 'Clasificación inválida: Tipo1 + Tipo2 ≠ Total',
        regulationArticle: 'CREG 101 072 Art 3.2',
        details: {
          'type1': classification.type1Surplus,
          'type2': classification.type2Surplus,
          'total': classification.totalSurplus,
          'sum': classification.type1Surplus + classification.type2Surplus,
        },
      );
    }

    // Verificar que sea aproximadamente 50/50
    final expectedType1 = classification.totalSurplus * 0.5;
    final expectedType2 = classification.totalSurplus * 0.5;

    final type1Diff = (classification.type1Surplus - expectedType1).abs();
    final type2Diff = (classification.type2Surplus - expectedType2).abs();

    if (type1Diff > 0.01 || type2Diff > 0.01) {
      return ValidationResult.warning(
        message: 'Clasificación no sigue división 50/50 exacta',
        regulationArticle: 'CREG 101 072 Art 3.2',
        details: {
          'type1Percentage': classification.type1Percentage,
          'type2Percentage': classification.type2Percentage,
          'expectedPercentage': 50.0,
        },
      );
    }

    return ValidationResult.success(
      message: 'Clasificación válida (50/50)',
      regulationArticle: 'CREG 101 072 Art 3.2',
      details: {
        'type1': classification.type1Surplus,
        'type2': classification.type2Surplus,
        'total': classification.totalSurplus,
      },
    );
  }

  /// Calcula el Tipo 2 disponible para P2P después de PDE
  ///
  /// [type2Total]: Total de Tipo 2 del usuario
  /// [pdeContributed]: kWh ya cedidos al PDE
  double calculateAvailableForP2P({
    required double type2Total,
    required double pdeContributed,
  }) {
    final available = type2Total - pdeContributed;
    return available > 0 ? available : 0.0;
  }

  /// Obtiene estadísticas de clasificación para un conjunto de registros
  Map<String, dynamic> getClassificationStats(List<EnergyRecord> records) {
    double totalType1 = 0.0;
    double totalType2 = 0.0;
    int prosumersWithSurplus = 0;
    int consumersOnly = 0;

    for (final record in records) {
      totalType1 += record.surplusType1;
      totalType2 += record.surplusType2;

      if (record.totalSurplus > 0) {
        prosumersWithSurplus++;
      } else {
        consumersOnly++;
      }
    }

    return {
      'totalType1': totalType1,
      'totalType2': totalType2,
      'totalSurplus': totalType1 + totalType2,
      'prosumersWithSurplus': prosumersWithSurplus,
      'consumersOnly': consumersOnly,
      'averageType1': prosumersWithSurplus > 0
          ? totalType1 / prosumersWithSurplus
          : 0.0,
      'averageType2': prosumersWithSurplus > 0
          ? totalType2 / prosumersWithSurplus
          : 0.0,
    };
  }
}
