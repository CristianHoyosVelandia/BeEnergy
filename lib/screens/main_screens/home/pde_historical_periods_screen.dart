import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/utils/formatters.dart';
import 'package:be_energy/models/models.dart';
import 'package:be_energy/repositories/impl/pde_period_repository_api.dart';
import 'package:flutter/material.dart';

import 'pde_historical_detail_screen.dart';

class PdeHistoricalPeriodsScreen extends StatefulWidget {
  final MyUser myUser;
  final int communityId;

  const PdeHistoricalPeriodsScreen({
    super.key,
    required this.myUser,
    required this.communityId,
  });

  @override
  State<PdeHistoricalPeriodsScreen> createState() =>
      _PdeHistoricalPeriodsScreenState();
}

class _PdeHistoricalPeriodsScreenState
    extends State<PdeHistoricalPeriodsScreen> {
  final _repository = PDEPeriodRepositoryApi();
  bool _isLoading = true;
  String? _error;
  UserPeriodHistory? _history;

  @override
  void initState() {
    super.initState();
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
    final periods = (_history?.periods ?? [])
        .where((period) => period.status != 'current')
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
                      child: ListView.separated(
                        padding: EdgeInsets.all(AppTokens.space16),
                        itemCount: periods.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: AppTokens.space12),
                        itemBuilder: (context, index) {
                          return _PeriodCard(
                            period: periods[index],
                            onTap: () => _openDetail(periods[index]),
                          );
                        },
                      ),
                    ),
    );
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
                value: Formatters.formatEnergy(
                  period.energyRecord.energyConsumed,
                  decimals: 2,
                ),
              ),
              _InfoLine(
                  label: 'Estado', value: _statusName(period.pdeStatusCode)),
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
          Text(label, style: context.textStyles.bodyMedium),
          Text(
            value,
            style: context.textStyles.bodyMedium?.copyWith(
              fontWeight: AppTokens.fontWeightBold,
              color: AppTokens.grey900,
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
