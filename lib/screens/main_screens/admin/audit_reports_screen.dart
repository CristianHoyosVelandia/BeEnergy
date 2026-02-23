// ignore_for_file: file_names
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/models/my_user.dart';
import 'package:be_energy/repositories/audit_repository.dart';
import 'package:be_energy/utils/metodos.dart';
import 'package:flutter/material.dart';

class AuditReportsScreen extends StatefulWidget {
  final MyUser? myUser;

  const AuditReportsScreen({super.key, this.myUser});

  @override
  State<AuditReportsScreen> createState() => _AuditReportsScreenState();
}

class _AuditReportsScreenState extends State<AuditReportsScreen> {
  final AuditRepository _repo = AuditRepository();
  DateTime? _startDate;
  DateTime? _endDate;
  String _format = 'json';
  bool _generating = false;
  final _userIdsController = TextEditingController();
  Map<String, dynamic>? _lastReport;
  final List<String> _eventTypesOptions = [
    'telemetry.ingest', 'alert_rule.create', 'device.create',
    'telemetry.query_latest', 'telemetry.query_history', 'alert.emit',
    'audit_report.generated', 'login', 'registro', 'transacción',
  ];
  final Set<String> _selectedEventTypes = {};

  @override
  void dispose() {
    _userIdsController.dispose();
    super.dispose();
  }

