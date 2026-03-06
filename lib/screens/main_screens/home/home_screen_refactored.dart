/// Home Screen refactorizado con arquitectura tipo-segura
/// Usa repositorios para abstraer la fuente de datos (fake/API)
library;

import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/utils/formatters.dart';
import 'package:be_energy/core/config/data_source_config.dart';
import 'package:be_energy/data/fake_periods_data.dart' show PeriodStatus;
import 'package:be_energy/models/callmodels.dart';
import 'package:be_energy/models/home_data_models.dart';
import 'package:be_energy/repositories/home_repository.dart';
import 'package:be_energy/routes.dart';
import 'package:be_energy/utils/metodos.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../consumer/consumer_marketplace_screen.dart';

class HomeScreen extends StatefulWidget {
  final MyUser? myUser;
  const HomeScreen({super.key, this.myUser});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Metodos metodos = Metodos();

  // Repositorio para obtener datos
  late final HomeRepository _repository;

  // Estado de la UI
  String _selectedPeriod = '2026-01'; // Se actualizará desde el repositorio
  ViewType _viewType = ViewType.user;

  // Datos cargados
  HomeScreenData? _homeData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Inicializar configuración de datasource desde entorno
    DataSourceConfig.initFromEnvironment();
    // Crear repositorio
    _repository = RepositoryFactory.createHomeRepository();
    // Cargar datos iniciales
    _loadHomeData();
  }

  /// Carga los datos del home desde el repositorio
  Future<void> _loadHomeData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Obtener período actual si es la primera carga
      if (_selectedPeriod.isEmpty) {
        _selectedPeriod = await _repository.getCurrentPeriod();
      }

      final userId = widget.myUser?.idUser ?? 24;
      final data = await _repository.getHomeData(
        period: _selectedPeriod,
        viewType: _viewType,
        userId: userId,
      );

      setState(() {
        _homeData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error cargando datos: $e';
        _isLoading = false;
      });
    }
  }

  /// Cambia el período seleccionado y recarga datos
  Future<void> _changePeriod(String newPeriod) async {
    setState(() {
      _selectedPeriod = newPeriod;
    });
    await _loadHomeData();
  }

  /// Cambia entre vista admin/usuario
  void _toggleViewType() {
    setState(() {
      _viewType = _viewType == ViewType.admin ? ViewType.user : ViewType.admin;
    });
    _loadHomeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: context.colors.surface,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: context.colors.primary),
            SizedBox(height: AppTokens.space16),
            Text(
              'Cargando datos...',
              style: context.textStyles.bodyMedium,
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppTokens.error),
            SizedBox(height: AppTokens.space16),
            Text(
              _error!,
              style: context.textStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppTokens.space16),
            ElevatedButton(
              onPressed: _loadHomeData,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_homeData == null) {
      return const Center(child: Text('No hay datos disponibles'));
    }

    return RefreshIndicator(
      onRefresh: _loadHomeData,
      child: ListView(
        padding: EdgeInsets.only(
          top: AppTokens.space16,
          bottom: AppTokens.space24,
        ),
        children: [
          _buildGreeting(),
          SizedBox(height: AppTokens.space16),
          _buildPeriodIndicator(),
          SizedBox(height: AppTokens.space16),

          // Widget destacado del PDE (solo para período actual)
          if (_homeData!.isCurrentPeriod && _homeData!.pdeInfo != null) ...[
            _buildPDEHighlightCard(),
            SizedBox(height: AppTokens.space16),
          ],

          _buildEnergyIndicators(),
          SizedBox(height: AppTokens.space24),

          // Precios de referencia (solo admin, período actual)
          if (_homeData!.isAdminView &&
              _homeData!.isCurrentPeriod &&
              _homeData!.priceReferences != null) ...[
            _buildPriceReferences(),
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
          _buildActivities(),
          SizedBox(height: AppTokens.space24),
          _buildRecentTransactions(),
        ],
      ),
    );
  }

  /// Widget de saludo con información del período
  Widget _buildGreeting() {
    final data = _homeData!;
    final viewLabel = data.isAdminView ? 'Comunidad UAO' : 'Mi Energía';
    final periodLabel = data.periodInfo.isCurrent ? 'Actual' : 'Histórico';
    final membersLabel = data.isAdminView
        ? '${data.userProfile.totalMembers} miembros'
        : 'Vista Individual';

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

  /// Indicador del período con botón para cambiar
  Widget _buildPeriodIndicator() {
    final periodInfo = _homeData!.periodInfo;
    final statusColor = _getStatusColor(periodInfo.status);
    final statusIcon = _getStatusIcon(periodInfo.status);
    final statusText = _getStatusText(periodInfo.status);

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
            if (periodInfo.isCurrent)
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
                child: Icon(statusIcon, color: statusColor, size: 16),
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
                    periodInfo.displayName,
                    style: context.textStyles.bodyMedium?.copyWith(
                      fontWeight: AppTokens.fontWeightSemiBold,
                    ),
                  ),
                ],
              ),
            ),
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

  /// Modal de selección de período
  Future<void> _showPeriodSelectorModal() async {
    try {
      final availablePeriods = await _repository.getAvailablePeriods();

      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (BuildContext modalContext) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(modalContext).size.height * 0.45,
            ),
            decoration: BoxDecoration(
              color: context.colors.surface,
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
                    color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),
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
                        color: context.colors.primary,
                        size: 24,
                      ),
                      SizedBox(width: AppTokens.space12),
                      Text(
                        'Seleccionar Período',
                        style: context.textStyles.titleLarge?.copyWith(
                          fontWeight: AppTokens.fontWeightBold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppTokens.space20),
                // Lista de períodos
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: availablePeriods.periods.map((period) {
                        return _buildPeriodOption(period);
                      }).toList(),
                    ),
                  ),
                ),
                SizedBox(height: AppTokens.space20),
              ],
            ),
          );
        },
      );
    } catch (e) {
      if (mounted) {
        context.showErrorSnackbar('Error cargando períodos: $e');
      }
    }
  }

  /// Opción de período en el modal
  Widget _buildPeriodOption(PeriodInfo period) {
    final isSelected = _selectedPeriod == period.period;
    final statusColor = _getStatusColor(period.status);
    final statusIcon = _getStatusIcon(period.status);

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

    return InkWell(
      onTap: period.hasData ? () {
        _changePeriod(period.period);
        Navigator.pop(context);
        context.showInfoSnackbar('Período cambiado a ${period.displayName}');
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
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: AppTokens.borderRadiusSmall,
              ),
              child: Icon(statusIcon, color: statusColor, size: 24),
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
                        period.displayName,
                        style: context.textStyles.bodyLarge?.copyWith(
                          fontWeight: AppTokens.fontWeightSemiBold,
                        ),
                      ),
                      SizedBox(width: AppTokens.space8),
                      Text(badge, style: TextStyle(fontSize: AppTokens.fontSize16)),
                    ],
                  ),
                  if (period.description != null) ...[
                    SizedBox(height: AppTokens.space4),
                    Text(
                      period.description!,
                      style: context.textStyles.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Checkmark
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected
                  ? statusColor
                  : context.colors.onSurfaceVariant.withValues(alpha: 0.4),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  /// Indicadores de energía (gráfico + tarjetas)
  Widget _buildEnergyIndicators() {
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
          Expanded(flex: 2, child: _buildChart()),
          SizedBox(width: AppTokens.space12),
          Expanded(flex: 3, child: _buildEnergyCards()),
        ],
      ),
    );
  }

  /// Gráfico circular de energía
  Widget _buildChart() {
    final chartData = _homeData!.energyStats.chartData.map((point) {
      return GGData(point.label, point.value.toInt());
    }).toList();

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
          dataSource: chartData,
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

  /// Tarjetas de energía importada/exportada
  Widget _buildEnergyCards() {
    final stats = _homeData!.energyStats;
    final isJan2026 = _selectedPeriod == '2026-01';

    // Primera tarjeta: depende del período y vista
    final String firstTitle = isJan2026
        ? (_homeData!.isAdminView ? "Importada de red" : "Autoconsumo solar")
        : "Importe";
    final double firstEnergy = isJan2026
        ? (_homeData!.isAdminView ? 120.0 : stats.solarAutoconsumption ?? 107.7)
        : stats.totalImported;
    final IconData firstIcon = isJan2026 && !_homeData!.isAdminView
        ? Icons.light_mode_rounded
        : Icons.trending_down_rounded;
    final Color firstColor = isJan2026 && !_homeData!.isAdminView
        ? AppTokens.energyGreen
        : AppTokens.error;

    return Column(
      children: [
        _buildEnergyCard(
          title: firstTitle,
          energy: firstEnergy,
          amount: firstEnergy * stats.costPerKwh,
          icon: firstIcon,
          color: firstColor,
        ),
        SizedBox(height: AppTokens.space8),
        _buildEnergyCard(
          title: "Exportada",
          energy: stats.totalExported,
          amount: stats.totalExported * stats.costPerKwh,
          icon: Icons.trending_up_rounded,
          color: AppTokens.primaryRed,
        ),
        // Excedentes totales – solo para enero 2026
        if (isJan2026 && stats.totalSurplus != null) ...[
          SizedBox(height: AppTokens.space8),
          _buildEnergyCard(
            title: "Excedentes totales",
            energy: stats.totalSurplus!,
            amount: 0,
            icon: Icons.bolt_rounded,
            color: AppTokens.primaryPurple,
            subtitle: "Disponibles para la comunidad",
            hideAmount: true,
          ),
        ],
      ],
    );
  }

  /// Widget reutilizable para tarjetas de energía
  Widget _buildEnergyCard({
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
            child: Icon(icon, size: 28, color: color),
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

  /// Widget destacado del PDE
  Widget _buildPDEHighlightCard() {
    final pdeInfo = _homeData!.pdeInfo!;

    return GestureDetector(
      onTap: () {
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
                  child: const Icon(Icons.bolt, color: Colors.white, size: 28),
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

            // Info footer
            Row(
              children: [
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
                          '${pdeInfo.minPrice.toStringAsFixed(1)} - ${pdeInfo.maxPrice.toStringAsFixed(1)} COP',
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
                  const Icon(Icons.add_shopping_cart, color: AppTokens.primaryRed, size: 20),
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

  /// Tarjetas de precios de referencia (solo admin)
  Widget _buildPriceReferences() {
    final prices = _homeData!.priceReferences!;

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
                        price.label,
                        style: context.textStyles.bodyMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '\$${Formatters.formatNumber(price.value.toInt())} COP/kWh',
                        style: context.textStyles.bodyMedium?.copyWith(
                          fontWeight: AppTokens.fontWeightBold,
                          color: context.colors.onSurface,
                        ),
                      ),
                    ],
                  ),
                  if (i < prices.length - 1)
                    Divider(
                      height: AppTokens.space24,
                      color: context.colors.outline.withValues(alpha: 0.1),
                    ),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Actividades (botones de acción)
  Widget _buildActivities() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
      child: Column(
        children: [
          // Vista Admin: Gestión de la Comunidad
          if (_homeData!.isAdminView) ...[
            _buildCommunityManagementButton(),
            SizedBox(height: AppTokens.space12),
          ],
          // Actividades comunes
          Row(
            children: [
              _buildActivityButton("Transferir", Icons.swap_horiz_rounded, () {
                context.push(const TradingScreen());
              }),
              SizedBox(width: AppTokens.space12),
              _buildActivityButton("Bolsa", Icons.account_balance_outlined, () {
                context.push(const BolsaScreen());
              }),
              SizedBox(width: AppTokens.space12),
              _buildActivityButton("Aprende", Icons.bookmark_outline_rounded, () {
                context.push(AprendeScreen(myUser: widget.myUser!));
              }),
            ],
          ),
        ],
      ),
    );
  }

  /// Botón de actividad individual
  Widget _buildActivityButton(String label, IconData icon, VoidCallback onTap) {
    return Expanded(
      flex: 1,
      child: InkWell(
        onTap: onTap,
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
                child: Icon(icon, color: context.colors.primary, size: 24),
              ),
              SizedBox(height: AppTokens.space8),
              Text(
                label,
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

  /// Botón de Gestión de la Comunidad (solo admin)
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
            const Icon(Icons.groups_rounded, color: Colors.white, size: 24),
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

  /// Transacciones recientes
  Widget _buildRecentTransactions() {
    final transactions = _homeData!.recentTransactions;

    return Container(
      padding: EdgeInsets.all(AppTokens.space16),
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppTokens.borderRadiusLarge,
      ),
      child: Column(
        children: [
          // Header
          Padding(
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
                    context.showInfoSnackbar("Próximamente: Ver historial completo");
                  },
                ),
              ],
            ),
          ),
          // Lista de transacciones
          ListView.separated(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            separatorBuilder: (context, index) => SizedBox(height: AppTokens.space8),
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              final color = transaction.isIncome ? AppTokens.primaryRed : AppTokens.error;

              return InkWell(
                onTap: () {
                  if (_selectedPeriod == '2026-01') {
                    context.push(const TransactionDetailScreen());
                  } else {
                    context.showInfoSnackbar("Transacción #${transaction.id}");
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
                      // Icon
                      Container(
                        padding: EdgeInsets.all(AppTokens.space8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: AppTokens.borderRadiusSmall,
                        ),
                        child: Icon(
                          transaction.isIncome
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          size: 20,
                          color: color,
                        ),
                      ),
                      SizedBox(width: AppTokens.space12),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transaction.counterpartyName,
                              style: context.textStyles.bodyMedium?.copyWith(
                                fontWeight: AppTokens.fontWeightMedium,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: AppTokens.space4),
                            Text(
                              "${transaction.source.name.toUpperCase()} • ${Formatters.formatEnergy(transaction.energy)}",
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
                            Formatters.formatCurrency(transaction.amount),
                            style: context.textStyles.bodyMedium?.copyWith(
                              color: color,
                              fontWeight: AppTokens.fontWeightBold,
                            ),
                          ),
                          SizedBox(height: AppTokens.space4),
                          Text(
                            transaction.date,
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
          ),
        ],
      ),
    );
  }

  /// AppBar personalizado
  PreferredSizeWidget _buildAppBar() {
    final userName = widget.myUser?.nombre ?? "Usuario";

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
              decoration: const BoxDecoration(shape: BoxShape.circle),
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
                  const Text(
                    "¡Hola,",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "$userName!",
                    style: const TextStyle(
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
            color: _viewType == ViewType.admin ? AppTokens.primaryRed : AppTokens.primaryBlue,
            border: Border.all(width: 2.0, color: Colors.white),
            borderRadius: BorderRadius.circular(25.0),
          ),
          margin: const EdgeInsets.only(top: 7.5, bottom: 7.5, right: 10.0),
          child: IconButton(
            icon: Icon(
              _viewType == ViewType.admin ? Icons.admin_panel_settings : Icons.person,
              size: 22.0,
            ),
            color: Colors.white,
            tooltip: _viewType == ViewType.admin ? "Vista Administrador" : "Vista Usuario",
            onPressed: _toggleViewType,
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

  // ========== Helper methods ==========

  Color _getStatusColor(PeriodStatus status) {
    switch (status) {
      case PeriodStatus.current:
        return AppTokens.primaryRed;
      case PeriodStatus.historical:
        return AppTokens.energyGreen;
      case PeriodStatus.future:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(PeriodStatus status) {
    switch (status) {
      case PeriodStatus.current:
        return Icons.auto_awesome;
      case PeriodStatus.historical:
        return Icons.autorenew_rounded;
      case PeriodStatus.future:
        return Icons.lock_outline;
    }
  }

  String _getStatusText(PeriodStatus status) {
    switch (status) {
      case PeriodStatus.current:
        return 'NUEVO MODELO';
      case PeriodStatus.historical:
        return 'MES CERRADO';
      case PeriodStatus.future:
        return 'NO DISPONIBLE';
    }
  }
}

// Generation grid data (usado por el gráfico)
class GGData {
  late final String fuente;
  late final int consumo;

  GGData(this.fuente, this.consumo);
}
