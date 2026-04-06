import 'package:flutter/material.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/api/api_exceptions.dart';
import '../../../models/consumer_offer.dart';
import '../../../models/my_user.dart';
import '../../../services/consumer_offer_api_service.dart';
import '../../../utils/metodos.dart';
import 'consumer_create_offer_screen.dart';

/// Pantalla que muestra todas las ofertas históricas del usuario
///
/// Permite:
/// - Ver todas las ofertas (sin límite de 3)
/// - Ver detalles de cada oferta
/// - Editar ofertas pendientes (redirige a ConsumerCreateOfferScreen)
/// - Cancelar ofertas pendientes
/// - Ver estado y energía asignada para ofertas confirmadas
class MyOffersScreen extends StatefulWidget {
  final MyUser myUser;
  final int communityId;

  const MyOffersScreen({
    super.key,
    required this.myUser,
    this.communityId = 1,
  });

  @override
  State<MyOffersScreen> createState() => _MyOffersScreenState();
}

class _MyOffersScreenState extends State<MyOffersScreen> {
  final ConsumerOfferApiService _apiService = ConsumerOfferApiService();

  bool _isLoading = true;
  List<ConsumerOffer> _offers = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  /// Carga todas las ofertas del usuario desde el Web Service
  Future<void> _loadOffers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final offers = await _apiService.getBuyerOffers(widget.myUser.idUser ?? 0);

