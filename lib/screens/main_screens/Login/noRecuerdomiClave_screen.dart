// ignore_for_file: file_names

import 'package:be_energy/utils/metodos.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/repositories/auth_repository.dart';
import 'package:flutter/material.dart';

import '../../../models/callmodels.dart';
import 'reset_password_screen.dart';

class NoRecuerdomiclaveScreen extends StatefulWidget {
  const NoRecuerdomiclaveScreen({super.key});

  @override
  State<NoRecuerdomiclaveScreen> createState() => _NoRecuerdomiclaveScreenState();
}

class _NoRecuerdomiclaveScreenState extends State<NoRecuerdomiclaveScreen> {
  final TextEditingController _emailController = TextEditingController();
  final AuthRepository _authRepository = AuthRepository();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

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
          color: context.colors.onSurface,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: context.textStyles.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
            fontWeight: AppTokens.fontWeightMedium,
          ),
          hintStyle: context.textStyles.bodyMedium?.copyWith(
            color: context.colors.outline,
          ),
          filled: true,
          fillColor: context.colors.surface,
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
            borderSide: BorderSide(
              color: context.colors.error,
              width: 1.5,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: AppTokens.borderRadiusMedium,
            borderSide: BorderSide(
              color: context.colors.error,
              width: 2.5,
            ),
          ),
          prefixIcon: Icon(
            Icons.email_outlined,
            color: context.colors.primary,
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
              color: context.colors.onSurfaceVariant,
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
                color: context.colors.primary,
                fontWeight: AppTokens.fontWeightBold,
                decoration: TextDecoration.underline,
                decorationColor: context.colors.primary,
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
              label: 'Correo electrónico',
              hint: 'correo@ejemplo.com',
              controller: _emailController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresa tu correo';
                }
                if (!Metodos.validateEmail(value.trim())) {
                  return 'Ingresa un correo válido';
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
                onPressed: _isLoading ? null : () async {
                  final email = _emailController.text.trim();
                  if (!Metodos.validateEmail(email)) {
                    Metodos.flushbarNegativo(context, 'Ingresa un correo válido');
                    return;
                  }
                  setState(() => _isLoading = true);
                  try {
                    final response = await _authRepository.forgotPassword(email: email);
                    if (context.mounted) {
                      if (response.success) {
                        Metodos.flushbarPositivo(
                          context,
                          'Si existe una cuenta con este correo, recibirás un código por email.',
                        );
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (context.mounted) {
                            context.push(ResetPasswordScreen(email: email));
                          }
                        });
                      } else {
                        Metodos.flushbarNegativo(
                          context,
                          response.message ?? 'No se pudo enviar el código. Intenta de nuevo.',
                        );
                      }
                    }
                  } catch (_) {
                    if (context.mounted) {
                      Metodos.flushbarNegativo(context, 'Error de conexión. Intenta de nuevo.');
                    }
                  } finally {
                    if (mounted) setState(() => _isLoading = false);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: context.colors.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: AppTokens.space16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(context.colors.onPrimary),
                        ),
                      )
                    : Text(
                        'Enviar código',
                        style: context.textStyles.titleMedium?.copyWith(
                          color: context.colors.onPrimary,
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