import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/utils/formatters.dart';
import 'package:be_energy/repositories/transaction_repository.dart';
import 'package:be_energy/utils/metodos.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/callmodels.dart';

class HistorialScreen extends StatefulWidget {
  final MyUser? myUser;

  const HistorialScreen({super.key, this.myUser});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  final TransactionRepository _transactionRepository = TransactionRepository();
  List<dynamic> _records = [];
  bool _loading = true;
  String? _error;
  DateTime _start = DateTime.now().subtract(const Duration(days: 30));
  DateTime _end = DateTime.now();
  /// Filtro por tipo de movimiento (generado, transferido, utilizado)
  String? _filterType;

  List<dynamic> get _filteredRecords {
    if (_filterType == null || _filterType!.isEmpty) return _records;
    return _records.where((r) {
      final item = r is Map ? r as Map<String, dynamic> : <String, dynamic>{};
      final type = (item['type'] ?? item['tipo'] ?? item['source_type'] ?? item['source'] ?? '').toString().toLowerCase();
      if (_filterType == 'generado') return type.contains('generado') || type.contains('generated') || type.contains('produc');
      if (_filterType == 'transferido') return type.contains('transfer') || type.contains('venta') || type.contains('sale');
      if (_filterType == 'utilizado') return type.contains('utilizado') || type.contains('used') || type.contains('consumo') || type.contains('compra');
      return true;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userId = widget.myUser?.idUser ?? 0;
    if (userId <= 0) {
      setState(() {
        _loading = false;
        _error = 'Inicia sesión para ver tu historial';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await _transactionRepository.getEnergyRecords(
        userId: userId,
        start: _start,
        end: _end,
      );
      if (response.success && response.data != null) {
        setState(() {
          _records = response.data is List ? response.data as List<dynamic> : [];
          _loading = false;
        });
      } else {
        setState(() {
          _records = [];
          _loading = false;
          _error = response.message ?? 'Sin datos';
        });
      }
    } catch (e) {
      setState(() {
        _records = [];
        _loading = false;
        _error = 'No se pudo cargar el historial';
      });
    }
  }

  String _recordsToCsv() {
    final sb = StringBuffer();
    sb.writeln('fecha,tipo,kWh,saldo_resultante,referencia');
    for (final r in _filteredRecords) {
      final item = r is Map ? r as Map<String, dynamic> : <String, dynamic>{};
      final kwh = (item['kwh'] ?? item['energy'] ?? 0.0) is num
          ? (item['kwh'] ?? item['energy'] as num).toDouble()
          : 0.0;
      final saldo = item['balance_after'] ?? item['saldo_resultante'] ?? item['balance'] ?? '';
      final ref = item['reference'] ?? item['transaction_id'] ?? item['id'] ?? '';
      sb.writeln('${item['date'] ?? item['created_at'] ?? ''},${item['type'] ?? item['source_type'] ?? 'movimiento'},$kwh,$saldo,$ref');
    }
    return sb.toString();
  }

  String _recordsToJson() {
    return jsonEncode({
      'registros': _filteredRecords,
      'exportado': DateTime.now().toIso8601String(),
    });
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Exportar historial',
                style: context.textStyles.titleMedium?.copyWith(
                  color: context.colors.onSurface,
                  fontWeight: AppTokens.fontWeightBold,
                ),
              ),
              const SizedBox(height: AppTokens.space16),
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _recordsToCsv()));
                  Navigator.pop(ctx);
                  Metodos.flushbarPositivo(context, 'CSV copiado al portapapeles');
                },
                icon: const Icon(Icons.table_chart),
                label: const Text('Copiar como CSV'),
              ),
              const SizedBox(height: AppTokens.space8),
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _recordsToJson()));
                  Navigator.pop(ctx);
                  Metodos.flushbarPositivo(context, 'JSON copiado al portapapeles');
                },
                icon: const Icon(Icons.code),
                label: const Text('Copiar como JSON'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final startPicked = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: DateTime(2020),
      lastDate: _end,
    );
    if (startPicked == null || !mounted) return;
    final endPicked = await showDatePicker(
      context: context,
      initialDate: _end.isAfter(startPicked) ? _end : startPicked,
      firstDate: startPicked,
      lastDate: DateTime.now(),
    );
    if (endPicked == null || !mounted) return;
    setState(() {
      _start = startPicked;
      _end = endPicked;
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Historial de energía',
          style: context.textStyles.titleLarge?.copyWith(
            color: context.colors.onSurface,
            fontWeight: AppTokens.fontWeightBold,
          ),
        ),
        backgroundColor: context.colors.surface,
        foregroundColor: context.colors.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _loading ? null : _pickDateRange,
            tooltip: 'Filtrar por fechas',
          ),
          if (_records.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _showExportOptions,
              tooltip: 'Exportar CSV/JSON',
            ),
        ],
        bottom: _records.isEmpty
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppTokens.space8, vertical: 8),
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Todos'),
                        selected: _filterType == null,
                        onSelected: (_) => setState(() => _filterType = null),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Generado'),
                        selected: _filterType == 'generado',
                        onSelected: (_) => setState(() => _filterType = 'generado'),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Transferido'),
                        selected: _filterType == 'transferido',
                        onSelected: (_) => setState(() => _filterType = 'transferido'),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Utilizado'),
                        selected: _filterType == 'utilizado',
                        onSelected: (_) => setState(() => _filterType = 'utilizado'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
      body: _loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: context.colors.primary),
                  const SizedBox(height: AppTokens.space16),
                  Text(
                    'Cargando historial...',
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTokens.space24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_rounded,
                          size: 64,
                          color: context.colors.outline,
                        ),
                        const SizedBox(height: AppTokens.space16),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: context.textStyles.bodyLarge?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppTokens.space24),
                        TextButton.icon(
                          onPressed: _load,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                )
              : _filteredRecords.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bolt_outlined,
                            size: 64,
                            color: context.colors.outline,
                          ),
                          const SizedBox(height: AppTokens.space16),
                          Text(
                            _records.isEmpty
                                ? 'No hay registros en los últimos 30 días'
                                : 'No hay movimientos del tipo seleccionado',
                            style: context.textStyles.bodyLarge?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: context.colors.primary,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(AppTokens.space16),
                        itemCount: _filteredRecords.length,
                        itemBuilder: (context, index) {
                          final item = _filteredRecords[index] is Map
                              ? _filteredRecords[index] as Map<String, dynamic>
                              : <String, dynamic>{};
                          final kwh = (item['kwh'] ?? item['energy'] ?? 0.0) is num
                              ? (item['kwh'] ?? item['energy'] as num).toDouble()
                              : 0.0;
                          final date = item['date'] ?? item['created_at'] ?? '';
                          final source = item['source'] ?? item['source_type'] ?? 'Energía';
                          return Card(
                            margin: const EdgeInsets.only(bottom: AppTokens.space12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: context.colors.primaryContainer,
                                child: Icon(
                                  Icons.bolt,
                                  color: context.colors.primary,
                                ),
                              ),
                              title: Text(
                                Formatters.formatEnergy(kwh),
                                style: context.textStyles.titleMedium?.copyWith(
                                  color: context.colors.onSurface,
                                  fontWeight: AppTokens.fontWeightSemiBold,
                                ),
                              ),
                              subtitle: Text(
                                '$source · $date',
                                style: context.textStyles.bodySmall?.copyWith(
                                  color: context.colors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
