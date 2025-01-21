// ignore_for_file: file_names
import 'dart:async';

import 'package:be_energy/utils/metodos.dart';
import 'package:flutter/material.dart';
import '../../../models/my_user.dart';

class TutorialScreen extends StatefulWidget {
  final MyUser myUser;

  const TutorialScreen({super.key, required this.myUser});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}


class _TutorialScreenState extends State<TutorialScreen> {
  Metodos metodos = Metodos();

  Widget _texto(){
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsetsDirectional.fromSTEB(25, 25, 25, 10),
            padding: const EdgeInsetsDirectional.fromSTEB(15, 25, 15, 0),
            child: Text(
              "Ingrese el correo electrónico asociado con su cuenta y le enviaremos un enlace para restablecer su contraseña",
              textAlign: TextAlign.justify,
              style: TextStyle(
                color: Theme.of(context).scaffoldBackgroundColor,
                fontSize: 15,
                fontWeight: FontWeight.w200,
                letterSpacing: 1.5,
                height: 1.5,
                
              )
            ),
          ),
        ),// _btnOption(textTitulo, action),
       ],
    );  
  }
  
  Widget _btnGuardarCambios() {
   return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      
      onTap: () async {

        await Metodos.flushbarPositivo(context, 'Correo enviado exitosamente');

        Timer(const Duration(seconds: 2), () => Navigator.pop(context));

        
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
            'Enviar',
            style: Metodos.btnTextStyleFondo(context, Colors.white)
          ),
        ),
      ),
    );     
  
  }
  
  Widget _body(){
    return  SingleChildScrollView(
        child: Column(

          children: [

            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
              child: _texto(),
            ),

            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 15, 0, 0),
              child: _btnGuardarCambios(),
            ),
            
          ],
        ),
      );
  }
  
  PreferredSizeWidget _appbarEditarPerfil() {
    return AppBar(
      backgroundColor: Theme.of(context).focusColor,
      automaticallyImplyLeading: false,
      leading: InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () async {
          Navigator.pop(context);
        },
        child: Icon(
          Icons.chevron_left_rounded,
          color: Theme.of(context).scaffoldBackgroundColor,
          size: 32,
        ),
      ),
      title: Text(
        "Cambiar Clave",
        style: Metodos.btnTextStyle(context),
      ),
      centerTitle: false,
      elevation: 0,
    );
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: _appbarEditarPerfil(),
      backgroundColor: Theme.of(context).focusColor,
      body:_body()
    );
  }
}


