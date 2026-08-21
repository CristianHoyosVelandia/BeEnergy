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
  final PdeAporteEnergyContext? energyContext;

  const PdeRenunciaScreen({
    super.key,
    required this.myUser,
    required this.communityId,
    required this.period,
    required this.periodDisplayName,
    required this.isAdminView,
    this.energyContext,
  });

  @override
  State<PdeRenunciaScreen> createState() => _PdeRenunciaScreenState();
}

class _PdeRenunciaScreenState extends State<PdeRenunciaScreen> {
  static const double _minimumPdeToKeep = 0.001; // 0.10%
  static const double _decimalTolerance = 0.000001;
  final PdeRenunciaService _service = PdeRenunciaService();
  PdeRenunciaStatus? _status;
  bool _isLoading = true;
  bool _isSubmitting = false;
  int _selectedOptionIndex = 0;
  bool _isCreatingNewDecision = false;

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
          _isCreatingNewDecision = false;
        });
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error cargando aporte PDE',
        tag: 'PdeRenunciaScreen',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        setState(() => _isLoading = false);
        context.showInfoSnackbar('No fue posible cargar el aporte PDE.');
      }
    }
  }

  Future<void> _submitRenuncia(double pdeRenunciado, String motivo,
      {PdeRenuncia? renuncia}) async {
    final current = _status?.pdeActual ?? 0;
    if (pdeRenunciado < 0 || pdeRenunciado > current) {
      context.showInfoSnackbar('El porcentaje de aporte no es válido.');
      return;
    }
    if (pdeRenunciado - _maxRenunciable(current) > _decimalTolerance) {
      context.showInfoSnackbar('Debes conservar mínimo 0,10% de tu PDE.');
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
          renunciaKwh: _pdeKwhForPercent(pdeRenunciado),
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
      if (mounted) {
        setState(() => _isCreatingNewDecision = false);
      }
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
              ? 'Aporte PDE enviado para revisión.'
              : 'Aporte PDE actualizado.',
        );
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error enviando aporte PDE',
        tag: 'PdeRenunciaScreen',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        context.showInfoSnackbar('Error enviando aporte PDE: $e');
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
            'Aportes cerrados. Periodo abierto para ofertas.');
        Navigator.pop(context, true);
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error cerrando aportes PDE',
        tag: 'PdeRenunciaScreen',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        context.showInfoSnackbar('Error cerrando aportes PDE: $e');
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
    final maxRenunciable = _maxRenunciable(current);
    double selectedValue = renuncia?.pdeRenunciado ??
        (maxRenunciable == 0 ? 0 : maxRenunciable / 2);
    inputController.text = Formatters.formatNumber(
      selectedValue * 100,
      decimals: 2,
    );

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final status = _status;
          final conservedValue =
              (current - selectedValue).clamp(0, current).toDouble();

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
            selectedValue = (parsed / 100).clamp(0, maxRenunciable).toDouble();
            setDialogState(() {});
          }

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: AppTokens.borderRadiusLarge,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9,
                maxHeight: MediaQuery.of(context).size.height * 0.78,
              ),
              child: Padding(
                padding: EdgeInsets.all(AppTokens.space20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aporte manual PDE',
                      style: context.textStyles.titleLarge?.copyWith(
                        fontWeight: AppTokens.fontWeightBold,
                      ),
                    ),
                    SizedBox(height: AppTokens.space16),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PDE disponible para aportar: ${_formatPercent(maxRenunciable)}',
                              style: context.textStyles.bodyMedium,
                            ),
                            if (status != null) ...[
                              SizedBox(height: AppTokens.space12),
                              _Rows(rows: [
                                MapEntry(
                                    'Aportas', _formatPercent(selectedValue)),
                                MapEntry('Conservas',
                                    _formatPercent(conservedValue)),
                                MapEntry(
                                  'Equivale a',
                                  Formatters.formatEnergy(
                                    _pdeKwhForPercent(conservedValue),
                                    decimals: 2,
                                  ),
                                ),
                              ]),
                              SizedBox(height: AppTokens.space12),
                              _PdeCoverageBar(
                                pdeKwh: _pdeKwhForPercent(conservedValue),
                                referenceKwh: _referenceConsumption(status),
                              ),
                            ],
                            SizedBox(height: AppTokens.space16),
                            Slider(
                              value: selectedValue
                                  .clamp(0, maxRenunciable)
                                  .toDouble(),
                              min: 0,
                              max:
                                  maxRenunciable == 0 ? 0.0001 : maxRenunciable,
                              divisions: maxRenunciable == 0 ? 1 : 100,
                              activeColor: AppTokens.primaryColor,
                              onChanged:
                                  maxRenunciable == 0 ? null : updateFromSlider,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('0%', style: context.textStyles.bodySmall),
                                Text(_formatPercent(maxRenunciable),
                                    style: context.textStyles.bodySmall),
                              ],
                            ),
                            SizedBox(height: AppTokens.space16),
                            TextField(
                              controller: inputController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              onChanged: updateFromInput,
                              decoration: InputDecoration(
                                labelText: 'Porcentaje a aportar',
                                suffixText: '%',
                                filled: true,
                                fillColor: context
                                    .colors.surfaceContainerHighest
                                    .withValues(alpha: 0.5),
                                border: OutlineInputBorder(
                                  borderRadius: AppTokens.borderRadiusMedium,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: AppTokens.space16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  vertical: AppTokens.space12),
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
                                inputController.text
                                    .trim()
                                    .replaceAll(',', '.'),
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
                                    ? 'Aporte manual voluntario'
                                    : 'Cambio de porcentaje de aporte voluntario',
                                renuncia: renuncia,
                              );
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTokens.primaryColor,
                              padding: EdgeInsets.symmetric(
                                  vertical: AppTokens.space12),
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
                ),
              ),
            ),
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
        'Aporte PDE',
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
            title: 'Gestionar aportes PDE',
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
                : const Text('Cerrar Aportes y Abrir Ofertas'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserContent() {
    final status = _status;
    if (status == null) {
      return Text(
        'No hay información de aporte PDE para este periodo.',
        style: context.textStyles.bodyMedium,
      );
    }

    final renuncia = _isCreatingNewDecision ? null : status.renuncia;
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
            title: 'Aporte Comunitario PDE',
            subtitle: widget.periodDisplayName,
          ),
          SizedBox(height: AppTokens.space16),
          _SectionLabel('Energía'),
          SizedBox(height: AppTokens.space4),
          _MetricStrip(items: [
            _MetricItem(
              'Promedio',
              Formatters.formatEnergy(_referenceConsumption(status)),
            ),
            if (_currentConsumption() != null)
              _MetricItem(
                  'Actual', Formatters.formatEnergy(_currentConsumption()!)),
            if (_previousConsumption() != null)
              _MetricItem('Mes anterior',
                  Formatters.formatEnergy(_previousConsumption()!)),
          ]),
          SizedBox(height: AppTokens.space12),
          _SectionLabel('PDE'),
          SizedBox(height: AppTokens.space4),
          _MetricStrip(items: [
            _MetricItem(
              renuncia == null ? 'Aporte bolsa' : 'Aporte registrado',
              _formatPercent(pdeRenunciado),
            ),
            _MetricItem(
              renuncia == null ? 'PDE conservado' : 'Nuevo PDE',
              _formatPercent(pdeConservado),
            ),
            _MetricItem(
              'Equivale',
              Formatters.formatEnergy(_pdeKwhForPercent(pdeConservado),
                  decimals: 2),
            ),
          ]),
          if (renuncia != null) ...[
            SizedBox(height: AppTokens.space12),
            _Rows(rows: [
              MapEntry('Estado', renuncia.estado),
            ]),
          ],
          SizedBox(height: AppTokens.space16),
          _PdeCoverageBar(
            pdeKwh: _pdeKwhForPercent(pdeConservado),
            referenceKwh: _referenceConsumption(status),
          ),
          SizedBox(height: AppTokens.space16),
          Text(
            renuncia == null
                ? 'Puedes aportar parte de tu PDE para liberarlo a la comunidad.'
                : renuncia.pdeRenunciado == 0
                    ? 'Tu decisión de conservar todo tu PDE quedó registrada para este periodo.'
                    : 'Tu aporte fue registrado y queda pendiente de revisión del administrador.',
            style: context.textStyles.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          if (renuncia == null) ...[
            SizedBox(height: AppTokens.space20),
            Text(
              'Opciones recomendadas',
              style: context.textStyles.titleMedium?.copyWith(
                color: AppTokens.primaryColor,
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
                  child: const Text('Aporte manual'),
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
                child: const Text('Cambiar porcentaje de aporte'),
              ),
            ),
          ] else ...[
            SizedBox(height: AppTokens.space20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isSubmitting
                    ? null
                    : () => setState(() => _isCreatingNewDecision = true),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppTokens.primaryColor),
                  padding: EdgeInsets.symmetric(vertical: AppTokens.space12),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTokens.borderRadiusMedium,
                  ),
                ),
                child: const Text('Registrar nuevo aporte'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildRecommendedOptions(PdeRenunciaStatus status) {
    final options = _effectiveOptions(status);

    return [
      for (var i = 0; i < options.length; i++) ...[
        Builder(builder: (context) {
          final renuncia = options[i].renunciaPorcentaje / 100;
          final conservado = (status.pdeActual - renuncia)
              .clamp(0, status.pdeActual)
              .toDouble();
          final keepsAllPde = renuncia == 0;

          return _RecommendedOptionCard(
            title: keepsAllPde
                ? 'Te recomendamos conservar todo tu PDE'
                : _optionTitle(options[i].id),
            pdeLabel: keepsAllPde
                ? 'Te quedas con ${_formatPercent(conservado)} PDE'
                : 'Aportas ${_formatPercent(renuncia)} PDE',
            detail: keepsAllPde
                ? 'No aportas PDE a la bolsa comunitaria'
                : 'Conservas ${_formatPercent(conservado)} PDE. ${options[i].descripcion}',
            selected: _selectedOptionIndex == i,
            enabled: !_isSubmitting && status.pdeActual > 0,
            onTap: () => setState(() => _selectedOptionIndex = i),
            onDoubleTap: () => _submitRenuncia(
              renuncia,
              keepsAllPde
                  ? 'Conservar todo el PDE asignado'
                  : options[i].descripcion,
            ),
          );
        }),
        if (i != options.length - 1) SizedBox(height: AppTokens.space8),
      ],
    ];
  }

  List<PdeRenunciaOption> _uniqueOptionsByRenuncia(
      List<PdeRenunciaOption> options) {
    final seen = <String>{};
    return options.where((option) {
      final key = option.renunciaPorcentaje.toStringAsFixed(4);
      return seen.add(key);
    }).toList();
  }

  List<PdeRenunciaOption> _effectiveOptions(PdeRenunciaStatus status) {
    final rawOptions = status.opciones.isEmpty
        ? [
            PdeRenunciaOption(
              id: 'sugerida',
              renunciaPorcentaje: status.pdeSugeridoRenuncia * 100,
              descripcion: 'Aportar PDE sugerido',
            ),
            PdeRenunciaOption(
              id: 'moderada',
              renunciaPorcentaje: status.pdeActual * 25,
              descripcion: 'Aportar una parte menor del PDE',
            ),
            PdeRenunciaOption(
              id: 'maxima',
              renunciaPorcentaje: _maxRenunciable(status.pdeActual) * 100,
              descripcion: 'Aportar el máximo manteniendo 0.1%',
            ),
          ]
        : status.opciones;

    return _uniqueOptionsByRenuncia(rawOptions);
  }

  String _optionTitle(String id) {
    switch (id) {
      case 'moderada':
        return 'Aporte moderado';
      case 'total':
        return 'Aporte total';
      case 'maxima':
        return 'Aporte máximo';
      default:
        return 'Aporte sugerido';
    }
  }

  String _formatPercent(double value) {
    return '${Formatters.formatNumber(value * 100, decimals: 2)}%';
  }

  double _selectedRenunciaValue(PdeRenunciaStatus status) {
    final options = _effectiveOptions(status);
    if (options.isNotEmpty && _selectedOptionIndex < options.length) {
      return options[_selectedOptionIndex].renunciaPorcentaje / 100;
    }

    switch (_selectedOptionIndex) {
      case 1:
        return status.pdeActual * 0.25;
      case 2:
        return _maxRenunciable(status.pdeActual);
      default:
        return status.pdeSugeridoRenuncia;
    }
  }

  double _maxRenunciable(double pdeActual) {
    if (pdeActual <= _minimumPdeToKeep) {
      return 0;
    }
    return (pdeActual - _minimumPdeToKeep).clamp(0, pdeActual).toDouble();
  }

  double? _currentConsumption() => widget.energyContext?.consumoActualKwh;

  double? _previousConsumption() => widget.energyContext?.consumoMesAnteriorKwh;

  double _referenceConsumption(PdeRenunciaStatus status) {
    return widget.energyContext?.consumoPromedioHistoricoKwh ??
        widget.energyContext?.consumoActualKwh ??
        status.consumoKwh;
  }

  double _pdeKwhForPercent(double pdeDecimal) {
    final generation = widget.energyContext?.generacionComunitariaPromedioKwh;
    if (generation != null && generation > 0) {
      return generation * pdeDecimal;
    }

    final currentPde = _status?.pdeActual;
    final currentKwh = widget.energyContext?.pdeActualKwh;
    if (currentPde != null && currentPde > 0 && currentKwh != null) {
      return currentKwh * (pdeDecimal / currentPde);
    }

    return (_status?.consumoKwh ?? 0) * pdeDecimal;
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
        border: Border.all(
          color: AppTokens.primaryColor.withValues(alpha: 0.22),
          width: 1.2,
        ),
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

class _MetricItem {
  final String label;
  final String value;

  const _MetricItem(this.label, this.value);
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.textStyles.labelLarge?.copyWith(
        color: AppTokens.grey900,
        fontWeight: AppTokens.fontWeightBold,
      ),
    );
  }
}

class _MetricStrip extends StatelessWidget {
  final List<_MetricItem> items;

  const _MetricStrip({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTokens.space12,
        vertical: AppTokens.space12,
      ),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.32),
        borderRadius: AppTokens.borderRadiusMedium,
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    items[i].label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.bodySmall?.copyWith(
                      color: AppTokens.grey700,
                      fontWeight: AppTokens.fontWeightSemiBold,
                    ),
                  ),
                  SizedBox(height: AppTokens.space4),
                  Text(
                    items[i].value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: AppTokens.grey900,
                      fontWeight: AppTokens.fontWeightBold,
                    ),
                  ),
                ],
              ),
            ),
            if (i != items.length - 1)
              Container(
                width: 1,
                height: 34,
                margin: EdgeInsets.symmetric(horizontal: AppTokens.space8),
                color: context.colors.outline.withValues(alpha: 0.12),
              ),
          ],
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

