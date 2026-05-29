import 'package:flutter/material.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/api/api_exceptions.dart';
import 'package:be_energy/core/utils/formatters.dart';
import 'package:be_energy/utils/metodos.dart';
import '../../../data/fake_data_january_2026.dart';
import '../../../services/consumer_offer_api_service.dart';
import '../../../models/consumer_offer.dart';
import '../../../models/my_user.dart';

/// Pantalla de Creación/Edición de Oferta P2P - CONSUMIDOR
/// Permite al consumidor crear o actualizar ofertas basadas en % del PDE
/// ENERO 2026+ - Nuevo modelo de mercado
class ConsumerCreateOfferScreen extends StatefulWidget {
  /// Oferta existente para editar (null si es creación)
  final ConsumerOffer? existingOffer;

  /// Período para la oferta (formato YYYY-MM)
  /// Si no se especifica, usa '2026-01' por defecto
  final String? period;

  /// Usuario actual
  final MyUser myUser;

  /// ID de la comunidad (por defecto 1)
  final int communityId;

  const ConsumerCreateOfferScreen({
    super.key,
    this.existingOffer,
    this.period,
    required this.myUser,
    this.communityId = 1, // Default comunidad 1
  });

  @override
  State<ConsumerCreateOfferScreen> createState() =>
      _ConsumerCreateOfferScreenState();
}

class _ConsumerCreateOfferScreenState extends State<ConsumerCreateOfferScreen> {
  final ConsumerOfferApiService _apiService = ConsumerOfferApiService();

  final _totalPDEAvailable = 1500.0; // kWh disponibles para PDE

  // Controles del formulario
  double _pdePercentageRequested = 5.0; // 5% por defecto (rango 0-9.99)
  double _pricePerKwh =
      FakeDataJanuary2026.precioMinimoConsumidor; // Precio mínimo

  bool _isLoading = false;
  String? _errorMessage;

  /// Indica si estamos en modo edición
  bool get _isEditMode => widget.existingOffer != null;

  /// Obtiene el período actual (del widget o default)
  String get _currentPeriod => widget.period ?? '2026-01';

  /// Obtiene el nombre formateado del período actual
  String get _currentPeriodDisplayName =>
      Formatters.formatPeriodToDisplayName(_currentPeriod);

  @override
  void initState() {
    super.initState();

    // Si existe oferta, pre-llenar el formulario
    if (_isEditMode) {
      final offer = widget.existingOffer!;
      _pdePercentageRequested =
          offer.pdePercentageRequested * 100; // Convertir decimal a porcentaje
      _pricePerKwh = offer.pricePerKwh;
    } else {
      // Inicializar con precio mínimo (MC_m × 1.1 = 330 COP)
      _pricePerKwh = FakeDataJanuary2026.precioMinimoConsumidor;
    }
  }

  /// Verifica si el precio está en rango válido (330 a 693.5 COP/kWh)
  bool get _isPriceValid {
    final minPrice = FakeDataJanuary2026.precioMinimoConsumidor;
    final maxPrice = FakeDataJanuary2026.precioMaximoConsumidor;
    return _pricePerKwh >= minPrice && _pricePerKwh <= maxPrice;
  }

  /// Calcula la energía total estimada en kWh
  double get _totalEnergyKwh {
    // Convertir porcentaje (1-100) a decimal (0.01-1.0)
    final pdeDecimal = _pdePercentageRequested / 100.0;
    return pdeDecimal * _totalPDEAvailable;
  }

  /// Calcula el valor total estimado en COP
  double get _totalValue {
    return _totalEnergyKwh * _pricePerKwh;
  }

  /// Crea o actualiza la oferta de consumidor
  Future<void> _submitOffer() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Validaciones
      if (_pdePercentageRequested <= 0.01) {
        throw Exception('Debe solicitar al menos 0.01% del PDE');
      }

      if (_pdePercentageRequested > 99.99) {
        throw Exception('No puede solicitar más del 99.99% del PDE');
      }

      if (!_isPriceValid) {
        final minPrice = FakeDataJanuary2026.precioMinimoConsumidor;
        final maxPrice = FakeDataJanuary2026.precioMaximoConsumidor;
        throw Exception(
          'Precio fuera de rango permitido (${Formatters.formatCurrency(minPrice, decimals: 0, showSymbol: false)}-${Formatters.formatCurrency(maxPrice, decimals: 0, showSymbol: false)} COP/kWh)',
        );
      }

      ConsumerOffer offer;

      if (_isEditMode) {
        // Actualizar oferta existente
        offer = await _apiService.updateOffer(
          offerId: widget.existingOffer!.id,
          pdePercentageRequested: _pdePercentageRequested,
          pricePerKwh: _pricePerKwh,
        );
      } else {
        // Crear nueva oferta
        offer = await _apiService.createOffer(
          buyerId: widget.myUser.idUser!,
          communityId: widget.communityId,
          period:
              widget.period ?? '2026-01', // Usar período del widget o default
          pdePercentageRequested: _pdePercentageRequested,
          pricePerKwh: _pricePerKwh,
        );
      }

