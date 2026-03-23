import 'package:flutter/material.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import '../../../data/fake_data_january_2026.dart';
import '../../../services/liquidation_service.dart';
import '../../../services/consumer_offer_service.dart';
import '../../../services/p2p_service.dart';
import '../../../models/liquidation_session.dart';
import '../../../models/consumer_offer.dart';
import '../../../widgets/pde_indicator.dart';

/// Panel de Liquidación P2P - ADMINISTRADOR
/// Permite al admin gestionar el proceso de liquidación manual:
/// 1. Ver ofertas de consumidores
/// 2. Ver energía disponible de prosumidores
/// 3. Hacer matching manual
/// 4. Finalizar liquidación y generar contratos
///
/// ENERO 2026+ - Nuevo modelo de mercado
class AdminLiquidationPanel extends StatefulWidget {
  final String period;

  const AdminLiquidationPanel({
    super.key,
    this.period = '2026-01',
  });

  @override
  State<AdminLiquidationPanel> createState() => _AdminLiquidationPanelState();
}

class _AdminLiquidationPanelState extends State<AdminLiquidationPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late LiquidationService _liquidationService;

  LiquidationSession? _currentSession;
  bool _isLoading = false;
  String? _errorMessage;

  // Para el matching manual
  int? _selectedOfferIndex;
  int? _selectedProsumerIndex;
  double _energyToAssign = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Inicializar servicios
    final consumerOfferService = ConsumerOfferService();
    final p2pService = P2PService();
    _liquidationService = LiquidationService(
      consumerOfferService: consumerOfferService,
      p2pService: p2pService,
    );

    // Cargar datos fake
    _initializeFakeData();

    // Crear o cargar sesión activa
    _loadOrCreateSession();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeFakeData() {
    // Inicializar con ofertas fake de Enero 2026
    final consumerOfferService = ConsumerOfferService();
    consumerOfferService.initializeWithFakeData([
      FakeDataJanuary2026.anaOfferJan2026,
    ]);
  }

  Future<void> _loadOrCreateSession() async {
    setState(() => _isLoading = true);

    try {
      // Buscar sesión activa o crear nueva
      var session = _liquidationService.getActiveSession(widget.period) ??
          await _liquidationService.createSession(
            period: widget.period,
            communityId: 1,
            adminUserId: 1, // Admin UAO
            mode: LiquidationMode.manual,
          );

      setState(() {
        _currentSession = session;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _createMatch() async {
    if (_selectedOfferIndex == null || _selectedProsumerIndex == null) {
      _showSnackBar('Selecciona una oferta y un prosumidor', isError: true);
      return;
    }

    if (_energyToAssign <= 0) {
      _showSnackBar('La energía debe ser mayor a 0 kWh', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Obtener datos
      final offers = _getPendingOffers();
      final offer = offers[_selectedOfferIndex!];

      // Prosumidores (mock)
      final prosumers = _getAvailableProsumers();
      final prosumer = prosumers[_selectedProsumerIndex!];

      // Crear match
      await _liquidationService.createManualMatch(
        sessionId: _currentSession!.id,
        consumerOfferId: offer.id,
        prosumerId: prosumer['id'] as int,
        prosumerName: prosumer['name'] as String,
        energyKwh: _energyToAssign,
      );

      // Recargar sesión
      final updatedSession = _liquidationService.getSessionById(_currentSession!.id);
      setState(() {
        _currentSession = updatedSession;
        _selectedOfferIndex = null;
        _selectedProsumerIndex = null;
        _energyToAssign = 0.0;
        _isLoading = false;
      });

      _showSnackBar('Match creado exitosamente');

      // Ir al tab de resumen
      _tabController.animateTo(3);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      _showSnackBar(e.toString(), isError: true);
    }
  }

  Future<void> _finalizeLiquidation() async {
    if (_currentSession == null || _currentSession!.matches.isEmpty) {
      _showSnackBar('No hay matches para finalizar', isError: true);
      return;
    }

    // Confirmar con el usuario
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalizar Liquidación'),
        content: Text(
          '¿Confirmas que deseas finalizar la liquidación?\n\n'
          '• ${_currentSession!.matches.length} match(es) creado(s)\n'
          '• Se generarán ${_currentSession!.matches.length} contrato(s) P2P\n'
          '• Este proceso no se puede revertir',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      // Finalizar liquidación
      final contracts = await _liquidationService.finalizeLiquidation(_currentSession!.id);

      setState(() {
        _currentSession = _liquidationService.getSessionById(_currentSession!.id);
        _isLoading = false;
      });

      // Mostrar resultado
      _showSuccessDialog(contracts.length);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      _showSnackBar(e.toString(), isError: true);
    }
  }

  void _showSuccessDialog(int contractsCreated) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: AppTokens.space12),
            const Text('Liquidación Completada'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'La liquidación se ha completado exitosamente.',
            ),
            SizedBox(height: AppTokens.space16),
            Text('• $contractsCreated contrato(s) P2P generado(s)'),
            Text('• ${_currentSession!.totalMatchesCreated} match(es) procesado(s)'),
            Text('• Eficiencia: ${(_currentSession!.matchingEfficiency * 100).toStringAsFixed(1)}%'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Volver a pantalla anterior
            },
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTokens.primaryRed : Colors.green,
      ),
    );
  }

  List<ConsumerOffer> _getPendingOffers() {
    final consumerOfferService = ConsumerOfferService();
    consumerOfferService.initializeWithFakeData([
      FakeDataJanuary2026.anaOfferJan2026,
    ]);
    return consumerOfferService.getPendingOffers(widget.period);
  }

  List<Map<String, dynamic>> _getAvailableProsumers() {
    // Mock de prosumidores disponibles
    final mariaType2 = FakeDataJanuary2026.mariaJan2026.surplusType2;
    final mariaPDE = FakeDataJanuary2026.pdeJan2026.allocatedEnergy;
    final mariaP2PAvailable = mariaType2 - mariaPDE;

    return [
      {
        'id': 24,
        'name': 'María García',
        'type2': mariaType2,
        'pdeCeded': mariaPDE,
        'p2pAvailable': mariaP2PAvailable,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _currentSession == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentSession == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Panel de Liquidación'),
          backgroundColor: AppTokens.primaryPurple,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              SizedBox(height: AppTokens.space16),
              Text(
                _errorMessage ?? 'Error al cargar sesión',
                style: context.textStyles.bodyLarge,
              ),
              SizedBox(height: AppTokens.space16),
              ElevatedButton(
                onPressed: _loadOrCreateSession,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Liquidación ${widget.period}'),
        backgroundColor: AppTokens.primaryPurple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Ofertas'),
            Tab(icon: Icon(Icons.bolt), text: 'Energía'),
            Tab(icon: Icon(Icons.link), text: 'Matching'),
            Tab(icon: Icon(Icons.summarize), text: 'Resumen'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOffersTab(),
                _buildEnergyTab(),
                _buildMatchingTab(),
                _buildSummaryTab(),
              ],
            ),
    );
  }

  Widget _buildOffersTab() {
    final offers = _getPendingOffers();

    return ListView(
      padding: EdgeInsets.all(AppTokens.space16),
      children: [
        // PDE Disponible
        PDEAvailabilitySummary(
          totalPDEAvailable: _currentSession!.totalPDEAvailable,
          period: widget.period,
          showHelp: true,
        ),
        SizedBox(height: AppTokens.space16),

        // Título
        Text(
          'Ofertas de Consumidores',
          style: context.textStyles.titleLarge?.copyWith(
            fontWeight: AppTokens.fontWeightBold,
          ),
        ),
        SizedBox(height: AppTokens.space8),

        // Lista de ofertas
        if (offers.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.all(AppTokens.space32),
              child: Text(
                'No hay ofertas pendientes',
                style: context.textStyles.bodyLarge?.copyWith(color: Colors.grey),
              ),
            ),
          )
        else
          ...offers.map((offer) => _buildOfferCard(offer)),
      ],
    );
  }

  Widget _buildOfferCard(ConsumerOffer offer) {
    final energyKwh = offer.calculateEnergyKwh(_currentSession!.totalPDEAvailable);

    return Card(
      margin: EdgeInsets.only(bottom: AppTokens.space12),
      child: Padding(
        padding: EdgeInsets.all(AppTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTokens.primaryPurple.withValues(alpha: 0.2),
                  child: Text(
                    offer.buyerName[0],
                    style: const TextStyle(
                      color: AppTokens.primaryPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: AppTokens.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.buyerName,
                        style: context.textStyles.titleMedium?.copyWith(
                          fontWeight: AppTokens.fontWeightBold,
                        ),
                      ),
                      Text(
                        'Oferta #${offer.id}',
                        style: context.textStyles.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTokens.space12,
                    vertical: AppTokens.space8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTokens.primaryPurple.withValues(alpha: 0.1),
                    borderRadius: AppTokens.borderRadiusMedium,
                    border: Border.all(color: AppTokens.primaryPurple.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    offer.status.displayName,
                    style: context.textStyles.bodySmall?.copyWith(
                      color: AppTokens.primaryPurple,
                      fontWeight: AppTokens.fontWeightBold,
                    ),
                  ),
                ),
              ],
            ),
            Divider(height: AppTokens.space24),
            PDEIndicator(
              percentage: offer.pdePercentageRequested,
              totalPDEAvailable: _currentSession!.totalPDEAvailable,
              mode: PDEIndicatorMode.full,
            ),
            SizedBox(height: AppTokens.space12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Precio ofertado:', style: context.textStyles.bodyMedium),
                Text(
                  '\$${offer.pricePerKwh.toStringAsFixed(0)} COP/kWh',
                  style: context.textStyles.bodyMedium?.copyWith(
                    fontWeight: AppTokens.fontWeightBold,
                    color: AppTokens.primaryPurple,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTokens.space4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Valor estimado:', style: context.textStyles.bodyMedium),
                Text(
                  '\$${(energyKwh * offer.pricePerKwh).toStringAsFixed(0)}',
                  style: context.textStyles.bodyMedium?.copyWith(
                    fontWeight: AppTokens.fontWeightBold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnergyTab() {
    final prosumers = _getAvailableProsumers();

    return ListView(
      padding: EdgeInsets.all(AppTokens.space16),
      children: [
        Text(
          'Energía Disponible',
          style: context.textStyles.titleLarge?.copyWith(
            fontWeight: AppTokens.fontWeightBold,
          ),
        ),
        SizedBox(height: AppTokens.space16),

        // Lista de prosumidores
        ...prosumers.map((prosumer) => _buildProsumerCard(prosumer)),
      ],
    );
  }

  Widget _buildProsumerCard(Map<String, dynamic> prosumer) {
    return Card(
      margin: EdgeInsets.only(bottom: AppTokens.space12),
      child: Padding(
        padding: EdgeInsets.all(AppTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green.withValues(alpha: 0.2),
                  child: const Icon(Icons.solar_power, color: Colors.green),
                ),
                SizedBox(width: AppTokens.space12),
                Expanded(
                  child: Text(
                    prosumer['name'] as String,
                    style: context.textStyles.titleMedium?.copyWith(
                      fontWeight: AppTokens.fontWeightBold,
                    ),
                  ),
                ),
              ],
            ),
            Divider(height: AppTokens.space24),
            _buildEnergyRow('Tipo 2 total', prosumer['type2'] as double, Colors.blue),
            SizedBox(height: AppTokens.space8),
            _buildEnergyRow('PDE cedido', prosumer['pdeCeded'] as double, Colors.grey, isSubtraction: true),
            Divider(height: AppTokens.space16),
            _buildEnergyRow('Disponible P2P', prosumer['p2pAvailable'] as double, Colors.green, isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildEnergyRow(String label, double value, Color color, {bool isSubtraction = false, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (isSubtraction) ...[
              Icon(Icons.remove, color: color, size: 16),
              SizedBox(width: AppTokens.space4),
            ],
            Text(
              label,
              style: context.textStyles.bodyMedium?.copyWith(
                fontWeight: isBold ? AppTokens.fontWeightBold : null,
                color: color,
              ),
            ),
          ],
        ),
        Text(
          '${value.toStringAsFixed(2)} kWh',
          style: context.textStyles.bodyMedium?.copyWith(
            fontWeight: isBold ? AppTokens.fontWeightBold : AppTokens.fontWeightSemiBold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMatchingTab() {
    final offers = _getPendingOffers();
    final prosumers = _getAvailableProsumers();

    return ListView(
      padding: EdgeInsets.all(AppTokens.space16),
      children: [
        Text(
          'Matching Manual',
          style: context.textStyles.titleLarge?.copyWith(
            fontWeight: AppTokens.fontWeightBold,
          ),
        ),
        SizedBox(height: AppTokens.space8),
        Text(
          'Selecciona una oferta de consumidor y un prosumidor para crear el matching',
          style: context.textStyles.bodyMedium?.copyWith(color: Colors.grey),
        ),
        SizedBox(height: AppTokens.space24),

        // Selección de oferta
        Text(
          '1. Seleccionar Oferta de Consumidor',
          style: context.textStyles.titleMedium?.copyWith(
            fontWeight: AppTokens.fontWeightSemiBold,
          ),
        ),
        SizedBox(height: AppTokens.space12),
        ...offers.asMap().entries.map((entry) => _buildSelectableOfferCard(entry.key, entry.value)),

        SizedBox(height: AppTokens.space24),

        // Selección de prosumidor
        Text(
          '2. Seleccionar Prosumidor',
          style: context.textStyles.titleMedium?.copyWith(
            fontWeight: AppTokens.fontWeightSemiBold,
          ),
        ),
        SizedBox(height: AppTokens.space12),
        ...prosumers.asMap().entries.map((entry) => _buildSelectableProsumerCard(entry.key, entry.value)),

        SizedBox(height: AppTokens.space24),

        // Energía a asignar
        if (_selectedOfferIndex != null && _selectedProsumerIndex != null) ...[
          Text(
            '3. Energía a Asignar',
            style: context.textStyles.titleMedium?.copyWith(
              fontWeight: AppTokens.fontWeightSemiBold,
            ),
          ),
          SizedBox(height: AppTokens.space12),
          _buildEnergyAssignmentCard(offers[_selectedOfferIndex!], prosumers[_selectedProsumerIndex!]),
        ],

        SizedBox(height: AppTokens.space24),

        // Botón crear match
        if (_selectedOfferIndex != null && _selectedProsumerIndex != null && _energyToAssign > 0)
          ElevatedButton.icon(
            onPressed: _createMatch,
            icon: const Icon(Icons.link),
            label: const Text('Crear Match'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTokens.primaryPurple,
              foregroundColor: Colors.white,
              padding: EdgeInsets.all(AppTokens.space16),
            ),
          ),
      ],
    );
  }

  Widget _buildSelectableOfferCard(int index, ConsumerOffer offer) {
    final isSelected = _selectedOfferIndex == index;

    return Card(
      margin: EdgeInsets.only(bottom: AppTokens.space12),
      color: isSelected ? AppTokens.primaryPurple.withValues(alpha: 0.1) : null,
      child: InkWell(
        onTap: () => setState(() => _selectedOfferIndex = index),
        child: Padding(
          padding: EdgeInsets.all(AppTokens.space16),
          child: Row(
            children: [
              if (isSelected)
                const Icon(Icons.check_circle, color: AppTokens.primaryPurple)
              else
                Icon(Icons.radio_button_unchecked, color: Colors.grey[400]),
              SizedBox(width: AppTokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.buyerName,
                      style: context.textStyles.bodyLarge?.copyWith(
                        fontWeight: AppTokens.fontWeightSemiBold,
                      ),
                    ),
                    PDEIndicator(
                      percentage: offer.pdePercentageRequested,
                      totalPDEAvailable: _currentSession!.totalPDEAvailable,
                      mode: PDEIndicatorMode.compact,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectableProsumerCard(int index, Map<String, dynamic> prosumer) {
    final isSelected = _selectedProsumerIndex == index;

    return Card(
      margin: EdgeInsets.only(bottom: AppTokens.space12),
      color: isSelected ? AppTokens.energyGreen.withValues(alpha: 0.1) : null,
      child: InkWell(
        onTap: () => setState(() => _selectedProsumerIndex = index),
        child: Padding(
          padding: EdgeInsets.all(AppTokens.space16),
          child: Row(
            children: [
              if (isSelected)
                Icon(Icons.check_circle, color: AppTokens.energyGreen)
              else
                Icon(Icons.radio_button_unchecked, color: Colors.grey[400]),
              SizedBox(width: AppTokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prosumer['name'] as String,
                      style: context.textStyles.bodyLarge?.copyWith(
                        fontWeight: AppTokens.fontWeightSemiBold,
                      ),
                    ),
                    Text(
                      'Disponible: ${(prosumer['p2pAvailable'] as double).toStringAsFixed(2)} kWh',
                      style: context.textStyles.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnergyAssignmentCard(ConsumerOffer offer, Map<String, dynamic> prosumer) {
    final maxEnergy = (prosumer['p2pAvailable'] as double).clamp(0.0, double.infinity);
    final requestedEnergy = offer.calculateEnergyKwh(_currentSession!.totalPDEAvailable);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Energía (kWh)',
                  style: context.textStyles.titleSmall?.copyWith(
                    fontWeight: AppTokens.fontWeightSemiBold,
                  ),
                ),
                Text(
                  '${_energyToAssign.toStringAsFixed(2)} kWh',
                  style: context.textStyles.bodyLarge?.copyWith(
                    fontWeight: AppTokens.fontWeightBold,
                    color: AppTokens.primaryPurple,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTokens.space16),
            Slider(
              value: _energyToAssign,
              min: 0,
              max: maxEnergy > 0 ? maxEnergy : 1.0,
              divisions: maxEnergy > 0 ? (maxEnergy * 10).toInt() : 10,
              label: '${_energyToAssign.toStringAsFixed(2)} kWh',
              onChanged: (value) => setState(() => _energyToAssign = value),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0 kWh', style: context.textStyles.bodySmall),
                Text('${maxEnergy.toStringAsFixed(2)} kWh', style: context.textStyles.bodySmall),
              ],
            ),
            SizedBox(height: AppTokens.space16),
            Container(
              padding: EdgeInsets.all(AppTokens.space12),
              decoration: BoxDecoration(
                color: AppTokens.primaryPurple.withValues(alpha: 0.05),
                borderRadius: AppTokens.borderRadiusMedium,
                border: Border.all(
                  color: AppTokens.primaryPurple.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Solicitado por consumidor:', style: context.textStyles.bodySmall),
                      Text('${requestedEnergy.toStringAsFixed(2)} kWh', style: context.textStyles.bodySmall),
                    ],
                  ),
                  SizedBox(height: AppTokens.space4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Disponible por prosumidor:', style: context.textStyles.bodySmall),
                      Text('${maxEnergy.toStringAsFixed(2)} kWh', style: context.textStyles.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryTab() {
    final summary = _liquidationService.getSessionSummary(_currentSession!.id);

    return ListView(
      padding: EdgeInsets.all(AppTokens.space16),
      children: [
        Text(
          'Resumen de Liquidación',
          style: context.textStyles.titleLarge?.copyWith(
            fontWeight: AppTokens.fontWeightBold,
          ),
        ),
        SizedBox(height: AppTokens.space16),

        // Estadísticas
        _buildSummaryCard('Estado', summary['status'] as String, Icons.info_outline),
        _buildSummaryCard('Total Ofertas', '${summary['totalOffers']}', Icons.people),
        _buildSummaryCard('Matches Creados', '${summary['totalMatches']}', Icons.link),
        _buildSummaryCard('Eficiencia', '${(summary['matchingEfficiency'] as double).toStringAsFixed(1)}%', Icons.analytics),

        SizedBox(height: AppTokens.space24),

        // Matches creados
        if (_currentSession!.matches.isNotEmpty) ...[
          Text(
            'Matches Creados',
            style: context.textStyles.titleMedium?.copyWith(
              fontWeight: AppTokens.fontWeightSemiBold,
            ),
          ),
          SizedBox(height: AppTokens.space12),
          ..._currentSession!.matches.map((match) => _buildMatchCard(match)),
        ],

        SizedBox(height: AppTokens.space24),

        // Botón finalizar
        if (_currentSession!.status != LiquidationStatus.completed)
          ElevatedButton.icon(
            onPressed: _currentSession!.matches.isEmpty ? null : _finalizeLiquidation,
            icon: const Icon(Icons.check),
            label: const Text('Finalizar Liquidación'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTokens.energyGreen,
              foregroundColor: Colors.white,
              padding: EdgeInsets.all(AppTokens.space16),
            ),
          ),

        if (_currentSession!.status == LiquidationStatus.completed)
          Container(
            padding: EdgeInsets.all(AppTokens.space16),
            decoration: BoxDecoration(
              color: AppTokens.energyGreen.withValues(alpha: 0.1),
              borderRadius: AppTokens.borderRadiusMedium,
              border: Border.all(color: AppTokens.energyGreen.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: AppTokens.energyGreen),
                SizedBox(width: AppTokens.space12),
                const Expanded(child: Text('Liquidación completada exitosamente')),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon) {
    return Card(
      margin: EdgeInsets.only(bottom: AppTokens.space12),
      child: Padding(
        padding: EdgeInsets.all(AppTokens.space16),
        child: Row(
          children: [
            Icon(icon, color: AppTokens.primaryPurple),
            SizedBox(width: AppTokens.space12),
            Expanded(
              child: Text(
                label,
                style: context.textStyles.bodyMedium,
              ),
            ),
            Text(
              value,
              style: context.textStyles.bodyLarge?.copyWith(
                fontWeight: AppTokens.fontWeightBold,
                color: AppTokens.primaryPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchCard(LiquidationMatch match) {
    return Card(
      margin: EdgeInsets.only(bottom: AppTokens.space12),
      child: Padding(
        padding: EdgeInsets.all(AppTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.link, color: Colors.green),
                SizedBox(width: AppTokens.space12),
                Expanded(
                  child: Text(
                    '${match.prosumerName} → ${match.buyerName}',
                    style: context.textStyles.bodyLarge?.copyWith(
                      fontWeight: AppTokens.fontWeightBold,
                    ),
                  ),
                ),
              ],
            ),
            Divider(height: AppTokens.space16),
            _buildMatchRow('Energía', '${match.energyKwh.toStringAsFixed(2)} kWh'),
            _buildMatchRow('Precio', '\$${match.pricePerKwh.toStringAsFixed(0)} COP/kWh'),
            _buildMatchRow('Valor Total', '\$${(match.energyKwh * match.pricePerKwh).toStringAsFixed(0)}'),
            _buildMatchRow('% PDE cumplido', '${(match.pdePercentageFulfilled * 100).toStringAsFixed(1)}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppTokens.space4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.textStyles.bodySmall),
          Text(
            value,
            style: context.textStyles.bodySmall?.copyWith(
              fontWeight: AppTokens.fontWeightSemiBold,
            ),
          ),
        ],
      ),
    );
  }
}
