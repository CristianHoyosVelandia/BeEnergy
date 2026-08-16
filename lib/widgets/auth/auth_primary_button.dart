import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

class AuthPrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppTokens.space32,
        vertical: AppTokens.space16,
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTokens.primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              AppTokens.primaryColor.withValues(alpha: 0.55),
          padding: EdgeInsets.symmetric(vertical: AppTokens.space16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 4,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                label,
                style: context.textStyles.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: AppTokens.fontWeightBold,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}
