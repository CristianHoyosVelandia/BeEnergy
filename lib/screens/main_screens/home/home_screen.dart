import 'package:be_energy/core/config/data_source_config.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/utils/formatters.dart';
import 'package:be_energy/core/utils/logger.dart';
import 'package:be_energy/data/fake_data.dart';
import 'package:be_energy/data/fake_data_january_2026.dart';
import 'package:be_energy/data/fake_data_phase2.dart';
import 'package:be_energy/data/fake_periods_data.dart';
import 'package:be_energy/models/models.dart';
import 'package:be_energy/routes.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../admin/admin_community_offers_screen.dart';
import '../consumer/consumer_marketplace_screen.dart';
import '../consumer/pde_suggestion_selection_screen.dart';
// import 'components/home_activity_section.dart';
import 'components/home_activity_section.dart';
import 'components/home_app_bar.dart';
import 'components/home_energy_card.dart';
import 'components/home_header.dart';
import 'components/pde_state_machine/pde_state_machine_card.dart';
import 'controllers/home_controller.dart';
import 'pde_cobro_screen.dart';
import 'pde_renuncia_screen.dart';
import 'widgets/price_reference_cards.dart';

class HomeScreen extends StatefulWidget {
  final MyUser? myUser;

  const HomeScreen({super.key, this.myUser});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const bool _showActivities = false;

  final HomeController _controller = HomeController();

  int get _currentCommunityId => widget.myUser?.communityId ?? 1;

  String get _currentCommunityName {
    final name = widget.myUser?.communityName;
    return name == null || name.trim().isEmpty ? 'Comunidad' : name.trim();
  }

  String get _selectedPeriod => _controller.selectedPeriod.isEmpty
      ? FakePeriodsData.currentPeriod
      : _controller.selectedPeriod;

