import 'package:flutter/material.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/utils/formatters.dart';
import '../../../data/fake_data.dart';
import '../../../models/p2p_models.dart';

/// Pantalla de Mercado P2P - Peer to Peer
/// Muestra los contratos de intercambio directo de energía entre prosumidores - Noviembre 2025
class P2PMarketScreen extends StatefulWidget {
  const P2PMarketScreen({super.key});

  @override
  State<P2PMarketScreen> createState() => _P2PMarketScreenState();
}

class _P2PMarketScreenState extends State<P2PMarketScreen> {
  String _filterStatus = 'all'; // 'all', 'active', 'completed'

  List<P2PContract> get filteredContracts {
    var contracts = FakeData.p2pContracts;

    if (_filterStatus == 'active') {
      contracts = contracts.where((c) => c.status == 'active').toList();
    } else if (_filterStatus == 'completed') {
      contracts = contracts.where((c) => c.status == 'completed').toList();
    }

    return contracts;
  }

  Widget _buildHeader() {
    final contracts = FakeData.p2pContracts;
    final totalEnergy = contracts.fold<double>(0, (sum, c) => sum + c.energyCommitted);
    final activeContracts = contracts.where((c) => c.status == 'active').length;

    return Container(
      margin: EdgeInsets.all(AppTokens.space16),
      padding: EdgeInsets.all(AppTokens.space20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green,
            Colors.green.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppTokens.borderRadiusLarge,
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.handshake_outlined, color: Colors.white, size: 32),
              SizedBox(width: AppTokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mercado P2P',
                      style: context.textStyles.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: AppTokens.fontWeightBold,
                      ),
                    ),
                    SizedBox(height: AppTokens.space4),
                    Text(
                      'Intercambio Directo de Energía',
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
                Column(
                  children: [
                    Text(
                      '$activeContracts',
                      style: context.textStyles.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: AppTokens.fontWeightBold,
                      ),
                    ),
                    SizedBox(height: AppTokens.space4),
                    Text(
                      'Contratos Activos',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                Column(
                  children: [
                    Text(
                      Formatters.formatEnergy(totalEnergy),
                      style: context.textStyles.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: AppTokens.fontWeightBold,
                      ),
                    ),
                    SizedBox(height: AppTokens.space4),
                    Text(
                      'Volumen Total',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                Column(
                  children: [
                    Text(
                      Formatters.formatCurrency(500),
                      style: context.textStyles.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: AppTokens.fontWeightBold,
                      ),
                    ),
                    SizedBox(height: AppTokens.space4),
                    Text(
                      'Precio/kWh',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
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

  Widget _buildFilters() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtrar por estado:',
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
                _buildFilterChip('Activos', 'active'),
                SizedBox(width: AppTokens.space8),
                _buildFilterChip('Completados', 'completed'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterStatus == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterStatus = value;
        });
      },
      backgroundColor: context.colors.surface,
      selectedColor: Colors.green,
      checkmarkColor: Colors.white,
      labelStyle: context.textStyles.bodyMedium?.copyWith(
        color: isSelected ? Colors.white : context.colors.onSurface,
        fontWeight: isSelected ? AppTokens.fontWeightBold : AppTokens.fontWeightMedium,
      ),
      side: BorderSide(
        color: isSelected ? Colors.green : context.colors.outline.withValues(alpha: 0.3),
        width: isSelected ? 2 : 1,
      ),
    );
  }

  Widget _buildSellerRankings() {
    final rankings = FakeData.sellerRankings;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
      padding: EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppTokens.borderRadiusLarge,
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.stars_rounded, color: Colors.amber, size: 24),
              SizedBox(width: AppTokens.space8),
              Text(
                'Top Vendedores',
                style: context.textStyles.titleMedium?.copyWith(
                  fontWeight: AppTokens.fontWeightBold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space16),
          ...rankings.take(3).toList().asMap().entries.map((entry) {
            final position = entry.key + 1;
            final ranking = entry.value;
            return _buildRankingItem(ranking, position);
          }),
        ],
      ),
    );
  }

  Widget _buildRankingItem(SellerRanking ranking, int position) {
    final medals = [Colors.amber, Colors.grey[400]!, Colors.brown];
    final medal = medals[position - 1];

    return Container(
      margin: EdgeInsets.only(bottom: AppTokens.space12),
      padding: EdgeInsets.all(AppTokens.space12),
      decoration: BoxDecoration(
        color: medal.withValues(alpha: 0.05),
        borderRadius: AppTokens.borderRadiusSmall,
        border: Border.all(
          color: medal.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: medal.withValues(alpha: 0.15),
              borderRadius: AppTokens.borderRadiusSmall,
            ),
            child: Center(
              child: Text(
                '#$position',
                style: context.textStyles.titleMedium?.copyWith(
                  color: medal,
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
                  ranking.userName,
                  style: context.textStyles.titleSmall?.copyWith(
                    fontWeight: AppTokens.fontWeightBold,
                  ),
                ),
                SizedBox(height: AppTokens.space4),
                Row(
                  children: [
                    Icon(Icons.bolt_outlined, size: 14, color: Colors.orange),
                    SizedBox(width: AppTokens.space4),
                    Text(
                      Formatters.formatEnergy(ranking.totalEnergySold),
                      style: context.textStyles.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(width: AppTokens.space12),
                    Icon(Icons.monetization_on_outlined, size: 14, color: Colors.green),
                    SizedBox(width: AppTokens.space4),
                    Text(
                      Formatters.formatCurrency(ranking.totalRevenue),
                      style: context.textStyles.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppTokens.space8,
              vertical: AppTokens.space4,
            ),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: AppTokens.borderRadiusSmall,
            ),
            child: Text(
              '${ranking.contractsCompleted} ventas',
              style: context.textStyles.bodySmall?.copyWith(
                color: Colors.green,
                fontWeight: AppTokens.fontWeightBold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContractsList() {
    final contracts = filteredContracts;

    if (contracts.isEmpty) {
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
                'No hay contratos',
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
            'Contratos P2P',
            style: context.textStyles.titleMedium?.copyWith(
              fontWeight: AppTokens.fontWeightBold,
            ),
          ),
          SizedBox(height: AppTokens.space12),
          ...contracts.map((contract) => _buildContractCard(contract)),
        ],
      ),
    );
  }

  Widget _buildContractCard(P2PContract contract) {
    final isActive = contract.status == 'active';
    final totalValue = contract.energyCommitted * contract.agreedPrice;

    return Container(
      margin: EdgeInsets.only(bottom: AppTokens.space12),
      padding: EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppTokens.borderRadiusMedium,
        border: Border.all(
          color: isActive
            ? Colors.green.withValues(alpha: 0.3)
            : context.colors.outline.withValues(alpha: 0.1),
          width: isActive ? 2 : 1,
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
          // Header con estado
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTokens.space12,
                  vertical: AppTokens.space8,
                ),
                decoration: BoxDecoration(
                  color: isActive
                    ? Colors.green.withValues(alpha: 0.1)
                    : context.colors.surfaceContainerHighest,
                  borderRadius: AppTokens.borderRadiusMedium,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive ? Colors.green : context.colors.onSurfaceVariant,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: AppTokens.space8),
                    Text(
                      isActive ? 'Activo' : 'Completado',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: isActive ? Colors.green : context.colors.onSurfaceVariant,
                        fontWeight: AppTokens.fontWeightBold,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Contrato #${contract.id}',
                style: context.textStyles.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space16),
          // Partes involucradas
          Row(
            children: [
              Expanded(
                child: _buildPartyInfo(
                  contract.sellerName,
                  'Vendedor',
                  Icons.arrow_circle_up_outlined,
                  Colors.orange,
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: Colors.green,
                size: 28,
              ),
              Expanded(
                child: _buildPartyInfo(
                  contract.buyerName,
                  'Comprador',
                  Icons.arrow_circle_down_outlined,
                  Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space16),
          Divider(height: 1, color: context.colors.outline.withValues(alpha: 0.1)),
          SizedBox(height: AppTokens.space16),
          // Detalles del contrato
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  'Energía',
                  Formatters.formatEnergy(contract.energyCommitted),
                  Icons.bolt_outlined,
                  Colors.orange,
                ),
              ),
              SizedBox(width: AppTokens.space12),
              Expanded(
                child: _buildDetailItem(
                  'Precio/kWh',
                  Formatters.formatCurrency(contract.agreedPrice),
                  Icons.attach_money_outlined,
                  Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space12),
          // Valor total
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Valor Total',
                  style: context.textStyles.bodyMedium?.copyWith(
                    fontWeight: AppTokens.fontWeightMedium,
                  ),
                ),
                Text(
                  Formatters.formatCurrency(totalValue),
                  style: context.textStyles.titleMedium?.copyWith(
                    color: Colors.green,
                    fontWeight: AppTokens.fontWeightBold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppTokens.space12),
          // Fecha
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: context.colors.onSurfaceVariant,
              ),
              SizedBox(width: AppTokens.space8),
              Text(
                _formatDate(contract.createdAt),
                style: context.textStyles.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPartyInfo(String name, String role, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: AppTokens.borderRadiusSmall,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        SizedBox(height: AppTokens.space8),
        Text(
          name,
          style: context.textStyles.bodyMedium?.copyWith(
            fontWeight: AppTokens.fontWeightBold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppTokens.space4),
        Text(
          role,
          style: context.textStyles.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon, Color color) {
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
              'El mercado P2P permite a los prosumidores vender energía directamente a otros miembros de la comunidad a un precio preferencial de 500 COP/kWh.',
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
        title: const Text('Mercado P2P'),
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
          _buildSellerRankings(),
          SizedBox(height: AppTokens.space16),
          _buildFilters(),
          SizedBox(height: AppTokens.space16),
          _buildContractsList(),
        ],
      ),
    );
  }
}
