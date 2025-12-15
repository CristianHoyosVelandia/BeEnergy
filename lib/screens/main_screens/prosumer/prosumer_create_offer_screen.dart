import 'package:flutter/material.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import '../../../data/fake_data_phase2.dart';
import '../../../services/p2p_service.dart';

/// Pantalla de Creación de Oferta P2P - PROSUMIDOR
/// Permite al prosumidor publicar ofertas de venta de energía Tipo 2
/// FASE 2 - Transaccional - Diciembre 2025
class ProsumerCreateOfferScreen extends StatefulWidget {
  const ProsumerCreateOfferScreen({super.key});

  @override
  State<ProsumerCreateOfferScreen> createState() => _ProsumerCreateOfferScreenState();
}

class _ProsumerCreateOfferScreenState extends State<ProsumerCreateOfferScreen> {
  final P2PService _p2pService = P2PService();

  // Datos del prosumidor (María García)
  final _prosumer = FakeDataPhase2.mariaGarcia;
  final _energyRecord = FakeDataPhase2.mariaDec2025;
  final _ve = FakeDataPhase2.veDecember2025;
  final _pdeAllocation = FakeDataPhase2.pdeDec2025;

  // Controles del formulario
  double _energyToSell = 0.0;
  double _pricePerKwh = 450.0; // VE base

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Inicializar con disponibilidad máxima
    final available = _availableForP2P;
    _energyToSell = available > 0 ? available : 0.0;
    _pricePerKwh = _ve.totalVE; // Iniciar con VE base
  }

  /// Calcula energía disponible para P2P
  double get _availableForP2P {
    final type2 = _energyRecord.surplusType2;
    final pdeCeded = _pdeAllocation.allocatedEnergy;
    return type2 - pdeCeded;
  }

  /// Verifica si el precio está en rango VE
  bool get _isPriceValid => _ve.isPriceWithinRange(_pricePerKwh);

  /// Calcula desviación del precio respecto al VE
  double get _priceDeviation => _ve.getDeviationPercentage(_pricePerKwh);

  /// Calcula el valor total de la oferta
  double get _totalValue => _energyToSell * _pricePerKwh;

  /// Crea la oferta P2P
  Future<void> _createOffer() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Validaciones
      if (_energyToSell <= 0) {
        throw Exception('Debe ofertar al menos 1 kWh');
      }

      if (_energyToSell > _availableForP2P) {
        throw Exception('Energía ofertada excede disponibilidad');
      }

      if (!_isPriceValid) {
        throw Exception('Precio fuera del rango VE permitido (${_ve.minAllowedPrice.toStringAsFixed(0)}-${_ve.maxAllowedPrice.toStringAsFixed(0)} COP/kWh)');
      }

      // Crear oferta usando el servicio
      final offer = await _p2pService.createOffer(
        sellerId: _prosumer.userId,
        sellerName: _prosumer.fullName,
        communityId: _prosumer.communityId,
        period: '2025-12',
        energyKwh: _energyToSell,
        pricePerKwh: _pricePerKwh,
        ve: _ve,
        type2Available: _availableForP2P,
        sellerNIU: _prosumer.niu,
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
            const Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: AppTokens.space12),
            const Text('Oferta Publicada'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tu oferta P2P ha sido publicada exitosamente en el mercado.'),
            SizedBox(height: AppTokens.space16),
            _buildInfoRow('Oferta #', '$offerId'),
            _buildInfoRow('Energía', '${_energyToSell.toStringAsFixed(2)} kWh'),
            _buildInfoRow('Precio', '${_pricePerKwh.toStringAsFixed(0)} COP/kWh'),
            _buildInfoRow('Total', '\$${_totalValue.toStringAsFixed(0)}'),
            SizedBox(height: AppTokens.space16),
            Container(
              padding: EdgeInsets.all(AppTokens.space12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: AppTokens.borderRadiusMedium,
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified, color: Colors.green, size: 20),
                  SizedBox(width: AppTokens.space8),
                  Expanded(
                    child: Text(
                      'Cumple CREG 101 072 Art 4.2',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: Colors.green,
                        fontWeight: AppTokens.fontWeightSemiBold,
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
        title: const Text('Crear Oferta P2P'),
        backgroundColor: AppTokens.primaryPurple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header: Disponibilidad
                  _buildAvailabilityCard(),

                  // Energía a vender
                  _buildEnergySlider(),

                  // Precio por kWh
                  _buildPriceSlider(),

                  // Validación VE
                  _buildVEValidationCard(),

                  // Preview de la oferta
                  _buildOfferPreview(),

                  // Mensajes de error
                  if (_errorMessage != null) _buildErrorMessage(),

                  SizedBox(height: AppTokens.space64),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading || !_isPriceValid || _energyToSell <= 0
            ? null
            : _createOffer,
        backgroundColor: _isPriceValid && _energyToSell > 0
            ? AppTokens.primaryPurple
            : Colors.grey,
        icon: const Icon(Icons.publish),
        label: const Text('Publicar Oferta'),
      ),
    );
  }

  Widget _buildAvailabilityCard() {
    final type2 = _energyRecord.surplusType2;
    final pdeCeded = _pdeAllocation.allocatedEnergy;
    final available = _availableForP2P;

    return Container(
      margin: EdgeInsets.all(AppTokens.space16),
      padding: EdgeInsets.all(AppTokens.space20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTokens.primaryPurple, AppTokens.primaryPurple.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppTokens.borderRadiusLarge,
        boxShadow: [
          BoxShadow(
            color: AppTokens.primaryPurple.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt, color: Colors.white, size: 32),
              SizedBox(width: AppTokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mi Disponibilidad P2P',
                      style: context.textStyles.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: AppTokens.fontWeightBold,
                      ),
                    ),
                    SizedBox(height: AppTokens.space4),
                    Text(
                      'Diciembre 2025',
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space20),
          Container(
            padding: EdgeInsets.all(AppTokens.space16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: AppTokens.borderRadiusMedium,
            ),
            child: Column(
              children: [
                _buildAvailabilityRow('Tipo 2 total', type2, Colors.white),
                SizedBox(height: AppTokens.space8),
                _buildAvailabilityRow('PDE cedido', pdeCeded, Colors.white.withValues(alpha: 0.7), isSubtraction: true),
                Divider(color: Colors.white.withValues(alpha: 0.3), height: AppTokens.space16),
                _buildAvailabilityRow('Disponible P2P', available, Colors.white, isBold: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityRow(String label, double value, Color color, {bool isSubtraction = false, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (isSubtraction) ...[
              Icon(Icons.remove, color: color, size: 16),
              SizedBox(width: AppTokens.space4),
            ],
            Text(
              label,
              style: context.textStyles.bodyMedium?.copyWith(
                color: color,
                fontWeight: isBold ? AppTokens.fontWeightBold : null,
              ),
            ),
          ],
        ),
        Text(
          '${value.toStringAsFixed(2)} kWh',
          style: context.textStyles.bodyLarge?.copyWith(
            color: color,
            fontWeight: isBold ? AppTokens.fontWeightBold : AppTokens.fontWeightSemiBold,
          ),
        ),
      ],
    );
  }

  Widget _buildEnergySlider() {
    final maxEnergy = _availableForP2P;

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
                  'Energía a Vender',
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
                    color: AppTokens.primaryPurple.withValues(alpha: 0.1),
                    borderRadius: AppTokens.borderRadiusMedium,
                  ),
                  child: Text(
                    '${_energyToSell.toStringAsFixed(1)} kWh',
                    style: context.textStyles.bodyLarge?.copyWith(
                      fontWeight: AppTokens.fontWeightBold,
                      color: AppTokens.primaryPurple,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTokens.space16),
            Slider(
              value: _energyToSell,
              min: 0,
              max: maxEnergy,
              divisions: maxEnergy > 0 ? (maxEnergy * 2).toInt() : 1,
              label: '${_energyToSell.toStringAsFixed(1)} kWh',
              activeColor: AppTokens.primaryPurple,
              onChanged: (value) {
                setState(() {
                  _energyToSell = value;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0 kWh', style: context.textStyles.bodySmall),
                Text('${maxEnergy.toStringAsFixed(1)} kWh', style: context.textStyles.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSlider() {
    final minPrice = _ve.minAllowedPrice;
    final maxPrice = _ve.maxAllowedPrice;

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
                  'Precio por kWh',
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
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: AppTokens.borderRadiusMedium,
                    border: Border.all(
                      color: _isPriceValid ? Colors.green : Colors.red,
                    ),
                  ),
                  child: Text(
                    '\$${_pricePerKwh.toStringAsFixed(0)}',
                    style: context.textStyles.bodyLarge?.copyWith(
                      fontWeight: AppTokens.fontWeightBold,
                      color: _isPriceValid ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTokens.space8),
            Text(
              'VE base: \$${_ve.totalVE.toStringAsFixed(0)} COP/kWh',
              style: context.textStyles.bodySmall?.copyWith(color: Colors.grey),
            ),
            SizedBox(height: AppTokens.space16),
            Slider(
              value: _pricePerKwh,
              min: minPrice,
              max: maxPrice,
              divisions: ((maxPrice - minPrice) / 5).toInt(),
              label: '\$${_pricePerKwh.toStringAsFixed(0)}',
              activeColor: _isPriceValid ? Colors.green : Colors.red,
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
                Text('VE ±10%', style: context.textStyles.bodySmall?.copyWith(color: Colors.grey)),
                Text('\$${maxPrice.toStringAsFixed(0)}', style: context.textStyles.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVEValidationCard() {
    final isValid = _isPriceValid;
    final deviation = _priceDeviation;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16, vertical: AppTokens.space8),
      color: isValid ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
      child: Padding(
        padding: EdgeInsets.all(AppTokens.space16),
        child: Row(
          children: [
            Icon(
              isValid ? Icons.check_circle : Icons.warning,
              color: isValid ? Colors.green : Colors.red,
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
                      color: isValid ? Colors.green : Colors.red,
                      fontWeight: AppTokens.fontWeightBold,
                    ),
                  ),
                  SizedBox(height: AppTokens.space4),
                  Text(
                    'Desviación: ${deviation.toStringAsFixed(1)}% del VE',
                    style: context.textStyles.bodySmall?.copyWith(
                      color: isValid ? Colors.green : Colors.red,
                    ),
                  ),
                  SizedBox(height: AppTokens.space4),
                  Text(
                    'CREG 101 072 Art 4.2',
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
            _buildPreviewRow('Vendedor', _prosumer.fullName),
            _buildPreviewRow('NIU', _prosumer.niu),
            _buildPreviewRow('Energía', '${_energyToSell.toStringAsFixed(2)} kWh'),
            _buildPreviewRow('Precio', '\$${_pricePerKwh.toStringAsFixed(0)} COP/kWh'),
            Divider(height: AppTokens.space24),
            _buildPreviewRow(
              'Total',
              '\$${_totalValue.toStringAsFixed(0)}',
              isBold: true,
            ),
            SizedBox(height: AppTokens.space8),
            Text(
              'Válida hasta: 31/12/2025',
              style: context.textStyles.bodySmall?.copyWith(color: Colors.grey),
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
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: AppTokens.borderRadiusMedium,
        border: Border.all(color: Colors.red),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red),
          SizedBox(width: AppTokens.space12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: context.textStyles.bodyMedium?.copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
