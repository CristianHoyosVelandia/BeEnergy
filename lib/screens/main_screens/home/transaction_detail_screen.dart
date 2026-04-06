import 'package:flutter/material.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/utils/formatters.dart';
import 'package:be_energy/utils/metodos.dart';
import '../../../data/fake_data_phase2.dart';

/// Pantalla de detalle de una transacción PDE – Enero 2026
/// Muestra toda la información económica y energética del consumidor k₁
class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final energyRecord = FakeDataPhase2.crisDec2025;
    final pde = FakeDataPhase2.pdeDec2025;
    final liquidation = FakeDataPhase2.anaLiquidation;
    final consumer = FakeDataPhase2.cristianHoyos;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context, consumer.userName, consumer.userLastName),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Espacio para el AppBar con gradiente
            SizedBox(height: MediaQuery.of(context).padding.top + 70),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppTokens.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Energía ──────────────────────────────────────────
                  _sectionTitle(context, 'Energía'),
                  SizedBox(height: AppTokens.space12),
                  _dataCard(context, [
                    _row(context, 'Energía importada desde la red',
                        Formatters.formatEnergy(energyRecord.energyImported), ' kWh/mes'),
                    _row(context, 'Energía exportada a la red',
                        Formatters.formatEnergy(energyRecord.energyExported), ' kWh/mes'),
                  ]),

                  SizedBox(height: AppTokens.space20),

                  // ── PDE ──────────────────────────────────────────────
                  _sectionTitle(context, 'PDE – Distribución de Excedentes'),
                  SizedBox(height: AppTokens.space12),
                  _dataCard(context, [
                    _row(context, 'Participación en el PDE',
                        Formatters.formatNumber(pde.sharePercentage * 100, decimals: 2), '%'),
                    _row(context, 'Energía asignada por PDE',
                        Formatters.formatEnergy(pde.allocatedEnergy), ' kWh/mes'),
                    _row(context, 'Excedentes Tipo 1 por PDE',
                        Formatters.formatEnergy(energyRecord.surplusType1), ' kWh/mes'),
                    _row(context, 'Excedentes Tipo 2 por PDE',
                        Formatters.formatEnergy(energyRecord.surplusType2), ' kWh/mes'),
                  ]),

                  SizedBox(height: AppTokens.space20),

                  // ── Mercado P2P ───────────────────────────────────────
                  _sectionTitle(context, 'Mercado P2P'),
                  SizedBox(height: AppTokens.space12),
                  _dataCard(context, [
                    _row(context, 'Rol en el mercado P2P',
                        'Comprador', ''),
                    _row(context, 'Precio de transacción P2P',
                        '\$${Formatters.formatNumber(FakeDataPhase2.precioP2P.toInt())}', ' COP/kWh'),
                  ]),

                  SizedBox(height: AppTokens.space20),

                  // ── Económico ─────────────────────────────────────────
                  _sectionTitle(context, 'Económico'),
                  SizedBox(height: AppTokens.space12),
                  _dataCard(context, [
                    _row(context, 'Costo P2P mensual',
                        '–\$${Formatters.formatNumber((liquidation['p2pCost'] as double).toInt())}', ' COP',
                        isNegative: true),
                    _row(context, 'Valor económico mensual (VE)',
                        '\$${Formatters.formatNumber((liquidation['veMensual'] as double).toInt())}', ' COP',
                        isNegative: false),
                  ]),

                  SizedBox(height: AppTokens.space12),

                  // Valor Final destacado
                  _valorFinalCard(context, liquidation['valorFinal'] as double),

                  SizedBox(height: AppTokens.space32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── AppBar con gradiente ────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context, String nombre, String apellido) {
    return AppBar(
      toolbarHeight: 60,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: Metodos.gradientClasic(context),
        ),
      ),
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalle Transacción',
            style: context.textStyles.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: AppTokens.fontWeightBold,
            ),
          ),
          Text(
            '$nombre $apellido',
            style: context.textStyles.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Título de sección ───────────────────────────────────────────────────
  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: context.textStyles.titleSmall?.copyWith(
        fontWeight: AppTokens.fontWeightSemiBold,
        color: context.colors.onSurface,
      ),
    );
  }

  // ─── Tarjeta de datos (lista de filas) ───────────────────────────────────
  Widget _dataCard(BuildContext context, List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppTokens.borderRadiusMedium,
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i < rows.length - 1)
              Divider(height: 1, color: context.colors.outline.withValues(alpha: 0.1)),
          ],
        ],
      ),
    );
  }

  // ─── Fila label / valor ──────────────────────────────────────────────────
  Widget _row(BuildContext context, String label, String value, String suffix,
      {bool isNegative = false}) {
    final valueColor = isNegative ? AppTokens.error : context.colors.onSurface;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppTokens.space16,
        vertical: AppTokens.space12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          Text(
            '$value$suffix',
            style: context.textStyles.bodyMedium?.copyWith(
              fontWeight: AppTokens.fontWeightSemiBold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Tarjeta VF destacada ────────────────────────────────────────────────
  Widget _valorFinalCard(BuildContext context, double valorFinal) {
    final isNegative = valorFinal < 0;
    final absValue = valorFinal.abs().toInt();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTokens.space20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isNegative
              ? [AppTokens.primaryRed, AppTokens.primaryRed.withValues(alpha: 0.75)]
              : [AppTokens.energyGreen, AppTokens.energyGreen.withValues(alpha: 0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppTokens.borderRadiusLarge,
        boxShadow: [
          BoxShadow(
            color: (isNegative ? AppTokens.primaryRed : AppTokens.energyGreen)
                .withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Valor Final del mes (VF)',
            style: context.textStyles.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          SizedBox(height: AppTokens.space8),
          Text(
            '${isNegative ? '–' : '+'}  \$${Formatters.formatNumber(absValue)}',
            style: context.textStyles.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: AppTokens.fontWeightBold,
            ),
          ),
          SizedBox(height: AppTokens.space4),
          Text(
            'COP',
            style: context.textStyles.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
