// Modelos para Liquidación y Facturación
// Basado en la tesis de Cristian Hoyos y Esteban Viveros

class BillingScenario {
  final String name;
  final String description;
  final String code; // 'traditional', 'credits', 'pde', 'p2p'

  BillingScenario({
    required this.name,
    required this.description,
    required this.code,
  });
}

class UserBilling {
  final int userId;
  final String userName;
  final String period; // 'YYYY-MM'
  final double traditionalCost;
  final double creditsScenarioCost;
  final double pdeScenarioCost;
  final double p2pScenarioCost;
  final double energyConsumed;
  final double energyGenerated;

  UserBilling({
    required this.userId,
    required this.userName,
    required this.period,
    required this.traditionalCost,
    required this.creditsScenarioCost,
    required this.pdeScenarioCost,
    required this.p2pScenarioCost,
    required this.energyConsumed,
    required this.energyGenerated,
  });

  double get savingsWithCredits => traditionalCost - creditsScenarioCost;
  double get savingsWithPDE => traditionalCost - pdeScenarioCost;
  double get savingsWithP2P => traditionalCost - p2pScenarioCost;

  double get bestSavings => [
        savingsWithCredits,
        savingsWithPDE,
        savingsWithP2P,
      ].reduce((a, b) => a > b ? a : b);

  factory UserBilling.fromJson(Map<String, dynamic> json) {
    return UserBilling(
      userId: json['user_id'] as int,
      userName: json['user_name'] as String,
      period: json['period'] as String,
      traditionalCost: (json['traditional_cost'] as num).toDouble(),
      creditsScenarioCost: (json['credits_scenario_cost'] as num).toDouble(),
      pdeScenarioCost: (json['pde_scenario_cost'] as num).toDouble(),
      p2pScenarioCost: (json['p2p_scenario_cost'] as num).toDouble(),
      energyConsumed: (json['energy_consumed'] as num).toDouble(),
      energyGenerated: (json['energy_generated'] as num).toDouble(),
    );
  }
}

class RegulatedCosts {
  final double cu; // Cargo por Uso (COP/kWh)
  final double mc; // Cargo por Comercialización (COP/kWh)
  final double pcn; // Precio de Cargo de Energía (COP/kWh)

  RegulatedCosts({
    required this.cu,
    required this.mc,
    required this.pcn,
  });

  double get totalCostPerKwh => cu + mc + pcn;

  factory RegulatedCosts.fromJson(Map<String, dynamic> json) {
    return RegulatedCosts(
      cu: (json['cu'] as num).toDouble(),
      mc: (json['mc'] as num).toDouble(),
      pcn: (json['pcn'] as num).toDouble(),
    );
  }
}

class CommunitySavings {
  final String period;
  final double totalTraditionalCost;
  final double totalWithCredits;
  final double totalWithPDE;
  final double totalWithP2P;

  CommunitySavings({
    required this.period,
    required this.totalTraditionalCost,
    required this.totalWithCredits,
    required this.totalWithPDE,
    required this.totalWithP2P,
  });

  double get savingsWithCredits => totalTraditionalCost - totalWithCredits;
  double get savingsWithPDE => totalTraditionalCost - totalWithPDE;
  double get savingsWithP2P => totalTraditionalCost - totalWithP2P;

  double get bestScenarioSavings => [
        savingsWithCredits,
        savingsWithPDE,
        savingsWithP2P,
      ].reduce((a, b) => a > b ? a : b);

  factory CommunitySavings.fromJson(Map<String, dynamic> json) {
    return CommunitySavings(
      period: json['period'] as String,
      totalTraditionalCost: (json['total_traditional_cost'] as num).toDouble(),
      totalWithCredits: (json['total_with_credits'] as num).toDouble(),
      totalWithPDE: (json['total_with_pde'] as num).toDouble(),
      totalWithP2P: (json['total_with_p2p'] as num).toDouble(),
    );
  }
}
