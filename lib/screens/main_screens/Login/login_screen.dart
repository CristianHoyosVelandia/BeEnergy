import 'package:be_energy/utils/metodos.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/services/auth_service.dart';
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

  //TextEditingController
  final TextEditingController _email = TextEditingController();
  final TextEditingController _clave = TextEditingController();

  //atributos de clase
  bool val= false;
  bool _isLoading = false;

  Function(String)? _validador() {
   
    return (validator) {
      setState(() {
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
            obscureText ? Icons.lock_outline : Icons.email_outlined,
            color: Colors.red,
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
              color: Colors.white,
              borderRadius: AppTokens.borderRadiusSmall,
            ),
            child: Text(
              '¿Olvidaste la contraseña?',
              style: context.textStyles.bodyMedium?.copyWith(
                color: Colors.red,
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

          if(val) {
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

              setState(() { _isLoading = false; });

              if (response['success']) {
                // Login exitoso con el API
                final userData = response['data'];
                final token = response['token'];

                // Crear usuario local con los datos del API
                MyUser usuario = MyUser(
                  idUser: userData['user_id'] ?? 0,
                  nombre: userData['name'] ?? userData['email'] ?? 'Cristian Hoyos',
                  telefono: userData['phone'] ?? '3176703596',
                  correo: userData['email'] ?? _email.text,
                  clave: _clave.text,
                  energia: userData['energy'] ?? '0',
                  dinero: userData['balance'] ?? '0',
                  idCiudad: userData['city_id'] ?? 0,
                );

                // Guardar en base de datos local
                iniciarSesion(usuario);

                // Guardar token si es necesario
                if (token != null) {
                  // El token ya está guardado en el ApiClient por el AuthService
                }

                // ignore: use_build_context_synchronously
                Metodos.flushbarPositivo(context, response['message'] ?? 'Ingresando a App');

                // ignore: use_build_context_synchronously
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => NavPages(myUser: usuario)
                  ),
                  (Route<dynamic> route) => false
                );
              } else {
                // Error en el login
                // ignore: use_build_context_synchronously
                Metodos.flushbarNegativo(context, response['message'] ?? 'Error al iniciar sesión');
              }
            } catch (e) {
                if (!mounted) return;

                setState(() {
                  _isLoading = false;
                });

                // ignore: use_build_context_synchronously
                Metodos.flushbarNegativo(context, 'Error de conexión. Verifica tu internet.');
            }
          } else {
            Metodos.flushbarNegativo(context, 'Por favor, completa todos los campos correctamente');
          }
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
        child: _isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              'Iniciar Sesión',
              style: context.textStyles.titleMedium?.copyWith(
                color: Colors.white,
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
              color: Colors.grey[600],
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
                color: Colors.red,
                fontWeight: AppTokens.fontWeightBold,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white,
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