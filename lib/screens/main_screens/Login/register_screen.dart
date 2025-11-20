// ignore_for_file: use_build_context_synchronously

import 'package:be_energy/utils/metodos.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
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
  final TextEditingController _email   = TextEditingController();
  final TextEditingController _nombre  = TextEditingController();
  final TextEditingController _pass    = TextEditingController();
  bool existeUsuario = false;

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
                onPressed: () async {
                  _validador();

                  if(val) {
                    var au = await dbHelper.getUsers();
                    List usuariosList = (au.usuarios != null) ? au.usuarios! : [];
                    existeUsuario = false;

                    for (var i = 0; i < usuariosList.length; i++) {
                      if(_email.value.text == usuariosList[i].correo){
                        existeUsuario = true;
                        break;
                      }
                    }

                    if(existeUsuario == true) {
                      await Metodos.flushbarNegativo(context, 'Ya existe una cuenta con este correo');
                    } else {
                      MyUser usuariolocal = MyUser(
                        idUser    : usuariosList.length,
                        nombre    : _nombre.value.text,
                        telefono  : '',
                        correo    : _email.value.text,
                        clave     : _pass.value.text,
                        energia   : '90',
                        dinero    : '100000',
                        idCiudad  : 0
                      );
                      dbHelper.addUsertbUsuarios(usuariolocal);
                      await Metodos.flushbarPositivoLargo(context, 'Usuario creado exitosamente');
                    }
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
                child: Text(
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