  bool get _isAdminView => _controller.isAdminView;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_refresh);
    _initializeData();
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _controller.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _initializeData() async {
    try {
      await _controller.initialize(
        user: widget.myUser,
        communityId: _currentCommunityId,
        fallbackPeriod: FakePeriodsData.currentPeriod,
        useFakeData: DataSourceConfig.isFake,
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error inicializando Home',
        tag: 'HomeScreen',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _reloadPriceReferences() async {
    if (DataSourceConfig.isFake || !_isAdminView || !_isCurrentPeriod) {
      return;
    }

    await _controller.loadPriceReferences(
      communityId: _currentCommunityId,
      period: _selectedPeriod,
    );
  }

  MonthPeriod get _currentPeriodData {
    return FakePeriodsData.getPeriodByKey(_selectedPeriod) ??
        FakePeriodsData.currentPeriodData;
  }

  String get _selectedPeriodDisplayName {
    final history = _controller.userPeriodHistory;
    if (!DataSourceConfig.isFake && history != null) {
      final periodItem = history.periods.firstWhere(
        (p) => p.period == _selectedPeriod,
        orElse: () => UserPeriodItem(
          period: _selectedPeriod,
          displayName: Formatters.formatPeriodToDisplayName(_selectedPeriod),
          status: 'current',
          hasData: false,
          pdeStatusCode: 0,
          pdeAvailable: false,
          energyRecord: EnergyRecordSummary(
            energyGenerated: 0,
            energyConsumed: 0,
            energyExported: 0,
            energyImported: 0,
          ),
        ),
      );
      return periodItem.displayName;
    }

    return _currentPeriodData.displayName;
  }

  bool get _isCurrentPeriod => _isCurrentPeriodFor(_selectedPeriod);

  bool _isCurrentPeriodFor(String period) {
    final history = _controller.userPeriodHistory;
    if (!DataSourceConfig.isFake && history != null) {
      return period == history.currentPeriod;
    }

    final periodData = FakePeriodsData.getPeriodByKey(period);
    return periodData?.status == PeriodStatus.current;
  }

  Map<String, double> get _selectedPeriodEnergyData {
    final history = _controller.userPeriodHistory;
    if (!DataSourceConfig.isFake && history != null) {
      final periodData = history.periods.firstWhere(
        (p) => p.period == _selectedPeriod,
        orElse: () => UserPeriodItem(
          period: _selectedPeriod,
          displayName: '',
          status: 'current',
          hasData: false,
          pdeStatusCode: 0,
          pdeAvailable: false,
          energyRecord: EnergyRecordSummary(
            energyGenerated: 0,
            energyConsumed: 0,
            energyExported: 0,
            energyImported: 0,
          ),
        ),
      );

      return {
        'generated': periodData.energyRecord.energyGenerated,
        'consumed': periodData.energyRecord.energyConsumed,
        'exported': periodData.energyRecord.energyExported,
        'imported': periodData.energyRecord.energyImported,
      };
    }

    return {
      'generated': 0,
      'consumed': 0,
      'exported': 0,
      'imported': 0,
    };
  }

  List<GGData> _getChartData() {
    if (!DataSourceConfig.isFake && _controller.userPeriodHistory != null) {
      final energyData = _selectedPeriodEnergyData;
      final chartData = <GGData>[];

      if (energyData['generated']! > 0) {
        chartData.add(GGData('Generada', energyData['generated']!.toInt()));
      }
      if (energyData['consumed']! > 0) {
        chartData.add(GGData('Consumida', energyData['consumed']!.toInt()));
      }
      if (energyData['exported']! > 0) {
        chartData.add(GGData('Exportada', energyData['exported']!.toInt()));
      }
      if (energyData['imported']! > 0) {
        chartData.add(GGData('Importada', energyData['imported']!.toInt()));
      }

      return chartData.isEmpty ? [GGData('Sin datos', 1)] : chartData;
    }

    late dynamic stats;
    late int p2pEnergy;
    double? gridImportOverride;

    switch (_selectedPeriod) {
      case '2026-01':
        stats = _isAdminView
            ? FakeDataPhase2.communityStats
            : FakeDataPhase2.cristianIndividualStatsDec2025;
        p2pEnergy = FakeDataPhase2.allContracts
            .fold<double>(0, (sum, c) => sum + c.energyCommitted)
            .toInt();
        gridImportOverride = _isAdminView ? 120 : 0;
        break;
      case '2025-12':
        stats = _isAdminView
            ? FakeData.communityStats
            : FakeData.cristianIndividualStatsNov2025;
        p2pEnergy = _isAdminView ? 650 : 30;
        break;
      default:
        stats = _isAdminView
            ? FakeData.communityStats
            : FakeData.cristianIndividualStatsNov2025;
        p2pEnergy = _isAdminView ? 650 : 30;
    }

    return [
      GGData('Directa Solar', stats.totalEnergyGenerated.toInt()),
      GGData('Red', (gridImportOverride ?? stats.totalEnergyImported).toInt()),
      GGData('Intercambios P2P', p2pEnergy),
    ];
  }

  Widget _energyChart() {
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
          dataSource: _getChartData(),
          xValueMapper: (data, _) => data.source,
          yValueMapper: (data, _) => data.value,
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            labelPosition: ChartDataLabelPosition.outside,
            connectorLineSettings: const ConnectorLineSettings(
              type: ConnectorType.curve,
              length: '10%',
            ),
            textStyle: TextStyle(
              color: context.colors.onSurface,
              fontSize: AppTokens.fontSize10,
              fontWeight: AppTokens.fontWeightMedium,
            ),
          ),
        ),
      ],
    );
  }

  Widget _energyCards() {
    if (!DataSourceConfig.isFake) {
      final energyData = _selectedPeriodEnergyData;
      return Column(
        children: [
          HomeEnergyCard(
            title: 'Generada',
            energy: energyData['generated']!,
            amount: 0,
            icon: Icons.wb_sunny_rounded,
            color: AppTokens.primaryColor,
            hideAmount: true,
          ),
          SizedBox(height: AppTokens.space8),
          HomeEnergyCard(
            title: 'Consumida',
            energy: energyData['consumed']!,
            amount: 0,
            icon: Icons.electric_bolt_rounded,
            color: AppTokens.primaryColor,
            hideAmount: true,
          ),
          SizedBox(height: AppTokens.space8),
          HomeEnergyCard(
            title: 'Exportada',
            energy: energyData['exported']!,
            amount: 0,
            icon: Icons.trending_up_rounded,
            color: AppTokens.primaryColor,
            hideAmount: true,
          ),
          SizedBox(height: AppTokens.space8),
          HomeEnergyCard(
            title: 'Importada',
            energy: energyData['imported']!,
            amount: 0,
            icon: Icons.trending_down_rounded,
            color: AppTokens.primaryColor,
            hideAmount: true,
          ),
        ],
      );
    }

    late CommunityStats stats;
    late double costPerKwh;

    switch (_selectedPeriod) {
      case '2026-01':
        stats = _isAdminView
            ? FakeDataPhase2.communityStats
            : FakeDataPhase2.cristianIndividualStatsDec2025;
        costPerKwh = FakeDataPhase2.mc;
        break;
      default:
        stats = _isAdminView
            ? FakeData.communityStats
            : FakeData.cristianIndividualStatsNov2025;
        costPerKwh = FakeData.regulatedCosts.totalCostPerKwh;
    }

    final isJan2026 = _selectedPeriod == '2026-01';
    final firstTitle = isJan2026
        ? (_isAdminView ? 'Importada de red' : 'Autoconsumo solar')
        : 'Importe';
    final firstEnergy =
        isJan2026 ? (_isAdminView ? 120.0 : 107.7) : stats.totalEnergyImported;
    final firstIcon = isJan2026 && !_isAdminView
        ? Icons.light_mode_rounded
        : Icons.trending_down_rounded;
    final firstColor =
        isJan2026 && !_isAdminView ? AppTokens.energyGreen : AppTokens.error;

    return Column(
      children: [
        HomeEnergyCard(
          title: firstTitle,
          energy: firstEnergy,
          amount: firstEnergy * costPerKwh,
          icon: firstIcon,
          color: firstColor,
        ),
        SizedBox(height: AppTokens.space8),
        HomeEnergyCard(
          title: 'Exportada',
          energy: stats.totalEnergyExported,
          amount: stats.totalEnergyExported * costPerKwh,
          icon: Icons.trending_up_rounded,
          color: AppTokens.primaryColor,
        ),
        if (isJan2026) ...[
          SizedBox(height: AppTokens.space8),
          HomeEnergyCard(
            title: 'Excedentes totales',
            energy: FakeDataPhase2.pdeDec2025.excessEnergy,
            amount: 0,
            icon: Icons.bolt_rounded,
            color: AppTokens.primaryPurple,
            subtitle: 'Disponibles para la comunidad',
            hideAmount: true,
          ),
        ],
      ],
    );
  }

  Widget _energySummary() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
      padding: EdgeInsets.all(AppTokens.space12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppTokens.borderRadiusLarge,
        border:
            Border.all(color: context.colors.outline.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: _energyChart()),
          SizedBox(width: AppTokens.space12),
          Expanded(flex: 3, child: _energyCards()),
        ],
      ),
    );
  }

  Widget _header() {
    final periodLabel = _currentPeriodData.status == PeriodStatus.current
        ? 'Actual'
        : 'Histórico';
    final title = _isAdminView ? _currentCommunityName : 'Mi Energía';
    final totalMembers = _isAdminView
        ? (_selectedPeriod == '2026-01'
            ? FakeDataPhase2.allMembers.length
            : FakeData.communityStats.totalMembers)
        : 1;

    return HomeHeader(
      title: title,
      periodLabel: periodLabel,
      membersLabel:
          _isAdminView ? '$totalMembers miembros' : 'Vista Individual',
    );
  }

  Widget _periodStatusIndicator() {
    if (DataSourceConfig.isFake) {
      final periodData = FakePeriodsData.getPeriodByKey(_selectedPeriod) ??
          FakePeriodsData.currentPeriodData;
      return _StatusIndicator(
        statusColor: periodData.getStatusColor(),
        statusIcon: periodData.getStatusIcon(),
        statusText: periodData.getStatusText(),
        periodLabel: periodData.displayName,
        isCurrentMonth: periodData.status == PeriodStatus.current,
        onTap: _showPeriodSelectorModal,
      );
    }

    final history = _controller.userPeriodHistory;
    if (history == null) {
      return _StatusIndicator(
        statusColor: context.colors.onSurfaceVariant,
        statusIcon: Icons.calendar_month_outlined,
        statusText: 'SIN DATOS',
        periodLabel: Formatters.formatCurrentPeriodDisplayName(),
        isCurrentMonth: false,
        onTap: _showPeriodSelectorModal,
      );
    }

    final periodIndex =
        history.periods.indexWhere((p) => p.period == _selectedPeriod);
    if (periodIndex != -1) {
      final periodItem = history.periods[periodIndex];
      return _StatusIndicator(
        statusColor: periodItem.getStatusColor(),
        statusIcon: periodItem.getStatusIcon(),
        statusText: periodItem.getStatusText(),
        periodLabel: periodItem.displayName,
        isCurrentMonth: periodItem.isCurrentPeriod,
        onTap: _showPeriodSelectorModal,
      );
    }

    final isCurrent = _selectedPeriod == history.currentPeriod;
    return _StatusIndicator(
      statusColor:
          isCurrent ? AppTokens.primaryColor : context.colors.onSurfaceVariant,
      statusIcon:
          isCurrent ? Icons.auto_awesome : Icons.calendar_month_outlined,
      statusText: isCurrent ? 'NUEVO MODELO' : 'MES CERRADO',
      periodLabel: Formatters.formatPeriodToDisplayName(_selectedPeriod),
      isCurrentMonth: isCurrent,
      onTap: _showPeriodSelectorModal,
    );
  }

  void _showPeriodSelectorModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.45),
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
              Container(
                margin: EdgeInsets.only(top: AppTokens.space12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: this
                      .context
                      .colors
                      .onSurfaceVariant
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: AppTokens.space16),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppTokens.space20),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_rounded,
                        color: this.context.colors.primary),
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
              Expanded(
                child: _controller.isLoadingPeriods
                    ? const Center(child: CircularProgressIndicator())
                    : _periodsList(),
              ),
              SizedBox(height: AppTokens.space20),
            ],
          ),
        );
      },
    );
  }

  Widget _periodsList() {
    if (DataSourceConfig.isFake) {
      return SingleChildScrollView(
        child: Column(
          children: FakePeriodsData.availablePeriods.map((period) {
            final metadata = FakePeriodsData.getPeriodMetadata(period.period);
            return _PeriodOption(
              period: period.period,
              selectedPeriod: _selectedPeriod,
              title: period.displayName,
              subtitle:
                  metadata?['description'] ?? 'Datos de comunidad energética',
              icon: period.getStatusIcon(),
              iconColor: period.getStatusColor(),
              badge: _fakePeriodBadge(period),
              enabled: period.hasData,
              onTap: _selectPeriod,
            );
          }).toList(),
        ),
      );
    }

    final history = _controller.userPeriodHistory;
    final options = <Widget>[];

    if (history != null) {
      final hasCurrentData =
          history.periods.any((p) => p.period == history.currentPeriod);
      if (!hasCurrentData) {
        options.add(_PeriodOption(
          period: history.currentPeriod,
          selectedPeriod: _selectedPeriod,
          title: Formatters.formatPeriodToDisplayName(history.currentPeriod),
          subtitle: _controller.pdePeriodStatus?.canCreateOffers == true
              ? 'PDE Disponible - Puedes crear ofertas'
              : 'Sin datos disponibles',
          icon: Icons.auto_awesome,
          iconColor: AppTokens.primaryColor,
          badge: '✨',
          onTap: _selectPeriod,
        ));
      }

      for (final period in history.periods) {
        options.add(_PeriodOption(
          period: period.period,
          selectedPeriod: _selectedPeriod,
          title: period.displayName,
          subtitle:
              'Consumo: ${Formatters.formatEnergy(period.energyRecord.energyConsumed)} • Generación: ${Formatters.formatEnergy(period.energyRecord.energyGenerated)}',
          icon: period.getStatusIcon(),
          iconColor: period.getStatusColor(),
          badge: period.getStatusBadge(),
          enabled: period.hasData,
          onTap: _selectPeriod,
        ));
      }
    }

    if (options.isEmpty) {
      return Center(
        child: Text(
          'Sin períodos disponibles',
          style: context.textStyles.bodyLarge?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      );
    }

    return SingleChildScrollView(child: Column(children: options));
  }

  String _fakePeriodBadge(MonthPeriod period) {
    switch (period.status) {
      case PeriodStatus.current:
        return '✨';
      case PeriodStatus.historical:
        return period.hasData ? '🔄' : '📊';
      case PeriodStatus.future:
        return '🔒';
    }
  }

  Future<void> _selectPeriod(String period, String title) async {
    Navigator.pop(context);
    try {
      await _controller.changePeriod(
        period: period,
        user: widget.myUser,
        communityId: _currentCommunityId,
        shouldLoadPriceReferences: _isAdminView && _isCurrentPeriodFor(period),
      );
      if (mounted) {
        context.showInfoSnackbar('Período cambiado a $title');
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error cambiando período',
        tag: 'HomeScreen',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Widget _pdeCard() {
    return PdeStateMachineCard(
      isLoadingStatus: _controller.isLoadingPDEStatus,
      isLoadingOffer: _controller.isLoadingBuyerOffer,
      isAdminView: _isAdminView,
      periodDisplayName: _selectedPeriodDisplayName,
      status: _controller.pdePeriodStatus,
      buyerOffer: _controller.buyerOffer,
      onAvailableTap: _handleAvailablePdeTap,
      onAdminClosedTap: _navigateToAdminOffers,
      onMoveToReconciliationTap: _showConfirmReconciliationModal,
      onVoluntaryWaiverTap: _navigateToPdeRenuncia,
      onPaymentTap: _navigateToPdeCobro,
    );
  }

  Future<void> _navigateToPdeCobro() async {
    if (widget.myUser == null) {
      context.showInfoSnackbar('No se pudo identificar el usuario actual.');
      return;
    }

    final shouldOpenContribution = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PdeCobroScreen(
          myUser: widget.myUser!,
          communityId: _currentCommunityId,
          period: _selectedPeriod,
          periodDisplayName: _selectedPeriodDisplayName,
          isAdminView: _isAdminView,
        ),
      ),
    );

    if (shouldOpenContribution == true) {
      await _controller.updatePeriodStatus(
        communityId: _currentCommunityId,
        newStatusCode: 6,
      );
    }
  }

  Future<void> _navigateToPdeRenuncia() async {
    if (widget.myUser == null) {
      context.showInfoSnackbar('No se pudo identificar el usuario actual.');
      return;
    }

    final shouldReload = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PdeRenunciaScreen(
          myUser: widget.myUser!,
          communityId: _currentCommunityId,
          period: _selectedPeriod,
          periodDisplayName: _selectedPeriodDisplayName,
          isAdminView: _isAdminView,
        ),
      ),
    );

    if (shouldReload == true) {
      await _controller.loadPDEPeriodStatus(
        user: widget.myUser,
        communityId: _currentCommunityId,
      );
    }
  }

  void _handleAvailablePdeTap() {
    if (_isAdminView) {
      _navigateToAdminOffers();
      return;
    }

    if (widget.myUser == null) {
      context.showInfoSnackbar('No se pudo identificar el usuario actual.');
      return;
    }

    if (_controller.buyerOffer?.status == ConsumerOfferStatus.pending) {
      _navigateToConsumerMarketplace();
    } else {
      _navigateToPdeSuggestions();
    }
  }

  void _navigateToAdminOffers() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminCommunityOffersScreen(
          period: _selectedPeriod,
          communityId: _currentCommunityId,
          communityName: _currentCommunityName,
        ),
      ),
    );
  }

  void _navigateToConsumerMarketplace() {
    if (widget.myUser == null) {
      context.showInfoSnackbar('No se pudo identificar el usuario actual.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConsumerMarketplaceScreen(
          period: _selectedPeriod,
          myUser: widget.myUser!,
          communityId: _currentCommunityId,
        ),
      ),
    );
  }

  void _navigateToPdeSuggestions() {
    if (widget.myUser == null) {
      context.showInfoSnackbar('No se pudo identificar el usuario actual.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdeSuggestionSelectionScreen(
          period: _selectedPeriod,
          myUser: widget.myUser!,
          communityId: _currentCommunityId,
          energyConsumed: _selectedPeriodEnergyData['consumed'] ?? 0,
          totalPDEAvailable: FakeDataJanuary2026.pdeJan2026.allocatedEnergy,
        ),
      ),
    );
  }

  void _showConfirmReconciliationModal() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: AppTokens.borderRadiusLarge),
          title: Text(
            'Confirmar Cambio de Estado',
            style: context.textStyles.titleLarge?.copyWith(
              fontWeight: AppTokens.fontWeightBold,
            ),
          ),
          content: Text(
            '¿Desea pasar el periodo $_selectedPeriodDisplayName a estado "En Conciliación"?',
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _updatePeriodStatus(4);
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updatePeriodStatus(int newStatusCode) async {
    try {
      context.showInfoSnackbar('Actualizando estado del periodo...');
      final status = await _controller.updatePeriodStatus(
        communityId: _currentCommunityId,
        newStatusCode: newStatusCode,
      );
      if (mounted) {
        context.showInfoSnackbar('Estado actualizado a: ${status.statusName}');
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error actualizando estado del periodo',
        tag: 'HomeScreen',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        context.showInfoSnackbar('Error al actualizar estado: $e');
      }
    }
  }

  Widget _priceCardsAdmin() {
    return PriceReferenceCards(
      prices: _controller.priceReferences,
      isLoading: _controller.isLoadingPriceReferences,
      error: _controller.priceReferencesError,
      onRetry: _reloadPriceReferences,
    );
  }

  Widget _body() {
    return ListView(
      padding:
          EdgeInsets.only(top: AppTokens.space16, bottom: AppTokens.space24),
      children: [
        _header(),
        SizedBox(height: AppTokens.space16),
        _periodStatusIndicator(),
        SizedBox(height: AppTokens.space16),
        _pdeCard(),
        SizedBox(height: AppTokens.space16),
        _energySummary(),
        SizedBox(height: AppTokens.space24),
        if (_isAdminView && _isCurrentPeriod) ...[
          _priceCardsAdmin(),
          SizedBox(height: AppTokens.space24),
        ],
        if (_showActivities)
          HomeActivitySection(
            isAdminView: _isAdminView,
            onCommunityManagementTap: () =>
                context.push(CommunityManagementScreen(
              communityId: _currentCommunityId,
              communityName: _currentCommunityName,
            )),
            onTransferTap: () => context.push(const TradingScreen()),
            onBolsaTap: () => context.push(const BolsaScreen()),
            onLearnTap: () {
              if (widget.myUser == null) {
                context.showInfoSnackbar(
                    'No se pudo identificar el usuario actual.');
                return;
              }
              context.push(AprendeScreen(myUser: widget.myUser!));
            },
          ),
        SizedBox(height: AppTokens.space64),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(
        userName: widget.myUser?.nombre ?? 'Cristian',
        canToggleAdminView: widget.myUser?.role != null &&
            (widget.myUser!.role == 3 || widget.myUser!.role == 4),
        isAdminView: _isAdminView,
        onToggleAdminView: () async {
          _controller.toggleAdminView();
          await _reloadPriceReferences();
          if (!mounted) {
            return;
          }

          this.context.showInfoSnackbar(
                _isAdminView
                    ? 'Vista: $_currentCommunityName'
                    : 'Vista: Usuario',
              );
        },
        onNotificationsTap: () => context.push(const NotificacionesScreen()),
      ),
      backgroundColor: context.colors.surface,
      body: _body(),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final Color statusColor;
  final IconData statusIcon;
  final String statusText;
  final String periodLabel;
  final bool isCurrentMonth;
  final VoidCallback onTap;

  const _StatusIndicator({
    required this.statusColor,
    required this.statusIcon,
    required this.statusText,
    required this.periodLabel,
    required this.isCurrentMonth,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppTokens.borderRadiusMedium,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
        padding: EdgeInsets.all(AppTokens.space12),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          borderRadius: AppTokens.borderRadiusMedium,
          border:
              Border.all(color: statusColor.withValues(alpha: 0.5), width: 2),
        ),
        child: Row(
          children: [
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
                    periodLabel,
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
              child:
                  Icon(Icons.swap_horiz_rounded, color: statusColor, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodOption extends StatelessWidget {
  final String period;
  final String selectedPeriod;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final String badge;
  final bool enabled;
  final Future<void> Function(String period, String title) onTap;

  const _PeriodOption({
    required this.period,
    required this.selectedPeriod,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.badge,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedPeriod == period;

    return InkWell(
      onTap: enabled ? () => onTap(period, title) : null,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppTokens.space20,
          vertical: AppTokens.space16,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppTokens.space12),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: AppTokens.borderRadiusSmall,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            SizedBox(width: AppTokens.space16),
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
                      Text(badge,
                          style: TextStyle(fontSize: AppTokens.fontSize16)),
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
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected
                  ? iconColor
                  : context.colors.onSurfaceVariant.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}

class GGData {
  final String source;
  final int value;

  GGData(this.source, this.value);
}
