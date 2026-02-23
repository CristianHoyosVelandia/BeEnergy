import 'package:be_energy/utils/metodos.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/api/api_exceptions.dart';
import 'package:be_energy/repositories/auth_repository.dart';
import 'package:be_energy/repositories/user_repository.dart';
import 'package:flutter/material.dart';

import '../../../models/callmodels.dart';
import '../../../routes.dart';
import 'verify_2fa_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  Metodos metodos = Metodos();
  final AuthRepository _authRepository = AuthRepository();
  final UserRepository _userRepository = UserRepository();
  bool _isLoading = false;

  //TextEditingController
  final TextEditingController _email = TextEditingController();
  final TextEditingController _clave = TextEditingController();
  
  //atributos de clase
  bool val= false;

  Function(String)? _validador() {
   
    return (validator) {
      setState(() {
        // print("Validate email inverso: ${!Metodos.validateEmail(_email.value.text)}");
        if ( Metodos.validateEmail(_email.value.text) && _clave.value.text.length >= 4 ) {
          val = true;
        } else {
          val = false;
        }
      });
    };
  }
  
  Widget imagenLogin(){
    return Image(
      alignment: AlignmentDirectional.center,
      image:  const AssetImage("assets/img/Login.png"),
      width: 3/4 * Metodos.width(context),
      height: 275,
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
                "Ingresa a tu cuenta",
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

  Widget _modernInput({
    required String label,
    required String hint,
    required TextEditingController controller,
    required String? Function(String?) validator,
    bool obscureText = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppTokens.space32,
        vertical: AppTokens.space8,
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        onChanged: _validador(),
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
          fillColor: context.colors.surfaceContainerHighest.withValues(alpha: 0.95),
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppTokens.space20,
            vertical: AppTokens.space16,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppTokens.borderRadiusMedium,
            borderSide: BorderSide(
              color: context.colors.outline.withValues(alpha: 0.6),
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
            obscureText ? Icons.lock_outline : Icons.email_outlined,
            color: context.colors.primary,
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _noRecuerdomiClave(){
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppTokens.space32,
        vertical: AppTokens.space4,
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: InkWell(
          onTap: () async {
            context.push(const NoRecuerdomiclaveScreen());
          },
          borderRadius: AppTokens.borderRadiusSmall,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppTokens.space12,
              vertical: AppTokens.space4,
            ),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: AppTokens.borderRadiusSmall,
            ),
            child: Text(
              '¿Olvidaste la contraseña?',
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.primary,
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
  void iniciarSesion(MyUser usuario) async {

    DatabaseHelper dbHelper = DatabaseHelper();

    MyUser usuariolocal = MyUser(
      idUser    : usuario.idUser,
      nombre    : usuario.nombre,
      telefono  : usuario.telefono,
      correo    : usuario.correo,
      clave     : usuario.clave,
      energia   : usuario.energia,
      dinero    : usuario.dinero,
      idCiudad  : usuario.idCiudad
    );


    dbHelper.addUser(usuariolocal);
  }
  

  Widget _ingresarAmiCuenta(BuildContext context){
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppTokens.space32,
        vertical: AppTokens.space16,
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : () async {
          _validador();
          if (!val) {
            Metodos.flushbarNegativo(context, 'Ingrese correo y contraseña válidos');
            return;
          }

          setState(() => _isLoading = true);
          try {
            final response = await _authRepository.login(
              email: _email.value.text.trim(),
              password: _clave.value.text,
            );

            if (response.success && response.data != null) {
              final data = response.data!;

              // Si el backend requiere 2FA, navegar a verificación OTP
              final otpRequired = data['otp_required'] == true;
              final tempSession = data['temp_session'] as String?;
              if (otpRequired && tempSession != null && tempSession.isNotEmpty) {
                final userId = data['user_id'] as int? ?? int.tryParse(data['id']?.toString() ?? '0') ?? 0;
                final email = data['email'] as String? ?? _email.value.text;
                if (context.mounted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Verify2FAScreen(
                        tempSession: tempSession,
                        email: email,
                        userId: userId,
                      ),
                    ),
                  );
                }
                return;
              }

              final userId = data['user_id'] as int? ?? int.tryParse(data['id']?.toString() ?? '0') ?? 0;
              final email = data['email'] as String? ?? _email.value.text;

              MyUser usuariolocal = MyUser(
                idUser: userId,
                nombre: data['name'] as String? ?? '',
                telefono: data['phone'] as String? ?? '',
                correo: email,
                clave: '',
                energia: '0',
                dinero: '0',
                idCiudad: 0,
              );

              try {
                final userResp = await _userRepository.getUser(userId);
                if (userResp.success && userResp.data != null) {
                  final u = userResp.data!;
                  final roleVal = u['role'];
                  final roleInt = roleVal is int ? roleVal : (roleVal != null ? int.tryParse(roleVal.toString()) : null);
                  usuariolocal = MyUser(
                    idUser: u['id'] ?? userId,
                    nombre: u['name'] ?? u['nombre'] ?? '',
                    telefono: u['phone'] ?? u['telefono'] ?? '',
                    correo: u['email'] ?? u['correo'] ?? email,
                    clave: '',
                    energia: '0',
                    dinero: '0',
                    idCiudad: u['idCiudad'] ?? 0,
                    role: roleInt,
                  );
                }
              } catch (_) {}

              iniciarSesion(usuariolocal);
              if (context.mounted) {
                Metodos.flushbarPositivo(context, 'Ingresando a App');
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => NavPages(myUser: usuariolocal)
                      ),
                      (Route<dynamic> route) => false
                    );
                  }
                });
              }
            } else {
              if (context.mounted) {
                final msg = response.message ?? '';
                String show = msg;
                if (msg.toLowerCase().contains('correo') && (msg.contains('no') || msg.contains('registrado'))) show = 'El correo no está registrado';
                else if (msg.toLowerCase().contains('contraseña') || msg.toLowerCase().contains('password') || msg.toLowerCase().contains('incorrect')) show = 'Contraseña incorrecta';
                Metodos.flushbarNegativo(context, show.isNotEmpty ? show : 'Credenciales incorrectas');
              }
            }
          } catch (e) {
            if (context.mounted) {
              String mensaje = 'Error de conexión. Verifica tu configuración.';
              if (e is ApiException) {
                final m = e.message.toLowerCase();
                if (m.contains('correo') && (m.contains('no') || m.contains('registrado'))) mensaje = 'El correo no está registrado';
                else if (m.contains('contraseña') || m.contains('password') || m.contains('incorrect')) mensaje = 'Contraseña incorrecta';
                else mensaje = e.message;
              }
              Metodos.flushbarNegativo(context, mensaje);
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
        child: Text(
          _isLoading ? 'Conectando...' : 'Iniciar Sesión',
          style: context.textStyles.titleMedium?.copyWith(
            color: context.colors.onPrimary,
            fontWeight: AppTokens.fontWeightBold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _noTienesCuenta(){
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppTokens.space24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "¿No tienes cuenta?",
            style: context.textStyles.bodyLarge?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          SizedBox(width: AppTokens.space8),
          InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: () {
              context.push(const RegisterScreen());
            },
            child: Text(
              "Regístrate",
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

            _modernInput(
              label: 'Contraseña',
              hint: 'Ingresa tu contraseña',
              controller: _clave,
              obscureText: true,
              validator: (value) {
                if (value!.length < 4) {
                  return 'Ingrese una contraseña mayor a 3 caracteres';
                }
                return null;
              },
            ),
            
            _noRecuerdomiClave(),

            _ingresarAmiCuenta(context),
            
            _noTienesCuenta()

          ],
        )
      
      ],
    );        
  }

  //metodo que pinta la pantalla principal del controlador de Kupi, en la misma se pregunta si el usuario
  //quiere loguearse o por defecto registrarse dentro de la app.
   Widget myScaffold() {
    return Metodos.mediaQuery(context, body());
  }

  @override
  Widget build(BuildContext context) {
    return myScaffold();
  }
}