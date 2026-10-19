import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/utils/formatters.dart';
import 'package:be_energy/core/utils/logger.dart';
import 'package:be_energy/core/utils/pde_contribution_policy.dart';
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
  final PdeRenunciaService? service;

  const PdeRenunciaScreen({
    super.key,
    required this.myUser,
    required this.communityId,
    required this.period,
    required this.periodDisplayName,
    required this.isAdminView,
    this.energyContext,
    this.service,
  });

  @override
  State<PdeRenunciaScreen> createState() => _PdeRenunciaScreenState();
}

class _PdeRenunciaScreenState extends State<PdeRenunciaScreen> {
  static const double _decimalTolerance = 0.000001;
  late final PdeRenunciaService _service;
  PdeRenunciaStatus? _status;
  bool _isLoading = true;
  bool _isSubmitting = false;
  int _selectedOptionIndex = 0;
  bool _isCreatingNewDecision = false;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? PdeRenunciaService();
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
    final current = renuncia?.pdeOriginal ?? _status?.pdeActual ?? 0;
    if (pdeRenunciado < 0 || pdeRenunciado > current) {
      context.showInfoSnackbar('El porcentaje de aporte no es válido.');
      return;
    }
    final applied = PdeContributionPolicy.applied(current, pdeRenunciado);

