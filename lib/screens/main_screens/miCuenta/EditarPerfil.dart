// ignore_for_file: file_names
import 'dart:async';

import 'package:be_energy/utils/metodos.dart';
import 'package:flutter/material.dart';

import '../../../models/my_user.dart';

class EditarPerfilScreen extends StatefulWidget {
  final MyUser myUser;

  const EditarPerfilScreen({Key? key, required this.myUser}) : super(key: key);

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}


class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  Metodos metodos = Metodos();

  final TextEditingController _nombre = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _edad = TextEditingController();
  final TextEditingController _titulo = TextEditingController();


  bool val= false;

  Widget _contenPrincipalCard(){
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 50, 0, 0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Image
              Card(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                color: Theme.of(context).scaffoldBackgroundColor,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(90),
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                  child: Container(
                    width: 160,
                    height: 160,
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
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 15, 0, 0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _btnOptionMain()
            ],
          ),
        ),
      ],
    );
  }

  Widget _btnOptionMain(){
    return  InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () => {
        // ignore: avoid_print
        print("Presiono en cambiar foto")
      },
      child: Material(
        color: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
          height: 40,
          width: 180,
          decoration: BoxDecoration(
            color: Theme.of(context).focusColor,
            borderRadius: BorderRadius.circular(8),
            border: Metodos.borderClasicFondoNegro(context)
          ),
          child: Padding(
            padding:const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Cambiar Foto",
                  style: Metodos.textStyle(context, Theme.of(context).scaffoldBackgroundColor, 15, FontWeight.w200, 1.5),
                ),
              ],
            ),
          ),
        ),
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
  
  Widget _btnGuardarCambios() {
   return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      
      onTap: () async {

        await Metodos.flushbarPositivo(context, 'Cambios realizados correctamente');

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
            'Guardar Cambios',
            style: Metodos.btnTextStyleFondo(context, Colors.white)
          ),
        ),
      ),
    );     
  
  }
  Widget _cartaPrincipal(){
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 0, 0),
        child: _contenPrincipalCard()
      ),
    );
            
  }
  
  Widget _body(){
    return  SingleChildScrollView(
        child: Column(

          children: [
            _cartaPrincipal(),

            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
              child: _optiones("Nombre", "Ingrese por favor su nombre", _nombre),
            ),

            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
              child: _optiones("Correo", "Ingrese por favor su correo", _email),
            ),

            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
              child: _optiones("Edad", "Ingrese por favor su edad", _edad),
            ),

            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
              child: _optiones("Titulo", "Ingrese por favor su titulo", _titulo),
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
        "Editar Perfil",
        style: Metodos.btnTextStyle(context),
      ),
      centerTitle: false,
      elevation: 0,
    );
  }
  @override
  Widget build(BuildContext context) {
    
    _email.text  = widget.myUser.correo!;
    _nombre.text = widget.myUser.nombre!;
    _titulo.text = "Ing. Mecatrónico";
    _edad.text   = "27";


    return Scaffold(
      appBar: _appbarEditarPerfil(),
      backgroundColor: Theme.of(context).focusColor,
      body:_body()
    );
  }
}


