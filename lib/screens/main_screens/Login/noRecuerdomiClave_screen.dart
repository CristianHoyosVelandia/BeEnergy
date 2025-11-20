// ignore_for_file: file_names

import 'package:be_energy/utils/metodos.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

import '../../../models/callmodels.dart';

class NoRecuerdomiclaveScreen extends StatefulWidget {
  const NoRecuerdomiclaveScreen({super.key});

  @override
  State<NoRecuerdomiclaveScreen> createState() => _NoRecuerdomiclaveScreenState();
}

class _NoRecuerdomiclaveScreenState extends State<NoRecuerdomiclaveScreen> {
  final TextEditingController _email = TextEditingController();

  Widget _modernInput({
    required String label,
    required String hint,
    required TextEditingController controller,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppTokens.space32,
        vertical: AppTokens.space8,
      ),
      child: TextFormField(
        controller: controller,
        style: context.textStyles.bodyLarge?.copyWith(
          color: Colors.grey[800],
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: context.textStyles.bodyMedium?.copyWith(
            color: Colors.grey[600],
            fontWeight: AppTokens.fontWeightMedium,
          ),
          hintStyle: context.textStyles.bodyMedium?.copyWith(
            color: Colors.grey[400],
          ),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.95),
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppTokens.space20,
            vertical: AppTokens.space16,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppTokens.borderRadiusMedium,
            borderSide: BorderSide(
              color: context.colors.outline.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppTokens.borderRadiusMedium,
            borderSide: BorderSide(
              color: context.colors.primary,
              width: 2.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppTokens.borderRadiusMedium,
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1.5,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: AppTokens.borderRadiusMedium,
            borderSide: const BorderSide(
              color: Colors.red,
              width: 2.5,
            ),
          ),
          prefixIcon: Icon(
            Icons.email_outlined,
            color: Colors.red,
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _volveraLogin(){
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppTokens.space24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "¿Ya tienes cuenta?",
            style: context.textStyles.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          SizedBox(width: AppTokens.space8),
          InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: () {
              context.pop();
            },
            child: Text(
              "Volver a login",
              style: context.textStyles.titleMedium?.copyWith(
                color: Colors.red,
                fontWeight: AppTokens.fontWeightBold,
                decoration: TextDecoration.underline,
                decorationColor: Colors.red,
                decorationThickness: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget imagenLogin(){
    return Container(
      alignment: AlignmentDirectional.center,
      child: Image(
        image: const AssetImage("assets/img/Login.png"),
        width: 3*Metodos.width(context)/4,
        height: 300,
      ),
    );
  }

  Widget loginText(){
    return Container(
      width: Metodos.width(context),
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      child:  Row(
        children: [
          const Expanded(
            flex: 1,
            child: Image(
              alignment: AlignmentDirectional.center,
              image:  AssetImage("assets/img/logo.png"),
              width: 50,
              height: 50,
            )
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Recuperar contraseña",
                style: Metodos.textStyle(
                  context,
                  Metodos.colorTitulos(context),
                  25,
                  FontWeight.bold,
                  1.5
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget body(){
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[

        const SingleChildScrollView(
          child: GradientBack()
        ),

        ListView(
          children: <Widget>[

            imagenLogin(),

            loginText(),

            SizedBox(height: AppTokens.space16),

            _modernInput(
              label: 'Email',
              hint: 'Ingresa tu correo electrónico',
              controller: _email,
              validator: (value) {
                if (!Metodos.validateEmail(value!)) {
                  return 'Ingrese un email válido';
                }
                return null;
              },
            ),

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppTokens.space32,
                vertical: AppTokens.space16,
              ),
              child: ElevatedButton(
                onPressed: () async {
                  // Lógica para enviar email de recuperación
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: AppTokens.space16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  'Enviar',
                  style: context.textStyles.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: AppTokens.fontWeightBold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            _volveraLogin()

          ]
        )

      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Metodos.mediaQuery(context, body());
  }
}