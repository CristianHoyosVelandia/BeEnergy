import 'package:flutter/material.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/utils/formatters.dart';
import 'package:be_energy/utils/metodos.dart';
import '../../../data/fake_data_phase2.dart';
import '../../../data/fake_data_january_2026.dart';
import '../../../models/p2p_offer.dart';
import '../../../models/consumer_offer.dart';
import '../../../services/consumer_offer_service.dart';
import '../../../widgets/pde_indicator.dart';
import 'offer_detail_acceptance_screen.dart';
import 'consumer_create_offer_screen.dart';
import 'consumer_offers_list_screen.dart';

/// Pantalla de Mercado P2P - CONSUMIDOR
/// Muestra las ofertas P2P disponibles para compra
/// - Diciembre 2025: Ofertas de prosumidores (modelo antiguo)
/// - Enero 2026+: Crear ofertas de compra basadas en PDE (modelo nuevo)
class ConsumerMarketplaceScreen extends StatefulWidget {
  const ConsumerMarketplaceScreen({super.key});

  @override
  State<ConsumerMarketplaceScreen> createState() => _ConsumerMarketplaceScreenState();
}

enum MarketPeriod {
  december2025('Diciembre 2025', '2025-12'),
  january2026('Enero 2026', '2026-01');

  final String displayName;
  final String period;
  const MarketPeriod(this.displayName, this.period);
}

