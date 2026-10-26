import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/utils/formatters.dart';
import 'package:be_energy/models/models.dart';
import 'package:be_energy/utils/metodos.dart';
import 'package:flutter/material.dart';

import 'pde_economic_widgets.dart';

class PdeSavingsScreen extends StatelessWidget {
  final PdeCobroResumen charge;
  final String periodDisplayName;

  const PdeSavingsScreen({
    super.key,
    required this.charge,
    required this.periodDisplayName,
  });

  @override
  Widget build(BuildContext context) {
    final savingsColor = charge.hasPositiveSavings
        ? AppTokens.energyGreen
        : AppTokens.energySolar;
    final savingsIcon = charge.hasPositiveSavings
        ? Icons.check_circle_outline
        : Icons.info_outline;
    final savingsTitle = charge.hasPositiveSavings
        ? 'Ahorro neto estimado'
        : 'Sin ahorro neto estimado';

    return Scaffold(
      backgroundColor:
          charge.economics != null ? const Color(0xFFF8FAFC) : null,
      appBar: AppBar(
        toolbarHeight: 60,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          'Ahorros',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                blurRadius: 6,
                color: Color(0x4B1A1F24),
                offset: Offset(0, 2),
              )
            ],
            gradient: Metodos.gradientClasic(context),
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: charge.economics != null
          ? Center(
              child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                padding: const EdgeInsets.all(AppTokens.space16),
                children: [
                  PdeEconomicSavingsContent(
                      charge: charge, periodDisplayName: periodDisplayName)
                ],
              ),
            ))
          : ListView(
              padding: EdgeInsets.all(AppTokens.space16),
              children: [
                Text(
                  'Ahorro y conveniencia',
                  style: context.textStyles.headlineSmall?.copyWith(
                    fontWeight: AppTokens.fontWeightBold,
                  ),
                ),
                SizedBox(height: AppTokens.space4),
                Text(
                  'Liquidación $periodDisplayName · ${_calculationStatusLabel(charge.statusCode)}',
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: AppTokens.space20),
                _SavingsCard(
                  title: 'Sin VoltÁgora',
                  subtitle:
                      '${Formatters.formatEnergy(_comparisonEnergyKwh, decimals: 2)} comparados · ${Formatters.formatCurrency(charge.gridPricePerKwh)} / kWh',
                  value: Formatters.formatCurrency(charge.traditionalBillValue),
                  icon: Icons.receipt_long,
                  color: AppTokens.grey900,
                ),
                SizedBox(height: AppTokens.space12),
                _SavingsCard(
                  title: 'Con VoltÁgora',
                  subtitle: charge.shouldReceive
                      ? 'Compensación a favor por PDE cedido'
                      : charge.hasCommunityRight
                          ? 'Derecho comunitario más excedente y comercialización'
                          : 'Energía comunitaria más comercialización',
                  value: charge.shouldReceive
                      ? '+${Formatters.formatCurrency(charge.receivableValue)}'
                      : Formatters.formatCurrency(charge.platformBillValue),
                  icon: charge.shouldReceive
                      ? Icons.savings_outlined
                      : Icons.bolt,
                  color: charge.shouldReceive
                      ? AppTokens.energyGreen
                      : AppTokens.primaryColor,
                ),
                SizedBox(height: AppTokens.space20),
                Container(
                  padding: EdgeInsets.all(AppTokens.space20),
                  decoration: BoxDecoration(
                    color: savingsColor.withValues(alpha: 0.1),
                    borderRadius: AppTokens.borderRadiusLarge,
                    border:
                        Border.all(color: savingsColor.withValues(alpha: 0.24)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(savingsIcon, color: savingsColor, size: 22),
                          SizedBox(width: AppTokens.space8),
                          Expanded(
                            child: Text(
                              savingsTitle,
                              style: context.textStyles.titleMedium?.copyWith(
                                color: savingsColor,
                                fontWeight: AppTokens.fontWeightBold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppTokens.space12),
                      Text(
                        Formatters.formatCurrency(charge.savingsWithPlatform),
                        style: context.textStyles.headlineMedium?.copyWith(
                          color: savingsColor,
                          fontWeight: AppTokens.fontWeightBold,
                        ),
                      ),
                      SizedBox(height: AppTokens.space8),
                      Text(
                        _savingsExplanation,
                        style: context.textStyles.bodyMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppTokens.space20),
                _DetailRows(rows: [
                  MapEntry(
                      'Energía comparada',
                      Formatters.formatEnergy(_comparisonEnergyKwh,
                          decimals: 2)),
                  MapEntry('Tarifa sin VoltÁgora',
                      '${Formatters.formatCurrency(charge.gridPricePerKwh)} / kWh'),
                  MapEntry('Precio comunitario',
                      '${Formatters.formatCurrency(charge.pricePerKwh)} / kWh'),
                  if (charge.commercializationCostPerKwh > 0)
                    MapEntry('Comercialización',
                        '${Formatters.formatCurrency(charge.commercializationCostPerKwh)} / kWh'),
                  if (charge.commercializationValue > 0)
                    MapEntry(
                        'Total comercialización',
                        Formatters.formatCurrency(
                            charge.commercializationValue)),
                  if (charge.hasCommunityRight)
                    MapEntry(
                        'Ahorro por derecho',
                        Formatters.formatCurrency(
                            charge.savingsWithoutPlatform)),
                  MapEntry(
                      'Ahorro VoltÁgora',
                      Formatters.formatCurrency(
                          charge.additionalPlatformSavings)),
                ]),
                SizedBox(height: AppTokens.space20),
                Text(
                  'La comparación es estimada: usa la tarifa de red, el precio comunitario y la comercialización reportados por el backend para este periodo. No reemplaza la factura final del comercializador.',
                  style: context.textStyles.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
    );
  }

  double get _comparisonEnergyKwh {
    if (charge.hasCommunityRight) {
      return charge.pdeFreeRightKwh + charge.pdePurchasedKwh;
    }
    return charge.energyKwh;
  }

  String get _savingsExplanation {
    if (!charge.hasPositiveSavings) {
      return 'Con los supuestos usados, el precio comunitario más la comercialización no genera ahorro frente a la tarifa sin VoltÁgora para la energía comparada.';
    }
    if (charge.hasCommunityRight) {
      return 'Incluye ${Formatters.formatCurrency(charge.savingsWithoutPlatform)} por derecho comunitario neto de comercialización y ${Formatters.formatCurrency(charge.additionalPlatformSavings)} adicionales por el VoltÁgora.';
    }
    return 'El ahorro compara la energía PDE recibida contra la tarifa sin VoltÁgora, descontando el precio comunitario y la comercialización.';
  }

  String _calculationStatusLabel(int statusCode) {
    if (statusCode == 5) return 'Definitivo';
    if (statusCode == 4 || statusCode == 7) return 'Conciliado';
    return 'Estimado';
  }
}

class _SavingsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final IconData icon;
  final Color color;

  const _SavingsCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppTokens.borderRadiusLarge,
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          SizedBox(width: AppTokens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textStyles.titleSmall?.copyWith(
                    fontWeight: AppTokens.fontWeightBold,
                  ),
                ),
                SizedBox(height: AppTokens.space4),
                Text(
                  subtitle,
                  style: context.textStyles.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: context.textStyles.titleLarge?.copyWith(
              color: color,
              fontWeight: AppTokens.fontWeightBold,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRows extends StatelessWidget {
  final List<MapEntry<String, String>> rows;

  const _DetailRows({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppTokens.borderRadiusLarge,
        border:
            Border.all(color: context.colors.outline.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Base de comparación',
            style: context.textStyles.titleSmall?.copyWith(
              fontWeight: AppTokens.fontWeightBold,
            ),
          ),
          SizedBox(height: AppTokens.space12),
          for (final row in rows)
            Padding(
              padding: EdgeInsets.only(bottom: AppTokens.space8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(row.key)),
                  SizedBox(width: AppTokens.space12),
                  Text(
                    row.value,
                    style: context.textStyles.bodyMedium?.copyWith(
                      fontWeight: AppTokens.fontWeightBold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
