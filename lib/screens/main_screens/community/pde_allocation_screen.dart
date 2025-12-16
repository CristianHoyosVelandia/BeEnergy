import 'package:flutter/material.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/utils/formatters.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/fake_data.dart';
import '../../../models/energy_models.dart';

/// Pantalla de PDE - Programa de Distribución de Excedentes
/// Muestra cómo se distribuye la energía excedente entre prosumidores - Noviembre 2025
class PDEAllocationScreen extends StatefulWidget {
  const PDEAllocationScreen({super.key});

  @override
  State<PDEAllocationScreen> createState() => _PDEAllocationScreenState();
}

class _PDEAllocationScreenState extends State<PDEAllocationScreen> {
  Widget _buildHeader() {
    final allocations = FakeData.pdeAllocations;
    final totalExcess = allocations.fold<double>(0, (sum, a) => sum + a.excessEnergy);

    return Container(
      margin: EdgeInsets.all(AppTokens.space16),
      padding: EdgeInsets.all(AppTokens.space20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange,
            Colors.orange.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppTokens.borderRadiusLarge,
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.share_outlined, color: Colors.white, size: 32),
              SizedBox(width: AppTokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Programa PDE',
                      style: context.textStyles.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: AppTokens.fontWeightBold,
                      ),
                    ),
                    SizedBox(height: AppTokens.space4),
                    Text(
                      'Distribución de Excedentes Homogénea',
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
                Column(
                  children: [
                    Text(
                      '${allocations.length}',
                      style: context.textStyles.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: AppTokens.fontWeightBold,
                      ),
                    ),
                    SizedBox(height: AppTokens.space4),
                    Text(
                      'Prosumidores',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                Column(
                  children: [
                    Text(
                      Formatters.formatEnergy(totalExcess),
                      style: context.textStyles.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: AppTokens.fontWeightBold,
                      ),
                    ),
                    SizedBox(height: AppTokens.space4),
                    Text(
                      'Total Excedente',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    final allocations = FakeData.pdeAllocations;

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
            'Distribución de Participación PDE',
            style: context.textStyles.titleMedium?.copyWith(
              fontWeight: AppTokens.fontWeightBold,
            ),
          ),
          SizedBox(height: AppTokens.space20),
          SizedBox(
            height: 280,
            child: PieChart(
              PieChartData(
                sections: allocations.map((allocation) {
                  // ⭐ NUEVO: Colorear según cumplimiento del 10%
                  final isCompliant = allocation.sharePercentage <= 0.10;
                  final color = isCompliant ? Colors.green : AppTokens.error;

                  return PieChartSectionData(
                    value: allocation.sharePercentage * 100,
                    title: '${(allocation.sharePercentage * 100).toStringAsFixed(1)}%',
                    color: color,
                    radius: 100,
                    titleStyle: context.textStyles.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: AppTokens.fontWeightBold,
                    ),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 50,
              ),
            ),
          ),
          SizedBox(height: AppTokens.space20),
          // Leyenda
          Wrap(
            spacing: AppTokens.space12,
            runSpacing: AppTokens.space8,
            children: allocations.map((allocation) {
              final isCompliant = allocation.sharePercentage <= 0.10;
              final color = isCompliant ? Colors.green : AppTokens.error;
              return _buildLegendItem(
                allocation.userName,
                color,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// ⭐ NUEVO: Construye tarjeta de validación CREG 101 072
  Widget _buildComplianceValidation() {
    final allocations = FakeData.pdeAllocations;

    // Calcular el PDE total y el porcentaje sobre Tipo 2
    // Nota: En fake data actual puede estar sobre total surplus, no solo Tipo 2
    // Para validación correcta, debería ser sobre surplusType2Only
    final totalPDE = allocations.fold<double>(
      0.0,
      (sum, a) => sum + a.allocatedEnergy,
    );

    // Total Tipo 2 disponible (suma de todos los prosumidores)
    final totalType2 = allocations.fold<double>(
      0.0,
      (sum, a) => sum + (a.surplusType2Only > 0 ? a.surplusType2Only : a.excessEnergy * 0.5),
    );

    final pdePercentage = totalType2 > 0 ? (totalPDE / totalType2) * 100 : 0.0;
    final isCompliant = pdePercentage <= 10.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
      padding: EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        color: isCompliant
            ? Colors.green.withValues(alpha: 0.1)
            : AppTokens.error.withValues(alpha: 0.1),
        borderRadius: AppTokens.borderRadiusMedium,
        border: Border.all(
          color: isCompliant
              ? Colors.green.withValues(alpha: 0.3)
              : AppTokens.error.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCompliant ? Icons.check_circle : Icons.warning,
                color: isCompliant ? Colors.green : AppTokens.error,
                size: 24,
              ),
              SizedBox(width: AppTokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Validación CREG 101 072',
                      style: context.textStyles.titleSmall?.copyWith(
                        fontWeight: AppTokens.fontWeightBold,
                        color: isCompliant ? Colors.green : AppTokens.error,
                      ),
                    ),
                    SizedBox(height: AppTokens.space4),
                    Text(
                      'Artículo 3.4: PDE ≤ 10% del Tipo 2',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space16),
          Divider(height: 1, color: context.colors.outline.withValues(alpha: 0.2)),
          SizedBox(height: AppTokens.space16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Tipo 2',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: AppTokens.space4),
                    Text(
                      Formatters.formatEnergy(totalType2),
                      style: context.textStyles.titleMedium?.copyWith(
                        fontWeight: AppTokens.fontWeightBold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PDE Asignado',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: AppTokens.space4),
                    Text(
                      Formatters.formatEnergy(totalPDE),
                      style: context.textStyles.titleMedium?.copyWith(
                        fontWeight: AppTokens.fontWeightBold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Porcentaje',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: AppTokens.space4),
                    Text(
                      '${pdePercentage.toStringAsFixed(1)}%',
                      style: context.textStyles.titleMedium?.copyWith(
                        fontWeight: AppTokens.fontWeightBold,
                        color: isCompliant ? Colors.green : AppTokens.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space16),
          // Estado de cumplimiento
          Container(
            padding: EdgeInsets.all(AppTokens.space12),
            decoration: BoxDecoration(
              color: isCompliant
                  ? Colors.green.withValues(alpha: 0.1)
                  : AppTokens.error.withValues(alpha: 0.1),
              borderRadius: AppTokens.borderRadiusSmall,
            ),
            child: Row(
              children: [
                Icon(
                  isCompliant ? Icons.check : Icons.close,
                  color: isCompliant ? Colors.green : AppTokens.error,
                  size: 20,
                ),
                SizedBox(width: AppTokens.space8),
                Expanded(
                  child: Text(
                    isCompliant
                        ? '✓ CUMPLE límite regulatorio (≤10%)'
                        : '✗ EXCEDE límite regulatorio\nActual: ${pdePercentage.toStringAsFixed(1)}% | Máximo: 10.0%',
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: isCompliant ? Colors.green : AppTokens.error,
                      fontWeight: AppTokens.fontWeightSemiBold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: AppTokens.borderRadiusSmall,
          ),
        ),
        SizedBox(width: AppTokens.space8),
        Text(
          label,
          style: context.textStyles.bodySmall?.copyWith(
            color: context.colors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildAllocationsList() {
    final allocations = FakeData.pdeAllocations;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Asignación Individual',
            style: context.textStyles.titleMedium?.copyWith(
              fontWeight: AppTokens.fontWeightBold,
            ),
          ),
          SizedBox(height: AppTokens.space12),
          ...allocations.map((allocation) => _buildAllocationCard(allocation)),
        ],
      ),
    );
  }

  Widget _buildAllocationCard(PDEAllocation allocation) {
    final member = FakeData.members.firstWhere(
      (m) => m.userId == allocation.userId,
      orElse: () => FakeData.members.first,
    );

    return Container(
      margin: EdgeInsets.only(bottom: AppTokens.space12),
      padding: EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppTokens.borderRadiusMedium,
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: AppTokens.borderRadiusSmall,
                ),
                child: Center(
                  child: Text(
                    allocation.userName[0].toUpperCase(),
                    style: context.textStyles.titleMedium?.copyWith(
                      color: Colors.orange,
                      fontWeight: AppTokens.fontWeightBold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppTokens.space12),
              // Nombre y capacidad
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      allocation.userName,
                      style: context.textStyles.titleMedium?.copyWith(
                        fontWeight: AppTokens.fontWeightBold,
                      ),
                    ),
                    SizedBox(height: AppTokens.space4),
                    Text(
                      'Capacidad: ${Formatters.formatPower(member.installedCapacity)}',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // Porcentaje badge
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTokens.space12,
                  vertical: AppTokens.space8,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: AppTokens.borderRadiusMedium,
                ),
                child: Text(
                  Formatters.formatPercentage(allocation.sharePercentage),
                  style: context.textStyles.titleMedium?.copyWith(
                    color: Colors.orange,
                    fontWeight: AppTokens.fontWeightBold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space16),
          Divider(height: 1, color: context.colors.outline.withValues(alpha: 0.1)),
          SizedBox(height: AppTokens.space16),
          // Métricas
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Excedente',
                  Formatters.formatEnergy(allocation.excessEnergy),
                  Icons.bolt_outlined,
                  Colors.orange,
                ),
              ),
              SizedBox(width: AppTokens.space12),
              Expanded(
                child: _buildMetricItem(
                  'Asignado',
                  Formatters.formatEnergy(allocation.allocatedEnergy),
                  Icons.check_circle_outline,
                  Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space12),
          // Barra de progreso
          _buildProgressBar(
            allocation.allocatedEnergy,
            allocation.excessEnergy,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(AppTokens.space12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: AppTokens.borderRadiusSmall,
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(height: AppTokens.space8),
          Text(
            value,
            style: context.textStyles.bodyMedium?.copyWith(
              color: color,
              fontWeight: AppTokens.fontWeightBold,
            ),
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

  Widget _buildProgressBar(double allocated, double total) {
    final percentage = total > 0 ? (allocated / total) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Distribución',
              style: context.textStyles.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            Text(
              '${(percentage * 100).toStringAsFixed(0)}%',
              style: context.textStyles.bodySmall?.copyWith(
                color: Colors.orange,
                fontWeight: AppTokens.fontWeightBold,
              ),
            ),
          ],
        ),
        SizedBox(height: AppTokens.space8),
        ClipRRect(
          borderRadius: AppTokens.borderRadiusSmall,
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: context.colors.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
      padding: EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: AppTokens.borderRadiusMedium,
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue, size: 24),
          SizedBox(width: AppTokens.space12),
          Expanded(
            child: Text(
              'El modelo PDE homogéneo distribuye la energía excedente de manera equitativa según la capacidad instalada de cada prosumidor.',
              style: context.textStyles.bodySmall?.copyWith(
                color: Colors.blue.shade900,
              ),
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
        title: const Text('Programa PDE'),
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
          // ⭐ NUEVO: Validación regulatoria CREG 101 072
          _buildComplianceValidation(),
          SizedBox(height: AppTokens.space16),
          _buildInfoCard(),
          SizedBox(height: AppTokens.space16),
          _buildPieChart(),
          SizedBox(height: AppTokens.space24),
          _buildAllocationsList(),
        ],
      ),
    );
  }
}