class _ConsumerMarketplaceScreenState extends State<ConsumerMarketplaceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _consumer = FakeDataPhase2.cristianHoyos;
  final _offerService = ConsumerOfferService();

  // Período seleccionado (por defecto Enero 2026)
  MarketPeriod _selectedPeriod = MarketPeriod.january2026;

  // Estado de oferta existente
  bool _hasExistingOffer = false;
  bool _isCheckingOffer = true;
  ConsumerOffer? _existingOffer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkExistingOffer();
  }

  /// Verifica si existe una oferta para el período actual
  Future<void> _checkExistingOffer() async {
    final offer = await _offerService.getBuyerOfferForPeriod(
      _consumer.userId,
      _selectedPeriod.period,
    );

    if (mounted) {
      setState(() {
        _existingOffer = offer;
        _hasExistingOffer = offer != null && offer.status == ConsumerOfferStatus.pending;
        _isCheckingOffer = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Obtiene ofertas disponibles
  List<P2POffer> get _availableOffers {
    return FakeDataPhase2.allOffers
        .where((offer) => offer.isAvailable)
        .toList();
  }

  /// Obtiene contratos del consumidor
  List get _myPurchases {
    return FakeDataPhase2.allContracts
        .where((contract) => contract.buyerId == _consumer.userId)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mercado P2P',
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: Metodos.gradientClasic(context),
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_selectedPeriod == MarketPeriod.january2026)
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.white),
              tooltip: '¿Qué son los PDE?',
              onPressed: () => _showPDEHelpDialog(),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
          tabs: _selectedPeriod == MarketPeriod.december2025
              ? const [
                  Tab(text: 'Ofertas Disponibles', icon: Icon(Icons.shopping_cart)),
                  Tab(text: 'Mis Compras', icon: Icon(Icons.receipt_long)),
                ]
              : const [
                  Tab(text: 'Crear Oferta', icon: Icon(Icons.add_shopping_cart)),
                  Tab(text: 'Mis Ofertas', icon: Icon(Icons.list)),
                ],
        ),
      ),
      body: Column(
        children: [
          // Selector de período
          _buildPeriodSelector(),

          // Contenido según período
          Expanded(
            child: _selectedPeriod == MarketPeriod.december2025
                ? TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAvailableOffersTab(),
                      _buildMyPurchasesTab(),
                    ],
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCreateOfferTab(),
                      _buildMyOffersTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      margin: EdgeInsets.all(AppTokens.space16),
      padding: EdgeInsets.all(AppTokens.space4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: AppTokens.borderRadiusLarge,
      ),
      child: Row(
        children: MarketPeriod.values.map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriod = period;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: AppTokens.space12,
                  horizontal: AppTokens.space8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppTokens.primaryRed : Colors.transparent,
                  borderRadius: AppTokens.borderRadiusLarge,
                ),
                child: Text(
                  period.displayName,
                  textAlign: TextAlign.center,
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: isSelected
                        ? AppTokens.fontWeightBold
                        : AppTokens.fontWeightMedium,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAvailableOffersTab() {
    final offers = _availableOffers;

    if (offers.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Header: VE Info
        _buildVEInfoCard(),

        // Lista de ofertas
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(AppTokens.space16),
            itemCount: offers.length,
            itemBuilder: (context, index) => _buildOfferCard(offers[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildVEInfoCard() {
    final ve = FakeDataPhase2.veDecember2025;

    return Container(
      margin: EdgeInsets.all(AppTokens.space16),
      padding: EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        color: AppTokens.info.withValues(alpha: 0.1),
        borderRadius: AppTokens.borderRadiusMedium,
        border: Border.all(color: AppTokens.info),
      ),
      child: Row(
        children: [
          const Icon(Icons.info, color: AppTokens.info),
          SizedBox(width: AppTokens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Valor de Energía (VE) - Diciembre 2025',
                  style: context.textStyles.bodyMedium?.copyWith(
                    fontWeight: AppTokens.fontWeightSemiBold,
                  ),
                ),
                SizedBox(height: AppTokens.space4),
                Text(
                  'VE: ${Formatters.formatCurrency(ve.totalVE)} COP/kWh | Rango P2P: ${Formatters.formatCurrency(ve.minAllowedPrice)}-${Formatters.formatCurrency(ve.maxAllowedPrice)}',
                  style: context.textStyles.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // DIÁLOGO DE AYUDA PDE
  // ============================================================================

  void _showPDEHelpDialog() {
    final minValue = FakeDataJanuary2026.pdeConstantsJan2026.mcmValorEnergiaPromedio * 1.1;
    final maxValue = (FakeDataJanuary2026.pdeConstantsJan2026.costoEnergia -
                      FakeDataJanuary2026.pdeConstantsJan2026.costoComercializacion) * 0.95;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: AppTokens.primaryRed),
            SizedBox(width: 12),
            Text('¿Qué son los PDE?'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Porcentaje de Distribución de Excedentes (PDE)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              const Text(
                'El PDE es el % del excedente Tipo 2 que se distribuye en los miembros comunitarios según la resoluciòn CREG 101 072 Art 3.4.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Text(
                '¿Por qué crear una oferta?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'El proceso de crear una oferta se hace con el fin de buscar favorabilidad en la asignación de los PDE.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Text(
                'Rango de Precios:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Mínimo: ${Formatters.formatCurrency(minValue, decimals: 2)} COP/kWh',
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                'Máximo: ${Formatters.formatCurrency(maxValue, decimals: 2)} COP/kWh',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              const Text(
                'Los valores mínimo y máximo están limitados para que los consumidores puedan generar un ahorro y los prosumidores un valor agregado sobre el precio mínimo de los mercados regulados.',
                style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // TABS ENERO 2026
  // ============================================================================

  Widget _buildCreateOfferTab() {
    // Mostrar loading mientras se verifica
    if (_isCheckingOffer) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTokens.primaryRed),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppTokens.space24),
      child: Column(
        children: [
          // Mostrar resumen compacto de oferta existente si hay una
          if (_hasExistingOffer && _existingOffer != null)
            _buildExistingOfferSummary(_existingOffer!),

          if (_hasExistingOffer && _existingOffer != null)
            SizedBox(height: AppTokens.space24),

          // Card de acción principal (solo si NO hay oferta)
          if (!_hasExistingOffer)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_shopping_cart,
                    size: 80,
                    color: AppTokens.primaryRed.withValues(alpha: 0.7),
                  ),
                  SizedBox(height: AppTokens.space24),
                  Text(
                    'Crear Oferta de Compra',
                    style: context.textStyles.titleLarge?.copyWith(
                      fontWeight: AppTokens.fontWeightBold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppTokens.space12),
                  Text(
                    'En Enero 2026, crea ofertas especificando qué % del PDE deseas comprar y a qué precio.',
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppTokens.space32),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ConsumerCreateOfferScreen(),
                        ),
                      );
                      _checkExistingOffer();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Crear Oferta'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTokens.primaryRed,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTokens.space24,
                        vertical: AppTokens.space16,
                      ),
                    ),
                  ),
                  SizedBox(height: AppTokens.space16),
                  OutlinedButton.icon(
                    onPressed: () => _showHowItWorksDialog(),
                    icon: const Icon(Icons.info_outline),
                    label: const Text('¿Cómo funciona?'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showHowItWorksDialog() {
    final minValue = FakeDataJanuary2026.pdeConstantsJan2026.mcmValorEnergiaPromedio * 1.1;
    final maxValue = (FakeDataJanuary2026.pdeConstantsJan2026.costoEnergia -
                      FakeDataJanuary2026.pdeConstantsJan2026.costoComercializacion) * 0.95;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: AppTokens.primaryRed),
            SizedBox(width: 12),
            Text('¿Cómo funciona?'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nuevo Modelo - Enero 2026',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              const Text(
                '¿Qué cambió?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('• Los consumidores ahora crean ofertas de compra'),
              const Text('• Las ofertas se basan en % del PDE disponible'),
              const Text('• Un administrador hace la liquidación'),
              const SizedBox(height: 16),
              const Text(
                'Rango de Precios:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Mínimo: ${Formatters.formatCurrency(minValue, decimals: 2)} COP/kWh'),
              Text('Máximo: ${Formatters.formatCurrency(maxValue, decimals: 2)} COP/kWh'),
              const SizedBox(height: 12),
              const Text(
                'Estos límites garantizan ahorro para consumidores y valor agregado para prosumidores.',
                style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 16),
              const Text(
                'Diferencia con Diciembre 2025:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('• Antes: Prosumidores publicaban, consumidores aceptaban'),
              const Text('• Ahora: Consumidores ofertan, admin liquida'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  /// Widget compacto que muestra el resumen de la oferta existente con ícono de edición
  Widget _buildExistingOfferSummary(ConsumerOffer offer) {
    const double pdeMesAnterior = 720.0;
    final double tarifaTradicional = FakeDataJanuary2026.pdeConstantsJan2026.costoEnergia;
    final double pdePercentage = offer.pdePercentageRequested * 100;
    final double kwhEstimados = (pdePercentage * pdeMesAnterior) / 100;
    final double ahorroPorKwh = tarifaTradicional - offer.pricePerKwh;
    final double ahorroTotal = ahorroPorKwh * kwhEstimados;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTokens.primaryRed,
            AppTokens.primaryRed.withValues(alpha: 0.85),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con ícono de edición
          Container(
            padding: EdgeInsets.all(AppTokens.space16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.only(
                topLeft: AppTokens.borderRadiusLarge.topLeft,
                topRight: AppTokens.borderRadiusLarge.topRight,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 24),
                SizedBox(width: AppTokens.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tu Oferta Actual',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: AppTokens.fontWeightBold,
                        ),
                      ),
                      Text(
                        _selectedPeriod.displayName,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                // Ícono de lápiz para editar
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  tooltip: 'Modificar Oferta',
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ConsumerCreateOfferScreen(),
                      ),
                    );
                    _checkExistingOffer();
                  },
                ),
              ],
            ),
          ),

          // Contenido principal compacto
          Padding(
            padding: EdgeInsets.all(AppTokens.space16),
            child: Column(
              children: [
                // PDE y Precio en fila
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetricColumn('PDE Solicitado', '${Formatters.formatEnergy(pdePercentage, unit: '', decimals: 2)}%'),
                    _buildMetricColumn('Precio', Formatters.formatCurrency(offer.pricePerKwh), subtitle: 'COP/kWh'),
                  ],
                ),

                SizedBox(height: AppTokens.space16),

                // Energía estimada
                _buildInfoRow(
                  Icons.electric_bolt,
                  'Recibirás aprox.',
                  Formatters.formatEnergy(kwhEstimados, decimals: 2),
                  AppTokens.white,
                ),

                SizedBox(height: AppTokens.space12),

                // Ahorro total
                _buildInfoRow(
                  Icons.savings,
                  'Ahorro vs Tradicional',
                  Formatters.formatCurrency(ahorroTotal),
                  Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Widget reutilizable para mostrar métricas
  Widget _buildMetricColumn(String label, String value, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
        SizedBox(height: AppTokens.space4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: AppTokens.fontWeightBold,
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 11,
            ),
          ),
      ],
    );
  }

  /// Widget reutilizable para filas de información
  Widget _buildInfoRow(IconData icon, String label, String value, Color iconColor) {
    return Container(
      padding: EdgeInsets.all(AppTokens.space12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: AppTokens.borderRadiusMedium,
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              SizedBox(width: AppTokens.space8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 13,
                  fontWeight: AppTokens.fontWeightSemiBold,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: AppTokens.fontWeightBold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyOffersTab() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppTokens.space32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.list_alt,
              size: 80,
              color: AppTokens.primaryRed.withValues(alpha: 0.7),
            ),
            SizedBox(height: AppTokens.space24),
            Text(
              'Mis Ofertas de Compra',
              style: context.textStyles.titleLarge?.copyWith(
                fontWeight: AppTokens.fontWeightBold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppTokens.space12),
            Text(
              'Ve el estado de tus ofertas: pendientes, confirmadas o parciales.',
              style: context.textStyles.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppTokens.space32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConsumerOffersListScreen(
                      period: _selectedPeriod.period,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.list),
              label: const Text('Ver Mis Ofertas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTokens.primaryRed,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: AppTokens.space24,
                  vertical: AppTokens.space16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferCard(P2POffer offer) {
    final traditionalPrice = 500.0; // Tarifa regulada
    final savingsPerKwh = traditionalPrice - offer.pricePerKwh;
    final totalSavings = savingsPerKwh * offer.energyAvailable;
    final savingsPercentage = (savingsPerKwh / traditionalPrice) * 100;

    return Card(
      margin: EdgeInsets.only(bottom: AppTokens.space16),
      elevation: AppTokens.elevation4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OfferDetailAcceptanceScreen(offer: offer),
            ),
          );
        },
        borderRadius: AppTokens.borderRadiusMedium,
        child: Padding(
          padding: EdgeInsets.all(AppTokens.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vendedor
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTokens.primaryRed.withValues(alpha: 0.2),
                    child: Text(
                      offer.sellerName[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppTokens.primaryRed,
                        fontWeight: AppTokens.fontWeightBold,
                      ),
                    ),
                  ),
                  SizedBox(width: AppTokens.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offer.sellerName,
                          style: context.textStyles.titleMedium?.copyWith(
                            fontWeight: AppTokens.fontWeightBold,
                          ),
                        ),
                        SizedBox(height: AppTokens.space4),
                        Row(
                          children: [
                            Icon(Icons.verified, size: 16, color: AppTokens.energyGreen),
                            SizedBox(width: AppTokens.space4),
                            Text(
                              'Verificado',
                              style: context.textStyles.bodySmall?.copyWith(
                                color: AppTokens.energyGreen,
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
                      color: AppTokens.energyGreen.withValues(alpha: 0.1),
                      borderRadius: AppTokens.borderRadiusMedium,
                      border: Border.all(color: AppTokens.energyGreen),
                    ),
                    child: Text(
                      offer.status.displayName,
                      style: context.textStyles.bodySmall?.copyWith(
                        color: AppTokens.energyGreen,
                        fontWeight: AppTokens.fontWeightBold,
                      ),
                    ),
                  ),
                ],
              ),

              Divider(height: AppTokens.space24),

              // Detalles de la oferta
              Row(
                children: [
                  Expanded(
                    child: _buildOfferDetail(
                      Icons.bolt,
                      'Energía',
                      Formatters.formatEnergy(offer.energyAvailable, decimals: 1),
                    ),
                  ),
                  Expanded(
                    child: _buildOfferDetail(
                      Icons.attach_money,
                      'Precio',
                      Formatters.formatCurrency(offer.pricePerKwh),
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppTokens.space12),

              Row(
                children: [
                  Expanded(
                    child: _buildOfferDetail(
                      Icons.calendar_today,
                      'Válida hasta',
                      '31/12/2025',
                    ),
                  ),
                  Expanded(
                    child: _buildOfferDetail(
                      Icons.payment,
                      'Total',
                      Formatters.formatCurrency(offer.totalValue),
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppTokens.space16),

              // Ahorro vs tarifa regulada
              Container(
                padding: EdgeInsets.all(AppTokens.space12),
                decoration: BoxDecoration(
                  color: savingsPerKwh > 0
                      ? AppTokens.energyGreen.withValues(alpha: 0.1)
                      : AppTokens.primaryRed.withValues(alpha: 0.1),
                  borderRadius: AppTokens.borderRadiusMedium,
                  border: Border.all(
                    color: savingsPerKwh > 0 ? AppTokens.energyGreen : AppTokens.primaryRed.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          savingsPerKwh > 0 ? Icons.trending_down : Icons.trending_up,
                          color: savingsPerKwh > 0 ? AppTokens.energyGreen : AppTokens.primaryRed,
                          size: 20,
                        ),
                        SizedBox(width: AppTokens.space8),
                        Text(
                          savingsPerKwh > 0 ? 'Ahorro' : 'Costo adicional',
                          style: context.textStyles.bodyMedium?.copyWith(
                            color: savingsPerKwh > 0 ? AppTokens.energyGreen : AppTokens.primaryRed,
                            fontWeight: AppTokens.fontWeightSemiBold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${savingsPerKwh > 0 ? '-' : '+'}${Formatters.formatCurrency(totalSavings.abs())} (${savingsPercentage.abs().toStringAsFixed(1)}%)',
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: savingsPerKwh > 0 ? AppTokens.energyGreen : AppTokens.primaryRed,
                        fontWeight: AppTokens.fontWeightBold,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppTokens.space16),

              // Botones
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OfferDetailAcceptanceScreen(offer: offer),
                          ),
                        );
                      },
                      icon: const Icon(Icons.visibility),
                      label: const Text('Ver Detalle'),
                    ),
                  ),
                  SizedBox(width: AppTokens.space12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OfferDetailAcceptanceScreen(offer: offer),
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('Comprar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTokens.energyGreen,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfferDetail(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        SizedBox(width: AppTokens.space8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: context.textStyles.bodySmall?.copyWith(color: Colors.grey),
            ),
            Text(
              value,
              style: context.textStyles.bodyMedium?.copyWith(
                fontWeight: AppTokens.fontWeightSemiBold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey.withValues(alpha: 0.3),
          ),
          SizedBox(height: AppTokens.space16),
          Text(
            'No hay ofertas disponibles',
            style: context.textStyles.titleMedium?.copyWith(
              color: Colors.grey,
              fontWeight: AppTokens.fontWeightBold,
            ),
          ),
          SizedBox(height: AppTokens.space8),
          Text(
            'Las ofertas P2P aparecerán aquí cuando\nlos prosumidores publiquen energía',
            textAlign: TextAlign.center,
            style: context.textStyles.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyPurchasesTab() {
    final purchases = _myPurchases;

    if (purchases.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: Colors.grey.withValues(alpha: 0.3),
            ),
            SizedBox(height: AppTokens.space16),
            Text(
              'Sin compras P2P',
              style: context.textStyles.titleMedium?.copyWith(
                color: Colors.grey,
                fontWeight: AppTokens.fontWeightBold,
              ),
            ),
            SizedBox(height: AppTokens.space8),
            Text(
              'Tus contratos P2P aparecerán aquí',
              textAlign: TextAlign.center,
              style: context.textStyles.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppTokens.space16),
      itemCount: purchases.length,
      itemBuilder: (context, index) => _buildPurchaseCard(purchases[index]),
    );
  }

  Widget _buildPurchaseCard(contract) {
    return Card(
      margin: EdgeInsets.only(bottom: AppTokens.space16),
      child: Padding(
        padding: EdgeInsets.all(AppTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Contrato #${contract.id}',
                  style: context.textStyles.titleSmall?.copyWith(
                    fontWeight: AppTokens.fontWeightBold,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTokens.space8,
                    vertical: AppTokens.space4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTokens.energyGreen.withValues(alpha: 0.1),
                    borderRadius: AppTokens.borderRadiusMedium,
                  ),
                  child: Text(
                    contract.status.toUpperCase(),
                    style: context.textStyles.bodySmall?.copyWith(
                      color: AppTokens.energyGreen,
                      fontWeight: AppTokens.fontWeightBold,
                    ),
                  ),
                ),
              ],
            ),
            Divider(height: AppTokens.space16),
            _buildContractRow('Vendedor', contract.sellerName),
            _buildContractRow('Energía', Formatters.formatEnergy(contract.energyCommitted, decimals: 2)),
            _buildContractRow('Precio', '${Formatters.formatCurrency(contract.agreedPrice)} COP/kWh'),
            _buildContractRow('Total', Formatters.formatCurrency(contract.totalValue), isBold: true),
            SizedBox(height: AppTokens.space8),
            Text(
              'Fecha: ${contract.createdAt.day}/${contract.createdAt.month}/${contract.createdAt.year}',
              style: context.textStyles.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContractRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppTokens.space4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: context.textStyles.bodyMedium?.copyWith(
              fontWeight: isBold ? AppTokens.fontWeightBold : null,
            ),
          ),
          Text(
            value,
            style: context.textStyles.bodyMedium?.copyWith(
              fontWeight: isBold ? AppTokens.fontWeightBold : AppTokens.fontWeightSemiBold,
            ),
          ),
        ],
      ),
    );
  }
}
