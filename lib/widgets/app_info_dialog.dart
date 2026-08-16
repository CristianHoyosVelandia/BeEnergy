import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

Future<void> showAppInfoDialog({
  required BuildContext context,
  required String title,
  String? message,
  Widget? content,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AppInfoDialog(
      title: title,
      message: message,
      content: content,
    ),
  );
}

class AppInfoDialog extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? content;

  const AppInfoDialog({
    super.key,
    required this.title,
    this.message,
    this.content,
  }) : assert(message != null || content != null);

  @override
  Widget build(BuildContext context) {
    final brandColor = AppTokens.primaryColor;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: AppTokens.space32),
      shape: RoundedRectangleBorder(borderRadius: AppTokens.borderRadiusLarge),
      backgroundColor: context.colors.surface,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppTokens.space24,
          AppTokens.space16,
          AppTokens.space16,
          AppTokens.space24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: AppTokens.space8),
                  child: _DialogBrandMark(color: brandColor),
                ),
                SizedBox(width: AppTokens.space12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: AppTokens.space8,
                      right: AppTokens.space12,
                    ),
                    child: Text(
                      title,
                      style: context.textStyles.titleLarge?.copyWith(
                        color: AppTokens.grey900,
                        fontWeight: AppTokens.fontWeightBold,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Cerrar',
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Icons.close_rounded,
                    color: brandColor,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            SizedBox(height: AppTokens.space16),
            if (content != null)
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.55,
                ),
                child: SingleChildScrollView(child: content!),
              )
            else
              Text(
                message!,
                style: context.textStyles.bodyMedium?.copyWith(
                  color: AppTokens.grey700,
                  height: 1.45,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DialogBrandMark extends StatelessWidget {
  final Color color;

  const _DialogBrandMark({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Image.asset(
        'assets/img/logo.png',
        fit: BoxFit.contain,
        color: color,
        colorBlendMode: BlendMode.srcIn,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.energy_savings_leaf_rounded,
          color: color,
          size: 30,
        ),
      ),
    );
  }
}
