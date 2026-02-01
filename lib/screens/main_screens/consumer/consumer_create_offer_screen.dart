import 'package:flutter/material.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import '../../../data/fake_data_january_2026.dart';
import '../../../services/consumer_offer_service.dart';
import '../../../widgets/pde_indicator.dart';
import '../../../models/regulatory_models.dart';

/// Pantalla de Creación de Oferta P2P - CONSUMIDOR
/// Permite al consumidor crear ofertas basadas en % del PDE
/// ENERO 2026+ - Nuevo modelo de mercado
class ConsumerCreateOfferScreen extends StatefulWidget {
  const ConsumerCreateOfferScreen({super.key});

  @override
  State<ConsumerCreateOfferScreen> createState() => _ConsumerCreateOfferScreenState();
}

class _ConsumerCreateOfferScreenState extends State<ConsumerCreateOfferScreen> {
  final ConsumerOfferService _offerService = ConsumerOfferService();

  // Datos del consumidor (Ana López)
  final _consumer = FakeDataJanuary2026.anaLopez;
  final _totalPDEAvailable = FakeDataJanuary2026.pdeJan2026.allocatedEnergy; // 6.5 kWh

  // MC_m - Valor de energía promedio (300 COP/kWh) para compatibilidad con validaciones
  final _ve = VECalculation(
    period: '2026-01',
    cuComponent: 0.0,
    mcComponent: 0.0,
    pcnComponent: 0.0,
    totalVE: FakeDataJanuary2026.mcmValorEnergiaPromedio, // 300 COP/kWh
    minAllowedPrice: FakeDataJanuary2026.precioMinimoConsumidor, // 330 COP/kWh
    maxAllowedPrice: FakeDataJanuary2026.precioMaximoConsumidor, // 693.5 COP/kWh
    source: 'manual',
  );

