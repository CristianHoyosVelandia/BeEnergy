import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/utils/formatters.dart';
import 'package:be_energy/models/pde_assignment_summary.dart';
import 'package:be_energy/models/pde_cobro_resumen.dart';
import 'package:be_energy/models/user_period_history.dart';
import 'package:be_energy/services/pde_assignment_summary_service.dart';
import 'package:be_energy/services/pde_cobro_service.dart';
import 'package:flutter/material.dart';

class PdeHistoricalDetailScreen extends StatefulWidget {
  final int communityId;
  final UserPeriodItem period;

  const PdeHistoricalDetailScreen({
    super.key,
    required this.communityId,
    required this.period,
  });

  @override
  State<PdeHistoricalDetailScreen> createState() =>
      _PdeHistoricalDetailScreenState();
}

class _PdeHistoricalDetailScreenState extends State<PdeHistoricalDetailScreen> {
  final _assignmentService = PdeAssignmentSummaryService();
  final _cobroService = PdeCobroService();
  bool _isLoading = true;
  String? _error;
  PdeAssignmentSummary? _assignment;
  PdeCobroResumen? _charge;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait<Object>([
        _assignmentService.getSummary(
          communityId: widget.communityId,
          period: widget.period.period,
        ),
        _cobroService.getResumen(
          communityId: widget.communityId,
          period: widget.period.period,
        ),
      ]);
      if (!mounted) return;
      setState(() {
        _assignment = results[0] as PdeAssignmentSummary;
        _charge = results[1] as PdeCobroResumen;
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.period.displayName,
          style: const TextStyle(
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
              ? _ErrorState(message: _error!, onRetry: _loadDetail)
              : RefreshIndicator(
                  onRefresh: _loadDetail,
                  child: ListView(
                    padding: EdgeInsets.all(AppTokens.space16),
                    children: [
                      _SectionCard(
                        title: 'Asignación PDE',
                        rows: _assignmentRows(),
                      ),
                      SizedBox(height: AppTokens.space12),
                      _SectionCard(
                        title: 'Energía del periodo',
                        rows: [
                          MapEntry(
                            'Consumo',
                            Formatters.formatEnergy(
                              widget.period.energyRecord.energyConsumed,
                              decimals: 2,
                            ),
                          ),
                          MapEntry(
                            'Exc. Tipo I',
                            Formatters.formatEnergy(
                              50.44,
                              decimals: 2,
                            ),
                          ),
                          MapEntry(
                            'Exc. Tipo II',
                            Formatters.formatEnergy(
                              131.36,
                              decimals: 2,
                            ),
                          ),
                          // MapEntry(
                          //   'Energía importada',
                          //   Formatters.formatEnergy(
                          //     widget.period.energyRecord.energyImported,
                          //     decimals: 2,
                          //   ),
                          // ),
                        ],
                      ),
                      SizedBox(height: AppTokens.space12),
                      _SectionCard(
                        title: 'Resultado económico',
                        rows: _chargeRows(),
                      ),
                    ],
                  ),
                ),
    );
  }

  List<MapEntry<String, String>> _assignmentRows() {
    final assignment = _assignment;
    if (assignment == null) return const [];
    return [
      MapEntry('PDE inicial', _formatPercent(assignment.pdeInicial)),
      MapEntry(
        assignment.aportoPde ? 'Total aportado' : 'Adicional asignado',
        _formatPercent(assignment.cambioAbsoluto),
      ),
      MapEntry('PDE final', _formatPercent(assignment.pdeFinalAsignado)),
      MapEntry(
        'Energía asociada',
        Formatters.formatEnergy(assignment.pdeFinalKwh, decimals: 2),
      ),
    ];
  }

  List<MapEntry<String, String>> _chargeRows() {
    final charge = _charge;
    if (charge == null) return const [];
    return [
      MapEntry('Estado', _positionLabel(charge.netPosition)),
      // TODO: traer el valor de Sin Volt Ágora desde el backend cuando esté disponible
      MapEntry('Sin VoltÁgora', Formatters.formatCurrency(145440.00)),
      MapEntry('Con VoltÁgora', Formatters.formatCurrency(charge.payableValue)),
      // TODOO: solo traer este dato cuando existan exdentes tipo II
      MapEntry(
          'Valor a favor', Formatters.formatCurrency(charge.receivableValue)),
      MapEntry('Ahorro estimado',
          Formatters.formatCurrency(charge.savingsWithPlatform)),
    ];
  }

  String _formatPercent(double value) {
    return '${Formatters.formatNumber(value, decimals: 2)}%';
  }

  String _positionLabel(String value) {
    switch (value) {
      case 'pay':
        return 'Por pagar';
      case 'receive':
        return 'A favor';
      default:
        return 'Sin movimiento';
    }
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<MapEntry<String, String>> rows;

  const _SectionCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
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
            title,
            style: context.textStyles.titleMedium?.copyWith(
              fontWeight: AppTokens.fontWeightBold,
              color: AppTokens.grey900,
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
                      color: AppTokens.grey900,
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
