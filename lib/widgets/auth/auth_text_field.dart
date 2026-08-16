import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;

  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.inputFormatters,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _hideText;

  @override
  void initState() {
    super.initState();
    _hideText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppTokens.space32,
        vertical: AppTokens.space8,
      ),
      child: TextFormField(
        controller: widget.controller,
        obscureText: _hideText,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        onChanged: widget.onChanged,
        inputFormatters: widget.inputFormatters,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        style: context.textStyles.bodyLarge?.copyWith(color: AppTokens.grey800),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          labelStyle: context.textStyles.bodyMedium?.copyWith(
            color: AppTokens.grey600,
            fontWeight: AppTokens.fontWeightMedium,
          ),
          hintStyle: context.textStyles.bodyMedium?.copyWith(
            color: AppTokens.grey400,
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
            borderSide: BorderSide(
              color: AppTokens.primaryColor,
              width: 1.5,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: AppTokens.borderRadiusMedium,
            borderSide: BorderSide(
              color: AppTokens.primaryColor,
              width: 2.5,
            ),
          ),
          prefixIcon: Icon(widget.icon, color: AppTokens.primaryColor),
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(
                    _hideText ? Icons.visibility_off : Icons.visibility,
                    color: AppTokens.primaryColor,
                  ),
                  onPressed: () => setState(() => _hideText = !_hideText),
                )
              : null,
        ),
        validator: widget.validator,
      ),
    );
  }
}
