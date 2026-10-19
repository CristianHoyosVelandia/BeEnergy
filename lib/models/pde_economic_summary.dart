/// Datos calculados por el backend. La UI no reconstruye facturas con porcentajes
/// legacy: cada escenario conserva sus propias cantidades, cargos y total.
class PdeEconomicSummary {
  final String strategy;
  final PdeEconomicValues parameters;
  final PdeEconomicValues energy;
  final PdeEconomicValues benefits;
  final PdeEconomicValues allocation;
  final PdeBillScenario traditional;
  final PdeBillScenario withoutMarket;
  final PdeBillScenario withMarket;

  const PdeEconomicSummary({
    required this.strategy,
    required this.parameters,
    required this.energy,
    required this.benefits,
    this.allocation = const PdeEconomicValues({}),
    required this.traditional,
    required this.withoutMarket,
    required this.withMarket,
  });

  static PdeEconomicSummary? tryParse(dynamic value) {
    if (value is! Map) return null;
    final json = Map<String, dynamic>.from(value);
    final scenarios = json['scenarios'];
    if (scenarios is! Map ||
        scenarios['traditional'] is! Map ||
        scenarios['community_without_market'] is! Map ||
        scenarios['community_with_market'] is! Map) {
      return null;
    }
    return PdeEconomicSummary(
      strategy: json['strategy'] as String? ?? '',
      parameters: PdeEconomicValues.fromJson(json['parameters']),
      energy: PdeEconomicValues.fromJson(json['energy_balance']),
      benefits: PdeEconomicValues.fromJson(json['benefits']),
      allocation: PdeEconomicValues.fromJson(json['allocation_context']),
      traditional: PdeBillScenario.fromJson(scenarios['traditional']),
      withoutMarket:
          PdeBillScenario.fromJson(scenarios['community_without_market']),
      withMarket: PdeBillScenario.fromJson(scenarios['community_with_market']),
    );
  }

  bool get hasFreeRight =>
      strategy == 'fundadores' || strategy == 'bocas_del_palo';
  String get beneficiaryLabel => strategy == 'caluce'
      ? 'Prosumidor proveedor'
      : strategy == 'fundadores'
          ? 'Cooperativa'
          : 'Consejo comunitario';
}

class PdeEconomicValues {
  final Map<String, dynamic> _values;

  const PdeEconomicValues(this._values);

  factory PdeEconomicValues.fromJson(dynamic json) => PdeEconomicValues(
        json is Map ? Map<String, dynamic>.from(json) : const {},
      );

  double value(String key) {
    final raw = _values[key];
    return raw is num ? raw.toDouble() : double.tryParse('$raw') ?? 0;
  }

  bool flag(String key) => _values[key] == true;
}

class PdeBillScenario extends PdeEconomicValues {
  const PdeBillScenario(super.values);

  factory PdeBillScenario.fromJson(dynamic json) => PdeBillScenario(
        json is Map ? Map<String, dynamic>.from(json) : const {},
      );

  double get communityUsedKwh => value('community_used_kwh');
  double get freeRightUsedKwh => value('free_right_used_kwh');
  double get communityPaidKwh => value('community_paid_kwh');
  double get gridKwh => value('grid_kwh');
  double get gridSubsidizedKwh => value('grid_subsidized_kwh');
  double get gridFullKwh => value('grid_full_kwh');
  double get communityEnergyValue => value('community_energy_value');
  double get commercializationValue => value('commercialization_value');
  double get gridSubsidizedValue => value('grid_subsidized_value');
  double get gridFullValue => value('grid_full_value');
  double get subtotal => value('subtotal');
  double get contributionValue => value('solidarity_contribution_value');
  double get total => value('total');
}
