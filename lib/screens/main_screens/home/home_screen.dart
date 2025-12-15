import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/utils/formatters.dart';
import 'package:be_energy/routes.dart';
import 'package:be_energy/utils/metodos.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../models/callmodels.dart';
import '../../../data/fake_data.dart';
import '../../../data/fake_data_phase2.dart';

class HomeScreen extends StatefulWidget {
  final MyUser? myUser;
  const HomeScreen({super.key, this.myUser});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Metodos metodos = Metodos();
  String _selectedPeriod = '2025-12'; // '2025-12' = Diciembre, '2025-11' = Noviembre
  bool _isAdminView = false; // Vista de usuario por defecto

  // Transacciones P2P según período seleccionado
  List<Map<String, dynamic>> get data {
    final isCurrentMonth = _selectedPeriod == '2025-12';
    final contracts = isCurrentMonth
        ? FakeDataPhase2.allContracts.take(5).toList()
        : FakeData.p2pContracts.take(5).toList();
    return contracts.asMap().entries.map((entry) {
      final index = entry.key;
      final contract = entry.value;
      // Determinar si es entrada (venta) o salida (compra) basado en el userId
      final isIncome = contract.sellerId == (widget.myUser?.idUser ?? 24);
      final nombre = isIncome ? contract.buyerName : contract.sellerName;

      // Formatear fecha manualmente sin locale (evita error de inicialización)
      final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
      final fecha = '${contract.createdAt.day}-${months[contract.createdAt.month - 1]}';

      return {
        'numTransaccion': index + 1,
        'entrada': isIncome,
        'nombre': nombre,
        'dinero': Formatters.formatCurrency(contract.totalValue),
        'energia': Formatters.formatEnergy(contract.energyCommitted),
        'fecha': fecha,
        'fuente': 'P2P'
      };
    }).toList();
  }

  List<GGData> _getChartData() {
    // Datos según vista (Admin/Usuario) y período seleccionado
    final isCurrentMonth = _selectedPeriod == '2025-12';

    // Seleccionar datos según vista
    final stats = _isAdminView
      ? (isCurrentMonth ? FakeDataPhase2.communityStats : FakeData.communityStats)
      : (isCurrentMonth ? FakeDataPhase2.cristianIndividualStatsDec2025 : FakeData.cristianIndividualStatsNov2025);

    // Calcular intercambios P2P según contratos del período y vista
    final p2pEnergy = isCurrentMonth
        ? (_isAdminView
          ? FakeDataPhase2.allContracts.fold<double>(0, (sum, c) => sum + c.energyCommitted).toInt()
          : 50) // Cristian individual: 50 kWh P2P
        : (_isAdminView
          ? 650 // Comunidad: 650 kWh
          : 30); // Cristian individual: 30 kWh

    final List<GGData> chartData = [
      GGData('Directa Solar', stats.totalEnergyGenerated.toInt()),
      GGData('Red', stats.totalEnergyImported.toInt()),
      GGData('Intercambios P2P', p2pEnergy),
    ];
    return chartData;
  }

