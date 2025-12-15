import 'package:flutter/material.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import '../../../data/fake_data_phase2.dart';
import '../../../models/p2p_offer.dart';
import 'offer_detail_acceptance_screen.dart';

/// Pantalla de Mercado P2P - CONSUMIDOR
/// Muestra las ofertas P2P disponibles para compra
/// FASE 2 - Transaccional - Diciembre 2025
class ConsumerMarketplaceScreen extends StatefulWidget {
  const ConsumerMarketplaceScreen({super.key});

  @override
  State<ConsumerMarketplaceScreen> createState() => _ConsumerMarketplaceScreenState();
}

class _ConsumerMarketplaceScreenState extends State<ConsumerMarketplaceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _ve = FakeDataPhase2.veDecember2025;
  final _consumer = FakeDataPhase2.anaLopez;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: const Text('Mercado P2P'),
        backgroundColor: AppTokens.energyGreen,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
          tabs: const [
            Tab(text: 'Ofertas Disponibles', icon: Icon(Icons.shopping_cart)),
            Tab(text: 'Mis Compras', icon: Icon(Icons.receipt_long)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAvailableOffersTab(),
          _buildMyPurchasesTab(),
        ],
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
                  'VE: \$${_ve.totalVE.toStringAsFixed(0)} COP/kWh | Rango P2P: \$${_ve.minAllowedPrice.toStringAsFixed(0)}-\$${_ve.maxAllowedPrice.toStringAsFixed(0)}',
                  style: context.textStyles.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
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
                    backgroundColor: AppTokens.primaryPurple.withValues(alpha: 0.2),
                    child: Text(
                      offer.sellerName[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppTokens.primaryPurple,
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
                            Icon(Icons.verified, size: 16, color: Colors.green),
                            SizedBox(width: AppTokens.space4),
                            Text(
                              'Verificado',
                              style: context.textStyles.bodySmall?.copyWith(
                                color: Colors.green,
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
                      borderRadius: AppTokens.borderRadiusMedium,
                      border: Border.all(color: Colors.green),
                    ),
                    child: Text(
                      offer.status.displayName,
                      style: context.textStyles.bodySmall?.copyWith(
                        color: Colors.green,
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
                      '${offer.energyAvailable.toStringAsFixed(1)} kWh',
                    ),
                  ),
                  Expanded(
                    child: _buildOfferDetail(
                      Icons.attach_money,
                      'Precio',
                      '\$${offer.pricePerKwh.toStringAsFixed(0)}',
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
                      '\$${offer.totalValue.toStringAsFixed(0)}',
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
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: AppTokens.borderRadiusMedium,
                  border: Border.all(
                    color: savingsPerKwh > 0 ? Colors.green : Colors.orange,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          savingsPerKwh > 0 ? Icons.trending_down : Icons.trending_up,
                          color: savingsPerKwh > 0 ? Colors.green : Colors.orange,
                          size: 20,
                        ),
                        SizedBox(width: AppTokens.space8),
                        Text(
                          savingsPerKwh > 0 ? 'Ahorro' : 'Costo adicional',
                          style: context.textStyles.bodyMedium?.copyWith(
                            color: savingsPerKwh > 0 ? Colors.green : Colors.orange,
                            fontWeight: AppTokens.fontWeightSemiBold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${savingsPerKwh > 0 ? '-' : '+'}\$${totalSavings.abs().toStringAsFixed(0)} (${savingsPercentage.abs().toStringAsFixed(1)}%)',
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: savingsPerKwh > 0 ? Colors.green : Colors.orange,
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
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: AppTokens.borderRadiusMedium,
                  ),
                  child: Text(
                    contract.status.toUpperCase(),
                    style: context.textStyles.bodySmall?.copyWith(
                      color: Colors.green,
                      fontWeight: AppTokens.fontWeightBold,
                    ),
                  ),
                ),
              ],
            ),
            Divider(height: AppTokens.space16),
            _buildContractRow('Vendedor', contract.sellerName),
            _buildContractRow('Energía', '${contract.energyCommitted.toStringAsFixed(2)} kWh'),
            _buildContractRow('Precio', '\$${contract.agreedPrice.toStringAsFixed(0)} COP/kWh'),
            _buildContractRow('Total', '\$${contract.totalValue.toStringAsFixed(0)}', isBold: true),
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
