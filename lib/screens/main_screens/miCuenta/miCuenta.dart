// ignore_for_file: file_names
import 'package:be_energy/screens/main_screens/miCuenta/cambiarClave.dart';
import 'package:be_energy/utils/metodos.dart';
import 'package:flutter/material.dart';
import 'package:be_energy/routes.dart';
import '../../../models/my_user.dart';

class MicuentaScreen extends StatefulWidget {
  final MyUser myUser;

  const MicuentaScreen({Key? key, required this.myUser}) : super(key: key);

  @override
  State<MicuentaScreen> createState() => _MicuentaScreenState();
}


class _MicuentaScreenState extends State<MicuentaScreen> {
  Metodos metodos = Metodos();

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
  
  Widget _contenPrincipalCard(){
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 50, 0, 0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //Image
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
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                "Cristian Hoyos V",
                style: TextStyle(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                )
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            const Padding(
              padding:
                  EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
              child: Text(
                'Ing. mecatrónico - ',
                style: TextStyle(
                  fontFamily: 'Lexend',
                  color: Color(0xB3FFFFFF),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(4, 8, 0, 0),
              child: Text(
                "cristiannhoyoss@gmail.com",
                style: TextStyle(
                  fontFamily: 'Lexend',
                  color: Theme.of(context).scaffoldBackgroundColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _info(){
    return [
      Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 12),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              "Mi Cuenta",
              style: Metodos.subtitulosInformativos(context)
            ),
          ],
        ),
      ),
    ];
  }
  

  Widget _btnOption(String textTitulo, int action){
    return  InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Material(
        color: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: 60,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Metodos.borderClasic(context)
          ),
          child: Padding(
            padding:const EdgeInsetsDirectional.fromSTEB(16, 0, 4, 0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  textTitulo,
                  style: Metodos.subtitulosInformativos(context),
                ),
                IconButton(
                  icon: Icon(
                    Icons.chevron_right_rounded,
                    color: Theme.of(context).canvasColor,
                    size: 25,
                  ),
                  onPressed: () {
                    switch (action) {
                      case 1:
                        Navigator.push(context, MaterialPageRoute(builder: (context) => EditarPerfilScreen(myUser: widget.myUser,)));
                      break;
                      case 2:
                        Navigator.push(context, MaterialPageRoute(builder: (context) => CambiarClavePerfilScreen(myUser: widget.myUser,)));
                      break;
                      default:
                      break;
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );    
  }

  Widget _optiones(String textTitulo, int action){
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _btnOption(textTitulo, action),
       ],
    );  
  }
  
  Widget _cartaPrincipal(){
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 200,
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
        padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 0, 0),
        child: _contenPrincipalCard()
      ),
    );
            
  }
  
  Widget _bodyIdeas(){
    return  SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            _cartaPrincipal(),
            Column(
              mainAxisSize: MainAxisSize.max,
              children: _info()
            ),
            _optiones("Editar Perfil", 1),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 15, 0, 0),
              child: _optiones("Cambiar Clave", 2),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 15, 0, 0),
              child: _optiones("Configuración De Las Notificaciones", 1),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 15, 0, 0),
              child: _optiones("Tutorial", 1),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 15, 0, 0),
              child: _optiones("Aprende sobre DERs", 1),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 15, 0, 0),
              child: _optiones("Política De Privacidad", 1),
            )

            
          ],
        ),
      );
  }
  @override
  Widget build(BuildContext context) {
    // return FondoScreen(
    //   myUser: widget.myUser,
    //   heightAppBar: 50,
    //   radiusAppBar: 90,
    //   leading: _leading(context, Metodos.width(context)),
    //   // actions: _actions(snapshotApp.data, snapshotUser.data),
    //   body: _bodyIdeas()
    // );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body:_bodyIdeas()
    );
  }
}


