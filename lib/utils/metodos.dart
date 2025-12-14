import 'dart:math';

import 'package:another_flushbar/flushbar.dart';
import 'package:auto_size_text/auto_size_text.dart';
export 'package:be_energy/data/iconos.dart';
export 'package:be_energy/data/svg.dart';
// import 'package:etrader/data/database_Helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/callmodels.dart';
import '../routes.dart';

class Metodos {

   actionBtn(BuildContext context, int accionbtn){
   
    switch (accionbtn) {
        case 0:
          Navigator.of(context).pop();
          break;
        case 1:
          Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Beenergy()),
          (Route<dynamic> route) => false
          );
          break;
        case 2:
          Navigator.pop(context, false);
          break;
        case 3:
          DatabaseHelper dbHelper = DatabaseHelper();
          dbHelper.deleteUserLocal(1);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Beenergy()),
            (Route<dynamic> route) => false
          );
          break;
        case 4:
          Navigator.pop(context, true);
          break;
        case 5:
          // Navigator.push(context,MaterialPageRoute(builder: (context) => Mapas(
          //   empresas: [empresaAux], 
          //   filtroDistancia: false, 
          //   distancia: 0, 
          //   todasEmpresas: [empresaAux], 
          //   buscador: '', 
          //   posicionInicial: widget.ubicacionUsuario
          // )));
          break;
        default:
          break;
      }
  }

  
  alertsDialogBotonUnico(BuildContext context, String mensaje, double width, double height, String btn1, int accionbtn1){    

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0))
        ),
        title: Container(
          alignment: Alignment.center,
          width: 4*width/5,
          height: 80,
          margin: const EdgeInsets.only( bottom: 10),
          child: const Image(
            alignment: AlignmentDirectional.center,
            image:  AssetImage("assets/img/logo.png"),
            height: 100.0,
          ),
        ),

        content:Container(
            width: 4*width/5,
            height: 120,
            alignment: Alignment.center,
            margin: const EdgeInsets.only(bottom: 5, left: 10, right: 10),
            child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Text(
                mensaje,
                textAlign: TextAlign.center,
                maxLines: 5,
                style: Metodos.descripcionTextStyle(context),
                ),
              )
        ),

        actions: <Widget>[
          SizedBox(
            width: 4*width/5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Flexible(
                  child: FractionallySizedBox(
                    widthFactor: 1,
                    child:Container(
                      decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.black38,
                          width: 1.0,
                        ),
                      )
                      ),
                      child: TextButton(
                        child: Text(
                          btn1,
                          style: Metodos.tittleTextStyle2(context),
                        ),
                        onPressed: () => actionBtn(context, accionbtn1)
                      ),
                    ),
                  )
                ),
              ]
            ),
          ),
          
          
        ]
      )
    );
                                
  }            
   
  alertsDialog(BuildContext context, String mensaje, double width, String btn1, int accionbtn1, String btn2, int accionbtn2){    

  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(25.0))
      ),
      title: Container(
        alignment: Alignment.center,
        width: 4*width/5,
        height: 80,
        margin: const EdgeInsets.only( bottom: 10),
        child: const Image(
          image: AssetImage("assets/img/logo.png"),
        ),
      ),

      content: Container(
        height: 70,
        width: 4*width/5,
        alignment: Alignment.center,
        margin: const EdgeInsets.only(bottom: 5),
        child: FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(
            mensaje,
            style: Metodos.alertDialogTextStyle(context, Theme.of(context).focusColor, FontWeight.normal)
          ),
        ),
      ),

      actions: <Widget>[
        SizedBox(
          width: 4*width/5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Flexible(
                child: FractionallySizedBox(
                  widthFactor: 1,
                  child:Container(
                    decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(
                          color: Colors.black38,
                          width: 1.0,
                        ),
                        right: BorderSide(
                          color: Colors.black38,
                          width: 1.0,
                        ),
                    )
                    ),
                    child: TextButton(
                      child: Text(
                        btn1,
                        style: Metodos.alertDialogTextStyle(context, Theme.of(context).focusColor, FontWeight.normal)
                      ),
                      onPressed: () => actionBtn(context, accionbtn1)
                    ),
                  ),
                )
              ),

              Flexible(
                child: FractionallySizedBox(
                  widthFactor: 1,
                  child: Container(
                    decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(
                          color: Colors.black38,
                          width: 1.0,
                        ),
                    )
                    ),
                    child: TextButton(
                      child: Text(
                        btn2,
                        style: Metodos.alertDialogTextStyle(context, Theme.of(context).focusColor, FontWeight.normal)
                      ),
                      onPressed: () async {
                        actionBtn(context, accionbtn2);
                      }
                    ),
                  ),
                ),
              ),
            ]
          ),
        ),
        
        
      ]
    )
  );
                              
}

  static Future flushbarPositivo(context, mensaje) {
    return Flushbar(
      message:mensaje,
      backgroundColor: Theme.of(context).canvasColor,
      messageColor: Colors.white,
      duration: const Duration(seconds: 3),
      icon: const Icon(
        Icons.compare_arrows_rounded,
        color: Colors.white,
      ),
    ).show(context);
  }

  static Future flushbarPositivoLargo(context, mensaje) {
    return Flushbar(
      message:mensaje,
      backgroundColor: Theme.of(context).canvasColor,
      messageColor: Colors.white,
      duration: const Duration(seconds: 5),
      icon: const Icon(
        Icons.compare_arrows_rounded,
        color: Colors.white,
      ),
    ).show(context);
  }

  static Future flushbarNegativo(context, mensaje) { 
    return Flushbar(
      message: mensaje,
      backgroundColor: Colors.red,
      messageColor: Colors.white,
      duration: const Duration(seconds: 3),
      icon: const Icon(
        Icons.warning_amber_rounded,
        // FontAwesomeIcons.exclamationCircle,
        color: Colors.white,
      ),
    ).show(context);
  }

  static bool validateEmail(String value) {
    bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value);
    return emailValid;
  }
  
  static Widget mediaQuery(BuildContext context, Widget body) {
    return  MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1)),
      child:Scaffold(
          extendBody: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: body
        )
    );
  }
  //Metodo que no hace nada para cuando se piden los retornos de los futuros
  dynamic doesntReturn() {/*do nothing*/}

  static Color colorInverso( BuildContext context) {
    return Theme.of(context).focusColor;
  }

  static Color colorTitulos( BuildContext context) {
    return Theme.of(context).primaryColor;
  }

  //metodo que me permite sacar el ancho de la pantalla del dispositivo
  static double width(BuildContext context){
    return MediaQuery.of(context).size.width;
  }

  static double height(BuildContext context){
    return MediaQuery.of(context).size.height;
  }

  static TextStyle appBartextStyle( BuildContext context, [Color? color, double? fontSize, FontWeight? fontWeight, double? letterSpacing]) {
    return TextStyle(
      color: (color != null) ? color :  Theme.of(context).scaffoldBackgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
    );
  }

  Border borderCajas(context){
    return Border.all(
      width: 1,
      color: Theme.of(context).focusColor
    );
  }
  AppBar appbarPrincipal(context, nombre){

    return  AppBar(
        toolbarHeight: 60,
        elevation: 0.0,
        flexibleSpace: Container(
        width: MediaQuery.of(context).size.width,
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
        )),
        backgroundColor: Colors.transparent,
        // backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        title: Container(
          margin: const EdgeInsets.only( top: 7.5, bottom: 7.5, right: 5.0, left: 5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              
              // Icon(
              //   Icons.account_circle,
              //   color: Theme.of(context).focusColor,
              //   size: 45.0,
              // ),
              Container(
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: const Image(
                  alignment: AlignmentDirectional.center,
                  image: AssetImage("assets/img/avatar.jpg"),
                  // image:  AssetImage("assets/img/logo.png"),
                  width: 55.0,
                  height: 55.0,
                ),
              ),
              
              const SizedBox(width: 15.0),
                    
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    
                    AutoSizeText(
                      "¡Hola, ",
                      maxLines: 2,
                      textAlign: TextAlign.start,
                      style: Metodos.textStyle(
                        context,
                        Theme.of(context).scaffoldBackgroundColor,
                        15,
                        FontWeight.bold,
                        1
                      ),
                    ),

                    AutoSizeText(
                      (nombre != null ) ? " $nombre ! ": "Cristian !", 
                      textAlign: TextAlign.start,
                      maxLines: 2,
                      style: Metodos.textStyle(
                        context,
                        Theme.of(context).scaffoldBackgroundColor,
                        15,
                        FontWeight.bold,
                        1
                      ),
                    )

                  ],
                ),
              ),
            
            ],
          ),
              
          
          
          
        ),
        actions: [
          Container(
            width: 45.0,
            height: 45.0,
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              border: Border.all(
                width: 2.0,
                color: Theme.of(context).scaffoldBackgroundColor
              ),
              borderRadius: BorderRadius.circular(25.0),
            ),
            margin: const EdgeInsets.only( top: 7.5, bottom: 7.5, right: 15.0, left: 0.0),
            child: IconButton(
              icon: const Icon(
                Icons.notifications,
                size: 25.0,
              ),
              color: Theme.of(context).scaffoldBackgroundColor,
              tooltip: "Cerrar Sesión",
              onPressed: () async {
                alertsDialog(context, "¿Deseas cerrar tu sesión ahora?", Metodos.width(context), "Cancelar", 2, "Si", 3);
              }
            ),
          ),
        ],
      );
  }

  AppBar appbarEnergia(context, nombre){

    return  AppBar(
        toolbarHeight: 150,
        elevation: 0.0,
        flexibleSpace: Container(
        width: MediaQuery.of(context).size.width,
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
        )),
        backgroundColor: Colors.transparent,
        // backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        title: Container(
          margin: const EdgeInsets.only( top: 7.5, bottom: 7.5, right: 5.0, left: 5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              
              Container(
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: const Image(
                  alignment: AlignmentDirectional.center,
                  image: AssetImage("assets/img/avatar.jpg"),
                  // image:  AssetImage("assets/img/logo.png"),
                  width: 55.0,
                  height: 55.0,
                ),
              ),
              
              const SizedBox(width: 15.0),
                    
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[

                    AutoSizeText(
                      (nombre != null ) ? "Casa de $nombre ": "Casa de Cristian", 
                      textAlign: TextAlign.start,
                      maxLines: 2,
                      style: Metodos.textStyle(
                        context,
                        Theme.of(context).scaffoldBackgroundColor,
                        15,
                        FontWeight.bold,
                        1
                      ),
                    ),

                    AutoSizeText(
                      "Sistema PV On", 
                      textAlign: TextAlign.start,
                      maxLines: 2,
                      style: Metodos.textStyle(
                        context,
                        Theme.of(context).tabBarTheme.indicatorColor ?? Theme.of(context).primaryColor,
                        14,
                        FontWeight.bold,
                        1
                      ),
                    )

                  ],
                ),
              ),
            
            ],
          ),
              
          
          
          
        ),
        
        actions: [
          Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(15.0, 40.0, 20.0, 10.0),
                width: 50.0,
                height: 50.0,
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  border: Border.all(
                    width: 2.0,
                    color: Theme.of(context).tabBarTheme.indicatorColor ?? Theme.of(context).primaryColor
                  ),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                // margin: const EdgeInsets.only( top: 7.5, bottom: 7.5, right: 15.0, left: 0.0),
                child: IconButton(
                  icon: const Icon(
                    Icons.swap_horiz_rounded,
                    size: 30.0,
                  ),
                  color: Theme.of(context).tabBarTheme.indicatorColor ?? Theme.of(context).primaryColor,
                  tooltip: "Transferido Hoy",
                  onPressed: () async {
                    Navigator.push(context,MaterialPageRoute(builder: (context) => const BolsaScreen()));
                    // alertsDialog(context, "¿Deseas cerrar tu sesión ahora?", Metodos.width(context), "Cancelar", 2, "Si", 3);
                  }
                ),
              ),
              Container(
                margin: const EdgeInsets.only( top: 0, bottom: 7.5, right: 15.0, left: 0.0),
                child: Row(
                  children: [
                    Text(
                      "50 kWh - \$ 14.300",
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Theme.of(context).tabBarTheme.indicatorColor ?? Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold
                      ),
                    )
                  ],
                )
              ),
            
            ],
          ),
        ],
      );
  }


  AppBar appbarSecundaria(context, titulo, color){

    return  AppBar(
        toolbarHeight: 60,
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 28.0,
          ),
          color: Theme.of(context).canvasColor,
          tooltip: "Volver",
          onPressed: () async {
            Navigator.pop(context);
          }
        ),
        title:  Center(
          child: Text(
            titulo, 
            textAlign: TextAlign.center,
            style: Metodos.textStyle(
              context,
              Metodos.colorInverso(context),
              20,
              FontWeight.w600,
              2.5
            ),
          ),
        ),
        actions: [
          Container(
            width: 45.0,
            height: 45.0,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border.all(
                width: 2.0,
                color: Theme.of(context).scaffoldBackgroundColor
              ),
              borderRadius: BorderRadius.circular(25.0),
            ),
            margin: const EdgeInsets.only( top: 2.0, bottom: 2.0, right: 15.0, left: 0.0),
            child: IconButton(
              icon: const Icon(
                Icons.donut_large_rounded,
                size: 30.0,
              ),
              color: Theme.of(context).canvasColor,
              tooltip: "Mis estadisticas",
              onPressed: () async {
                Navigator.pop(context);
              }
            ),
          ),
        ],
      );
  }
  
  static TextStyle tittleTextStyle2( BuildContext context,  [ Color? color, FontWeight? fontWeight]){
    return textStyle(context, color, 25, fontWeight, 1.5);
  }

  static TextStyle btnTextStyle( BuildContext context,  [ Color? color, FontWeight? fontWeight]){
    return textStyle(context, color, 20, fontWeight, 1.5);
  }

  static TextStyle btnTextStyleFondo( BuildContext context,  [ Color? color, FontWeight? fontWeight]){
    return textStyle(context, color, 15, fontWeight, 1.5);
  }

  static LinearGradient gradientClasic(BuildContext context){
    return LinearGradient(
      colors: [Theme.of(context).canvasColor, Theme.of(context).focusColor],
      stops: const [0, 1],
      begin: const AlignmentDirectional(0.94, -1),
      end:   const AlignmentDirectional(-0.94, 1),
    );
  }

  static Border borderClasic(BuildContext context) {
    return Border.all(
      width: 0.25,
      color: Theme.of(context).focusColor
    );
  }

  static Border borderClasicFondoNegro(BuildContext context) {
    return Border.all(
      width: 0.25,
      color: Theme.of(context).scaffoldBackgroundColor
    );
  }
  static TextStyle alertDialogTextStyle( BuildContext context,  [ Color? color, FontWeight? fontWeight]){
    return textStyle(context, color, 15, fontWeight, 1.5);
  }

  static TextStyle textStyle( BuildContext context, [Color? color, double? fontSize, FontWeight? fontWeight, double? letterSpacing]) {
    return TextStyle(
      color: (color != null) ? color :  Theme.of(context).scaffoldBackgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
    );
  }
  
  static TextStyle textosSimple(BuildContext context){
    return TextStyle(
      color: Theme.of(context).focusColor,
      fontSize: 14.0,
      fontWeight: FontWeight.w400,
      letterSpacing: 1.5,
    );
  }

  static TextStyle subtitulosSimple(BuildContext context){
    return TextStyle(
      color: Theme.of(context).focusColor,
      fontSize: 15.0,
      height: 1.5,
      fontFamily: "SEGOEUI",
      fontWeight: FontWeight.w200,
      letterSpacing: 1.10,
    );
  }

  static TextStyle subtitulosInformativos(BuildContext context){
    return TextStyle(
      color: Theme.of(context).focusColor,
      fontSize: 15.0,
      fontFamily:"SEGOEUI",
      fontWeight: FontWeight.bold,
      letterSpacing: 1.10,
    );
  }

  static TextStyle subtitulosInformativosFondoNegro(BuildContext context){
    return TextStyle(
      color: Theme.of(context).scaffoldBackgroundColor,
      fontSize: 15.0,
      fontFamily:"SEGOEUI",
      fontWeight: FontWeight.bold,
      letterSpacing: 1.10,
    );
  }

  static TextStyle textofromEditingFondoNegro(BuildContext context){
    return TextStyle(
      color: Theme.of(context).scaffoldBackgroundColor,
      fontSize: 15.0,
      fontFamily:"SEGOEUI",
      fontWeight: FontWeight.w100,
      letterSpacing: 2.5,
    );
  }

  
  static TextStyle textofromEditingFondoBlanco(BuildContext context){
    return TextStyle(
      color: Theme.of(context).focusColor,
      fontSize: 12.0,
      fontFamily:"SEGOEUI",
      fontWeight: FontWeight.w100,
      letterSpacing: 2.5,
    );
  }

  static TextStyle subtitulosInformativosW(BuildContext context){
    return TextStyle(
      color: Theme.of(context).scaffoldBackgroundColor,
      fontSize: 15.0,
      fontFamily:"SEGOEUI",
      fontWeight: FontWeight.bold,
      letterSpacing: 1.10,
    );
  }



  static String saldo(String valor) {
    var decimal = NumberFormat("###,###.##");
    String decimall = decimal.format(int.parse(valor));
    decimall=decimall.replaceAll(",",".");
    return decimall;
  }

  static String energia(String valor) {
    var decimal = NumberFormat("###,###.##");
    String decimall = decimal.format(int.parse(valor));
    decimall=decimall.replaceAll(",",".");
    return decimall;
  }

  //Descripcion textos
  static TextStyle descripcionTextStyle( BuildContext context, [Color? color, double? fontSize, FontWeight? fontWeight, double? letterSpacing, TextDecoration decoration = TextDecoration.none]) {
    return TextStyle(
      color: Metodos.colorInverso(context),
      fontSize: fontSize ?? 22,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      decoration: decoration
    );
  }

  //metodo para decorar formularios.
  static InputDecoration decorationformularios (BuildContext context, Color colApp1, String labelText){
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      alignLabelWithHint: true,
      fillColor: Colors.black,
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: colApp1
        )
      ),
      errorStyle: descripcionTextStyle(context, Colors.red, 15),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: colApp1
        ) 
      ),
      hintStyle: descripcionTextStyle(context, colApp1),
      labelText: labelText,
      labelStyle: textStyle(context, colApp1),
      counterStyle: descripcionTextStyle(context, null,18)
    );
  }

  static bool distancia(double latActual, double lonActual, double latDestino, double lonDestino, double distanciaMaxima) {
    const R = 6371e3; // metres
      var v1 = latActual * pi/180; // φ, λ in radians
      var v2 = latDestino * pi/180;
      var v3 = (latDestino - latActual) * pi/180;
      var v4 = (lonDestino - lonActual) * pi/180;
      var a = sin(v3/2) * sin(v3/2) + cos(v1) * cos(v2) * sin(v4/2) * sin(v4/2);
      var c = 2 * atan2(sqrt(a), sqrt(1-a));
      var d = R * c; // in metres
      return d <= distanciaMaxima*1000;
  }
}

