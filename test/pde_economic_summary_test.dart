import 'package:be_energy/models/pde_cobro_resumen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'pde_economic_fixture.dart';

void main() {
  test('Conserva los tres escenarios sin mezclarlos con importes legacy', () {
    final charge = PdeCobroResumen.fromJson(economicChargeFixture());
    final economics = charge.economics!;
    expect(economics.traditional.total, 236700);
    expect(economics.withoutMarket.total, 139350);
    expect(economics.withMarket.total, 102000);
    expect(economics.withMarket.commercializationValue, 35000);
    expect(economics.withMarket.contributionValue, 17000);
    expect(charge.calculationStatus, 'estimated');
  });

  test('Conserva sobrecostos y consumo cero en lugar de descartarlos', () {
    final json = economicChargeFixture();
    final economics = json['economic_summary'] as Map;
    (economics['benefits'] as Map)['additional_savings'] = -2849;
    (economics['energy_balance'] as Map)['consumption_kwh'] = 0;
    final charge = PdeCobroResumen.fromJson(json);
    expect(charge.economics!.benefits.value('additional_savings'), -2849);
    expect(charge.economics!.energy.value('consumption_kwh'), 0);
  });

  test('Acepta respuesta anterior sin inventar escenarios', () {
    final json = economicChargeFixture()..remove('economic_summary');
    final charge = PdeCobroResumen.fromJson(json);
    expect(charge.economics, isNull);
    expect(charge.traditionalBillValue, 999999);
  });

  test('Distingue aporte aplicado de excedente restante a precio spot', () {
    final economics =
        PdeCobroResumen.fromJson(surplusChargeFixture()).economics!;
    expect(economics.allocation.flag('renunciation_applied'), isTrue);
    expect(economics.energy.value('contributed_kwh'), 45);
    expect(economics.energy.value('type2_surplus_kwh'), 1);
    expect(economics.benefits.value('type2_surplus_value'), 240);
    expect(economics.withMarket.total, 13440);
  });
}