class _PdeCoverageBar extends StatelessWidget {
  final double pdeKwh;
  final double referenceKwh;

  const _PdeCoverageBar({
    required this.pdeKwh,
    required this.referenceKwh,
  });

  @override
  Widget build(BuildContext context) {
    final safePde = pdeKwh < 0 ? 0.0 : pdeKwh;
    final safeReference = referenceKwh <= 0 ? safePde : referenceKwh;
    final total = safePde > safeReference ? safePde : safeReference;
    final pdeCovered = safePde > safeReference ? safeReference : safePde;
    final excess = safePde > safeReference ? safePde - safeReference : 0.0;

    if (total <= 0) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Cubiertos PDE',
              style: context.textStyles.labelMedium?.copyWith(
                color: AppTokens.primaryColor,
                fontWeight: AppTokens.fontWeightBold,
              ),
            ),
            Text(
              'Consumo promedio',
              style: context.textStyles.labelMedium?.copyWith(
                color: AppTokens.grey700,
                fontWeight: AppTokens.fontWeightBold,
              ),
            ),
          ],
        ),
        SizedBox(height: AppTokens.space8),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final coveredWidth = width * (pdeCovered / total);
            final excessWidth = width * (excess / total);
            final pdeLabelLeft =
                (coveredWidth - 42).clamp(0.0, width - 84).toDouble();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    width: double.infinity,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppTokens.primaryColor.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppTokens.primaryColor.withValues(alpha: 0.28),
                      ),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: coveredWidth,
                            height: 22,
                            decoration: BoxDecoration(
                              color: AppTokens.primaryColor,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        if (excess > 0)
                          Positioned(
                            left: coveredWidth,
                            child: Container(
                              width: excessWidth,
                              height: 22,
                              color:
                                  AppTokens.energyGreen.withValues(alpha: 0.35),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: AppTokens.space8),
                SizedBox(
                  height: 22,
                  child: Stack(
                    children: [
                      Positioned(
                        left: pdeLabelLeft,
                        child: Text(
                          Formatters.formatEnergy(safePde, decimals: 2),
                          style: context.textStyles.bodySmall?.copyWith(
                            color: AppTokens.primaryColor,
                            fontWeight: AppTokens.fontWeightBold,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: Text(
                          Formatters.formatEnergy(safeReference),
                          style: context.textStyles.bodySmall?.copyWith(
                            color: AppTokens.grey700,
                            fontWeight: AppTokens.fontWeightBold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        if (excess > 0) ...[
          SizedBox(height: AppTokens.space4),
          Text(
            'Exceso disponible: ${Formatters.formatEnergy(excess, decimals: 2)}',
            style: context.textStyles.bodySmall?.copyWith(
              color: AppTokens.energyGreen,
              fontWeight: AppTokens.fontWeightSemiBold,
            ),
          ),
        ],
      ],
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
