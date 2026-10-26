import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/utils/formatters.dart';
import 'package:be_energy/models/user_period_history.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PdeHistoryConsumptionChart extends StatelessWidget {
  /// Periodos con medición, ordenados del más antiguo al más reciente.
  final List<UserPeriodItem> periods;
  final String? selectedPeriod;
  final ValueChanged<String> onPeriodSelected;

  const PdeHistoryConsumptionChart({
    super.key,
    required this.periods,
    required this.selectedPeriod,
    required this.onPeriodSelected,
  });

  @override
  Widget build(BuildContext context) {
    final highest = periods.fold<double>(0, (maximum, period) {
      final consumption = period.energyRecord.energyConsumed;
      return consumption > maximum ? consumption : maximum;
    });
    final maxY = highest > 0 ? highest * 1.2 : 1.0;

    return Container(
      padding: EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppTokens.borderRadiusLarge,
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Consumo de energía',
            style: context.textStyles.titleMedium?.copyWith(
              fontWeight: AppTokens.fontWeightBold,
            ),
          ),
          SizedBox(height: AppTokens.space4),
          Text(
            'Últimos ${periods.length} periodos con medición · kWh',
            style: context.textStyles.bodySmall,
          ),
          SizedBox(height: AppTokens.space24),
          if (periods.isEmpty)
            const Text('Aún no hay mediciones de consumo disponibles.')
          else ...[
            SizedBox(
              height: 240,
              child: BarChart(
                BarChartData(
                  minY: 0,
                  maxY: maxY,
                  alignment: BarChartAlignment.spaceAround,
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    horizontalInterval: maxY / 4,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: context.colors.outline.withValues(alpha: 0.12),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 48,
                        interval: maxY / 4,
                        getTitlesWidget: (value, meta) => Text(
                          NumberFormat.compact(locale: 'es').format(value),
                          style: context.textStyles.bodySmall,
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 48,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= periods.length) {
                            return const SizedBox.shrink();
                          }
                          final period = periods[index];
                          return Padding(
                            padding: EdgeInsets.only(top: AppTokens.space8),
                            child: Text(
                              _axisLabel(period),
                              textAlign: TextAlign.center,
                              style: context.textStyles.bodySmall?.copyWith(
                                fontSize: 10,
                                color: period.period == selectedPeriod
                                    ? AppTokens.primaryColor
                                    : context.colors.onSurfaceVariant,
                                fontWeight: period.period == selectedPeriod
                                    ? AppTokens.fontWeightBold
                                    : AppTokens.fontWeightRegular,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    touchCallback: (event, response) {
                      final spot = response?.spot;
                      if (event is FlTapUpEvent && spot != null) {
                        onPeriodSelected(
                          periods[spot.touchedBarGroupIndex].period,
                        );
                      }
                    },
                    touchTooltipData: BarTouchTooltipData(
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final period = periods[groupIndex];
                        return BarTooltipItem(
                          '${period.displayName}\n'
                          '${Formatters.formatEnergy(rod.toY, decimals: 2)}',
                          const TextStyle(color: Colors.white, fontSize: 12),
                        );
                      },
                    ),
                  ),
                  barGroups: List.generate(periods.length, (index) {
                    final period = periods[index];
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: period.energyRecord.energyConsumed,
                          width: 22,
                          color: AppTokens.primaryColor.withValues(
                            alpha: period.period == selectedPeriod ? 1 : 0.35,
                          ),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            SizedBox(height: AppTokens.space12),
            Text(
              'Toca una barra para consultar el periodo.',
              style: context.textStyles.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  String _axisLabel(UserPeriodItem period) {
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    final date = DateTime.parse('${period.period}-01');
    return '${months[date.month - 1]}\n${date.year}';
  }
}
