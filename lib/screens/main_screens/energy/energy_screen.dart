import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/utils/formatters.dart';
import 'package:be_energy/data/fake_data.dart';
import 'package:be_energy/models/models.dart';
import 'package:flutter/material.dart';

class EnergyScreen extends StatelessWidget {
  final MyUser? myUser;

  const EnergyScreen({super.key, this.myUser});

  EnergyRecord _record() {
    return FakeData.energyRecords.firstWhere(
      (record) => record.userId == (myUser?.idUser ?? 24),
      orElse: () => FakeData.energyRecords[11],
    );
  }

  @override
  Widget build(BuildContext context) {
    final record = _record();

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            AppTokens.space16,
            AppTokens.space24,
            AppTokens.space16,
            AppTokens.space32,
          ),
          children: [
            Text(
              'Detalle energético',
              style: context.textStyles.headlineSmall?.copyWith(
                fontWeight: AppTokens.fontWeightBold,
                color: AppTokens.grey900,
              ),
            ),
            SizedBox(height: AppTokens.space4),
            Text(
              'Generación, consumo e intercambio del periodo.',
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppTokens.space24),
            _EnergyHero(record: record),
            SizedBox(height: AppTokens.space16),
            _EnergyMetricCard(
              title: 'Generada',
              value: record.energyGenerated,
              icon: Icons.wb_sunny_rounded,
              color: AppTokens.primaryColor,
            ),
            _EnergyMetricCard(
              title: 'Consumida',
              value: record.energyConsumed,
              icon: Icons.electric_bolt_rounded,
              color: AppTokens.primaryColor.withValues(alpha: 0.78),
            ),
            _EnergyMetricCard(
              title: 'Exportada',
              value: record.energyExported,
              icon: Icons.trending_up_rounded,
              color: AppTokens.primaryColor.withValues(alpha: 0.58),
            ),
            _EnergyMetricCard(
              title: 'Importada',
              value: record.energyImported,
              icon: Icons.trending_down_rounded,
              color: AppTokens.primaryColor.withValues(alpha: 0.42),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnergyHero extends StatelessWidget {
  final EnergyRecord record;

  const _EnergyHero({required this.record});

  @override
  Widget build(BuildContext context) {
    final total = record.energyGenerated + record.energyImported;

    return Container(
      padding: EdgeInsets.all(AppTokens.space20),
      decoration: BoxDecoration(
        color: AppTokens.primaryColor.withValues(alpha: 0.08),
        borderRadius: AppTokens.borderRadiusLarge,
        border:
            Border.all(color: AppTokens.primaryColor.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Balance disponible',
            style: context.textStyles.bodyMedium?.copyWith(
              color: AppTokens.grey700,
              fontWeight: AppTokens.fontWeightSemiBold,
            ),
          ),
          SizedBox(height: AppTokens.space8),
          Text(
            Formatters.formatEnergy(total, decimals: 2),
            style: context.textStyles.headlineMedium?.copyWith(
              color: AppTokens.primaryColor,
              fontWeight: AppTokens.fontWeightBold,
            ),
          ),
          SizedBox(height: AppTokens.space8),
          Text(
            'Suma de energía generada e importada para cubrir tu consumo.',
            style: context.textStyles.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _EnergyMetricCard extends StatelessWidget {
  final String title;
  final double value;
  final IconData icon;
  final Color color;

  const _EnergyMetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppTokens.space12),
      padding: EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppTokens.borderRadiusLarge,
        border:
            Border.all(color: context.colors.outline.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppTokens.space12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppTokens.borderRadiusMedium,
            ),
            child: Icon(icon, color: color),
          ),
          SizedBox(width: AppTokens.space12),
          Expanded(
            child: Text(
              title,
              style: context.textStyles.bodyLarge?.copyWith(
                color: AppTokens.grey800,
                fontWeight: AppTokens.fontWeightSemiBold,
              ),
            ),
          ),
          Text(
            Formatters.formatEnergy(value, decimals: 2),
            style: context.textStyles.titleMedium?.copyWith(
              color: color,
              fontWeight: AppTokens.fontWeightBold,
            ),
          ),
        ],
      ),
    );
  }
}
