// ignore_for_file: file_names
import 'dart:async';

import 'package:be_energy/utils/metodos.dart';
import 'package:flutter/material.dart';

import '../../../models/my_user.dart';

class CambiarClavePerfilScreen extends StatefulWidget {
  final MyUser myUser;

  const CambiarClavePerfilScreen({Key? key, required this.myUser}) : super(key: key);

  @override
  State<CambiarClavePerfilScreen> createState() => _CambiarClavePerfilScreenState();
}


class _CambiarClavePerfilScreenState extends State<CambiarClavePerfilScreen> {
  Metodos metodos = Metodos();
  
  final TextEditingController _email = TextEditingController();
  
  
  Widget _btnOption(String label, String hintText, TextEditingController controller){
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 0),
      child: TextFormField(
        controller: controller,
        obscureText: false,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: Metodos.subtitulosInformativosFondoNegro(context),
          hintText: hintText,
          hintStyle: Metodos.textofromEditingFondoNegro(context),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).scaffoldBackgroundColor,
              width: 0.25,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).scaffoldBackgroundColor,
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
              color: Theme.of(context).scaffoldBackgroundColor,
              width: 0.25,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Theme.of(context).focusColor,
          contentPadding: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 10),
        ),
        style: Metodos.textofromEditingFondoNegro(context),
        validator: (value) {
          if (value!.length < 4) {
            return 'Ingrese una clave mayor a 3 caracetes';
          }
          return null;
        },
      ),
    );

  }

  Widget _optiones(String label, String hintText, TextEditingController controller){
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(5, 5, 5, 0),
            child: _btnOption(label, hintText, controller),
          ),
        ),// _btnOption(textTitulo, action),
       ],
    );  
  }
  

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
              padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
              child: _optiones("Correo", "Ingrese por favor su correo", _email),
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
    _email.text = "Ingrese por favor su correo";
    return Scaffold(
      appBar: _appbarEditarPerfil(),
      backgroundColor: Theme.of(context).focusColor,
      body:_body()
    );
  }
}


