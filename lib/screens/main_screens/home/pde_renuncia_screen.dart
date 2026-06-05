import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/utils/formatters.dart';
import 'package:be_energy/core/utils/logger.dart';
import 'package:be_energy/models/models.dart';
import 'package:be_energy/services/pde_renuncia_service.dart';
import 'package:flutter/material.dart';

import 'components/pde_state_machine/pde_progress_timeline.dart';

class PdeRenunciaScreen extends StatefulWidget {
  final MyUser myUser;
  final int communityId;
  final String period;
  final String periodDisplayName;
  final bool isAdminView;

  const PdeRenunciaScreen({
    super.key,
    required this.myUser,
    required this.communityId,
    required this.period,
    required this.periodDisplayName,
    required this.isAdminView,
  });

  @override
  State<PdeRenunciaScreen> createState() => _PdeRenunciaScreenState();
}

class _PdeRenunciaScreenState extends State<PdeRenunciaScreen> {
  final PdeRenunciaService _service = PdeRenunciaService();
  PdeRenunciaStatus? _status;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    if (widget.isAdminView) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final status = await _service.getUserStatus(
        comunidadId: widget.communityId,
        usuarioId: widget.myUser.idUser!,
        periodo: widget.period,
      );
      if (mounted) {
        setState(() {
          _status = status;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error cargando renuncia PDE',
        tag: 'PdeRenunciaScreen',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        setState(() => _isLoading = false);
        context.showInfoSnackbar('No fue posible cargar la renuncia PDE.');
      }
    }
  }

