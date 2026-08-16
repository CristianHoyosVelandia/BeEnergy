import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

class AuthFooterLink extends StatelessWidget {
  final String text;
  final String actionText;
  final VoidCallback onTap;

  const AuthFooterLink({
    super.key,
    required this.text,
    required this.actionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppTokens.space24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: context.textStyles.bodyLarge?.copyWith(
              color: AppTokens.grey600,
            ),
          ),
          SizedBox(width: AppTokens.space8),
          InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: onTap,
            child: Text(
              actionText,
              style: context.textStyles.titleMedium?.copyWith(
                color: AppTokens.primaryColor,
                fontWeight: AppTokens.fontWeightBold,
                decoration: TextDecoration.underline,
                decorationColor: AppTokens.primaryColor,
                decorationThickness: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
