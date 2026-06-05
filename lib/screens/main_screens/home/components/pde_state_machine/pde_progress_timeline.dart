import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

class PdeProgressTimeline extends StatelessWidget {
  final int currentStatus;
  final bool onDark;

  const PdeProgressTimeline({
    super.key,
    required this.currentStatus,
    this.onDark = true,
  });

  @override
  Widget build(BuildContext context) {
    const steps = [
      MapEntry(1, 'Disponible'),
      MapEntry(2, 'Cerrado'),
      MapEntry(3, 'Asignado'),
      MapEntry(4, 'Conciliación'),
      MapEntry(5, 'Histórico'),
    ];
    final baseColor = onDark ? Colors.white : AppTokens.primaryColor;
    final mutedColor =
        onDark ? Colors.white.withValues(alpha: 0.55) : AppTokens.grey500;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTokens.space12),
      decoration: BoxDecoration(
        color: onDark
            ? Colors.white.withValues(alpha: 0.12)
            : AppTokens.primaryColor.withValues(alpha: 0.06),
        borderRadius: AppTokens.borderRadiusMedium,
        border: Border.all(
          color: onDark
              ? Colors.white.withValues(alpha: 0.18)
              : AppTokens.primaryColor.withValues(alpha: 0.16),
        ),
      ),
      child: Wrap(
        spacing: AppTokens.space8,
        runSpacing: AppTokens.space8,
        children: steps.map((step) {
          final isCurrent = step.key == currentStatus;
          final isDone = step.key < currentStatus;

          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppTokens.space8,
              vertical: AppTokens.space4,
            ),
            decoration: BoxDecoration(
              color: isCurrent ? baseColor.withValues(alpha: 0.22) : null,
              borderRadius: AppTokens.borderRadiusCircular,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isDone
                      ? Icons.check_circle
                      : isCurrent
                          ? Icons.radio_button_checked
                          : Icons.circle_outlined,
                  color: isCurrent || isDone ? baseColor : mutedColor,
                  size: 14,
                ),
                SizedBox(width: AppTokens.space4),
                Text(
                  step.value,
                  style: context.textStyles.bodySmall?.copyWith(
                    color: isCurrent || isDone ? baseColor : mutedColor,
                    fontWeight: isCurrent
                        ? AppTokens.fontWeightBold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
