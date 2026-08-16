import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final bool showLogo;
  final String? subtitle;

  const AuthHeader({
    super.key,
    required this.title,
    this.showLogo = true,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppTokens.space32,
        vertical: AppTokens.space16,
      ),
      child: Row(
        crossAxisAlignment: subtitle == null
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          if (showLogo) ...[
            const Image(
              alignment: AlignmentDirectional.center,
              image: AssetImage('assets/img/logo.png'),
              width: 50,
              height: 50,
            ),
            SizedBox(width: AppTokens.space20),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textStyles.headlineSmall?.copyWith(
                    color: AppTokens.primaryColor,
                    fontWeight: AppTokens.fontWeightBold,
                    letterSpacing: 1.2,
                    height: 1.35,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: AppTokens.space8),
                  Text(
                    subtitle!,
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: AppTokens.grey600,
                      height: 1.35,
                    ),
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
