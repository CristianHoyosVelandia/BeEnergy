// ignore_for_file: file_names
import 'dart:async';

import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/utils/metodos.dart';
import 'package:flutter/material.dart';

import '../../../models/my_user.dart';

class CambiarClavePerfilScreen extends StatefulWidget {
  final MyUser myUser;
  const CambiarClavePerfilScreen({super.key, required this.myUser});
  @override
  State<CambiarClavePerfilScreen> createState() => _CambiarClavePerfilScreenState();
}

class _CambiarClavePerfilScreenState extends State<CambiarClavePerfilScreen> {
  Metodos metodos = Metodos();

  final TextEditingController _email = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  /// AppBar personalizado con gradiente
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0.0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              blurRadius: 6,
              color: Color(0x4B1A1F24),
              offset: Offset(0, 2),
            )
          ],
          gradient: Metodos.gradientClasic(context),
        ),
      ),
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Cambiar Clave',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: false,
    );
  }

  /// Icono ilustrativo
  Widget _buildIcon() {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: AppTokens.space24,
        horizontal: AppTokens.space16,
      ),
      child: Center(
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppTokens.primaryBlue.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.lock_reset,
            size: 60,
            color: AppTokens.primaryBlue,
          ),
        ),
      ),
    );
  }

  /// Card con información y formulario
  Widget _buildFormCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
      padding: EdgeInsets.all(AppTokens.space20),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppTokens.borderRadiusLarge,
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(
              'Restablecer Contraseña',
              style: context.textStyles.titleLarge?.copyWith(
                fontWeight: AppTokens.fontWeightBold,
              ),
            ),
            SizedBox(height: AppTokens.space12),
            // Descripción
            Text(
              'Ingrese el correo electrónico asociado con su cuenta y le enviaremos un enlace para restablecer su contraseña.',
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: AppTokens.space24),
            // Campo de correo
            Text(
              'Correo Electrónico',
              style: context.textStyles.titleSmall?.copyWith(
                fontWeight: AppTokens.fontWeightSemiBold,
              ),
            ),
            SizedBox(height: AppTokens.space8),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'ejemplo@correo.com',
                hintStyle: context.textStyles.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant.withValues(alpha: 0.6),
                ),
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: AppTokens.primaryRed,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: context.colors.outline.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  borderRadius: AppTokens.borderRadiusMedium,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppTokens.primaryBlue,
                    width: 2,
                  ),
                  borderRadius: AppTokens.borderRadiusMedium,
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.red,
                    width: 1.5,
                  ),
                  borderRadius: AppTokens.borderRadiusMedium,
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.red,
                    width: 2,
                  ),
                  borderRadius: AppTokens.borderRadiusMedium,
                ),
                filled: true,
                fillColor: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppTokens.space16,
                  vertical: AppTokens.space16,
                ),
              ),
              style: context.textStyles.bodyLarge,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese su correo electrónico';
                }
                if (!value.contains('@') || !value.contains('.')) {
                  return 'Ingrese un correo electrónico válido';
                }
                return null;
              },
            ),
            SizedBox(height: AppTokens.space24),
            // Botón de enviar
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  /// Botón de enviar con gradiente
  Widget _buildSubmitButton() {
    return InkWell(
      onTap: () async {
        if (_formKey.currentState!.validate()) {
          // Mostrar mensaje de éxito
          context.showSuccessSnackbar('Correo enviado exitosamente');

          // Esperar 2 segundos y volver
          Timer(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        }
      },
      borderRadius: AppTokens.borderRadiusMedium,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: AppTokens.space16),
        decoration: BoxDecoration(
          gradient: Metodos.gradientClasic(context),
          borderRadius: AppTokens.borderRadiusMedium,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.send_rounded,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: AppTokens.space8),
            Text(
              'Enviar Enlace',
              style: context.textStyles.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: AppTokens.fontWeightMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Info adicional
  Widget _buildAdditionalInfo() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppTokens.space16,
        vertical: AppTokens.space20,
      ),
      padding: EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        color: AppTokens.info.withValues(alpha: 0.1),
        borderRadius: AppTokens.borderRadiusMedium,
        border: Border.all(
          color: AppTokens.info.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppTokens.info,
            size: 24,
          ),
          SizedBox(width: AppTokens.space12),
          Expanded(
            child: Text(
              'El enlace de restablecimiento será válido por 24 horas.',
              style: context.textStyles.bodySmall?.copyWith(
                color: AppTokens.info,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: context.colors.surfaceContainerLowest,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: AppTokens.space16,
          bottom: AppTokens.space24,
        ),
        child: Column(
          children: [
            _buildIcon(),
            _buildFormCard(),
            _buildAdditionalInfo(),
          ],
        ),
      ),
    );
  }
}
