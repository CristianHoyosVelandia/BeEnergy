import 'package:flutter/material.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/utils/formatters.dart';
import '../../../data/fake_data.dart';
import '../../../models/p2p_models.dart';

/// Pantalla de Créditos Energéticos
/// Muestra el balance de créditos y transacciones de los prosumidores - Noviembre 2025
class EnergyCreditsScreen extends StatefulWidget {
  const EnergyCreditsScreen({super.key});

  @override
  State<EnergyCreditsScreen> createState() => _EnergyCreditsScreenState();
}

class _EnergyCreditsScreenState extends State<EnergyCreditsScreen> {
  String _filterType = 'all'; // 'all', 'credit', 'debit'

  List<CreditTransaction> get filteredTransactions {
    var transactions = FakeData.creditTransactions;

    if (_filterType == 'credit') {
      transactions = transactions.where((t) => t.isCredit).toList();
    } else if (_filterType == 'debit') {
      transactions = transactions.where((t) => t.isDebit).toList();
    }

    return transactions;
  }

  Widget _buildHeader() {
    final credits = FakeData.energyCredits;
    final totalBalance = credits.fold<double>(0, (sum, c) => sum + c.balance);
    final transactions = FakeData.creditTransactions;
    final totalCredits = transactions.where((t) => t.isCredit).fold<double>(0, (sum, t) => sum + t.amount);
    final totalDebits = transactions.where((t) => t.isDebit).fold<double>(0, (sum, t) => sum + t.amount);

    return Container(
      margin: EdgeInsets.all(AppTokens.space16),
      padding: EdgeInsets.all(AppTokens.space20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple,
            Colors.purple.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppTokens.borderRadiusLarge,
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 32),
              SizedBox(width: AppTokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Créditos Energéticos',
                      style: context.textStyles.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: AppTokens.fontWeightBold,
                      ),
                    ),
                    SizedBox(height: AppTokens.space4),
                    Text(
                      'Sistema de Balance Financiero',
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
                // Balance total
                Text(
                  'Balance Total',
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                SizedBox(height: AppTokens.space8),
                Text(
                  Formatters.formatCurrency(totalBalance),
                  style: context.textStyles.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: AppTokens.fontWeightBold,
                  ),
                ),
                SizedBox(height: AppTokens.space20),
                // Ingresos y Gastos
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Icon(Icons.arrow_circle_down_outlined, color: Colors.green, size: 28),
                        SizedBox(height: AppTokens.space8),
                        Text(
                          Formatters.formatCurrency(totalCredits),
                          style: context.textStyles.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: AppTokens.fontWeightBold,
                          ),
                        ),
                        SizedBox(height: AppTokens.space4),
                        Text(
                          'Ingresos',
                          style: context.textStyles.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    Column(
                      children: [
                        Icon(Icons.arrow_circle_up_outlined, color: Colors.red, size: 28),
                        SizedBox(height: AppTokens.space8),
                        Text(
                          Formatters.formatCurrency(totalDebits),
                          style: context.textStyles.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: AppTokens.fontWeightBold,
                          ),
                        ),
                        SizedBox(height: AppTokens.space4),
                        Text(
                          'Gastos',
                          style: context.textStyles.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditsList() {
    final credits = FakeData.energyCredits;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Balance por Prosumidor',
            style: context.textStyles.titleMedium?.copyWith(
              fontWeight: AppTokens.fontWeightBold,
            ),
          ),
          SizedBox(height: AppTokens.space12),
          ...credits.map((credit) => _buildCreditCard(credit)),
        ],
      ),
    );
  }

