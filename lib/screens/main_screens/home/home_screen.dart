import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/utils/formatters.dart';
import 'package:be_energy/routes.dart';
import 'package:be_energy/utils/metodos.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../models/callmodels.dart';
import '../../../models/community_models.dart';
import '../../../data/fake_data.dart';
import '../../../data/fake_data_phase2.dart';
import '../../../data/fake_data_january_2026.dart';
import '../../../data/fake_periods_data.dart';
import '../consumer/consumer_marketplace_screen.dart';
import 'transaction_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final MyUser? myUser;
  const HomeScreen({super.key, this.myUser});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Metodos metodos = Metodos();
  String _selectedPeriod = FakePeriodsData.currentPeriod; // Período actual por defecto
  bool _isAdminView = false; // Vista de usuario por defecto

  /// Obtiene el período seleccionado como objeto MonthPeriod
  MonthPeriod get _currentPeriodData {
    return FakePeriodsData.getPeriodByKey(_selectedPeriod) ??
           FakePeriodsData.currentPeriodData;
  }

  /// Verifica si el período seleccionado es el actual
  bool get _isCurrentPeriod {
    return _currentPeriodData.status == PeriodStatus.current;
  }

  // Transacciones P2P según período seleccionado
  List<Map<String, dynamic>> get data {
    // Enero 2026: ingreso por PDE del consumidor
    if (_selectedPeriod == '2026-01') {
      final pde = FakeDataPhase2.pdeDec2025;
      final totalCost = pde.allocatedEnergy * FakeDataPhase2.precioP2P; // 41.21 × 400 = 16484
      final consumer = FakeDataPhase2.cristianHoyos;
      return [
        {
          'numTransaccion': 1,
          'entrada': true,
          'nombre': '${consumer.userName} ${consumer.userLastName}',
          'dinero': Formatters.formatCurrency(totalCost),
          'energia': Formatters.formatEnergy(pde.allocatedEnergy),
          'fecha': 'Ene 2026',
          'fuente': 'PDE',
        },
      ];
    }

    // Períodos históricos: mapear desde contratos
    List contracts;
    switch (_selectedPeriod) {
      case '2025-12': // Diciembre 2025 - Modelo antiguo
        contracts = FakeDataPhase2.allContracts.take(5).toList();
        break;
      default: // Históricos
        contracts = FakeData.p2pContracts.take(5).toList();
    }
    return contracts.asMap().entries.map((entry) {
      final index = entry.key;
      final contract = entry.value;
      final isIncome = contract.sellerId == (widget.myUser?.idUser ?? 24);
      final nombre = isIncome ? contract.buyerName : contract.sellerName;

      final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
      final fecha = '${contract.createdAt.day}-${months[contract.createdAt.month - 1]}';

      return {
        'numTransaccion': index + 1,
        'entrada': isIncome,
        'nombre': nombre,
        'dinero': Formatters.formatCurrency(contract.totalValue),
        'energia': Formatters.formatEnergy(contract.energyCommitted),
        'fecha': fecha,
        'fuente': 'P2P'
      };
    }).toList();
  }

  List<GGData> _getChartData() {
    // Datos según vista (Admin/Usuario) y período seleccionado
    late dynamic stats;
    late int p2pEnergy;
    // Para 2026-01: Red = solo importación real de la red (no autoconsumo solar)
    double? gridImportOverride;

    switch (_selectedPeriod) {
      case '2026-01': // Enero 2026 – datos del caso de estudio
        stats = _isAdminView
            ? FakeDataPhase2.communityStats          // Admin: comunidad agregada
            : FakeDataPhase2.cristianIndividualStatsDec2025; // Usuario: prosumidor l₁

        // P2P: energía del contrato activo (408.38 kWh)
        p2pEnergy = FakeDataPhase2.allContracts
            .fold<double>(0, (sum, c) => sum + c.energyCommitted)
            .toInt();

        // Prosumidor l₁ no importa de red (su 107.7 es autoconsumo solar)
        // Admin: solo el consumidor k₁ importa 120 kWh de red
        gridImportOverride = _isAdminView ? 120.0 : 0.0;
        break;

      case '2025-12': // Diciembre 2025 – datos históricos Phase1
        stats = _isAdminView
            ? FakeData.communityStats
            : FakeData.cristianIndividualStatsNov2025;

        p2pEnergy = _isAdminView
            ? 650
            : 30;
        break;

      default: // Históricos anteriores
        stats = _isAdminView
            ? FakeData.communityStats
            : FakeData.cristianIndividualStatsNov2025;

        p2pEnergy = _isAdminView
            ? 650
            : 30;
    }

    final List<GGData> chartData = [
      GGData('Directa Solar', stats.totalEnergyGenerated.toInt()),
      GGData('Red', (gridImportOverride ?? stats.totalEnergyImported).toInt()),
      GGData('Intercambios P2P', p2pEnergy),
    ];
    return chartData;
  }

  Widget _grafico() {
    List<GGData> dataCircularSeries = _getChartData();
    return SfCircularChart(
      legend: Legend(
        isVisible: true,
        overflowMode: LegendItemOverflowMode.wrap,
        textStyle: context.textStyles.bodySmall?.copyWith(
          fontSize: AppTokens.fontSize10,
        ),
        position: LegendPosition.bottom,
      ),
      series: <CircularSeries>[
        DoughnutSeries<GGData, String>(
          dataSource: dataCircularSeries,
          xValueMapper: (data, _) => data.fuente,
          yValueMapper: (datum, _) => datum.consumo,
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            labelPosition: ChartDataLabelPosition.outside,
            connectorLineSettings: ConnectorLineSettings(
              type: ConnectorType.curve,
              length: '10%',
            ),
            textStyle: TextStyle(
              color: context.colors.onSurface,
              fontSize: AppTokens.fontSize10,
              fontWeight: AppTokens.fontWeightMedium,
            ),
          ),
        )
      ],
    );
  }

  Widget _trData() {
    // Seleccionar datos según vista y período
    late CommunityStats stats;
    late double costPerKwh;

    switch (_selectedPeriod) {
      case '2026-01':
        stats = _isAdminView
            ? FakeDataPhase2.communityStats
            : FakeDataPhase2.cristianIndividualStatsDec2025;
        costPerKwh = FakeDataPhase2.mc; // MC = 300 COP/kWh
        break;
      default:
        stats = _isAdminView
            ? FakeData.communityStats
            : FakeData.cristianIndividualStatsNov2025;
        costPerKwh = FakeData.regulatedCosts.totalCostPerKwh;
    }

    // Para 2026-01: la primera tarjeta depende de la vista
    // Prosumidor: Autoconsumo (107.7 kWh desde solar, no es importación de red)
    // Admin: Importada de red (120 kWh, solo el consumidor k₁)
    final bool isJan2026 = _selectedPeriod == '2026-01';
    final String firstTitle = isJan2026
        ? (_isAdminView ? "Importada de red" : "Autoconsumo solar")
        : "Importe";
    final double firstEnergy = isJan2026
        ? (_isAdminView ? 120.0 : 107.7) // Admin: red del consumidor | Prosumidor: autoconsumo
        : stats.totalEnergyImported;
    final IconData firstIcon = isJan2026 && !_isAdminView
        ? Icons.light_mode_rounded   // sol para autoconsumo
        : Icons.trending_down_rounded;
    final Color firstColor = isJan2026 && !_isAdminView
        ? AppTokens.energyGreen      // verde para autoconsumo solar
        : AppTokens.error;

    final exportEnergy = stats.totalEnergyExported;

    return Column(
      children: [
        _energyCard(
          title: firstTitle,
          energy: firstEnergy,
          amount: firstEnergy * costPerKwh,
          icon: firstIcon,
          color: firstColor,
        ),
        SizedBox(height: AppTokens.space8),
        _energyCard(
          title: "Exportada",
          energy: exportEnergy,
          amount: exportEnergy * costPerKwh,
          icon: Icons.trending_up_rounded,
          color: AppTokens.primaryRed,
        ),
        // Excedentes totales – solo para enero 2026
        if (isJan2026) ...[
          SizedBox(height: AppTokens.space8),
          _energyCard(
            title: "Excedentes totales",
            energy: FakeDataPhase2.pdeDec2025.excessEnergy, // 412.5 kWh
            amount: 0, // No tiene valor monetario directo; se oculta en el card
            icon: Icons.bolt_rounded,
            color: AppTokens.primaryPurple,
            subtitle: "Disponibles para la comunidad",
            hideAmount: true,
          ),
        ],
      ],
    );
  }

  /// Widget reutilizable para mostrar tarjetas de energía (import/export)
  Widget _energyCard({
    required String title,
    required double energy,
    required double amount,
    required IconData icon,
    required Color color,
    String? subtitle,
    bool hideAmount = false,
  }) {
    return Container(
      padding: EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppTokens.borderRadiusMedium,
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppTokens.space12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: AppTokens.borderRadiusSmall,
            ),
            child: Icon(
              icon,
              size: 28,
              color: color,
            ),
          ),
          SizedBox(width: AppTokens.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textStyles.labelSmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    fontWeight: AppTokens.fontWeightMedium,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: AppTokens.space4),
                  Text(
                    subtitle,
                    style: context.textStyles.labelSmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                      fontSize: AppTokens.fontSize10,
                    ),
                  ),
                ],
                SizedBox(height: AppTokens.space8),
                Text(
                  Formatters.formatEnergy(energy),
                  style: context.textStyles.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: AppTokens.fontWeightBold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (!hideAmount) ...[
                  SizedBox(height: AppTokens.space4),
                  Text(
                    Formatters.formatCurrency(amount),
                    style: context.textStyles.titleMedium?.copyWith(
                      color: color,
                      fontWeight: AppTokens.fontWeightSemiBold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _saludoText() {
    // Determinar datos según vista (Admin/Usuario) y período seleccionado
    final periodData = _currentPeriodData;
    final periodLabel = periodData.status == PeriodStatus.current ? 'Actual' : 'Histórico';

    // Texto descriptivo según vista
    final viewLabel = _isAdminView ? 'Comunidad UAO' : 'Mi Energía';

    // Determinar total de miembros según período
    late int totalMembers;
    if (_isAdminView) {
      totalMembers = _selectedPeriod == '2026-01'
          ? FakeDataPhase2.allMembers.length
          : FakeData.communityStats.totalMembers;
    } else {
      totalMembers = 1; // Vista usuario: solo 1 (usuario individual)
    }

    final membersLabel = _isAdminView ? '$totalMembers miembros' : 'Vista Individual';

    return Container(
      width: context.width,
      padding: EdgeInsets.symmetric(
        horizontal: AppTokens.space16,
        vertical: AppTokens.space12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            viewLabel,
            style: context.textStyles.titleLarge?.copyWith(
              fontWeight: AppTokens.fontWeightBold,
            ),
          ),
          SizedBox(height: AppTokens.space4),
          Text(
            "$periodLabel • $membersLabel",
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Indicador visual compacto de estado mensual con botón para cambiar período
  Widget _buildMonthlyStatusIndicator() {
    // Obtener datos del período desde FakePeriodsData
    final periodData = FakePeriodsData.getPeriodByKey(_selectedPeriod) ??
                       FakePeriodsData.currentPeriodData;

    final statusColor = periodData.getStatusColor();
    final statusIcon = periodData.getStatusIcon();
    final statusText = periodData.getStatusText();
    final periodLabel = periodData.displayName;
    final isCurrentMonth = periodData.status == PeriodStatus.current;

    return InkWell(
      onTap: _showPeriodSelectorModal,
      borderRadius: AppTokens.borderRadiusMedium,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
        padding: EdgeInsets.all(AppTokens.space12),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          borderRadius: AppTokens.borderRadiusMedium,
          border: Border.all(
            color: statusColor.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Indicador pulsante para mes en curso
            if (isCurrentMonth)
              Container(
                width: 10,
                height: 10,
                margin: EdgeInsets.only(right: AppTokens.space8),
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withValues(alpha: 0.6),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              )
            else
              Container(
                margin: EdgeInsets.only(right: AppTokens.space8),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: 16,
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusText,
                    style: context.textStyles.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: AppTokens.fontWeightBold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: AppTokens.space4),
                  Text(
                    periodLabel,
                    style: context.textStyles.bodyMedium?.copyWith(
                      fontWeight: AppTokens.fontWeightSemiBold,
                    ),
                  ),
                ],
              ),
            ),
            // Botón de cambio de período
            Container(
              padding: EdgeInsets.all(AppTokens.space8),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: AppTokens.borderRadiusSmall,
              ),
              child: Icon(
                Icons.swap_horiz_rounded,
                color: statusColor,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Muestra modal de selección de período
  void _showPeriodSelectorModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.45,
          ),
          decoration: BoxDecoration(
            color: this.context.colors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppTokens.space20),
              topRight: Radius.circular(AppTokens.space20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: AppTokens.space12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: this.context.colors.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: AppTokens.space16),
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppTokens.space20),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      color: this.context.colors.primary,
                      size: 24,
                    ),
                    SizedBox(width: AppTokens.space12),
                    Text(
                      'Seleccionar Período',
                      style: this.context.textStyles.titleLarge?.copyWith(
                        fontWeight: AppTokens.fontWeightBold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppTokens.space20),
              // Lista de períodos con scroll
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ...FakePeriodsData.availablePeriods.map((period) {
                        final metadata = FakePeriodsData.getPeriodMetadata(period.period);
                        final subtitle = metadata?['description'] ?? 'Datos de comunidad energética';

                        // Determinar badge según estado
                        String badge;
                        switch (period.status) {
                          case PeriodStatus.current:
                            badge = '✨';
                            break;
                          case PeriodStatus.historical:
                            badge = period.hasData ? '🔄' : '📊';
                            break;
                          case PeriodStatus.future:
                            badge = '🔒';
                            break;
                        }

                        return Column(
                          children: [
                            if (FakePeriodsData.availablePeriods.indexOf(period) > 0)
                              Divider(height: 1, color: this.context.colors.outline.withValues(alpha: 0.1)),
                            _buildModalPeriodOption(
                              period: period.period,
                              title: period.displayName,
                              subtitle: subtitle,
                              icon: period.getStatusIcon(),
                              iconColor: period.getStatusColor(),
                              badge: badge,
                              enabled: period.hasData,
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppTokens.space20),
            ],
          ),
        );
      },
    );
  }

  /// Opción de período en el modal
  Widget _buildModalPeriodOption({
    required String period,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required String badge,
    bool enabled = true,
  }) {
    final isSelected = _selectedPeriod == period;

    return InkWell(
      onTap: enabled ? () {
        setState(() {
          _selectedPeriod = period;
        });
        Navigator.pop(context);
        context.showInfoSnackbar('Período cambiado a $title');
      } : null,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppTokens.space20,
          vertical: AppTokens.space16,
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(AppTokens.space12),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: AppTokens.borderRadiusSmall,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            SizedBox(width: AppTokens.space16),
            // Text info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: context.textStyles.bodyLarge?.copyWith(
                          fontWeight: AppTokens.fontWeightSemiBold,
                        ),
                      ),
                      SizedBox(width: AppTokens.space8),
                      Text(
                        badge,
                        style: TextStyle(fontSize: AppTokens.fontSize16),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTokens.space4),
                  Text(
                    subtitle,
                    style: context.textStyles.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            // Checkmark
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: iconColor,
                size: 24,
              )
            else
              Icon(
                Icons.radio_button_unchecked,
                color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _indicadores() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
      padding: EdgeInsets.all(AppTokens.space12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppTokens.borderRadiusLarge,
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _grafico(),
          ),
          SizedBox(width: AppTokens.space12),
          Expanded(
            flex: 3,
            child: _trData(),
          )
        ],
      ),
    );
  }

  Widget _btnActividadIcon(String nombre, BuildContext context, int onTap, IconData icon) {
    return Expanded(
      flex: 1,
      child: InkWell(
        onTap: () {
          switch (onTap) {
            case 1:
              context.push(const TradingScreen());
              break;
            case 2:
              context.push(const BolsaScreen());
              break;
            case 3:
              context.push(
                AprendeScreen(myUser: widget.myUser!)
              );
              break;
            default:
              context.push(const TradingScreen());

              break;
          }
        },
        borderRadius: AppTokens.borderRadiusMedium,
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: AppTokens.space16,
            horizontal: AppTokens.space12,
          ),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: AppTokens.borderRadiusMedium,
            border: Border.all(
              color: context.colors.outline.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(AppTokens.space12),
                decoration: BoxDecoration(
                  color: context.colors.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: AppTokens.borderRadiusSmall,
                ),
                child: Icon(
                  icon,
                  color: context.colors.primary,
                  size: 24,
                ),
              ),
              SizedBox(height: AppTokens.space8),
              Text(
                nombre,
                style: context.textStyles.labelMedium,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actividades() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
      child: Column(
        children: [
          // Vista Admin: Mostrar Gestión de la Comunidad primero y destacado
          if (_isAdminView) ...[
            _buildCommunityManagementButton(),
            SizedBox(height: AppTokens.space12),
          ],
          // Actividades comunes para ambas vistas
          Row(
            children: [
              _btnActividadIcon(
                "Transferir",
                context,
                1,
                Icons.swap_horiz_rounded,
              ),
              SizedBox(width: AppTokens.space12),
              _btnActividadIcon(
                "Bolsa",
                context,
                2,
                Icons.account_balance_outlined,
              ),
              SizedBox(width: AppTokens.space12),
              _btnActividadIcon(
                "Aprende",
                context,
                3,
                Icons.bookmark_outline_rounded,
              ),
            ],
          ),
          // Vista Usuario: No mostrar Gestión de la Comunidad (solo para admins)
        ],
      ),
    );
  }

  /// Botón de Gestión de la Comunidad
  Widget _buildCommunityManagementButton() {
    return InkWell(
            onTap: () {
              context.push(const CommunityManagementScreen());
            },
            borderRadius: AppTokens.borderRadiusMedium,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: AppTokens.space16,
                horizontal: AppTokens.space16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTokens.primaryRed,
                    AppTokens.primaryRed.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: AppTokens.borderRadiusMedium,
                boxShadow: [
                  BoxShadow(
                    color: AppTokens.primaryRed.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.groups_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: AppTokens.space12),
                  Text(
                    "Gestión de la Comunidad",
                    style: context.textStyles.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: AppTokens.fontWeightBold,
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget _miniListHistorial() {
    return ListView.separated(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.length,
      separatorBuilder: (context, index) => SizedBox(height: AppTokens.space8),
      itemBuilder: (BuildContext context, int index) {
        final transaction = data[index];
        final bool isIncome = transaction['entrada'] as bool;
        final color = isIncome ? AppTokens.primaryRed : AppTokens.error;

        return InkWell(
          onTap: () {
            if (_selectedPeriod == '2026-01') {
              context.push(const TransactionDetailScreen());
            } else {
              context.showInfoSnackbar(
                "Transacción #${transaction['numTransaccion']}"
              );
            }
          },
          borderRadius: AppTokens.borderRadiusMedium,
          child: Container(
            padding: EdgeInsets.all(AppTokens.space12),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: AppTokens.borderRadiusMedium,
              border: Border.all(
                color: context.colors.outline.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Icon Container
                Container(
                  padding: EdgeInsets.all(AppTokens.space8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: AppTokens.borderRadiusSmall,
                  ),
                  child: Icon(
                    isIncome ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                    size: 20,
                    color: color,
                  ),
                ),
                SizedBox(width: AppTokens.space12),
                // Transaction Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${transaction['nombre']}",
                        style: context.textStyles.bodyMedium?.copyWith(
                          fontWeight: AppTokens.fontWeightMedium,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: AppTokens.space4),
                      Text(
                        "${transaction['fuente']} • ${transaction['energia']}",
                        style: context.textStyles.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppTokens.space8),
                // Amount & Date
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${transaction['dinero']}",
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: color,
                        fontWeight: AppTokens.fontWeightBold,
                      ),
                    ),
                    SizedBox(height: AppTokens.space4),
                    Text(
                      "${transaction['fecha']}",
                      style: context.textStyles.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _titulobtnHistorial() {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTokens.space12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Transacciones",
            style: context.textStyles.titleMedium?.copyWith(
              fontWeight: AppTokens.fontWeightSemiBold,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.arrow_forward_rounded,
              size: 24,
              color: context.colors.primary,
            ),
            tooltip: "Ver todas",
            onPressed: () {
              // TODO: Navegar a la pantalla de historial completo
              context.showInfoSnackbar("Próximamente: Ver historial completo");
            },
          ),
        ],
      ),
    );
  }

  Widget _minihostiral() {
    return Container(
      padding: EdgeInsets.all(AppTokens.space16),
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppTokens.borderRadiusLarge,
      ),
      child: Column(
        children: [
          _titulobtnHistorial(),
          _miniListHistorial(),
        ],
      ),
    );
  }

  /// Widget destacado del PDE - Solo para Enero 2026
  Widget _buildPDEHighlightCard() {
    final minValue = FakeDataJanuary2026.pdeConstantsJan2026.mcmValorEnergiaPromedio * 1.1;
    final maxValue = (FakeDataJanuary2026.pdeConstantsJan2026.costoEnergia - FakeDataJanuary2026.pdeConstantsJan2026.costoComercializacion) * 0.95;
    return GestureDetector(
      onTap: () {
        // Navegar al marketplace con tab de Enero 2026
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ConsumerMarketplaceScreen(),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
        padding: EdgeInsets.all(AppTokens.space20),
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
              color: AppTokens.primaryRed.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
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
                  padding: EdgeInsets.all(AppTokens.space12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: AppTokens.borderRadiusSmall,
                  ),
                  child: const Icon(
                    Icons.bolt,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                SizedBox(width: AppTokens.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '⚡ Nuevo: PDE Disponible',
                        style: context.textStyles.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: AppTokens.fontWeightBold,
                        ),
                      ),
                      SizedBox(height: AppTokens.space4),
                      Text(
                        'Enero 2026 - Modelo de Ofertas',
                        style: context.textStyles.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 20,
                ),
              ],
            ),
            SizedBox(height: AppTokens.space20),

            // PDE Amount
            // Container(
            //   padding: EdgeInsets.all(AppTokens.space16),
            //   decoration: BoxDecoration(
            //     color: Colors.white.withValues(alpha: 0.15),
            //     borderRadius: AppTokens.borderRadiusMedium,
            //     border: Border.all(
            //       color: Colors.white.withValues(alpha: 0.3),
            //       width: 1,
            //     ),
            //   ),
            //   child: Column(
            //     children: [
            //       Row(
            //         mainAxisAlignment: MainAxisAlignment.center,
            //         crossAxisAlignment: CrossAxisAlignment.end,
            //         children: [
            //           Text(
            //             totalPDEAvailable.toStringAsFixed(1),
            //             style: const TextStyle(
            //               color: Colors.white,
            //               fontSize: 48,
            //               fontWeight: FontWeight.bold,
            //             ),
            //           ),
            //           SizedBox(width: AppTokens.space8),
            //           Padding(
            //             padding: EdgeInsets.only(bottom: AppTokens.space12),
            //             child: Text(
            //               'kWh',
            //               style: TextStyle(
            //                 color: Colors.white.withValues(alpha: 0.9),
            //                 fontSize: 20,
            //                 fontWeight: AppTokens.fontWeightSemiBold,
            //               ),
            //             ),
            //           ),
            //         ],
            //       ),
            //       SizedBox(height: AppTokens.space8),
            //       Text(
            //         'Programa de Distribución de Excedentes',
            //         style: TextStyle(
            //           color: Colors.white.withValues(alpha: 0.8),
            //           fontSize: 12,
            //         ),
            //         textAlign: TextAlign.center,
            //       ),
            //     ],
            //   ),
            // ),
            // SizedBox(height: AppTokens.space16),

            // Info footer
            Row(
              children: [
                // Expanded(
                //   child: Container(
                //     padding: EdgeInsets.all(AppTokens.space12),
                //     decoration: BoxDecoration(
                //       color: Colors.white.withValues(alpha: 0.1),
                //       borderRadius: AppTokens.borderRadiusSmall,
                //     ),
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         Text(
                //           'Prosumidor',
                //           style: TextStyle(
                //             color: Colors.white.withValues(alpha: 0.7),
                //             fontSize: 11,
                //           ),
                //         ),
                //         SizedBox(height: AppTokens.space4),
                //         Text(
                //           prosumerName,
                //           style: const TextStyle(
                //             color: Colors.white,
                //             fontSize: 13,
                //             fontWeight: FontWeight.bold,
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                // SizedBox(width: AppTokens.space12),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(AppTokens.space12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: AppTokens.borderRadiusSmall,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Rango Precio',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 11,
                          ),
                        ),
                        SizedBox(height: AppTokens.space4),
                        Text(
                          '$minValue - $maxValue COP',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTokens.space16),

            // CTA Button
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: AppTokens.space12,
                horizontal: AppTokens.space16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppTokens.borderRadiusMedium,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_shopping_cart,
                    color: AppTokens.primaryRed,
                    size: 20,
                  ),
                  SizedBox(width: AppTokens.space8),
                  Text(
                    'Crear Oferta de PDE',
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: AppTokens.primaryRed,
                      fontWeight: AppTokens.fontWeightBold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tarjetas de precios de referencia para el gestor comunitario (admin)
  Widget _buildPriceCardsAdmin() {
    final prices = [
      {'label': 'Precio unitario de bolsa (MC)', 'value': FakeDataPhase2.mc},
      {'label': 'Costo unitario de venta (CUV)', 'value': FakeDataPhase2.cuv},
      {'label': 'Costo de comercialización', 'value': FakeDataPhase2.costoComercializacion},
      {'label': 'Precio de transacción P2P', 'value': FakeDataPhase2.precioP2P},
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: AppTokens.space12),
            child: Text(
              "Precios de referencia",
              style: context.textStyles.titleMedium?.copyWith(
                fontWeight: AppTokens.fontWeightSemiBold,
              ),
            ),
          ),
          Container(
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
              children: prices.asMap().entries.map((entry) {
                final i = entry.key;
                final price = entry.value;
                return Column(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        price['label'] as String,
                        style: context.textStyles.bodyMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '\$${Formatters.formatNumber((price['value'] as double).toInt())} COP/kWh',
                        style: context.textStyles.bodyMedium?.copyWith(
                          fontWeight: AppTokens.fontWeightBold,
                          color: context.colors.onSurface,
                        ),
                      ),
                    ],
                  ),
                  if (i < prices.length - 1)
                    Divider(height: AppTokens.space24, color: context.colors.outline.withValues(alpha: 0.1)),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget body() {
    return ListView(
      padding: EdgeInsets.only(
        top: AppTokens.space16,
        bottom: AppTokens.space24,
      ),
      children: [
        _saludoText(),
        SizedBox(height: AppTokens.space16),
        // Indicador visual de estado mensual con selector de período
        _buildMonthlyStatusIndicator(),
        SizedBox(height: AppTokens.space16),
        // Widget destacado del PDE (solo para período actual que es Enero 2026)
        if (_isCurrentPeriod) ...[
          _buildPDEHighlightCard(),
          SizedBox(height: AppTokens.space16),
        ],
        _indicadores(),
        SizedBox(height: AppTokens.space24),
        // Precios de referencia del mes (solo admin, período actual)
        if (_isAdminView && _isCurrentPeriod) ...[
          _buildPriceCardsAdmin(),
          SizedBox(height: AppTokens.space24),
        ],
        Padding(
          padding: EdgeInsets.only(
            left: AppTokens.space16,
            bottom: AppTokens.space12,
          ),
          child: Text(
            "Actividades",
            style: context.textStyles.titleMedium?.copyWith(
              fontWeight: AppTokens.fontWeightSemiBold,
            ),
          ),
        ),
        _actividades(),
        SizedBox(height: AppTokens.space24),
        _minihostiral(),
      ],
    );
  }

  /// AppBar personalizado con botón de cambio de vista
  PreferredSizeWidget _buildAppBar() {
    final userName = widget.myUser?.nombre ?? "Cristian";

    return AppBar(
      toolbarHeight: 60,
      elevation: 0.0,
      flexibleSpace: Container(
        width: context.width,
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              blurRadius: 6,
              color: Color(0x4B1A1F24),
              offset: Offset(0, 2),
            )
          ],
          gradient: Metodos.gradientClasic(context),
          borderRadius: BorderRadius.circular(0),
        ),
      ),
      backgroundColor: Colors.transparent,
      title: Container(
        margin: const EdgeInsets.only(top: 7.5, bottom: 7.5, right: 5.0, left: 5.0),
        child: Row(
          children: [
            // Avatar
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: const Image(
                alignment: AlignmentDirectional.center,
                image: AssetImage("assets/img/avatar.jpg"),
                width: 55.0,
                height: 55.0,
              ),
            ),
            const SizedBox(width: 15.0),
            // Saludo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "¡Hola,",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "$userName!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        // Botón de cambio de vista Admin/Usuario
        Container(
          width: 45.0,
          height: 45.0,
          decoration: BoxDecoration(
            color: _isAdminView ? AppTokens.primaryRed : AppTokens.primaryBlue,
            border: Border.all(width: 2.0, color: Colors.white),
            borderRadius: BorderRadius.circular(25.0),
          ),
          margin: const EdgeInsets.only(top: 7.5, bottom: 7.5, right: 10.0),
          child: IconButton(
            icon: Icon(
              _isAdminView ? Icons.admin_panel_settings : Icons.person,
              size: 22.0,
            ),
            color: Colors.white,
            tooltip: _isAdminView ? "Vista Administrador" : "Vista Usuario",
            onPressed: () {
              setState(() {
                _isAdminView = !_isAdminView;
              });
              context.showInfoSnackbar(
                _isAdminView ? 'Vista: Administrador Comunitario' : 'Vista: Usuario'
              );
            },
          ),
        ),
        // Botón de notificaciones
        Container(
          width: 45.0,
          height: 45.0,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(width: 2.0, color: Colors.white),
            borderRadius: BorderRadius.circular(25.0),
          ),
          margin: const EdgeInsets.only(top: 7.5, bottom: 7.5, right: 15.0),
          child: IconButton(
            icon: const Icon(Icons.notifications, size: 25.0),
            color: AppTokens.primaryBlue,
            tooltip: "Notificaciones",
            onPressed: () {
              context.push(const NotificacionesScreen());
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: context.colors.surface,
      body: body(),
    );
  }
}

//Generation grid data
class GGData {
  late final String fuente;
  late final int consumo;

  GGData(this.fuente, this.consumo);
}
