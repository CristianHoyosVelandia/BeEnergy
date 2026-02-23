// ignore_for_file: use_build_context_synchronously

import 'package:be_energy/core/api/api_exceptions.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/repositories/auth_repository.dart';
import 'package:be_energy/utils/metodos.dart';
import 'package:flutter/material.dart';

import '../../../models/callmodels.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  //creo el formulario y los controladores del mismo
  final form = GlobalKey<FormState>();
  final TextEditingController _email    = TextEditingController();
  final TextEditingController _nombre   = TextEditingController();
  final TextEditingController _apellido = TextEditingController();
  final TextEditingController _telefono = TextEditingController();
  final TextEditingController _pass     = TextEditingController();
  int _tipoPerfil = 1; // 1=consumidor, 2=prosumidor
  bool _isLoading = false;

  final AuthRepository _authRepository = AuthRepository();

  //Objetos de clase
  DatabaseHelper dbHelper = DatabaseHelper();
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
    String? Function(String?)? validator,
    bool obscureText = false,
    IconData? icon,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppTokens.space32,
        vertical: AppTokens.space8,
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
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
            icon ?? (obscureText ? Icons.lock_outline : Icons.person_outline),
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

        Form(
          key: form,
          child: ListView(
            children: <Widget>[
            
            imagenLogin(),

            loginText(),

            SizedBox(height: AppTokens.space16),

            _modernInput(
              label: 'Nombre',
              hint: 'Ingresa tu nombre',
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
              label: 'Apellido',
              hint: 'Ingresa tu apellido',
              controller: _apellido,
              icon: Icons.person_outline,
              validator: (value) {
                if (value!.length < 2) {
                  return 'Ingrese un apellido válido';
                }
                return null;
              },
            ),

            _modernInput(
              label: 'Celular',
              hint: '10 dígitos (ej: 3001234567)',
              controller: _telefono,
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return null;
                final digits = value.trim().replaceAll(RegExp(r'\D'), '');
                if (digits.length != 10) {
                  return 'El celular debe tener exactamente 10 números';
                }
                return null;
              },
            ),

            _modernInput(
              label: 'Email',
              hint: 'Ingresa tu correo electrónico',
              controller: _email,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingrese un correo electrónico';
                }
                if (!Metodos.validateEmail(value.trim())) {
                  return 'El correo debe ser válido';
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
              padding: EdgeInsets.symmetric(horizontal: AppTokens.space32, vertical: AppTokens.space8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tipo de perfil', style: context.textStyles.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant)),
                  Row(
                    children: [
                      Radio<int>(value: 1, groupValue: _tipoPerfil, onChanged: (v) => setState(() => _tipoPerfil = v!)),
                      Text('Consumidor'),
                      Radio<int>(value: 2, groupValue: _tipoPerfil, onChanged: (v) => setState(() => _tipoPerfil = v!)),
                      Text('Prosumidor'),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppTokens.space32,
                vertical: AppTokens.space16,
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : () async {
                  if (_tipoPerfil != 1 && _tipoPerfil != 2) {
                    Metodos.flushbarNegativo(context, 'Perfil inválido');
                    return;
                  }
                  if (!(form.currentState?.validate() ?? false)) return;

                  setState(() => _isLoading = true);
                  try {
                    final response = await _authRepository.register(
                      nombre: _nombre.value.text.trim(),
                      apellido: _apellido.value.text.trim(),
                      email: _email.value.text.trim(),
                      password: _pass.value.text,
                      telefono: () {
                        final t = _telefono.text.trim();
                        if (t.isEmpty) return null;
                        return t.replaceAll(RegExp(r'\D'), '');
                      }(),
                      role: _tipoPerfil,
                    );

                    if (response.success) {
                      if (context.mounted) {
                        await Metodos.flushbarPositivo(context, 'Registro exitoso');
                        context.pop();
                      }
                    } else {
                      if (context.mounted) {
                        final msg = (response.message ?? '').toLowerCase();
                        String show = response.message ?? 'Error al registrarse';
                        if (msg.contains('email') || msg.contains('correo')) {
                          if (msg.contains('existe') || msg.contains('registrado')) {
                            show = 'Ya existe un usuario Registrado con ese email';
                          }
                        } else if (msg.contains('perfil')) {
                          show = 'Perfil inválido';
                        }
                        Metodos.flushbarNegativo(context, show);
                      }
                    }
                  } on ApiException catch (e) {
                    if (context.mounted) {
                      final m = e.message.toLowerCase();
                      String show = 'Error al registrarse';
                      if (m.contains('email') || m.contains('correo')) {
                        if (m.contains('existe') || m.contains('registrado') || m.contains('ya')) {
                          show = 'Ya existe un usuario registrado con este email';
                        } else {
                          show = e.message;
                        }
                      } else if (m.contains('perfil')) {
                        show = 'Perfil inválido';
                      } else if (m.contains('documento')) {
                        show = e.message;
                      } else {
                        show = e.message;
                      }
                      Metodos.flushbarNegativo(context, show);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Metodos.flushbarNegativo(context, 'Error de conexión. Verifica tu configuración.');
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
                  _isLoading ? 'Registrando...' : 'Crear Cuenta',
                  style: context.textStyles.titleMedium?.copyWith(
                    color: context.colors.onPrimary,
                    fontWeight: AppTokens.fontWeightBold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ), 

            // comprueboListaUsuarios(),
            
            _volveraLogin()
          
          ],
          ),
        )
       
      ],
    );   
  }


  @override
  Widget build(BuildContext context) {
    return Metodos.mediaQuery(context, body());
  }
}