  Future<void> _pickRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (range != null) {
      setState(() {
        _startDate = range.start;
        _endDate = range.end;
      });
    }
  }

  Future<void> _generateReport() async {
    if (_startDate == null || _endDate == null) {
      Metodos.flushbarNegativo(context, 'Selecciona rango de fechas');
      return;
    }
    if (_format != 'json') {
      Metodos.flushbarNegativo(context, 'Para CSV o PDF usa la API directamente con format=csv o format=pdf');
      return;
    }
    setState(() => _generating = true);
    setState(() => _lastReport = null);
    try {
      final userIdsStr = _userIdsController.text.trim();
      final userIds = userIdsStr.isEmpty
          ? null
          : userIdsStr.split(',').map((e) => int.tryParse(e.trim())).whereType<int>().toList();
      final eventTypes = _selectedEventTypes.isEmpty ? null : _selectedEventTypes.toList();
      final resp = await _repo.generateReport(
        startDate: _startDate!,
        endDate: _endDate!,
        format: 'json',
        eventTypes: eventTypes,
        userIds: userIds,
      );
      if (resp.success && mounted) {
        Metodos.flushbarPositivo(context, 'Reporte generado correctamente');
        final report = resp.data as Map<String, dynamic>?;
        if (mounted) setState(() => _lastReport = report);
      } else {
        if (mounted) Metodos.flushbarNegativo(context, resp.message ?? 'Error al generar reporte');
      }
    } catch (e) {
      if (mounted) Metodos.flushbarNegativo(context, 'Error de conexión');
    }
    if (mounted) setState(() => _generating = false);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.myUser != null && !widget.myUser!.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Reportes de auditoría')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 64, color: context.colors.error),
              const SizedBox(height: 16),
              Text('Acceso denegado', style: context.textStyles.titleLarge),
              const SizedBox(height: 8),
              Text('Solo administradores pueden generar reportes de auditoría.', textAlign: TextAlign.center, style: context.textStyles.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant)),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reportes de auditoría',
          style: context.textStyles.titleLarge?.copyWith(
            color: context.colors.onSurface,
            fontWeight: AppTokens.fontWeightBold,
          ),
        ),
        backgroundColor: context.colors.surface,
        foregroundColor: context.colors.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTokens.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTokens.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Parámetros del reporte',
                      style: context.textStyles.titleMedium?.copyWith(
                        color: context.colors.onSurface,
                        fontWeight: AppTokens.fontWeightSemiBold,
                      ),
                    ),
                    const SizedBox(height: AppTokens.space16),
                    Text(
                      'Rango de fechas',
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppTokens.space8),
                    OutlinedButton.icon(
                      onPressed: _pickRange,
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(
                        _startDate != null && _endDate != null
                            ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year} — ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                            : 'Seleccionar fechas',
                      ),
                    ),
                    const SizedBox(height: AppTokens.space16),
                    Text(
                      'Tipos de evento (opcional)',
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppTokens.space8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _eventTypesOptions.map((e) {
                        final selected = _selectedEventTypes.contains(e);
                        return FilterChip(
                          label: Text(e.length > 20 ? '${e.substring(0, 20)}…' : e, style: const TextStyle(fontSize: 11)),
                          selected: selected,
                          onSelected: (v) => setState(() {
                            if (v) _selectedEventTypes.add(e);
                            else _selectedEventTypes.remove(e);
                          }),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppTokens.space16),
                    TextField(
                      controller: _userIdsController,
                      decoration: const InputDecoration(
                        labelText: 'IDs de usuarios (opcional)',
                        hintText: 'Ej: 1, 2, 5',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: AppTokens.space20),
                    FilledButton.icon(
                      onPressed: _generating ? null : _generateReport,
                      icon: _generating ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.onPrimary)) : const Icon(Icons.summarize, size: 20),
                      label: Text(_generating ? 'Generando...' : 'Generar reporte'),
                    ),
                  ],
                ),
              ),
            ),
            if (_lastReport != null) ...[
              const SizedBox(height: AppTokens.space24),
              _buildReportSummary(_lastReport!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReportSummary(Map<String, dynamic> report) {
    final summary = report['summary'] as Map<String, dynamic>? ?? {};
    final period = report['period'] as Map<String, dynamic>? ?? {};
    final total = summary['total_events'] ?? 0;
    final byAction = summary['by_action'] as Map<String, dynamic>? ?? {};
    final byUser = summary['by_user'] as Map<String, dynamic>? ?? {};
    final detail = report['detail'] as List? ?? [];

    return Card(
      color: context.colors.primaryContainer.withValues(alpha: 0.2),
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assignment_turned_in, color: context.colors.primary),
                const SizedBox(width: AppTokens.space8),
                Text(
                  'Resumen del reporte',
                  style: context.textStyles.titleMedium?.copyWith(
                    color: context.colors.onSurface,
                    fontWeight: AppTokens.fontWeightSemiBold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.space12),
            Text('Período: ${period['start'] ?? '-'} — ${period['end'] ?? '-'}', style: context.textStyles.bodySmall),
            const SizedBox(height: AppTokens.space8),
            Text('Total eventos: $total', style: context.textStyles.titleSmall?.copyWith(color: context.colors.primary, fontWeight: AppTokens.fontWeightBold)),
            if (byAction.isNotEmpty) ...[
              const SizedBox(height: AppTokens.space12),
              Text('Por tipo de acción:', style: context.textStyles.bodySmall?.copyWith(fontWeight: AppTokens.fontWeightSemiBold)),
              ...byAction.entries.map((e) => Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Text('${e.key}: ${e.value}', style: context.textStyles.bodySmall),
              )),
            ],
            if (byUser.isNotEmpty) ...[
              const SizedBox(height: AppTokens.space8),
              Text('Por usuario:', style: context.textStyles.bodySmall?.copyWith(fontWeight: AppTokens.fontWeightSemiBold)),
              ...byUser.entries.take(10).map((e) => Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Text('Usuario ${e.key}: ${e.value}', style: context.textStyles.bodySmall),
              )),
            ],
            if (detail.isNotEmpty) ...[
              const SizedBox(height: AppTokens.space12),
              Text('Detalle (${detail.length} registros)', style: context.textStyles.bodySmall?.copyWith(fontWeight: AppTokens.fontWeightSemiBold)),
              const SizedBox(height: AppTokens.space8),
              ...detail.take(5).map((r) {
                final m = r is Map ? r as Map<String, dynamic> : <String, dynamic>{};
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• ${m['action'] ?? '-'} — usuario ${m['actor_user_id'] ?? '-'}', style: context.textStyles.bodySmall?.copyWith(fontSize: 11)),
                );
              }),
              if (detail.length > 5) Text('... y ${detail.length - 5} más', style: context.textStyles.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
            ],
          ],
        ),
      ),
    );
  }
}
