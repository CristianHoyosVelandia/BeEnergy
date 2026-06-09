import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/utils/formatters.dart';
import 'package:be_energy/models/models.dart';
import 'package:be_energy/utils/metodos.dart';
import 'package:flutter/material.dart';

class PdeCobroScreen extends StatefulWidget {
  final MyUser myUser;
  final int communityId;
  final String period;
  final String periodDisplayName;
  final bool isAdminView;

  const PdeCobroScreen({
    super.key,
    required this.myUser,
    required this.communityId,
    required this.period,
    required this.periodDisplayName,
    required this.isAdminView,
  });

  @override
  State<PdeCobroScreen> createState() => _PdeCobroScreenState();
}

class _PdeCobroScreenState extends State<PdeCobroScreen> {
  bool _isPaid = false;
  bool _isSubmitting = false;

  final _mockCharge = const _MockPdeCharge(
    amount: 148500,
    energyKwh: 185.6,
    pdeApplied: 0.05,
    previousPeriod: 'Mayo 2026',
    dueDate: '20/06/2026',
  );

  Future<void> _simulatePayment() async {
    setState(() => _isSubmitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _isPaid = true;
      _isSubmitting = false;
    });
    context.showInfoSnackbar('Pago simulado correctamente.');
  }

  Future<void> _closePaymentStage() async {
    setState(() => _isSubmitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: ListView(
        padding: EdgeInsets.all(AppTokens.space16),
        children: [
          if (widget.isAdminView) _buildAdminContent() else _buildUserContent(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      toolbarHeight: 60,
      elevation: 0,
      foregroundColor: Colors.white,
      title: const Text(
        'Cobro PDE',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              blurRadius: 6,
              color: Color(0x4B1A1F24),
              offset: Offset(0, 2),
            )
          ],
          gradient: Metodos.gradientClasic(context),
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildUserContent() {
    return _CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TitleRow(
            icon: Icons.receipt_long,
            title: 'Cobro del periodo',
            subtitle: 'Liquidación ${_mockCharge.previousPeriod}',
          ),
          SizedBox(height: AppTokens.space20),
          _StatusPill(
            label: _isPaid ? 'Pagado' : 'Pendiente',
            color: _isPaid ? AppTokens.energyGreen : AppTokens.energySolar,
          ),
          SizedBox(height: AppTokens.space20),
          _Rows(rows: [
            MapEntry(
                'Valor a pagar', Formatters.formatCurrency(_mockCharge.amount)),
            MapEntry('Energía liquidada',
                Formatters.formatEnergy(_mockCharge.energyKwh)),
            MapEntry('PDE aplicado', _formatPercent(_mockCharge.pdeApplied)),
            MapEntry('Fecha límite', _mockCharge.dueDate),
          ]),
          SizedBox(height: AppTokens.space20),
          Text(
            _isPaid
                ? 'Tu pago quedó registrado visualmente. Cuando exista pasarela se conciliará con backend.'
                : 'Si no realizas el pago, quedarás excluido temporalmente del próximo periodo PDE y tu PDE retornará a la bolsa comunitaria.',
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          SizedBox(height: AppTokens.space24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSubmitting || _isPaid ? null : _simulatePayment,
              style: FilledButton.styleFrom(
                backgroundColor: AppTokens.primaryColor,
                padding: EdgeInsets.symmetric(vertical: AppTokens.space12),
                shape: RoundedRectangleBorder(
                  borderRadius: AppTokens.borderRadiusMedium,
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isPaid ? 'Pago registrado' : 'Simular pago'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminContent() {
    return _CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TitleRow(
            icon: Icons.receipt_long,
            title: 'Gestión de cobros',
            subtitle: widget.periodDisplayName,
          ),
          SizedBox(height: AppTokens.space20),
          _Rows(rows: [
            const MapEntry('Total usuarios', '15'),
            const MapEntry('Pagados', '11'),
            const MapEntry('Pendientes', '4'),
            const MapEntry('Excluidos provisionalmente', '4'),
            MapEntry('Recaudo mock', Formatters.formatCurrency(1633500)),
          ]),
          SizedBox(height: AppTokens.space20),
          Text(
            'Los usuarios que no paguen se excluyen del próximo ciclo PDE hasta ponerse al día. Esta vista es mock hasta integrar pasarela y cron real.',
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          SizedBox(height: AppTokens.space24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSubmitting ? null : _closePaymentStage,
              style: FilledButton.styleFrom(
                backgroundColor: AppTokens.primaryColor,
                padding: EdgeInsets.symmetric(vertical: AppTokens.space12),
                shape: RoundedRectangleBorder(
                  borderRadius: AppTokens.borderRadiusMedium,
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Cerrar cobro y abrir aporte'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPercent(double value) {
    return '${Formatters.formatNumber(value * 100, decimals: 2)}%';
  }
}

class _MockPdeCharge {
  final double amount;
  final double energyKwh;
  final double pdeApplied;
  final String previousPeriod;
  final String dueDate;

  const _MockPdeCharge({
    required this.amount,
    required this.energyKwh,
    required this.pdeApplied,
    required this.previousPeriod,
    required this.dueDate,
  });
}

class _CardContainer extends StatelessWidget {
  final Widget child;

  const _CardContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTokens.space20),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppTokens.borderRadiusLarge,
        border:
            Border.all(color: context.colors.outline.withValues(alpha: 0.12)),
      ),
      child: child,
    );
  }
}

class _TitleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _TitleRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTokens.primaryColor, size: 28),
        SizedBox(width: AppTokens.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.textStyles.titleMedium?.copyWith(
                  fontWeight: AppTokens.fontWeightBold,
                ),
              ),
              SizedBox(height: AppTokens.space4),
              Text(
                subtitle,
                style: context.textStyles.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTokens.space12,
        vertical: AppTokens.space8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppTokens.borderRadiusCircular,
      ),
      child: Text(
        label,
        style: context.textStyles.labelLarge?.copyWith(
          color: color,
          fontWeight: AppTokens.fontWeightBold,
        ),
      ),
    );
  }
}

class _Rows extends StatelessWidget {
  final List<MapEntry<String, String>> rows;

  const _Rows({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: rows
          .map(
            (row) => Padding(
              padding: EdgeInsets.symmetric(vertical: AppTokens.space8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(row.key, style: context.textStyles.bodyMedium),
                  Text(
                    row.value,
                    style: context.textStyles.bodyMedium?.copyWith(
                      fontWeight: AppTokens.fontWeightBold,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
