import 'package:flutter/material.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/utils/formatters.dart';
import '../../../data/fake_data.dart';
import '../../../models/billing_models.dart';

/// Pantalla de Liquidación Mensual
/// Muestra el detalle de facturación de todos los miembros - Noviembre 2025
class MonthlyBillingScreen extends StatefulWidget {
  const MonthlyBillingScreen({super.key});

  @override
  State<MonthlyBillingScreen> createState() => _MonthlyBillingScreenState();
}

class _MonthlyBillingScreenState extends State<MonthlyBillingScreen> {
  String _filterType = 'all'; // 'all', 'prosumer', 'consumer'
  String _selectedScenario = 'p2p'; // 'traditional', 'credits', 'pde', 'p2p'

  List<UserBilling> get filteredBillings {
    var billings = FakeData.userBillings;

    if (_filterType == 'prosumer') {
      final prosumerIds = FakeData.members.where((m) => m.isProsumer).map((m) => m.userId).toList();
      billings = billings.where((b) => prosumerIds.contains(b.userId)).toList();
    } else if (_filterType == 'consumer') {
      final consumerIds = FakeData.members.where((m) => m.isConsumer).map((m) => m.userId).toList();
      billings = billings.where((b) => consumerIds.contains(b.userId)).toList();
    }

    return billings;
  }

  double _getCostForScenario(UserBilling billing) {
    switch (_selectedScenario) {
      case 'traditional':
        return billing.traditionalCost;
      case 'credits':
        return billing.creditsScenarioCost;
      case 'pde':
        return billing.pdeScenarioCost;
      case 'p2p':
      default:
        return billing.p2pScenarioCost;
    }
  }

  double _getSavings(UserBilling billing) {
    switch (_selectedScenario) {
      case 'credits':
        return billing.savingsWithCredits;
      case 'pde':
        return billing.savingsWithPDE;
      case 'p2p':
        return billing.savingsWithP2P;
      case 'traditional':
      default:
        return 0;
    }
  }

