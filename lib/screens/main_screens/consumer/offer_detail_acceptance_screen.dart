import 'package:flutter/material.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import '../../../data/fake_data_phase2.dart';
import '../../../models/p2p_offer.dart';
import '../../../services/p2p_service.dart';

/// Pantalla de Detalle y Aceptación de Oferta - CONSUMIDOR
/// Muestra detalle completo de una oferta P2P y permite aceptarla
/// FASE 2 - Transaccional - Diciembre 2025
class OfferDetailAcceptanceScreen extends StatefulWidget {
  final P2POffer offer;

  const OfferDetailAcceptanceScreen({
    super.key,
    required this.offer,
  });

  @override
  State<OfferDetailAcceptanceScreen> createState() => _OfferDetailAcceptanceScreenState();
}

class _OfferDetailAcceptanceScreenState extends State<OfferDetailAcceptanceScreen> {
  final P2PService _p2pService = P2PService();

  final _consumer = FakeDataPhase2.anaLopez;
  final _ve = FakeDataPhase2.veDecember2025;

  double _energyToBuy = 0.0;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Inicializar con toda la energía disponible
    _energyToBuy = widget.offer.energyRemaining;
  }

  /// Calcula el total a pagar
  double get _totalCost => _energyToBuy * widget.offer.pricePerKwh;

  /// Calcula ahorro vs tarifa regulada
  double get _savings {
    const traditionalPrice = 500.0;
    return (_energyToBuy * traditionalPrice) - _totalCost;
  }

  /// Calcula porcentaje de ahorro
  double get _savingsPercentage {
    const traditionalPrice = 500.0;
    final traditionalCost = _energyToBuy * traditionalPrice;
    return traditionalCost > 0 ? (_savings / traditionalCost) * 100 : 0.0;
  }

  /// Acepta la oferta y crea el contrato
  Future<void> _acceptOffer() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Validaciones
      if (_energyToBuy <= 0) {
        throw Exception('Debe comprar al menos 1 kWh');
      }

      if (_energyToBuy > widget.offer.energyRemaining) {
        throw Exception('Energía solicitada excede disponibilidad');
      }

      // Crear contrato usando el servicio
      final contract = await _p2pService.acceptOffer(
        offerId: widget.offer.id,
        buyerId: _consumer.userId,
        buyerName: _consumer.fullName,
        energyKwh: _energyToBuy,
        ve: _ve,
        buyerNIU: _consumer.niu,
      );

      // Mostrar éxito
      if (mounted) {
        _showSuccessDialog(contract.id);
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

  void _showSuccessDialog(int contractId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: AppTokens.space12),
            const Text('Compra Exitosa'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tu contrato P2P ha sido creado exitosamente.'),
            SizedBox(height: AppTokens.space16),
            _buildInfoRow('Contrato #', '$contractId'),
            _buildInfoRow('Vendedor', widget.offer.sellerName),
            _buildInfoRow('Energía', '${_energyToBuy.toStringAsFixed(2)} kWh'),
            _buildInfoRow('Precio', '\$${widget.offer.pricePerKwh.toStringAsFixed(0)} COP/kWh'),
            _buildInfoRow('Total', '\$${_totalCost.toStringAsFixed(0)}'),
            _buildInfoRow('Ahorro', '\$${_savings.toStringAsFixed(0)} (${_savingsPercentage.toStringAsFixed(1)}%)'),
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
                      'Cumple CREG 101 072 Art 4.3',
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
              Navigator.of(context).pop(); // Cerrar diálogo
              Navigator.of(context).pop(); // Volver al marketplace
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
        title: const Text('Detalle de Oferta'),
        backgroundColor: AppTokens.energyGreen,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Información del vendedor
                  _buildSellerCard(),

                  // Detalle de la oferta
                  _buildOfferCard(),

                  // Cantidad a comprar
                  _buildQuantitySelector(),

                  // Comparación de precios
                  _buildPriceComparisonCard(),

                  // Cumplimiento regulatorio
                  _buildComplianceCard(),

                  // Resumen de compra
                  _buildPurchaseSummary(),

                  // Mensajes de error
                  if (_errorMessage != null) _buildErrorMessage(),

                  SizedBox(height: AppTokens.space64),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSellerCard() {
    // Obtener datos del vendedor (María)
    final seller = FakeDataPhase2.allMembers.firstWhere(
      (m) => m.userId == widget.offer.sellerId,
      orElse: () => FakeDataPhase2.mariaGarcia,
    );

    return Card(
      margin: EdgeInsets.all(AppTokens.space16),
      child: Padding(
        padding: EdgeInsets.all(AppTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vendedor',
              style: context.textStyles.titleMedium?.copyWith(
                fontWeight: AppTokens.fontWeightBold,
              ),
            ),
            SizedBox(height: AppTokens.space16),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTokens.primaryPurple.withValues(alpha: 0.2),
                  child: Text(
                    widget.offer.sellerName[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      color: AppTokens.primaryPurple,
                      fontWeight: AppTokens.fontWeightBold,
                    ),
                  ),
                ),
                SizedBox(width: AppTokens.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.offer.sellerName,
                        style: context.textStyles.titleMedium?.copyWith(
                          fontWeight: AppTokens.fontWeightBold,
                        ),
                      ),
                      SizedBox(height: AppTokens.space4),
                      Text(
                        'NIU: ${seller.niu}',
                        style: context.textStyles.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: AppTokens.space8),
                      Row(
                        children: [
                          Icon(Icons.verified, size: 16, color: Colors.green),
                          SizedBox(width: AppTokens.space4),
                          Text(
                            'Prosumidor Verificado',
                            style: context.textStyles.bodySmall?.copyWith(
                              color: Colors.green,
                              fontWeight: AppTokens.fontWeightSemiBold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferCard() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16, vertical: AppTokens.space8),
      child: Padding(
        padding: EdgeInsets.all(AppTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalles de la Oferta',
              style: context.textStyles.titleMedium?.copyWith(
                fontWeight: AppTokens.fontWeightBold,
              ),
            ),
            SizedBox(height: AppTokens.space16),
            _buildDetailRow('Energía disponible', '${widget.offer.energyRemaining.toStringAsFixed(2)} kWh'),
            _buildDetailRow('Precio por kWh', '\$${widget.offer.pricePerKwh.toStringAsFixed(0)}'),
            _buildDetailRow('Valor total', '\$${widget.offer.totalValue.toStringAsFixed(0)}'),
            _buildDetailRow('Vigencia', 'Hasta 31/12/2025'),
            SizedBox(height: AppTokens.space8),
            Container(
              padding: EdgeInsets.all(AppTokens.space8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: AppTokens.borderRadiusMedium,
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  SizedBox(width: AppTokens.space8),
                  Text(
                    widget.offer.status.displayName,
                    style: context.textStyles.bodySmall?.copyWith(
                      color: Colors.green,
                      fontWeight: AppTokens.fontWeightBold,
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

  Widget _buildQuantitySelector() {
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
                  'Cantidad a Comprar',
                  style: context.textStyles.titleMedium?.copyWith(
                    fontWeight: AppTokens.fontWeightBold,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTokens.space12,
                    vertical: AppTokens.space8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTokens.energyGreen.withValues(alpha: 0.1),
                    borderRadius: AppTokens.borderRadiusMedium,
                  ),
                  child: Text(
                    '${_energyToBuy.toStringAsFixed(1)} kWh',
                    style: context.textStyles.bodyLarge?.copyWith(
                      fontWeight: AppTokens.fontWeightBold,
                      color: AppTokens.energyGreen,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTokens.space16),
            Slider(
              value: _energyToBuy,
              min: 0,
              max: widget.offer.energyRemaining,
              divisions: (widget.offer.energyRemaining * 2).toInt(),
              label: '${_energyToBuy.toStringAsFixed(1)} kWh',
              activeColor: AppTokens.energyGreen,
              onChanged: (value) {
                setState(() {
                  _energyToBuy = value;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0 kWh', style: context.textStyles.bodySmall),
                Text('${widget.offer.energyRemaining.toStringAsFixed(1)} kWh', style: context.textStyles.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceComparisonCard() {
    const traditionalPrice = 500.0;
    final p2pPrice = widget.offer.pricePerKwh;
    final difference = traditionalPrice - p2pPrice;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16, vertical: AppTokens.space8),
      child: Padding(
        padding: EdgeInsets.all(AppTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comparación de Precios',
              style: context.textStyles.titleMedium?.copyWith(
                fontWeight: AppTokens.fontWeightBold,
              ),
            ),
            SizedBox(height: AppTokens.space16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(AppTokens.space12),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: AppTokens.borderRadiusMedium,
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Tarifa Regulada',
                          style: context.textStyles.bodySmall?.copyWith(color: Colors.grey),
                        ),
                        SizedBox(height: AppTokens.space8),
                        Text(
                          '\$${traditionalPrice.toStringAsFixed(0)}',
                          style: context.textStyles.titleLarge?.copyWith(
                            fontWeight: AppTokens.fontWeightBold,
                          ),
                        ),
                        Text(
                          'COP/kWh',
                          style: context.textStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppTokens.space8),
                  child: Icon(Icons.arrow_forward, color: Colors.grey),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(AppTokens.space12),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: AppTokens.borderRadiusMedium,
                      border: Border.all(color: Colors.green),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Precio P2P',
                          style: context.textStyles.bodySmall?.copyWith(color: Colors.green),
                        ),
                        SizedBox(height: AppTokens.space8),
                        Text(
                          '\$${p2pPrice.toStringAsFixed(0)}',
                          style: context.textStyles.titleLarge?.copyWith(
                            fontWeight: AppTokens.fontWeightBold,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          'COP/kWh',
                          style: context.textStyles.bodySmall?.copyWith(color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTokens.space16),
            Container(
              padding: EdgeInsets.all(AppTokens.space12),
              decoration: BoxDecoration(
                color: difference > 0
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.orange.withValues(alpha: 0.1),
                borderRadius: AppTokens.borderRadiusMedium,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    difference > 0 ? Icons.trending_down : Icons.trending_up,
                    color: difference > 0 ? Colors.green : Colors.orange,
                  ),
                  SizedBox(width: AppTokens.space8),
                  Text(
                    '${difference > 0 ? '-' : '+'}\$${difference.abs().toStringAsFixed(0)} COP/kWh',
                    style: context.textStyles.titleSmall?.copyWith(
                      color: difference > 0 ? Colors.green : Colors.orange,
                      fontWeight: AppTokens.fontWeightBold,
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

  Widget _buildComplianceCard() {
    final isCompliant = _ve.isPriceWithinRange(widget.offer.pricePerKwh);
    final deviation = _ve.getDeviationPercentage(widget.offer.pricePerKwh);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16, vertical: AppTokens.space8),
      child: Padding(
        padding: EdgeInsets.all(AppTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cumplimiento Regulatorio',
              style: context.textStyles.titleMedium?.copyWith(
                fontWeight: AppTokens.fontWeightBold,
              ),
            ),
            SizedBox(height: AppTokens.space16),
            _buildDetailRow('VE Diciembre 2025', '\$${_ve.totalVE.toStringAsFixed(0)} COP/kWh'),
            _buildDetailRow('Rango permitido', '\$${_ve.minAllowedPrice.toStringAsFixed(0)}-\$${_ve.maxAllowedPrice.toStringAsFixed(0)}'),
            _buildDetailRow('Precio oferta', '\$${widget.offer.pricePerKwh.toStringAsFixed(0)} COP/kWh'),
            SizedBox(height: AppTokens.space12),
            Container(
              padding: EdgeInsets.all(AppTokens.space12),
              decoration: BoxDecoration(
                color: isCompliant
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: AppTokens.borderRadiusMedium,
                border: Border.all(
                  color: isCompliant ? Colors.green : Colors.red,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isCompliant ? Icons.verified : Icons.warning,
                    color: isCompliant ? Colors.green : Colors.red,
                  ),
                  SizedBox(width: AppTokens.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isCompliant ? 'CUMPLE CREG 101 072' : 'NO CUMPLE',
                          style: context.textStyles.bodyMedium?.copyWith(
                            color: isCompliant ? Colors.green : Colors.red,
                            fontWeight: AppTokens.fontWeightBold,
                          ),
                        ),
                        Text(
                          'Desviación: ${deviation.toStringAsFixed(1)}% del VE',
                          style: context.textStyles.bodySmall?.copyWith(
                            color: isCompliant ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
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

  Widget _buildPurchaseSummary() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16, vertical: AppTokens.space8),
      color: AppTokens.energyGreen.withValues(alpha: 0.1),
      child: Padding(
        padding: EdgeInsets.all(AppTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen de Compra',
              style: context.textStyles.titleMedium?.copyWith(
                fontWeight: AppTokens.fontWeightBold,
              ),
            ),
            SizedBox(height: AppTokens.space16),
            _buildSummaryRow('Energía', '${_energyToBuy.toStringAsFixed(2)} kWh'),
            _buildSummaryRow('Precio', '\$${widget.offer.pricePerKwh.toStringAsFixed(0)} COP/kWh'),
            Divider(height: AppTokens.space24),
            _buildSummaryRow('Total a pagar', '\$${_totalCost.toStringAsFixed(0)}', isBold: true),
            _buildSummaryRow(
              'Ahorro',
              '\$${_savings.toStringAsFixed(0)} (${_savingsPercentage.toStringAsFixed(1)}%)',
              isGreen: _savings > 0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
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

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, bool isGreen = false}) {
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
              color: isGreen ? Colors.green : null,
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

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: AppTokens.space16),
                ),
                child: const Text('Cancelar'),
              ),
            ),
            SizedBox(width: AppTokens.space12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _isLoading || _energyToBuy <= 0
                    ? null
                    : _acceptOffer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTokens.energyGreen,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: AppTokens.space16),
                ),
                icon: const Icon(Icons.check_circle),
                label: Text(
                  _isLoading ? 'Procesando...' : 'Confirmar Compra',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
