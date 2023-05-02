import 'package:auto_size_text/auto_size_text.dart';
import 'package:be_energy/utils/metodos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../routes.dart';

class IntercambiosEnergyScreen extends StatefulWidget {
  const IntercambiosEnergyScreen({Key? key}) : super(key: key);

  @override
  State<IntercambiosEnergyScreen> createState() => _IntercambiosEnergyScreenState();
}

 
class _IntercambiosEnergyScreenState extends State<IntercambiosEnergyScreen> {
    
  Metodos metodos = Metodos();
  bool valBuscar= false;

  final dataIntercambios = [
    {
      'numTransaccion': 1,
      'entrada': true,
      'nombre': 'Estiven Hoyos',
      'dinero':  ' \$ 250.00',
      'energia':  '25 kW',
      'fecha':  '02-May',
      'fuente':  'Solar-Eólica',
      'fuenteIcon': 5,
      'horarioSuminsitro':"Diurno Bloque 2 CLPE No 03-2021",
      'estado': 'En curso'
    },
    {
      'numTransaccion': 1,
      'entrada': true,
      'nombre': 'Estiven Hoyos',
      'dinero':  ' \$ 500.00',
      'energia':  '25 kW',
      'fecha':  '25-Feb',
      'fuente':  'Solar',
      'fuenteIcon': 1,
      'horarioSuminsitro':"Diurno Bloque 2 CLPE No 03-2021",
      'estado': 'Finalizada'
    },
    {
      'numTransaccion': 2,
      'entrada': true,
      'nombre': 'Angel Hoyos',
      'dinero':  ' \$ 240.00',
      'energia':  '5 kW',
      'fecha':  '27-Feb',
      'fuente':  'Solar',
      'fuenteIcon': 1,
      'horarioSuminsitro':"Diurno Bloque 2 CLPE No 03-2021",
      'estado': 'Finalizada'
    },
    {
      'numTransaccion': 3,
      'entrada': false,
      'nombre': 'Clara Velandia',
      'dinero':  ' \$ 150.00',
      'energia':  '8 kW',
      'fecha':  '28-Feb',
      'fuente':  'Solar',
      'fuenteIcon': 1,
      'horarioSuminsitro':"Diurno Bloque 2 CLPE No 03-2021",

      'estado': 'Finalizada'

    }
  ];

