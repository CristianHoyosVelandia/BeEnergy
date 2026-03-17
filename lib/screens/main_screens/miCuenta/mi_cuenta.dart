import 'package:flutter/material.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/screens/main_screens/miCuenta/cambiarClave.dart';
import 'package:be_energy/utils/metodos.dart';
import 'package:be_energy/routes.dart';
import '../../../models/my_user.dart';
import '../../../data/database_Helper.dart';

class MicuentaScreen extends StatefulWidget {
  final MyUser myUser;
  const MicuentaScreen({super.key, required this.myUser});
  @override
  State<MicuentaScreen> createState() => _MicuentaScreenState();
}


class _MicuentaScreenState extends State<MicuentaScreen> {
  Metodos metodos = Metodos();
  IconButton _leading(BuildContext context, double width) {
    return IconButton(
      icon: Icon(
        Icons.logout_rounded,
        color: Colors.white, size: 22,
      ),
      tooltip: "Cerrar Sesión",
      onPressed: () async {
        _showLogoutDialog(context, width);
      }
    );
  }

  void _showLogoutDialog(BuildContext context, double width) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0))
        ),
        title: Container(
          alignment: Alignment.center,
          width: 4*width/5,
          height: 80,
          margin: const EdgeInsets.only(bottom: 10),
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
              "¿Deseas cerrar tu sesión ahora?",
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
                    child: Container(
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
                          "Cancelar",
                          style: Metodos.alertDialogTextStyle(context, Theme.of(context).focusColor, FontWeight.normal)
                        ),
                        onPressed: () => Navigator.pop(context, false)
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
                          "Si",
                          style: Metodos.alertDialogTextStyle(context, Theme.of(context).focusColor, FontWeight.normal)
                        ),
                        onPressed: () {
                          DatabaseHelper dbHelper = DatabaseHelper();
                          dbHelper.deleteUserLocal(widget.myUser.idUser);
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const Beenergy()),
                            (Route<dynamic> route) => false
                          );
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
  
  Widget _contenPrincipalCard(){
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppTokens.space16,
        vertical: AppTokens.space24,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icono de usuario
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.person,
              size: 28,
              color: Colors.white,
            ),
          ),

          SizedBox(width: AppTokens.space12),

          // Información del usuario
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.myUser.nombre ?? "Usuario",
                  style: context.textStyles.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: AppTokens.fontWeightBold,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppTokens.space4),
                Text(
                  widget.myUser.correo ?? "correo@ejemplo.com",
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: AppTokens.fontWeightRegular,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Botón de logout
          _leading(context, context.width),
        ],
      ),
    );
  }

  Widget _sectionTitle(){
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppTokens.space16,
        vertical: AppTokens.space16,
      ),
      child: Text(
        "Mi Cuenta",
        style: context.textStyles.titleLarge?.copyWith(
          fontWeight: AppTokens.fontWeightSemiBold,
        ),
      ),
    );
  }
  

  Widget _optionButton(String title, IconData icon, int action){
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppTokens.space16,
        vertical: AppTokens.space8,
      ),
      child: InkWell(
        onTap: () {
          switch (action) {
            case 1:
              context.push(EditarPerfilScreen(myUser: widget.myUser));
            break;
            case 2:
              context.push(CambiarClavePerfilScreen(myUser: widget.myUser));
            break;
            case 3:
              context.push(CentroNotificacionesPerfilScreen(myUser: widget.myUser));
            break;
            case 4:
              context.push(TutorialScreen(myUser: widget.myUser));
            break;
            case 5:
              context.push(AprendeScreen(myUser: widget.myUser));
            break;
            case 6:
              context.push(TutorialScreen(myUser: widget.myUser));
            break;
            default:
            break;
          }
        },
        borderRadius: AppTokens.borderRadiusMedium,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppTokens.space16,
            vertical: AppTokens.space16,
          ),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: AppTokens.borderRadiusMedium,
            border: Border.all(
              color: context.colors.outline.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppTokens.space8),
                      decoration: BoxDecoration(
                        color: context.colors.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: AppTokens.borderRadiusSmall,
                      ),
                      child: Icon(
                        icon,
                        size: 20,
                        color: context.colors.primary,
                      ),
                    ),
                    SizedBox(width: AppTokens.space12),
                    Expanded(
                      child: Text(
                        title,
                        style: context.textStyles.bodyLarge?.copyWith(
                          fontWeight: AppTokens.fontWeightMedium,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: context.colors.primary,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _cartaPrincipal(){
    return Container(
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
      ),
      child: _contenPrincipalCard(),
    );
  }
  
  Widget _body(){
    return SingleChildScrollView(
      child: Column(
        children: [
          _cartaPrincipal(),
          SizedBox(height: AppTokens.space24),
          _sectionTitle(),
          _optionButton("Editar Perfil", Icons.person_outline, 1),
          _optionButton("Cambiar Clave", Icons.lock_outline, 2),
          _optionButton("Notificaciones", Icons.notifications_outlined, 3),
          _optionButton("Tutorial", Icons.help_outline, 4),
          _optionButton("Aprende sobre DERs", Icons.school_outlined, 5),
          _optionButton("Política De Privacidad", Icons.privacy_tip_outlined, 6),
          SizedBox(height: AppTokens.space32),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: _body()
    );
  }
}


