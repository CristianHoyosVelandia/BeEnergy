// ignore_for_file: file_names
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/models/my_user.dart';
import 'package:be_energy/repositories/audit_repository.dart';
import 'package:be_energy/utils/metodos.dart';
import 'package:flutter/material.dart';

class AuditLogsScreen extends StatefulWidget {
  final MyUser? myUser;

  const AuditLogsScreen({super.key, this.myUser});

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  final AuditRepository _repo = AuditRepository();
  List<dynamic> _logs = [];
  bool _loading = false;
  int _page = 1;
  int _total = 0;
  static const int _pageSize = 50;
  DateTime? _startDate;
  DateTime? _endDate;
  final _userIdController = TextEditingController();
  final _transactionIdController = TextEditingController();
  final _actionController = TextEditingController();

  @override
  void dispose() {
    _userIdController.dispose();
    _transactionIdController.dispose();
    _actionController.dispose();
    super.dispose();
  }

  Future<void> _loadLogs({bool resetPage = true}) async {
    if (resetPage) _page = 1;
    setState(() => _loading = true);
    try {
      final userId = int.tryParse(_userIdController.text.trim());
      final transactionId = _transactionIdController.text.trim().isEmpty ? null : _transactionIdController.text.trim();
      final action = _actionController.text.trim().isEmpty ? null : _actionController.text.trim();
      final resp = await _repo.queryLogs(
        userId: userId,
        transactionId: transactionId,
        startDate: _startDate,
        endDate: _endDate,
        action: action,
        page: _page,
        limit: _pageSize,
      );
      if (resp.success && resp.data != null && mounted) {
        final data = resp.data as Map<String, dynamic>;
        final list = data['logs'] ?? data['data'] ?? data['records'] ?? data['items'];
        final totalVal = data['total'] ?? data['total_count'] ?? data['totalCount'];
        setState(() {
          _logs = list is List ? list : [];
          _total = totalVal is int ? totalVal : _logs.length;
        });
      } else {
        setState(() => _logs = []);
      }
    } catch (e) {
      if (mounted) {
        Metodos.flushbarNegativo(context, 'Error al cargar registros');
        setState(() => _logs = []);
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _pickDateRange() async {
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
      _loadLogs();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.myUser != null && !widget.myUser!.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Registros de auditoría')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 64, color: context.colors.error),
              const SizedBox(height: 16),
              Text('Acceso denegado', style: context.textStyles.titleLarge),
              const SizedBox(height: 8),
              Text('Solo administradores pueden consultar registros de auditoría.', textAlign: TextAlign.center, style: context.textStyles.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant)),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Registros de auditoría',
          style: context.textStyles.titleLarge?.copyWith(
            color: context.colors.onSurface,
            fontWeight: AppTokens.fontWeightBold,
          ),
        ),
        backgroundColor: context.colors.surface,
        foregroundColor: context.colors.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : () => _loadLogs(),
          ),
        ],
      ),
      body: Column(
        children: [
          Material(
            color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
            child: Padding(
              padding: const EdgeInsets.all(AppTokens.space12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _userIdController,
                          decoration: const InputDecoration(
                            labelText: 'ID Usuario',
                            hintText: 'Opcional',
                            isDense: true,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: AppTokens.space8),
                      Expanded(
                        child: TextField(
                          controller: _transactionIdController,
                          decoration: const InputDecoration(
                            labelText: 'ID Transacción',
                            hintText: 'Opcional',
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTokens.space8),
                  TextField(
                    controller: _actionController,
                    decoration: const InputDecoration(
                      labelText: 'Acción (opcional)',
                      hintText: 'Ej: telemetry.ingest, login',
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: AppTokens.space8),
                  Row(
                    children: [
                      Text(
                        _startDate != null && _endDate != null
                            ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year} - ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                            : 'Rango de fechas',
                        style: context.textStyles.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                      TextButton(
                        onPressed: _pickDateRange,
                        child: const Text('Seleccionar'),
                      ),
                    ],
                  ),
                  FilledButton(
                    onPressed: _loading ? null : () => _loadLogs(),
                    child: const Text('Buscar'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _loading && _logs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: context.colors.primary),
                        const SizedBox(height: AppTokens.space16),
                        Text(
                          'Cargando...',
                          style: context.textStyles.bodyMedium?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : _logs.isEmpty
                    ? Center(
                        child: Text(
                          'No hay registros con los filtros indicados.',
                          style: context.textStyles.bodyMedium?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: RefreshIndicator(
                              onRefresh: () => _loadLogs(),
                              color: context.colors.primary,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(AppTokens.space16),
                                itemCount: _logs.length,
                                itemBuilder: (context, i) {
                                  final log = _logs[i] is Map
                                      ? _logs[i] as Map<String, dynamic>
                                      : <String, dynamic>{};
                                  final action = log['action'] ?? log['event_type'] ?? '-';
                                  final userId = log['actor_user_id'] ?? log['user_id'] ?? log['userId'];
                                  final resourceType = log['resource_type'];
                                  final resourceId = log['resource_id'];
                                  final ts = log['timestamp'] ?? log['created_at'] ?? log['date'] ?? '';
                                  final deviceId = log['actor_device_id'];
                                  final details = log['details'];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: AppTokens.space8),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: context.colors.primaryContainer,
                                        child: Icon(Icons.article_outlined, color: context.colors.primary, size: 20),
                                      ),
                                      title: Text(
                                        action.toString(),
                                        style: context.textStyles.titleSmall?.copyWith(
                                          color: context.colors.onSurface,
                                          fontWeight: AppTokens.fontWeightSemiBold,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Usuario: ${userId ?? deviceId ?? '-'}${resourceType != null ? ' · $resourceType' : ''}${resourceId != null ? ' #$resourceId' : ''}',
                                            style: context.textStyles.bodySmall?.copyWith(
                                              color: context.colors.onSurfaceVariant,
                                            ),
                                          ),
                                          if (ts.toString().isNotEmpty)
                                            Text(
                                              ts.toString().length > 25 ? ts.toString().substring(0, 25) : ts.toString(),
                                              style: context.textStyles.bodySmall?.copyWith(
                                                color: context.colors.outline,
                                                fontSize: 11,
                                              ),
                                            ),
                                        ],
                                      ),
                                      isThreeLine: true,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Material(
                            color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Página $_page${_total > 0 ? ' · ${(_total / _pageSize).ceil().clamp(1, 10000)} páginas' : ''}',
                                    style: context.textStyles.bodySmall?.copyWith(
                                      color: context.colors.onSurfaceVariant,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      TextButton(
                                        onPressed: _page > 1 && !_loading
                                            ? () {
                                                setState(() => _page--);
                                                _loadLogs(resetPage: false);
                                              }
                                            : null,
                                        child: const Text('Anterior'),
                                      ),
                                      const SizedBox(width: 8),
                                      TextButton(
                                        onPressed: _logs.length >= _pageSize && !_loading
                                            ? () {
                                                setState(() => _page++);
                                                _loadLogs(resetPage: false);
                                              }
                                            : null,
                                        child: const Text('Siguiente'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
