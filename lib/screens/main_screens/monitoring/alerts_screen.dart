// ignore_for_file: file_names
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/repositories/monitoring_repository.dart';
import 'package:be_energy/utils/metodos.dart';
import 'package:flutter/material.dart';

class AlertsScreen extends StatefulWidget {
  final int? userId;

  const AlertsScreen({super.key, this.userId});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> with SingleTickerProviderStateMixin {
  final MonitoringRepository _repo = MonitoringRepository();
  late TabController _tabController;
  List<dynamic> _rules = [];
  List<dynamic> _alerts = [];
  bool _loadingRules = false;
  bool _loadingAlerts = false;
  DateTime? _alertsStart;
  DateTime? _alertsEnd;
  final _deviceIdController = TextEditingController();
  final _metricController = TextEditingController();
  final _thresholdController = TextEditingController();
  String _operator = '>';
  bool _savingRule = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRules();
    _loadAlerts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _deviceIdController.dispose();
    _metricController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  Future<void> _loadRules() async {
    setState(() => _loadingRules = true);
    try {
      final resp = await _repo.getAlertRules(ownerUserId: widget.userId);
      if (resp.success && resp.data != null) {
        setState(() => _rules = resp.data is List ? resp.data as List<dynamic> : []);
      } else {
        setState(() => _rules = []);
      }
    } catch (_) {
      setState(() => _rules = []);
    }
    setState(() => _loadingRules = false);
  }

  Future<void> _loadAlerts() async {
    setState(() => _loadingAlerts = true);
    try {
      final resp = await _repo.getAlerts(
        ownerUserId: widget.userId,
        startDate: _alertsStart,
        endDate: _alertsEnd,
      );
      if (resp.success && resp.data != null) {
        setState(() => _alerts = resp.data is List ? resp.data as List<dynamic> : []);
      } else {
        setState(() => _alerts = []);
      }
    } catch (_) {
      setState(() => _alerts = []);
    }
    setState(() => _loadingAlerts = false);
  }

  Future<void> _createRule() async {
    final userId = widget.userId ?? 0;
    final deviceId = _deviceIdController.text.trim();
    final metric = _metricController.text.trim().isEmpty ? 'power_kw' : _metricController.text.trim();
    final threshold = double.tryParse(_thresholdController.text.replaceAll(',', '.'));
    if (userId <= 0) {
      Metodos.flushbarNegativo(context, 'Inicia sesión para crear reglas');
      return;
    }
    if (deviceId.isEmpty) {
      Metodos.flushbarNegativo(context, 'Ingresa ID del dispositivo');
      return;
    }
    if (threshold == null || threshold <= 0) {
      Metodos.flushbarNegativo(context, 'Umbral debe ser un número positivo');
      return;
    }
    final apiOperator = _operator;
    setState(() => _savingRule = true);
    try {
      final resp = await _repo.createAlertRule(
        ownerUserId: userId,
        deviceId: deviceId,
        metric: metric,
        operator: apiOperator,
        threshold: threshold,
      );
      if (resp.success && mounted) {
        Metodos.flushbarPositivo(context, 'Regla de alerta creada');
        _deviceIdController.clear();
        _metricController.clear();
        _thresholdController.clear();
        _loadRules();
      } else if (mounted) {
        Metodos.flushbarNegativo(context, resp.message ?? 'Error al crear regla');
      }
    } catch (e) {
      if (mounted) Metodos.flushbarNegativo(context, 'Error de conexión');
    }
    if (mounted) setState(() => _savingRule = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Alertas de consumo',
          style: context.textStyles.titleLarge?.copyWith(
            color: context.colors.onSurface,
            fontWeight: AppTokens.fontWeightBold,
          ),
        ),
        backgroundColor: context.colors.surface,
        foregroundColor: context.colors.onSurface,
        bottom: TabBar(
          controller: _tabController,
          labelColor: context.colors.primary,
          unselectedLabelColor: context.colors.onSurfaceVariant,
          tabs: const [
            Tab(text: 'Reglas'),
            Tab(text: 'Historial'),
            Tab(text: 'Nueva regla'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRulesTab(),
          _buildAlertsTab(),
          _buildNewRuleTab(),
        ],
      ),
    );
  }

  Widget _buildRulesTab() {
    if (_loadingRules) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: context.colors.primary),
            const SizedBox(height: AppTokens.space16),
            Text(
              'Cargando reglas...',
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }
    if (_rules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rule_outlined, size: 64, color: context.colors.outline),
            const SizedBox(height: AppTokens.space16),
            Text(
              'No tienes reglas de alerta.\nCrea una en la pestaña "Nueva regla".',
              textAlign: TextAlign.center,
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadRules,
      color: context.colors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppTokens.space16),
        itemCount: _rules.length,
        itemBuilder: (context, i) {
          final r = _rules[i] is Map ? _rules[i] as Map<String, dynamic> : <String, dynamic>{};
          final metric = r['metric'] ?? '-';
          final op = r['operator'] ?? '>';
          final threshold = r['threshold'] ?? 0;
          return Card(
            margin: const EdgeInsets.only(bottom: AppTokens.space8),
            child: ListTile(
              title: Text(
                '$metric $op $threshold',
                style: context.textStyles.titleSmall?.copyWith(
                  color: context.colors.onSurface,
                ),
              ),
              subtitle: Text(
                r['device_id']?.toString() ?? '',
                style: context.textStyles.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAlertsTab() {
    if (_loadingAlerts) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: context.colors.primary),
            const SizedBox(height: AppTokens.space16),
            Text(
              'Cargando alertas...',
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadAlerts,
      color: context.colors.primary,
      child: ListView(
        padding: const EdgeInsets.all(AppTokens.space16),
        children: [
          OutlinedButton.icon(
            onPressed: () async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (range != null) {
                setState(() {
                  _alertsStart = range.start;
                  _alertsEnd = range.end;
                });
                _loadAlerts();
              }
            },
            icon: const Icon(Icons.date_range),
            label: Text(
              _alertsStart != null && _alertsEnd != null
                  ? '${_alertsStart!.day}/${_alertsStart!.month} - ${_alertsEnd!.day}/${_alertsEnd!.month}'
                  : 'Filtrar por fechas',
            ),
          ),
          const SizedBox(height: AppTokens.space16),
          ..._alerts.map((e) {
            final a = e is Map ? e as Map<String, dynamic> : <String, dynamic>{};
            final metric = a['metric'] ?? '';
            final value = a['value'];
            final threshold = a['threshold'];
            final op = a['operator'] ?? '>';
            final msg = a['message'] ?? (metric.isNotEmpty && value != null && threshold != null
                ? '$metric $op $threshold (valor: $value)'
                : a['severity'] ?? 'Alerta de consumo elevado');
            return Card(
              margin: const EdgeInsets.only(bottom: AppTokens.space8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: context.colors.errorContainer,
                  child: Icon(Icons.warning_amber, color: context.colors.error, size: 22),
                ),
                title: Text(
                  msg.toString(),
                  style: context.textStyles.titleSmall?.copyWith(
                    color: context.colors.onSurface,
                    fontWeight: AppTokens.fontWeightSemiBold,
                  ),
                ),
                subtitle: Text(
                  a['timestamp']?.toString() ?? a['created_at']?.toString() ?? '',
                  style: context.textStyles.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNewRuleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTokens.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Define un umbral para recibir alertas cuando se supere',
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppTokens.space24),
          TextField(
            controller: _deviceIdController,
            decoration: const InputDecoration(
              labelText: 'ID del dispositivo',
              hintText: 'Ej: medidor-001',
            ),
          ),
          const SizedBox(height: AppTokens.space16),
          TextField(
            controller: _metricController,
            decoration: const InputDecoration(
              labelText: 'Métrica (opcional)',
              hintText: 'power_kw, energy_kwh',
            ),
          ),
          const SizedBox(height: AppTokens.space16),
          DropdownButtonFormField<String>(
            value: _operator,
            decoration: const InputDecoration(
              labelText: 'Operador',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: '>', child: Text('Mayor que (>)')),
              DropdownMenuItem(value: '>=', child: Text('Mayor o igual (≥)')),
              DropdownMenuItem(value: '<', child: Text('Menor que (<)')),
              DropdownMenuItem(value: '<=', child: Text('Menor o igual (≤)')),
            ],
            onChanged: (v) => setState(() => _operator = v ?? '>'),
          ),
          const SizedBox(height: AppTokens.space16),
          TextField(
            controller: _thresholdController,
            decoration: const InputDecoration(
              labelText: 'Umbral',
              hintText: 'Ej: 5.0',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: AppTokens.space32),
          FilledButton(
            onPressed: _savingRule ? null : _createRule,
            child: Text(_savingRule ? 'Guardando...' : 'Crear regla de alerta'),
          ),
        ],
      ),
    );
  }
}
