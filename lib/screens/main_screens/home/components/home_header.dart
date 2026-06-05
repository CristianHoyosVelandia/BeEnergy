import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final String title;
  final String periodLabel;
  final String membersLabel;

  const HomeHeader({
    super.key,
    required this.title,
    required this.periodLabel,
    required this.membersLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width,
      padding: EdgeInsets.symmetric(
        horizontal: AppTokens.space16,
        vertical: AppTokens.space12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.textStyles.titleLarge?.copyWith(
              fontWeight: AppTokens.fontWeightBold,
            ),
          ),
          SizedBox(height: AppTokens.space4),
          Text(
            '$periodLabel • $membersLabel',
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
