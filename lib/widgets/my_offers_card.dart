import 'package:flutter/material.dart';
import '../core/theme/app_tokens.dart';
import '../core/extensions/context_extensions.dart';
import '../core/utils/formatters.dart';
import '../models/consumer_offer.dart';

/// Widget que muestra las últimas ofertas del usuario (máximo 3)
///
/// Se muestra en la pantalla principal de ofertas PDE y permite:
/// - Ver un resumen de las últimas 3 ofertas
/// - Navegar a la pantalla de todas las ofertas
/// - Ver el estado de cada oferta (pendiente, confirmada, parcial)
class MyOffersCard extends StatelessWidget {
  final List<ConsumerOffer> offers;
  final VoidCallback onViewAll;

  const MyOffersCard({
    Key? key,
    required this.offers,
    required this.onViewAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (offers.isEmpty) {
      return _buildEmptyState(context);
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16, vertical: AppTokens.space12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTokens.borderRadiusLarge,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(AppTokens.space16),
            child: Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: AppTokens.primaryRed,
                  size: 24,
                ),
                SizedBox(width: AppTokens.space12),
                Expanded(
                  child: Text(
                    'Mis Ofertas de Compra',
                    style: context.textStyles.titleMedium?.copyWith(
                      fontWeight: AppTokens.fontWeightBold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onViewAll,
                  child: Text(
                    'Ver Todas',
                    style: TextStyle(
                      color: AppTokens.primaryRed,
                      fontWeight: AppTokens.fontWeightSemiBold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.grey[300]),

          // Lista de ofertas (máx 3)
          ...offers.take(3).map((offer) => _buildOfferItem(context, offer)),

          // Footer con mensaje si hay más ofertas
          if (offers.length > 3)
            Container(
              padding: EdgeInsets.all(AppTokens.space12),
              decoration: BoxDecoration(
                color: AppTokens.primaryRed.withValues(alpha: 0.05),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppTokens.space16),
                  bottomRight: Radius.circular(AppTokens.space16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppTokens.primaryRed,
                  ),
                  SizedBox(width: AppTokens.space8),
                  Text(
                    'Tienes ${offers.length - 3} ofertas más',
                    style: context.textStyles.bodySmall?.copyWith(
                      color: AppTokens.primaryRed,
                      fontWeight: AppTokens.fontWeightMedium,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16, vertical: AppTokens.space12),
      padding: EdgeInsets.all(AppTokens.space24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTokens.borderRadiusLarge,
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          SizedBox(height: AppTokens.space12),
          Text(
            'No tienes ofertas',
            style: context.textStyles.titleSmall?.copyWith(
              color: Colors.grey[700],
              fontWeight: AppTokens.fontWeightSemiBold,
            ),
          ),
          SizedBox(height: AppTokens.space8),
          Text(
            'Crea tu primera oferta de compra P2P',
            style: context.textStyles.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOfferItem(BuildContext context, ConsumerOffer offer) {
    return InkWell(
      onTap: () => onViewAll(), // Por ahora navega a ver todas
      child: Container(
        padding: EdgeInsets.all(AppTokens.space16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con período y estado
            Row(
              children: [
                Expanded(
                  child: Text(
                    Formatters.formatPeriodToDisplayName(offer.period),
                    style: context.textStyles.bodyMedium?.copyWith(
                      fontWeight: AppTokens.fontWeightSemiBold,
                    ),
                  ),
                ),
                _buildStatusBadge(context, offer.status),
              ],
            ),

            SizedBox(height: AppTokens.space12),

            // Detalles de la oferta
            Row(
              children: [
                Expanded(
                  child: _buildDetailChip(
                    context,
                    icon: Icons.percent,
                    label: 'PDE',
                    value: '${Formatters.formatNumber(offer.pdePercentageRequested * 100, decimals: 1)}%',
                  ),
                ),
                SizedBox(width: AppTokens.space8),
                Expanded(
                  child: _buildDetailChip(
                    context,
                    icon: Icons.attach_money,
                    label: 'Precio',
                    value: Formatters.formatCurrency(offer.pricePerKwh, decimals: 0),
                  ),
                ),
              ],
            ),

            // Info adicional según estado
            if (offer.status == ConsumerOfferStatus.matched ||
                offer.status == ConsumerOfferStatus.partialMatch) ...[
              SizedBox(height: AppTokens.space12),
              Container(
                padding: EdgeInsets.all(AppTokens.space8),
                decoration: BoxDecoration(
                  color: AppTokens.energyGreen.withValues(alpha: 0.1),
                  borderRadius: AppTokens.borderRadiusMedium,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: AppTokens.energyGreen,
                    ),
                    SizedBox(width: AppTokens.space8),
                    Expanded(
                      child: Text(
                        offer.energyKwhCalculated != null
                            ? 'Energía asignada: ${Formatters.formatNumber(offer.energyKwhCalculated!, decimals: 2)} kWh'
                            : 'Oferta confirmada',
                        style: context.textStyles.bodySmall?.copyWith(
                          color: AppTokens.energyGreen,
                          fontWeight: AppTokens.fontWeightMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTokens.space12,
        vertical: AppTokens.space8,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: AppTokens.borderRadiusMedium,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[700],
          ),
          SizedBox(width: AppTokens.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: AppTokens.fontWeightBold,
                    color: Colors.grey[900],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, ConsumerOfferStatus status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case ConsumerOfferStatus.pending:
        backgroundColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange;
        icon = Icons.schedule;
        break;
      case ConsumerOfferStatus.matched:
        backgroundColor = AppTokens.energyGreen.withValues(alpha: 0.1);
        textColor = AppTokens.energyGreen;
        icon = Icons.check_circle;
        break;
      case ConsumerOfferStatus.partialMatch:
        backgroundColor = Colors.blue.withValues(alpha: 0.1);
        textColor = Colors.blue;
        icon = Icons.pie_chart;
        break;
      case ConsumerOfferStatus.cancelled:
        backgroundColor = Colors.grey.withValues(alpha: 0.1);
        textColor = Colors.grey;
        icon = Icons.cancel;
        break;
      case ConsumerOfferStatus.expired:
        backgroundColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red;
        icon = Icons.access_time;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTokens.space8,
        vertical: AppTokens.space4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppTokens.borderRadiusMedium,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          SizedBox(width: AppTokens.space4),
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: AppTokens.fontWeightSemiBold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
