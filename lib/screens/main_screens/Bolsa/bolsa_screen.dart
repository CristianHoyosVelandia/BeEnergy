import 'package:flutter/material.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/utils/formatters.dart';
import 'package:be_energy/utils/metodos.dart';
import '../../../data/fake_data_phase2.dart';
import '../../../models/p2p_offer.dart';
import '../../../models/p2p_models.dart';
import '../prosumer/prosumer_create_offer_screen.dart';

/// Pantalla de Marketplace P2P para Prosumidor
/// Vista del prosumidor (Cristian Hoyos) para gestionar sus ofertas P2P
/// Muestra disponibilidad Tipo 2, PVE, ofertas activas y contratos
class BolsaScreen extends StatefulWidget {
  const BolsaScreen({super.key});

  @override
  State<BolsaScreen> createState() => _BolsaScreenState();
}

class _BolsaScreenState extends State<BolsaScreen> {
  // Usuario prosumidor (Cristian Hoyos según datos del backend)
  final _prosumer = FakeDataPhase2.mariaGarcia; // Usaremos los datos de María pero con el nombre de Cristian
  final _energyRecord = FakeDataPhase2.mariaDec2025;
  final _pdeAllocation = FakeDataPhase2.pdeDec2025;
  final _ve = FakeDataPhase2.veDecember2025;

  /// Obtiene ofertas activas del prosumidor
  List<P2POffer> get _myOffers {
    return FakeDataPhase2.allOffers
        .where((offer) => offer.sellerId == _prosumer.userId)
        .toList();
  }

  /// Obtiene contratos donde el prosumidor es vendedor
  List<P2PContract> get _myContracts {
    return FakeDataPhase2.allContracts
        .where((contract) => contract.sellerId == _prosumer.userId)
        .toList();
  }

  /// Calcula disponibilidad P2P (Tipo 2 - PDE cedido)
  double get _availableForP2P {
    final type2 = _energyRecord.surplusType2;
    final pdeCeded = _pdeAllocation.allocatedEnergy;
    return type2 - pdeCeded;
  }

  /// Calcula energía ya ofertada
  double get _energyOffered {
    return _myOffers.fold(0.0, (sum, offer) => sum + offer.energyAvailable);
  }

