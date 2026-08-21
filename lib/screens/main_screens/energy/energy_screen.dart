import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/utils/formatters.dart';
import 'package:be_energy/models/models.dart';
import 'package:flutter/material.dart';

import 'controllers/energy_controller.dart';

class EnergyScreen extends StatefulWidget {
  final MyUser? myUser;

  const EnergyScreen({super.key, this.myUser});

  @override
  State<EnergyScreen> createState() => _EnergyScreenState();
}

class _EnergyScreenState extends State<EnergyScreen> {
  final EnergyController _controller = EnergyController();

  int get _currentCommunityId => widget.myUser?.communityId ?? 1;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_refresh);
    _load();
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _controller.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    await _controller.load(
      user: widget.myUser,
      communityId: _currentCommunityId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTokens.primaryColor,
          onRefresh: _load,
          child: _body(),
        ),
      ),
    );
  }

  Widget _body() {
    if (_controller.isLoading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Center(
              child: CircularProgressIndicator(color: AppTokens.primaryColor),
            ),
          ),
        ],
      );
    }

    if (_controller.errorMessage != null) {
      return _StateList(
        icon: Icons.error_outline_rounded,
        title: 'No pudimos cargar tus datos',
        message: _controller.errorMessage!,
        onRetry: _load,
      );
    }

    final record = _controller.currentPeriod?.energyRecord;
    final summary = _controller.summary;
    if (record == null || summary == null) {
      return _StateList(
        icon: Icons.bolt_outlined,
        title: 'Sin datos energéticos',
        message: 'Aún no hay información energética para este periodo.',
        onRetry: _load,
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        AppTokens.space16,
        AppTokens.space24,
        AppTokens.space16,
        AppTokens.space64,
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
          'Consumo y PDE individual del periodo.',
          style: context.textStyles.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        SizedBox(height: AppTokens.space24),
        _PdeEnergyHero(summary: summary),
        SizedBox(height: AppTokens.space16),
        _EnergyMetricCard(
          title: 'Consumo actual',
          value: summary.currentConsumptionKwh,
          icon: Icons.electric_bolt_rounded,
          color: AppTokens.primaryColor,
        ),
        _EnergyMetricCard(
          title: 'Consumo anterior',
          value: summary.lastConsumptionKwh,
          icon: Icons.history_rounded,
          color: AppTokens.primaryColor.withValues(alpha: 0.78),
        ),
        _EnergyMetricCard(
          title: 'PDE actual',
          value: summary.userPdePercentage,
          suffix: '%',
          secondaryValue: summary.userPdeKwh,
          secondarySuffix: 'adjudicados',
          icon: Icons.bolt_rounded,
          color: AppTokens.primaryColor.withValues(alpha: 0.66),
        ),
        _EnergyMetricCard(
          title: 'PDE anterior',
          value: summary.lastUserPdePercentage,
          suffix: '%',
          secondaryValue: summary.lastUserPdeKwh,
          secondarySuffix: 'adjudicados',
          icon: Icons.assignment_turned_in_rounded,
          color: AppTokens.primaryColor.withValues(alpha: 0.54),
        ),
        _EnergyMetricCard(
          title: 'Importada',
          value: _displayImportedEnergy(record, summary),
          icon: Icons.trending_down_rounded,
          color: AppTokens.primaryColor.withValues(alpha: 0.42),
        ),
        if (record.energyGenerated > 0)
          _EnergyMetricCard(
            title: 'Generada',
            value: record.energyGenerated,
            icon: Icons.wb_sunny_rounded,
            color: AppTokens.primaryColor.withValues(alpha: 0.9),
          ),
        if (record.energyExported > 0)
          _EnergyMetricCard(
            title: 'Exportada',
            value: record.energyExported,
            icon: Icons.trending_up_rounded,
            color: AppTokens.primaryColor.withValues(alpha: 0.58),
          ),
      ],
    );
  }

  double? _displayImportedEnergy(
    EnergyRecordSummary record,
    UserCurrentSummary summary,
  ) {
    final hasOwnGeneration =
        record.energyGenerated > 0 || record.energyExported > 0;
    if (!hasOwnGeneration) {
      return summary.currentConsumptionKwh ?? record.energyConsumed;
    }

    return record.energyImported;
  }
}

class _PdeEnergyHero extends StatelessWidget {
  final UserCurrentSummary summary;

  const _PdeEnergyHero({required this.summary});

