import 'package:be_energy/utils/metodos.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/services/auth_service.dart';
import 'package:be_energy/models/auth_models.dart';
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
  Metodos metodos = Metodos();
  final AuthService _authService = AuthService();
  final CommunityService _communityService = CommunityService();
  //TextEditingController
  final TextEditingController _email = TextEditingController();
  final TextEditingController _clave = TextEditingController();
  //atributos de clase
  bool val = false;
  bool _isLoading = false;
  bool showpassword = false;

  void _updateFormState([String? _]) {
    setState(() {
      val =
          Metodos.validateEmail(_email.text.trim()) && _clave.text.length >= 4;
    });
  }

  String _themeValue(
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

  AuthUser _buildAuthUser(Map<String, dynamic> userData, String? token) {
    return AuthUser.fromJson({
      ...userData,
      'token': token ?? '',
    });
  }

  MyUser _applyCommunityToUser(MyUser user, Community community) {
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

  Future<void> _saveUserThemeAndEnter(
    BuildContext context,
    MyUser usuario,
    String message,
  ) async {
    await iniciarSesion(usuario);

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

  Widget _noRecuerdomiClave(BuildContext context) {
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

  //comparador para iniciar session en la App de Kupi. si hay un error por medio de
  // un flus bar indica el error al usuario (usuario no existente, password incorrecta). entre otros.
  // de ser el caso al iniciar la sesión por primera vez, desplega el tutorial.
  Future<void> iniciarSesion(MyUser usuario) async {
    DatabaseHelper dbHelper = DatabaseHelper();

    MyUser usuariolocal = MyUser(
      idUser: usuario.idUser,
      nombre: usuario.nombre,
      lastname: usuario.lastname,
      telefono: usuario.telefono,
      correo: usuario.correo,
      clave: usuario.clave,
      energia: usuario.energia,
      dinero: usuario.dinero,
      idCiudad: usuario.idCiudad,
      role: usuario.role,
      roleName: usuario.roleName,
      primaryColor: usuario.primaryColor,
      secondColor: usuario.secondColor,
      urlImg: usuario.urlImg,
      communityId: usuario.communityId,
      communityName: usuario.communityName,
    );
    await dbHelper.addUser(usuariolocal);
  }

  Widget _ingresarAmiCuenta(BuildContext context) {
    return AuthPrimaryButton(
      label: 'Iniciar Sesión',
      isLoading: _isLoading,
      onPressed: _isLoading
          ? null
          : () async {
              // Capturar el context antes del await
              final localContext = context;

              _updateFormState();
              if (val) {
                setState(() {
                  _isLoading = true;
                });
                try {
                  // Llamada al servicio de autenticación
                  final response = await _authService.login(
                    email: _email.text.trim(),
                    password: _clave.text,
                  );

                  if (!mounted) return;
                  setState(() {
                    _isLoading = false;
                  });

                  if (response['success']) {
                    // Login exitoso con el API
                    final userData = response['data'] as Map<String, dynamic>;
                    final token = response['token'];
                    final primaryColor = _themeValue(
                      userData,
                      'primary_color',
                      CommunityThemeStorage.defaultPrimaryColor,
                    );
                    final secondColor = _themeValue(
                      userData,
                      'second_color',
                      CommunityThemeStorage.defaultSecondColor,
                    );
                    final urlImg = _themeValue(
                      userData,
                      'url_img',
                      CommunityThemeStorage.defaultUrlImg,
                    );

                    // Crear usuario local con los datos del API
                    MyUser usuario = MyUser(
                      idUser: userData['user_id'] ?? 0,
                      nombre: userData['name'] ?? userData['email'],
                      lastname: userData['lastname'] ?? '',
                      telefono: userData['phone'] ?? '',
                      correo: userData['email'] ?? _email.text,
                      clave: _clave.text,
                      energia: userData['energy'] ?? '0',
                      dinero: userData['balance'] ?? '0',
                      idCiudad: userData['city_id'] ?? 0,
                      role: userData['role'],
                      roleName: userData['role_name'],
                      primaryColor: primaryColor,
                      secondColor: secondColor,
                      urlImg: urlImg,
                    );

                    // Debug: imprimir datos del usuario
                    debugPrint('Login - Usuario creado:');
                    debugPrint('  ID: ${usuario.idUser}');
                    debugPrint('  Nombre: ${usuario.nombre}');
                    debugPrint('  Role: ${usuario.role}');
                    debugPrint('  Role Name: ${usuario.roleName}');

                    // Guardar token si es necesario
                    if (token != null) {
                      // El token ya está guardado en el ApiClient por el AuthService
                    }

                    final communities =
                        _parseCommunityIds(userData['communities']);
                    debugPrint('Login - Comunidades: $communities');
                    final message =
                        response['message'] as String? ?? 'Ingresando a App';

                    if (communities.length > 1) {
                      final authUser =
                          _buildAuthUser(userData, token as String?);

                      if (!localContext.mounted) return;
                      Navigator.of(localContext).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (selectionContext) =>
                              CommunitySelectionScreen(
                            user: authUser,
                            onCommunitySelected: (community) async {
                              final selectedUser =
                                  _applyCommunityToUser(usuario, community);
                              await _saveUserThemeAndEnter(
                                  selectionContext, selectedUser, message);
                            },
                          ),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    } else if (communities.length == 1) {
                      final community = await _communityService
                          .selectCommunity(communities.first);
                      final selectedUser =
                          _applyCommunityToUser(usuario, community);
                      if (!localContext.mounted) return;
                      await _saveUserThemeAndEnter(
                          localContext, selectedUser, message);
                    } else {
                      if (!localContext.mounted) return;
                      await _saveUserThemeAndEnter(
                          localContext, usuario, message);
                    }
                  } else {
                    // Error en el login
                    if (!localContext.mounted) return;
                    Metodos.flushbarNegativo(localContext,
                        response['message'] ?? 'Error al iniciar sesión');
                  }
                } catch (e) {
                  if (!mounted) return;
                  setState(() {
                    _isLoading = false;
                  });
                  if (!localContext.mounted) return;
                  Metodos.flushbarNegativo(
                      localContext, 'Error de conexión. Verifica tu internet.');
                }
              } else {
                Metodos.flushbarNegativo(localContext,
                    'Por favor, completa todos los campos correctamente');
              }
            },
    );
  }

  Widget _noTienesCuenta(BuildContext context) {
    return const SizedBox.shrink();
  }

  Widget body(BuildContext context) {
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
          onChanged: _updateFormState,
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
          controller: _clave,
          icon: Icons.lock_outline,
          obscureText: true,
          textInputAction: TextInputAction.done,
          onChanged: _updateFormState,
          validator: (value) {
            if (value!.length < 4) {
              return 'Ingrese una contraseña mayor a 3 caracteres';
            }
            return null;
          },
        ),
        _noRecuerdomiClave(context),
        _ingresarAmiCuenta(context),
        _noTienesCuenta(context)
      ],
    );
  }

  //metodo que pinta la pantalla principal del controlador de Kupi, en la misma se pregunta si el usuario
  //quiere loguearse o por defecto registrarse dentro de la app.
  Widget myScaffold(BuildContext context) {
    return body(context);
  }

  @override
  Widget build(BuildContext context) {
    return myScaffold(context);
  }
}
