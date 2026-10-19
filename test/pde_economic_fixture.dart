Map<String, dynamic> economicChargeFixture() => {
      'community_id': 2,
      'period': '2026-09',
      'status_code': 4,
      'payable_value': 102000,
      // Datos legacy deliberadamente distintos: la comparación debe usar escenarios.
      'traditional_bill_value': 999999,
      'platform_bill_value': 999999,
      'calculation_metadata': {
        'status': 'estimated',
        'defaulted_parameters': <String>[],
      },
      'economic_summary': {
        'strategy': 'fundadores',
        'parameters': {
          'price_per_kwh': 400,
          'commercialization_cost_per_kwh': 140,
          'grid_price_per_kwh': 789,
          'solidarity_contribution_rate': 0.2,
          'spot_price_per_kwh': 240,
        },
        'energy_balance': {
          'consumption_kwh': 250,
          'original_allocation_kwh': 125,
          'final_allocation_kwh': 250,
          'ceded_kwh': 0,
          'contributed_kwh': 0,
          'type2_surplus_kwh': 0,
        },
        'benefits': {
          'savings_with_market': 134700,
          'additional_savings': 37350,
          'supplier_revenue': 50000,
          'supplier_spot_reference': 30000,
          'supplier_margin_vs_spot': 20000,
        },
        'scenarios': {
          'traditional': {
            'community_used_kwh': 0,
            'grid_kwh': 250,
            'grid_full_kwh': 250,
            'grid_full_value': 197250,
            'subtotal': 197250,
            'solidarity_contribution_value': 39450,
            'total': 236700,
          },
          'community_without_market': {
            'community_used_kwh': 125,
            'free_right_used_kwh': 125,
            'commercialization_value': 17500,
            'grid_kwh': 125,
            'grid_full_kwh': 125,
            'grid_full_value': 98625,
            'subtotal': 116125,
            'solidarity_contribution_value': 23225,
            'total': 139350,
          },
          'community_with_market': {
            'community_used_kwh': 250,
            'free_right_used_kwh': 125,
            'community_paid_kwh': 125,
            'community_energy_value': 50000,
            'commercialization_value': 35000,
            'grid_kwh': 0,
            'subtotal': 85000,
            'solidarity_contribution_value': 17000,
            'total': 102000,
          },
        },
      },
    };

Map<String, dynamic> surplusChargeFixture() {
  final json = economicChargeFixture();
  final economics = json['economic_summary'] as Map;
  economics['allocation_context'] = {
    'source': 'period_allocation',
    'renunciation_applied': true,
    'original_pde_pct': 0.42,
    'final_pde_pct': 0.27,
  };
  economics['energy_balance'] = {
    'consumption_kwh': 80,
    'original_allocation_kwh': 126,
    'final_allocation_kwh': 81,
    'contributed_kwh': 45,
    'type2_surplus_kwh': 1,
  };
  economics['benefits'] = {
    'type2_surplus_value': 240,
    'supplier_revenue': 0,
    'savings_with_market': 62304,
    'additional_savings': 0,
  };
  (economics['scenarios'] as Map)['community_with_market'] = {
    'community_used_kwh': 80,
    'free_right_used_kwh': 80,
    'community_paid_kwh': 0,
    'commercialization_value': 11200,
    'grid_kwh': 0,
    'subtotal': 11200,
    'solidarity_contribution_value': 2240,
    'total': 13440,
  };
  json['payable_value'] = 13440;
  return json;
}
