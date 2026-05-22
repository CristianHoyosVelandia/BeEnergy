import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/utils/formatters.dart';
import 'package:be_energy/models/community_price_reference.dart';
import 'package:flutter/material.dart';

class PriceReferenceCards extends StatelessWidget {
  final List<CommunityPriceReference> prices;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;

  const PriceReferenceCards({
    super.key,
    required this.prices,
    required this.isLoading,
    this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: AppTokens.space12),
            child: Text(
              'Precios de referencia',
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
            child: _buildContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Row(
        children: [
          Icon(Icons.info_outline, color: context.colors.onSurfaceVariant),
          SizedBox(width: AppTokens.space8),
          Expanded(
            child: Text(
              'No fue posible cargar los precios.',
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
        ],
      );
    }

    if (prices.isEmpty) {
      // Si aun no hay registros SQL para el periodo, ocultamos valores inventados.
      return Text(
        'Sin precios configurados para este periodo.',
        style: context.textStyles.bodyMedium?.copyWith(
          color: context.colors.onSurfaceVariant,
        ),
      );
    }

    return Column(
      children: prices.asMap().entries.map((entry) {
        final i = entry.key;
        final price = entry.value;
        return Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  price.label,
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ),
              SizedBox(width: AppTokens.space12),
              Text(
                '${Formatters.formatCurrency(price.value, decimals: 0)} COP/kWh',
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
    );
  }
}
