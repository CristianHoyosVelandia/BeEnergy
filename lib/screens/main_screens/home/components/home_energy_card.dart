import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/utils/formatters.dart';
import 'package:flutter/material.dart';

class HomeEnergyCard extends StatelessWidget {
  final String title;
  final double energy;
  final double amount;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final bool hideAmount;

  const HomeEnergyCard({
    super.key,
    required this.title,
    required this.energy,
    required this.amount,
    required this.icon,
    required this.color,
    this.subtitle,
    this.hideAmount = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTokens.space12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppTokens.borderRadiusMedium,
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppTokens.space8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: AppTokens.borderRadiusSmall,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          SizedBox(width: AppTokens.space12),
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
                    subtitle!,
                    style: context.textStyles.labelSmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                      fontSize: AppTokens.fontSize10,
                    ),
                  ),
                ],
                SizedBox(height: AppTokens.space4),
                Text(
                  Formatters.formatEnergy(energy, decimals: 2),
                  style: context.textStyles.titleMedium?.copyWith(
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
}