class GradientBack extends StatelessWidget {
  

  const GradientBack({super.key });

  @override
  Widget build(BuildContext context) {

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    
    // Color colApp1 = Theme.of(context).primaryColor;
    // Color colApp2 = Theme.of(context).canvasColor;
  

    return Stack(
      children: <Widget>[
        Container(
          width: screenWidth,
          height: screenHeight,
          color: Theme.of(context).primaryColor.withAlpha((0.90 * 255).toInt()),
          child: FittedBox(
            fit: BoxFit.none,
            alignment: const Alignment(0, 4),
            child: Container(
              width: screenWidth,
              height: screenHeight-100,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ),
      ],
    );
  }

}



// ignore: must_be_immutable
class GradientBackInsideApp extends StatelessWidget {
  
  final double height;
  Color? color;
  final double opacity;

  GradientBackInsideApp({
    super.key,
    required this.color,
    required this.height,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: <Widget>[
        Container(
          width: screenWidth,
          height: screenHeight,
          color: Theme.of(context).scaffoldBackgroundColor,
          child: FittedBox(
            fit: BoxFit.none,
            alignment: const Alignment(0, 4),
            child: Container(
              width: screenWidth,
              height: screenHeight- height,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ),
      ],
    );
  }

}

// ignore: must_be_immutable
class InputTextFieldWidget extends StatelessWidget {



  InputTextFieldWidget({
    super.key,
    required this.labelText,
    required this.controller,
    this.formato,
    this.onChange,
    this.textType,
    this.readOnly,
    this.obscureText,
    required this.context, required String? Function(dynamic value) validador,
  });

  String labelText;
  TextEditingController controller;
  List<TextInputFormatter>? formato;
  Function(String p1)? onChange;
  TextInputType? textType;
  bool? readOnly;
  bool? obscureText;
  BuildContext context;

  //Constantes
  static final List<TextInputFormatter> formatoSinTildes = [FilteringTextInputFormatter.deny(RegExp('[ñ,Á,é,É,í,Í,ó,Ó,ú,Ú,ü,Ü,Ñ,á]'))];
  static final List<TextInputFormatter> formatoNombre = [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z, ]'))];
  static final List<TextInputFormatter> formatoSoloDigitos = [FilteringTextInputFormatter.digitsOnly];
  static final List<TextInputFormatter> formatoTexto = [FilteringTextInputFormatter.singleLineFormatter];

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        readOnly: readOnly ?? false,
        controller: controller,
        inputFormatters: formato ?? [FilteringTextInputFormatter.deny(RegExp('[ñ,Á,é,É,í,Í,ó,Ó,ú,Ú,ü,Ü,Ñ,á]'))],
        keyboardType: textType ?? TextInputType.name,
        
        onChanged: onChange ?? (_){},
        decoration: Metodos.decorationformularios(
          context,
          Metodos.colorInverso(context), 
          labelText
        ),
        style: Metodos.descripcionTextStyle(
          context,
          readOnly ?? false
            ? Colors.grey.shade600
            : Metodos.colorInverso(context),
          15,
          FontWeight.w300,
          1.5
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        // validator: validador ?? null,
        obscureText: obscureText ?? false,

      ),
    );
  }
}



class AppbarBtns extends StatelessWidget {
  
  final double height;
  final String? color;
  final double opacity;

  const AppbarBtns({
    super.key,
    this.color,
    required this.height,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: <Widget>[
        Container(
          width: screenWidth,
          height: screenHeight,
          color: Theme.of(context).primaryColor.withAlpha((opacity* 255).toInt()),
          child: FittedBox(
            fit: BoxFit.none,
            alignment: const Alignment(0, 4),
            child: Container(
              width: screenWidth,
              height: screenHeight- height,
              decoration: BoxDecoration(
                color: color != null ? Theme.of(context).scaffoldBackgroundColor : Color(int.parse("0xff$color")),
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ),
      ],
    );
  }

}




// ignore: must_be_immutable
class FondoScreen extends StatefulWidget {
  
  final Widget body;
  double marginBody;
  double heightAppBar;
  double radiusAppBar;
  bool showCircles;
  bool backButton;
  bool floatingButton;
  bool buttonQR;
  bool showLogo;
  bool? showAppBar;
  double? toolbarHeight;
  double? topCircles;
  Widget? leading;
  Size? sizeLogo;
  List<Widget>? actions;
  MyUser? myUser;
  Widget? floatingButtonIcon;
  Function()? floatingButtonOnTap;
  Function()? backButtonPressed;

  FondoScreen({
    super.key, 
    required this.body,
    this.marginBody = 0,
    required this.heightAppBar,
    this.radiusAppBar = 0,
    this.showCircles = false,
    this.backButton = false,
    this.showLogo = true,
    this.buttonQR = false,
    this.floatingButton = false,
    this.toolbarHeight,
    this.topCircles,
    this.leading,
    this.actions,
    this.sizeLogo,
    this.showAppBar,
    this.myUser,
    this.floatingButtonIcon,
    this.floatingButtonOnTap,
    this.backButtonPressed,
  });

  @override
  State<FondoScreen> createState() => _FondoScreenState();
}

class _FondoScreenState extends State<FondoScreen> {
  //atirbutos de clase
  String result = "No data";
  bool qrEncontrado = false;

  @override
  Widget build(BuildContext context) {


    return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1)),
      child: widget.showAppBar ?? true 
      ? Scaffold(
        appBar: AppBar(
          elevation: 0,
          
          centerTitle: true,
          
          title: const Text( 
            'Be Energy',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800
            ),
          
          ),
          // title: Placeholder(),
          toolbarHeight: 50,
          leading: widget.leading ?? (widget.backButton ? BackButton(onPressed: widget.backButtonPressed, color: Theme.of(context).tabBarTheme.indicatorColor ?? Theme.of(context).primaryColor ): Container()),
          actions: widget.actions,
        ),
        body:  Stack(
          alignment: Alignment.center,
          children: <Widget>[
            SingleChildScrollView(
              // ignore: prefer_const_constructors
              child: GradientBackInsideApp(
                color: Theme.of(context).primaryColor,
                height: widget.heightAppBar,
                opacity: 0.9,
              )
            ),

            ListView(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: widget.marginBody),
                  child: widget.body,
                ),
              ],
            ),
          ]
        )
      ) 
      : Container()
    );
 }
}
