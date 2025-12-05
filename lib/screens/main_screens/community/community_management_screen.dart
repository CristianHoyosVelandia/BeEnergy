import 'package:flutter/material.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/utils/formatters.dart';
import '../../../data/fake_data.dart';
import '../../../models/community_models.dart';
import '../../../utils/metodos.dart';
import 'user_detail_screen.dart';

/// Pantalla de Gestión de la Comunidad Energética
/// Muestra la lista de los 15 miembros de la Comunidad UAO
class CommunityManagementScreen extends StatefulWidget {
  const CommunityManagementScreen({super.key});

  @override
  State<CommunityManagementScreen> createState() => _CommunityManagementScreenState();
}

class _CommunityManagementScreenState extends State<CommunityManagementScreen> {
  final Metodos metodos = Metodos();
  String _filterRole = 'all'; // 'all', 'prosumer', 'consumer'
  String _searchQuery = '';

  // Obtener miembros filtrados
  List<CommunityMember> get filteredMembers {
    var members = FakeData.members;

    // Filtrar por rol
    if (_filterRole == 'prosumer') {
      members = members.where((m) => m.isProsumer).toList();
    } else if (_filterRole == 'consumer') {
      members = members.where((m) => m.isConsumer).toList();
    }

    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      members = members.where((m) =>
        m.fullName.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    return members;
  }

  Widget _buildStatsCard() {
    final stats = FakeData.communityStats;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
      padding: EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTokens.primaryRed,
            AppTokens.primaryRed.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppTokens.borderRadiusLarge,
        boxShadow: [
          BoxShadow(
            color: AppTokens.primaryRed.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.groups_rounded,
                color: Colors.white,
                size: 32,
              ),
              SizedBox(width: AppTokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      FakeData.community.name,
                      style: context.textStyles.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: AppTokens.fontWeightBold,
                      ),
                    ),
                    SizedBox(height: AppTokens.space4),
                    Text(
                      FakeData.community.location,
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Miembros',
                  '${stats.totalMembers}',
                  Icons.people_outline,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildStatItem(
                  'Prosumidores',
                  '${stats.totalProsumers}',
                  Icons.solar_power_outlined,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildStatItem(
                  'Capacidad',
                  Formatters.formatPower(stats.totalInstalledCapacity),
                  Icons.bolt_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        SizedBox(height: AppTokens.space8),
        Text(
          value,
          style: context.textStyles.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: AppTokens.fontWeightBold,
          ),
        ),
        SizedBox(height: AppTokens.space4),
        Text(
          label,
          style: context.textStyles.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
      child: Column(
        children: [
          // Barra de búsqueda
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Buscar miembro...',
              prefixIcon: Icon(Icons.search, color: context.colors.primary),
              filled: true,
              fillColor: context.colors.surface,
              border: OutlineInputBorder(
                borderRadius: AppTokens.borderRadiusMedium,
                borderSide: BorderSide(
                  color: context.colors.outline.withValues(alpha: 0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppTokens.borderRadiusMedium,
                borderSide: BorderSide(
                  color: context.colors.outline.withValues(alpha: 0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppTokens.borderRadiusMedium,
                borderSide: BorderSide(
                  color: context.colors.primary,
                  width: 2,
                ),
              ),
            ),
          ),
          SizedBox(height: AppTokens.space12),
          // Chips de filtrado
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
    final isSelected = _filterRole == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterRole = value;
        });
      },
      backgroundColor: context.colors.surface,
      selectedColor: AppTokens.primaryRed,
      checkmarkColor: Colors.white,
      labelStyle: context.textStyles.bodyMedium?.copyWith(
        color: isSelected ? Colors.white : context.colors.onSurface,
        fontWeight: isSelected ? AppTokens.fontWeightBold : AppTokens.fontWeightMedium,
      ),
      side: BorderSide(
        color: isSelected ? AppTokens.primaryRed : context.colors.outline.withValues(alpha: 0.3),
        width: isSelected ? 2 : 1,
      ),
    );
  }

  Widget _buildMembersList() {
    final members = filteredMembers;

    if (members.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppTokens.space32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_search_outlined,
                size: 64,
                color: context.colors.onSurfaceVariant,
              ),
              SizedBox(height: AppTokens.space16),
              Text(
                'No se encontraron miembros',
                style: context.textStyles.titleMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: AppTokens.space16),
      itemCount: members.length,
      separatorBuilder: (context, index) => SizedBox(height: AppTokens.space12),
      itemBuilder: (context, index) {
        final member = members[index];
        return _buildMemberCard(member);
      },
    );
  }

  Widget _buildMemberCard(CommunityMember member) {
    // Obtener datos de energía del miembro
    final energyRecord = FakeData.energyRecords.firstWhere(
      (record) => record.userId == member.userId,
      orElse: () => FakeData.energyRecords.first,
    );

    return InkWell(
      onTap: () {
        context.push(UserDetailScreen(member: member));
      },
      borderRadius: AppTokens.borderRadiusMedium,
      child: Container(
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
            Row(
              children: [
                // Avatar con inicial
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
                      member.userName[0].toUpperCase(),
                      style: context.textStyles.titleLarge?.copyWith(
                        color: member.isProsumer ? AppTokens.primaryRed : context.colors.primary,
                        fontWeight: AppTokens.fontWeightBold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppTokens.space12),
                // Información del miembro
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.fullName,
                        style: context.textStyles.titleMedium?.copyWith(
                          fontWeight: AppTokens.fontWeightBold,
                        ),
                      ),
                      SizedBox(height: AppTokens.space4),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppTokens.space8,
                              vertical: AppTokens.space4,
                            ),
                            decoration: BoxDecoration(
                              color: member.isProsumer
                                  ? AppTokens.primaryRed.withValues(alpha: 0.1)
                                  : context.colors.surfaceContainerHighest,
                              borderRadius: AppTokens.borderRadiusSmall,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  member.isProsumer ? Icons.solar_power : Icons.home,
                                  size: 14,
                                  color: member.isProsumer ? AppTokens.primaryRed : context.colors.onSurfaceVariant,
                                ),
                                SizedBox(width: AppTokens.space4),
                                Text(
                                  member.isProsumer ? 'Prosumidor' : 'Consumidor',
                                  style: context.textStyles.bodySmall?.copyWith(
                                    color: member.isProsumer ? AppTokens.primaryRed : context.colors.onSurfaceVariant,
                                    fontWeight: AppTokens.fontWeightMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (member.isProsumer) ...[
                            SizedBox(width: AppTokens.space8),
                            Text(
                              Formatters.formatPower(member.installedCapacity),
                              style: context.textStyles.bodySmall?.copyWith(
                                color: context.colors.onSurfaceVariant,
                                fontWeight: AppTokens.fontWeightMedium,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: context.colors.onSurfaceVariant,
                ),
              ],
            ),
            SizedBox(height: AppTokens.space12),
            Divider(height: 1, color: context.colors.outline.withValues(alpha: 0.1)),
            SizedBox(height: AppTokens.space12),
            // Métricas energéticas
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    'Consumo',
                    Formatters.formatEnergy(energyRecord.energyConsumed),
                    Icons.trending_down_rounded,
                    AppTokens.error,
                  ),
                ),
                if (member.isProsumer) ...[
                  Container(
                    width: 1,
                    height: 30,
                    color: context.colors.outline.withValues(alpha: 0.1),
                  ),
                  Expanded(
                    child: _buildMetricItem(
                      'Generación',
                      Formatters.formatEnergy(energyRecord.energyGenerated),
                      Icons.wb_sunny_outlined,
                      AppTokens.primaryRed,
                    ),
                  ),
                ],
                Container(
                  width: 1,
                  height: 30,
                  color: context.colors.outline.withValues(alpha: 0.1),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Balance',
                    Formatters.formatEnergy(energyRecord.netBalance),
                    energyRecord.netBalance >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                    energyRecord.netBalance >= 0 ? Colors.green : AppTokens.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        SizedBox(height: AppTokens.space4),
        Text(
          value,
          style: context.textStyles.bodyMedium?.copyWith(
            color: color,
            fontWeight: AppTokens.fontWeightBold,
          ),
          textAlign: TextAlign.center,
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
    );
  }

  Widget _buildQuickAccessMenu() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Acceso Rápido',
            style: context.textStyles.titleMedium?.copyWith(
              fontWeight: AppTokens.fontWeightBold,
            ),
          ),
          SizedBox(height: AppTokens.space12),
          Row(
            children: [
              Expanded(
                child: _buildQuickAccessCard(
                  'Registro Energético',
                  Icons.analytics_outlined,
                  Colors.blue,
                  () => Navigator.pushNamed(context, 'energyRecords'),
                ),
              ),
              SizedBox(width: AppTokens.space12),
              Expanded(
                child: _buildQuickAccessCard(
                  'PDE',
                  Icons.share_outlined,
                  Colors.orange,
                  () => Navigator.pushNamed(context, 'pdeAllocation'),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space12),
          Row(
            children: [
              Expanded(
                child: _buildQuickAccessCard(
                  'Mercado P2P',
                  Icons.handshake_outlined,
                  Colors.green,
                  () => Navigator.pushNamed(context, 'p2pMarket'),
                ),
              ),
              SizedBox(width: AppTokens.space12),
              Expanded(
                child: _buildQuickAccessCard(
                  'Créditos',
                  Icons.account_balance_wallet_outlined,
                  Colors.purple,
                  () => Navigator.pushNamed(context, 'energyCredits'),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space12),
          Row(
            children: [
              Expanded(
                child: _buildQuickAccessCard(
                  'Liquidación',
                  Icons.receipt_long_outlined,
                  Colors.teal,
                  () => Navigator.pushNamed(context, 'monthlyBilling'),
                ),
              ),
              SizedBox(width: AppTokens.space12),
              Expanded(
                child: _buildQuickAccessCard(
                  'Reportes',
                  Icons.insights_outlined,
                  Colors.indigo,
                  () => Navigator.pushNamed(context, 'reports'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppTokens.borderRadiusMedium,
      child: Container(
        padding: EdgeInsets.all(AppTokens.space16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: AppTokens.borderRadiusMedium,
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: AppTokens.borderRadiusSmall,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(height: AppTokens.space8),
            Text(
              title,
              style: context.textStyles.bodySmall?.copyWith(
                fontWeight: AppTokens.fontWeightBold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de la Comunidad'),
        elevation: 0,
        backgroundColor: context.colors.surface,
      ),
      backgroundColor: context.colors.surfaceContainerLowest,
      body: ListView(
        padding: EdgeInsets.only(
          top: AppTokens.space16,
          bottom: AppTokens.space24,
        ),
        children: [
          _buildStatsCard(),
          SizedBox(height: AppTokens.space16),
          _buildQuickAccessMenu(),
          SizedBox(height: AppTokens.space24),
          _buildFilters(),
          SizedBox(height: AppTokens.space16),
          _buildMembersList(),
        ],
      ),
    );
  }
}
