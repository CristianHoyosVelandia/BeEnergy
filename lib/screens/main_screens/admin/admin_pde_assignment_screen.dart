import 'package:flutter/material.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import '../../../data/fake_data_phase2.dart';

/// Pantalla de Asignación PDE - ADMINISTRADOR
/// Permite al administrador asignar el PDE mensual (≤10% del Tipo 2 total)
/// FASE 2 - Transaccional - Diciembre 2025
class AdminPDEAssignmentScreen extends StatefulWidget {
  const AdminPDEAssignmentScreen({super.key});

  @override
  State<AdminPDEAssignmentScreen> createState() => _AdminPDEAssignmentScreenState();
}

class _AdminPDEAssignmentScreenState extends State<AdminPDEAssignmentScreen> {
  // Control de asignación PDE
  double _pdeToAssign = 0.0;
  final Map<int, double> _consumerAllocations = {};

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _initializeAllocations();
  }

  /// Inicializa las asignaciones con distribución homogénea
  void _initializeAllocations() {
    final consumers = FakeDataPhase2.allMembers
        .where((m) => !m.isProsumer)
        .toList();

    // Total Tipo 2 disponible (María tiene 70 kWh)
    final totalType2 = FakeDataPhase2.mariaDec2025.surplusType2;

    // PDE máximo permitido: 10%
    final maxPDE = totalType2 * 0.10;

    // Distribución homogénea entre consumidores
    _pdeToAssign = maxPDE;
    final perConsumer = consumers.isNotEmpty ? maxPDE / consumers.length : 0.0;

    for (final consumer in consumers) {
      _consumerAllocations[consumer.userId] = perConsumer;
    }
  }

  /// Calcula el total de PDE asignado
  double get _totalPDEAssigned {
    return _consumerAllocations.values.fold(0.0, (sum, value) => sum + value);
  }

  /// Calcula el porcentaje de PDE respecto al Tipo 2 total
  double get _pdePercentage {
    final totalType2 = FakeDataPhase2.mariaDec2025.surplusType2;
    return totalType2 > 0 ? (_totalPDEAssigned / totalType2) * 100 : 0.0;
  }

  /// Verifica si cumple el límite regulatorio
  bool get _isCompliant => _pdePercentage <= 10.0;

  /// Asigna el PDE
  Future<void> _assignPDE() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // Validar que haya asignaciones
      if (_totalPDEAssigned <= 0) {
        throw Exception('Debe asignar al menos 1 kWh de PDE');
      }

      // Validar cumplimiento regulatorio
      if (!_isCompliant) {
        throw Exception('PDE excede el límite regulatorio del 10%');
      }

      // Simular guardado (en producción sería API call)
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _successMessage = 'PDE asignado correctamente (${_pdePercentage.toStringAsFixed(1)}%)';
      });

      // Mostrar diálogo de confirmación
      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: AppTokens.space12),
            const Text('PDE Asignado'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('El Programa de Distribución de Excedentes ha sido asignado exitosamente.'),
            SizedBox(height: AppTokens.space16),
            _buildInfoRow('Total PDE', '${_totalPDEAssigned.toStringAsFixed(2)} kWh'),
            _buildInfoRow('Porcentaje', '${_pdePercentage.toStringAsFixed(1)}%'),
            _buildInfoRow('Consumidores', '${_consumerAllocations.length}'),
            SizedBox(height: AppTokens.space16),
            Container(
              padding: EdgeInsets.all(AppTokens.space12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: AppTokens.borderRadiusMedium,
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified, color: Colors.green, size: 20),
                  SizedBox(width: AppTokens.space8),
                  Expanded(
                    child: Text(
                      'Cumple CREG 101 072 Art 3.4',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: Colors.green,
                        fontWeight: AppTokens.fontWeightSemiBold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppTokens.space4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.textStyles.bodyMedium),
          Text(
            value,
            style: context.textStyles.bodyMedium?.copyWith(
              fontWeight: AppTokens.fontWeightSemiBold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalType2 = FakeDataPhase2.mariaDec2025.surplusType2;
    final maxPDE = totalType2 * 0.10;
    final consumers = FakeDataPhase2.allMembers.where((m) => !m.isProsumer).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asignar PDE - Diciembre 2025'),
        backgroundColor: AppTokens.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header: Resumen Tipo 2
                  _buildHeaderCard(totalType2, maxPDE),

                  // Slider: PDE a asignar
                  _buildPDESlider(maxPDE),

                  // Validación
                  _buildValidationCard(),

                  // Lista de consumidores
                  _buildConsumersList(consumers),

                  // Mensajes
                  if (_errorMessage != null) _buildErrorMessage(),
                  if (_successMessage != null) _buildSuccessMessage(),

                  SizedBox(height: AppTokens.space64),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _assignPDE,
        backgroundColor: _isCompliant ? AppTokens.primaryBlue : Colors.grey,
        icon: const Icon(Icons.check),
        label: const Text('Asignar PDE'),
      ),
    );
  }

  Widget _buildHeaderCard(double totalType2, double maxPDE) {
    return Container(
      margin: EdgeInsets.all(AppTokens.space16),
      padding: EdgeInsets.all(AppTokens.space20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTokens.primaryBlue, AppTokens.primaryBlue.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppTokens.borderRadiusLarge,
        boxShadow: [
          BoxShadow(
            color: AppTokens.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.energy_savings_leaf, color: Colors.white, size: 32),
              SizedBox(width: AppTokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tipo 2 Disponible',
                      style: context.textStyles.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: AppTokens.fontWeightBold,
                      ),
                    ),
                    SizedBox(height: AppTokens.space4),
                    Text(
                      'Excedentes vendibles de la comunidad',
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space20),
          Container(
            padding: EdgeInsets.all(AppTokens.space16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: AppTokens.borderRadiusMedium,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn('Total Tipo 2', '${totalType2.toStringAsFixed(0)} kWh', Colors.white),
                Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.3)),
                _buildStatColumn('PDE Máximo (10%)', '${maxPDE.toStringAsFixed(1)} kWh', Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: context.textStyles.headlineSmall?.copyWith(
            color: color,
            fontWeight: AppTokens.fontWeightBold,
          ),
        ),
        SizedBox(height: AppTokens.space4),
        Text(
          label,
          style: context.textStyles.bodySmall?.copyWith(
            color: color.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildPDESlider(double maxPDE) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16, vertical: AppTokens.space8),
      child: Padding(
        padding: EdgeInsets.all(AppTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PDE a Asignar',
              style: context.textStyles.titleMedium?.copyWith(
                fontWeight: AppTokens.fontWeightSemiBold,
              ),
            ),
            SizedBox(height: AppTokens.space16),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _pdeToAssign,
                    min: 0,
                    max: maxPDE,
                    divisions: 20,
                    label: '${_pdeToAssign.toStringAsFixed(1)} kWh',
                    onChanged: (value) {
                      setState(() {
                        _pdeToAssign = value;
                        _updateConsumerAllocations();
                      });
                    },
                  ),
                ),
                SizedBox(width: AppTokens.space12),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTokens.space12,
                    vertical: AppTokens.space8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTokens.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: AppTokens.borderRadiusMedium,
                  ),
                  child: Text(
                    '${_pdeToAssign.toStringAsFixed(1)} kWh',
                    style: context.textStyles.bodyLarge?.copyWith(
                      fontWeight: AppTokens.fontWeightBold,
                      color: AppTokens.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _updateConsumerAllocations() {
    final consumers = FakeDataPhase2.allMembers.where((m) => !m.isProsumer).toList();
    final perConsumer = consumers.isNotEmpty ? _pdeToAssign / consumers.length : 0.0;

    setState(() {
      for (final consumer in consumers) {
        _consumerAllocations[consumer.userId] = perConsumer;
      }
    });
  }

  Widget _buildValidationCard() {
    final isCompliant = _isCompliant;
    final percentage = _pdePercentage;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16, vertical: AppTokens.space8),
      color: isCompliant ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
      child: Padding(
        padding: EdgeInsets.all(AppTokens.space16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  isCompliant ? Icons.check_circle : Icons.warning,
                  color: isCompliant ? Colors.green : Colors.red,
                  size: 32,
                ),
                SizedBox(width: AppTokens.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCompliant ? 'Cumple Regulación' : 'Excede Límite',
                        style: context.textStyles.titleMedium?.copyWith(
                          color: isCompliant ? Colors.green : Colors.red,
                          fontWeight: AppTokens.fontWeightBold,
                        ),
                      ),
                      SizedBox(height: AppTokens.space4),
                      Text(
                        'CREG 101 072 Art 3.4',
                        style: context.textStyles.bodySmall?.copyWith(
                          color: isCompliant ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: context.textStyles.headlineMedium?.copyWith(
                    color: isCompliant ? Colors.green : Colors.red,
                    fontWeight: AppTokens.fontWeightBold,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTokens.space12),
            LinearProgressIndicator(
              value: percentage / 10.0,
              backgroundColor: Colors.grey.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                isCompliant ? Colors.green : Colors.red,
              ),
            ),
            SizedBox(height: AppTokens.space8),
            Text(
              'Límite máximo: 10% del Tipo 2 total',
              style: context.textStyles.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsumersList(List consumers) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16, vertical: AppTokens.space8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(AppTokens.space16),
            child: Text(
              'Consumidores Elegibles',
              style: context.textStyles.titleMedium?.copyWith(
                fontWeight: AppTokens.fontWeightSemiBold,
              ),
            ),
          ),
          const Divider(height: 1),
          ...consumers.map((consumer) => _buildConsumerTile(consumer)),
        ],
      ),
    );
  }

  Widget _buildConsumerTile(consumer) {
    final allocation = _consumerAllocations[consumer.userId] ?? 0.0;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppTokens.primaryBlue.withValues(alpha: 0.2),
        child: Text(
          consumer.userName[0].toUpperCase(),
          style: const TextStyle(
            color: AppTokens.primaryBlue,
            fontWeight: AppTokens.fontWeightBold,
          ),
        ),
      ),
      title: Text(consumer.fullName),
      subtitle: Text('NIU: ${consumer.niu}'),
      trailing: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppTokens.space12,
          vertical: AppTokens.space8,
        ),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: AppTokens.borderRadiusMedium,
          border: Border.all(color: Colors.green),
        ),
        child: Text(
          '${allocation.toStringAsFixed(2)} kWh',
          style: context.textStyles.bodyMedium?.copyWith(
            color: Colors.green,
            fontWeight: AppTokens.fontWeightSemiBold,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      margin: EdgeInsets.all(AppTokens.space16),
      padding: EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: AppTokens.borderRadiusMedium,
        border: Border.all(color: Colors.red),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red),
          SizedBox(width: AppTokens.space12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: context.textStyles.bodyMedium?.copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      margin: EdgeInsets.all(AppTokens.space16),
      padding: EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: AppTokens.borderRadiusMedium,
        border: Border.all(color: Colors.green),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: AppTokens.space12),
          Expanded(
            child: Text(
              _successMessage!,
              style: context.textStyles.bodyMedium?.copyWith(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}
