// ignore_for_file: file_names
import 'dart:async';

import 'package:be_energy/utils/metodos.dart';
import 'package:flutter/material.dart';
import '../../../models/my_user.dart';

class CentroNotificacionesPerfilScreen extends StatefulWidget {
  final MyUser myUser;

  const CentroNotificacionesPerfilScreen({Key? key, required this.myUser}) : super(key: key);

  @override
  State<CentroNotificacionesPerfilScreen> createState() => _CentroNotificacionesPerfilScreenState();
}


class _CentroNotificacionesPerfilScreenState extends State<CentroNotificacionesPerfilScreen> {
  Metodos metodos = Metodos();
  bool pushNotifications = true;
  bool emailNotifications = false;
  bool locationServices = true;

  @override
  void initState() {
    super.initState();
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
              "Elije qué notificaciones deseas recibir a continuación y actualizaremos la configuración.",
              textAlign: TextAlign.justify,
              style: TextStyle(
                color: Theme.of(context).scaffoldBackgroundColor,
                fontSize: 13,
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

        await Metodos.flushbarPositivo(context, 'Configuración guardada exitosamente');

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
            'Guardar',
            style: Metodos.btnTextStyleFondo(context, Colors.white)
          ),
        ),
      ),
    );     
  
  }
  
  Widget _optionScroll(bool value1, int expression, String titulo, String subtitulo) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(8, 15, 8, 0),
      child: SwitchListTile.adaptive(
          value: value1,
          onChanged: (newValue) async {
            setState(() {
              switch (expression) {
                case 1:
                 pushNotifications = newValue; 
                break;
                case 2:
                 emailNotifications = newValue;
                break;
                case 3:
                  locationServices = newValue;
                break;
                default:
                pushNotifications = newValue;
              }
            });
          },
          title: Text(
            titulo,
            style: Metodos.subtitulosInformativosW(context),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.fromLTRB(8, 15, 8,0),
            child: Text(
              subtitulo,
              style: TextStyle(
                color: Theme.of(context).scaffoldBackgroundColor,
                fontSize: 13,
                fontWeight: FontWeight.w200,
                letterSpacing: 1.5,
                height: 1.5,
                
              ),
            ),
          ),
          tileColor: Theme.of(context).focusColor,
          activeColor: Theme.of(context).canvasColor,
          activeTrackColor: Theme.of(context).scaffoldBackgroundColor,
          dense: false,
          controlAffinity: ListTileControlAffinity.trailing,
          contentPadding: const EdgeInsetsDirectional.fromSTEB(24, 12, 24, 12),
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
            _optionScroll(pushNotifications,  1,"Notificaciones Push",'Reciba notificaciones automáticas de nuestra aplicación de forma semi regular.'),
            _optionScroll(emailNotifications, 2,"Notificaciónes de Email",'Reciba notificaciones por email de nuestro equipo de marketing y soporte sobre transacciones de energía y nuevas funciones'),
            _optionScroll(locationServices,   3,"Servicios de localización",'Permítanos rastrear su ubicación, esto nos ayuda a contactarlo con Peers cercanos y brindarle asistencia en intercambios energéticos.'),

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
        "Centro de Notificaciones",
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


