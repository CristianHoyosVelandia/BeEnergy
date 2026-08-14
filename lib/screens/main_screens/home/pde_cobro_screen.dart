import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/utils/formatters.dart';
import 'package:be_energy/models/models.dart';
import 'package:be_energy/services/pde_cobro_service.dart';
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
            title: _screenTitle,
            subtitle: 'Liquidación ${widget.periodDisplayName}',
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
    if (charge == null || !charge.hasMovement) {
      return Text(
        'No tienes cobros ni compensaciones PDE para este periodo.',
        style: context.textStyles.bodyMedium?.copyWith(
          color: context.colors.onSurfaceVariant,
          height: 1.35,
        ),
      );
    }

    final amountLabel = charge.isCredit ? 'Valor a recibir' : 'Valor a pagar';
    final pdeLabel = charge.isCredit ? 'PDE cedido' : 'PDE comprado';
    final energyLabel =
        charge.isCredit ? 'Energía cedida' : 'Energía entregada';

    return _Rows(rows: [
      MapEntry(amountLabel, Formatters.formatCurrency(charge.amount)),
      MapEntry(
          energyLabel, Formatters.formatEnergy(charge.energyKwh, decimals: 2)),
      MapEntry('PDE aplicado', _formatPercentValue(charge.pdeAppliedPct)),
      MapEntry(pdeLabel, _formatPercentValue(charge.pdeTransactedPct)),
      MapEntry('Precio energía comunitaria',
          '${Formatters.formatCurrency(charge.pricePerKwh)} / kWh'),
    ]);
  }

  Widget _buildMessage() {
    final charge = _charge;
    final textStyle = context.textStyles.bodyMedium?.copyWith(
      color: context.colors.onSurfaceVariant,
      height: 1.35,
    );

    if (charge == null || !charge.hasMovement) {
      return Text(
        'Cuando tengas una compra o cesión PDE liquidada, el detalle aparecerá en esta sección.',
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
        'Cediste PDE a la comunidad. Este valor queda como compensación a tu favor; la dispersión real se habilitará cuando se integre la pasarela de pago.',
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
    final pendingText = charge?.isCredit == true
        ? 'Registrar compensación visual'
        : 'Simular pago';
    final paidText = charge?.isCredit == true
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
    if (charge?.isCredit == true) {
      return 'Compensación PDE';
    }
    return 'Cobro del periodo';
  }

  String get _statusLabel {
    if (_isLoading) return 'Cargando';
    if (_errorMessage != null) return 'Error';
    final charge = _charge;
    if (charge == null || !charge.hasMovement) return 'Sin movimientos';
    if (charge.isCredit) return _isPaid ? 'Compensación registrada' : 'A favor';
    return _isPaid ? 'Pagado' : 'Pendiente';
  }

  Color get _statusColor {
    if (_errorMessage != null) return AppTokens.error;
    final charge = _charge;
    if (charge == null || !charge.hasMovement) return context.colors.outline;
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
