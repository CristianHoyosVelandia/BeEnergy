import 'package:flutter/material.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/utils/formatters.dart';
import '../../../data/fake_data.dart';
import '../../../models/community_models.dart';
import '../../../models/energy_models.dart';
import '../../../models/p2p_models.dart';

/// Pantalla de Detalle del Usuario
/// Muestra información completa de un miembro de la comunidad
class UserDetailScreen extends StatefulWidget {
  final CommunityMember member;

  const UserDetailScreen({
    super.key,
    required this.member,
  });

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  late final EnergyRecord energyRecord;
  late final List<P2PContract> userContracts;
  late final EnergyCredit? energyCredit;

  @override
  void initState() {
    super.initState();

    // Obtener datos del usuario
    energyRecord = FakeData.energyRecords.firstWhere(
      (record) => record.userId == widget.member.userId,
      orElse: () => FakeData.energyRecords.first,
    );

    // Contratos P2P donde el usuario es comprador o vendedor
    userContracts = FakeData.p2pContracts.where((contract) =>
      contract.buyerId == widget.member.userId ||
      contract.sellerId == widget.member.userId
    ).toList();

    // Créditos energéticos (solo prosumidores)
    if (widget.member.isProsumer) {
      energyCredit = FakeData.energyCredits.firstWhere(
        (credit) => credit.userId == widget.member.userId,
        orElse: () => EnergyCredit(
          id: 0,
          userId: widget.member.userId,
          userName: widget.member.fullName,
          balance: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    } else {
      energyCredit = null;
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(AppTokens.space20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.member.isProsumer
              ? [AppTokens.primaryRed, AppTokens.primaryRed.withValues(alpha: 0.8)]
              : [context.colors.primary, context.colors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppTokens.borderRadiusLarge.topLeft.x),
          bottomRight: Radius.circular(AppTokens.borderRadiusLarge.topRight.x),
        ),
      ),
      child: Column(
        children: [
          // Avatar grande
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                widget.member.userName[0].toUpperCase(),
                style: context.textStyles.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: AppTokens.fontWeightBold,
                ),
              ),
            ),
          ),
          SizedBox(height: AppTokens.space16),
          // Nombre
          Text(
            widget.member.fullName,
            style: context.textStyles.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: AppTokens.fontWeightBold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTokens.space8),
          // Rol
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppTokens.space16,
              vertical: AppTokens.space8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: AppTokens.borderRadiusMedium,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.member.isProsumer ? Icons.solar_power : Icons.home,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: AppTokens.space8),
                Text(
                  widget.member.isProsumer ? 'Prosumidor' : 'Consumidor',
                  style: context.textStyles.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: AppTokens.fontWeightBold,
                  ),
                ),
              ],
            ),
          ),
          if (widget.member.isProsumer) ...[
            SizedBox(height: AppTokens.space12),
            Text(
              'Capacidad instalada: ${Formatters.formatPower(widget.member.installedCapacity)}',
              style: context.textStyles.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEnergyMetrics() {
    return Container(
      margin: EdgeInsets.all(AppTokens.space16),
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
          Text(
            'Datos Energéticos - Noviembre 2025',
            style: context.textStyles.titleMedium?.copyWith(
              fontWeight: AppTokens.fontWeightBold,
            ),
          ),
          SizedBox(height: AppTokens.space16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Consumo',
                  Formatters.formatEnergy(energyRecord.energyConsumed),
                  Icons.trending_down_rounded,
                  AppTokens.error,
                ),
              ),
              SizedBox(width: AppTokens.space12),
              Expanded(
                child: _buildMetricCard(
                  'Generación',
                  Formatters.formatEnergy(energyRecord.energyGenerated),
                  Icons.wb_sunny_outlined,
                  Colors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Exportado',
                  Formatters.formatEnergy(energyRecord.energyExported),
                  Icons.upload_outlined,
                  Colors.green,
                ),
              ),
              SizedBox(width: AppTokens.space12),
              Expanded(
                child: _buildMetricCard(
                  'Importado',
                  Formatters.formatEnergy(energyRecord.energyImported),
                  Icons.download_outlined,
                  Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space16),
          Divider(height: 1, color: context.colors.outline.withValues(alpha: 0.1)),
          SizedBox(height: AppTokens.space16),
          // Balance neto
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Balance Neto',
                style: context.textStyles.titleMedium?.copyWith(
                  fontWeight: AppTokens.fontWeightBold,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTokens.space16,
                  vertical: AppTokens.space8,
                ),
                decoration: BoxDecoration(
                  color: energyRecord.netBalance >= 0
                      ? Colors.green.withValues(alpha: 0.1)
                      : AppTokens.error.withValues(alpha: 0.1),
                  borderRadius: AppTokens.borderRadiusMedium,
                ),
                child: Text(
                  Formatters.formatEnergy(energyRecord.netBalance),
                  style: context.textStyles.titleMedium?.copyWith(
                    color: energyRecord.netBalance >= 0 ? Colors.green : AppTokens.error,
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

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(AppTokens.space12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: AppTokens.borderRadiusMedium,
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: AppTokens.space8),
          Text(
            value,
            style: context.textStyles.titleMedium?.copyWith(
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

  Widget _buildP2PContracts() {
    if (userContracts.isEmpty) {
      return const SizedBox.shrink();
    }

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
              Icon(Icons.handshake_outlined, color: context.colors.primary),
              SizedBox(width: AppTokens.space8),
              Text(
                'Contratos P2P',
                style: context.textStyles.titleMedium?.copyWith(
                  fontWeight: AppTokens.fontWeightBold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space16),
          ...userContracts.map((contract) => _buildContractCard(contract)),
        ],
      ),
    );
  }

  Widget _buildContractCard(P2PContract contract) {
    final isSeller = contract.sellerId == widget.member.userId;
    final otherParty = isSeller ? contract.buyerName : contract.sellerName;

    return Container(
      margin: EdgeInsets.only(bottom: AppTokens.space12),
      padding: EdgeInsets.all(AppTokens.space12),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: AppTokens.borderRadiusMedium,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppTokens.space8),
            decoration: BoxDecoration(
              color: isSeller
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.blue.withValues(alpha: 0.1),
              borderRadius: AppTokens.borderRadiusSmall,
            ),
            child: Icon(
              isSeller ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              color: isSeller ? Colors.green : Colors.blue,
              size: 20,
            ),
          ),
          SizedBox(width: AppTokens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSeller ? 'Venta a $otherParty' : 'Compra de $otherParty',
                  style: context.textStyles.bodyMedium?.copyWith(
                    fontWeight: AppTokens.fontWeightBold,
                  ),
                ),
                SizedBox(height: AppTokens.space4),
                Text(
                  '${Formatters.formatEnergy(contract.energyCommitted)} • ${Formatters.formatCurrency(contract.totalValue)}',
                  style: context.textStyles.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
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
              color: contract.isActive
                  ? Colors.green.withValues(alpha: 0.1)
                  : context.colors.surfaceContainerHighest,
              borderRadius: AppTokens.borderRadiusSmall,
            ),
            child: Text(
              contract.isActive ? 'Activo' : 'Completado',
              style: context.textStyles.bodySmall?.copyWith(
                color: contract.isActive ? Colors.green : context.colors.onSurfaceVariant,
                fontWeight: AppTokens.fontWeightMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnergyCredits() {
    if (energyCredit == null || !widget.member.isProsumer) {
      return const SizedBox.shrink();
    }

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
              Icon(Icons.account_balance_wallet_outlined, color: Colors.green),
              SizedBox(width: AppTokens.space8),
              Text(
                'Créditos Energéticos',
                style: context.textStyles.titleMedium?.copyWith(
                  fontWeight: AppTokens.fontWeightBold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Balance disponible',
                style: context.textStyles.bodyLarge?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              Text(
                Formatters.formatCurrency(energyCredit!.balance),
                style: context.textStyles.headlineSmall?.copyWith(
                  color: Colors.green,
                  fontWeight: AppTokens.fontWeightBold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPDEInfo() {
    if (!widget.member.isProsumer) {
      return const SizedBox.shrink();
    }

    // Buscar asignación PDE del usuario
    final pdeAllocation = FakeData.pdeAllocations.firstWhere(
      (allocation) => allocation.userId == widget.member.userId,
      orElse: () => PDEAllocation(
        id: 0,
        userId: widget.member.userId,
        userName: widget.member.fullName,
        communityId: 1,
        excessEnergy: 0,
        allocatedEnergy: 0,
        sharePercentage: 0,
        allocationPeriod: '2025-11',
      ),
    );

    if (pdeAllocation.allocatedEnergy == 0) {
      return const SizedBox.shrink();
    }

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
              Icon(Icons.share_outlined, color: Colors.orange),
              SizedBox(width: AppTokens.space8),
              Text(
                'Programa PDE',
                style: context.textStyles.titleMedium?.copyWith(
                  fontWeight: AppTokens.fontWeightBold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Energía excedente',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: AppTokens.space4),
                    Text(
                      Formatters.formatEnergy(pdeAllocation.excessEnergy),
                      style: context.textStyles.titleMedium?.copyWith(
                        fontWeight: AppTokens.fontWeightBold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Porcentaje PDE',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: AppTokens.space4),
                    Text(
                      Formatters.formatPercentage(pdeAllocation.sharePercentage),
                      style: context.textStyles.titleMedium?.copyWith(
                        color: Colors.orange,
                        fontWeight: AppTokens.fontWeightBold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfaceContainerLowest,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: widget.member.isProsumer ? AppTokens.primaryRed : context.colors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(height: AppTokens.space16),
                _buildEnergyMetrics(),
                SizedBox(height: AppTokens.space16),
                _buildPDEInfo(),
                SizedBox(height: AppTokens.space16),
                _buildEnergyCredits(),
                SizedBox(height: AppTokens.space16),
                _buildP2PContracts(),
                SizedBox(height: AppTokens.space24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
