import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/utils/formatters.dart';
import 'package:be_energy/models/models.dart';
import 'package:be_energy/repositories/domain/pde_period_repository.dart';
import 'package:be_energy/repositories/impl/pde_period_repository_api.dart';
import 'package:flutter/material.dart';

import 'pde_historical_detail_screen.dart';
import 'components/pde_history_consumption_chart.dart';

class PdeHistoricalPeriodsScreen extends StatefulWidget {
  final MyUser myUser;
  final int communityId;
  final PDEPeriodRepository? repository;

  const PdeHistoricalPeriodsScreen({
    super.key,
    required this.myUser,
    required this.communityId,
    this.repository,
  });

  @override
  State<PdeHistoricalPeriodsScreen> createState() =>
      _PdeHistoricalPeriodsScreenState();
}

class _PdeHistoricalPeriodsScreenState
    extends State<PdeHistoricalPeriodsScreen> {
  late final PDEPeriodRepository _repository;
  bool _isLoading = true;
  String? _error;
  UserPeriodHistory? _history;
  String? _selectedPeriod;

  List<UserPeriodItem> get _periods =>
      [...?_history?.periods]..sort((a, b) => b.period.compareTo(a.period));

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? PDEPeriodRepositoryApi();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final history = await _repository.getUserPeriodHistory(
        userId: widget.myUser.idUser!,
        communityId: widget.communityId,
        limit: 12,
      );
      if (!mounted) return;
      setState(() {
        _history = history;
        final periods = _periods;
        if (!periods.any((period) => period.period == _selectedPeriod)) {
          final measured = periods.where((period) => period.hasData);
          _selectedPeriod = measured.isNotEmpty
              ? measured.first.period
              : periods.isNotEmpty
                  ? periods.first.period
                  : null;
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final periods = _periods;
    final selected = _history?.getPeriodByKey(_selectedPeriod ?? '');
    final chartPeriods = periods
        .where((period) => period.hasData)
        .take(6)
        .toList()
        .reversed
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Históricos PDE',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTokens.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorState(message: _error!, onRetry: _loadHistory)
              : periods.isEmpty
                  ? const _EmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadHistory,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.all(AppTokens.space16),
                        children: [
                          PdeHistoryConsumptionChart(
                            periods: chartPeriods,
                            selectedPeriod: _selectedPeriod,
                            onPeriodSelected: _selectPeriod,
                          ),
                          SizedBox(height: AppTokens.space24),
                          Theme(
                            data: Theme.of(context).copyWith(
                              focusColor: AppTokens.primaryColor
                                  .withValues(alpha: 0.08),
                              hoverColor: AppTokens.primaryColor
                                  .withValues(alpha: 0.04),
                            ),
                            child: DropdownButtonFormField<String>(
                              key: ValueKey(_selectedPeriod),
                              initialValue: _selectedPeriod,
                              isExpanded: true,
                              dropdownColor: context.colors.surface,
                              borderRadius: AppTokens.borderRadiusMedium,
                              style: context.textStyles.bodyLarge?.copyWith(
                                color: context.colors.onSurface,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Seleccionar periodo',
                                prefixIcon: const Icon(Icons.calendar_month),
                                border: OutlineInputBorder(
                                  borderRadius: AppTokens.borderRadiusMedium,
                                ),
                              ),
                              items: periods
                                  .map((period) => DropdownMenuItem(
                                        value: period.period,
                                        child: Text(
                                          period.displayName,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) _selectPeriod(value);
                              },
                            ),
                          ),
                          SizedBox(height: AppTokens.space16),
                          if (selected != null)
                            _PeriodCard(
                              period: selected,
                              onTap: () => _openDetail(selected),
                            ),
                        ],
                      ),
                    ),
    );
  }

  void _selectPeriod(String period) {
    setState(() => _selectedPeriod = period);
  }

  void _openDetail(UserPeriodItem period) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdeHistoricalDetailScreen(
          communityId: widget.communityId,
          period: period,
        ),
      ),
    );
  }
}

class _PeriodCard extends StatelessWidget {
  final UserPeriodItem period;
  final VoidCallback onTap;

  const _PeriodCard({required this.period, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surface,
      borderRadius: AppTokens.borderRadiusLarge,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppTokens.borderRadiusLarge,
        child: Container(
          padding: EdgeInsets.all(AppTokens.space16),
          decoration: BoxDecoration(
            borderRadius: AppTokens.borderRadiusLarge,
            border: Border.all(
              color: context.colors.outline.withValues(alpha: 0.14),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.history_rounded, color: AppTokens.primaryColor),
                  SizedBox(width: AppTokens.space12),
                  Expanded(
                    child: Text(
                      period.displayName,
                      style: context.textStyles.titleMedium?.copyWith(
                        fontWeight: AppTokens.fontWeightBold,
                        color: AppTokens.grey900,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: context.colors.onSurfaceVariant),
                ],
              ),
              SizedBox(height: AppTokens.space12),
              _InfoLine(
                label: 'Consumo',
                value: period.hasData
                    ? Formatters.formatEnergy(
                        period.energyRecord.energyConsumed,
                        decimals: 2,
                      )
                    : 'Sin medición',
              ),
              if (period.isCurrentPeriod && period.hasData)
                _InfoLine(
                    label: 'Estado', value: _statusName(period.pdeStatusCode)),
              SizedBox(height: AppTokens.space8),
              Text(
                'Ver detalle del periodo',
                style: context.textStyles.bodyMedium?.copyWith(
                  color: AppTokens.primaryColor,
                  fontWeight: AppTokens.fontWeightSemiBold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusName(int statusCode) {
    switch (statusCode) {
      case 1:
        return 'PDE disponible';
      case 2:
        return 'Cerrado';
      case 3:
        return 'Asignado';
      case 4:
        return 'Conciliación';
      case 5:
        return 'Histórico';
      case 6:
        return 'Aporte';
      case 7:
        return 'Cobro';
      default:
        return 'Sin estado';
    }
  }
}

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;

  const _InfoLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTokens.space4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: context.textStyles.bodyMedium)),
          SizedBox(width: AppTokens.space8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: context.textStyles.bodyMedium?.copyWith(
                fontWeight: AppTokens.fontWeightBold,
                color: AppTokens.grey900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppTokens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            SizedBox(height: AppTokens.space16),
            FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppTokens.space24),
        child: const Text('No hay periodos históricos disponibles.'),
      ),
    );
  }
}