  @override
  Widget build(BuildContext context) {
    final pdePercentage = summary.userPdePercentage;
    final communityAverageGeneration = summary.energiaComunitariaPromedio;
    final coveredByPde =
        pdePercentage != null && communityAverageGeneration != null
            ? communityAverageGeneration * (pdePercentage / 100)
            : summary.userPdeKwh;
    final currentConsumption = summary.currentConsumptionKwh;
    final balance = currentConsumption != null && coveredByPde != null
        ? currentConsumption - coveredByPde
        : null;

    return Container(
      padding: EdgeInsets.all(AppTokens.space20),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppTokens.borderRadiusLarge,
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            pdePercentage == null
                ? 'Sin PDE asignado'
                : Formatters.formatNumber(pdePercentage, decimals: 2),
            textAlign: TextAlign.center,
            style: context.textStyles.displaySmall?.copyWith(
              color: AppTokens.grey900,
              fontWeight: AppTokens.fontWeightBold,
              height: 1,
            ),
          ),
          SizedBox(height: AppTokens.space4),
          Text(
            'PDE actual (PDE asignado)',
            textAlign: TextAlign.center,
            style: context.textStyles.bodyMedium?.copyWith(
              color: AppTokens.grey700,
              fontWeight: AppTokens.fontWeightSemiBold,
            ),
          ),
          SizedBox(height: AppTokens.space24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _HeroValue(
                  value: coveredByPde == null
                      ? '-'
                      : Formatters.formatEnergy(coveredByPde, decimals: 2),
                  label: 'Consumo promedio cubierto por PDE',
                ),
              ),
              SizedBox(width: AppTokens.space16),
              Expanded(
                child: _HeroValue(
                  value: pdePercentage == null
                      ? '- %'
                      : '${Formatters.formatNumber(pdePercentage, decimals: 2)}%',
                  label: 'Equivalente en PDE',
                  alignEnd: true,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _HeroValue(
                  value: currentConsumption == null
                      ? '-'
                      : Formatters.formatEnergy(currentConsumption,
                          decimals: 2),
                  label: 'Consumo total del usuario',
                ),
              ),
              SizedBox(width: AppTokens.space16),
              Expanded(
                child: _HeroValue(
                  value: balance == null
                      ? '-'
                      : Formatters.formatEnergy(balance.abs(), decimals: 2),
                  label: balance != null && balance <= 0
                      ? 'Balance cubierto'
                      : 'Balance pendiente',
                  alignEnd: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroValue extends StatelessWidget {
  final String value;
  final String label;
  final bool alignEnd;

  const _HeroValue({
    required this.value,
    required this.label,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          value,
          textAlign: alignEnd ? TextAlign.right : TextAlign.left,
          style: context.textStyles.titleLarge?.copyWith(
            color: AppTokens.primaryColor,
            fontWeight: AppTokens.fontWeightBold,
          ),
        ),
        SizedBox(height: AppTokens.space8),
        Text(
          label,
          textAlign: alignEnd ? TextAlign.right : TextAlign.left,
          style: context.textStyles.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _EnergyMetricCard extends StatelessWidget {
  final String title;
  final double? value;
  final String suffix;
  final double? secondaryValue;
  final String? secondarySuffix;
  final IconData icon;
  final Color color;

  const _EnergyMetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.suffix = 'kWh',
    this.secondaryValue,
    this.secondarySuffix,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = value == null
        ? '-'
        : suffix == '%'
            ? '${Formatters.formatNumber(value!, decimals: 2)}%'
            : Formatters.formatEnergy(value!, decimals: 2);

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textStyles.bodyLarge?.copyWith(
                    color: AppTokens.grey800,
                    fontWeight: AppTokens.fontWeightSemiBold,
                  ),
                ),
                if (secondaryValue != null && secondarySuffix != null) ...[
                  SizedBox(height: AppTokens.space4),
                  Text(
                    '${Formatters.formatEnergy(secondaryValue!, decimals: 2)} $secondarySuffix',
                    style: context.textStyles.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            displayValue,
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

class _StateList extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Future<void> Function() onRetry;

  const _StateList({
    required this.icon,
    required this.title,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(AppTokens.space24),
      children: [
        SizedBox(height: AppTokens.space64),
        Icon(icon, color: AppTokens.primaryColor, size: 48),
        SizedBox(height: AppTokens.space16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: context.textStyles.titleLarge?.copyWith(
            color: AppTokens.grey900,
            fontWeight: AppTokens.fontWeightBold,
          ),
        ),
        SizedBox(height: AppTokens.space8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: context.textStyles.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        SizedBox(height: AppTokens.space24),
        FilledButton(
          onPressed: onRetry,
          child: const Text('Reintentar'),
        ),
      ],
    );
  }
}
