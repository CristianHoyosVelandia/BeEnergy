// ignore_for_file: file_names
import 'dart:async';

import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/utils/formatters.dart';
import 'package:be_energy/repositories/monitoring_repository.dart';
import 'package:be_energy/utils/metodos.dart';
import 'package:flutter/material.dart';

class ConsumptionScreen extends StatefulWidget {
  final int? userId;

  const ConsumptionScreen({super.key, this.userId});

  @override
  State<ConsumptionScreen> createState() => _ConsumptionScreenState();
}

class _ConsumptionScreenState extends State<ConsumptionScreen> {
  final MonitoringRepository _repo = MonitoringRepository();
  final _deviceIdController = TextEditingController(text: '');
  final _deviceTokenController = TextEditingController(text: '');
  Map<String, dynamic>? _latest;
  List<dynamic> _history = [];
  bool _loading = false;
  bool _autoRefreshEnabled = false;
  Timer? _autoRefreshTimer;
  static const _autoRefreshInterval = Duration(seconds: 15);

  Future<void> _loadLatest() async {
    final deviceId = _deviceIdController.text.trim();
    final token = _deviceTokenController.text.trim();
    if (deviceId.isEmpty || token.isEmpty) {
      Metodos.flushbarNegativo(context, 'Ingresa ID y token del dispositivo');
      return;
    }
    setState(() => _loading = true);
    try {
      final resp = await _repo.getLatestMeasurement(deviceId: deviceId, deviceToken: token);
      if (resp.success && resp.data != null && mounted) {
        setState(() => _latest = resp.data as Map<String, dynamic>);
      } else {
        setState(() => _latest = null);
      }
      _startAutoRefreshIfEnabled();
    } catch (e) {
      if (mounted) {
        Metodos.flushbarNegativo(context, 'Error al obtener medición');
        setState(() => _latest = null);
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  void _startAutoRefreshIfEnabled() {
    _autoRefreshTimer?.cancel();
    if (!_autoRefreshEnabled || !mounted) return;
    final deviceId = _deviceIdController.text.trim();
    final token = _deviceTokenController.text.trim();
    if (deviceId.isEmpty || token.isEmpty) return;
    _autoRefreshTimer = Timer.periodic(_autoRefreshInterval, (_) {
      if (!mounted) return;
      _repo.getLatestMeasurement(deviceId: deviceId, deviceToken: token).then((resp) {
        if (resp.success && resp.data != null && mounted) {
          setState(() => _latest = resp.data as Map<String, dynamic>);
        }
      });
    });
  }

  void _stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }

  @override
  void dispose() {
    _stopAutoRefresh();
    _deviceIdController.dispose();
    _deviceTokenController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final deviceId = _deviceIdController.text.trim();
    final token = _deviceTokenController.text.trim();
    if (deviceId.isEmpty || token.isEmpty) {
      Metodos.flushbarNegativo(context, 'Ingresa ID y token del dispositivo');
      return;
    }
    setState(() => _loading = true);
    try {
      final resp = await _repo.getMeasurementHistory(
        deviceId: deviceId,
        deviceToken: token,
        limit: 100,
      );
      if (resp.success && resp.data != null && mounted) {
        setState(() => _history = resp.data is List ? resp.data as List<dynamic> : []);
      } else {
        setState(() => _history = []);
      }
    } catch (e) {
      if (mounted) {
        Metodos.flushbarNegativo(context, 'Error al obtener historial');
        setState(() => _history = []);
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Consumo en tiempo real',
          style: context.textStyles.titleLarge?.copyWith(
            color: context.colors.onSurface,
            fontWeight: AppTokens.fontWeightBold,
          ),
        ),
        backgroundColor: context.colors.surface,
        foregroundColor: context.colors.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Credenciales del medidor',
              style: context.textStyles.titleSmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppTokens.space8),
            TextField(
              controller: _deviceIdController,
              decoration: const InputDecoration(
                labelText: 'ID del dispositivo',
                hintText: 'Ej: medidor-001',
              ),
            ),
            const SizedBox(height: AppTokens.space12),
            TextField(
              controller: _deviceTokenController,
              decoration: const InputDecoration(
                labelText: 'Token del dispositivo',
                hintText: 'Token de autenticación',
              ),
              obscureText: true,
            ),
            const SizedBox(height: AppTokens.space16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _loading ? null : _loadLatest,
                    icon: const Icon(Icons.speed),
                    label: const Text('Última'),
                  ),
                ),
                const SizedBox(width: AppTokens.space8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _loading ? null : _loadHistory,
                    icon: const Icon(Icons.history),
                    label: const Text('Historial'),
                  ),
                ),
              ],
            ),
            if (_loading) ...[
              const SizedBox(height: AppTokens.space16),
              Center(
                child: CircularProgressIndicator(color: context.colors.primary),
              ),
            ],
            if (_latest != null && !_loading) ...[
              const SizedBox(height: AppTokens.space24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Última medición',
                    style: context.textStyles.titleMedium?.copyWith(
                      color: context.colors.onSurface,
                    ),
                  ),
                  Row(
                    children: [
                      Text('Actualizar cada 15 s', style: context.textStyles.bodySmall?.copyWith(color: context.colors.onSurfaceVariant)),
                      Switch(
                        value: _autoRefreshEnabled,
                        onChanged: (v) {
                          setState(() => _autoRefreshEnabled = v);
                          if (v) _startAutoRefreshIfEnabled();
                          else _stopAutoRefresh();
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppTokens.space8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTokens.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMetricRow('Potencia (kW)', _latest!['power_kw'] ?? _latest!['power'] ?? _latest!['value']),
                      _buildMetricRow('Energía (kWh)', _latest!['energy_kwh'] ?? _latest!['energy']),
                      if (_latest!['timestamp'] != null)
                        Text(
                          'Fecha: ${_latest!['timestamp']}',
                          style: context.textStyles.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
            if (_history.isNotEmpty && !_loading) ...[
              const SizedBox(height: AppTokens.space24),
              Text(
                'Historial reciente',
                style: context.textStyles.titleMedium?.copyWith(
                  color: context.colors.onSurface,
                ),
              ),
              const SizedBox(height: AppTokens.space8),
              ..._history.take(20).map((e) {
                final m = e is Map ? e as Map<String, dynamic> : <String, dynamic>{};
                final val = m['power_kw'] ?? m['power'] ?? m['value'] ?? 0;
                final ts = m['timestamp'] ?? m['created_at'] ?? '';
                return ListTile(
                  title: Text(Formatters.formatPower(val is num ? val.toDouble() : 0)),
                  subtitle: Text(ts.toString()),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, dynamic value) {
    if (value == null) return const SizedBox.shrink();
    final numVal = value is num ? value.toDouble() : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTokens.space8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          Text(
            label.contains('kW') ? Formatters.formatPower(numVal) : Formatters.formatEnergy(numVal),
            style: context.textStyles.titleMedium?.copyWith(
              color: context.colors.primary,
              fontWeight: AppTokens.fontWeightSemiBold,
            ),
          ),
        ],
      ),
    );
  }
}