  /// Calcula ingresos del mes por ventas P2P
  double get _monthlyIncome {
    return _myContracts.fold(0.0, (sum, contract) => sum + contract.totalValue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Intercambios P2P',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w400
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: Metodos.gradientClasic(context),
            boxShadow: const [
              BoxShadow(
                blurRadius: 6,
                color: Color(0x4B1A1F24),
                offset: Offset(0, 2),
              )
            ],
          ),
        ),
      ),
      backgroundColor: context.colors.surfaceContainerLowest,
      body: ListView(
        padding: EdgeInsets.only(bottom: AppTokens.space24),
        children: [
          SizedBox(height: AppTokens.space16),
          _buildProsumerHeader(),
          SizedBox(height: AppTokens.space16),
          _buildPVEInfoCard(),
          SizedBox(height: AppTokens.space16),
          _buildAvailabilityCard(),
          SizedBox(height: AppTokens.space24),
          _buildMyOffersSection(),
          SizedBox(height: AppTokens.space24),
          _buildMyContractsSection(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProsumerCreateOfferScreen(),
            ),
          );
        },
        backgroundColor: AppTokens.primaryRed,
        foregroundColor: Colors.white,
        elevation: 8,
        child: const Icon(Icons.add_circle_outline, size: 24),
      ),
    );
  }

  /// Header del prosumidor con avatar y datos
  Widget _buildProsumerHeader() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
      padding: EdgeInsets.all(AppTokens.space20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTokens.energyGreen,
            AppTokens.energyGreen.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppTokens.borderRadiusLarge,
        boxShadow: [
          BoxShadow(
            color: AppTokens.energyGreen.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/img/avatar.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Text(
                    'CH',
                    style: context.textStyles.headlineMedium?.copyWith(
                      color: AppTokens.energyGreen,
                      fontWeight: AppTokens.fontWeightBold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: AppTokens.space16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cristian Hoyos V.',
                  style: context.textStyles.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: AppTokens.fontWeightBold,
                  ),
                ),
                SizedBox(height: AppTokens.space4),
                Row(
                  children: [
                    Icon(Icons.verified, size: 16, color: Colors.white),
                    SizedBox(width: AppTokens.space4),
                    Text(
                      'NIU-UAO-024-2025',
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppTokens.space4),
                Row(
                  children: [
                    Icon(Icons.solar_power, size: 16, color: Colors.white),
                    SizedBox(width: AppTokens.space4),
                    Text(
                      'Prosumidor • ${_prosumer.installedCapacity.toStringAsFixed(0)} kW',
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Tarjeta de información del PVE (Precio Valor de Energía)
  Widget _buildPVEInfoCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
      padding: EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        color: AppTokens.info.withValues(alpha: 0.1),
        borderRadius: AppTokens.borderRadiusMedium,
        border: Border.all(color: AppTokens.info, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppTokens.info, size: 24),
              SizedBox(width: AppTokens.space12),
              Expanded(
                child: Text(
                  'Precio Valor de Energía (PVE)',
                  style: context.textStyles.titleMedium?.copyWith(
                    color: AppTokens.info,
                    fontWeight: AppTokens.fontWeightBold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space16),
          Divider(height: 1, color: AppTokens.info.withValues(alpha: 0.2)),
          SizedBox(height: AppTokens.space16),

          // VE Base
          _buildPVERow(
            'VE Base (CREG 101 072)',
            '${_ve.totalVE.toStringAsFixed(0)} COP/kWh',
            Icons.bolt,
            AppTokens.info,
          ),
          SizedBox(height: AppTokens.space12),

          // Rango permitido
          Container(
            padding: EdgeInsets.all(AppTokens.space12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: AppTokens.borderRadiusSmall,
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, size: 18, color: Colors.green),
                    SizedBox(width: AppTokens.space8),
                    Text(
                      'Rango Permitido P2P (±10%)',
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: Colors.green,
                        fontWeight: AppTokens.fontWeightSemiBold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppTokens.space8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Mínimo',
                          style: context.textStyles.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: AppTokens.space4),
                        Text(
                          '${_ve.minAllowedPrice.toStringAsFixed(0)} COP',
                          style: context.textStyles.titleMedium?.copyWith(
                            color: Colors.green,
                            fontWeight: AppTokens.fontWeightBold,
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.arrow_forward, color: context.colors.onSurfaceVariant),
                    Column(
                      children: [
                        Text(
                          'Máximo',
                          style: context.textStyles.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: AppTokens.space4),
                        Text(
                          '${_ve.maxAllowedPrice.toStringAsFixed(0)} COP',
                          style: context.textStyles.titleMedium?.copyWith(
                            color: Colors.green,
                            fontWeight: AppTokens.fontWeightBold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: AppTokens.space12),

          // Recomendación
          Container(
            padding: EdgeInsets.all(AppTokens.space12),
            decoration: BoxDecoration(
              color: AppTokens.primaryPurple.withValues(alpha: 0.1),
              borderRadius: AppTokens.borderRadiusSmall,
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, size: 18, color: AppTokens.primaryPurple),
                SizedBox(width: AppTokens.space8),
                Expanded(
                  child: Text(
                    'Fija tu precio de venta entre este rango para cumplir CREG 101 072',
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
    );
  }

  Widget _buildPVERow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        SizedBox(width: AppTokens.space12),
        Expanded(
          child: Text(
            label,
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: context.textStyles.titleMedium?.copyWith(
            color: color,
            fontWeight: AppTokens.fontWeightBold,
          ),
        ),
      ],
    );
  }

  /// Tarjeta de disponibilidad P2P
  Widget _buildAvailabilityCard() {
    final available = _availableForP2P;
    final offered = _energyOffered;
    final remaining = available - offered;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
      padding: EdgeInsets.all(AppTokens.space20),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppTokens.borderRadiusLarge,
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppTokens.space12),
                decoration: BoxDecoration(
                  color: AppTokens.energyGreen.withValues(alpha: 0.15),
                  borderRadius: AppTokens.borderRadiusSmall,
                ),
                child: Icon(
                  Icons.battery_charging_full,
                  color: AppTokens.energyGreen,
                  size: 28,
                ),
              ),
              SizedBox(width: AppTokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mi Disponibilidad P2P',
                      style: context.textStyles.titleLarge?.copyWith(
                        fontWeight: AppTokens.fontWeightBold,
                      ),
                    ),
                    SizedBox(height: AppTokens.space4),
                    Text(
                      'Diciembre 2025',
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space20),
          Divider(height: 1),
          SizedBox(height: AppTokens.space20),

          // Tipo 2 Total
          _buildAvailabilityMetric(
            'Tipo 2 Total',
            _energyRecord.surplusType2,
            'Excedente vendible',
            AppTokens.energyGreen,
            Icons.sunny,
          ),
          SizedBox(height: AppTokens.space12),

          // PDE Cedido
          _buildAvailabilityMetric(
            'PDE Cedido',
            _pdeAllocation.allocatedEnergy,
            'Solidaridad energética (10%)',
            AppTokens.primaryPurple,
            Icons.volunteer_activism,
          ),
          SizedBox(height: AppTokens.space12),

          // Disponible
          Container(
            padding: EdgeInsets.all(AppTokens.space16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: AppTokens.borderRadiusMedium,
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 32),
                SizedBox(width: AppTokens.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Disponible para P2P',
                        style: context.textStyles.bodyMedium?.copyWith(
                          color: Colors.green,
                          fontWeight: AppTokens.fontWeightSemiBold,
                        ),
                      ),
                      SizedBox(height: AppTokens.space4),
                      Text(
                        Formatters.formatEnergy(available),
                        style: context.textStyles.headlineMedium?.copyWith(
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

          if (offered > 0) ...[
            SizedBox(height: AppTokens.space12),
            Row(
              children: [
                Icon(Icons.campaign, size: 16, color: context.colors.onSurfaceVariant),
                SizedBox(width: AppTokens.space8),
                Text(
                  'Ya ofertado: ${Formatters.formatEnergy(offered)}',
                  style: context.textStyles.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.trending_up, size: 16, color: AppTokens.energyGreen),
                SizedBox(width: AppTokens.space8),
                Text(
                  'Restante: ${Formatters.formatEnergy(remaining)}',
                  style: context.textStyles.bodySmall?.copyWith(
                    color: AppTokens.energyGreen,
                    fontWeight: AppTokens.fontWeightSemiBold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvailabilityMetric(
    String label,
    double value,
    String subtitle,
    Color color,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(AppTokens.space8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: AppTokens.borderRadiusSmall,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(width: AppTokens.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.textStyles.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
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
        Text(
          Formatters.formatEnergy(value),
          style: context.textStyles.titleLarge?.copyWith(
            color: color,
            fontWeight: AppTokens.fontWeightBold,
          ),
        ),
      ],
    );
  }

  /// Sección de mis ofertas activas
  Widget _buildMyOffersSection() {
    final offers = _myOffers;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mis Ofertas Activas',
                style: context.textStyles.titleLarge?.copyWith(
                  fontWeight: AppTokens.fontWeightBold,
                ),
              ),
              if (offers.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTokens.space12,
                    vertical: AppTokens.space4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTokens.energyGreen.withValues(alpha: 0.2),
                    borderRadius: AppTokens.borderRadiusSmall,
                  ),
                  child: Text(
                    '${offers.length}',
                    style: context.textStyles.titleMedium?.copyWith(
                      color: AppTokens.energyGreen,
                      fontWeight: AppTokens.fontWeightBold,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: AppTokens.space16),

          if (offers.isEmpty)
            _buildEmptyState(
              'No tienes ofertas activas',
              'Crea tu primera oferta para vender energía P2P',
              Icons.campaign_outlined,
            )
          else
            ...offers.map((offer) => _buildOfferCard(offer)),
        ],
      ),
    );
  }

  Widget _buildOfferCard(P2POffer offer) {
    return Container(
      margin: EdgeInsets.only(bottom: AppTokens.space12),
      padding: EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppTokens.borderRadiusMedium,
        border: Border.all(
          color: _getOfferStatusColor(offer.status).withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Oferta #${offer.id}',
                style: context.textStyles.titleMedium?.copyWith(
                  fontWeight: AppTokens.fontWeightBold,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTokens.space8,
                  vertical: AppTokens.space4,
                ),
                decoration: BoxDecoration(
                  color: _getOfferStatusColor(offer.status).withValues(alpha: 0.2),
                  borderRadius: AppTokens.borderRadiusSmall,
                ),
                child: Text(
                  offer.status.displayName,
                  style: context.textStyles.bodySmall?.copyWith(
                    color: _getOfferStatusColor(offer.status),
                    fontWeight: AppTokens.fontWeightBold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space12),
          Divider(height: 1),
          SizedBox(height: AppTokens.space12),

          Row(
            children: [
              Expanded(
                child: _buildOfferMetric('Energía', Formatters.formatEnergy(offer.energyAvailable)),
              ),
              Expanded(
                child: _buildOfferMetric('Precio', '\$${offer.pricePerKwh.toStringAsFixed(0)}'),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space8),
          Row(
            children: [
              Expanded(
                child: _buildOfferMetric('Restante', Formatters.formatEnergy(offer.energyRemaining)),
              ),
              Expanded(
                child: _buildOfferMetric('Total', Formatters.formatCurrency(offer.totalValue)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOfferMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textStyles.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        SizedBox(height: AppTokens.space4),
        Text(
          value,
          style: context.textStyles.bodyLarge?.copyWith(
            fontWeight: AppTokens.fontWeightBold,
          ),
        ),
      ],
    );
  }

  Color _getOfferStatusColor(OfferStatus status) {
    switch (status) {
      case OfferStatus.available:
        return Colors.green;
      case OfferStatus.partial:
        return Colors.orange;
      case OfferStatus.sold:
        return AppTokens.primaryPurple;
      case OfferStatus.expired:
      case OfferStatus.cancelled:
        return Colors.grey;
    }
  }

  /// Sección de mis contratos del mes
  Widget _buildMyContractsSection() {
    final contracts = _myContracts;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ventas del Mes',
                style: context.textStyles.titleLarge?.copyWith(
                  fontWeight: AppTokens.fontWeightBold,
                ),
              ),
              if (contracts.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Ingresos',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      Formatters.formatCurrency(_monthlyIncome),
                      style: context.textStyles.titleMedium?.copyWith(
                        color: Colors.green,
                        fontWeight: AppTokens.fontWeightBold,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          SizedBox(height: AppTokens.space16),

          if (contracts.isEmpty)
            _buildEmptyState(
              'Sin ventas este mes',
              'Tus contratos P2P aparecerán aquí',
              Icons.receipt_long_outlined,
            )
          else
            ...contracts.map((contract) => _buildContractCard(contract)),
        ],
      ),
    );
  }

  Widget _buildContractCard(P2PContract contract) {
    return Container(
      margin: EdgeInsets.only(bottom: AppTokens.space12),
      padding: EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppTokens.borderRadiusMedium,
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.handshake, color: Colors.green, size: 24),
              SizedBox(width: AppTokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vendido a: ${contract.buyerName}',
                      style: context.textStyles.titleMedium?.copyWith(
                        fontWeight: AppTokens.fontWeightBold,
                      ),
                    ),
                    Text(
                      'Contrato #${contract.id}',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                Formatters.formatCurrency(contract.totalValue),
                style: context.textStyles.titleLarge?.copyWith(
                  color: Colors.green,
                  fontWeight: AppTokens.fontWeightBold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space12),
          Row(
            children: [
              Icon(Icons.bolt, size: 16, color: context.colors.onSurfaceVariant),
              SizedBox(width: AppTokens.space4),
              Text(
                '${Formatters.formatEnergy(contract.energyCommitted)} @ \$${contract.agreedPrice.toStringAsFixed(0)}/kWh',
                style: context.textStyles.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Container(
      padding: EdgeInsets.all(AppTokens.space32),
      child: Center(
        child: Column(
          children: [
            Icon(
              icon,
              size: 64,
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            SizedBox(height: AppTokens.space16),
            Text(
              title,
              style: context.textStyles.titleMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
                fontWeight: AppTokens.fontWeightBold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppTokens.space8),
            Text(
              subtitle,
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