  Widget _grafico() {
    List<GGData> dataCircularSeries = _getChartData();
    return SfCircularChart(
      legend: Legend(
        isVisible: true,
        overflowMode: LegendItemOverflowMode.wrap,
        textStyle: context.textStyles.bodySmall?.copyWith(
          fontSize: AppTokens.fontSize10,
        ),
        position: LegendPosition.bottom,
      ),
      series: <CircularSeries>[
        DoughnutSeries<GGData, String>(
          dataSource: dataCircularSeries,
          xValueMapper: (data, _) => data.fuente,
          yValueMapper: (datum, _) => datum.consumo,
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            labelPosition: ChartDataLabelPosition.outside,
            connectorLineSettings: ConnectorLineSettings(
              type: ConnectorType.curve,
              length: '10%',
            ),
            textStyle: TextStyle(
              color: context.colors.onSurface,
              fontSize: AppTokens.fontSize10,
              fontWeight: AppTokens.fontWeightMedium,
            ),
          ),
        )
      ],
    );
  }

  Widget _trData() {
    // Datos según vista (Admin/Usuario) y período seleccionado
    final isCurrentMonth = _selectedPeriod == '2025-12';

    // Seleccionar datos según vista
    final stats = _isAdminView
      ? (isCurrentMonth ? FakeDataPhase2.communityStats : FakeData.communityStats)
      : (isCurrentMonth ? FakeDataPhase2.cristianIndividualStatsDec2025 : FakeData.cristianIndividualStatsNov2025);

    final importEnergy = stats.totalEnergyImported;
    final exportEnergy = stats.totalEnergyExported;

    // Cálculo de costos según período
    final costPerKwh = isCurrentMonth
        ? 450.0 // Diciembre: usar tarifa base VE
        : FakeData.regulatedCosts.totalCostPerKwh; // Noviembre: usar datos existentes

    return Column(
      children: [
        _energyCard(
          title: "Importe",
          energy: importEnergy,
          amount: importEnergy * costPerKwh,
          icon: Icons.trending_down_rounded,
          color: AppTokens.error,
        ),
        SizedBox(height: AppTokens.space8),
        _energyCard(
          title: "Exporte",
          energy: exportEnergy,
          amount: exportEnergy * costPerKwh,
          icon: Icons.trending_up_rounded,
          color: AppTokens.primaryRed,
        ),
      ],
    );
  }

  /// Widget reutilizable para mostrar tarjetas de energía (import/export)
  Widget _energyCard({
    required String title,
    required double energy,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppTokens.borderRadiusMedium,
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppTokens.space12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: AppTokens.borderRadiusSmall,
            ),
            child: Icon(
              icon,
              size: 28,
              color: color,
            ),
          ),
          SizedBox(width: AppTokens.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textStyles.labelSmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    fontWeight: AppTokens.fontWeightMedium,
                  ),
                ),
                SizedBox(height: AppTokens.space8),
                Text(
                  Formatters.formatEnergy(energy),
                  style: context.textStyles.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: AppTokens.fontWeightBold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppTokens.space4),
                Text(
                  Formatters.formatCurrency(amount),
                  style: context.textStyles.titleMedium?.copyWith(
                    color: color,
                    fontWeight: AppTokens.fontWeightSemiBold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _saludoText() {
    // Determinar datos según vista (Admin/Usuario) y período seleccionado
    final isCurrentMonth = _selectedPeriod == '2025-12';
    final periodLabel = isCurrentMonth ? 'Diciembre 2025' : 'Noviembre 2025';

    // Texto descriptivo según vista
    final viewLabel = _isAdminView ? 'Comunidad UAO' : 'Mi Energía';
    final totalMembers = _isAdminView
      ? (isCurrentMonth ? FakeDataPhase2.allMembers.length : FakeData.communityStats.totalMembers)
      : 1; // Vista usuario: solo 1 (Cristian)
    final membersLabel = _isAdminView ? '$totalMembers miembros' : 'Vista Individual';

    return Container(
      width: context.width,
      padding: EdgeInsets.symmetric(
        horizontal: AppTokens.space16,
        vertical: AppTokens.space12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            viewLabel,
            style: context.textStyles.titleLarge?.copyWith(
              fontWeight: AppTokens.fontWeightBold,
            ),
          ),
          SizedBox(height: AppTokens.space4),
          Text(
            "$periodLabel • $membersLabel",
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Indicador visual compacto de estado mensual con botón para cambiar período
  Widget _buildMonthlyStatusIndicator() {
    final isCurrentMonth = _selectedPeriod == '2025-12';
    final statusColor = isCurrentMonth ? AppTokens.energyGreen : Colors.grey;
    final statusIcon = isCurrentMonth ? Icons.autorenew_rounded : Icons.lock_outline;
    final statusText = isCurrentMonth ? 'MES EN CURSO' : 'MES CERRADO';
    final periodLabel = isCurrentMonth ? 'Diciembre 2025' : 'Noviembre 2025';

    return InkWell(
      onTap: _showPeriodSelectorModal,
      borderRadius: AppTokens.borderRadiusMedium,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
        padding: EdgeInsets.all(AppTokens.space12),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          borderRadius: AppTokens.borderRadiusMedium,
          border: Border.all(
            color: statusColor.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Indicador pulsante para mes en curso
            if (isCurrentMonth)
              Container(
                width: 10,
                height: 10,
                margin: EdgeInsets.only(right: AppTokens.space8),
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withValues(alpha: 0.6),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              )
            else
              Container(
                margin: EdgeInsets.only(right: AppTokens.space8),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: 16,
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusText,
                    style: context.textStyles.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: AppTokens.fontWeightBold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: AppTokens.space4),
                  Text(
                    periodLabel,
                    style: context.textStyles.bodyMedium?.copyWith(
                      fontWeight: AppTokens.fontWeightSemiBold,
                    ),
                  ),
                ],
              ),
            ),
            // Botón de cambio de período
            Container(
              padding: EdgeInsets.all(AppTokens.space8),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: AppTokens.borderRadiusSmall,
              ),
              child: Icon(
                Icons.swap_horiz_rounded,
                color: statusColor,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Muestra modal de selección de período
  void _showPeriodSelectorModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: this.context.colors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppTokens.space20),
              topRight: Radius.circular(AppTokens.space20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: AppTokens.space12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: this.context.colors.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: AppTokens.space16),
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppTokens.space20),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      color: this.context.colors.primary,
                      size: 24,
                    ),
                    SizedBox(width: AppTokens.space12),
                    Text(
                      'Seleccionar Período',
                      style: this.context.textStyles.titleLarge?.copyWith(
                        fontWeight: AppTokens.fontWeightBold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppTokens.space20),
              // Opciones de período
              _buildModalPeriodOption(
                period: '2025-12',
                title: 'Diciembre 2025',
                subtitle: 'Mes en Curso - Transaccional',
                icon: Icons.bolt_rounded,
                iconColor: AppTokens.energyGreen,
                badge: '🔄',
              ),
              Divider(height: 1, color: this.context.colors.outline.withValues(alpha: 0.1)),
              _buildModalPeriodOption(
                period: '2025-11',
                title: 'Noviembre 2025',
                subtitle: 'Histórico - Solo lectura',
                icon: Icons.history_rounded,
                iconColor: Colors.grey,
                badge: '📊',
              ),
              SizedBox(height: AppTokens.space20),
            ],
          ),
        );
      },
    );
  }

  /// Opción de período en el modal
  Widget _buildModalPeriodOption({
    required String period,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required String badge,
  }) {
    final isSelected = _selectedPeriod == period;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
        });
        Navigator.pop(context);
        context.showInfoSnackbar('Período cambiado a $title');
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppTokens.space20,
          vertical: AppTokens.space16,
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(AppTokens.space12),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: AppTokens.borderRadiusSmall,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            SizedBox(width: AppTokens.space16),
            // Text info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: context.textStyles.bodyLarge?.copyWith(
                          fontWeight: AppTokens.fontWeightSemiBold,
                        ),
                      ),
                      SizedBox(width: AppTokens.space8),
                      Text(
                        badge,
                        style: TextStyle(fontSize: AppTokens.fontSize16),
                      ),
                    ],
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
            // Checkmark
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: iconColor,
                size: 24,
              )
            else
              Icon(
                Icons.radio_button_unchecked,
                color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _indicadores() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
      padding: EdgeInsets.all(AppTokens.space12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppTokens.borderRadiusLarge,
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _grafico(),
          ),
          SizedBox(width: AppTokens.space12),
          Expanded(
            flex: 3,
            child: _trData(),
          )
        ],
      ),
    );
  }

  Widget _btnActividadIcon(String nombre, BuildContext context, int onTap, IconData icon) {
    return Expanded(
      flex: 1,
      child: InkWell(
        onTap: () {
          switch (onTap) {
            case 1:
              context.push(const TradingScreen());
              break;
            case 2:
              context.push(const BolsaScreen());
              break;
            case 3:
              context.push(
                AprendeScreen(myUser: widget.myUser!)
              );
              break;
            default:
              context.push(const TradingScreen());

              break;
          }
        },
        borderRadius: AppTokens.borderRadiusMedium,
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: AppTokens.space16,
            horizontal: AppTokens.space12,
          ),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: AppTokens.borderRadiusMedium,
            border: Border.all(
              color: context.colors.outline.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(AppTokens.space12),
                decoration: BoxDecoration(
                  color: context.colors.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: AppTokens.borderRadiusSmall,
                ),
                child: Icon(
                  icon,
                  color: context.colors.primary,
                  size: 24,
                ),
              ),
              SizedBox(height: AppTokens.space8),
              Text(
                nombre,
                style: context.textStyles.labelMedium,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actividades() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
      child: Column(
        children: [
          // Vista Admin: Mostrar Gestión de la Comunidad primero y destacado
          if (_isAdminView) ...[
            _buildCommunityManagementButton(),
            SizedBox(height: AppTokens.space12),
          ],
          // Actividades comunes para ambas vistas
          Row(
            children: [
              _btnActividadIcon(
                "Transferir",
                context,
                1,
                Icons.swap_horiz_rounded,
              ),
              SizedBox(width: AppTokens.space12),
              _btnActividadIcon(
                "Bolsa",
                context,
                2,
                Icons.account_balance_outlined,
              ),
              SizedBox(width: AppTokens.space12),
              _btnActividadIcon(
                "Aprende",
                context,
                3,
                Icons.bookmark_outline_rounded,
              ),
            ],
          ),
          // Vista Usuario: No mostrar Gestión de la Comunidad (solo para admins)
        ],
      ),
    );
  }

  /// Botón de Gestión de la Comunidad
  Widget _buildCommunityManagementButton() {
    return InkWell(
            onTap: () {
              context.push(const CommunityManagementScreen());
            },
            borderRadius: AppTokens.borderRadiusMedium,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: AppTokens.space16,
                horizontal: AppTokens.space16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTokens.primaryRed,
                    AppTokens.primaryRed.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: AppTokens.borderRadiusMedium,
                boxShadow: [
                  BoxShadow(
                    color: AppTokens.primaryRed.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.groups_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: AppTokens.space12),
                  Text(
                    "Gestión de la Comunidad",
                    style: context.textStyles.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: AppTokens.fontWeightBold,
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget _miniListHistorial() {
    return ListView.separated(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.length,
      separatorBuilder: (context, index) => SizedBox(height: AppTokens.space8),
      itemBuilder: (BuildContext context, int index) {
        final transaction = data[index];
        final bool isIncome = transaction['entrada'] as bool;
        final color = isIncome ? AppTokens.primaryRed : AppTokens.error;

        return InkWell(
          onTap: () {
            // TODO: Navegar a detalle de transacción
            context.showInfoSnackbar(
              "Transacción #${transaction['numTransaccion']}"
            );
          },
          borderRadius: AppTokens.borderRadiusMedium,
          child: Container(
            padding: EdgeInsets.all(AppTokens.space12),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: AppTokens.borderRadiusMedium,
              border: Border.all(
                color: context.colors.outline.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Icon Container
                Container(
                  padding: EdgeInsets.all(AppTokens.space8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: AppTokens.borderRadiusSmall,
                  ),
                  child: Icon(
                    isIncome ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                    size: 20,
                    color: color,
                  ),
                ),
                SizedBox(width: AppTokens.space12),
                // Transaction Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${transaction['nombre']}",
                        style: context.textStyles.bodyMedium?.copyWith(
                          fontWeight: AppTokens.fontWeightMedium,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: AppTokens.space4),
                      Text(
                        "${transaction['fuente']} • ${transaction['energia']}",
                        style: context.textStyles.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppTokens.space8),
                // Amount & Date
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${transaction['dinero']}",
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: color,
                        fontWeight: AppTokens.fontWeightBold,
                      ),
                    ),
                    SizedBox(height: AppTokens.space4),
                    Text(
                      "${transaction['fecha']}",
                      style: context.textStyles.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _titulobtnHistorial() {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTokens.space12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Transacciones",
            style: context.textStyles.titleMedium?.copyWith(
              fontWeight: AppTokens.fontWeightSemiBold,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.arrow_forward_rounded,
              size: 24,
              color: context.colors.primary,
            ),
            tooltip: "Ver todas",
            onPressed: () {
              // TODO: Navegar a la pantalla de historial completo
              context.showInfoSnackbar("Próximamente: Ver historial completo");
            },
          ),
        ],
      ),
    );
  }

  Widget _minihostiral() {
    return Container(
      padding: EdgeInsets.all(AppTokens.space16),
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppTokens.borderRadiusLarge,
      ),
      child: Column(
        children: [
          _titulobtnHistorial(),
          _miniListHistorial(),
        ],
      ),
    );
  }

  Widget body() {
    return ListView(
      padding: EdgeInsets.only(
        top: AppTokens.space16,
        bottom: AppTokens.space24,
      ),
      children: [
        _saludoText(),
        SizedBox(height: AppTokens.space16),
        // Indicador visual de estado mensual con selector de período
        _buildMonthlyStatusIndicator(),
        SizedBox(height: AppTokens.space16),
        _indicadores(),
        SizedBox(height: AppTokens.space24),
        Padding(
          padding: EdgeInsets.only(
            left: AppTokens.space16,
            bottom: AppTokens.space12,
          ),
          child: Text(
            "Actividades",
            style: context.textStyles.titleMedium?.copyWith(
              fontWeight: AppTokens.fontWeightSemiBold,
            ),
          ),
        ),
        _actividades(),
        SizedBox(height: AppTokens.space24),
        _minihostiral(),
      ],
    );
  }

  /// AppBar personalizado con botón de cambio de vista
  PreferredSizeWidget _buildAppBar() {
    final userName = widget.myUser?.nombre ?? "Cristian";

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
      title: Container(
        margin: const EdgeInsets.only(top: 7.5, bottom: 7.5, right: 5.0, left: 5.0),
        child: Row(
          children: [
            // Avatar
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: const Image(
                alignment: AlignmentDirectional.center,
                image: AssetImage("assets/img/avatar.jpg"),
                width: 55.0,
                height: 55.0,
              ),
            ),
            const SizedBox(width: 15.0),
            // Saludo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "¡Hola,",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "$userName!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        // Botón de cambio de vista Admin/Usuario
        Container(
          width: 45.0,
          height: 45.0,
          decoration: BoxDecoration(
            color: _isAdminView ? AppTokens.primaryRed : AppTokens.info,
            border: Border.all(width: 2.0, color: Colors.white),
            borderRadius: BorderRadius.circular(25.0),
          ),
          margin: const EdgeInsets.only(top: 7.5, bottom: 7.5, right: 10.0),
          child: IconButton(
            icon: Icon(
              _isAdminView ? Icons.admin_panel_settings : Icons.person,
              size: 22.0,
            ),
            color: Colors.white,
            tooltip: _isAdminView ? "Vista Administrador" : "Vista Usuario",
            onPressed: () {
              setState(() {
                _isAdminView = !_isAdminView;
              });
              context.showInfoSnackbar(
                _isAdminView ? 'Vista: Administrador Comunitario' : 'Vista: Usuario'
              );
            },
          ),
        ),
        // Botón de notificaciones
        Container(
          width: 45.0,
          height: 45.0,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(width: 2.0, color: Colors.white),
            borderRadius: BorderRadius.circular(25.0),
          ),
          margin: const EdgeInsets.only(top: 7.5, bottom: 7.5, right: 15.0),
          child: IconButton(
            icon: const Icon(Icons.notifications, size: 25.0),
            color: AppTokens.primaryBlue,
            tooltip: "Notificaciones",
            onPressed: () {
              context.showInfoSnackbar("Notificaciones");
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: context.colors.surface,
      body: body(),
    );
  }
}

//Generation grid data
class GGData {
  late final String fuente;
  late final int consumo;

  GGData(this.fuente, this.consumo);
}
