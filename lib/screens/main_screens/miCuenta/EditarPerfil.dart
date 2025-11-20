// ignore_for_file: file_names
import 'dart:async';

import 'package:be_energy/utils/metodos.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

import '../../../models/my_user.dart';

class EditarPerfilScreen extends StatefulWidget {
  final MyUser myUser;

  const EditarPerfilScreen({super.key, required this.myUser});

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
          padding: EdgeInsets.only(top: AppTokens.space48),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                color: context.colors.surface,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(90),
                ),
                child: Padding(
                  padding: EdgeInsets.all(AppTokens.space4),
                  child: Container(
                    width: 160,
                    height: 160,
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
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: AppTokens.space16),
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
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () => {
        // ignore: avoid_print
        print("Presiono en cambiar foto")
      },
      borderRadius: AppTokens.borderRadiusSmall,
      child: Container(
        height: 40,
        width: 180,
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: AppTokens.borderRadiusSmall,
          border: Border.all(
            color: context.colors.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            "Cambiar Foto",
            style: context.textStyles.titleMedium?.copyWith(
              fontWeight: AppTokens.fontWeightMedium,
            ),
          ),
        ),
      ),
    );
  }

  
  Widget _btnOption(String label, String hintText, TextEditingController controller){
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppTokens.space20,
        vertical: AppTokens.space12,
      ),
      child: TextFormField(
        controller: controller,
        obscureText: false,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: context.textStyles.bodyLarge?.copyWith(
            fontWeight: AppTokens.fontWeightMedium,
          ),
          hintText: hintText,
          hintStyle: context.textStyles.bodyMedium?.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.6),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: context.colors.outline.withValues(alpha: 0.3),
              width: 1,
            ),
            borderRadius: AppTokens.borderRadiusSmall,
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: context.colors.primary,
              width: 2,
            ),
            borderRadius: AppTokens.borderRadiusSmall,
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1,
            ),
            borderRadius: AppTokens.borderRadiusSmall,
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.red,
              width: 2,
            ),
            borderRadius: AppTokens.borderRadiusSmall,
          ),
          filled: true,
          fillColor: context.colors.surface,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppTokens.space20,
            vertical: AppTokens.space12,
          ),
        ),
        style: context.textStyles.bodyLarge,
        validator: (value) {
          if (value!.length < 4) {
            return 'Ingrese una clave mayor a 3 caracteres';
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
          child: _btnOption(label, hintText, controller),
        ),
      ],
    );
  }
  
  Widget _btnGuardarCambios() {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () async {
        await Metodos.flushbarPositivo(context, 'Cambios realizados correctamente');
        Timer(const Duration(seconds: 2), () => context.pop());
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 65,
          vertical: AppTokens.space16,
        ),
        height: 50,
        decoration: BoxDecoration(
          color: context.colors.primary,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: Text(
            'Guardar Cambios',
            style: context.textStyles.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: AppTokens.fontWeightBold,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _cartaPrincipal(){
    return SizedBox(
      width: context.width,
      child: Padding(
        padding: EdgeInsets.only(left: AppTokens.space20),
        child: _contenPrincipalCard(),
      ),
    );
  }
  
  Widget _body(){
    return SingleChildScrollView(
      child: Column(
        children: [
          _cartaPrincipal(),
          _optiones("Nombre", "Ingrese por favor su nombre", _nombre),
          _optiones("Correo", "Ingrese por favor su correo", _email),
          _optiones("Edad", "Ingrese por favor su edad", _edad),
          _optiones("Titulo", "Ingrese por favor su titulo", _titulo),
          _btnGuardarCambios(),
        ],
      ),
    );
  }
  
  PreferredSizeWidget _appbarEditarPerfil() {
    return AppBar(
      backgroundColor: context.colors.surface,
      automaticallyImplyLeading: false,
      leading: InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () async {
          context.pop();
        },
        child: Icon(
          Icons.chevron_left_rounded,
          color: context.colors.onSurface,
          size: 32,
        ),
      ),
      title: Text(
        "Editar Perfil",
        style: context.textStyles.titleLarge?.copyWith(
          fontWeight: AppTokens.fontWeightSemiBold,
        ),
      ),
      centerTitle: false,
      elevation: 0,
    );
  }
  @override
  Widget build(BuildContext context) {
    _email.text  = widget.myUser.correo ?? "";
    _nombre.text = widget.myUser.nombre ?? "";
    _titulo.text = "Ing. Mecatrónico";
    _edad.text   = "27";

    return Scaffold(
      appBar: _appbarEditarPerfil(),
      backgroundColor: context.colors.surface,
      body: _body(),
    );
  }
}


