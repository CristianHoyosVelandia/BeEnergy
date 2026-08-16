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

import '../admin/admin_community_offers_screen.dart';
import '../consumer/consumer_marketplace_screen.dart';
import '../consumer/pde_suggestion_selection_screen.dart';
// import 'components/home_activity_section.dart';
import 'components/home_activity_section.dart';
import 'components/home_app_bar.dart';
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

  String get _selectedPeriod {
    if (_controller.selectedPeriod.isNotEmpty) {
      return _controller.selectedPeriod;
    }
    return DataSourceConfig.isFake ? FakePeriodsData.currentPeriod : '';
  }

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
        forceRefresh: true,
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

  Future<void> _refreshHome() async {
    try {
      await _controller.initialize(
        user: widget.myUser,
        communityId: _currentCommunityId,
        fallbackPeriod: FakePeriodsData.currentPeriod,
        useFakeData: DataSourceConfig.isFake,
        forceRefresh: true,
      );
      await _reloadPriceReferences();
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error recargando Home',
        tag: 'HomeScreen',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        context.showInfoSnackbar('No se pudo actualizar la información.');
      }
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
    if (!DataSourceConfig.isFake && _selectedPeriod.isEmpty) {
      return 'Resumen energético';
    }
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

  double? _previousConsumption() {
    final summary = _controller.userPeriodHistory?.summary;
    if (!DataSourceConfig.isFake && summary != null) {
      return summary.lastConsumptionKwh;
    }

    final history = _controller.userPeriodHistory;
    if (!DataSourceConfig.isFake && history != null) {
      final currentIndex =
          history.periods.indexWhere((p) => p.period == _selectedPeriod);
      if (currentIndex >= 0 && currentIndex + 1 < history.periods.length) {
        return history.periods[currentIndex + 1].energyRecord.energyConsumed;
      }
    }
    return null;
  }

  double? _currentConsumption() {
    final summary = _controller.userPeriodHistory?.summary;
    if (!DataSourceConfig.isFake && summary != null) {
      return summary.currentConsumptionKwh;
    }

    final consumed = _selectedPeriodEnergyData['consumed'] ?? 0;
    if (consumed > 0) return consumed;
    return null;
  }

  double? _historicalAverageConsumption() {
    final summary = _controller.userPeriodHistory?.summary;
    if (!DataSourceConfig.isFake && summary != null) {
      return summary.userHistoricalAverageConsumptionKwh ??
          summary.communityAverageConsumptionKwh;
    }

    return null;
  }

  Widget _consumptionComparison() {
    final current = _currentConsumption();
    final previous = _previousConsumption();
    final historicalAverage = _historicalAverageConsumption();
    final values =
        [current, previous, historicalAverage].whereType<double>().toList();
    final hasData = values.isNotEmpty;
    final maxValue = hasData
        ? values.reduce((value, element) => value > element ? value : element)
        : 1.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
      padding: EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppTokens.borderRadiusLarge,
        border:
            Border.all(color: context.colors.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Datos energéticos',
            style: context.textStyles.titleMedium?.copyWith(
              fontWeight: AppTokens.fontWeightBold,
              color: AppTokens.grey900,
            ),
          ),
          if (!hasData) ...[
            SizedBox(height: AppTokens.space4),
            Text(
              'Sin datos de consumo para este periodo.',
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
          SizedBox(height: AppTokens.space16),
          if (current != null)
            _ConsumptionBar(
              label: 'Actual',
              value: current,
              maxValue: maxValue,
              color: AppTokens.primaryColor,
            ),
          if (current != null && previous != null)
            SizedBox(height: AppTokens.space12),
          if (previous != null)
            _ConsumptionBar(
              label: 'Mes anterior',
              value: previous,
              maxValue: maxValue,
              color: AppTokens.primaryColor.withValues(alpha: 0.72),
            ),
          if ((current != null || previous != null) &&
              historicalAverage != null)
            SizedBox(height: AppTokens.space12),
          if (historicalAverage != null)
            _ConsumptionBar(
              label: 'Promedio histórico',
              value: historicalAverage,
              maxValue: maxValue,
              color: AppTokens.primaryColor.withValues(alpha: 0.48),
            ),
        ],
      ),
    );
  }

  Widget _userPdeSummary() {
    if (_isAdminView) return const SizedBox.shrink();

    final summary = _controller.userPeriodHistory?.summary;
    final offer = _controller.buyerOffer;
    final assignedPercentage = offer?.pdePercentageAssigned;
    final summaryPdePercentage =
        !DataSourceConfig.isFake ? summary?.userPdePercentage : null;

    final effectivePdePercentage = summaryPdePercentage ??
        (assignedPercentage == null ? null : assignedPercentage * 100);
    final pdeValue = effectivePdePercentage == null ||
            effectivePdePercentage <= 0
        ? 'Sin asignación'
        : '${Formatters.formatNumber(effectivePdePercentage, decimals: 2)}%';
    final communityAverageGeneration =
        !DataSourceConfig.isFake ? summary?.energiaComunitariaPromedio : null;
    final equivalentKwh = effectivePdePercentage != null &&
            effectivePdePercentage > 0 &&
            communityAverageGeneration != null
        ? communityAverageGeneration * (effectivePdePercentage / 100)
        : null;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
      padding: EdgeInsets.all(AppTokens.space20),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppTokens.borderRadiusLarge,
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bolt_rounded,
                color: AppTokens.primaryColor,
                size: 64,
              ),
              SizedBox(width: AppTokens.space16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tu PDE actual',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: AppTokens.grey700,
                        fontWeight: AppTokens.fontWeightSemiBold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: AppTokens.space4),
                    Text(
                      pdeValue,
                      style: context.textStyles.displaySmall?.copyWith(
                        color: AppTokens.grey900,
                        fontWeight: AppTokens.fontWeightBold,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Equivale a:',
                    style: context.textStyles.bodySmall?.copyWith(
                      color: AppTokens.grey700,
                      fontWeight: AppTokens.fontWeightSemiBold,
                    ),
                  ),
                  SizedBox(height: AppTokens.space8),
                  Text(
                    equivalentKwh == null
                        ? '- kWh'
                        : Formatters.formatEnergy(equivalentKwh, decimals: 2),
                    style: context.textStyles.titleMedium?.copyWith(
                      color: AppTokens.grey900,
                      fontWeight: AppTokens.fontWeightBold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: AppTokens.space20),
          Text(
            'Nota: el valor de equivalencia corresponde a una comparación de energía histórica de la comunidad que puede variar.',
            style: context.textStyles.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    final periodLabel = _isAdminView
        ? (_currentPeriodData.status == PeriodStatus.current
            ? 'Actual'
            : 'Histórico')
        : '';
    final title = _isAdminView
        ? _currentCommunityName
        : _selectedPeriod.isEmpty
            ? 'Resumen energético'
            : 'Resumen energético';
    final totalMembers = _isAdminView
        ? (_selectedPeriod == '2026-01'
            ? FakeDataPhase2.allMembers.length
            : FakeData.communityStats.totalMembers)
        : 1;

    return HomeHeader(
      title: title,
      periodLabel: periodLabel,
      membersLabel: _isAdminView ? '$totalMembers miembros' : '',
    );
  }

  Widget _periodStatusIndicator() {
    if (DataSourceConfig.isFake) {
      final periodData = FakePeriodsData.getPeriodByKey(_selectedPeriod) ??
          FakePeriodsData.currentPeriodData;
      return _StatusIndicator(
        statusColor: periodData.getStatusColor(),
        statusIcon: periodData.getStatusIcon(),
        statusText: periodData.status == PeriodStatus.current
            ? 'Periodo actual'
            : 'Periodo histórico',
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
        statusText: _controller.isLoadingPeriods ? 'Cargando' : 'Sin datos',
        periodLabel: _controller.isLoadingPeriods
            ? 'Consultando backend'
            : 'Sin periodo disponible',
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
        statusText:
            periodItem.isCurrentPeriod ? 'Periodo actual' : 'Periodo histórico',
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
      statusText: isCurrent ? 'Periodo actual' : 'Periodo cerrado',
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
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Seleccionar período',
                    style: this.context.textStyles.titleLarge?.copyWith(
                          fontWeight: AppTokens.fontWeightBold,
                        ),
                  ),
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
          subtitle: 'Periodo actual',
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

  Widget _energyDataLoading() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
      padding: EdgeInsets.all(AppTokens.space20),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppTokens.borderRadiusLarge,
        border:
            Border.all(color: context.colors.outline.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppTokens.primaryColor,
            ),
          ),
          SizedBox(width: AppTokens.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cargando datos energéticos',
                  style: context.textStyles.titleMedium?.copyWith(
                    color: AppTokens.grey900,
                    fontWeight: AppTokens.fontWeightBold,
                  ),
                ),
                SizedBox(height: AppTokens.space4),
                Text(
                  'Consultando consumo y PDE del periodo.',
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: AppTokens.borderRadiusLarge),
        title: Text(
          'Cerrar sesión',
          style: context.textStyles.titleLarge?.copyWith(
            fontWeight: AppTokens.fontWeightBold,
          ),
        ),
        content: const Text('¿Quieres cerrar tu sesión actual?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              DatabaseHelper().deleteUserLocal(widget.myUser?.idUser);
              AppTokens.resetToDefaultColors();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const Beenergy()),
                (Route<dynamic> route) => false,
              );
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    final isLoadingEnergyData = _controller.isLoadingEnergyData;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding:
          EdgeInsets.only(top: AppTokens.space16, bottom: AppTokens.space24),
      children: [
        if (isLoadingEnergyData) ...[
          _energyDataLoading(),
          SizedBox(height: AppTokens.space64),
        ] else ...[
          _header(),
          SizedBox(height: AppTokens.space16),
          _periodStatusIndicator(),
          SizedBox(height: AppTokens.space16),
          _userPdeSummary(),
          if (!_isAdminView) SizedBox(height: AppTokens.space16),
          _pdeCard(),
          SizedBox(height: AppTokens.space16),
          _consumptionComparison(),
          SizedBox(height: AppTokens.space24),
          if (_isAdminView && _isCurrentPeriod) ...[
            _priceCardsAdmin(),
            SizedBox(height: AppTokens.space24),
          ],
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
        onLogoutTap: _showLogoutDialog,
      ),
      backgroundColor: context.colors.surface,
      body: RefreshIndicator(
        color: context.colors.primary,
        onRefresh: _refreshHome,
        child: _body(),
      ),
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
          vertical: 14,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textStyles.bodyLarge?.copyWith(
                      fontWeight: AppTokens.fontWeightSemiBold,
                      color: enabled
                          ? context.colors.onSurface
                          : context.colors.onSurfaceVariant,
                    ),
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
              isSelected ? Icons.check_circle : Icons.circle_outlined,
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

class _ConsumptionBar extends StatelessWidget {
  final String label;
  final double value;
  final double maxValue;
  final Color color;

  const _ConsumptionBar({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final safeMax = maxValue <= 0 ? 1 : maxValue;
    final factor = (value / safeMax).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: context.textStyles.bodyMedium?.copyWith(
                fontWeight: AppTokens.fontWeightSemiBold,
                color: AppTokens.grey800,
              ),
            ),
            Text(
              Formatters.formatEnergy(value, decimals: 0),
              style: context.textStyles.bodyMedium?.copyWith(
                fontWeight: AppTokens.fontWeightBold,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: AppTokens.space8),
        ClipRRect(
          borderRadius: AppTokens.borderRadiusCircular,
          child: LinearProgressIndicator(
            value: factor,
            minHeight: 10,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
