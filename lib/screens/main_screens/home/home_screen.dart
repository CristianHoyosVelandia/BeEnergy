import 'package:auto_size_text/auto_size_text.dart';
import 'package:be_energy/screens/main_screens/Trading/trading_screen.dart';
import 'package:be_energy/utils/metodos.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../models/callmodels.dart';

class HomeScreen extends StatefulWidget {
  final MyUser? myUser;
  const HomeScreen({Key? key, this.myUser}) : super(key: key);
  
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
        // isResponsive: true,
        overflowMode: LegendItemOverflowMode.scroll
      ),
      series: <CircularSeries>[
        DoughnutSeries<GGData, String>(
          dataSource: dataCircularSeries,
          xValueMapper: (data, _) => data.fuente,
          yValueMapper: (datum, _) => datum.consumo,
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            textStyle: TextStyle(   
              color: Theme.of(context).scaffoldBackgroundColor
            )
          ),

        )
      ],

    );
  }


  Widget _trData() {
    return Column(
      children: [
        _importee(),
        _exportee()
      ],
    );
  }

  Widget _importee() {
    return  Container(
      margin:  const EdgeInsets.all(5.0),
      padding: const EdgeInsets.all(5.0),

      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(15.0)
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width:  Metodos.width(context),
            margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: Text(
              "Importe:",
              style: Metodos.subtitulosInformativos(context)
            ),
          ),
          Row(
            children: [
      
              const Icon(
                Icons.trending_down_outlined,
                size: 50,
                color: Colors.red,
              ),
                  
              const SizedBox(width: 15.0),
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const <Widget>[
                  
                  AutoSizeText(
                    "-20 kWh",
                    textAlign: TextAlign.start,
                    maxLines: 2,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    )
                  ),
                                
                      SizedBox(height: 15.0),

                      AutoSizeText(
                        "\$ 5.720",
                        textAlign: TextAlign.start,
                        maxLines: 2,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        )
                      ),
                    

                ],
              ),

            ],
          ),
      
        ],
      ),
    );
  }

  Widget _exportee() {
    return  Container(
      margin:  const EdgeInsets.only(top:15.0, left:5.0, right: 5.0),
      padding: const EdgeInsets.all(5.0),

      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(15.0)
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width:  Metodos.width(context),
            margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: Text(
              "Exporte:",
              style: Metodos.subtitulosInformativos(context)
            ),
          ),
          Row(
            children: [
      
              Icon(
                Icons.trending_up_outlined,
                size: 50,
                color: Theme.of(context).canvasColor,
              ),
                  
              const SizedBox(width: 15.0),
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  
                  AutoSizeText(
                    "+50 kWh",
                    textAlign: TextAlign.start,
                      maxLines: 2,
                      style: TextStyle(
                        color: Theme.of(context).canvasColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      )
                    ),
                                
                  const SizedBox(height: 15.0),

                  AutoSizeText(
                      "\$ 14.300",
                      textAlign: TextAlign.start,
                      maxLines: 2,
                      style: TextStyle(
                        color: Theme.of(context).canvasColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      )
                    ),
                    

                ],
              ),

            ],
          ),
      
        ],
      ),
    );
  }

  Widget _saludoText(){

    String nombre= "cristian";
    if(widget.myUser != null) {
      nombre = (widget.myUser!.nombre)!;
      final splitted = nombre.split(' ');
      nombre = splitted[0];
    }

    return Container(
      width: Metodos.width(context),
      margin: const EdgeInsets.only(right: 25, left: 25, top: 30, bottom: 10),
      child:  Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(
          //   (widget.myUser != null ) ? "¡Hola, $nombre !": "¡Hola, Cristian !",
          //   style: Metodos.textStyle(
          //     context,
          //     Metodos.colorInverso(context),
          //     25,
          //     FontWeight.bold,
          //     1
          //   ),
          // ),
          Container(
            width:  Metodos.width(context),
            margin: const EdgeInsets.only(top: 10.0),
            child: Text(
              "Tus movimientos Hoy (kWh):",
              style: Metodos.subtitulosInformativos(context)
            ),
          ),
        ],
        
      ),
        
        
    );
  }

  Widget _indicadores(){
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
      child: Row(
    
        children: [
          Expanded(
            flex: 3,
            child: SizedBox(
              // height: 200,
              child: _grafico()
            ),
          ),
          Expanded(
            flex: 2,
            child: SizedBox(
              // height: 200,
              child: _trData()
            ),
          )
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _btnActividad(String nombre,BuildContext context, int onTap, String image){
    return Expanded(
      flex: 1,
      child: InkWell(
        onTap: () async {
          switch (onTap) {
            case 1:
              Navigator.push(context,MaterialPageRoute(builder: (context) => const TradingScreen()));
              break;
            case 2:
              Navigator.push(context,MaterialPageRoute(builder: (context) => const TradingScreen()));
              break; 
            default:
              Navigator.push(context,MaterialPageRoute(builder: (context) => const TradingScreen()));
              break;
          }
        },
        child: Container(
          padding: const EdgeInsets.all(5),
          margin: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(15.0),
            border: Metodos.borderClasic(context)
            // border: Border.all(
            //   width: 0.25,
            //   color: Theme.of(context).focusColor
            // )
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                image: AssetImage(image),
                width: 40,
                height: 40,
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 15, 0, 0),
                child: Text(
                  nombre,
                  style: Metodos.subtitulosInformativos(context),
                ),
              ),
            ],
          ),
        ),
      )

    );
          
  }
  
  Widget _btnActividadIcon(String nombre,BuildContext context, int onTap, IconData icon){
    return Expanded(
      flex: 1,
      child: InkWell(
        onTap: () async {
          switch (onTap) {
            case 1:
              Navigator.push(context,MaterialPageRoute(builder: (context) => const TradingScreen()));
              break;
            case 2:
              Navigator.push(context,MaterialPageRoute(builder: (context) => const TradingScreen()));
              break; 
            default:
              Navigator.push(context,MaterialPageRoute(builder: (context) => const TradingScreen()));
              break;
          }
        },
        child: Container(
          padding: const EdgeInsets.all(5),
          margin: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(15.0),
            border: Metodos.borderClasic(context)
            // border: Border.all(
            //   width: 0.25,
            //   color: Theme.of(context).focusColor
            // )
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Theme.of(context).focusColor,
                size: 35,
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
                child: Text(
                  nombre,
                  style: Metodos.subtitulosInformativos(context),
                ),
              ),
            ],
          ),
        ),
      )

    );
          
  }
  
  Widget _actividades(){
    return Container(
      // height: 50,
      margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: Row(
    
        children: [

          _btnActividadIcon(
            "Transferir",
            context,
            1, 
            Icons.swap_horiz_rounded
          ),
          // _btnActividad(
          //   "bolsa",
          //   context,
          //   2,
          //   "assets/img/energy.png"
          // ),
          _btnActividadIcon(
            "bolsa",
            context,
            2, 
            Icons.account_balance_outlined
          ),
          _btnActividadIcon(
            "Aprende",
            context,
            1, 
            Icons.bookmark
          ),
        ],
      ),
    );
  }

  Widget _miniListHistorial() {
    return ListView.builder(
      // Agregar estas dos lineas cuandos e
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: data.length,
      itemBuilder: (BuildContext context, int index){
        return InkWell(
          child:Container(

            margin: const EdgeInsets.only(right: 2.5, left: 2.5, top:5, bottom: 15),
            // child: const Placeholder(),

            child: Card(
              color: Theme.of(context).scaffoldBackgroundColor,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
                side: BorderSide(
                  width: 0.25,
                  color: Theme.of(context).focusColor
                )
              ),
              
              child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    
                    Expanded(
                      flex: 6,
                      child: Row(
                        children: [
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(80.0),
                              color: Theme.of(context).focusColor,
                            ),
                            child: (data[index]['entrada'] == true) ? 
                              Icon(
                                Icons.arrow_drop_up,
                                size: 50,
                                color: Theme.of(context).canvasColor,
                              ): 
                              const Icon(
                                Icons.arrow_drop_down,
                                size: 50,
                                color: Colors.red,
                              ) 
                              
                          ),

                          const SizedBox(width: 15.0),
                          
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                
                                AutoSizeText(
                                  "${data[index]['nombre']}",
                                  maxLines: 2,
                                  textAlign: TextAlign.start,
                                  style: Metodos.descripcionTextStyle(context, Theme.of(context).focusColor, 15),
                                ),

                                AutoSizeText(
                                  "${data[index]['fuente']} - ${data[index]['energia']}",
                                  textAlign: TextAlign.start,
                                  maxLines: 2,
                                  style: Metodos.descripcionTextStyle( context, Theme.of(context).focusColor,15),
                                )

                              ],
                            ),
                          ),
                        ],
                      )
                    ),

                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Column(
                            children: [
                              AutoSizeText(
                                "${data[index]['dinero']}",
                                maxLines: 2,
                                textAlign: TextAlign.start,
                                minFontSize: 7,
                                maxFontSize: 25,
                                style: (data[index]['entrada'] == true) ? Metodos.descripcionTextStyle(context, Theme.of(context).canvasColor, 15, FontWeight.w800) :  Metodos.descripcionTextStyle(context, Colors.red ,15, FontWeight.w800),
                              ),
                              AutoSizeText(
                                  "${data[index]['fecha']}",
                                  textAlign: TextAlign.start,
                                  maxLines: 2,
                                  style: Metodos.descripcionTextStyle( context, Theme.of(context).focusColor,15),
                                )
                            ]
                          )
                        ],
                      )
                    ),
                  
                  ],
                ),
              ),
            ),
          
          ),
          onTap: () async {
            if(data[index]['numTransaccion']!=""){
              // ignore: avoid_print
              print("Presiono la carta con numTransaccion ${data[index]['numTransaccion']}");
              // Navigator.push(context,MaterialPageRoute(builder: (context) =>
              // DescTransaccion(
              //   numTransaccion: historial[index].numTransaccion, 
              //   codUsuario: widget.codUsuario, 
              //   costo: historial[index].valTransaccion,
              //   myKupiApp: myKupiApp
              // )));
  
            }
          },
        );
      },
    );
  }
  
  Widget _titulobtnHistorial() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 15, top: 10.0),
          child: Text(
            "Transacciones:",
            style: Metodos.subtitulosInformativos(context)
          ),
        ),
              
        Container(
          margin: const EdgeInsets.only(top: 10.0, right: 15.0),
          child: IconButton(
            //icono de cerrar sesion
            icon: Icon(
              Icons.add_outlined,
              size: 25,
              color: Theme.of(context).canvasColor,
            ),

            tooltip: "Cerrar Sesión",
            onPressed: () async {
              metodos.alertsDialog(context, "¿Deseas cerrar tu sesión ahora?", Metodos.width(context)-50, "Cancelar", 2, "Si", 3);
            }
          )
        ),                 
      ],
    );
  }
  
  Widget _minihostiral(){
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration( 
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        // border: Border.all(
        //   width: 1.5,
        //   color: Theme.of(context).focusColor
        // )
      ),
      child: Column(
        children: [
          _titulobtnHistorial(),
          _miniListHistorial()
        ],
      )
      
    );
     
  }


  Widget body(){
    return Stack(

      alignment: Alignment.center,
      children: <Widget>[

        ListView(
          children: <Widget>[
            _saludoText(),
            
            _indicadores(),
            
            Container(
              width:  Metodos.width(context),
              margin: const EdgeInsets.only(left: 20, top: 25.0),
              child: Text(
                "Actividades:",
                style: Metodos.subtitulosInformativos(context)
              ),
            ),

            _actividades(),

            _minihostiral()
            // _cajasText('Tus movimientos Hoy'),

          ],
        )
      
      ],
    );        
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: metodos.appbarPrincipal(context, widget.myUser!.nombre),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: body(),
    );
  }
}

//Generation grid data
class GGData {

  late final String fuente;
  late final int consumo;

  GGData( this.fuente, this.consumo );
}