  Widget _buildCreditCard(EnergyCredit credit) {
    final isPositive = credit.balance >= 0;

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
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isPositive
                  ? Colors.green.withValues(alpha: 0.15)
                  : AppTokens.error.withValues(alpha: 0.15),
              borderRadius: AppTokens.borderRadiusSmall,
            ),
            child: Center(
              child: Icon(
                isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                color: isPositive ? Colors.green : AppTokens.error,
                size: 28,
              ),
            ),
          ),
          SizedBox(width: AppTokens.space12),
          // Nombre
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  credit.userName,
                  style: context.textStyles.titleMedium?.copyWith(
                    fontWeight: AppTokens.fontWeightBold,
                  ),
                ),
                SizedBox(height: AppTokens.space4),
                Text(
                  'ID: ${credit.userId}',
                  style: context.textStyles.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Balance
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppTokens.space16,
              vertical: AppTokens.space12,
            ),
            decoration: BoxDecoration(
              color: isPositive
                  ? Colors.green.withValues(alpha: 0.1)
                  : AppTokens.error.withValues(alpha: 0.1),
              borderRadius: AppTokens.borderRadiusMedium,
            ),
            child: Text(
              Formatters.formatCurrency(credit.balance.abs()),
              style: context.textStyles.titleMedium?.copyWith(
                color: isPositive ? Colors.green : AppTokens.error,
                fontWeight: AppTokens.fontWeightBold,
              ),
            ),
          ),
        ],
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
            'Filtrar transacciones:',
            style: context.textStyles.bodyMedium?.copyWith(
              fontWeight: AppTokens.fontWeightMedium,
            ),
          ),
          SizedBox(height: AppTokens.space12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Todas', 'all'),
                SizedBox(width: AppTokens.space8),
                _buildFilterChip('Ingresos', 'credit'),
                SizedBox(width: AppTokens.space8),
                _buildFilterChip('Gastos', 'debit'),
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
      selectedColor: Colors.purple,
      checkmarkColor: Colors.white,
      labelStyle: context.textStyles.bodyMedium?.copyWith(
        color: isSelected ? Colors.white : context.colors.onSurface,
        fontWeight: isSelected ? AppTokens.fontWeightBold : AppTokens.fontWeightMedium,
      ),
      side: BorderSide(
        color: isSelected ? Colors.purple : context.colors.outline.withValues(alpha: 0.3),
        width: isSelected ? 2 : 1,
      ),
    );
  }

  Widget _buildTransactionsList() {
    final transactions = filteredTransactions;

    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppTokens.space32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: context.colors.onSurfaceVariant,
              ),
              SizedBox(height: AppTokens.space16),
              Text(
                'No hay transacciones',
                style: context.textStyles.titleMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Historial de Transacciones',
            style: context.textStyles.titleMedium?.copyWith(
              fontWeight: AppTokens.fontWeightBold,
            ),
          ),
          SizedBox(height: AppTokens.space12),
          ...transactions.map((transaction) => _buildTransactionCard(transaction)),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(CreditTransaction transaction) {
    final isCredit = transaction.isCredit;

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
      child: Row(
        children: [
          // Icono de tipo
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isCredit
                  ? Colors.green.withValues(alpha: 0.15)
                  : AppTokens.error.withValues(alpha: 0.15),
              borderRadius: AppTokens.borderRadiusSmall,
            ),
            child: Center(
              child: Icon(
                isCredit ? Icons.add_circle_outline : Icons.remove_circle_outline,
                color: isCredit ? Colors.green : AppTokens.error,
                size: 28,
              ),
            ),
          ),
          SizedBox(width: AppTokens.space12),
          // Detalles
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.userName,
                  style: context.textStyles.titleSmall?.copyWith(
                    fontWeight: AppTokens.fontWeightBold,
                  ),
                ),
                SizedBox(height: AppTokens.space4),
                Text(
                  transaction.description,
                  style: context.textStyles.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: AppTokens.space8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 12,
                      color: context.colors.onSurfaceVariant,
                    ),
                    SizedBox(width: AppTokens.space4),
                    Text(
                      _formatDate(transaction.transactionDate),
                      style: context.textStyles.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Monto
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCredit ? '+' : '-'} ${Formatters.formatCurrency(transaction.amount)}',
                style: context.textStyles.titleMedium?.copyWith(
                  color: isCredit ? Colors.green : AppTokens.error,
                  fontWeight: AppTokens.fontWeightBold,
                ),
              ),
              SizedBox(height: AppTokens.space4),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTokens.space8,
                  vertical: AppTokens.space4,
                ),
                decoration: BoxDecoration(
                  color: isCredit
                      ? Colors.green.withValues(alpha: 0.1)
                      : AppTokens.error.withValues(alpha: 0.1),
                  borderRadius: AppTokens.borderRadiusSmall,
                ),
                child: Text(
                  isCredit ? 'Ingreso' : 'Gasto',
                  style: context.textStyles.bodySmall?.copyWith(
                    color: isCredit ? Colors.green : AppTokens.error,
                    fontWeight: AppTokens.fontWeightBold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildInfoCard() {
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
              'Los créditos energéticos representan el balance financiero de cada prosumidor por ventas y compras en el mercado P2P.',
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
        title: const Text('Créditos Energéticos'),
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
          _buildInfoCard(),
          SizedBox(height: AppTokens.space16),
          _buildCreditsList(),
          SizedBox(height: AppTokens.space24),
          _buildFilters(),
          SizedBox(height: AppTokens.space16),
          _buildTransactionsList(),
        ],
      ),
    );
  }
}
