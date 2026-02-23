// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/utils/formatters.dart';
import '../../../data/constants.dart';
import '../../../data/fake_data.dart';
import '../../../models/my_user.dart';
import '../../../utils/metodos.dart';
import 'package:fl_chart/fl_chart.dart';

class EnergyScreen extends StatefulWidget {
  final MyUser? myUser;
  const EnergyScreen({super.key, this.myUser});

  @override
  State<EnergyScreen> createState() => _EnergyScreenState();
}

class _EnergyScreenState extends State<EnergyScreen> {

  Metodos metodos = Metodos();
  bool casaVal = true;

  // Obtener datos del prosumidor (usuario 24 - Andrea Martínez)
  late final userRecord = FakeData.energyRecords.firstWhere(
    (record) => record.userId == (widget.myUser?.idUser ?? 24),
    orElse: () => FakeData.energyRecords[11], // Default: usuario 24
  );

  late final memberData = FakeData.members.firstWhere(
    (member) => member.userId == (widget.myUser?.idUser ?? 24),
    orElse: () => FakeData.members[11], // Default: usuario 24
  );


  Widget _imagen(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: AppTokens.space8,
            right: AppTokens.space4,
            bottom: AppTokens.space4,
          ),
          child: const Image(
            alignment: AlignmentDirectional.center,
            image: AssetImage("assets/img/ecoHouse.jpg"),
            width: 205.0,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppTokens.space8,
            vertical: AppTokens.space8,
          ),
          child: Column(
            children: [
              Text(
                Formatters.formatPower(memberData.installedCapacity),
                style: context.textStyles.headlineMedium?.copyWith(
                  fontWeight: AppTokens.fontWeightBold,
                ),
              ),
              SizedBox(height: AppTokens.space4),
              Text(
                "Capacidad",
                style: context.textStyles.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              SizedBox(height: AppTokens.space24),
              Text(
                Formatters.formatEnergy(userRecord.energyConsumed),
                style: context.textStyles.headlineMedium?.copyWith(
                  fontWeight: AppTokens.fontWeightBold,
                ),
              ),
              SizedBox(height: AppTokens.space4),
              Text(
                "Consumo Mensual",
                style: context.textStyles.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          )
        ),
      ],
    );
  }
  Widget _indicadoresCasa(){
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppTokens.space16,
        vertical: AppTokens.space8,
      ),
      padding: EdgeInsets.all(AppTokens.space12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppTokens.borderRadiusLarge,
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // Weather info header
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(right: AppTokens.space8),
                child: const Image(
                  alignment: AlignmentDirectional.center,
                  image: AssetImage("assets/img/cloudy.png"),
                  width: 30.0,
                  height: 30.0,
                ),
              ),
              Text(
                "27 °C - Tulúa",
                style: context.textStyles.titleMedium?.copyWith(
                  fontWeight: AppTokens.fontWeightSemiBold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space12),
          // Date and Switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "5",
                      style: context.textStyles.displayMedium?.copyWith(
                        fontWeight: AppTokens.fontWeightBold,
                      ),
                    ),
                    SizedBox(width: AppTokens.space4),
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: AppTokens.space8),
                        child: Text(
                          "Dic 2025",
                          style: context.textStyles.titleMedium?.copyWith(
                            fontWeight: AppTokens.fontWeightSemiBold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    (casaVal) ? "Almacenar" : "Exportar",
                    style: context.textStyles.labelSmall?.copyWith(
                      fontWeight: AppTokens.fontWeightBold,
                    ),
                  ),
                  Transform.scale(
                    scale: 0.7, // 0.7 = más pequeño (puedes ajustar)
                    child: Switch(
                      value: casaVal,
                      activeThumbColor: context.colors.primary,
                      onChanged: (bool value) {
                        setState(() {
                          casaVal = value;
                        });
                      },
                    ),
                  )

                ],
              )
            ],
          ),
          SizedBox(height: AppTokens.space12),
          _imagen()
        ]
      )
    );
  }
  
  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          height: 14,
          width: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: AppTokens.borderRadiusSmall,
          ),
        ),
        SizedBox(width: AppTokens.space4),
        Text(
          label,
          style: context.textStyles.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _figura1() {
    return const LineChartSample();
  }

  Widget _figura2() {
    return const LineChartSample1();
  }

  Widget _indicadoresLine(){
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppTokens.space16,
        vertical: AppTokens.space8,
      ),
      padding: EdgeInsets.all(AppTokens.space12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppTokens.borderRadiusLarge,
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: AppTokens.space8),
            child: Text(
              "Análisis Horario Completo",
              style: context.textStyles.titleMedium?.copyWith(
                fontWeight: AppTokens.fontWeightSemiBold,
              ),
            ),
          ),
          // Leyenda
          Wrap(
            spacing: AppTokens.space12,
            runSpacing: AppTokens.space4,
            children: [
              _legendItem('Consumo',        const Color(0xFF0000FF)),
              _legendItem('Producción Solar',const Color(0xFFFFFF00)),
              _legendItem('Autoconsumo',     const Color(0xFF90EE90)),
              _legendItem('Importada',       const Color(0xFFFA8072)),
              _legendItem('Exportada',       const Color(0xFFDA70D6)),
            ],
          ),
          SizedBox(height: AppTokens.space4),
          _figura1()
        ]
      )
    );
  }


  Widget _indicadoresLine2(){
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppTokens.space16,
        vertical: AppTokens.space8,
      ),
      padding: EdgeInsets.all(AppTokens.space12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppTokens.borderRadiusLarge,
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // Title
          Padding(
            padding: EdgeInsets.only(bottom: AppTokens.space12),
            child: Text(
              "Potencia exporta e importada mensual",
              style: context.textStyles.titleMedium?.copyWith(
                fontWeight: AppTokens.fontWeightSemiBold,
              ),
            ),
          ),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Potencia importada
              Row(
                children: [
                  Container(
                    height: 15,
                    width: 15,
                    margin: EdgeInsets.only(right: AppTokens.space8),
                    decoration: BoxDecoration(
                      color: Color(int.parse("0xff${ColorsApp.color2}")),
                      borderRadius: AppTokens.borderRadiusSmall,
                    ),
                  ),
                  Text(
                    "Potencia importada",
                    style: context.textStyles.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              // Potencia exporta
              Row(
                children: [
                  Container(
                    height: 15,
                    width: 15,
                    margin: EdgeInsets.only(right: AppTokens.space8),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: AppTokens.borderRadiusSmall,
                    ),
                  ),
                  Text(
                    "Potencia exporta",
                    style: context.textStyles.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: AppTokens.space8),
          // Demanda
          Row(
            children: [
              Container(
                height: 15,
                width: 15,
                margin: EdgeInsets.only(right: AppTokens.space8),
                decoration: BoxDecoration(
                  color: Color(int.parse("0xff${ColorsApp.color4}")),
                  borderRadius: AppTokens.borderRadiusSmall,
                ),
              ),
              Text(
                "Demanda",
                style: context.textStyles.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space12),
          _figura2()
        ]
      )
    );
  }

  Widget body(){
    return ListView(
      padding: EdgeInsets.only(
        top: AppTokens.space8,
        bottom: AppTokens.space24,
      ),
      children: <Widget>[
        _indicadoresCasa(),
        _indicadoresLine(),
        _indicadoresLine2(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: metodos.appbarEnergia(
        context,
        widget.myUser?.nombre ?? "Usuario"
      ),
      backgroundColor: context.colors.surface,
      body: body(),
    );
  }
}

/// Gráfico de análisis horario completo con 5 series:
/// Consumo (línea azul), Producción Solar (línea amarilla),
/// Autoconsumo (área verde), Importada (área salmón), Exportada (área rosa/morada)
class LineChartSample extends StatelessWidget {
  const LineChartSample({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: Padding(
        padding: EdgeInsets.only(
          right: AppTokens.space8,
          left: AppTokens.space4,
          top: AppTokens.space12,
          bottom: AppTokens.space8,
        ),
        child: LineChart(_buildChartData(context)),
      ),
    );
  }

  // ─── Colores de la imagen de referencia ───
  static const Color _colorConsumo   = Color(0xFF0000FF); // azul
  static const Color _colorSolar     = Color(0xFFFFFF00); // amarillo
  static const Color _colorAutoconsumo = Color(0xFF90EE90); // verde claro
  static const Color _colorImportada = Color(0xFFFA8072); // salmón
  static const Color _colorExportada = Color(0xFFDA70D6); // orchid/rosa

  LineChartData _buildChartData(BuildContext context) {
    final data = FakeData.hourlyAnalysis;

    // Serie 1: Consumo (línea sólida azul, sin área)
    final consumoSpots = data.map((d) => FlSpot(d.hour.toDouble(), d.consumption)).toList();

    // Serie 2: Producción Solar (línea sólida amarilla, sin área)
    final solarSpots = data.map((d) => FlSpot(d.hour.toDouble(), d.solarProd)).toList();

    // Serie 3: Autoconsumo (área verde bajo la línea de consumo)
    final autoconsumoSpots = data.map((d) => FlSpot(d.hour.toDouble(), d.selfConsumption)).toList();

    // Serie 4: Importada (área salmón)
    final importadaSpots = data.map((d) => FlSpot(d.hour.toDouble(), d.gridImport)).toList();

    // Serie 5: Exportada (área rosa/morada)
    final exportadaSpots = data.map((d) => FlSpot(d.hour.toDouble(), d.gridExport)).toList();

    return LineChartData(
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (spot) => Colors.white.withValues(alpha: 0.95),
          maxContentWidth: 200,
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((spot) {
              final labels = ['Consumo', 'Solar', 'Autoconsumo', 'Importada', 'Exportada'];
              final colors = [_colorConsumo, _colorSolar, _colorAutoconsumo, _colorImportada, _colorExportada];
              final idx = spot.barIndex;
              return LineTooltipItem(
                '${labels[idx]}: ${spot.y.toStringAsFixed(2)} kWh/h',
                TextStyle(color: colors[idx], fontWeight: FontWeight.bold, fontSize: 11),
              );
            }).toList();
          },
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        verticalInterval: 3,
        horizontalInterval: 0.1,
        getDrawingHorizontalLine: (value) => FlLine(
          color: context.colors.outline.withValues(alpha: 0.15),
          strokeWidth: 0.5,
        ),
        getDrawingVerticalLine: (value) => FlLine(
          color: context.colors.outline.withValues(alpha: 0.15),
          strokeWidth: 0.5,
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 24,
            interval: 3,
            getTitlesWidget: (value, meta) {
              final style = context.textStyles.labelSmall?.copyWith(
                fontSize: AppTokens.fontSize10,
                color: context.colors.onSurfaceVariant,
              );
              return SideTitleWidget(
                meta: meta,
                child: Text('${value.toInt()}', style: style),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 38,
            interval: 0.1,
            getTitlesWidget: (value, meta) {
              // Solo mostrar etiquetas en 0, 0.2, 0.4, 0.6
              if (value == 0.0 || value == 0.2 || value == 0.4 || value == 0.6) {
                final style = context.textStyles.labelSmall?.copyWith(
                  fontSize: AppTokens.fontSize10,
                  color: context.colors.onSurfaceVariant,
                );
                return Text(value.toStringAsFixed(1), style: style, textAlign: TextAlign.right);
              }
              return const SizedBox();
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      minX: 0,
      maxX: 23,
      minY: 0,
      maxY: 0.7,
      lineBarsData: [
        // 0: Consumo – línea azul sólida, sin área
        LineChartBarData(
          spots: consumoSpots,
          isCurved: false,
          color: _colorConsumo,
          barWidth: 2.5,
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(show: false),
        ),
        // 1: Producción Solar – línea amarilla sólida, sin área
        LineChartBarData(
          spots: solarSpots,
          isCurved: false,
          color: _colorSolar,
          barWidth: 2.5,
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(show: false),
        ),
        // 2: Autoconsumo – área verde (bajo consumo)
        LineChartBarData(
          spots: autoconsumoSpots,
          isCurved: false,
          color: _colorAutoconsumo,
          barWidth: 0,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: _colorAutoconsumo.withValues(alpha: 0.55),
          ),
        ),
        // 3: Importada – área salmón
        LineChartBarData(
          spots: importadaSpots,
          isCurved: false,
          color: _colorImportada,
          barWidth: 0,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: _colorImportada.withValues(alpha: 0.45),
          ),
        ),
        // 4: Exportada – área rosa/morada
        LineChartBarData(
          spots: exportadaSpots,
          isCurved: false,
          color: _colorExportada,
          barWidth: 0,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: _colorExportada.withValues(alpha: 0.45),
          ),
        ),
      ],
    );
  }
}



class _LineChart extends StatelessWidget {
  const _LineChart({required this.isShowingMainData});

  final bool isShowingMainData;

  @override
  Widget build(BuildContext context) {
    return LineChart(
      _sampleData2(context),
    );
  }

  LineChartData _sampleData2(BuildContext context) => LineChartData(
    lineTouchData: lineTouchData2,
    gridData: _gridData(context),
    titlesData: _titlesData2(context),
    borderData: _borderData(context),
    lineBarsData: _lineBarsData2(context),
    minX: 0,
    maxX: 29,
    maxY: 2,
    minY: 0,
  );

  LineTouchData get lineTouchData2 => LineTouchData(
    enabled: false,
  );

  FlTitlesData _titlesData2(BuildContext context) => FlTitlesData(
    bottomTitles: AxisTitles(
      sideTitles: _bottomTitles(context),
    ),
    rightTitles: AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
    topTitles: AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
    leftTitles: AxisTitles(
      sideTitles: _leftTitles(context),
    ),
  );

  List<LineChartBarData> _lineBarsData2(BuildContext context) => [
    _lineChartBarData2_1(context),
    _lineChartBarData2_2(context),
    _lineChartBarData2_3(context),
  ];

  Widget leftTitleWidgets(double value, TitleMeta meta, BuildContext context) {
    final style = context.textStyles.labelSmall?.copyWith(
      fontWeight: AppTokens.fontWeightBold,
      fontSize: AppTokens.fontSize12,
    );
    String text;
    switch (value.toInt()) {
      case 2:
        text = '2 kW';
        break;
      case 4:
        text = '4 kW';
        break;
      case 6:
        text = '6 kW';
        break;
      case 8:
        text = '8 kW';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.center);
  }

  SideTitles _leftTitles(BuildContext context) => SideTitles(
    getTitlesWidget: (value, meta) => leftTitleWidgets(value, meta, context),
    showTitles: true,
    interval: 1,
    reservedSize: 45,
  );

  Widget bottomTitleWidgets(double value, TitleMeta meta, BuildContext context) {
    final style = context.textStyles.labelMedium?.copyWith(
      fontWeight: AppTokens.fontWeightBold,
      fontSize: AppTokens.fontSize14,
    );

    Widget text;

    switch (value.toInt()) {
      case 5:
        text = Text('05-12', style: style);
        break;
      case 10:
        text = Text('10-12', style: style);
        break;
      case 15:
        text = Text('15-12', style: style);
        break;
      case 20:
        text = Text('20-12', style: style);
        break;
      case 25:
        text = Text('25-12', style: style);
        break;
      case 30:
        text = Text('30-12', style: style);
        break;
      default:
        text = Text('', style: style);
        break;
    }

    return SideTitleWidget(
      meta: meta,
      space: 10,
      child: text,
    );
  }

  SideTitles _bottomTitles(BuildContext context) => SideTitles(
    showTitles: true,
    reservedSize: 32,
    interval: 1,
    getTitlesWidget: (value, meta) => bottomTitleWidgets(value, meta, context),
  );

  FlGridData _gridData(BuildContext context) => FlGridData(
    show: true,
    drawHorizontalLine: true,
    drawVerticalLine: true,
    getDrawingHorizontalLine: (value) {
      return FlLine(
        color: context.colors.outline.withValues(alpha: 0.2),
        strokeWidth: 1,
      );
    },
    getDrawingVerticalLine: (value) {
      return FlLine(
        color: context.colors.outline.withValues(alpha: 0.2),
        strokeWidth: 1,
      );
    },
  );

  FlBorderData _borderData(BuildContext context) => FlBorderData(
    show: true,
    border: Border(
      bottom: BorderSide(
        color: AppTokens.primaryRed.withValues(alpha: 0.2),
        width: 4,
      ),
      left: const BorderSide(color: Colors.transparent),
      right: const BorderSide(color: Colors.transparent),
      top: const BorderSide(color: Colors.transparent),
    ),
  );

  LineChartBarData _lineChartBarData2_1(BuildContext context) {
    // Datos reales de potencia exportada (diciembre 2025)
    final dailyData = FakeData.dailyEnergyData;
    final spots = dailyData.asMap().entries.map((entry) {
      final day = entry.key + 1;
      final data = entry.value;
      return FlSpot(day.toDouble(), data.exported / 100); // Escalar para visualización
    }).toList();

    return LineChartBarData(
      isCurved: true,
      curveSmoothness: 0,
      color: Color(int.parse("0xff${ColorsApp.color3}")).withValues(alpha: 0.7),
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(show: true),
      spots: spots,
    );
  }

  LineChartBarData _lineChartBarData2_2(BuildContext context) {
    // Datos reales de demanda (diciembre 2025)
    final dailyData = FakeData.dailyEnergyData;
    final spots = dailyData.asMap().entries.map((entry) {
      final day = entry.key + 1;
      final data = entry.value;
      return FlSpot(day.toDouble(), data.demand / 100); // Escalar para visualización
    }).toList();

    return LineChartBarData(
      isCurved: true,
      color: Color(int.parse("0xff${ColorsApp.color4}")).withValues(alpha: 0.7),
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(show: true),
      belowBarData: BarAreaData(
        show: true,
        color: Color(int.parse("0xff${ColorsApp.color4}")).withValues(alpha: 0.2),
      ),
      spots: spots,
    );
  }

  LineChartBarData _lineChartBarData2_3(BuildContext context) {
    // Datos reales de potencia importada (diciembre 2025)
    final dailyData = FakeData.dailyEnergyData;
    final spots = dailyData.asMap().entries.map((entry) {
      final day = entry.key + 1;
      final data = entry.value;
      return FlSpot(day.toDouble(), data.imported / 100); // Escalar para visualización
    }).toList();

    return LineChartBarData(
      isCurved: true,
      curveSmoothness: 0,
      color: Color(int.parse("0xff${ColorsApp.color2}")).withValues(alpha: 0.7),
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(show: true),
      belowBarData: BarAreaData(show: false),
      spots: spots,
    );
  }
}

class LineChartSample1 extends StatefulWidget {
  const LineChartSample1({super.key});

  @override
  State<StatefulWidget> createState() => LineChartSample1State();
}

class LineChartSample1State extends State<LineChartSample1> {
  late bool isShowingMainData;

  @override
  void initState() {
    super.initState();
    isShowingMainData = false;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.23,
      child: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const <Widget>[
              SizedBox(
                height: 20,
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 16, left: 16),
                  child: _LineChart(isShowingMainData: false),
                ),
              ),
              SizedBox(
                height: 50,
              ),
            ],
          ),
        ],
      ),
    );
  }
}