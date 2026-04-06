import 'package:flutter/material.dart';
import '../core/theme/app_tokens.dart';
import '../core/utils/formatters.dart';

/// Widget indicador de PDE (Porcentaje de Distribución de Excedentes)
///
/// Muestra el porcentaje del PDE de forma visual y legible:
/// "15% del PDE (≈ 10.5 kWh)"
///
/// Uso:
/// ```dart
/// PDEIndicator(
///   percentage: 0.15, // 15%
///   totalPDEAvailable: 70.0, // 70 kWh disponibles
/// )
/// ```
class PDEIndicator extends StatelessWidget {
  /// Porcentaje del PDE (0.0 - 1.0)
  /// Ejemplo: 0.15 = 15%
  final double percentage;

  /// Total de PDE disponible en kWh
  final double totalPDEAvailable;

  /// Modo de visualización
  final PDEIndicatorMode mode;

  /// Color personalizado (opcional)
  final Color? customColor;

  /// Mostrar tooltip explicativo
  final bool showTooltip;

  const PDEIndicator({
    super.key,
    required this.percentage,
    required this.totalPDEAvailable,
    this.mode = PDEIndicatorMode.full,
    this.customColor,
    this.showTooltip = false,
  });

  @override
  Widget build(BuildContext context) {
    final kwh = percentage * totalPDEAvailable;
    final percentageText = '${Formatters.formatNumber(percentage * 100, decimals: 1)}%';
    final kwhText = '≈ ${Formatters.formatNumber(kwh, decimals: 2)} kWh';

    final color = customColor ?? AppTokens.primaryRed;

    Widget content;

    switch (mode) {
      case PDEIndicatorMode.compact:
        content = _buildCompactMode(percentageText, kwhText, color);
        break;
      case PDEIndicatorMode.full:
        content = _buildFullMode(percentageText, kwhText, color);
        break;
      case PDEIndicatorMode.minimal:
        content = _buildMinimalMode(percentageText, color);
        break;
    }

    if (showTooltip) {
      return Tooltip(
        message: _getTooltipMessage(),
        child: content,
      );
    }

    return content;
  }

  /// Modo compacto: texto inline
  Widget _buildCompactMode(String percentageText, String kwhText, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$percentageText del PDE ',
          style: TextStyle(
            fontWeight: AppTokens.fontWeightSemiBold,
            color: color,
          ),
        ),
        Text(
          '($kwhText)',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// Modo completo: con indicador visual circular
  Widget _buildFullMode(String percentageText, String kwhText, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Indicador circular
        SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            children: [
              CircularProgressIndicator(
                value: percentage.clamp(0.0, 1.0),
                strokeWidth: 3,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
              Center(
                child: Text(
                  percentageText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: AppTokens.fontWeightBold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: AppTokens.space12),
        // Texto
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$percentageText del PDE',
              style: TextStyle(
                fontWeight: AppTokens.fontWeightSemiBold,
                color: color,
              ),
            ),
            Text(
              kwhText,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Modo mínimo: solo porcentaje
  Widget _buildMinimalMode(String percentageText, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTokens.space12,
        vertical: AppTokens.space8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppTokens.borderRadiusMedium,
        border: Border.all(color: color),
      ),
      child: Text(
        '$percentageText del PDE',
        style: TextStyle(
          fontWeight: AppTokens.fontWeightBold,
          color: color,
        ),
      ),
    );
  }

  String _getTooltipMessage() {
    return 'El Programa de Distribución de Excedentes (PDE) es el 10% '
        'del excedente Tipo 2 que se distribuye según CREG 101 072 Art 3.4. '
        'En Enero 2026, puedes solicitar un % de este PDE especificando '
        'cuánto estás dispuesto a pagar.';
  }
}

/// Modos de visualización del indicador
enum PDEIndicatorMode {
  /// Compacto: solo texto inline
  compact,

  /// Completo: con indicador circular y texto
  full,

  /// Mínimo: solo porcentaje en badge
  minimal,
}

/// Widget para mostrar resumen de PDE disponible
class PDEAvailabilitySummary extends StatelessWidget {
  final double totalPDEAvailable;
  final String period;
  final bool showHelp;

  const PDEAvailabilitySummary({
    super.key,
    required this.totalPDEAvailable,
    required this.period,
    this.showHelp = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTokens.primaryRed,
            AppTokens.primaryRed.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppTokens.borderRadiusLarge,
        boxShadow: [
          BoxShadow(
            color: AppTokens.primaryPurple.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt, color: Colors.white, size: 28),
              SizedBox(width: AppTokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PDE Disponible',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      period,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (showHelp)
                IconButton(
                  icon: const Icon(Icons.help_outline, color: Colors.white),
                  onPressed: () => _showPDEHelp(context),
                ),
            ],
          ),
          SizedBox(height: AppTokens.space16),
          
          // Container(
          //   padding: EdgeInsets.all(AppTokens.space16),
          //   decoration: BoxDecoration(
          //     color: Colors.white.withValues(alpha: 0.2),
          //     borderRadius: AppTokens.borderRadiusMedium,
          //   ),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       Text(
          //         '${Formatters.formatNumber(totalPDEAvailable, decimals: 2)} kWh',
          //         style: const TextStyle(
          //           color: Colors.white,
          //           fontSize: 32,
          //           fontWeight: FontWeight.bold,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          
          SizedBox(height: AppTokens.space8),
          Text(
            'Hasta un máximo del 10 % disponible',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showPDEHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: AppTokens.primaryPurple),
            SizedBox(width: 12),
            Text('¿Qué es el PDE?'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'El Programa de Distribución de Excedentes (PDE) es el 10% '
              'del excedente Tipo 2 que se distribuye solidariamente según '
              'CREG 101 072 Art 3.4.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Text(
              'En Enero 2026, como consumidor puedes:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Solicitar un % del PDE disponible'),
            Text('• Especificar cuánto estás dispuesto a pagar'),
            Text('• Esperar la liquidación del administrador'),
            SizedBox(height: 16),
            Text(
              'Nota: En Diciembre 2025 el PDE era gratis. Ahora se paga según tu oferta.',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