      setState(() {
        _offers = offers;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = 'Error al cargar ofertas: ${e.message}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error inesperado: $e';
        _isLoading = false;
      });
    }
  }

  /// Cancela una oferta
  Future<void> _cancelOffer(ConsumerOffer offer) async {
    // Mostrar confirmación
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cancelar oferta?'),
        content: Text(
          '¿Estás seguro de cancelar tu oferta para ${Formatters.formatPeriodToDisplayName(offer.period)}?\n\n'
          'PDE: ${Formatters.formatNumber(offer.pdePercentageRequested * 100, decimals: 1)}%\n'
          'Precio: ${Formatters.formatCurrency(offer.pricePerKwh, decimals: 0)} COP/kWh',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTokens.primaryRed,
            ),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Mostrar loading
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTokens.primaryRed),
          ),
        ),
      );
    }

    try {
      await _apiService.cancelOffer(offer.id);

      if (mounted) {
        Navigator.pop(context); // Cerrar loading

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Oferta cancelada exitosamente'),
            backgroundColor: AppTokens.energyGreen,
          ),
        );

        // Recargar ofertas
        _loadOffers();
      }
    } on ApiException catch (e) {
      if (mounted) {
        Navigator.pop(context); // Cerrar loading

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✗ Error: ${e.message}'),
            backgroundColor: AppTokens.primaryRed,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Cerrar loading

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✗ Error inesperado: $e'),
            backgroundColor: AppTokens.primaryRed,
          ),
        );
      }
    }
  }

  /// Navega a editar una oferta pendiente
  void _editOffer(ConsumerOffer offer) {
    // Redirigir a ConsumerCreateOfferScreen con los datos de la oferta
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConsumerCreateOfferScreen(
          myUser: widget.myUser,
          communityId: widget.communityId,
          existingOffer: offer, // Pasamos la oferta a editar
        ),
      ),
    ).then((_) {
      // Recargar ofertas al volver
      _loadOffers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
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
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTokens.primaryRed),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTokens.primaryRed,
            ),
            SizedBox(height: AppTokens.space16),
            Text(
              _error!,
              style: context.textStyles.bodyMedium?.copyWith(
                color: AppTokens.primaryRed,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppTokens.space24),
            ElevatedButton(
              onPressed: _loadOffers,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTokens.primaryRed,
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_offers.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadOffers,
      color: AppTokens.primaryRed,
      child: ListView.builder(
        padding: EdgeInsets.all(AppTokens.space16),
        itemCount: _offers.length,
        itemBuilder: (context, index) => _buildOfferCard(_offers[index]),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: AppTokens.space24),
          Text(
            'No tienes ofertas',
            style: context.textStyles.titleLarge?.copyWith(
              color: Colors.grey[700],
              fontWeight: AppTokens.fontWeightBold,
            ),
          ),
          SizedBox(height: AppTokens.space12),
          Text(
            'Crea tu primera oferta de compra P2P',
            style: context.textStyles.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTokens.space32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context); // Volver a la pantalla anterior
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTokens.primaryRed,
              padding: EdgeInsets.symmetric(
                horizontal: AppTokens.space32,
                vertical: AppTokens.space16,
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Crear Oferta'),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(ConsumerOffer offer) {
    return Card(
      margin: EdgeInsets.only(bottom: AppTokens.space16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: AppTokens.borderRadiusLarge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con período y estado
          Container(
            padding: EdgeInsets.all(AppTokens.space16),
            decoration: BoxDecoration(
              color: _getStatusColor(offer.status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppTokens.space16),
                topRight: Radius.circular(AppTokens.space16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Formatters.formatPeriodToDisplayName(offer.period),
                        style: context.textStyles.titleMedium?.copyWith(
                          fontWeight: AppTokens.fontWeightBold,
                        ),
                      ),
                      SizedBox(height: AppTokens.space4),
                      Text(
                        'Creada: ${Formatters.formatDateMedium(offer.createdAt)}',
                        style: context.textStyles.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(offer.status),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.grey[300]),

          // Detalles de la oferta
          Padding(
            padding: EdgeInsets.all(AppTokens.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(
                  icon: Icons.percent,
                  label: 'PDE Solicitado',
                  value: '${Formatters.formatNumber(offer.pdePercentageRequested * 100, decimals: 2)}%',
                  valueColor: AppTokens.primaryRed,
                ),
                SizedBox(height: AppTokens.space12),
                _buildDetailRow(
                  icon: Icons.attach_money,
                  label: 'Precio Ofertado',
                  value: '${Formatters.formatCurrency(offer.pricePerKwh, decimals: 0)} COP/kWh',
                  valueColor: AppTokens.primaryRed,
                ),

                // Mostrar energía calculada si está disponible
                if (offer.energyKwhCalculated != null) ...[
                  SizedBox(height: AppTokens.space12),
                  _buildDetailRow(
                    icon: Icons.flash_on,
                    label: 'Energía Asignada',
                    value: '${Formatters.formatNumber(offer.energyKwhCalculated!, decimals: 2)} kWh',
                    valueColor: AppTokens.primaryRed,
                  ),
                  SizedBox(height: AppTokens.space12),
                  _buildDetailRow(
                    icon: Icons.calculate,
                    label: 'Valor Total',
                    value: Formatters.formatCurrency(
                      offer.energyKwhCalculated! * offer.pricePerKwh,
                      decimals: 0,
                    ),
                    valueColor: AppTokens.primaryRed,
                  ),
                ],

                // Acciones según estado
                if (offer.status == ConsumerOfferStatus.pending) ...[
                  SizedBox(height: AppTokens.space16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _editOffer(offer),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppTokens.primaryRed),
                          ),
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Editar'),
                        ),
                      ),
                      SizedBox(width: AppTokens.space12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _cancelOffer(offer),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppTokens.primaryRed),
                          ),
                          icon: const Icon(Icons.cancel, size: 18),
                          label: const Text('Cancelar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
        ),
        SizedBox(width: AppTokens.space8),
        Expanded(
          child: Text(
            label,
            style: context.textStyles.bodyMedium?.copyWith(
              color: Colors.grey[700],
            ),
          ),
        ),
        Text(
          value,
          style: context.textStyles.bodyMedium?.copyWith(
            fontWeight: AppTokens.fontWeightBold,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(ConsumerOfferStatus status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case ConsumerOfferStatus.pending:
        backgroundColor = Colors.orange.withValues(alpha: 0.2);
        textColor = AppTokens.primaryRed;
        icon = Icons.schedule;
        break;
      case ConsumerOfferStatus.matched:
        backgroundColor = AppTokens.energyGreen.withValues(alpha: 0.2);
        textColor = Colors.green[800]!;
        icon = Icons.check_circle;
        break;
      case ConsumerOfferStatus.partialMatch:
        backgroundColor = Colors.blue.withValues(alpha: 0.2);
        textColor = Colors.blue[800]!;
        icon = Icons.pie_chart;
        break;
      case ConsumerOfferStatus.cancelled:
        backgroundColor = Colors.grey.withValues(alpha: 0.2);
        textColor = Colors.grey[800]!;
        icon = Icons.cancel;
        break;
      case ConsumerOfferStatus.expired:
        backgroundColor = AppTokens.primaryRed.withValues(alpha: 0.2);
        textColor = AppTokens.primaryRed;
        icon = Icons.access_time;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTokens.space12,
        vertical: AppTokens.space8,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppTokens.borderRadiusMedium,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          SizedBox(width: AppTokens.space4),
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: 13,
              fontWeight: AppTokens.fontWeightBold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ConsumerOfferStatus status) {
    switch (status) {
      case ConsumerOfferStatus.pending:
        return Colors.orange;
      case ConsumerOfferStatus.matched:
        return AppTokens.energyGreen;
      case ConsumerOfferStatus.partialMatch:
        return Colors.blue;
      case ConsumerOfferStatus.cancelled:
        return Colors.grey;
      case ConsumerOfferStatus.expired:
        return AppTokens.primaryRed;
    }
  }
}
