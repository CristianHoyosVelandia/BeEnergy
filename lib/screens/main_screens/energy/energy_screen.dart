// ignore_for_file: file_names
import 'package:flutter/material.dart';
import '../../../data/constants.dart';
import '../../../models/my_user.dart';
import '../../../utils/metodos.dart';
import 'package:fl_chart/fl_chart.dart';

class EnergyScreen extends StatefulWidget {
  final MyUser? myUser;
  const EnergyScreen({Key? key, this.myUser}) : super(key: key);

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
        const Padding(
          padding: EdgeInsets.fromLTRB(10.0, 0.0, 5.0, 5.0),
          child: Image(
            alignment: AlignmentDirectional.center,
            image: AssetImage("assets/img/ecoHouse.jpg"),
            width: 275.0,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 10.0, 5.0, 0.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 10.0, 5.0, 0.0),
                child: Text(
                  "10 kW",
                  style: TextStyle(
                    color: Theme.of(context).focusColor,
                    fontSize: 25.0,
                    fontFamily:"SEGOEUI",
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.10,
                  )
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 0.0, 5.0, 0.0),
                child: Text(
                  "Capacidad",
                  style: TextStyle(
                    color: Theme.of(context).focusColor,
                    fontSize: 12.0,
                    fontFamily:"SEGOEUI",
                    fontWeight: FontWeight.w200,
                    letterSpacing: 1.10,
                  )
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 25.0, 5.0, 0.0),
                child: Text(
                  "5.5 kWh",
                  style: TextStyle(
                    color: Theme.of(context).focusColor,
                    fontSize: 25.0,
                    fontFamily:"SEGOEUI",
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.10,
                  )
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 0.0, 5.0, 15.0),
                child: Text(
                  "Consumo",
                  style: TextStyle(
                    color: Theme.of(context).focusColor,
                    fontSize: 12.0,
                    fontFamily:"SEGOEUI",
                    fontWeight: FontWeight.w200,
                    letterSpacing: 1.10,
                  )
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
      margin: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        // border: metodos.borderCajas(context),
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(
          color: Theme.of(context).focusColor,
          width: 0.25
        )
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(10.0, 10.0, 5.0, 0.0),
                child: Image(
                  alignment: AlignmentDirectional.center,
                  image: AssetImage("assets/img/cloudy.png"),
                  // image:  AssetImage("assets/img/logo.png"),
                  width: 30.0,
                  height: 30.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 10.0, 5.0, 0.0),
                child: Text(
                  "27 °C - Tulúa",
                  style: TextStyle(
                    color: Theme.of(context).focusColor,
                    fontSize: 15.0,
                    fontFamily:"SEGOEUI",
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.10,
                  )
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 0.0),
                    child: Text(
                      "28",
                      style: TextStyle(
                        color: Theme.of(context).focusColor,
                        fontSize: 35.0,
                        fontFamily:"SEGOEUI",
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.10,
                      )
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(2.0, 20.0, 5.0, 0.0),
                    child: Text(
                      "Abril",
                      style: TextStyle(
                        color: Theme.of(context).focusColor,
                        fontSize: 15.0,
                        fontFamily:"SEGOEUI",
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.10,
                      )
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5.0, 5.0, 15.0, 0.0),
                    child: Text(
                      (casaVal) ?"Almacenar" : "Exportar",
                      style: TextStyle(
                        color: Theme.of(context).focusColor,
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  Switch(
                    // This bool value toggles the switch.
                    value: casaVal,
                    activeColor: Theme.of(context).canvasColor,
                    onChanged: (bool value) {
                      // This is called when the user toggles the switch.
                      setState(() {
                        casaVal = value;
                      });
                    },
                  ),
                ],
              )
            ],
          ),
          _imagen()

        ]
      )
    );
  }
  
  Widget _figura1() {
    return const LineChartSample();
  }
  Widget _indicadoresLine(){
    return Container(
      margin: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        // border: metodos.borderCajas(context),
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(
          color: Theme.of(context).focusColor,
          width: 0.25
        )
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 10.0, 5.0, 0.0),
                child: Text(
                  "Electricidad Generada PV",
                  style: TextStyle(
                    color: Theme.of(context).focusColor,
                    fontSize: 15.0,
                    fontFamily:"SEGOEUI",
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.10,
                  )
                ),
              ),
            ],
          ),
          _figura1()

        ]
      )
    );
  }

  Widget body(){
    return Stack(

      alignment: Alignment.center,
      children: <Widget>[

        ListView(
          children: <Widget>[

            _indicadoresCasa(),

            _indicadoresLine(),


          ],
        )
      
      ],
    );        
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: metodos.appbarEnergia(context, widget.myUser!.nombre),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
    Color(int.parse("0xff${ColorsApp.color3}")),
    const Color(0xff212D3D),
  ];

  bool showAvg = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.70,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 18,
              left: 12,
              top: 24,
              bottom: 12,
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
                fontSize: 12,
                color: showAvg ? Colors.white.withOpacity(0.5) : Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );
    Widget text;
    switch (value.toInt()) {
      case 7:
        text = const Text('7:00 a.m', style: style);
        break;
      case 12:
        text = const Text('12:00 m', style: style);
        break;
      case 17:
        text = const Text('17:00 p.m', style: style);
        break;

      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style =TextStyle(
      color: Color(0xff212D3D),
      fontSize: 12.0,
      fontFamily:"SEGOEUI",
      fontWeight: FontWeight.bold,
      letterSpacing: 1.10,
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
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff212D3D)  ,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Color(int.parse("0xff${ColorsApp.color3}")),
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
        border: Border.all(color: const Color(0xff37434d)),
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
                  .map((color) => color.withOpacity(0.3))
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
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
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
        border: Border.all(color: const Color(0xff37434d)),
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
                    .withOpacity(0.1),
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


