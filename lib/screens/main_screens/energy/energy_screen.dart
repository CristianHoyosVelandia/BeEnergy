// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/utils/formatters.dart';
import '../../../data/constants.dart';
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
            width: 225.0,
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
                Formatters.formatPower(10),
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
                Formatters.formatEnergy(5.5),
                style: context.textStyles.headlineMedium?.copyWith(
                  fontWeight: AppTokens.fontWeightBold,
                ),
              ),
              SizedBox(height: AppTokens.space4),
              Text(
                "Consumo",
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "28",
                    style: context.textStyles.displayMedium?.copyWith(
                      fontWeight: AppTokens.fontWeightBold,
                    ),
                  ),
                  SizedBox(width: AppTokens.space4),
                  Padding(
                    padding: EdgeInsets.only(bottom: AppTokens.space8),
                    child: Text(
                      "Abril",
                      style: context.textStyles.titleMedium?.copyWith(
                        fontWeight: AppTokens.fontWeightSemiBold,
                      ),
                    ),
                  ),
                ],
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
                      activeColor: context.colors.primary,
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
              "Electricidad Generada PV",
              style: context.textStyles.titleMedium?.copyWith(
                fontWeight: AppTokens.fontWeightSemiBold,
              ),
            ),
          ),
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

class LineChartSample extends StatefulWidget {
  const LineChartSample({super.key});

  @override
  State<LineChartSample> createState() => _LineChartSampleState();
}

class _LineChartSampleState extends State<LineChartSample> {
  List<Color> gradientColors = [
    AppTokens.primaryRed,
    AppTokens.error,
  ];