  // Controles del formulario
  double _pdePercentageRequested = 0.15; // 15% por defecto
  double _pricePerKwh = FakeDataJanuary2026.precioMinimoConsumidor; // Precio mínimo

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Inicializar con precio mínimo (MC_m × 1.1 = 330 COP)
    _pricePerKwh = FakeDataJanuary2026.precioMinimoConsumidor;
  }

  /// Calcula energía estimada en kWh desde porcentaje
  double get _estimatedEnergyKwh => _pdePercentageRequested * _totalPDEAvailable;

  /// Verifica si el precio está en rango válido (330 a 693.5 COP/kWh)
  bool get _isPriceValid {
    final minPrice = FakeDataJanuary2026.precioMinimoConsumidor;
    final maxPrice = FakeDataJanuary2026.precioMaximoConsumidor;
    return _pricePerKwh >= minPrice && _pricePerKwh <= maxPrice;
  }

  /// Calcula el valor total estimado
  double get _totalValue => _estimatedEnergyKwh * _pricePerKwh;

  /// Crea la oferta de consumidor
  Future<void> _createOffer() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Validaciones
      if (_pdePercentageRequested < 0.01) {
        throw Exception('Debe solicitar al menos 1% del PDE');
      }

      if (_pdePercentageRequested > 1.0) {
        throw Exception('No puede solicitar más del 100% del PDE');
      }

      if (!_isPriceValid) {
        final minPrice = FakeDataJanuary2026.precioMinimoConsumidor;
        final maxPrice = FakeDataJanuary2026.precioMaximoConsumidor;
        throw Exception(
          'Precio fuera de rango permitido (${minPrice.toStringAsFixed(0)}-${maxPrice.toStringAsFixed(0)} COP/kWh)',
        );
      }

      // Crear oferta usando el servicio
      final offer = await _offerService.createConsumerOffer(
        buyerId: _consumer.userId,
        buyerName: _consumer.fullName,
        communityId: _consumer.communityId,
        period: '2026-01',
        pdePercentageRequested: _pdePercentageRequested,
        pricePerKwh: _pricePerKwh,
        ve: _ve,
        tarifaMax: FakeDataJanuary2026.precioMaximoConsumidor,
        buyerNIU: _consumer.niu,
      );

      // Mostrar éxito
      if (mounted) {
        _showSuccessDialog(offer.id);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
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
            const Icon(Icons.check_circle, color: AppTokens.energyGreen, size: 32),
            SizedBox(width: AppTokens.space12),
            const Text('Oferta Publicada'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tu oferta de compra ha sido publicada exitosamente. '
              'El administrador revisará las ofertas durante la liquidación mensual.',
            ),
            SizedBox(height: AppTokens.space16),
            _buildInfoRow('Oferta #', '$offerId'),
            _buildInfoRow(
              'PDE Solicitado',
              '${(_pdePercentageRequested * 100).toStringAsFixed(1)}%',
            ),
            _buildInfoRow(
              'Energía estimada',
              '≈ ${_estimatedEnergyKwh.toStringAsFixed(2)} kWh',
            ),
            _buildInfoRow('Precio', '${_pricePerKwh.toStringAsFixed(0)} COP/kWh'),
            _buildInfoRow('Valor estimado', '\$${_totalValue.toStringAsFixed(0)}'),
            SizedBox(height: AppTokens.space16),
            Container(
              padding: EdgeInsets.all(AppTokens.space12),
              decoration: BoxDecoration(
                color: AppTokens.primaryPurple.withValues(alpha: 0.1),
                borderRadius: AppTokens.borderRadiusMedium,
                border: Border.all(color: AppTokens.primaryPurple.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppTokens.primaryPurple.withValues(alpha: 0.7), size: 20),
                  SizedBox(width: AppTokens.space8),
                  Expanded(
                    child: Text(
                      'Energía final dependerá de la liquidación',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: AppTokens.primaryPurple.withValues(alpha: 0.8),
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
        title: const Text('Crear Oferta de Compra'),
        backgroundColor: AppTokens.primaryPurple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header: PDE Disponible
                  _buildPDEAvailabilityCard(),

                  // % del PDE solicitado
                  _buildPDEPercentageSlider(),

                  // Precio por kWh
                  _buildPriceSlider(),

                  // Validación de precio
                  _buildPriceValidationCard(),

                  // Preview de la oferta
                  _buildOfferPreview(),

                  // Mensajes de error
                  if (_errorMessage != null) _buildErrorMessage(),

                  SizedBox(height: AppTokens.space64),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading || !_isPriceValid || _pdePercentageRequested < 0.01
            ? null
            : _createOffer,
        backgroundColor: _isPriceValid && _pdePercentageRequested >= 0.01
            ? AppTokens.primaryPurple
            : Colors.grey,
        icon: const Icon(Icons.publish),
        label: const Text('Publicar Oferta'),
      ),
    );
  }

  Widget _buildPDEAvailabilityCard() {
    return PDEAvailabilitySummary(
      totalPDEAvailable: _totalPDEAvailable,
      period: 'Enero 2026',
      showHelp: true,
    );
  }

  Widget _buildPDEPercentageSlider() {
    final percentageText = '${(_pdePercentageRequested * 100).toStringAsFixed(1)}%';
    final kwhText = '≈ ${_estimatedEnergyKwh.toStringAsFixed(2)} kWh';

    return Card(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16, vertical: AppTokens.space8),
      child: Padding(
        padding: EdgeInsets.all(AppTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '% del PDE Solicitado',
                  style: context.textStyles.titleMedium?.copyWith(
                    fontWeight: AppTokens.fontWeightSemiBold,
                  ),
                ),
                PDEIndicator(
                  percentage: _pdePercentageRequested,
                  totalPDEAvailable: _totalPDEAvailable,
                  mode: PDEIndicatorMode.compact,
                ),
              ],
            ),
            SizedBox(height: AppTokens.space16),
            Slider(
              value: _pdePercentageRequested,
              min: 0.01,
              max: 1.0,
              divisions: 99,
              label: '$percentageText ($kwhText)',
              activeColor: AppTokens.primaryPurple,
              onChanged: (value) {
                setState(() {
                  _pdePercentageRequested = value;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('1%', style: context.textStyles.bodySmall),
                Text('100%', style: context.textStyles.bodySmall),
              ],
            ),
            SizedBox(height: AppTokens.space12),
            Container(
              padding: EdgeInsets.all(AppTokens.space12),
              decoration: BoxDecoration(
                color: AppTokens.primaryPurple.withValues(alpha: 0.1),
                borderRadius: AppTokens.borderRadiusMedium,
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppTokens.primaryPurple, size: 20),
                  SizedBox(width: AppTokens.space8),
                  Expanded(
                    child: Text(
                      'Energía final calculada durante liquidación',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: AppTokens.primaryPurple,
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
    final minPrice = FakeDataJanuary2026.precioMinimoConsumidor; // MC_m × 1.1 = 330
    final maxPrice = FakeDataJanuary2026.precioMaximoConsumidor; // 693.5

    return Card(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16, vertical: AppTokens.space8),
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
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTokens.space12,
                    vertical: AppTokens.space8,
                  ),
                  decoration: BoxDecoration(
                    color: _isPriceValid
                        ? AppTokens.energyGreen.withValues(alpha: 0.1)
                        : context.colors.error.withValues(alpha: 0.1),
                    borderRadius: AppTokens.borderRadiusMedium,
                    border: Border.all(
                      color: _isPriceValid ? AppTokens.energyGreen : context.colors.error,
                    ),
                  ),
                  child: Text(
                    '\$${_pricePerKwh.toStringAsFixed(0)}',
                    style: context.textStyles.bodyLarge?.copyWith(
                      fontWeight: AppTokens.fontWeightBold,
                      color: _isPriceValid ? AppTokens.energyGreen : context.colors.error,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTokens.space8),
            Text(
              'MC_m (Precio Promedio): \$${FakeDataJanuary2026.mcmValorEnergiaPromedio.toStringAsFixed(0)} COP/kWh',
              style: context.textStyles.bodySmall?.copyWith(color: Colors.grey),
            ),
            Text(
              'Rango válido: MC_m×1.1 a (Energía-Comercialización)×0.95',
              style: context.textStyles.bodySmall?.copyWith(color: Colors.grey),
            ),
            SizedBox(height: AppTokens.space16),
            Slider(
              value: _pricePerKwh,
              min: minPrice,
              max: maxPrice,
              divisions: ((maxPrice - minPrice) / 5).toInt(),
              label: '\$${_pricePerKwh.toStringAsFixed(0)}',
              activeColor: _isPriceValid ? AppTokens.energyGreen : context.colors.error,
              onChanged: (value) {
                setState(() {
                  _pricePerKwh = value;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('\$${minPrice.toStringAsFixed(0)}', style: context.textStyles.bodySmall),
                Text('MC_m×1.1', style: context.textStyles.bodySmall?.copyWith(color: Colors.grey)),
                Text('\$${maxPrice.toStringAsFixed(1)}', style: context.textStyles.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceValidationCard() {
    final isValid = _isPriceValid;
    final minPrice = FakeDataJanuary2026.precioMinimoConsumidor;
    final maxPrice = FakeDataJanuary2026.precioMaximoConsumidor;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16, vertical: AppTokens.space8),
      color: isValid ? AppTokens.energyGreen.withValues(alpha: 0.1) : context.colors.error.withValues(alpha: 0.1),
      child: Padding(
        padding: EdgeInsets.all(AppTokens.space16),
        child: Row(
          children: [
            Icon(
              isValid ? Icons.check_circle : Icons.warning,
              color: isValid ? AppTokens.energyGreen : context.colors.error,
              size: 32,
            ),
            SizedBox(width: AppTokens.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isValid ? 'Precio Válido' : 'Precio Fuera de Rango',
                    style: context.textStyles.titleSmall?.copyWith(
                      color: isValid ? AppTokens.energyGreen : context.colors.error,
                      fontWeight: AppTokens.fontWeightBold,
                    ),
                  ),
                  SizedBox(height: AppTokens.space4),
                  Text(
                    'Rango: ${minPrice.toStringAsFixed(0)}-${maxPrice.toStringAsFixed(0)} COP/kWh',
                    style: context.textStyles.bodySmall?.copyWith(
                      color: isValid ? AppTokens.energyGreen.withValues(alpha: 0.8) : context.colors.error.withValues(alpha: 0.8),
                    ),
                  ),
                  SizedBox(height: AppTokens.space4),
                  Text(
                    'CREG 101 072 - Rango consumidor',
                    style: context.textStyles.bodySmall?.copyWith(
                      color: Colors.grey,
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

  Widget _buildOfferPreview() {
    final percentageText = '${(_pdePercentageRequested * 100).toStringAsFixed(1)}%';

    return Card(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16, vertical: AppTokens.space8),
      child: Padding(
        padding: EdgeInsets.all(AppTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vista Previa',
              style: context.textStyles.titleMedium?.copyWith(
                fontWeight: AppTokens.fontWeightSemiBold,
              ),
            ),
            SizedBox(height: AppTokens.space16),
            _buildPreviewRow('Comprador', _consumer.fullName),
            _buildPreviewRow('NIU', _consumer.niu),
            _buildPreviewRow('% PDE Solicitado', percentageText),
            _buildPreviewRow('Energía estimada', '≈ ${_estimatedEnergyKwh.toStringAsFixed(2)} kWh'),
            _buildPreviewRow('Precio', '\$${_pricePerKwh.toStringAsFixed(0)} COP/kWh'),
            Divider(height: AppTokens.space24),
            _buildPreviewRow(
              'Valor estimado',
              '\$${_totalValue.toStringAsFixed(0)}',
              isBold: true,
            ),
            SizedBox(height: AppTokens.space8),
            Text(
              'Válida hasta: 31/01/2026',
              style: context.textStyles.bodySmall?.copyWith(color: Colors.grey),
            ),
            SizedBox(height: AppTokens.space8),
            Text(
              'Estado: Pendiente de liquidación',
              style: context.textStyles.bodySmall?.copyWith(color: AppTokens.primaryPurple),
            ),
          ],
        ),
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
            ),
          ),
          Text(
            value,
            style: context.textStyles.bodyMedium?.copyWith(
              fontWeight: isBold ? AppTokens.fontWeightBold : AppTokens.fontWeightSemiBold,
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
              style: context.textStyles.bodyMedium?.copyWith(color: context.colors.error),
            ),
          ),
        ],
      ),
    );
  }
}
