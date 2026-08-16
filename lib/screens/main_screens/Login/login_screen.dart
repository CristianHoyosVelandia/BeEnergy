import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/services/auth_service.dart';
import 'package:be_energy/utils/metodos.dart';
import 'package:be_energy/models/community_models.dart';
import 'package:be_energy/screens/auth/community_selection_screen.dart';
import 'package:be_energy/services/community_service.dart';
import 'package:be_energy/services/community_theme_storage.dart';
import 'package:be_energy/widgets/auth/auth_header.dart';
import 'package:be_energy/widgets/auth/auth_primary_button.dart';
import 'package:be_energy/widgets/auth/auth_scaffold.dart';
import 'package:be_energy/widgets/auth/auth_text_field.dart';
import 'package:flutter/material.dart';

import '../../../models/callmodels.dart';
import '../../../routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final CommunityService _communityService = CommunityService();

  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return Metodos.validateEmail(_email.text.trim()) &&
        _password.text.length >= 4;
  }

  String _stringValue(
    Map<String, dynamic> userData, String key, String fallback) {
    final value = userData[key]?.toString();
    return value == null || value.isEmpty ? fallback : value;
  }

  List<int> _parseCommunityIds(dynamic value) {
    if (value is! List) return <int>[];
    return value
        .map((item) => item is int ? item : int.tryParse(item.toString()))
        .whereType<int>()
        .toList();
  }

  MyUser _copyUserWithCommunity(MyUser user, Community community) {
    return MyUser(
      idUser: user.idUser,
      nombre: user.nombre,
      lastname: user.lastname,
      telefono: user.telefono,
      correo: user.correo,
      clave: user.clave,
      energia: user.energia,
      dinero: user.dinero,
      idCiudad: user.idCiudad,
      role: community.role ?? user.role,
      roleName: community.roleName ?? user.roleName,
      primaryColor: community.primaryColor ?? user.primaryColor,
      secondColor: community.secondColor ?? user.secondColor,
      urlImg: community.urlImg ?? user.urlImg,
      communityId: community.id,
      communityName: community.name,
    );
  }

  MyUser _buildLocalUser(Map<String, dynamic> userData) {
    return MyUser(
      idUser: userData['user_id'] ?? 0,
      nombre: userData['name'] ?? userData['email'],
      lastname: userData['lastname'] ?? '',
      telefono: userData['phone'] ?? '',
      correo: userData['email'] ?? _email.text,
      clave: _password.text,
      energia: userData['energy'] ?? '0',
      dinero: userData['balance'] ?? '0',
      idCiudad: userData['city_id'] ?? 0,
      role: userData['role'],
      roleName: userData['role_name'],
      primaryColor: _stringValue(
        userData,
        'primary_color',
        CommunityThemeStorage.defaultPrimaryColor,
      ),
      secondColor: _stringValue(
        userData,
        'second_color',
        CommunityThemeStorage.defaultSecondColor,
      ),
      urlImg: _stringValue(
        userData,
        'url_img',
        CommunityThemeStorage.defaultUrlImg,
      ),
    );
  }

  Future<void> _saveSessionAndEnter(
    BuildContext context,
    MyUser usuario,
    String message,
  ) async {
    await _saveLocalSession(usuario);

    final primaryColor =
        usuario.primaryColor ?? CommunityThemeStorage.defaultPrimaryColor;
    final secondColor =
        usuario.secondColor ?? CommunityThemeStorage.defaultSecondColor;
    final urlImg = usuario.urlImg ?? CommunityThemeStorage.defaultUrlImg;

    AppTokens.updateThemeColors(
      primary: Color(CommunityThemeStorage.parseColorString(primaryColor)),
      secondary: Color(CommunityThemeStorage.parseColorString(secondColor)),
      imageUrl: urlImg,
    );

    if (!context.mounted) return;
    Metodos.flushbarPositivo(context, message);

    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => NavPages(myUser: usuario),
      ),
      (Route<dynamic> route) => false,
    );
  }

  Widget _forgotPasswordLink(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppTokens.space32,
        vertical: AppTokens.space4,
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: InkWell(
          onTap: () {
            if (!mounted) return;
            context.push(const NoRecuerdomiclaveScreen());
          },
          borderRadius: AppTokens.borderRadiusSmall,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppTokens.space12,
              vertical: AppTokens.space4,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppTokens.borderRadiusSmall,
            ),
            child: Text(
              '¿Olvidaste la contraseña?',
              style: context.textStyles.bodyMedium?.copyWith(
                color: AppTokens.primaryColor,
                fontWeight: AppTokens.fontWeightMedium,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveLocalSession(MyUser usuario) async {
    await DatabaseHelper().addUser(usuario);
  }

  Future<void> _login() async {
    if (!_isFormValid) {
      Metodos.flushbarNegativo(
        context,
        'Por favor, completa todos los campos correctamente',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _authService.login(
        email: _email.text.trim(),
        password: _password.text,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response['success'] != true) {
        Metodos.flushbarNegativo(
          context,
          response['message'] ?? 'Error al iniciar sesión',
        );
        return;
      }

      await _handleSuccessfulLogin(response);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      Metodos.flushbarNegativo(
        context,
        'Error de conexión. Verifica tu internet.',
      );
    }
  }

  Future<void> _handleSuccessfulLogin(Map<String, dynamic> response) async {
    final userData = response['data'] as Map<String, dynamic>;
    final usuario = _buildLocalUser(userData);
    final communities = _parseCommunityIds(userData['communities']);
    final message = response['message'] as String? ?? 'Ingresando a App';

    if (communities.length > 1) {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (selectionContext) => CommunitySelectionScreen(
            onCommunitySelected: (community) async {
              final selectedUser = _copyUserWithCommunity(usuario, community);
              await _saveSessionAndEnter(
                selectionContext,
                selectedUser,
                message,
              );
            },
          ),
        ),
        (Route<dynamic> route) => false,
      );
      return;
    }

    if (communities.length == 1) {
      final community = await _communityService.selectCommunity(
        communities.first,
      );
      final selectedUser = _copyUserWithCommunity(usuario, community);
      if (!mounted) return;
      await _saveSessionAndEnter(context, selectedUser, message);
      return;
    }

    await _saveSessionAndEnter(context, usuario, message);
  }

  Widget _loginButton() {
    return AuthPrimaryButton(
      label: 'Iniciar Sesión',
      isLoading: _isLoading,
      onPressed: _login,
    );
  }

  Widget _registerLinkPlaceholder() {
    // #por implementar: habilitar registro público cuando esté aprobado.
    return const SizedBox.shrink();
  }

  Widget _body(BuildContext context) {
    return AuthScaffold(
      children: <Widget>[
        const AuthHeader(title: 'Ingresa a tu cuenta'),
        SizedBox(height: AppTokens.space16),
        AuthTextField(
          label: 'Email',
          hint: 'Ingresa tu correo electrónico',
          controller: _email,
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (!Metodos.validateEmail(value!)) {
              return 'Ingrese un email válido';
            }
            return null;
          },
        ),
        AuthTextField(
          label: 'Contraseña',
          hint: 'Ingresa tu contraseña',
          controller: _password,
          icon: Icons.lock_outline,
          obscureText: true,
          textInputAction: TextInputAction.done,
          validator: (value) {
            if (value!.length < 4) {
              return 'Ingrese una contraseña mayor a 3 caracteres';
            }
            return null;
          },
        ),
        _forgotPasswordLink(context),
        _loginButton(),
        _registerLinkPlaceholder(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _body(context);
  }
}
