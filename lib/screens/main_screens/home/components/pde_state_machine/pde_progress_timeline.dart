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
      MapEntry(7, 'Cobro'),
      MapEntry(6, 'Aporte'),
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
          final currentIndex =
              steps.indexWhere((item) => item.key == currentStatus);
          final stepIndex = steps.indexOf(step);
          final isCurrent = step.key == currentStatus;
          final isDone = currentIndex != -1 && stepIndex < currentIndex;

          return InkWell(
            borderRadius: AppTokens.borderRadiusCircular,
            onTap: () => _showStepExplanation(context, step.key, step.value),
            child: Container(
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
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showStepExplanation(
      BuildContext context, int statusCode, String title) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: AppTokens.borderRadiusLarge),
        title: Text(title),
        content: Text(_stepExplanation(statusCode)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  String _stepExplanation(int statusCode) {
    switch (statusCode) {
      case 7:
        return 'Cobro del periodo anterior. Aquí se revisa el valor pendiente antes de continuar con el ciclo PDE.';
      case 6:
        return 'Aporte comunitario. El usuario puede liberar parte del PDE asignado para que la comunidad lo use nuevamente.';
      case 1:
        return 'PDE disponible. La comunidad puede crear ofertas para solicitar energía del periodo abierto.';
      case 2:
        return 'Periodo cerrado. Ya no se reciben ofertas nuevas y se prepara la asignación del PDE.';
      case 3:
        return 'Asignado. Las ofertas fueron procesadas y el PDE quedó distribuido entre los participantes.';
      case 4:
        return 'Conciliación. La información está pendiente de validación con el comercializador.';
      case 5:
        return 'Histórico. El periodo ya terminó y queda disponible solo para consulta de resultados.';
      default:
        return 'Estado del proceso PDE.';
    }
  }
}