    setState(() => _isSubmitting = true);
    try {
      PdeRenuncia? savedRenuncia;
      if (renuncia == null) {
        savedRenuncia = await _service.createRenuncia(
          comunidadId: widget.communityId,
          usuarioId: widget.myUser.idUser!,
          periodo: widget.period,
          pdeRenunciado: applied,
          renunciaKwh: _pdeKwhForPercent(applied),
          motivo: motivo,
        );
      } else {
        savedRenuncia = await _service.updateRenuncia(
          comunidadId: widget.communityId,
          periodo: widget.period,
          pdeRenunciado: applied,
          renunciaKwh: _pdeKwhForPercent(applied),
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

  Future<void> _confirmAndSubmitRenuncia(
    double pdeRenunciado,
    String motivo, {
    PdeRenuncia? renuncia,
  }) async {
    final current = renuncia?.pdeOriginal ?? _status?.pdeActual ?? 0;
    final pdeAportado = PdeContributionPolicy.applied(current, pdeRenunciado);
    final pdeConservado = (current - pdeAportado).clamp(0, current).toDouble();
    final shouldSubmit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: AppTokens.borderRadiusLarge,
          ),
          title: Text(
            'Confirmar aporte PDE',
            style: context.textStyles.titleLarge?.copyWith(
              fontWeight: AppTokens.fontWeightBold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Rows(rows: [
                MapEntry('PDE actual', _formatPercent(current)),
                MapEntry('Conservas', _formatPercent(pdeConservado)),
                MapEntry('Aportas', _formatPercent(pdeAportado)),
                MapEntry(
                  'Energía conservada',
                  Formatters.formatEnergy(
                    _pdeKwhForPercent(pdeConservado),
                    decimals: 2,
                  ),
                ),
                MapEntry(
                  'Energía aportada',
                  Formatters.formatEnergy(
                    _pdeKwhForPercent(pdeAportado),
                    decimals: 2,
                  ),
                ),
              ]),
              SizedBox(height: AppTokens.space12),
              if (pdeRenunciado > pdeAportado + _decimalTolerance) ...[
                Text(
                    'Al aportar todo, se conserva una reserva técnica de 0,01% de PDE.',
                    style: context.textStyles.bodySmall),
                SizedBox(height: AppTokens.space12),
              ],
              Text(
                'Al aportar este porcentaje, liberas parte de tu PDE para que la comunidad pueda reasignarlo.',
                style: context.textStyles.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (shouldSubmit == true) {
      await _submitRenuncia(pdeAportado, motivo, renuncia: renuncia);
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

  Future<void> _showManualDialog({PdeRenuncia? renuncia}) async {
    final inputController = TextEditingController();
    final status = _status;
    final current = renuncia?.pdeOriginal ?? status?.pdeActual ?? 0;
    final maxRenunciable = _maxRenunciable(current);
    // El modal parte de la misma opción que se muestra en el resumen, no de la
    // mitad del máximo. Al editar, se conserva el aporte ya registrado.
    double selectedValue = (renuncia?.pdeRenunciado ??
            (status == null ? 0.0 : _selectedRenunciaValue(status)))
        .clamp(0, maxRenunciable)
        .toDouble();
    inputController.text = Formatters.formatNumber(
      selectedValue * 100,
      decimals: 2,
    );

    final route = DialogRoute<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final status = _status;
          final appliedValue =
              PdeContributionPolicy.applied(current, selectedValue);
          final conservedValue =
              (current - appliedValue).clamp(0, current).toDouble();

          void updateFromSlider(double value) {
            selectedValue = value;
            inputController.text =
                Formatters.formatNumber(value * 100, decimals: 2);
            setDialogState(() {});
          }

          void updateFromInput(String value) {
            final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
            if (parsed == null || !parsed.isFinite) {
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
                              'Puedes aportar hasta ${_formatPercent(maxRenunciable)} de tu asignación.',
                              style: context.textStyles.bodyMedium,
                            ),
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
                                Text('0% mínimo',
                                    style: context.textStyles.bodySmall),
                                Text('${_formatPercent(maxRenunciable)} máximo',
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
                            SizedBox(height: AppTokens.space12),
                            Text(
                                'Al aportar todo, se mantiene una reserva técnica de 0,01% de PDE.',
                                style: context.textStyles.bodySmall?.copyWith(
                                    color: context.colors.onSurfaceVariant,
                                    height: 1.4)),
                            if (status != null) ...[
                              SizedBox(height: AppTokens.space24),
                              _PdeCoverageBar(
                                  pdeKwh: _pdeKwhForPercent(conservedValue),
                                  referenceKwh: _referenceConsumption(status)),
                              SizedBox(height: AppTokens.space24),
                              _PdeEnergySummary(
                                consumption: [
                                  _MetricItem(
                                      'Histórico',
                                      Formatters.formatNumber(
                                          _referenceConsumption(status),
                                          decimals: 2)),
                                  if (_currentConsumption() != null)
                                    _MetricItem(
                                        'Actual',
                                        Formatters.formatNumber(
                                            _currentConsumption()!,
                                            decimals: 2)),
                                  if (_previousConsumption() != null)
                                    _MetricItem(
                                        'Mes anterior',
                                        Formatters.formatNumber(
                                            _previousConsumption()!,
                                            decimals: 2)),
                                ],
                                contributedPercent:
                                    _formatPercent(appliedValue),
                                conservedPercent:
                                    _formatPercent(conservedValue),
                                contributedKwh: _pdeKwhForPercent(appliedValue),
                                conservedKwh: _pdeKwhForPercent(conservedValue),
                              ),
                            ],
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
                              if (value == null || !value.isFinite) {
                                context.showInfoSnackbar(
                                    'Ingresa un porcentaje válido.');
                                return;
                              }
                              if (value < 0 ||
                                  value / 100 >
                                      maxRenunciable + _decimalTolerance) {
                                context.showInfoSnackbar(
                                    'El aporte debe estar entre 0% y ${_formatPercent(maxRenunciable)}.');
                                return;
                              }
                              Navigator.pop(dialogContext);
                              _confirmAndSubmitRenuncia(
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
    await Navigator.of(context, rootNavigator: true).push(route);
    // Esperar también la animación de salida: el TextField mantiene el
    // controller mientras el diálogo todavía está en el overlay.
    await route.completed;
    inputController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppTokens.space8),
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
    final pdeRenunciado = renuncia?.pdeRenunciado ??
        PdeContributionPolicy.applied(pdeBase, _selectedRenunciaValue(status));
    final pdeConservado = renuncia == null
        ? (pdeBase - pdeRenunciado).clamp(0, pdeBase).toDouble()
        : (pdeBase - renuncia.pdeRenunciado).clamp(0, pdeBase).toDouble();

    return Container(
      padding: EdgeInsets.all(AppTokens.space8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TitleRow(
            icon: Icons.volunteer_activism,
            title: 'Aporte Comunitario PDE',
            subtitle: widget.periodDisplayName,
          ),
          SizedBox(height: AppTokens.space16),
          _PdeEnergySummary(
            consumption: [
              _MetricItem(
                'Histórico',
                Formatters.formatNumber(_referenceConsumption(status),
                    decimals: 2),
              ),
              if (_currentConsumption() != null)
                _MetricItem('Actual',
                    Formatters.formatNumber(_currentConsumption()!, decimals: 2)),
              if (_previousConsumption() != null)
                _MetricItem(
                    'Mes anterior',
                    Formatters.formatNumber(_previousConsumption()!,
                        decimals: 2)),
            ],
            contributedPercent: _formatPercent(pdeRenunciado),
            conservedPercent: _formatPercent(pdeConservado),
            contributedKwh: _pdeKwhForPercent(pdeRenunciado),
            conservedKwh: _pdeKwhForPercent(pdeConservado),
          ),
          if (renuncia != null) ...[
            SizedBox(height: AppTokens.space12),
            _Rows(rows: [
              MapEntry('Estado', renuncia.estado),
            ]),
          ],
          SizedBox(height: AppTokens.space24),
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
            SizedBox(height: AppTokens.space32),
            Text(
              'Elige tu aporte',
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
                  child: const Text('Elegir otro aporte'),
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
                child: const Text('Cambiar Aporte'),
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
    final options = _compactOptions(status);

    return [
      for (var i = 0; i < options.length; i++) ...[
        Builder(builder: (context) {
          final requested = options[i].renunciaPorcentaje / 100;
          final renuncia =
              PdeContributionPolicy.applied(status.pdeActual, requested);
          final conservado = (status.pdeActual - renuncia)
              .clamp(0, status.pdeActual)
              .toDouble();
          final keepsAllPde = renuncia == 0;
          final contributesAll =
              options[i].id == 'maxima' || options[i].id == 'total';

          return _RecommendedOptionCard(
            title:
                keepsAllPde ? 'Conservar mi PDE' : _optionTitle(options[i].id),
            pdeLabel: keepsAllPde
                ? 'Te quedas con ${_formatPercent(conservado)}'
                : contributesAll
                    ? 'Aportar toda mi asignación'
                    : 'Aportas ${_formatPercent(renuncia)}',
            detail: keepsAllPde
                ? 'No envías energía a la bolsa comunitaria'
                : contributesAll
                    ? 'Reserva técnica: ${_formatPercent(conservado)}'
                    : 'Conservas ${_formatPercent(conservado)}',
            selected: _selectedOptionIndex == i,
            enabled: !_isSubmitting && status.pdeActual > 0,
            onTap: () => setState(() => _selectedOptionIndex = i),
            onDoubleTap: () => _confirmAndSubmitRenuncia(
              requested,
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
              descripcion: 'Aporte total con reserva técnica de 0,01%',
            ),
          ]
        : status.opciones;

    // Las recomendaciones pueden venir cacheadas con el mínimo anterior. La
    // opción total siempre permite seleccionar todo; el cálculo aplica la reserva.
    return _uniqueOptionsByRenuncia(rawOptions
        .map((option) => option.id == 'maxima' || option.id == 'total'
            ? PdeRenunciaOption(
                id: option.id,
                renunciaPorcentaje: status.pdeActual * 100,
                descripcion: 'Aporte total con reserva técnica de 0,01%')
            : option)
        .toList());
  }

  List<PdeRenunciaOption> _compactOptions(PdeRenunciaStatus status) {
    final options = _effectiveOptions(status);
    if (options.length <= 2) return options;

    final keepAll = options.where((option) =>
        (option.renunciaPorcentaje / 100).abs() <= _decimalTolerance);
    final maximum = options.where((option) => option.id == 'maxima');

    final compact = <PdeRenunciaOption>[
      if (keepAll.isNotEmpty) keepAll.first,
      if (maximum.isNotEmpty) maximum.first,
    ];

    if (compact.length == 2) return compact;

    return [options.first, options.last];
  }

  String _optionTitle(String id) {
    switch (id) {
      case 'moderada':
        return 'Aporte moderado';
      case 'total':
        return 'Aporte total';
      case 'maxima':
        return 'Aporte total';
      default:
        return 'Aporte sugerido';
    }
  }

  String _formatPercent(double value) {
    return '${Formatters.formatNumber(value * 100, decimals: 2)}%';
  }

  double _selectedRenunciaValue(PdeRenunciaStatus status) {
    // Las tarjetas muestran la lista compacta. Usar la lista completa con el
    // mismo índice podía calcular un aporte distinto del que estaba marcado.
    final options = _compactOptions(status);
    if (options.isEmpty) return status.pdeSugeridoRenuncia;
    final index = _selectedOptionIndex.clamp(0, options.length - 1).toInt();
    return options[index].renunciaPorcentaje / 100;
  }

  double _maxRenunciable(double pdeActual) {
    return pdeActual < 0 ? 0 : pdeActual;
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

/// Contexto de consumo y decisión en una sola tarjeta, sin cajas anidadas.
class _PdeEnergySummary extends StatelessWidget {
  final List<_MetricItem> consumption;
  final String contributedPercent;
  final String conservedPercent;
  final double contributedKwh;
  final double conservedKwh;

  const _PdeEnergySummary({
    required this.consumption,
    required this.contributedPercent,
    required this.conservedPercent,
    required this.contributedKwh,
    required this.conservedKwh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: AppTokens.borderRadiusLarge,
        border:
            Border.all(color: context.colors.outline.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Resumen de tu energía',
              style: context.textStyles.titleSmall?.copyWith(
                fontWeight: AppTokens.fontWeightBold,
              )),
          const SizedBox(height: AppTokens.space20),
          const _SectionLabel('Consumo · kWh'),
          const SizedBox(height: AppTokens.space12),
          _MetricStrip(items: consumption, framed: false),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppTokens.space20),
            child: Divider(
                height: 1,
                color: context.colors.outline.withValues(alpha: 0.15)),
          ),
          const _SectionLabel('Distribución de tu PDE'),
          const SizedBox(height: AppTokens.space12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: _distribution(
                      context, 'Aportas', contributedPercent, contributedKwh)),
              const SizedBox(width: AppTokens.space16),
              Expanded(
                  child: _distribution(
                      context, 'Conservas', conservedPercent, conservedKwh)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _distribution(
      BuildContext context, String label, String percentage, double kwh) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: context.textStyles.bodySmall
                ?.copyWith(color: context.colors.onSurfaceVariant)),
        const SizedBox(height: AppTokens.space8),
        Text(percentage,
            style: context.textStyles.titleLarge?.copyWith(
              color: AppTokens.primaryColor,
              fontWeight: AppTokens.fontWeightBold,
            )),
        const SizedBox(height: AppTokens.space4),
        Text(Formatters.formatEnergy(kwh, decimals: 2),
            style: context.textStyles.bodyMedium?.copyWith(
              fontWeight: AppTokens.fontWeightSemiBold,
            )),
      ],
    );
  }
}

class _MetricStrip extends StatelessWidget {
  final List<_MetricItem> items;
  final bool framed;

  const _MetricStrip({required this.items, this.framed = true});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: framed
          ? EdgeInsets.symmetric(
              horizontal: AppTokens.space12,
              vertical: AppTokens.space12,
            )
          : EdgeInsets.zero,
      decoration: framed
          ? BoxDecoration(
              color:
                  context.colors.surfaceContainerHighest.withValues(alpha: 0.7),
              borderRadius: AppTokens.borderRadiusMedium,
              border: Border.all(
                color: context.colors.outline.withValues(alpha: 0.18),
              ),
            )
          : null,
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    items[i].label,
                    maxLines: 2,
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
                  Expanded(
                      child:
                          Text(row.key, style: context.textStyles.bodyMedium)),
                  SizedBox(width: AppTokens.space12),
                  Flexible(
                      child: Text(
                    row.value,
                    textAlign: TextAlign.end,
                    style: context.textStyles.bodyMedium?.copyWith(
                      fontWeight: AppTokens.fontWeightBold,
                    ),
                  )),
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
    final missing = safeReference > safePde ? safeReference - safePde : 0.0;
    final remainderColor =
        excess > 0 ? AppTokens.energyGreen : AppTokens.warning;

    if (total <= 0) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Así queda tu energía',
          style: context.textStyles.titleSmall?.copyWith(
            fontWeight: AppTokens.fontWeightBold,
          ),
        ),
        SizedBox(height: AppTokens.space8),
        Text(
          'Comparada con tu consumo histórico de ${Formatters.formatEnergy(safeReference, decimals: 2)}.',
          style: context.textStyles.bodySmall?.copyWith(
            color: AppTokens.grey700,
            height: 1.4,
          ),
        ),
        SizedBox(height: AppTokens.space16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: Text(
              'PDE conservado',
              style: context.textStyles.labelMedium?.copyWith(
                color: AppTokens.primaryColor,
                fontWeight: AppTokens.fontWeightBold,
              ),
            )),
            SizedBox(width: AppTokens.space12),
            Flexible(
                child: Text(
              Formatters.formatEnergy(safePde, decimals: 2),
              textAlign: TextAlign.end,
              style: context.textStyles.bodyMedium?.copyWith(
                color: AppTokens.primaryColor,
                fontWeight: AppTokens.fontWeightBold,
              ),
            )),
          ],
        ),
        SizedBox(height: AppTokens.space12),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final coveredWidth = width * (pdeCovered / total);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    width: double.infinity,
                    height: 22,
                    decoration: BoxDecoration(
                      color: remainderColor.withValues(alpha: 0.35),
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
                            color: AppTokens.primaryColor,
                          ),
                        ),
                        if (pdeCovered > 0 && (excess > 0 || missing > 0))
                          Positioned(
                            left: coveredWidth - 1,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: 2,
                              color: context.colors.surface,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        SizedBox(height: AppTokens.space12),
        _legendRow(
            context,
            missing > 0 ? 'Cubierto con PDE' : 'Consumo cubierto',
            pdeCovered,
            AppTokens.primaryColor),
        if (excess > 0)
          _legendRow(context, 'Excedente de referencia', excess,
              AppTokens.energyGreen),
        if (missing > 0)
          _legendRow(
              context, 'Faltante por cubrir', missing, AppTokens.warning),
        SizedBox(height: AppTokens.space8),
        Text(
          missing > 0
              ? 'La barra representa tu consumo histórico: una parte se cubre con tu PDE y el resto queda por cubrir.'
              : 'La barra representa todo tu PDE conservado: cubre el consumo histórico y, si sobra, queda un excedente.',
          style: context.textStyles.bodySmall?.copyWith(
            color: AppTokens.grey700,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _legendRow(
      BuildContext context, String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTokens.space4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
                width: 10,
                height: 10,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle)),
          ),
          const SizedBox(width: AppTokens.space8),
          Expanded(child: Text(label, style: context.textStyles.bodySmall)),
          const SizedBox(width: AppTokens.space12),
          Flexible(
              child: Text(Formatters.formatEnergy(value, decimals: 2),
                  textAlign: TextAlign.end,
                  style: context.textStyles.bodySmall?.copyWith(
                      color: color, fontWeight: AppTokens.fontWeightBold))),
        ],
      ),
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
        padding: EdgeInsets.symmetric(
          horizontal: AppTokens.space16,
          vertical: AppTokens.space12,
        ),
        decoration: BoxDecoration(
          color: Color.alphaBlend(
              AppTokens.primaryColor.withValues(alpha: selected ? 0.10 : 0.04),
              context.colors.surface),
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
                    style: context.textStyles.bodyMedium?.copyWith(
                      fontWeight: AppTokens.fontWeightMedium,
                      fontSize: 12,
                      color: AppTokens.grey900,
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
                  Text(
                    detail,
                    style: context.textStyles.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
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
