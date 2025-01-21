import 'package:be_energy/models/callmodels.dart';
import 'package:be_energy/utils/metodos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/svg.dart';

import '../../../data/constants.dart';

class ErecordScreen extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final Intercambio dataScreen;
  const ErecordScreen({super.key, required this.dataScreen});

  @override
  State<ErecordScreen> createState() => _ErecordScreenState();
}

 
class _ErecordScreenState extends State<ErecordScreen> {
    
  Metodos metodos = Metodos();

  //Controllers
  final TextEditingController _nombre = TextEditingController();
  final TextEditingController _ubicacion = TextEditingController();
  final TextEditingController _tipodeEnergia = TextEditingController();
  final TextEditingController _cantidad = TextEditingController();
  final TextEditingController _horarioSuminsitro = TextEditingController();
  final TextEditingController _tarifa = TextEditingController();
  final TextEditingController _periodo = TextEditingController();
  final TextEditingController _expriracion = TextEditingController();

  bool val= false;

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
        Icons.login_rounded,
        color: Theme.of(context).scaffoldBackgroundColor,
        size: 25,
      ),
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(Theme.of(context).primaryColor),
        iconColor: WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor),
      ),

      tooltip: "Cerrar Sesión",
      onPressed: () async {
        metodos.alertsDialog(context, "¿Deseas cerrar tu sesión ahora?", width, "Cancelar", 2, "Si", 3);
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
        backgroundColor: WidgetStatePropertyAll(Theme.of(context).primaryColor),
        iconColor: WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor),
      ),

      tooltip: "Volver",
      onPressed: () async {
        Navigator.pop(context);
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
      padding: const EdgeInsetsDirectional.fromSTEB(20, 5, 20, 12),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
            child: Text(
              "Tu transacción de intercambio de energía No ${widget.dataScreen.numTransaccion} es:",
              style: Metodos.subtitulosSimple(context)
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _btnVolver() {
   return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      
      onTap: () {
        Navigator.pop(context);
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
            'Volver',
            style: Metodos.btnTextStyleFondo(context, Colors.white)
          ),
        ),
      ),
    );     
  
  }
 
  Widget _ticket(){

    String energia = widget.dataScreen.energia.split(" ").first;
    String dinero = widget.dataScreen.dinero.split(" ").elementAt(1);

    // double dinero = double.parse(widget.dataScreen.dinero.split(" ").first);
    double total = double.parse(energia)*double.parse(dinero);


    Widget datosFila(IconData icono, bool tipoIcono, String titulo, double marginBottom, dynamic informacion) {
      return Container(
        margin: EdgeInsets.only(bottom: marginBottom),
        padding: const EdgeInsets.symmetric(horizontal: K_PADDING_SHORT),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: K_MARGIN_SHORT*2),
                    child: (tipoIcono == true) ? 
                      Icon(
                        icono,
                        size: 18,
                        color: Theme.of(context).canvasColor,
                      )
                      :
                      SvgPicture.asset(
                        BeenergyIcons.ecoBombilla,
                        alignment: AlignmentDirectional.center,
                        width: 25,
                        height: 18,
                      ),
                  ),
                  Text(
                    titulo,
                    style: Metodos.subtitulosInformativos(context)
                  ),
                ],
              ),
            ),

            Expanded(
              flex: 2,
              child: Text(
                '$informacion',
                textAlign: TextAlign.right,
                style: Metodos.subtitulosSimple(context)
              ),
            ),
          ],
        ),
      );
    }


    Widget datosTransaccion = Column(
      children: [
        datosFila(Icons.storage_rounded, true, 'Estado tr:', K_MARGIN, widget.dataScreen.estado),
        datosFila(Icons.supervised_user_circle_outlined, true, 'usuario:', K_MARGIN_LONG, widget.dataScreen.nombre),

        datosFila(Icons.abc, false, 'Fuente:', K_MARGIN, widget.dataScreen.fuente),
        datosFila(Icons.access_alarms, true, 'Horario Suminsitro:', K_MARGIN, widget.dataScreen.horarioSuminsitro),
        datosFila(Icons.calendar_month_outlined, true, 'Fecha', K_MARGIN_LONG, widget.dataScreen.fecha),
        datosFila(Icons.storage_rounded, true, 'Valor tr:', K_MARGIN, widget.dataScreen.dinero),
        datosFila(Icons.energy_savings_leaf, true, 'Energia tranzada:', K_MARGIN, widget.dataScreen.energia),
        // datosFila(FontAwesomeIcons.alignJustify, true, 'Descripción', K_MARGIN_SHORT*2, ''),

        // Container(
        //   margin: const EdgeInsets.only(bottom: K_MARGIN_LONG),
        //   padding: const EdgeInsets.symmetric(horizontal: K_PADDING_SHORT),
        //   alignment: Alignment.centerLeft,
        //   child: Text(
        //     "Hola",
        //     style: Metodos.descripcionTextStyle(context),
        //   ),
        // ),

      ],
    );

    
    Widget ciruclos(bool left, double sizeWidth) {
      return SizedBox(
        height: sizeWidth*2,
        width: sizeWidth,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(left ? sizeWidth : 0), 
              bottomRight: Radius.circular(left ? sizeWidth : 0),
              topLeft: Radius.circular(!left ? sizeWidth : 0),
              bottomLeft: Radius.circular(!left ? sizeWidth : 0)
            ),
            color: Theme.of(context).cardColor.withAlpha((0.1 * 255).toInt()),
          ),
        ),
      );
    }


    Widget lineas = Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: LayoutBuilder(
          builder: (context,constraints){
          return Flex(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            direction: Axis.horizontal,
            children: List.generate((constraints.constrainWidth()/10).floor(), (index) =>
                SizedBox(
                  height: 1,
                  width: 5,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor.withAlpha((0.5 * 255).toInt()),
                    )
                  ))
                )
              );
          }
        ),
      )
    );
    
    Widget divisor = Row(
      children: <Widget>[
        ciruclos(true, 15),
        lineas,
        ciruclos(false, 15),
      ],
    );
    
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
           BoxShadow(
            color: K_COLOR_GREY,
            offset: Offset(0,5),
            blurRadius: 15
          )
        ]
      ),
      margin: const EdgeInsets.only(top: K_MARGIN),
      child: Column(
        children: [
          datosTransaccion,
          divisor,
          Container(
            margin: const EdgeInsets.symmetric(vertical: K_MARGIN_SHORT, horizontal: K_MARGIN),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: K_MARGIN),
                      child: Icon(
                        Icons.monetization_on,
                        color:Theme.of(context).canvasColor
                      )
                    ),
                    Text(
                      "Total",
                      style: Metodos.subtitulosInformativos(context)
                    ),
                  ],
                ),
                Text(
                  "\$ $total",
                  textAlign: TextAlign.end,
                  style: Metodos.subtitulosInformativos(context)
                ),
              ],
            ),
          ),
        
        ],
      ),
    );
  }

  List<Widget> body() {
    return [
      _cartaPrincipal(),
      // _image(),
      Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 25.0, 0.0, 0.0),
        child: _info(),
      ),
      Padding(
        padding: const EdgeInsets.all(12.0),
        child: _ticket(),
      ),
      _btnVolver()
      
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
    
    _nombre.text = "Estiven Hoyos Velandia";
    _ubicacion.text = "Cra 38 16 21 - Tulúa";
    _tipodeEnergia.text = "Solar-Eólica";
    _cantidad.text = "25 kW";
    _horarioSuminsitro.text= "Diurno Bloque 2 CLPE No 03-2021";
    _tarifa.text = "\$ 250 [COP/ Kw]";
    _periodo.text = "Hasta la Cantidad establecida";
    _expriracion.text = "1 Semana";
    
    return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1)),
      child: Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
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