  Widget _image() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
      child: Image(
        alignment: AlignmentDirectional.center,
        image:  const AssetImage("assets/img/5.png"),
        width: 3/4 * Metodos.width(context),
        height: 150,
      )
    );
  }

  Widget _contenPrincipalCard(){
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //Image
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                        
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 16, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        _leadingBack(context, Metodos.width(context)),
                      ],
                    ),
                  ),
                
                  Card(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    color: Theme.of(context).scaffoldBackgroundColor,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                      child: Container(
                        width: 60,
                        height: 60,
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          "assets/img/avatar.jpg",
                        ),
                      ),
                    ),
                  ),    
                
                ],
              ),
              
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 16, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0x40000000),
                          borderRadius:
                              BorderRadius.circular(8),
                        ),
                        child: _leading(context, Metodos.width(context))
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconButton _leading(BuildContext context, double width) {
    return IconButton(
      //icono de cerrar sesion
      icon: Icon(
        Icons.search,
        color: Theme.of(context).scaffoldBackgroundColor,
        size: 25,
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(Theme.of(context).primaryColor),
        iconColor: MaterialStatePropertyAll(Theme.of(context).scaffoldBackgroundColor),
      ),

      tooltip: "Buscar",
      onPressed: () async {
        setState(() {
          if(valBuscar==true) {
            valBuscar = false;
          }else{
            valBuscar = true;
          }
        });
      }
    );
  }
    
  IconButton _leadingBack(BuildContext context, double width) {
    return IconButton(
      //icono de cerrar sesion
      icon: Icon(
        Icons.arrow_back_ios_new,
        color: Theme.of(context).scaffoldBackgroundColor,
        size: 25,
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(Theme.of(context).primaryColor),
        iconColor: MaterialStatePropertyAll(Theme.of(context).scaffoldBackgroundColor),
      ),

      tooltip: "Volver",
      onPressed: () async {

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Beenergy()),
          (Route<dynamic> route) => false
        );  
      }
    );
  }
    
  Widget _cartaPrincipal(){
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 90,
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
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
        child: _contenPrincipalCard()
      ),
    );
            
  }
  
  Widget _info(){
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 15, 20, 12),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
            child: Text(
              "Sus intercambios de energía son:",
              style: Metodos.subtitulosSimple(context)
            ),
          ),
        ],
      ),
    );
  }

  Widget _btnCrear() {
   return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      
      onTap: () async {

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Beenergy()),
          (Route<dynamic> route) => false
        );
      },

      child: Container(
        margin: const EdgeInsets.only(right: 65, left: 65, top: 15),
        height: 50,
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.circular(25),
        ),
        
        child: Center(
          child: Text(
            'Finalizar',
            style: Metodos.btnTextStyleFondo(context, Colors.white)
          ),
        ),
      ),
    );     
  
  }
  
  String _iconCard(int numero) {
    var au = 'assets/icons/CleanWater.svg';
    
    switch (numero) {
      case 1:
        au = BeenergyIcons.solarPanel;
      break;
      case 5:
        au = BeenergyIcons.ecoHouse;
      break;
      default:
       au = au;
    }

    return au;
  }
  Widget _card(var data){
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: (data['entrada'] == true )?Theme.of(context).canvasColor: Colors.red,
          width: 1
        ),
        borderRadius: BorderRadius.circular(15.0)
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: SvgPicture.asset(_iconCard(data['fuenteIcon'])),
                )
              ),
              Expanded(
                child: Column(
                children: [
      
                Icon(
                  (data['entrada'] == false )? Icons.trending_down_outlined: Icons.trending_up_outlined,
                  size: 30,
                  color: (data['entrada'] == false )? Colors.red: Theme.of(context).canvasColor,
                ),

                const SizedBox(height: 5.0),

                AutoSizeText(
                  data['estado'],
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: Metodos.subtitulosInformativos(context)
                ),
            ],
          ),
      
              ),
            ],
            )
          ),
          
          Expanded(
            child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    data['nombre'].toString().split(' ').first,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).focusColor
                    ),
                  ),
                )
              ),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    
                    AutoSizeText(
                      data['dinero'],
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: TextStyle(
                        color: Theme.of(context).focusColor,
                        fontSize: 12.0,
                        fontFamily:"SEGOEUI",
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.10,
                      )
                    ),
                                  
                    const SizedBox(height: 5.0),

                    AutoSizeText(
                      data['energia'],
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: TextStyle(
                        color: Theme.of(context).focusColor,
                        fontSize: 12.0,
                        fontFamily:"SEGOEUI",
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.10,
                      )
                    ),
                  

                  ],
                ),

              ),
            ],
            )
          ),
          
        ],
      ),
    );
  }
  Widget _gridViewCards() {
    return  Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        margin: const EdgeInsets.only(top: 20),
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            childAspectRatio: 5/4,
            crossAxisSpacing: 10, // espaciado horizontal
            mainAxisSpacing: 10, // espaciado vertical
            mainAxisExtent: 150,
            maxCrossAxisExtent: 3*Metodos.width(context) / 4,
          ),
          itemCount: dataIntercambios.length,
          itemBuilder: (context, index){
            return _card(dataIntercambios[index]);
          }
        ),
      ),
    );
  }
  Widget body() {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        ListView(
          children: <Widget>[
            _cartaPrincipal(),
            ( valBuscar==true ) ? _image() : Container(),
            _info(),
            _gridViewCards(),
            _btnCrear()
          ]
        )
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
        body: body(),
      )
    );
  }
}
