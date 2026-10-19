import 'package:be_energy/core/utils/formatters.dart';
import 'package:be_energy/models/pde_cobro_resumen.dart';
import 'package:be_energy/screens/main_screens/home/pde_economic_widgets.dart';
import 'package:be_energy/screens/main_screens/home/pde_savings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'pde_economic_fixture.dart';

Widget host(Widget child, {double scale = 1}) => MaterialApp(
      builder: (context, widget) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale)),
        child: widget!,
      ),
      home: child,
    );

void main() {
  for (final width in [320.0, 430.0]) {
    testWidgets('Cobro adaptable a $width px con texto ampliado',
        (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final charge = PdeCobroResumen.fromJson(economicChargeFixture());
      var compared = false;
      var paid = false;
      await tester.pumpWidget(host(
        Scaffold(
            body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: PdeEconomicChargeContent(
            charge: charge,
            periodDisplayName: 'Septiembre 2026',
            onCompare: () => compared = true,
            onSimulatePayment: () => paid = true,
            isPaid: false,
            isSubmitting: false,
          ),
        )),
        scale: 1.5,
      ));
      expect(find.text('TOTAL MENSUAL'), findsOneWidget);
      expect(find.text('Componente comunitario'), findsNothing);
      expect(find.text('Faltante comprado a la red'), findsNothing);
      await tester.ensureVisible(find.text('Simular pago'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Simular pago'));
      expect(paid, isTrue);
      expect(find.text(Formatters.formatCurrency(102000)), findsWidgets);
      expect(find.text(Formatters.formatCurrency(85000)), findsWidgets);
      expect(find.textContaining('Contribución solidaria'), findsOneWidget);
      expect(find.text('Cálculo del Periodo'), findsOneWidget);
      final compare = find.text('Comparar escenarios y ahorros');
      await tester.ensureVisible(compare);
      await tester.tap(compare);
      await tester.pumpAndSettle();
      expect(compared, isTrue);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Ahorros usa escenarios y permite abrir el desglose',
      (tester) async {
    final charge = PdeCobroResumen.fromJson(economicChargeFixture());
    await tester.pumpWidget(host(PdeSavingsScreen(
        charge: charge, periodDisplayName: 'Septiembre 2026')));
    expect(find.text('Mercado tradicional'), findsOneWidget);
    expect(find.text('Comunidad sin mercado interno'), findsOneWidget);
    expect(find.text('Comunidad con mercado interno'), findsOneWidget);
    expect(find.text(Formatters.formatCurrency(999999)), findsNothing);
    expect(find.text(Formatters.formatCurrency(236700)), findsOneWidget);
    final breakdown = find.text('Ver desglose').at(2);
    await tester.ensureVisible(breakdown);
    await tester.pumpAndSettle();
    await tester.tap(breakdown);
    await tester.pumpAndSettle();
    expect(find.text(Formatters.formatCurrency(17000)), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('El sobrecosto se identifica aunque exista ahorro total',
      (tester) async {
    final json = economicChargeFixture();
    ((json['economic_summary'] as Map)['benefits']
        as Map)['additional_savings'] = -2849;
    final charge = PdeCobroResumen.fromJson(json);
    await tester.pumpWidget(host(Scaffold(
        body: SingleChildScrollView(
      child: PdeEconomicSavingsContent(
          charge: charge, periodDisplayName: 'Septiembre 2026'),
    ))));
    expect(find.text('Sobrecosto del mercado interno'), findsOneWidget);
    expect(find.text('Ahorro frente al tradicional'), findsOneWidget);
    expect(find.text(Formatters.formatCurrency(2849)), findsOneWidget);
  });

  testWidgets(
      'El excedente posterior al aporte se valora a spot sin descontar la factura',
      (tester) async {
    final charge = PdeCobroResumen.fromJson(surplusChargeFixture());
    await tester.pumpWidget(host(Scaffold(
        body: SingleChildScrollView(
      child: PdeEconomicChargeContent(
          charge: charge,
          periodDisplayName: 'Septiembre 2026',
          onCompare: () {},
          onSimulatePayment: () {},
          isPaid: false,
          isSubmitting: false),
    ))));
    expect(find.text('Excedentes tipo II'), findsOneWidget);
    expect(find.text('Valor de excedentes tipo II'), findsOneWidget);
    expect(find.text(Formatters.formatCurrency(240)), findsOneWidget);
    expect(find.text(Formatters.formatCurrency(13440)), findsWidgets);
    expect(find.text('Derecho gratuito utilizado'), findsOneWidget);
    expect(find.text('Energía cedida'), findsNothing);
    final allocation = find.text('Tu asignación de energía');
    await tester.ensureVisible(allocation);
    await tester.pumpAndSettle();
    await tester.tap(allocation);
    await tester.pumpAndSettle();
    expect(find.text('Aporte aplicado al PDE'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Caluce no muestra derecho gratuito y conserva energía comunitaria pagada',
      (tester) async {
    final json = economicChargeFixture();
    final economics = json['economic_summary'] as Map;
    economics['strategy'] = 'caluce';
    final bill =
        (economics['scenarios'] as Map)['community_with_market'] as Map;
    bill['free_right_used_kwh'] = 0;
    bill['community_paid_kwh'] = 250;
    final charge = PdeCobroResumen.fromJson(json);
    await tester.pumpWidget(host(Scaffold(
        body: SingleChildScrollView(
      child: PdeEconomicChargeContent(
          charge: charge,
          periodDisplayName: 'Septiembre 2026',
          onCompare: () {},
          onSimulatePayment: () {},
          isPaid: false,
          isSubmitting: false),
    ))));
    expect(find.text('Derecho gratuito utilizado'), findsNothing);
    expect(find.text('Energía por derecho comunitario'), findsNothing);
    expect(find.text('Energía comunitaria pagada'), findsOneWidget);
    expect(find.text('Excedentes tipo II'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
