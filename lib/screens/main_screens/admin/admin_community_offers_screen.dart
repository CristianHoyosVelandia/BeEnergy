import 'package:flutter/material.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/utils/formatters.dart';
import 'package:be_energy/utils/metodos.dart';
import 'package:be_energy/models/consumer_offer.dart';
import 'package:be_energy/repositories/impl/consumer_offer_repository_api.dart';

enum SortType { price, pde }
enum SortOrder { asc, desc }

/// Pantalla de gestión de ofertas comunitarias para administradores
///
/// Muestra:
/// - Resumen de participación de la comunidad
/// - Lista de ofertas por miembro
/// - Opción para cerrar el periodo
class AdminCommunityOffersScreen extends StatefulWidget {
  final String period;
  const AdminCommunityOffersScreen({ super.key, required this.period });

  @override
  State<AdminCommunityOffersScreen> createState() => _AdminCommunityOffersScreenState();
}

class _AdminCommunityOffersScreenState extends State<AdminCommunityOffersScreen> {
  bool _isLoading = false;
  final _repository = ConsumerOfferRepositoryApi();

  // Datos reales desde el backend
  List<ConsumerOffer> _offers = [];
  int _totalMembers = 0;
  double _totalEnergyOffered = 0.0;
  String _periodStatus = "Cargando...";

  // Estado de ordenamiento
  SortType _sortType = SortType.price;
  SortOrder _sortOrder = SortOrder.desc;

  @override
  void initState() {
    super.initState();
    print('📍 [AdminCommunityOffersScreen] widget.period: ${widget.period}');
    // Cargar datos desde el backend
    _loadOffers();
  }

  /// Carga las ofertas desde el backend
  Future<void> _loadOffers() async {
    setState(() => _isLoading = true);

    try {
      print('🌐 [AdminCommunityOffersScreen] Cargando ofertas para periodo: ${widget.period}');

      final offers = await _repository.getCommunityPeriodOffers(
        communityId: 1, // UAO community
        period: widget.period,
      );

      print('✅ [AdminCommunityOffersScreen] ${offers.length} ofertas cargadas');

      // Calcular estadísticas
      final totalEnergy = offers.fold<double>(
        0.0,
        (sum, offer) => sum + (offer.energyKwhCalculated ?? 0.0),
      );

      setState(() {
        _offers = offers;
        _totalMembers = 15; // TODO: Obtener del backend
        _totalEnergyOffered = totalEnergy;
        _periodStatus = "PDE Disponible"; // TODO: Obtener del backend
        _isLoading = false;
      });
    } catch (e) {
      print('❌ [AdminCommunityOffersScreen] Error cargando ofertas: $e');

      if (mounted) {
        setState(() => _isLoading = false);
        context.showErrorSnackbar('Error cargando ofertas: $e');
      }
    }
  }

  /// Número de miembros con ofertas (calculado)
  int get _membersWithOffers => _offers.length;

  /// Ordena la lista de ofertas según el tipo y orden seleccionados
  void _sortOffers() {
    setState(() {
      _offers.sort((a, b) {
        double valueA, valueB;

        if (_sortType == SortType.price) {
          valueA = a.pricePerKwh;
          valueB = b.pricePerKwh;
        } else {
          // SortType.pde
          valueA = a.pdePercentageRequested;
          valueB = b.pdePercentageRequested;
        }

        // Aplicar orden ASC o DESC
        if (_sortOrder == SortOrder.asc) {
          return valueA.compareTo(valueB);
        } else {
          return valueB.compareTo(valueA);
        }
      });
    });
  }

  /// Cambia el tipo de ordenamiento (precio o PDE)
  void _changeSortType(SortType newType) {
    if (_sortType != newType) {
      setState(() {
        _sortType = newType;
      });
      _sortOffers();
    }
  }

  /// Cambia el orden (ASC o DESC)
  void _toggleSortOrder() {
    setState(() {
      _sortOrder = _sortOrder == SortOrder.asc ? SortOrder.desc : SortOrder.asc;
    });
    _sortOffers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: CustomScrollView(
                slivers: [
                  // Resumen de la comunidad
                  SliverToBoxAdapter(
                    child: _buildCommunitySummary(),
                  ),

                  // Título de la lista
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppTokens.space16,
                        AppTokens.space24,
                        AppTokens.space16,
                        AppTokens.space12,
                      ),
                      child: Text(
                        'Lista de ofertas',
                        style: context.textStyles.titleMedium?.copyWith(
                          fontWeight: AppTokens.fontWeightSemiBold,
                        ),
                      ),
                    ),
                  ),

