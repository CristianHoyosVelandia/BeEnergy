import 'package:flutter/material.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/utils/formatters.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/fake_data.dart';

/// Pantalla de Reportes
/// Muestra resúmenes y comparativas de la comunidad - Noviembre 2025
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  Widget _buildHeader() {
    final stats = FakeData.communityStats;
    final savings = FakeData.communitySavings;

    return Container(
      margin: EdgeInsets.all(AppTokens.space16),
      padding: EdgeInsets.all(AppTokens.space20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.indigo,
            Colors.indigo.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppTokens.borderRadiusLarge,
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, color: Colors.white, size: 32),
              SizedBox(width: AppTokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reportes Comunidad',
                      style: context.textStyles.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: AppTokens.fontWeightBold,
                      ),
                    ),
                    SizedBox(height: AppTokens.space4),
                    Text(
                      'Análisis Completo • Noviembre 2025',
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space20),
          Container(
            padding: EdgeInsets.all(AppTokens.space16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: AppTokens.borderRadiusMedium,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildHeaderStat(
                  '${stats.totalMembers}',
                  'Miembros',
                  Icons.groups_rounded,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                _buildHeaderStat(
                  Formatters.formatEnergy(stats.totalEnergyGenerated),
                  'Generado',
                  Icons.wb_sunny_outlined,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                _buildHeaderStat(
                  Formatters.formatCurrency(savings.bestScenarioSavings),
                  'Ahorro Máx',
                  Icons.savings_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        SizedBox(height: AppTokens.space8),
        Text(
          value,
          style: context.textStyles.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: AppTokens.fontWeightBold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppTokens.space4),
        Text(
          label,
          style: context.textStyles.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildEnergyBreakdownChart() {
    final stats = FakeData.communityStats;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
      padding: EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppTokens.borderRadiusLarge,
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Balance Energético Comunitario',
            style: context.textStyles.titleMedium?.copyWith(
              fontWeight: AppTokens.fontWeightBold,
            ),
          ),
          SizedBox(height: AppTokens.space20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: stats.totalEnergyConsumed * 1.2,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const titles = ['Generado', 'Consumido', 'Importado', 'Exportado'];
                        if (value.toInt() >= 0 && value.toInt() < titles.length) {
                          return Padding(
                            padding: EdgeInsets.only(top: AppTokens.space8),
                            child: Text(
                              titles[value.toInt()],
                              style: context.textStyles.bodySmall,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${(value / 1000).toStringAsFixed(1)}k',
                          style: context.textStyles.bodySmall,
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: stats.totalEnergyGenerated,
                        color: Colors.orange,
                        width: 40,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: stats.totalEnergyConsumed,
                        color: AppTokens.error,
                        width: 40,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barRods: [
                      BarChartRodData(
                        toY: stats.totalEnergyImported,
                        color: Colors.blue,
                        width: 40,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 3,
                    barRods: [
                      BarChartRodData(
                        toY: stats.totalEnergyExported,
                        color: Colors.green,
                        width: 40,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsComparisonChart() {
    final savings = FakeData.communitySavings;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
      padding: EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppTokens.borderRadiusLarge,
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comparación de Escenarios de Facturación',
            style: context.textStyles.titleMedium?.copyWith(
              fontWeight: AppTokens.fontWeightBold,
            ),
          ),
          SizedBox(height: AppTokens.space20),
          _buildScenarioBar(
            'Tradicional',
            savings.totalTraditionalCost,
            savings.totalTraditionalCost,
            Colors.grey,
          ),
          SizedBox(height: AppTokens.space12),
          _buildScenarioBar(
            'Créditos',
            savings.totalWithCredits,
            savings.totalTraditionalCost,
            Colors.blue,
          ),
          SizedBox(height: AppTokens.space12),
          _buildScenarioBar(
            'PDE',
            savings.totalWithPDE,
            savings.totalTraditionalCost,
            Colors.orange,
          ),
          SizedBox(height: AppTokens.space12),
          _buildScenarioBar(
            'P2P',
            savings.totalWithP2P,
            savings.totalTraditionalCost,
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioBar(String label, double cost, double maxCost, Color color) {
    final percentage = maxCost > 0 ? cost / maxCost : 0;
    final savingsAmount = maxCost - cost;
    final savingsPercent = maxCost > 0 ? (savingsAmount / maxCost) * 100 : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: context.textStyles.bodyMedium?.copyWith(
                fontWeight: AppTokens.fontWeightBold,
              ),
            ),
            Row(
              children: [
                Text(
                  Formatters.formatCurrency(cost),
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: AppTokens.fontWeightBold,
                  ),
                ),
                if (savingsAmount > 0) ...[
                  SizedBox(width: AppTokens.space8),
                  Text(
                    '(-${savingsPercent.toStringAsFixed(1)}%)',
                    style: context.textStyles.bodySmall?.copyWith(
                      color: Colors.green,
                      fontWeight: AppTokens.fontWeightBold,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        SizedBox(height: AppTokens.space8),
        ClipRRect(
          borderRadius: AppTokens.borderRadiusSmall,
          child: LinearProgressIndicator(
            value: percentage.toDouble(),
            backgroundColor: context.colors.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildKeyMetrics() {
    final stats = FakeData.communityStats;
    final p2pContracts = FakeData.p2pContracts;
    final totalP2PEnergy = p2pContracts.fold<double>(0, (sum, c) => sum + c.energyCommitted);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Métricas Clave',
            style: context.textStyles.titleMedium?.copyWith(
              fontWeight: AppTokens.fontWeightBold,
            ),
          ),
          SizedBox(height: AppTokens.space12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Autosuficiencia',
                  '${((stats.totalEnergyGenerated / stats.totalEnergyConsumed) * 100).toStringAsFixed(1)}%',
                  Icons.solar_power_outlined,
                  Colors.orange,
                ),
              ),
              SizedBox(width: AppTokens.space12),
              Expanded(
                child: _buildMetricCard(
                  'Energía P2P',
                  Formatters.formatEnergy(totalP2PEnergy),
                  Icons.handshake_outlined,
                  Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Prosumidores',
                  '${stats.totalProsumers}/${stats.totalMembers}',
                  Icons.groups_rounded,
                  AppTokens.primaryRed,
                ),
              ),
              SizedBox(width: AppTokens.space12),
              Expanded(
                child: _buildMetricCard(
                  'Capacidad Total',
                  Formatters.formatPower(stats.totalInstalledCapacity),
                  Icons.bolt_outlined,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppTokens.borderRadiusMedium,
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: AppTokens.borderRadiusSmall,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: AppTokens.space12),
          Text(
            value,
            style: context.textStyles.titleLarge?.copyWith(
              color: color,
              fontWeight: AppTokens.fontWeightBold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTokens.space4),
          Text(
            label,
            style: context.textStyles.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTopPerformers() {
    final rankings = FakeData.sellerRankings.take(3).toList();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
      padding: EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppTokens.borderRadiusLarge,
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events_outlined, color: Colors.amber, size: 24),
              SizedBox(width: AppTokens.space8),
              Text(
                'Top Contribuidores P2P',
                style: context.textStyles.titleMedium?.copyWith(
                  fontWeight: AppTokens.fontWeightBold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space16),
          ...rankings.asMap().entries.map((entry) {
            final position = entry.key + 1;
            final ranking = entry.value;
            return _buildPerformerCard(ranking, position);
          }),
        ],
      ),
    );
  }

  Widget _buildPerformerCard(ranking, int position) {
    final medals = [Colors.amber, Colors.grey[400]!, Colors.brown];
    final medal = medals[position - 1];

    return Container(
      margin: EdgeInsets.only(bottom: position < 3 ? AppTokens.space12 : 0),
      padding: EdgeInsets.all(AppTokens.space12),
      decoration: BoxDecoration(
        color: medal.withValues(alpha: 0.05),
        borderRadius: AppTokens.borderRadiusSmall,
        border: Border.all(
          color: medal.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: medal.withValues(alpha: 0.2),
              borderRadius: AppTokens.borderRadiusSmall,
            ),
            child: Center(
              child: Text(
                '#$position',
                style: context.textStyles.titleSmall?.copyWith(
                  color: medal,
                  fontWeight: AppTokens.fontWeightBold,
                ),
              ),
            ),
          ),
          SizedBox(width: AppTokens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ranking.userName,
                  style: context.textStyles.bodyMedium?.copyWith(
                    fontWeight: AppTokens.fontWeightBold,
                  ),
                ),
                SizedBox(height: AppTokens.space4),
                Text(
                  '${Formatters.formatEnergy(ranking.totalEnergySold)} vendidos',
                  style: context.textStyles.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            Formatters.formatCurrency(ranking.totalRevenue),
            style: context.textStyles.titleSmall?.copyWith(
              color: Colors.green,
              fontWeight: AppTokens.fontWeightBold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
        elevation: 0,
        backgroundColor: context.colors.surface,
      ),
      backgroundColor: context.colors.surfaceContainerLowest,
      body: ListView(
        padding: EdgeInsets.only(bottom: AppTokens.space24),
        children: [
          SizedBox(height: AppTokens.space16),
          _buildHeader(),
          SizedBox(height: AppTokens.space16),
          _buildKeyMetrics(),
          SizedBox(height: AppTokens.space16),
          _buildEnergyBreakdownChart(),
          SizedBox(height: AppTokens.space16),
          _buildSavingsComparisonChart(),
          SizedBox(height: AppTokens.space16),
          _buildTopPerformers(),
        ],
      ),
    );
  }
}
