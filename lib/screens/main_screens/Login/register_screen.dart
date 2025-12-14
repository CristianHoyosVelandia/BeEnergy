// ignore_for_file: use_build_context_synchronously

import 'package:be_energy/utils/metodos.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/services/auth_service.dart';
import 'package:flutter/material.dart';

import '../../../models/callmodels.dart';
import '../../../routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  //creo el formulario y los controladores del mismo
  final form = GlobalKey<FormState>();
  final TextEditingController _email   = TextEditingController();
  final TextEditingController _nombre  = TextEditingController();
  final TextEditingController _pass    = TextEditingController();
  bool existeUsuario = false;

  //Objetos de clase
  DatabaseHelper dbHelper = DatabaseHelper();
  final AuthService _authService = AuthService();
  MyUser usuariolocal =  MyUser(
    idUser    : 0,
    nombre    : '',
    telefono  : '',
    correo    : '',
    clave     : '',
    energia   : '',
    dinero    : '',
    idCiudad  : 0,
  );

  bool val = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    dbHelper.addUser(usuariolocal);
  }

  Function(String)? _validador() {
   
    return (validator) {
      setState(() {
        if (_nombre.value.text != '' && _pass.value.text.length < 4 ) {
          val = false;
        } else {
          val = true;
        }
      });
    };
  }

  Widget _modernInput({
    required String label,
    required String hint,
    required TextEditingController controller,
    required String? Function(String?) validator,
    bool obscureText = false,
    IconData? icon,
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
            icon ?? (obscureText ? Icons.lock_outline : Icons.person_outline),
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
        width: 3/4 * Metodos.width(context),
        height: 275,
      ),
    );
  }

  Widget loginText(){
    return Container(
      width: Metodos.width(context),
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      child:  Text(
        'Registro Usuario',
        style: Metodos.textStyle(
          context,
          Metodos.colorTitulos(context),
          22,
          FontWeight.bold,
          1.5
        ),
      ),
    );
  }


  // Widget comprueboListaUsuarios() {
  //   return InkWell(
  //     highlightColor: Colors.transparent,
  //     splashColor: Colors.transparent,
      
  //     onTap: () async {
        
  //       dbHelper = DatabaseHelper();
  //       final au= await dbHelper.getUsers();
  //       List usuariosList =  (au.usuarios != null) ? au.usuarios!  : [];
  //       // print(usuariosList.length);
  //     },

  //     child: Container(
  //       margin: const EdgeInsets.only(right: 65, left: 65, top: 10),
  //       height: 50,
  //       decoration: BoxDecoration(
  //         color: Theme.of(context).cardColor,
  //         borderRadius: BorderRadius.circular(25),
  //       ),
        
  //       child: Center(
  //         child: Text(
  //           'Leer base de datos',
  //           style: Metodos.btnTextStyle(context, Colors.white)
  //         ),
  //       ),
  //     ),
  //   );
  // }

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
              label: 'Nombre',
              hint: 'Ingresa tu nombre completo',
              controller: _nombre,
              icon: Icons.person_outline,
              validator: (value) {
                if (value!.length < 3) {
                  return 'Ingrese un nombre mayor a 3 caracteres';
                }
                return null;
              },
            ),

            _modernInput(
              label: 'Email',
              hint: 'Ingresa tu correo electrónico',
              controller: _email,
              icon: Icons.email_outlined,
              validator: (value) {
                if (!Metodos.validateEmail(value!)) {
                  return 'Ingrese un email válido';
                }
                return null;
              },
            ),

            _modernInput(
              label: 'Contraseña',
              hint: 'Crea una contraseña segura',
              controller: _pass,
              obscureText: true,
              validator: (value) {
                if (value!.length < 4) {
                  return 'Ingrese una contraseña mayor a 3 caracteres';
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
                  _validador();

                  if(val) {
                    // Guardar BuildContext antes del async gap
                    final scaffoldContext = context;

                    setState(() {
                      _isLoading = true;
                    });

                    try {
                      // Llamada al servicio de autenticación para registrar usuario
                      final response = await _authService.signUp(
                        email: _email.text.trim(),
                        password: _pass.text,
                        name: _nombre.text.trim(),
                      );

                      setState(() {
                        _isLoading = false;
                      });

                      if (response['success']) {
                        // Registro exitoso con el API
                        final userData = response['data'];
                        // final token = response['token'];

                        // Crear usuario local con los datos del API
                        MyUser usuario = MyUser(
                          idUser: userData['id'] ?? 0,
                          nombre: userData['name'] ?? _nombre.text,
                          telefono: userData['phone'] ?? '',
                          correo: userData['email'] ?? _email.text,
                          clave: _pass.text,
                          energia: userData['energy'] ?? '90',
                          dinero: userData['balance'] ?? '100000',
                          idCiudad: userData['city_id'] ?? 0,
                        );

                        // Guardar en base de datos local
                        dbHelper.addUsertbUsuarios(usuario);

                        if (mounted) {
                          await Metodos.flushbarPositivoLargo(
                            scaffoldContext,
                            response['message'] ?? 'Usuario creado exitosamente'
                          );

                          // Navegar al login o a la pantalla principal
                          if (mounted) {
                            Navigator.of(scaffoldContext).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => NavPages(myUser: usuario)
                              ),
                              (Route<dynamic> route) => false
                            );
                          }
                        }
                      } else {
                        // Error en el registro
                        if (mounted) {
                          Metodos.flushbarNegativo(
                            scaffoldContext,
                            response['message'] ?? 'Error al crear la cuenta'
                          );
                        }
                      }
                    } catch (e) {
                      setState(() {
                        _isLoading = false;
                      });
                      if (mounted) {
                        Metodos.flushbarNegativo(scaffoldContext, 'Error de conexión. Verifica tu internet.');
                      }
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
                      'Crear Cuenta',
                      style: context.textStyles.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: AppTokens.fontWeightBold,
                        letterSpacing: 0.5,
                      ),
                    ),
              ),
            ), 

            // comprueboListaUsuarios(),
            
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