                  // Controles de ordenamiento
                  SliverToBoxAdapter(
                    child: _buildSortControls(),
                  ),

                  // Lista de ofertas por miembro
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: AppTokens.space16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final offer = _offers[index];
                          return _buildMemberOffersCard(offer);
                        },
                        childCount: _offers.length,
                      ),
                    ),
                  ),

                  // Espaciado inferior para el FAB
                  SliverToBoxAdapter(
                    child: SizedBox(height: AppTokens.space64 + AppTokens.space16),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showClosePeriodDialog,
        backgroundColor: AppTokens.primaryRed,
        tooltip: 'Cerrar Periodo',
        child: const Icon(Icons.lock_clock, color: Colors.white, size: 28),
      ),
    );
  }

  /// AppBar con estilo de gradiente personalizado
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      toolbarHeight: 60,
      elevation: 0.0,
      flexibleSpace: Container(
        width: context.width,
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              blurRadius: 6,
              color: Color(0x4B1A1F24),
              offset: Offset(0, 2),
            )
          ],
          gradient: Metodos.gradientClasic(context),
          borderRadius: BorderRadius.circular(0),
        ),
      ),
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Container(
        margin: const EdgeInsets.only(top: 7.5, bottom: 7.5, right: 5.0, left: 5.0),
        child:  const Text(
          'Ofertas Comunitarias',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      actions: [
        // Botón de refresh
        Container(
          width: 45.0,
          height: 45.0,
          decoration: BoxDecoration(
            color: AppTokens.primaryRed,
            border: Border.all(width: 2.0, color: Colors.white),
            borderRadius: BorderRadius.circular(25.0),
          ),
          margin: const EdgeInsets.only(top: 7.5, bottom: 7.5, right: 15.0),
          child: IconButton(
            icon: const Icon(Icons.refresh, size: 22.0),
            color: Colors.white,
            tooltip: "Actualizar",
            onPressed: _refreshData,
          ),
        ),
      ],
    );
  }

  /// Resumen de participación de la comunidad
  Widget _buildCommunitySummary() {
    // Calcular suma total de porcentajes PDE ofertados
    final totalPdePercentage = _offers.fold<double>(
      0.0,
      (sum, offer) => sum + (offer.pdePercentageRequested * 100),
    );

    return Container(
      margin: EdgeInsets.all(AppTokens.space16),
      padding: EdgeInsets.all(AppTokens.space20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTokens.primaryRed,
            AppTokens.primaryRed.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppTokens.borderRadiusLarge,
        boxShadow: [
          BoxShadow(
            color: AppTokens.primaryRed.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppTokens.space12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: AppTokens.borderRadiusSmall,
                ),
                child: const Icon(
                  Icons.groups,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              SizedBox(width: AppTokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumen Comunitario',
                      style: context.textStyles.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: AppTokens.fontWeightBold,
                      ),
                    ),
                    SizedBox(height: AppTokens.space4),
                    Text(
                      'Estado: $_periodStatus',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTokens.space12,
                  vertical: AppTokens.space4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: AppTokens.borderRadiusSmall,
                ),
                child: Text(
                  '${Formatters.formatNumber(totalPdePercentage, decimals: 2)} %',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space20),

          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.people,
                  label: 'Total Miembros',
                  value: '$_totalMembers',
                ),
              ),
              SizedBox(width: AppTokens.space12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.how_to_vote,
                  label: 'Han Ofertado',
                  value: '$_membersWithOffers',
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.bolt,
                  label: 'Energía Total',
                  value: Formatters.formatEnergy(_totalEnergyOffered),
                  valueStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: AppTokens.space12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.pending_actions,
                  label: 'Ofertas Totales',
                  value: '$_membersWithOffers',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Controles de ordenamiento
  Widget _buildSortControls() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppTokens.space16,
        vertical: AppTokens.space8,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppTokens.space12,
        vertical: AppTokens.space8,
      ),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: AppTokens.borderRadiusMedium,
        border: Border.all(
          color: context.colors.outlineVariant,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icono de ordenar
          Icon(
            Icons.sort,
            size: 18,
            color: context.colors.onSurfaceVariant,
          ),
          SizedBox(width: AppTokens.space8),

          // Texto "Ordenar por:"
          Text(
            'Ordenar por:',
            style: context.textStyles.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          SizedBox(width: AppTokens.space8),

          // Chip: Precio
          GestureDetector(
            onTap: () => _changeSortType(SortType.price),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppTokens.space12,
                vertical: AppTokens.space4,
              ),
              decoration: BoxDecoration(
                color: _sortType == SortType.price
                    ? AppTokens.primaryRed
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _sortType == SortType.price
                      ? AppTokens.primaryRed
                      : context.colors.outline,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.attach_money,
                    size: 14,
                    color: _sortType == SortType.price
                        ? Colors.white
                        : context.colors.onSurfaceVariant,
                  ),
                  SizedBox(width: AppTokens.space4),
                  Text(
                    'Precio',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: _sortType == SortType.price
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: _sortType == SortType.price
                          ? Colors.white
                          : context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: AppTokens.space8),

          // Chip: PDE %
          GestureDetector(
            onTap: () => _changeSortType(SortType.pde),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppTokens.space12,
                vertical: AppTokens.space4,
              ),
              decoration: BoxDecoration(
                color: _sortType == SortType.pde
                    ? AppTokens.energyGreen
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _sortType == SortType.pde
                      ? AppTokens.energyGreen
                      : context.colors.outline,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bolt,
                    size: 14,
                    color: _sortType == SortType.pde
                        ? Colors.white
                        : context.colors.onSurfaceVariant,
                  ),
                  SizedBox(width: AppTokens.space4),
                  Text(
                    'PDE %',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: _sortType == SortType.pde
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: _sortType == SortType.pde
                          ? Colors.white
                          : context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Botón de orden ASC/DESC
          IconButton(
            onPressed: _toggleSortOrder,
            icon: Icon(
              _sortOrder == SortOrder.asc
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
              size: 20,
            ),
            color: AppTokens.primaryRed,
            tooltip: _sortOrder == SortOrder.asc
                ? 'Orden ascendente'
                : 'Orden descendente',
            padding: EdgeInsets.all(AppTokens.space8),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    TextStyle? valueStyle,
  }) {
    return Container(
      padding: EdgeInsets.all(AppTokens.space12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: AppTokens.borderRadiusSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 18),
          SizedBox(height: AppTokens.space8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 11,
            ),
          ),
          SizedBox(height: AppTokens.space4),
          Text(
            value,
            style: valueStyle ??
                const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  /// Card de oferta de un miembro (UNA oferta por periodo)
  /// Estructura basada en tabla consumer_offers
  ///
  /// Campos de la BD:
  /// - buyer_id (user)
  /// - pde_percentage_requested (decimal 0.0-1.0)
  /// - price_per_kwh (COP/kWh)
  /// - status (0-4)
  Widget _buildMemberOffersCard(ConsumerOffer offer) {
    // Determinar color basado en ROL del usuario
    final isProsumidor = offer.buyerType == 'Prosumidor';
    final roleColor = isProsumidor ? AppTokens.energyGreen : AppTokens.primaryRed;

    // Información del estado de la oferta
    final statusInfo = _getStatusInfo(offer.status.index);

    // Calcular energía estimada (PDE × Total Energía)
    final pdePercentage = offer.pdePercentageRequested;
    final energyEstimated = offer.energyKwhCalculated ?? 0.0;

    return Card(
      margin: EdgeInsets.only(bottom: AppTokens.space12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: AppTokens.borderRadiusMedium,
      ),
      child: Padding(
        padding: EdgeInsets.all(AppTokens.space16),
        child: Column(
          children: [
            // Fila principal
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === LADO IZQUIERDO: Info del Comprador ===
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre del comprador (SIEMPRE en primaryRed)
                      Text(
                        offer.buyerName.toUpperCase(),
                        style: context.textStyles.titleMedium?.copyWith(
                          fontWeight: AppTokens.fontWeightBold,
                          color: AppTokens.primaryRed,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: AppTokens.space8),
                      // Rol (Prosumidor/Consumidor)
                      Row(
                        children: [
                          Icon(
                            isProsumidor ? Icons.solar_power : Icons.electric_bolt,
                            size: 14,
                            color: roleColor,
                          ),
                          SizedBox(width: AppTokens.space4),
                          Text(
                            offer.buyerType ?? '',
                            style: TextStyle(
                              color: roleColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppTokens.space8),
                      // kWh estimado (PDE × Total Energía)
                      Row(
                        children: [
                          Icon(
                            Icons.flash_on,
                            size: 14,
                            color: context.colors.onSurfaceVariant,
                          ),
                          SizedBox(width: AppTokens.space4),
                          Text(
                            'kWh estimado: ',
                            style: context.textStyles.bodySmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            Formatters.formatEnergy(energyEstimated),
                            style: context.textStyles.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppTokens.space16),
                // === LADO DERECHO: Info de la Oferta ===
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Precio de oferta en dinero (price_per_kwh)
                      Text(
                        '${Formatters.formatCurrency(offer.pricePerKwh, decimals: 0)} COP/kWh',
                        style: context.textStyles.titleMedium?.copyWith(
                          color: AppTokens.primaryRed,
                          fontWeight: AppTokens.fontWeightBold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: AppTokens.space8),
                      // Porcentaje del PDE (pde_percentage_requested) - Formato español
                      Text(
                        '${Formatters.formatNumber(pdePercentage * 100, decimals: 2)} %',
                        style: context.textStyles.titleMedium?.copyWith(
                          color: roleColor,
                          fontWeight: AppTokens.fontWeightBold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: AppTokens.space8),
                      // Estado de la oferta (mejorado)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppTokens.space8,
                          vertical: AppTokens.space4,
                        ),
                        decoration: BoxDecoration(
                          color: statusInfo['color'].withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              statusInfo['icon'],
                              size: 12,
                              color: statusInfo['color'],
                            ),
                            SizedBox(width: AppTokens.space4),
                            Text(
                              statusInfo['label'],
                              style: TextStyle(
                                color: statusInfo['color'],
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
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
          ],
        ),
      ),
    );
  }

  /// Obtiene información de visualización del estado de la oferta
  /// Status codes de la BD:
  /// 0 = pending, 1 = matched, 2 = partialMatch, 3 = expired, 4 = cancelled
  Map<String, dynamic> _getStatusInfo(int status) {
    switch (status) {
      case 0:
        return {
          'label': 'Pendiente',
          'color': AppTokens.warning,
          'icon': Icons.pending_actions,
        };
      case 1:
        return {
          'label': 'Emparejada',
          'color': AppTokens.energyGreen,
          'icon': Icons.check_circle,
        };
      case 2:
        return {
          'label': 'Parcial',
          'color': Colors.orange,
          'icon': Icons.change_circle,
        };
      case 3:
        return {
          'label': 'Expirada',
          'color': Colors.grey,
          'icon': Icons.schedule,
        };
      case 4:
        return {
          'label': 'Cancelada',
          'color': AppTokens.primaryRed,
          'icon': Icons.cancel,
        };
      default:
        return {
          'label': 'Desconocido',
          'color': Colors.grey,
          'icon': Icons.help_outline,
        };
    }
  }

  /// Diálogo para confirmar cierre de periodo
  void _showClosePeriodDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Periodo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Estás seguro de que deseas cerrar el periodo ${widget.period}?',
              style: context.textStyles.bodyMedium,
            ),
            SizedBox(height: AppTokens.space16),
            Container(
              padding: EdgeInsets.all(AppTokens.space12),
              decoration: BoxDecoration(
                color: AppTokens.warning.withValues(alpha: 0.1),
                borderRadius: AppTokens.borderRadiusSmall,
                border: Border.all(
                  color: AppTokens.warning.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppTokens.warning,
                    size: 20,
                  ),
                  SizedBox(width: AppTokens.space8),
                  Expanded(
                    child: Text(
                      'Esta acción no se puede deshacer. No se podrán crear más ofertas para este periodo.',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: AppTokens.warning.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppTokens.space16),
            Text(
              'Resumen:',
              style: context.textStyles.bodySmall?.copyWith(
                fontWeight: AppTokens.fontWeightSemiBold,
              ),
            ),
            SizedBox(height: AppTokens.space8),
            Text('• $_membersWithOffers de $_totalMembers miembros participaron'),
            Text('• Total: ${Formatters.formatEnergy(_totalEnergyOffered)} ofertados'),
            Text('• $_membersWithOffers ofertas en total (1 por miembro)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _closePeriod();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTokens.primaryRed,
            ),
            child: const Text('Cerrar Periodo'),
          ),
        ],
      ),
    );
  }

  /// Cierra el periodo
  Future<void> _closePeriod() async {
    setState(() => _isLoading = true);

    // TODO: Llamar al WS para cerrar el periodo
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isLoading = false);
      context.showSuccessSnackbar('Periodo cerrado exitosamente');
      Navigator.pop(context); // Volver al HomeScreen
    }
  }

  /// Refresca los datos
  Future<void> _refreshData() async {
    await _loadOffers();

    if (mounted) {
      context.showInfoSnackbar('Datos actualizados');
    }
  }
}
