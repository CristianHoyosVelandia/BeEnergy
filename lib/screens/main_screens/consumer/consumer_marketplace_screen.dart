import 'package:flutter/material.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/utils/formatters.dart';
import 'package:be_energy/core/api/api_exceptions.dart';
import 'package:be_energy/utils/metodos.dart';
import '../../../data/fake_data_january_2026.dart';
import '../../../models/consumer_offer.dart';
import '../../../models/my_user.dart';
import '../../../services/consumer_offer_api_service.dart';
import '../../../widgets/my_offers_card.dart';
import 'consumer_create_offer_screen.dart';
import 'my_offers_screen.dart';

/// Pantalla de Ofertas PDE - CONSUMIDOR
/// Permite a los consumidores crear ofertas de compra basadas en % del PDE
/// disponible para un período específico
class ConsumerMarketplaceScreen extends StatefulWidget {
  final String? period; // Período inicial (opcional, formato YYYY-MM)
  final MyUser myUser; // Usuario actual
  final int communityId; // ID de la comunidad (por defecto 1)

  const ConsumerMarketplaceScreen({
    super.key,
    this.period,
    required this.myUser,
    this.communityId = 1, // Default comunidad 1
  });

  @override
  State<ConsumerMarketplaceScreen> createState() => _ConsumerMarketplaceScreenState();
}