      // Mostrar éxito
      if (mounted) {
        _showSuccessDialog(offer.id);
      }
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error inesperado: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog(int offerId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle,
                color: AppTokens.energyGreen, size: 32),
            SizedBox(width: AppTokens.space12),
            Text(_isEditMode ? 'Oferta Actualizada' : 'Oferta Publicada'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppTokens.space12),
            Text(
              _isEditMode
                  ? 'Tu oferta de compra ha sido actualizada exitosamente. '
                      'El administrador revisará las ofertas durante la liquidación mensual.'
                  : 'Tu oferta de compra ha sido publicada exitosamente. '
                      'El administrador revisará las ofertas durante la liquidación mensual.',
            ),
            SizedBox(height: AppTokens.space32),
            _buildInfoRow('Oferta #', '$offerId'),
            _buildInfoRow(
              'Energía Comunitaria Estimada',
              '${Formatters.formatNumber(_totalPDEAvailable, decimals: 1)} kWh',
            ),
            _buildInfoRow(
              'PDE Solicitado',
              '${Formatters.formatNumber(_pdePercentageRequested, decimals: 2)}%',
            ),
            _buildInfoRow('Precio',
                '${Formatters.formatCurrency(_pricePerKwh, decimals: 0)} COP/kWh'),
            // _buildInfoRow('Valor estimado', '\$${_totalValue.toStringAsFixed(0)}'),
            SizedBox(height: AppTokens.space16),
            Container(
              padding: EdgeInsets.all(AppTokens.space12),
              decoration: BoxDecoration(
                color: AppTokens.primaryColor.withValues(alpha: 0.1),
                borderRadius: AppTokens.borderRadiusMedium,
                border: Border.all(
                    color: AppTokens.primaryColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: AppTokens.primaryColor.withValues(alpha: 0.7),
                      size: 20),
                  SizedBox(width: AppTokens.space8),
                  Expanded(
                    child: Text(
                      'Energía final dependerá de la liquidación',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: AppTokens.primaryColor.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Volver a pantalla anterior
            },
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppTokens.space4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.textStyles.bodyMedium),
          Text(
            value,
            style: context.textStyles.bodyMedium?.copyWith(
              fontWeight: AppTokens.fontWeightSemiBold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Actualizar Oferta de PDE' : 'Crear Oferta de PDE',
          style: const TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: Metodos.gradientClasic(context),
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildOfferPreview(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // kWh del PDE solicitado
                        _buildPDEKwhSlider(),

                        // Precio por kWh
                        _buildPriceSlider(),

                        // Mensajes de error
                        if (_errorMessage != null) _buildErrorMessage(),

                        SizedBox(height: AppTokens.space64),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: Tooltip(
        message: 'Publicar oferta',
        child: FloatingActionButton(
          onPressed:
              _isLoading || !_isPriceValid || _pdePercentageRequested <= 0.0
                  ? null
                  : _submitOffer,
          backgroundColor: _isPriceValid && _pdePercentageRequested > 0.0
              ? AppTokens.primaryColor
              : Colors.grey,
          child: Icon(
            _isEditMode ? Icons.save : Icons.publish,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildPDEKwhSlider() {
    return Card(
      margin: EdgeInsets.symmetric(
          horizontal: AppTokens.space16, vertical: AppTokens.space8),
      child: Padding(
        padding: EdgeInsets.all(AppTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PDE Solicitado (%)',
                  style: context.textStyles.titleMedium?.copyWith(
                    fontWeight: AppTokens.fontWeightSemiBold,
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: TextField(
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    style: context.textStyles.bodyLarge?.copyWith(
                      fontWeight: AppTokens.fontWeightBold,
                      color: AppTokens.primaryColor,
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppTokens.space12,
                        vertical: AppTokens.space8,
                      ),
                      filled: true,
                      fillColor: AppTokens.primaryColor.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: AppTokens.borderRadiusMedium,
                        borderSide: BorderSide(color: AppTokens.primaryColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppTokens.borderRadiusMedium,
                        borderSide: BorderSide(color: AppTokens.primaryColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppTokens.borderRadiusMedium,
                        borderSide:
                            BorderSide(color: AppTokens.primaryColor, width: 2),
                      ),
                      suffixText: '%',
                      suffixStyle: context.textStyles.bodyMedium?.copyWith(
                        color: AppTokens.primaryColor,
                      ),
                    ),
                    controller: TextEditingController(
                      text: Formatters.formatNumber(_pdePercentageRequested,
                          decimals: 2),
                    )..selection = TextSelection.fromPosition(
                        TextPosition(
                            offset: Formatters.formatNumber(
                                    _pdePercentageRequested,
                                    decimals: 2)
                                .length),
                      ),
                    onChanged: (value) {
                      final parsed = double.tryParse(value);
                      if (parsed != null && parsed > 0.0 && parsed <= 9.99) {
                        setState(() {
                          _pdePercentageRequested = parsed;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTokens.space16),
            Slider(
              value: _pdePercentageRequested,
              min: 0.01,
              max: 9.99,
              divisions: 998,
              label:
                  '${Formatters.formatNumber(_pdePercentageRequested, decimals: 2)}%',
              activeColor: AppTokens.primaryColor,
              onChanged: (value) {
                setState(() {
                  _pdePercentageRequested = value;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0,01%', style: context.textStyles.bodySmall),
                Text('9,99%', style: context.textStyles.bodySmall),
              ],
            ),
            SizedBox(height: AppTokens.space12),
            Container(
              padding: EdgeInsets.all(AppTokens.space12),
              decoration: BoxDecoration(
                color: AppTokens.primaryColor.withValues(alpha: 0.1),
                borderRadius: AppTokens.borderRadiusMedium,
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: AppTokens.primaryColor.withValues(alpha: 0.7),
                      size: 20),
                  SizedBox(width: AppTokens.space8),
                  Expanded(
                    child: Text(
                      'Energía final asignada dependerá de la liquidación del administrador',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: AppTokens.primaryColor.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSlider() {
    final minPrice =
        FakeDataJanuary2026.precioMinimoConsumidor; // MC_m × 1.1 = 330
    final maxPrice = FakeDataJanuary2026.precioMaximoConsumidor; // 693.5

    return Card(
      margin: EdgeInsets.symmetric(
          horizontal: AppTokens.space16, vertical: AppTokens.space8),
      child: Padding(
        padding: EdgeInsets.all(AppTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Precio Ofertado',
                  style: context.textStyles.titleMedium?.copyWith(
                    fontWeight: AppTokens.fontWeightSemiBold,
                  ),
                ),
                SizedBox(
                  width: 140,
                  child: TextField(
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    style: context.textStyles.bodyLarge?.copyWith(
                      fontWeight: AppTokens.fontWeightBold,
                      color: _isPriceValid
                          ? AppTokens.primaryColor
                          : context.colors.error,
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppTokens.space12,
                        vertical: AppTokens.space8,
                      ),
                      filled: true,
                      fillColor: _isPriceValid
                          ? AppTokens.primaryColor.withValues(alpha: 0.1)
                          : context.colors.error.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: AppTokens.borderRadiusMedium,
                        borderSide: BorderSide(
                          color: _isPriceValid
                              ? AppTokens.primaryColor
                              : context.colors.error,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppTokens.borderRadiusMedium,
                        borderSide: BorderSide(
                          color: _isPriceValid
                              ? AppTokens.primaryColor
                              : context.colors.error,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppTokens.borderRadiusMedium,
                        borderSide: BorderSide(
                          color: _isPriceValid
                              ? AppTokens.primaryColor
                              : context.colors.error,
                          width: 2,
                        ),
                      ),
                      prefixText: '\$',
                      suffixText: ' COP/kWh',
                      prefixStyle: context.textStyles.bodyMedium?.copyWith(
                        color: _isPriceValid
                            ? AppTokens.primaryColor
                            : context.colors.error,
                      ),
                      suffixStyle: context.textStyles.bodySmall?.copyWith(
                        color: _isPriceValid
                            ? AppTokens.primaryColor
                            : context.colors.error,
                      ),
                    ),
                    controller: TextEditingController(
                      text: Formatters.formatNumber(_pricePerKwh, decimals: 0),
                    )..selection = TextSelection.fromPosition(
                        TextPosition(
                            offset: Formatters.formatNumber(_pricePerKwh,
                                    decimals: 0)
                                .length),
                      ),
                    onChanged: (value) {
                      final parsed = double.tryParse(value);
                      if (parsed != null &&
                          parsed >= minPrice &&
                          parsed <= maxPrice) {
                        setState(() {
                          _pricePerKwh = parsed;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTokens.space8),
            Text(
              'MCm (Precio Promedio): ${Formatters.formatCurrency(FakeDataJanuary2026.mcmValorEnergiaPromedio, decimals: 0)} COP/kWh',
              style: context.textStyles.bodySmall?.copyWith(color: Colors.grey),
            ),
            SizedBox(height: AppTokens.space8),
            Text(
              'Rango válido:',
              style: context.textStyles.titleSmall
                  ?.copyWith(fontWeight: AppTokens.fontWeightMedium),
            ),
            SizedBox(height: AppTokens.space16),
            Slider(
              value: _pricePerKwh,
              min: minPrice,
              max: maxPrice,
              divisions: ((maxPrice - minPrice) / 5).toInt(),
              label: Formatters.formatCurrency(_pricePerKwh, decimals: 0),
              activeColor:
                  _isPriceValid ? AppTokens.primaryColor : context.colors.error,
              onChanged: (value) {
                setState(() {
                  _pricePerKwh = value;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(Formatters.formatCurrency(minPrice, decimals: 0),
                    style: context.textStyles.bodySmall),
                // Text('MC_m×1.1', style: context.textStyles.bodySmall?.copyWith(color: Colors.grey)),
                Text(Formatters.formatCurrency(maxPrice, decimals: 0),
                    style: context.textStyles.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferPreview() {
    return Card(
      color: Colors.transparent,
      elevation: AppTokens.elevation6,
      margin: EdgeInsets.fromLTRB(
        AppTokens.space16,
        AppTokens.space8,
        AppTokens.space16,
        AppTokens.space4,
      ),
      shape: RoundedRectangleBorder(borderRadius: AppTokens.borderRadiusLarge),
      child: Container(
        padding: EdgeInsets.all(AppTokens.space16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTokens.primaryColor,
              AppTokens.primaryColor.withValues(alpha: 0.82),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppTokens.borderRadiusLarge,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPDEPreviewHeader(),
            SizedBox(height: AppTokens.space12),
            _buildPreviewSupportMessage(),
            SizedBox(height: AppTokens.space12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Vista Previa de Oferta',
                    style: context.textStyles.titleMedium?.copyWith(
                      fontWeight: AppTokens.fontWeightBold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Icon(
                  _isPriceValid ? Icons.check_circle : Icons.warning,
                  color: _isPriceValid ? Colors.white : AppTokens.primaryYellow,
                  size: 20,
                ),
              ],
            ),
            SizedBox(height: AppTokens.space12),
            _buildPreviewRow('PDE Solicitado',
                Formatters.formatPercentageES(_pdePercentageRequested)),
            _buildPreviewRow('Precio Ofertado',
                '${Formatters.formatCurrencyES(_pricePerKwh)} COP/kWh'),
            Divider(
              height: AppTokens.space16,
              color: Colors.white.withValues(alpha: 0.25),
            ),
            _buildPreviewRow(
              'Energía estimada',
              Formatters.formatEnergyES(_totalEnergyKwh),
              isBold: true,
            ),
            _buildPreviewRow(
              'Valor Total Estimado',
              Formatters.formatCurrencyES(_totalValue),
              isBold: true,
            ),
            SizedBox(height: AppTokens.space8),
          ],
        ),
      ),
    );
  }

  Widget _buildPDEPreviewHeader() {
    return Row(
      children: [
        const Icon(Icons.bolt, color: Colors.white, size: 28),
        SizedBox(width: AppTokens.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PDE Disponible - $_currentPeriodDisplayName',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.help_outline,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ],
    );
  }

  Widget _buildPreviewSupportMessage() {
    final minValue = FakeDataJanuary2026.precioMinimoConsumidor;
    final maxValue = FakeDataJanuary2026.precioMaximoConsumidor;
    final color = _isPriceValid ? Colors.white : AppTokens.primaryYellow;

    return Container(
      padding: EdgeInsets.all(AppTokens.space12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: AppTokens.borderRadiusSmall,
        border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _isPriceValid ? Icons.touch_app : Icons.info_outline,
            color: color,
            size: 18,
          ),
          SizedBox(width: AppTokens.space8),
          Expanded(
            child: Text(
              'Usa los sliders para modificartu oferta.'
              '\n\n${_isPriceValid ? 'Precio válido' : 'Precio fuera de rango'}: ${Formatters.formatCurrencyES(minValue)} - ${Formatters.formatCurrencyES(maxValue)} COP/kWh. '
              '\nOferta válida hasta: 31/05/2026',
              style: context.textStyles.bodySmall?.copyWith(
                color: color,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppTokens.space4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: context.textStyles.bodyMedium?.copyWith(
              fontWeight: isBold ? AppTokens.fontWeightBold : null,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          Text(
            value,
            style: context.textStyles.bodyMedium?.copyWith(
              fontWeight: isBold
                  ? AppTokens.fontWeightBold
                  : AppTokens.fontWeightSemiBold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      margin: EdgeInsets.all(AppTokens.space16),
      padding: EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        color: context.colors.error.withValues(alpha: 0.1),
        borderRadius: AppTokens.borderRadiusMedium,
        border: Border.all(color: context.colors.error),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: context.colors.error),
          SizedBox(width: AppTokens.space12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: context.textStyles.bodyMedium
                  ?.copyWith(color: context.colors.error),
            ),
          ),
        ],
      ),
    );
  }
}