  Widget _buildHeader() {
    final savings = FakeData.communitySavings;
    final totalTraditional = savings.totalTraditionalCost;

    double totalCost;
    double totalSavings;

    switch (_selectedScenario) {
      case 'credits':
        totalCost = savings.totalWithCredits;
        totalSavings = savings.savingsWithCredits;
        break;
      case 'pde':
        totalCost = savings.totalWithPDE;
        totalSavings = savings.savingsWithPDE;
        break;
      case 'p2p':
        totalCost = savings.totalWithP2P;
        totalSavings = savings.savingsWithP2P;
        break;
      case 'traditional':
      default:
        totalCost = totalTraditional;
        totalSavings = 0;
    }

    final savingsPercent = totalTraditional > 0 ? (totalSavings / totalTraditional) * 100 : 0;

    return Container(
      margin: EdgeInsets.all(AppTokens.space16),
      padding: EdgeInsets.all(AppTokens.space20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.teal,
            Colors.teal.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppTokens.borderRadiusLarge,
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long_outlined, color: Colors.white, size: 32),
              SizedBox(width: AppTokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Liquidación Mensual',
                      style: context.textStyles.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: AppTokens.fontWeightBold,
                      ),
                    ),
                    SizedBox(height: AppTokens.space4),
                    Text(
                      'Noviembre 2025 • Comunidad UAO',
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
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          Formatters.formatCurrency(totalCost),
                          style: context.textStyles.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: AppTokens.fontWeightBold,
                          ),
                        ),
                        SizedBox(height: AppTokens.space4),
                        Text(
                          'Costo Total',
                          style: context.textStyles.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                    if (_selectedScenario != 'traditional') ...[
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      Column(
                        children: [
                          Text(
                            Formatters.formatCurrency(totalSavings),
                            style: context.textStyles.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: AppTokens.fontWeightBold,
                            ),
                          ),
                          SizedBox(height: AppTokens.space4),
                          Text(
                            'Ahorro Total',
                            style: context.textStyles.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                if (_selectedScenario != 'traditional') ...[
                  SizedBox(height: AppTokens.space16),
                  Divider(color: Colors.white.withValues(alpha: 0.3), height: 1),
                  SizedBox(height: AppTokens.space16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.savings_outlined, color: Colors.green, size: 28),
                      SizedBox(width: AppTokens.space8),
                      Text(
                        'Ahorro Promedio: ${savingsPercent.toStringAsFixed(1)}%',
                        style: context.textStyles.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: AppTokens.fontWeightBold,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioSelector() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Escenario de Facturación:',
            style: context.textStyles.titleMedium?.copyWith(
              fontWeight: AppTokens.fontWeightBold,
            ),
          ),
          SizedBox(height: AppTokens.space12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildScenarioChip('Tradicional', 'traditional', Colors.grey),
                SizedBox(width: AppTokens.space8),
                _buildScenarioChip('Créditos', 'credits', Colors.blue),
                SizedBox(width: AppTokens.space8),
                _buildScenarioChip('PDE', 'pde', Colors.orange),
                SizedBox(width: AppTokens.space8),
                _buildScenarioChip('P2P', 'p2p', Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioChip(String label, String value, Color color) {
    final isSelected = _selectedScenario == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedScenario = value;
        });
      },
      backgroundColor: context.colors.surface,
      selectedColor: color,
      labelStyle: context.textStyles.bodyMedium?.copyWith(
        color: isSelected ? Colors.white : context.colors.onSurface,
        fontWeight: isSelected ? AppTokens.fontWeightBold : AppTokens.fontWeightMedium,
      ),
      side: BorderSide(
        color: isSelected ? color : context.colors.outline.withValues(alpha: 0.3),
        width: isSelected ? 2 : 1,
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtrar por tipo:',
            style: context.textStyles.bodyMedium?.copyWith(
              fontWeight: AppTokens.fontWeightMedium,
            ),
          ),
          SizedBox(height: AppTokens.space12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Todos', 'all'),
                SizedBox(width: AppTokens.space8),
                _buildFilterChip('Prosumidores', 'prosumer'),
                SizedBox(width: AppTokens.space8),
                _buildFilterChip('Consumidores', 'consumer'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterType == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterType = value;
        });
      },
      backgroundColor: context.colors.surface,
      selectedColor: Colors.teal,
      checkmarkColor: Colors.white,
      labelStyle: context.textStyles.bodyMedium?.copyWith(
        color: isSelected ? Colors.white : context.colors.onSurface,
        fontWeight: isSelected ? AppTokens.fontWeightBold : AppTokens.fontWeightMedium,
      ),
      side: BorderSide(
        color: isSelected ? Colors.teal : context.colors.outline.withValues(alpha: 0.3),
        width: isSelected ? 2 : 1,
      ),
    );
  }

  Widget _buildBillingsList() {
    final billings = filteredBillings;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Facturas Individuales',
            style: context.textStyles.titleMedium?.copyWith(
              fontWeight: AppTokens.fontWeightBold,
            ),
          ),
          SizedBox(height: AppTokens.space12),
          ...billings.map((billing) => _buildBillingCard(billing)),
        ],
      ),
    );
  }

  Widget _buildBillingCard(UserBilling billing) {
    final member = FakeData.members.firstWhere(
      (m) => m.userId == billing.userId,
      orElse: () => FakeData.members.first,
    );

    final cost = _getCostForScenario(billing);
    final savings = _getSavings(billing);
    final savingsPercent = billing.traditionalCost > 0
        ? (savings / billing.traditionalCost) * 100
        : 0;

    return Container(
      margin: EdgeInsets.only(bottom: AppTokens.space12),
      padding: EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppTokens.borderRadiusMedium,
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: member.isProsumer
                      ? AppTokens.primaryRed.withValues(alpha: 0.15)
                      : context.colors.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: AppTokens.borderRadiusSmall,
                ),
                child: Center(
                  child: Text(
                    billing.userName[0].toUpperCase(),
                    style: context.textStyles.titleLarge?.copyWith(
                      color: member.isProsumer ? AppTokens.primaryRed : context.colors.primary,
                      fontWeight: AppTokens.fontWeightBold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppTokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      billing.userName,
                      style: context.textStyles.titleMedium?.copyWith(
                        fontWeight: AppTokens.fontWeightBold,
                      ),
                    ),
                    SizedBox(height: AppTokens.space4),
                    Row(
                      children: [
                        Icon(
                          member.isProsumer ? Icons.solar_power : Icons.home,
                          size: 14,
                          color: context.colors.onSurfaceVariant,
                        ),
                        SizedBox(width: AppTokens.space4),
                        Text(
                          member.isProsumer ? 'Prosumidor' : 'Consumidor',
                          style: context.textStyles.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Cost badge
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTokens.space12,
                  vertical: AppTokens.space8,
                ),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.1),
                  borderRadius: AppTokens.borderRadiusMedium,
                ),
                child: Column(
                  children: [
                    Text(
                      'Costo',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: AppTokens.space4),
                    Text(
                      Formatters.formatCurrency(cost),
                      style: context.textStyles.titleSmall?.copyWith(
                        color: Colors.teal,
                        fontWeight: AppTokens.fontWeightBold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space16),
          Divider(height: 1, color: context.colors.outline.withValues(alpha: 0.1)),
          SizedBox(height: AppTokens.space16),
          // Energy metrics
          Row(
            children: [
              Expanded(
                child: _buildMetric(
                  'Consumo',
                  Formatters.formatEnergy(billing.energyConsumed),
                  Icons.flash_on_outlined,
                  AppTokens.error,
                ),
              ),
              if (member.isProsumer) ...[
                SizedBox(width: AppTokens.space12),
                Expanded(
                  child: _buildMetric(
                    'Generación',
                    Formatters.formatEnergy(billing.energyGenerated),
                    Icons.wb_sunny_outlined,
                    Colors.orange,
                  ),
                ),
              ],
            ],
          ),
          // Savings indicator (only if not traditional)
          if (_selectedScenario != 'traditional' && savings > 0) ...[
            SizedBox(height: AppTokens.space16),
            Container(
              padding: EdgeInsets.all(AppTokens.space12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.05),
                borderRadius: AppTokens.borderRadiusSmall,
                border: Border.all(
                  color: Colors.green.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.savings_outlined, color: Colors.green, size: 20),
                  SizedBox(width: AppTokens.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ahorro vs. Tradicional',
                          style: context.textStyles.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: AppTokens.space4),
                        Text(
                          '${Formatters.formatCurrency(savings)} (${savingsPercent.toStringAsFixed(1)}%)',
                          style: context.textStyles.bodyMedium?.copyWith(
                            color: Colors.green,
                            fontWeight: AppTokens.fontWeightBold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(AppTokens.space12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: AppTokens.borderRadiusSmall,
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(height: AppTokens.space8),
          Text(
            value,
            style: context.textStyles.bodyMedium?.copyWith(
              color: color,
              fontWeight: AppTokens.fontWeightBold,
            ),
          ),
          SizedBox(height: AppTokens.space4),
          Text(
            label,
            style: context.textStyles.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    String infoText;
    switch (_selectedScenario) {
      case 'traditional':
        infoText = 'Escenario tradicional: Toda la energía se compra de la red a tarifa regulada (450 COP/kWh).';
        break;
      case 'credits':
        infoText = 'Escenario con créditos: Los prosumidores autoconsumen su generación y solo pagan por la energía importada de la red.';
        break;
      case 'pde':
        infoText = 'Escenario PDE: Distribución homogénea de excedentes entre prosumidores según capacidad instalada.';
        break;
      case 'p2p':
      default:
        infoText = 'Escenario P2P: Intercambio directo de energía entre miembros a 500 COP/kWh, complementado con red regulada.';
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
      padding: EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: AppTokens.borderRadiusMedium,
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue, size: 24),
          SizedBox(width: AppTokens.space12),
          Expanded(
            child: Text(
              infoText,
              style: context.textStyles.bodySmall?.copyWith(
                color: Colors.blue.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liquidación Mensual'),
        elevation: 0,
        backgroundColor: context.colors.surface,
      ),
      backgroundColor: context.colors.surfaceContainerLowest,
      body: ListView(
        padding: EdgeInsets.only(bottom: AppTokens.space24),
        children: [
          SizedBox(height: AppTokens.space16),
          _buildHeader(),
          SizedBox(height: AppTokens.space16),
          _buildScenarioSelector(),
          SizedBox(height: AppTokens.space16),
          _buildInfoCard(),
          SizedBox(height: AppTokens.space16),
          _buildFilters(),
          SizedBox(height: AppTokens.space16),
          _buildBillingsList(),
        ],
      ),
    );
  }
}