class _ConsumerMarketplaceScreenState extends State<ConsumerMarketplaceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _apiService = ConsumerOfferApiService();

  // Período actual (del parámetro del widget, por defecto 2026-01)
  late String _currentPeriod;

  // Estado de oferta existente
  bool _hasExistingOffer = false;
  bool _isCheckingOffer = true;
  ConsumerOffer? _existingOffer;
  String? _loadError;

  // Ofertas recientes del usuario (para mostrar en el tab)
  List<ConsumerOffer> _recentOffers = [];
  bool _isLoadingOffers = false;

  @override
  void initState() {
    super.initState();

    // Usar período del parámetro o default
    _currentPeriod = widget.period ?? '2026-01';

    _tabController = TabController(length: 2, vsync: this);
    _checkExistingOffer();
    _loadRecentOffers();
  }

  /// Formatea el período YYYY-MM a nombre legible (ej: "2026-03" → "Marzo 2026")
  String _formatPeriodToDisplayName(String period) {
    try {
      final parts = period.split('-');
      if (parts.length != 2) return period;

      final year = parts[0];
      final month = int.parse(parts[1]);

      const months = [
        '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
        'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
      ];

      if (month < 1 || month > 12) return period;

      return '${months[month]} $year';
    } catch (e) {
      return period;
    }
  }

  /// Obtiene el nombre formateado del período actual
  String get _currentPeriodDisplayName => _formatPeriodToDisplayName(_currentPeriod);

  /// Verifica si existe una oferta para el período actual
  Future<void> _checkExistingOffer() async {
    if (!mounted) return;

    setState(() {
      _isCheckingOffer = true;
      _loadError = null;
    });

    try {
      final offer = await _apiService.getBuyerOfferForPeriod( widget.myUser.idUser!, _currentPeriod );

      if (mounted) {
        setState(() {
          _existingOffer = offer;
          _hasExistingOffer = offer != null && offer.status == ConsumerOfferStatus.pending;
          _isCheckingOffer = false;
          _loadError = null;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _existingOffer = null;
          _hasExistingOffer = false;
          _isCheckingOffer = false;
          _loadError = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _existingOffer = null;
          _hasExistingOffer = false;
          _isCheckingOffer = false;
          _loadError = 'Error al cargar oferta: $e';
        });
      }
    }
  }

  /// Carga las últimas ofertas del usuario (máximo 3) desde el Web Service
  Future<void> _loadRecentOffers() async {
    if (!mounted) return;

    setState(() {
      _isLoadingOffers = true;
    });

    try {
      final allOffers = await _apiService.getBuyerOffers(widget.myUser.idUser ?? 0);
      final recentOffers = allOffers.take(3).toList();

      if (mounted) {
        setState(() {
          _recentOffers = recentOffers;
          _isLoadingOffers = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _recentOffers = [];
          _isLoadingOffers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _recentOffers = [];
          _isLoadingOffers = false;
        });
      }
    }
  }

  /// Cancela la oferta existente
  Future<void> _cancelOffer() async {
    if (_existingOffer == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Oferta'),
        content: const Text('¿Estás seguro de que deseas cancelar esta oferta?\n\nEsta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppTokens.primaryRed,
            ),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await _apiService.cancelOffer(_existingOffer!.id);

      if (mounted) {
        Navigator.pop(context); // Cerrar loading

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Oferta cancelada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );

        // Recargar ofertas
        await _checkExistingOffer();
        await _loadRecentOffers();
      }
    } on ApiException catch (e) {
      if (mounted) {
        Navigator.pop(context); // Cerrar loading

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cancelar: ${e.message}'),
            backgroundColor: AppTokens.primaryRed,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Cerrar loading

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: $e'),
            backgroundColor: AppTokens.primaryRed,
          ),
        );
      }
    }
  }

  /// Navega a la pantalla de editar oferta
  Future<void> _editOffer() async {
    if (_existingOffer == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConsumerCreateOfferScreen(
          existingOffer: _existingOffer,
          period: _currentPeriod,
          myUser: widget.myUser,
          communityId: widget.communityId,
        ),
      ),
    );

    // Recargar ofertas después de editar
    _checkExistingOffer();
    _loadRecentOffers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ofertas PDE - $_currentPeriodDisplayName',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            tooltip: '¿Qué son los PDE?',
            onPressed: () => _showPDEHelpDialog(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
          tabs: const [
            Tab(text: 'Crear Oferta', icon: Icon(Icons.add_shopping_cart)),
            Tab(text: 'Mis Ofertas', icon: Icon(Icons.list)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCreateOfferTab(),
          _buildMyOffersTab(),
        ],
      ),
    );
  }

  // ============================================================================
  // DIÁLOGO DE AYUDA PDE
  // ============================================================================

  void _showPDEHelpDialog() {
    final minValue = FakeDataJanuary2026.pdeConstantsJan2026.mcmValorEnergiaPromedio * 1.1;
    final maxValue = (FakeDataJanuary2026.pdeConstantsJan2026.costoEnergia -
                      FakeDataJanuary2026.pdeConstantsJan2026.costoComercializacion) * 0.95;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: AppTokens.primaryRed),
            SizedBox(width: 12),
            Text('¿Qué son los PDE?'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Porcentaje de Distribución de Excedentes (PDE)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              const Text(
                'El PDE es el % del excedente Tipo 2 que se distribuye en los miembros comunitarios según la resoluciòn CREG 101 072 Art 3.4.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Text(
                '¿Por qué crear una oferta?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'El proceso de crear una oferta se hace con el fin de buscar favorabilidad en la asignación de los PDE.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Text(
                'Rango de Precios:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Mínimo: ${Formatters.formatCurrency(minValue, decimals: 2)} COP/kWh',
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                'Máximo: ${Formatters.formatCurrency(maxValue, decimals: 2)} COP/kWh',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              const Text(
                'Los valores mínimo y máximo están limitados para que los consumidores puedan generar un ahorro y los prosumidores un valor agregado sobre el precio mínimo de los mercados regulados.',
                style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // TABS ENERO 2026
  // ============================================================================

  Widget _buildCreateOfferTab() {
    // Mostrar loading mientras se verifica
    if (_isCheckingOffer) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTokens.primaryRed),
        ),
      );
    }

    // Mostrar error si hubo problema al cargar
    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppTokens.space24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppTokens.primaryRed.withValues(alpha: 0.7),
              ),
              SizedBox(height: AppTokens.space16),
              Text(
                'Error al cargar ofertas',
                style: context.textStyles.titleMedium?.copyWith(
                  fontWeight: AppTokens.fontWeightBold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppTokens.space8),
              Text(
                _loadError!,
                style: context.textStyles.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppTokens.space24),
              ElevatedButton.icon(
                onPressed: _checkExistingOffer,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTokens.primaryRed,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTokens.space24,
                    vertical: AppTokens.space12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppTokens.space24),
      child: Column(
        children: [
          // Mostrar resumen compacto de oferta existente si hay una
          if (_hasExistingOffer && _existingOffer != null)
            _buildExistingOfferSummary(_existingOffer!),

          if (_hasExistingOffer && _existingOffer != null)
            SizedBox(height: AppTokens.space24),

          // Card de acción principal (solo si NO hay oferta)
          if (!_hasExistingOffer)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_shopping_cart,
                    size: 80,
                    color: AppTokens.primaryRed.withValues(alpha: 0.7),
                  ),
                  SizedBox(height: AppTokens.space24),
                  Text(
                    'Crear Oferta de Compra',
                    style: context.textStyles.titleLarge?.copyWith(
                      fontWeight: AppTokens.fontWeightBold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppTokens.space12),
                  Text(
                    'Crea ofertas especificando qué % del PDE deseas comprar y a qué precio.',
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppTokens.space32),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConsumerCreateOfferScreen(
                            period: _currentPeriod,
                            myUser: widget.myUser,
                            communityId: widget.communityId,
                          ),
                        ),
                      );
                      _checkExistingOffer();
                      _loadRecentOffers();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Crear Oferta'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTokens.primaryRed,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTokens.space24,
                        vertical: AppTokens.space16,
                      ),
                    ),
                  ),
                  SizedBox(height: AppTokens.space16),
                  OutlinedButton.icon(
                    onPressed: () => _showHowItWorksDialog(),
                    icon: const Icon(Icons.info_outline),
                    label: const Text('¿Cómo funciona?'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showHowItWorksDialog() {
    final minValue = FakeDataJanuary2026.pdeConstantsJan2026.mcmValorEnergiaPromedio * 1.1;
    final maxValue = (FakeDataJanuary2026.pdeConstantsJan2026.costoEnergia -
                      FakeDataJanuary2026.pdeConstantsJan2026.costoComercializacion) * 0.95;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: AppTokens.primaryRed),
            SizedBox(width: 12),
            Text('¿Cómo funciona?'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Modelo de Ofertas PDE',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              const Text(
                '¿Cómo funciona?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('• Los consumidores crean ofertas de compra'),
              const Text('• Las ofertas se basan en % del PDE disponible'),
              const Text('• Un administrador hace la liquidación mensual'),
              const SizedBox(height: 16),
              const Text(
                'Rango de Precios:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Mínimo: ${Formatters.formatCurrency(minValue, decimals: 2)} COP/kWh'),
              Text('Máximo: ${Formatters.formatCurrency(maxValue, decimals: 2)} COP/kWh'),
              const SizedBox(height: 12),
              const Text(
                'Estos límites garantizan ahorro para consumidores y valor agregado para prosumidores.',
                style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  /// Widget compacto que muestra el resumen de la oferta existente con ícono de edición
  Widget _buildExistingOfferSummary(ConsumerOffer offer) {
    const double pdeMesAnterior = 720.0;
    final double tarifaTradicional = FakeDataJanuary2026.pdeConstantsJan2026.costoEnergia;
    final double pdePercentage = offer.pdePercentageRequested * 100;
    final double kwhEstimados = (pdePercentage * pdeMesAnterior) / 100;
    final double ahorroPorKwh = tarifaTradicional - offer.pricePerKwh;
    final double ahorroTotal = ahorroPorKwh * kwhEstimados;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTokens.primaryRed,
            AppTokens.primaryRed.withValues(alpha: 0.85),
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
          // Header con ícono de edición
          Container(
            padding: EdgeInsets.all(AppTokens.space16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.only(
                topLeft: AppTokens.borderRadiusLarge.topLeft,
                topRight: AppTokens.borderRadiusLarge.topRight,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 24),
                SizedBox(width: AppTokens.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tu Oferta Actual',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: AppTokens.fontWeightBold,
                        ),
                      ),
                      Text(
                        _currentPeriodDisplayName,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                // Ícono de lápiz para editar
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  tooltip: 'Modificar Oferta',
                  onPressed: _editOffer,
                ),
              ],
            ),
          ),

          // Contenido principal compacto
          Padding(
            padding: EdgeInsets.all(AppTokens.space16),
            child: Column(
              children: [
                // PDE y Precio en fila
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetricColumn('PDE Solicitado', '${Formatters.formatEnergy(pdePercentage, unit: '', decimals: 2)}%'),
                    _buildMetricColumn('Precio', Formatters.formatCurrency(offer.pricePerKwh), subtitle: 'COP/kWh'),
                  ],
                ),

                SizedBox(height: AppTokens.space16),

                // Energía estimada
                _buildInfoRow(
                  Icons.electric_bolt,
                  'Recibirás aprox.',
                  Formatters.formatEnergy(kwhEstimados, decimals: 2),
                  AppTokens.white,
                ),

                SizedBox(height: AppTokens.space12),

                // Ahorro total
                _buildInfoRow(
                  Icons.savings,
                  'Ahorro vs Tradicional',
                  Formatters.formatCurrency(ahorroTotal),
                  Colors.white,
                ),

                SizedBox(height: AppTokens.space16),

                // Botón de cancelar oferta
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _cancelOffer,
                    icon: const Icon(Icons.cancel, size: 18),
                    label: const Text('Cancelar Oferta'),
                    style: OutlinedButton.styleFrom(
                      
                      foregroundColor: AppTokens.white,
                      side: const BorderSide(color: Colors.white, width: 1.5),
                      padding: EdgeInsets.symmetric(vertical: AppTokens.space12),
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

  /// Widget reutilizable para mostrar métricas
  Widget _buildMetricColumn(String label, String value, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
        SizedBox(height: AppTokens.space4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: AppTokens.fontWeightBold,
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 11,
            ),
          ),
      ],
    );
  }

  /// Widget reutilizable para filas de información
  Widget _buildInfoRow(IconData icon, String label, String value, Color iconColor) {
    return Container(
      padding: EdgeInsets.all(AppTokens.space12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: AppTokens.borderRadiusMedium,
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              SizedBox(width: AppTokens.space8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 13,
                  fontWeight: AppTokens.fontWeightSemiBold,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: AppTokens.fontWeightBold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyOffersTab() {
    if (_isLoadingOffers) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTokens.primaryRed),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: AppTokens.space16),

          // Widget de ofertas recientes (máx 3)
          MyOffersCard(
            offers: _recentOffers,
            onViewAll: () {
              // Navegar a la pantalla de todas las ofertas
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyOffersScreen(
                    myUser: widget.myUser,
                    communityId: widget.communityId,
                  ),
                ),
              ).then((_) {
                // Recargar ofertas al volver
                _loadRecentOffers();
              });
            },
          ),

          SizedBox(height: AppTokens.space24),

          // Información adicional
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppTokens.space16),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(AppTokens.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: AppTokens.primaryBlue,
                        ),
                        SizedBox(width: AppTokens.space8),
                        Text(
                          'Estados de Ofertas',
                          style: context.textStyles.titleSmall?.copyWith(
                            fontWeight: AppTokens.fontWeightBold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppTokens.space12),
                    _buildStatusInfo(
                      Icons.schedule,
                      Colors.orange,
                      'Pendiente',
                      'Oferta creada, esperando liquidación',
                    ),
                    SizedBox(height: AppTokens.space8),
                    _buildStatusInfo(
                      Icons.check_circle,
                      AppTokens.energyGreen,
                      'Confirmada',
                      'Oferta 100% satisfecha con energía asignada',
                    ),
                    SizedBox(height: AppTokens.space8),
                    _buildStatusInfo(
                      Icons.pie_chart,
                      Colors.blue,
                      'Parcial',
                      'Solo se cumplió parte del % solicitado',
                    ),
                    SizedBox(height: AppTokens.space8),
                    _buildStatusInfo(
                      Icons.cancel,
                      Colors.grey,
                      'Cancelada',
                      'Oferta cancelada por el usuario',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusInfo(IconData icon, Color color, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        SizedBox(width: AppTokens.space8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: AppTokens.fontWeightSemiBold,
                  fontSize: 13,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
