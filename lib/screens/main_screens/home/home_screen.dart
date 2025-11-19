import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/utils/formatters.dart';
import 'package:be_energy/routes.dart';
import 'package:be_energy/utils/metodos.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../models/callmodels.dart';

class HomeScreen extends StatefulWidget {
  final MyUser? myUser;
  const HomeScreen({super.key, this.myUser});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  Metodos metodos = Metodos();

  final data = [
    {
      'numTransaccion': 1,
      'entrada': true,
      'nombre': 'Estiven Hoyos',
      'dinero':  ' \$ 500.00',
      'energia':  '25 kWh',
      'fecha':  '25-Feb',
      'fuente':  'Solar'
    },
    {
      'numTransaccion': 2,
      'entrada': true,
      'nombre': 'Angel Hoyos',
      'dinero':  ' \$ 240.00',
      'energia':  '5 kWh',
      'fecha':  '27-Feb',
      'fuente':  'Solar'
    },
    {
      'numTransaccion': 3,
      'entrada': false,
      'nombre': 'Clara Velandia',
      'dinero':  ' \$ 150.00',
      'energia':  '8 kWh',
      'fecha':  '28-Feb',
      'fuente':  'Solar'
    }
  ];

  List<GGData> _getChartData() {
    final List<GGData> chartData = [
      GGData('Directa Solar', 100),
      GGData('Red', 150),
      GGData('Bateria', 125),
      GGData('Intercambios', 25),
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
    return Column(
      children: [
        _energyCard(
          title: "Importe",
          energy: -20,
          amount: 5720,
          icon: Icons.trending_down_rounded,
          color: AppTokens.error,
        ),
        SizedBox(height: AppTokens.space8),
        _energyCard(
          title: "Exporte",
          energy: 50,
          amount: 14300,
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
            "Tus movimientos mensuales",
            style: context.textStyles.titleLarge?.copyWith(
              fontWeight: AppTokens.fontWeightSemiBold,
            ),
          ),
          SizedBox(height: AppTokens.space4),
          Text(
            "kWh",
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
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
      child: Row(
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
            1,
            Icons.bookmark_outline_rounded,
          ),
        ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: metodos.appbarPrincipal(
        context,
        widget.myUser?.nombre ?? "Usuario"
      ),
      backgroundColor: context.colors.background,
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
