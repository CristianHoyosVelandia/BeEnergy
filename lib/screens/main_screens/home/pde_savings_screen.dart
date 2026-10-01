import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/utils/formatters.dart';
import 'package:be_energy/models/models.dart';
import 'package:be_energy/utils/metodos.dart';
import 'package:flutter/material.dart';

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
    return Scaffold(
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
      body: ListView(
        padding: EdgeInsets.all(AppTokens.space16),
        children: [
          Text(
            'Ahorro del usuario',
            style: context.textStyles.headlineSmall?.copyWith(
              fontWeight: AppTokens.fontWeightBold,
            ),
          ),
          SizedBox(height: AppTokens.space4),
          Text(
            'Liquidación $periodDisplayName',
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppTokens.space20),
          _SavingsCard(
            title: 'Sin VoltÁgora',
            subtitle:
                '${Formatters.formatEnergy(charge.userConsumptionKwh, decimals: 2)} consumidos · ${Formatters.formatCurrency(charge.gridPricePerKwh)} / kWh',
            value: Formatters.formatCurrency(charge.traditionalBillValue),
            icon: Icons.receipt_long,
            color: AppTokens.grey900,
          ),
          SizedBox(height: AppTokens.space12),
          _SavingsCard(
            title: 'Con VoltÁgora',
            subtitle: charge.shouldReceive
                ? 'Compensación a favor por PDE cedido'
                : 'Pago neto después del derecho comunitario',
            value: charge.shouldReceive
                ? '+${Formatters.formatCurrency(charge.receivableValue)}'
                : Formatters.formatCurrency(charge.platformBillValue),
            icon: charge.shouldReceive ? Icons.savings_outlined : Icons.bolt,
            color: charge.shouldReceive
                ? AppTokens.energyGreen
                : AppTokens.primaryColor,
          ),
          SizedBox(height: AppTokens.space20),
          Container(
            padding: EdgeInsets.all(AppTokens.space20),
            decoration: BoxDecoration(
              color: AppTokens.energyGreen.withValues(alpha: 0.1),
              borderRadius: AppTokens.borderRadiusLarge,
              border: Border.all(
                  color: AppTokens.energyGreen.withValues(alpha: 0.24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ahorro con la plataforma',
                  style: context.textStyles.titleMedium?.copyWith(
                    color: AppTokens.energyGreen,
                    fontWeight: AppTokens.fontWeightBold,
                  ),
                ),
                SizedBox(height: AppTokens.space12),
                Text(
                  Formatters.formatCurrency(charge.savingsWithPlatform),
                  style: context.textStyles.headlineMedium?.copyWith(
                    color: AppTokens.energyGreen,
                    fontWeight: AppTokens.fontWeightBold,
                  ),
                ),
                SizedBox(height: AppTokens.space8),
                Text(
                  'Incluye ${Formatters.formatCurrency(charge.savingsWithoutPlatform)} por derecho comunitario y ${Formatters.formatCurrency(charge.additionalPlatformSavings)} adicionales por el mercado interno.',
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppTokens.space20),
          // Text(
          //   'El precio sin VoltÁgora y el precio comunitario se toman de community_energy_price_references. Si no hay referencia activa para el periodo, el backend usa valores por defecto.',
          //   style: context.textStyles.bodySmall?.copyWith(
          //     color: context.colors.onSurfaceVariant,
          //     height: 1.35,
          //   ),
          // ),
        ],
      ),
    );
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
