import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/utils/formatters.dart';
import 'package:be_energy/models/models.dart';
import 'package:be_energy/services/pde_cobro_service.dart';
import 'package:be_energy/utils/metodos.dart';
import 'package:flutter/material.dart';

import 'pde_savings_screen.dart';

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
  final PdeCobroService _cobroService = PdeCobroService();

  bool _isPaid = false;
  bool _isSubmitting = false;
  bool _isLoading = true;
  String? _errorMessage;
  PdeCobroResumen? _charge;

  @override
  void initState() {
    super.initState();
    _loadCharge();
  }

  Future<void> _loadCharge() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final charge = await _cobroService.getResumen(
        communityId: widget.communityId,
        period: widget.period,
      );
      if (!mounted) return;
      setState(() {
        _charge = charge;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

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
        'Cobro',
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
            title: _screenTitle,
            subtitle: 'Liquidación ${widget.periodDisplayName}',
            trailing: _charge?.hasCommunityRight == true
                ? IconButton(
                    tooltip: 'Ver ahorros',
                    onPressed: _openSavings,
                    icon: const Icon(Icons.add_circle_outline),
                    color: AppTokens.primaryColor,
                  )
                : null,
          ),
          SizedBox(height: AppTokens.space20),
          _StatusPill(
            label: _statusLabel,
            color: _statusColor,
          ),
          SizedBox(height: AppTokens.space20),
          _buildBodyState(),
          SizedBox(height: AppTokens.space20),
          if (!_isLoading && _errorMessage == null) _buildMessage(),
          SizedBox(height: AppTokens.space24),
          if (_charge?.hasMovement == true) _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildBodyState() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No se pudo cargar el resumen PDE.',
            style: context.textStyles.bodyMedium?.copyWith(
              color: AppTokens.error,
              fontWeight: AppTokens.fontWeightBold,
            ),
          ),
          SizedBox(height: AppTokens.space8),
          Text(
            _errorMessage!,
            style: context.textStyles.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppTokens.space12),
          OutlinedButton(
            onPressed: _loadCharge,
            child: const Text('Reintentar'),
          ),
        ],
      );
    }

    final charge = _charge;
    if (charge == null) {
      return Text(
        'No tienes cobros ni compensaciones PDE para este periodo.',
        style: context.textStyles.bodyMedium?.copyWith(
          color: context.colors.onSurfaceVariant,
          height: 1.35,
        ),
      );
    }

    if (!charge.hasMovement && !charge.hasCommunityRight) {
      return Text(
        'No tienes cobros ni compensaciones PDE para este periodo.',
        style: context.textStyles.bodyMedium?.copyWith(
          color: context.colors.onSurfaceVariant,
          height: 1.35,
        ),
      );
    }

    if (charge.hasCommunityRight) {
      return _CommunityRightSummary(
        charge: charge,
        formatPercentValue: _formatPercentValue,
        onExplain: _showCommunityRightExplanation,
      );
    }

    final rows = <MapEntry<String, String>>[];
    if (charge.hasMovement) {
      final amountLabel = charge.isCredit ? 'Valor a recibir' : 'Valor a pagar';
      final pdeLabel = charge.isCredit ? 'PDE cedido' : 'PDE comprado';
      final energyLabel =
          charge.isCredit ? 'Energía cedida' : 'Energía entregada';

      rows.addAll([
        MapEntry(amountLabel, Formatters.formatCurrency(charge.amount)),
        MapEntry(energyLabel,
            Formatters.formatEnergy(charge.energyKwh, decimals: 2)),
        if (!charge.hasCommunityRight)
          MapEntry('PDE aplicado', _formatPercentValue(charge.pdeAppliedPct)),
        MapEntry(pdeLabel, _formatPercentValue(charge.pdeTransactedPct)),
        MapEntry('Precio energía comunitaria',
            '${Formatters.formatCurrency(charge.pricePerKwh)} / kWh'),
      ]);
    }

    return _Rows(rows: rows);
  }

  void _showCommunityRightExplanation() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: AppTokens.borderRadiusLarge),
        title: const Text('Cómo se calcula'),
        content: const Text(
          'Tu derecho comunitario es el PDE base que recibes sin costo por la generación comunitaria. Si usas más PDE que tu derecho, pagas solo ese excedente. Si cedes parte de tu derecho, recibes compensación por la diferencia.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _openSavings() {
    final charge = _charge;
    if (charge == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdeSavingsScreen(
          charge: charge,
          periodDisplayName: widget.periodDisplayName,
        ),
      ),
    );
  }

  Widget _buildMessage() {
    final charge = _charge;
    final textStyle = context.textStyles.bodyMedium?.copyWith(
      color: context.colors.onSurfaceVariant,
      height: 1.35,
    );

    if (charge == null || (!charge.hasMovement && !charge.hasCommunityRight)) {
      return Text(
        'Cuando tengas una compra o cesión PDE liquidada, el detalle aparecerá en esta sección.',
        style: textStyle,
      );
    }

    if (charge.hasCommunityRight) {
      if (!charge.hasMovement) {
        return Text(
          'Tu PDE base proviene de generación comunitaria y se reconoce como derecho comunitario sin cobro. En este periodo no tienes diferencias por pagar o recibir.',
          style: textStyle,
        );
      }
      if (charge.shouldReceive || charge.isCredit) {
        return Text(
          'Tu PDE base por derecho comunitario no se cobra. La compensación corresponde únicamente a la diferencia que cediste a la comunidad.',
          style: textStyle,
        );
      }
      return Text(
        'Tu PDE base por derecho comunitario no se cobra. El valor pendiente corresponde solo a la diferencia adicional recibida frente a tu derecho base.',
        style: textStyle,
      );
    }

    if (charge.isCommunityManagement) {
      return Text(
        'Gestión comunitaria solidaria: este valor se verá reflejado como un ingreso / egreso adicional en su cuota de administración.',
        style: textStyle,
      );
    }

    if (charge.isCredit) {
      return Text(
        'Tus aportes generaron ${Formatters.formatCurrency(charge.amount)} para la comunidad. Estos valores serán gestionados próximamente según el proceso comunitario.',
        style: textStyle,
      );
    }

    return Text(
      _isPaid
          ? 'Tu pago quedó registrado visualmente. La conciliación real se habilitará cuando se integre la pasarela de pago.'
          : 'Este valor corresponde a la energía comunitaria PDE que recibiste en la liquidación del periodo. El pago real queda pendiente hasta integrar la pasarela.',
      style: textStyle,
    );
  }

  Widget _buildActionButton() {
    final charge = _charge;
    final pendingText =
        charge?.shouldReceive == true || charge?.isCredit == true
            ? 'Registrar compensación visual'
            : 'Simular pago';
    final paidText = charge?.shouldReceive == true || charge?.isCredit == true
        ? 'Compensación registrada'
        : 'Pago registrado';

    return SizedBox(
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
            : Text(_isPaid ? paidText : pendingText),
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

  String get _screenTitle {
    final charge = _charge;
    if (charge?.isCommunityManagement == true) {
      return 'Gestión comunitaria';
    }
    if (charge?.hasCommunityRight == true) {
      return 'Energía Cooperativa';
    }
    if (charge?.isCredit == true) {
      return 'Compensación PDE';
    }
    return 'Cobro del periodo';
  }

  String get _statusLabel {
    if (_isLoading) return 'Cargando';
    if (_errorMessage != null) return 'Error';
    final charge = _charge;
    if (charge == null || (!charge.hasMovement && !charge.hasCommunityRight)) {
      return 'Sin movimientos';
    }
    if (!charge.hasMovement && charge.hasCommunityRight) {
      return 'Sin diferencia';
    }
    if (charge.isCredit) return _isPaid ? 'Compensación registrada' : 'A favor';
    return _isPaid ? 'Pagado' : 'Pendiente';
  }

  Color get _statusColor {
    if (_errorMessage != null) return AppTokens.error;
    final charge = _charge;
    if (charge == null || (!charge.hasMovement && !charge.hasCommunityRight)) {
      return context.colors.outline;
    }
    if (!charge.hasMovement && charge.hasCommunityRight) {
      return AppTokens.energyGreen;
    }
    if (_isPaid || charge.isCredit) return AppTokens.energyGreen;
    return AppTokens.energySolar;
  }

  String _formatPercentValue(double value) {
    return '${Formatters.formatNumber(value, decimals: 2)}%';
  }
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
  final Widget? trailing;

  const _TitleRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
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
        if (trailing != null) trailing!,
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

class _CommunityRightSummary extends StatelessWidget {
  final PdeCobroResumen charge;
  final String Function(double value) formatPercentValue;
  final VoidCallback onExplain;

  const _CommunityRightSummary({
    required this.charge,
    required this.formatPercentValue,
    required this.onExplain,
  });

  @override
  Widget build(BuildContext context) {
    final hasPayment = charge.shouldPay;
    final hasReceivable = charge.shouldReceive;
    final movementTitle = hasReceivable
        ? 'Compensación PDE'
        : hasPayment
            ? 'Valor a Pagar'
            : 'Sin diferencia';
    final movementValue = hasReceivable
        ? Formatters.formatCurrency(charge.receivableValue)
        : hasPayment
            ? Formatters.formatCurrency(charge.payableValue)
            : 'Sin pago';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SummaryTile(
          icon: Icons.savings_outlined,
          title: 'Ahorro cooperativo',
          value: Formatters.formatCurrency(charge.rightSavingsValue),
          subtitle:
              '${formatPercentValue(charge.pdeBaseRightPct)} gratis · ${Formatters.formatEnergy(charge.pdeFreeRightKwh, decimals: 2)}',
          color: AppTokens.energyGreen,
        ),
        SizedBox(height: AppTokens.space12),
        _SummaryTile(
          icon: hasReceivable
              ? Icons.volunteer_activism
              : hasPayment
                  ? Icons.bolt
                  : Icons.check_circle_outline,
          title: movementTitle,
          value: movementValue,
          subtitle: hasReceivable
              ? '${formatPercentValue(charge.pdeContributedPct)} cedido · ${Formatters.formatEnergy(charge.pdeContributedKwh, decimals: 2)}'
              : hasPayment
                  ? '${formatPercentValue(charge.pdePurchasedPct)} adicional · ${Formatters.formatEnergy(charge.pdePurchasedKwh, decimals: 2)}'
                  : 'Usaste solo tu derecho comunitario',
          color: hasReceivable
              ? AppTokens.energyGreen
              : hasPayment
                  ? AppTokens.energySolar
                  : AppTokens.primaryColor,
        ),
        SizedBox(height: AppTokens.space12),
        _Rows(rows: [
          MapEntry('PDE final', formatPercentValue(charge.pdeFinalPct)),
          MapEntry('Precio comunitario',
              '${Formatters.formatCurrency(charge.pricePerKwh)} / kWh'),
        ]),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: onExplain,
            icon: const Icon(Icons.info_outline, size: 18),
            label: const Text('¿Cómo se calcula?'),
          ),
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _SummaryTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTokens.space12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppTokens.borderRadiusMedium,
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(width: AppTokens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    fontWeight: AppTokens.fontWeightSemiBold,
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
          SizedBox(width: AppTokens.space8),
          Text(
            value,
            style: context.textStyles.titleMedium?.copyWith(
              color: color,
              fontWeight: AppTokens.fontWeightBold,
            ),
          ),
        ],
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
