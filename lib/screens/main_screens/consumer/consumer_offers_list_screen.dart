import 'package:flutter/material.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/utils/metodos.dart';
import '../../../data/fake_data_january_2026.dart';
import '../../../services/consumer_offer_service.dart';
import '../../../models/consumer_offer.dart';
import '../../../models/my_user.dart';
import '../../../widgets/pde_indicator.dart';

/// Pantalla de Listado de Ofertas - CONSUMIDOR
/// Permite al consumidor ver sus ofertas de compra P2P:
/// - Ofertas pending (puede cancelar)
/// - Ofertas matched (resultados de liquidación)
/// - Ofertas parciales
/// - Ofertas canceladas/expiradas
///
/// ENERO 2026+ - Nuevo modelo de mercado
class ConsumerOffersListScreen extends StatefulWidget {
  final String period;
  final MyUser myUser;

  const ConsumerOffersListScreen({
    super.key,
    this.period = '2026-01',
    required this.myUser,
  });

  @override
  State<ConsumerOffersListScreen> createState() => _ConsumerOffersListScreenState();
}

class _ConsumerOffersListScreenState extends State<ConsumerOffersListScreen> {
  final ConsumerOfferService _offerService = ConsumerOfferService();
  final _totalPDEAvailable = FakeDataJanuary2026.pdeJan2026.allocatedEnergy;

  bool _isLoading = true;
  List<ConsumerOffer> _offers = [];

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    setState(() => _isLoading = true);

    // Cargar ofertas desde almacenamiento local
    final offers = await _offerService.getBuyerOfferForPeriod(
      widget.myUser.idUser!,
      widget.period,
    );

