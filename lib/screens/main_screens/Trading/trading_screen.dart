import 'package:be_energy/data/constants.dart';
import 'package:be_energy/utils/metodos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class TradingScreen extends StatefulWidget {
  const TradingScreen({Key? key}) : super(key: key);

  @override
  State<TradingScreen> createState() => _TradingScreenState();
}

 
class _TradingScreenState extends State<TradingScreen> {
  
  Metodos metodos = Metodos();


  Widget _image() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
      child: Image(
        alignment: AlignmentDirectional.center,
        image:  const AssetImage("assets/img/5.png"),
        width: 3/4 * Metodos.width(context),
        height: 200,
      )
    );
  }

  Widget _card() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
      // height: 250,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 16),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                blurRadius: 6,
                color: Color(0x4B1A1F24),
                offset: Offset(0, 2),
              )
              
            ],
            gradient: Metodos.gradientClasic(context),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).focusColor,
              width: 0.25
            )
          ),
          child: _subtitleText()
        )
      ),
    );  
  
  
  }
  
  Widget _subtitleText(){
    // Generated code for this Column Widget...
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          margin: const EdgeInsets.only( top: 25.0, bottom: 15.0),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  "Disponible",
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    color: Theme.of(context).scaffoldBackgroundColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 15.0),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 4, 20, 0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  "\$ 333.333",
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    color: Theme.of(context).scaffoldBackgroundColor,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.5
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 15, 20, 12),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "* **** 0149 *",
                style: TextStyle(
                  fontFamily: 'Roboto Mono',
                  fontSize: 18.0,
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
              Text(
                "05/25 ",
                style: TextStyle(
                  fontFamily: 'Roboto Mono',
                  fontSize: 18.0,
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
              ),           
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 4, 20, 12),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "CRISTIAN HOYOS",
                style: TextStyle(
                  fontFamily: 'Roboto Mono',
                  fontSize: 18.0,
                  color: Theme.of(context).scaffoldBackgroundColor,
                  letterSpacing: 1.5
                ),
              )           
            ],
          ),
        ),
      
      ],
    );

  }

  
  Widget _actividades(){
    return Container(
      // height: 50,
      margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: Row(
    
        children: [

          Expanded(
            flex: 1,
            child: InkWell(
              onTap: () async {
                Navigator.push(context,MaterialPageRoute(builder: (context) => const TradingScreen()));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10.0),
                margin: const EdgeInsets.only(right: 25.0, left: 25.0),

                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.circular(15.0),
                  gradient: Metodos.gradientClasic(context),
                  border: Metodos.borderClasic(context)
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Image(
                      image: AssetImage("assets/img/moneybag.png"),
                      width: 40,
                      height: 40,
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                      child: Text(
                        "Colchón",
                        style: TextStyle(
                          fontFamily: 'Roboto Mono',
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )

          ),
          
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: () async {
                Navigator.push(context,MaterialPageRoute(builder: (context) => const TradingScreen()));
              },
              child: Container(
                
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10.0),
                margin: const EdgeInsets.only(right: 25.0, left: 25.0),

                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.circular(15.0),
                  gradient: Metodos.gradientClasic(context),
                  border: Metodos.borderClasic(context)
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Image(
                      image: AssetImage("assets/img/bolsillo.png"),
                      width: 40,
                      height: 40,
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                      child: Text(
                        "Aprende",
                        style: TextStyle(
                          fontFamily: 'Roboto Mono',
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )

          ),
          
        ],
      ),
    );
  }

  List<Widget> body() {
    return [
      _image(),
      _card(),
      _actividades()
    ];

  }
  
  Widget _btnFlotante(){
    return SpeedDial(
      backgroundColor: Theme.of(context).canvasColor,
      foregroundColor: Theme.of(context).scaffoldBackgroundColor,
      overlayColor: Theme.of(context).primaryColor,
      elevation: 15,
      animatedIcon: AnimatedIcons.menu_close,
      children: [
        SpeedDialChild(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          onTap: () {
            
          },
          labelWidget: Container(
            padding: const EdgeInsets.only( left: 5.0, right: 5.0),
            child: Text(
              "Envia",
              style: Metodos.textStyle(
                context,
                Theme.of(context).scaffoldBackgroundColor,
                16,
                FontWeight.bold,
                1
              ),
            ),
          ),
          
          child: Icon(
            Icons.arrow_forward_ios_sharp,
            size: 15,
            color: Theme.of(context).canvasColor,
          ),
        ),
        SpeedDialChild(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          onTap: () {
            
          },
          child: Icon(
            Icons.keyboard_arrow_down_outlined,
            size: 25,
            color: Theme.of(context).canvasColor,
          ),
          labelWidget: Container(
            padding: const EdgeInsets.only( left: 5.0, right: 5.0),
            child: Text(
              "Retira",
              style: Metodos.textStyle(
                context,
                Theme.of(context).scaffoldBackgroundColor,
                16,
                FontWeight.bold,
                1
              ),
            ),
          ),
          
        ),
        SpeedDialChild(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          onTap: () {

          },
          child: Icon(
            Icons.dashboard_customize_outlined,
            size: 30,
            color: Theme.of(context).canvasColor,
          ),
          labelWidget: Container(
            padding: const EdgeInsets.only( left: 5.0, right: 5.0),
            child: Text(
              "Servicios",
              style: Metodos.textStyle(
                context,
                Theme.of(context).scaffoldBackgroundColor,
                16,
                FontWeight.bold,
                1
              ),
            ),
          ),
          
        ),
      ] 
    );
  }
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.4),
      ),
      child: Scaffold(
      appBar: metodos.appbarSecundaria(context, "Transferir", ColorsApp.color4),
      // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SingleChildScrollView(
            // ignore: prefer_const_constructors
            child: GradientBackInsideApp(
              color: Theme.of(context).focusColor,
              height: 85,
              opacity: 0.75,
            )
          ),

          ListView(
            children: body()
          ),
        ]
      ),
      
      floatingActionButton: _btnFlotante(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat
      ));
  }
}