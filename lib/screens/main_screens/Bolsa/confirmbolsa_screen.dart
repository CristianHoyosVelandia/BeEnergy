import 'dart:async';

import 'package:be_energy/utils/metodos.dart';
import 'package:flutter/material.dart';
import '../../../models/my_intercambio.dart';
import '../../../routes.dart';

class ConfirmchangeScreen extends StatefulWidget {
  final Intercambio dataScreen;
  const ConfirmchangeScreen({Key? key, required this.dataScreen}) : super(key: key);

  @override
  State<ConfirmchangeScreen> createState() => _ConfirmchangeScreenState();
}

 
class _ConfirmchangeScreenState extends State<ConfirmchangeScreen> {
    
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

  Widget _image() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
      child: Image(
        alignment: AlignmentDirectional.center,
        image:  const AssetImage("assets/img/4.png"),
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
        Icons.login_rounded,
        color: Theme.of(context).scaffoldBackgroundColor,
        size: 25,
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(Theme.of(context).primaryColor),
        iconColor: MaterialStatePropertyAll(Theme.of(context).scaffoldBackgroundColor),
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
        backgroundColor: MaterialStatePropertyAll(Theme.of(context).primaryColor),
        iconColor: MaterialStatePropertyAll(Theme.of(context).scaffoldBackgroundColor),
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
              "Usted cuenta con los recursos para realizar el intercambio, los datos para el intercambio de energía:",
              style: Metodos.subtitulosSimple(context)
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _btnOption(String label, String hintText, TextEditingController controller){
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 0),
      child: TextFormField(
        controller: controller,
        obscureText: false,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: Metodos.subtitulosInformativos(context),
          hintText: hintText,
          hintStyle: Metodos.textofromEditingFondoBlanco(context),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).focusColor,
              width: 0.25,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).focusColor,
              width: 0.25,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.red,
              width: 0.25,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).focusColor,
              width: 0.25,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Theme.of(context).scaffoldBackgroundColor,
          contentPadding: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 10),
        ),
        style: Metodos.textofromEditingFondoBlanco(context),
        validator: (value) {
          // if (value!.length < 4) {
          //   return 'Ingrese una clave mayor a 3 caracetes';
          // }
          return null;
        },
      ),
    );

  }

  Widget _optiones(String label1, String hintText1, TextEditingController controller1, String label2, String hintText2, TextEditingController controller2){
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(5, 5, 5, 0),
            child: _btnOption(label1, hintText1, controller1),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(5, 5, 5, 0),
            child: _btnOption(label2, hintText2, controller2),
          ),
        ),// _btnOption(textTitulo, action),
       ],
    );  
  }

  Widget _option(String label1, String hintText1, TextEditingController controller1){
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(5, 5, 5, 0),
            child: _btnOption(label1, hintText1, controller1),
          ),
        ),
      ],
    );  
  }

  
  Widget _btnCrear() {
   return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      
      onTap: () async {

        await Metodos.flushbarPositivo(context, 'Creando intercambio');

        Timer(const Duration(seconds: 2), () => Navigator.push(context,MaterialPageRoute(builder: (context) => const OnboardingWidget())));
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
            'Comfirmar',
            style: Metodos.btnTextStyleFondo(context, Colors.white)
          ),
        ),
      ),
    );     
  
  }
 

  List<Widget> body() {
    return [
      _cartaPrincipal(),
      _image(),
      _info(),
      Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
        child: _optiones("Nombre", "Ingrese por favor su nombre", _nombre, "Ubicación", "Ingrese por favor su ubicación", _ubicacion),
      ),
      Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
        child: _optiones("Tipo de energía", "Ingrese por favor su nombre", _tipodeEnergia, "Cantidad de energía", "Ingrese por favor la cantidad", _cantidad),
      ),
      Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
        child: _optiones("Tarifas", "", _tarifa, "Expiración", "", _expriracion),
      ),
      Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
        child: _option("Horario de suministro", "", _horarioSuminsitro),
      ),
      Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
        child: _option("Periodo de suministro", "", _periodo),
      ),
      _btnCrear()
      
    ];

  }
  
  @override
  Widget build(BuildContext context) {
    
    _nombre.text = widget.dataScreen.nombre;
    _ubicacion.text = "Cra 38 16 21 - Tulúa";
    _tipodeEnergia.text = widget.dataScreen.fuente;
    _cantidad.text = widget.dataScreen.energia;
    _horarioSuminsitro.text= widget.dataScreen.horarioSuminsitro;
    _tarifa.text = widget.dataScreen.dinero;
    _periodo.text = "Hasta la Cantidad establecida";
    _expriracion.text = "1 Semana";
    
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.4),
      ),
      child: Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          ListView(
            children: body()
          ),
        ]
      )
      ));
  }
}