  bool showAvg = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.70,
          child: Padding(
            padding: EdgeInsets.only(
              right: AppTokens.space16,
              left: AppTokens.space12,
              top: AppTokens.space24,
              bottom: AppTokens.space12,
            ),
            child: LineChart(
              showAvg ? avgData() : mainData(),
            ),
          ),
        ),
        SizedBox(
          width: 60,
          height: 34,
          child: TextButton(
            onPressed: () {
              setState(() {
                showAvg = !showAvg;
              });
            },
            child: Text(
              'avg',
              style: TextStyle(
                fontSize: AppTokens.fontSize12,
                color: showAvg
                  ? context.colors.primary.withValues(alpha: 0.5)
                  : context.colors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    final style = context.textStyles.labelSmall?.copyWith(
      fontWeight: AppTokens.fontWeightBold,
      fontSize: AppTokens.fontSize10,
    );
    Widget text;
    switch (value.toInt()) {
      case 7:
        text = Text('7:00 a.m', style: style);
        break;
      case 12:
        text = Text('12:00 m', style: style);
        break;
      case 17:
        text = Text('17:00 p.m', style: style);
        break;

      default:
        text = Text('', style: style);
        break;
    }

    return SideTitleWidget(
      meta: meta,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    final style = context.textStyles.labelSmall?.copyWith(
      fontWeight: AppTokens.fontWeightBold,
      fontSize: AppTokens.fontSize12,
    );
    String text;
    switch (value.toInt()) {
      case 1:
        text = '2 kW';
        break;
      case 3:
        text = '5 kW';
        break;
      case 5:
        text = '10 kW';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        verticalInterval: 1,
        horizontalInterval: 1,
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: context.colors.outline.withValues(alpha: 0.2),
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: context.colors.outline.withValues(alpha: 0.2),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.2),
        ),
      ),
      minX: 6,
      maxX: 20,
      minY: 0,
      maxY: 5,
      lineBarsData: [
        LineChartBarData(
          spots: const [

            FlSpot(6, 0),
            FlSpot(7, 0.25),
            FlSpot(8, 0.75),

            FlSpot(9, 1.6),
            FlSpot(10, 2.21),
            FlSpot(11, 3),

            FlSpot(12, 3.3),
            FlSpot(13, 3.2),
            FlSpot(14, 3.1),

            FlSpot(15, 2.6),
            FlSpot(16, 2),
            FlSpot(17, 1.26),

            FlSpot(18, 0.5),
            FlSpot(19, 0.25),
            FlSpot(20, 0),

          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withAlpha((0.3 * 255).toInt()))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData avgData() {
    return LineChartData(
      lineTouchData: LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        verticalInterval: 1,
        horizontalInterval: 1,
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: context.colors.outline.withValues(alpha: 0.2),
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: context.colors.outline.withValues(alpha: 0.2),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: bottomTitleWidgets,
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
            interval: 1,
          ),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.2),
        ),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3.44),
            FlSpot(2.6, 3.44),
            FlSpot(4.9, 3.44),
            FlSpot(6.8, 3.44),
            FlSpot(8, 3.44),
            FlSpot(9.5, 3.44),
            FlSpot(11, 3.44),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
            ],
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withAlpha((0.1 * 255).toInt()),
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withAlpha((0.1 * 255).toInt()),
              ],
            ),
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
    maxY: 8,
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
        text = Text('05-04', style: style);
        break;
      case 10:
        text = Text('10-04', style: style);
        break;
      case 15:
        text = Text('15-04', style: style);
        break;
      case 20:
        text = Text('20-04', style: style);
        break;
      case 25:
        text = Text('25-04', style: style);
        break;
      case 30:
        text = Text('30-04', style: style);
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

  LineChartBarData _lineChartBarData2_1(BuildContext context) => LineChartBarData(
        isCurved: true,
        curveSmoothness: 0,
        color: Color(int.parse("0xff${ColorsApp.color3}")).withValues(alpha: 0.7),
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(show: true),
        spots: const [
          FlSpot(1, 6),
          FlSpot(3, 1.5),
          FlSpot(5, 1.4),
          FlSpot(7, 3.4),
          FlSpot(9, 2),
          FlSpot(11, 2.2),
          FlSpot(13, 1.8),
          FlSpot(15, 1),
          FlSpot(17, 1.5),
          FlSpot(19, 1.4),
          FlSpot(21, 3.4),
          FlSpot(23, 2),
          FlSpot(25, 2.2),
          FlSpot(27, 1.8),
        ],
      );

  LineChartBarData _lineChartBarData2_2(BuildContext context) => LineChartBarData(
        isCurved: true,
        color: Color(int.parse("0xff${ColorsApp.color4}")).withValues(alpha: 0.7),
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(show: true),
        belowBarData: BarAreaData(
          show: true,
          color: Color(int.parse("0xff${ColorsApp.color4}")).withValues(alpha: 0.2),
        ),
        spots: const [
          FlSpot(1, 0.5),
          FlSpot(3, 2.5),
          FlSpot(5, 2.4),
          FlSpot(7, 2.4),
          FlSpot(9, 3),
          FlSpot(11, 4.2),
          FlSpot(13, 4.8),
          FlSpot(15, 5.5),
          FlSpot(17, 4.5),
          FlSpot(19, 4.0),
          FlSpot(21, 3.4),
          FlSpot(23, 3.0),
          FlSpot(25, 3.4),
          FlSpot(27, 3.8),
        ],
      );

  LineChartBarData _lineChartBarData2_3(BuildContext context) => LineChartBarData(
        isCurved: true,
        curveSmoothness: 0,
        color: Color(int.parse("0xff${ColorsApp.color2}")).withValues(alpha: 0.7),
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(show: true),
        belowBarData: BarAreaData(show: false),
        spots: const [
          FlSpot(1, 1.8),
          FlSpot(3, 1.9),
          FlSpot(5, 1.0),
          FlSpot(7, 1.3),
          FlSpot(9, 1.5),
          FlSpot(11, 1.7),
          FlSpot(13, 1.8),
          FlSpot(15, 1.5),
          FlSpot(17, 0.5),
          FlSpot(19, 0.6),
          FlSpot(21, 1.4),
          FlSpot(23, 1.5),
          FlSpot(25, 1.0),
          FlSpot(27, 1.2),
        ],
      );
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