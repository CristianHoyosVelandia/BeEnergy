// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/screens/main_screens/miCuenta/cambiarClave.dart';
import 'package:be_energy/utils/metodos.dart';
import 'package:be_energy/routes.dart';
import '../../../models/my_user.dart';

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
        color: Colors.white,
        size: 22,
      ),
      tooltip: "Cerrar Sesión",
      onPressed: () async {
        metodos.alertsDialog(
          context,
          "¿Deseas cerrar tu sesión ahora?",
          width,
          "Cancelar",
          2,
          "Si",
          3
        );
      }
    );
  }
  
  Widget _contenPrincipalCard(){
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: AppTokens.space48,
            right: AppTokens.space16, // Evita overflow
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //Image
              Card(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                color: context.colors.surface,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Padding(
                  padding: EdgeInsets.all(AppTokens.space4),
                  child: Container(
                    width: 60,
                    height: 60,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      "assets/img/avatar.jpg",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              _leading(context, context.width),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: AppTokens.space8,
            right: AppTokens.space16, // Evita overflow
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Text(
                  widget.myUser.nombre ?? "Usuario",
                  style: context.textStyles.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: AppTokens.fontWeightSemiBold,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: AppTokens.space8,
            right: AppTokens.space16, // Evita overflow
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Text(
                  widget.myUser.correo ?? "correo@ejemplo.com",
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: AppTokens.fontWeightMedium,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
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
      height: 220,
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
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          _cartaPrincipal(),
          SizedBox(height: AppTokens.space16),
          _sectionTitle(),
          _optionButton("Editar Perfil", Icons.person_outline, 1),
          _optionButton("Cambiar Clave", Icons.lock_outline, 2),
          _optionButton("Notificaciones", Icons.notifications_outlined, 3),
          _optionButton("Tutorial", Icons.help_outline, 4),
          _optionButton("Aprende sobre DERs", Icons.school_outlined, 5),
          _optionButton("Política De Privacidad", Icons.privacy_tip_outlined, 6),
          SizedBox(height: AppTokens.space24),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: _bodyIdeas()
    );
  }
}


