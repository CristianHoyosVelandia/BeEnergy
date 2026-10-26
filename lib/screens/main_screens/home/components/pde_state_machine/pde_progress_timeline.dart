import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/widgets/app_info_dialog.dart';
import 'package:flutter/material.dart';

class PdeProgressTimeline extends StatelessWidget {
  final int currentStatus;
  final bool onDark;
  final Map<int, bool> enabledSteps;
  final String periodDisplayName;

  const PdeProgressTimeline({
    super.key,
    required this.currentStatus,
    this.onDark = true,
    this.enabledSteps = const {},
    this.periodDisplayName = '',
  });

  @override
  Widget build(BuildContext context) {
    const allSteps = [
      MapEntry(6, 'Aporte'),
      MapEntry(1, 'Disponible'),
      MapEntry(2, 'Cerrado'),
      MapEntry(3, 'Asignado'),
      MapEntry(4, 'Conciliación'),
      MapEntry(7, 'Cobro'),
      MapEntry(5, 'Histórico'),
    ];
    final steps = allSteps;
    if (steps.isEmpty) {
      return const SizedBox.shrink();
    }
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
    showAppInfoDialog(
      context: context,
      title: title,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _stepSchedule(statusCode),
            style: context.textStyles.bodyMedium?.copyWith(
              color: AppTokens.primaryColor,
              fontWeight: AppTokens.fontWeightBold,
            ),
          ),
          SizedBox(height: AppTokens.space12),
          Text(
            _stepExplanation(statusCode),
            style: context.textStyles.bodyMedium?.copyWith(
              color: AppTokens.grey700,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  String _stepSchedule(int statusCode) {
    final month = periodDisplayName.trim().isEmpty
        ? 'del mes actual'
        : 'de $periodDisplayName';
    switch (statusCode) {
      case 6:
        return 'Aporte del 5 al 8 $month';
      case 1:
        return 'Disponible del 9 al 11 $month';
      case 2:
        return 'Cerrado el 12 $month';
      case 3:
        return 'Asignado del 13 al 15 $month';
      case 4:
        return 'Conciliación del 15 al 25 $month';
      case 7:
        return 'Cobro del 25 al 30 $month';
      case 5:
        return 'Histórico del 1 al 4 de ${_nextMonthName()}';
      default:
        return 'Periodo $month';
    }
  }

  String _nextMonthName() {
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    final normalized = periodDisplayName.trim().toLowerCase();
    final index = months.indexWhere(
      (month) => normalized.contains(month.toLowerCase()),
    );
    if (index == -1) return 'el mes siguiente';
    return months[(index + 1) % months.length];
  }

  String _stepExplanation(int statusCode) {
    switch (statusCode) {
      case 7:
        return 'Cobro del periodo. Aquí se revisa el valor pendiente o a favor del ciclo PDE.';
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
