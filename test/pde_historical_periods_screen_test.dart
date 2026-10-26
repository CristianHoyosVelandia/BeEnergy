import 'package:be_energy/core/theme/app_theme.dart';
import 'package:be_energy/core/utils/formatters.dart';
import 'package:be_energy/models/my_user.dart';
import 'package:be_energy/models/user_period_history.dart';
import 'package:be_energy/repositories/domain/pde_period_repository.dart';
import 'package:be_energy/screens/main_screens/home/components/pde_history_consumption_chart.dart';
import 'package:be_energy/screens/main_screens/home/pde_historical_periods_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _HistoryRepository extends Fake implements PDEPeriodRepository {
  final List<UserPeriodItem> periods;

  _HistoryRepository(this.periods);

  @override
  Future<UserPeriodHistory> getUserPeriodHistory({
    required int userId,
    int communityId = 1,
    int limit = 4,
  }) async =>
      UserPeriodHistory(
        currentPeriod: '2026-09',
        periods: periods,
        totalPeriods: periods.length,
      );
}

UserPeriodItem _period(int month, {bool hasData = true, double? consumption}) {
  const names = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
  ];
  return UserPeriodItem(
    period: '2026-${month.toString().padLeft(2, '0')}',
    displayName: '${names[month - 1]} 2026',
    status: month == 9 ? 'current' : 'historical',
    hasData: hasData,
    pdeStatusCode: month == 9 ? 4 : 5,
    pdeAvailable: false,
    energyRecord: EnergyRecordSummary(
      energyConsumed: consumption ?? month * 10,
      energyGenerated: 0,
      energyExported: 0,
      energyImported: 0,
    ),
  );
}

Future<void> _showHistory(
  WidgetTester tester,
  List<UserPeriodItem> periods, {
  double scale = 1,
}) async {
  tester.view.physicalSize = const Size(320, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(scale),
      ),
      child: child!,
    ),
    home: PdeHistoricalPeriodsScreen(
      myUser: MyUser(idUser: 1),
      communityId: 1,
      repository: _HistoryRepository(periods),
    ),
  ));
  await tester.pumpAndSettle();
}

Future<void> _selectPeriod(WidgetTester tester, String label) async {
  final selector = find.byType(DropdownButtonFormField<String>);
  await tester.ensureVisible(selector);
  await tester.tap(selector);
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Grafica las seis mediciones más recientes en orden cronológico',
      (tester) async {
    await _showHistory(tester, [
      _period(4),
      _period(9, hasData: false),
      _period(2),
      _period(8),
      _period(1),
      _period(6),
      _period(3),
      _period(7),
      _period(5),
    ]);
    final chart = tester.widget<PdeHistoryConsumptionChart>(
      find.byType(PdeHistoryConsumptionChart),
    );
    expect(chart.periods.map((period) => period.period), [
      '2026-03',
      '2026-04',
      '2026-05',
      '2026-06',
      '2026-07',
      '2026-08',
    ]);
    final bars = tester.widget<BarChart>(find.byType(BarChart)).data.barGroups;
    expect(bars.map((group) => group.barRods.single.toY),
        [30, 40, 50, 60, 70, 80]);
    expect(find.text('Estado'), findsNothing);

    await _selectPeriod(tester, 'Febrero 2026');
    expect(find.text(Formatters.formatEnergy(20, decimals: 2)), findsOneWidget);
    expect(find.text('Ver detalle del periodo'), findsOneWidget);
    expect(find.text('Estado'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tocar una barra sincroniza el selector y el consumo',
      (tester) async {
    await _showHistory(tester, [_period(7), _period(8)]);
    final rect = tester.getRect(find.byType(BarChart));
    // La primera barra ocupa el centro de la primera mitad del área de trazado.
    await tester.tapAt(Offset(
      rect.left + 48 + (rect.width - 48) / 4,
      rect.top + (rect.height - 48) / 2,
    ));
    await tester.pumpAndSettle();
    final selector = tester.widget<DropdownButtonFormField<String>>(
      find.byType(DropdownButtonFormField<String>),
    );
    expect(selector.initialValue, '2026-07');
    expect(find.text(Formatters.formatEnergy(70, decimals: 2)), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Solo el periodo actual medido muestra estado, incluso con cero',
      (tester) async {
    await _showHistory(tester, [_period(9, consumption: 0), _period(8)],
        scale: 1.5);
    await tester.ensureVisible(find.text('Estado'));
    expect(find.text('Estado'), findsOneWidget);
    expect(find.text('Conciliación'), findsOneWidget);
    expect(find.text(Formatters.formatEnergy(0, decimals: 2)), findsOneWidget);
    await _selectPeriod(tester, 'Agosto 2026');
    expect(find.text('Estado'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Actual sin medición no muestra estado ni inventa un consumo',
      (tester) async {
    await _showHistory(tester, [_period(9, hasData: false), _period(8)]);
    await _selectPeriod(tester, 'Septiembre 2026');
    expect(find.text('Sin medición'), findsOneWidget);
    expect(find.text('Estado'), findsNothing);
    expect(find.text(Formatters.formatEnergy(90, decimals: 2)), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Sin mediciones muestra mensaje en lugar de barras de cero',
      (tester) async {
    await _showHistory(tester, [_period(9, hasData: false)]);
    expect(find.text('Aún no hay mediciones de consumo disponibles.'),
        findsOneWidget);
    expect(find.byType(BarChart), findsNothing);
    expect(find.text('Sin medición'), findsOneWidget);
    expect(find.text('Estado'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
