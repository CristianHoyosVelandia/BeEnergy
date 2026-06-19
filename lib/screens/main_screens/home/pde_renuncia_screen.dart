import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/utils/formatters.dart';
import 'package:be_energy/core/utils/logger.dart';
import 'package:be_energy/models/models.dart';
import 'package:be_energy/services/pde_renuncia_service.dart';
import 'package:be_energy/utils/metodos.dart';
import 'package:flutter/material.dart';

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
  int _selectedOptionIndex = 0;

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

  Future<void> _submitRenuncia(double pdeRenunciado, String motivo,
      {PdeRenuncia? renuncia}) async {
    final current = _status?.pdeActual ?? 0;
    if (pdeRenunciado <= 0 || pdeRenunciado > current) {
      context.showInfoSnackbar('El porcentaje de renuncia no es válido.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      PdeRenuncia? savedRenuncia;
      if (renuncia == null) {
        savedRenuncia = await _service.createRenuncia(
          comunidadId: widget.communityId,
          usuarioId: widget.myUser.idUser!,
          periodo: widget.period,
          pdeRenunciado: pdeRenunciado,
          renunciaKwh: (_status?.consumoKwh ?? 0) * pdeRenunciado,
          motivo: motivo,
        );
      } else {
        savedRenuncia = await _service.updateRenuncia(
          renunciaId: renuncia.id,
          usuarioId: widget.myUser.idUser!,
          pdeRenunciado: pdeRenunciado,
          motivo: motivo,
        );
      }
      await _loadStatus();
      final renunciaGuardada = savedRenuncia;
      if (mounted && _status?.renuncia == null) {
        final currentStatus = _status;
        setState(() {
          _status = PdeRenunciaStatus(
            comunidadId: currentStatus?.comunidadId ?? widget.communityId,
            usuarioId: currentStatus?.usuarioId ?? widget.myUser.idUser!,
            periodo: currentStatus?.periodo ?? widget.period,
            pdeActual: currentStatus?.pdeActual ?? renunciaGuardada.pdeOriginal,
            consumoKwh: currentStatus?.consumoKwh ?? 0,
            pdeSugeridoRenuncia: currentStatus?.pdeSugeridoRenuncia ??
                renunciaGuardada.pdeRenunciado,
            pdeSugeridoConservado: currentStatus?.pdeSugeridoConservado ??
                renunciaGuardada.pdeConservado,
            fuente: currentStatus?.fuente,
            nivelConfianza: currentStatus?.nivelConfianza,
            opciones: currentStatus?.opciones ?? const [],
            permiteRenunciaManual: currentStatus?.permiteRenunciaManual ?? true,
            renuncia: renunciaGuardada,
          );
        });
      }
      if (mounted) {
        context.showInfoSnackbar(
          renuncia == null
              ? 'Renuncia PDE enviada para revisión.'
              : 'Renuncia PDE actualizada.',
        );
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

  void _showManualDialog({PdeRenuncia? renuncia}) {
    final inputController = TextEditingController();
    final current = _status?.pdeActual ?? 0;
    double selectedValue =
        renuncia?.pdeRenunciado ?? (current == 0 ? 0 : current / 2);
    inputController.text = Formatters.formatNumber(
      selectedValue * 100,
      decimals: 2,
    );

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          void updateFromSlider(double value) {
            selectedValue = value;
            inputController.text =
                Formatters.formatNumber(value * 100, decimals: 2);
            setDialogState(() {});
          }

          void updateFromInput(String value) {
            final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
            if (parsed == null) {
              return;
            }
            selectedValue = (parsed / 100).clamp(0, current).toDouble();
            setDialogState(() {});
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: AppTokens.borderRadiusLarge,
            ),
            title: Text(
              'Renuncia manual PDE',
              style: context.textStyles.titleLarge?.copyWith(
                fontWeight: AppTokens.fontWeightBold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PDE disponible para renunciar: ${_formatPercent(current)}',
                  style: context.textStyles.bodyMedium,
                ),
                SizedBox(height: AppTokens.space16),
                Slider(
                  value: selectedValue.clamp(0, current).toDouble(),
                  min: 0,
                  max: current == 0 ? 0.0001 : current,
                  divisions: current == 0 ? 1 : 100,
                  activeColor: AppTokens.primaryColor,
                  onChanged: current == 0 ? null : updateFromSlider,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('0%', style: context.textStyles.bodySmall),
                    Text(_formatPercent(current),
                        style: context.textStyles.bodySmall),
                  ],
                ),
                SizedBox(height: AppTokens.space16),
                TextField(
                  controller: inputController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: updateFromInput,
                  decoration: InputDecoration(
                    labelText: 'Porcentaje a renunciar',
                    suffixText: '%',
                    filled: true,
                    fillColor: context.colors.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    border: OutlineInputBorder(
                      borderRadius: AppTokens.borderRadiusMedium,
                    ),
                  ),
                ),
              ],
            ),
            actionsPadding: EdgeInsets.fromLTRB(
              AppTokens.space24,
              0,
              AppTokens.space24,
              AppTokens.space20,
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: OutlinedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(vertical: AppTokens.space12),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppTokens.borderRadiusMedium,
                        ),
                        side: BorderSide(color: AppTokens.primaryColor),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  SizedBox(width: AppTokens.space12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        final value = double.tryParse(
                          inputController.text.trim().replaceAll(',', '.'),
                        );
                        if (value == null) {
                          context.showInfoSnackbar(
                              'Ingresa un porcentaje válido.');
                          return;
                        }
                        Navigator.pop(dialogContext);
                        _submitRenuncia(
                          value / 100,
                          renuncia == null
                              ? 'Renuncia manual voluntaria'
                              : 'Cambio de porcentaje de renuncia voluntaria',
                          renuncia: renuncia,
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTokens.primaryColor,
                        padding:
                            EdgeInsets.symmetric(vertical: AppTokens.space12),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppTokens.borderRadiusMedium,
                        ),
                      ),
                      child: const Text('Enviar'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      toolbarHeight: 60,
      elevation: 0,
      foregroundColor: Colors.white,
      title: const Text(
        'Renuncia PDE',
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
    final pdeBase = renuncia?.pdeOriginal ?? status.pdeActual;
    final pdeRenunciado =
        renuncia?.pdeRenunciado ?? _selectedRenunciaValue(status);
    final pdeConservado = renuncia == null
        ? (pdeBase - pdeRenunciado).clamp(0, pdeBase).toDouble()
        : (pdeBase - renuncia.pdeRenunciado).clamp(0, pdeBase).toDouble();

    return _CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TitleRow(
            icon: Icons.volunteer_activism,
            title: 'Renuncia Voluntaria PDE',
            subtitle: widget.periodDisplayName,
          ),
          SizedBox(height: AppTokens.space16),
          _Rows(rows: [
            MapEntry('PDE actual', _formatPercent(pdeBase)),
            MapEntry(
                'Consumo del mes', Formatters.formatEnergy(status.consumoKwh)),
            MapEntry(
              renuncia == null ? 'Renuncia seleccionada' : 'Renuncia sugerida',
              _formatPercent(pdeRenunciado),
            ),
            MapEntry(
              renuncia == null ? 'PDE conservado sugerido' : 'Nuevo PDE',
              _formatPercent(pdeConservado),
            ),
            if (renuncia != null)
              MapEntry('Renuncia registrada', _formatPercent(pdeRenunciado)),
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
            Text(
              'Opciones recomendadas',
              style: context.textStyles.titleMedium?.copyWith(
                fontWeight: AppTokens.fontWeightBold,
              ),
            ),
            SizedBox(height: AppTokens.space12),
            ..._buildRecommendedOptions(status),
            if (status.permiteRenunciaManual) ...[
              SizedBox(height: AppTokens.space12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isSubmitting ? null : _showManualDialog,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTokens.primaryColor),
                    padding: EdgeInsets.symmetric(vertical: AppTokens.space12),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppTokens.borderRadiusMedium,
                    ),
                  ),
                  child: const Text('Renuncia manual'),
                ),
              ),
            ],
          ] else if (renuncia.estado == 'pendiente') ...[
            SizedBox(height: AppTokens.space20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isSubmitting
                    ? null
                    : () => _showManualDialog(renuncia: renuncia),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppTokens.primaryColor),
                  padding: EdgeInsets.symmetric(vertical: AppTokens.space12),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTokens.borderRadiusMedium,
                  ),
                ),
                child: const Text('Cambiar porcentaje de renuncia'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildRecommendedOptions(PdeRenunciaStatus status) {
    final options = status.opciones.isEmpty
        ? [
            PdeRenunciaOption(
              id: 'sugerida',
              renunciaPorcentaje: status.pdeSugeridoRenuncia,
              descripcion: 'Liberar PDE sugerido',
            ),
            PdeRenunciaOption(
              id: 'moderada',
              renunciaPorcentaje: status.pdeActual * 0.25,
              descripcion: 'Liberar una parte menor del PDE',
            ),
            PdeRenunciaOption(
              id: 'total',
              renunciaPorcentaje: status.pdeActual,
              descripcion: 'Renunciar todo',
            ),
          ]
        : status.opciones;

    return [
      for (var i = 0; i < options.length; i++) ...[
        _RecommendedOptionCard(
          title: _optionTitle(options[i].id),
          pdeLabel:
              '${_formatPercent(options[i].renunciaPorcentaje / 100)} PDE',
          detail: options[i].descripcion,
          selected: _selectedOptionIndex == i,
          enabled: !_isSubmitting && options[i].renunciaPorcentaje > 0,
          onTap: () => setState(() => _selectedOptionIndex = i),
          onDoubleTap: () => _submitRenuncia(
            options[i].renunciaPorcentaje / 100,
            options[i].descripcion,
          ),
        ),
        if (i != options.length - 1) SizedBox(height: AppTokens.space8),
      ],
    ];
  }

  String _optionTitle(String id) {
    switch (id) {
      case 'moderada':
        return 'Renuncia moderada';
      case 'total':
        return 'Renuncia total';
      default:
        return 'Renuncia sugerida';
    }
  }

  String _formatPercent(double value) {
    return '${Formatters.formatNumber(value * 100, decimals: 2)}%';
  }

  double _selectedRenunciaValue(PdeRenunciaStatus status) {
    if (status.opciones.isNotEmpty &&
        _selectedOptionIndex < status.opciones.length) {
      return status.opciones[_selectedOptionIndex].renunciaPorcentaje / 100;
    }

    switch (_selectedOptionIndex) {
      case 1:
        return status.pdeActual * 0.25;
      case 2:
        return status.pdeActual;
      default:
        return status.pdeSugeridoRenuncia;
    }
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

class _RecommendedOptionCard extends StatelessWidget {
  final String title;
  final String pdeLabel;
  final String detail;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;

  const _RecommendedOptionCard({
    required this.title,
    required this.pdeLabel,
    required this.detail,
    required this.selected,
    required this.enabled,
    required this.onTap,
    required this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      onDoubleTap: enabled ? onDoubleTap : null,
      borderRadius: AppTokens.borderRadiusLarge,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppTokens.space16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: AppTokens.borderRadiusLarge,
          border: Border.all(
            color: selected
                ? AppTokens.primaryColor
                : context.colors.outline.withValues(alpha: 0.16),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppTokens.primaryColor.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textStyles.labelMedium?.copyWith(
                      fontWeight: AppTokens.fontWeightBold,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: AppTokens.space4),
                  Text(
                    pdeLabel,
                    style: context.textStyles.titleMedium?.copyWith(
                      color: AppTokens.primaryColor,
                      fontWeight: AppTokens.fontWeightBold,
                    ),
                  ),
                  SizedBox(height: AppTokens.space4),
                  Text(detail, style: context.textStyles.bodySmall),
                ],
              ),
            ),
            if (selected)
              Icon(
                Icons.check_circle,
                color: AppTokens.primaryColor,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
