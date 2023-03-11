import 'package:another_flushbar/flushbar.dart';
// import 'package:etrader/data/database_Helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class Metodos {

  //  actionBtn(BuildContext context, int accionbtn){
   
  //   switch (accionbtn) {
  //       case 0:
  //         Navigator.of(context).pop();
  //         break;
  //       case 1:
  //         Navigator.of(context).pushNamedAndRemoveUntil('/kupi', (Route<dynamic> route) => false);
  //         break;
  //       case 2:
  //         Navigator.pop(context, false);
  //         break;
  //       case 3:
  //         DatabaseHelper dbHelper = new DatabaseHelper();
  //         dbHelper.deleteUserLocal(0);
  //         Navigator.of(context).pushNamedAndRemoveUntil('/etrader', (Route<dynamic> route) => false);                 
  //         break;
  //       case 4:
  //         Navigator.pop(context, true);
  //         break;
  //       default:
  //         print("no reconoce ninguna accion");
  //         break;
  //     }
  // }

  //  alertsDialog(BuildContext context, String mensaje, double width, String btn1, int accionbtn1, String btn2, int accionbtn2){    

  //   return showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.all(Radius.circular(25.0))
  //       ),
  //       title: Container(
  //         alignment: Alignment.center,
  //         width: 4*width/5,
  //         height: 80,
  //         margin: EdgeInsets.only( bottom: 10),
  //         child: Image(
  //           image: AssetImage("assets/img/head.png"),
  //         ),
  //       ),

  //       content: Container(
  //         height: 70,
  //         width: 4*width/5,
  //         alignment: Alignment.center,
  //         margin: EdgeInsets.only(bottom: 5),
  //         child: FittedBox(
  //           fit: BoxFit.fitWidth,
  //           child: Text(
  //             "$mensaje",
  //             style: Metodos.alertDialogTextStyle(context, Theme.of(context).focusColor, FontWeight.normal)
  //           ),
  //         ),
  //       ),

  //       actions: <Widget>[
  //         Container(
  //           width: 4*width/5,
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [

  //               Flexible(
  //                 child: FractionallySizedBox(
  //                   widthFactor: 1,
  //                   child:Container(
  //                     decoration: BoxDecoration(
  //                     border: Border(
  //                       top: BorderSide(
  //                           color: Colors.black38,
  //                           width: 1.0,
  //                         ),
  //                         right: BorderSide(
  //                           color: Colors.black38,
  //                           width: 1.0,
  //                         ),
  //                     )
  //                     ),
  //                     child: TextButton(
  //                       child: Text(
  //                         btn1,
  //                         style: Metodos.alertDialogTextStyle(context, Theme.of(context).focusColor, FontWeight.normal)
  //                       ),
  //                       onPressed: () => actionBtn(context, accionbtn1)
  //                     ),
  //                   ),
  //                 )
  //               ),

  //               Flexible(
  //                 child: FractionallySizedBox(
  //                   widthFactor: 1,
  //                   child: Container(
  //                     decoration: BoxDecoration(
  //                     border: Border(
  //                       top: BorderSide(
  //                           color: Colors.black38,
  //                           width: 1.0,
  //                         ),
  //                     )
  //                     ),
  //                     child: TextButton(
  //                       child: Text(
  //                         btn2,
  //                         style: Metodos.alertDialogTextStyle(context, Theme.of(context).focusColor, FontWeight.normal)
  //                       ),
  //                       onPressed: () async {
  //                         actionBtn(context, accionbtn2);
  //                       }
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ]
  //           ),
  //         ),
          
          
  //       ]
  //     )
  //   );
                                
  // }



  static Future flushbarPositivo(context, mensaje) {
    return Flushbar(
      message:mensaje,
      backgroundColor: Theme.of(context).cardColor,
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
      backgroundColor: Theme.of(context).cardColor,
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
      data: MediaQuery.of(context).copyWith(
      textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.4),
      // textScaleFactor:0.5,
    ),
    
    child:Scaffold(
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
  //metodo que me permite sacar el ancho de la pantalla del dispositivo
  static double width(BuildContext context){
    return MediaQuery.of(context).size.width;
  }

  static double height(BuildContext context){
    return MediaQuery.of(context).size.height;
  }

  AppBar appbarPrincipal(context, title, actions ){

    return  AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      title: title,
      actions: actions,
    );
  }


  static TextStyle tittleTextStyle2( BuildContext context,  [ Color? color, FontWeight? fontWeight]){
    return textStyle(context, color, 25, fontWeight, 1.5);
  }

  static TextStyle btnTextStyle( BuildContext context,  [ Color? color, FontWeight? fontWeight]){
    return textStyle(context, color, 20, fontWeight, 1.5);
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
          color: Theme.of(context).primaryColor,
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
class InputTextFieldWidget extends StatelessWidget {



  InputTextFieldWidget({
    Key? key,
    required this.labelText,
    required this.controller,
    this.formato,
    this.onChange,
    this.textType,
    this.readOnly,
    this.obscureText,
    required this.context,
  }) : super(key: key);

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
          18,
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