    setState(() {
      _offers = offers != null ? [offers] : [];
      _isLoading = false;
    });
  }

  Future<void> _cancelOffer(ConsumerOffer offer) async {
    // Confirmar cancelación
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Oferta'),
        content: Text(
          '¿Estás seguro de que deseas cancelar esta oferta?\n\n'
          'Oferta #${offer.id}\n'
          '${(offer.pdePercentageRequested * 100).toStringAsFixed(2)}% del PDE\n\n'
          'Esta acción no se puede revertir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              foregroundColor: AppTokens.primaryRed,
              side: const BorderSide(color: AppTokens.primaryRed),
            ),
            child: const Text('Sí, Cancelar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      await _offerService.cancelOffer(
        offerId: offer.id,
        buyerId: widget.myUser.idUser!,
        reason: 'Cancelada por el usuario',
      );

      setState(() {
        _isLoading = false;
      });

      _showSnackBar('Oferta cancelada exitosamente');
      _loadOffers();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar(e.toString(), isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTokens.primaryRed : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingOffers = _offers.where((o) => o.status == ConsumerOfferStatus.pending).toList();
    final matchedOffers = _offers.where((o) => o.status == ConsumerOfferStatus.matched).toList();
    final partialOffers = _offers.where((o) => o.status == ConsumerOfferStatus.partialMatch).toList();
    final inactiveOffers = _offers.where(
      (o) => o.status == ConsumerOfferStatus.cancelled || o.status == ConsumerOfferStatus.expired,
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mis Ofertas',
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
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTokens.primaryRed),
              ),
            )
          : _offers.isEmpty
              ? _buildEmptyState()
              : ListView(
                  padding: EdgeInsets.all(AppTokens.space16),
                  children: [
                    // Estadísticas
                    _buildStatsCard(_offers.length, pendingOffers.length, matchedOffers.length),
                    SizedBox(height: AppTokens.space24),

                    // Ofertas Pending
                    if (pendingOffers.isNotEmpty) ...[
                      _buildSectionHeader(
                        'Ofertas Pendientes',
                        Icons.pending_actions,
                        AppTokens.primaryRed,
                      ),
                      ...pendingOffers.map((offer) => _buildOfferCard(offer, canCancel: true)),
                      SizedBox(height: AppTokens.space16),
                    ],

                    // Ofertas Matched
                    if (matchedOffers.isNotEmpty) ...[
                      _buildSectionHeader(
                        'Ofertas Confirmadas',
                        Icons.check_circle,
                        Colors.green,
                      ),
                      ...matchedOffers.map((offer) => _buildOfferCard(offer)),
                      SizedBox(height: AppTokens.space16),
                    ],

                    // Ofertas Parciales
                    if (partialOffers.isNotEmpty) ...[
                      _buildSectionHeader(
                        'Ofertas Parciales',
                        Icons.pie_chart,
                        Colors.blue,
                      ),
                      ...partialOffers.map((offer) => _buildOfferCard(offer)),
                      SizedBox(height: AppTokens.space16),
                    ],

                    // Ofertas Inactivas
                    if (inactiveOffers.isNotEmpty) ...[
                      _buildSectionHeader(
                        'Ofertas Inactivas',
                        Icons.archive,
                        Colors.grey,
                      ),
                      ...inactiveOffers.map((offer) => _buildOfferCard(offer)),
                    ],

                    SizedBox(height: AppTokens.space64),
                  ],
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppTokens.space32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: AppTokens.space16),
            Text(
              'No tienes ofertas',
              style: context.textStyles.titleLarge?.copyWith(
                color: Colors.grey,
              ),
            ),
            SizedBox(height: AppTokens.space8),
            Text(
              'Crea tu primera oferta de compra P2P',
              style: context.textStyles.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppTokens.space24),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.add),
              label: const Text('Crear Oferta'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTokens.primaryRed,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(int total, int pending, int matched) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen',
              style: context.textStyles.titleMedium?.copyWith(
                fontWeight: AppTokens.fontWeightBold,
              ),
            ),
            SizedBox(height: AppTokens.space16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total', total, AppTokens.primaryRed),
                _buildStatItem('Pendientes', pending, AppTokens.primaryRed),
                _buildStatItem('Confirmadas', matched, AppTokens.primaryRed),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          '$value',
          style: context.textStyles.headlineMedium?.copyWith(
            color: color,
            fontWeight: AppTokens.fontWeightBold,
          ),
        ),
        SizedBox(height: AppTokens.space4),
        Text(
          label,
          style: context.textStyles.bodySmall?.copyWith(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTokens.space12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(width: AppTokens.space8),
          Text(
            title,
            style: context.textStyles.titleMedium?.copyWith(
              fontWeight: AppTokens.fontWeightBold,
              color: context.colors.onSurface, // Usar color del tema en vez del color del icon
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(ConsumerOffer offer, {bool canCancel = false}) {
    final energyKwh = offer.energyKwhCalculated ??
        offer.calculateEnergyKwh(_totalPDEAvailable);
    final totalValue = energyKwh * offer.pricePerKwh;

    return Card(
      margin: EdgeInsets.only(bottom: AppTokens.space12),
      child: Padding(
        padding: EdgeInsets.all(AppTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Oferta #${offer.id}',
                  style: context.textStyles.titleSmall?.copyWith(
                    fontWeight: AppTokens.fontWeightBold,
                  ),
                ),
                _buildStatusBadge(offer.status),
              ],
            ),
            SizedBox(height: AppTokens.space12),

            // PDE Indicator
            PDEIndicator(
              percentage: offer.pdePercentageRequested,
              totalPDEAvailable: _totalPDEAvailable,
              mode: PDEIndicatorMode.full,
            ),
            SizedBox(height: AppTokens.space12),

            // Detalles
            _buildDetailRow('Precio', '\$${offer.pricePerKwh.toStringAsFixed(0)} COP/kWh'),
            _buildDetailRow('Valor', '\$${totalValue.toStringAsFixed(0)}'),

            if (offer.status == ConsumerOfferStatus.matched ||
                offer.status == ConsumerOfferStatus.partialMatch) ...[
              SizedBox(height: AppTokens.space8),
              Container(
                padding: EdgeInsets.all(AppTokens.space12),
                decoration: BoxDecoration(
                  color: AppTokens.energyGreen.withValues(alpha: 0.1),
                  borderRadius: AppTokens.borderRadiusMedium,
                  border: Border.all(color: AppTokens.energyGreen.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: AppTokens.energyGreen, size: 16),
                        SizedBox(width: AppTokens.space8),
                        Text(
                          'Liquidación completada',
                          style: context.textStyles.bodySmall?.copyWith(
                            color: AppTokens.energyGreen,
                            fontWeight: AppTokens.fontWeightBold,
                          ),
                        ),
                      ],
                    ),
                    if (offer.energyKwhCalculated != null) ...[
                      SizedBox(height: AppTokens.space8),
                      Text(
                        'Energía asignada: ${offer.energyKwhCalculated!.toStringAsFixed(2)} kWh',
                        style: context.textStyles.bodySmall,
                      ),
                    ],
                    if (offer.liquidatedAt != null) ...[
                      Text(
                        'Liquidada: ${_formatDate(offer.liquidatedAt!)}',
                        style: context.textStyles.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            // Fechas
            SizedBox(height: AppTokens.space12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Creada: ${_formatDate(offer.createdAt)}',
                  style: context.textStyles.bodySmall?.copyWith(color: Colors.grey),
                ),
                Text(
                  'Válida hasta: ${_formatDate(offer.validUntil)}',
                  style: context.textStyles.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),

            // Botón cancelar
            if (canCancel) ...[
              SizedBox(height: AppTokens.space12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _cancelOffer(offer),
                  icon: const Icon(Icons.cancel, size: 20),
                  label: const Text('Cancelar Oferta'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTokens.primaryRed,
                    side: const BorderSide(color: AppTokens.primaryRed),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ConsumerOfferStatus status) {
    Color color;
    IconData icon;

    switch (status) {
      case ConsumerOfferStatus.pending:
        color = Colors.orange;
        icon = Icons.pending_actions;
        break;
      case ConsumerOfferStatus.matched:
        color = AppTokens.energyGreen;
        icon = Icons.check_circle;
        break;
      case ConsumerOfferStatus.partialMatch:
        color = AppTokens.primaryRed.withValues(alpha: 0.7);
        icon = Icons.pie_chart;
        break;
      case ConsumerOfferStatus.expired:
        color = Colors.grey;
        icon = Icons.timer_off;
        break;
      case ConsumerOfferStatus.cancelled:
        color = Colors.grey.shade600;
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTokens.space12,
        vertical: AppTokens.space8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppTokens.borderRadiusMedium,
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          SizedBox(width: AppTokens.space4),
          Text(
            status.displayName,
            style: context.textStyles.bodySmall?.copyWith(
              color: color,
              fontWeight: AppTokens.fontWeightBold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppTokens.space4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.textStyles.bodyMedium),
          Text(
            value,
            style: context.textStyles.bodyMedium?.copyWith(
              fontWeight: AppTokens.fontWeightSemiBold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