  Future<void> _submitRenuncia(double pdeRenunciado, String motivo) async {
    final current = _status?.pdeActual ?? 0;
    if (pdeRenunciado <= 0 || pdeRenunciado > current) {
      context.showInfoSnackbar('El porcentaje de renuncia no es válido.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _service.createRenuncia(
        comunidadId: widget.communityId,
        usuarioId: widget.myUser.idUser!,
        periodo: widget.period,
        pdeRenunciado: pdeRenunciado,
        motivo: motivo,
      );
      await _loadStatus();
      if (mounted) {
        context.showInfoSnackbar('Renuncia PDE enviada para revisión.');
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error enviando renuncia PDE',
        tag: 'PdeRenunciaScreen',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        context.showInfoSnackbar('Error enviando renuncia PDE: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _closeFlow() async {
    setState(() => _isSubmitting = true);
    try {
      await _service.closeFlow(
        comunidadId: widget.communityId,
        periodo: widget.period,
        adminId: widget.myUser.idUser!,
      );
      if (mounted) {
        context.showInfoSnackbar(
            'Renuncias cerradas. Periodo abierto para ofertas.');
        Navigator.pop(context, true);
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error cerrando renuncias PDE',
        tag: 'PdeRenunciaScreen',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        context.showInfoSnackbar('Error cerrando renuncias PDE: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showManualDialog() {
    final inputController = TextEditingController();
    final current = _status?.pdeActual ?? 0;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: AppTokens.borderRadiusLarge),
        title: const Text('Renuncia manual PDE'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PDE disponible para renunciar: ${_formatPercent(current)}',
            ),
            SizedBox(height: AppTokens.space12),
            TextField(
              controller: inputController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Porcentaje a renunciar',
                hintText: 'Ej: 4.99',
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(
                inputController.text.trim().replaceAll(',', '.'),
              );
              if (value == null) {
                context.showInfoSnackbar('Ingresa un porcentaje válido.');
                return;
              }
              Navigator.pop(dialogContext);
              _submitRenuncia(value / 100, 'Renuncia manual voluntaria');
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Renuncia PDE'),
        backgroundColor: AppTokens.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(AppTokens.space16),
              children: [
                if (widget.isAdminView)
                  _buildAdminContent()
                else
                  _buildUserContent(),
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
            icon: Icons.volunteer_activism,
            title: 'Gestionar renuncias PDE',
            subtitle: widget.periodDisplayName,
          ),
          SizedBox(height: AppTokens.space20),
          const PdeProgressTimeline(currentStatus: 6, onDark: false),
          SizedBox(height: AppTokens.space16),
          Text(
            'Los usuarios que no respondieron conservan su PDE completo. Al cerrar este flujo se abre el periodo para ofertas PDE.',
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppTokens.space20),
          FilledButton(
            onPressed: _isSubmitting ? null : _closeFlow,
            child: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Cerrar Renuncias y Abrir Ofertas'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserContent() {
    final status = _status;
    if (status == null) {
      return Text(
        'No hay información de renuncia PDE para este periodo.',
        style: context.textStyles.bodyMedium,
      );
    }

    final renuncia = status.renuncia;
    return _CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TitleRow(
            icon: Icons.volunteer_activism,
            title: 'Renuncia Voluntaria PDE',
            subtitle: widget.periodDisplayName,
          ),
          SizedBox(height: AppTokens.space20),
          const PdeProgressTimeline(currentStatus: 6, onDark: false),
          SizedBox(height: AppTokens.space16),
          _Rows(rows: [
            MapEntry('PDE actual', _formatPercent(status.pdeActual)),
            MapEntry(
                'Consumo del mes', Formatters.formatEnergy(status.consumoKwh)),
            MapEntry('Renuncia sugerida',
                _formatPercent(status.pdeSugeridoRenuncia)),
            MapEntry('PDE conservado sugerido',
                _formatPercent(status.pdeSugeridoConservado)),
            if (renuncia != null)
              MapEntry('Renuncia registrada',
                  _formatPercent(renuncia.pdeRenunciado)),
            if (renuncia != null) MapEntry('Estado', renuncia.estado),
          ]),
          SizedBox(height: AppTokens.space16),
          Text(
            renuncia == null
                ? 'Puedes liberar parte de tu PDE para que otros miembros oferten por él cuando el admin abra el periodo.'
                : 'Tu renuncia fue registrada y queda pendiente de revisión del administrador.',
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          if (renuncia == null) ...[
            SizedBox(height: AppTokens.space20),
            _ActionButton(
              label: 'Renunciar sugerido',
              description: _formatPercent(status.pdeSugeridoRenuncia),
              enabled: !_isSubmitting && status.pdeSugeridoRenuncia > 0,
              onTap: () => _submitRenuncia(
                status.pdeSugeridoRenuncia,
                'Renuncia sugerida por bajo consumo del periodo',
              ),
            ),
            SizedBox(height: AppTokens.space8),
            _ActionButton(
              label: 'Renunciar manualmente',
              description: 'Elegir porcentaje',
              enabled: !_isSubmitting,
              onTap: _showManualDialog,
            ),
            SizedBox(height: AppTokens.space8),
            _ActionButton(
              label: 'Renunciar todo',
              description: _formatPercent(status.pdeActual),
              enabled: !_isSubmitting && status.pdeActual > 0,
              onTap: () => _submitRenuncia(
                status.pdeActual,
                'Renuncia total voluntaria del PDE asignado',
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatPercent(double value) {
    return '${Formatters.formatNumber(value * 100, decimals: 2)}%';
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

class _ActionButton extends StatelessWidget {
  final String label;
  final String description;
  final bool enabled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.description,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: AppTokens.borderRadiusMedium,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppTokens.space12),
        decoration: BoxDecoration(
          color:
              AppTokens.primaryColor.withValues(alpha: enabled ? 0.08 : 0.03),
          borderRadius: AppTokens.borderRadiusMedium,
          border: Border.all(
            color:
                AppTokens.primaryColor.withValues(alpha: enabled ? 0.22 : 0.08),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: context.textStyles.bodyMedium?.copyWith(
                      fontWeight: AppTokens.fontWeightBold,
                    ),
                  ),
                  SizedBox(height: AppTokens.space4),
                  Text(
                    description,
                    style: context.textStyles.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: context.colors.onSurfaceVariant,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
