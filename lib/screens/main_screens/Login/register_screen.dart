// ignore_for_file: use_build_context_synchronously

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

  Widget _volveraLogin(){

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        height: 30,
          child: InkWell(
            onTap: () async {
              Navigator.pop(context);
            },
            child: Text(
              'Volver a login',
              style: Metodos.textStyle(
                context,
                Metodos.colorInverso(context),
                15,
                FontWeight.w300,
                1.5
              ),
            ),
          ),
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

  Widget _cajasText(String text){

    return Container(
      width: Metodos.width(context),
      margin: const EdgeInsets.only(left: 60, top: 10),
      child:  Text(
        text,
        style: Metodos.textStyle(
          context,
          Metodos.colorInverso(context),
          15,
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
            
            _cajasText('Nombre'),
            
            // 
            Container(
              margin: const EdgeInsets.only(left: 60, right: 60, top: 0),
              child: InputTextFieldWidget(
                context: context,
                labelText: 'Ingresa tu nombre aqui',
                controller: _nombre,
                readOnly: false,
                onChange: _validador(),
                validador: (value) {
                  if (value!.length < 3) {
                    return 'Ingrese un nombre mayor a 3 caracetes';
                  }
                  return null;
                },
              ),
            ),

            _cajasText('Email'),
            // 
            Container(
              margin: const EdgeInsets.only(left: 60, right: 60, top: 0),
              child: InputTextFieldWidget(
                context: context,
                labelText: 'Ingresa tu correo aqui',
                controller: _email,
                readOnly: false,
                onChange: _validador(),
                validador: (value) {
                  if (!Metodos.validateEmail(value!)) {
                    return 'Ingrese un email válido ';
                  }
                  return null;
                },
              ),
            ),

            _cajasText('Clave'),
            // 
            Container(
              margin: const EdgeInsets.only(left: 60, right: 60, top: 0),
              child: InputTextFieldWidget(
                context: context,
                labelText: 'Clave',
                controller: _pass,
                readOnly: false,
                obscureText: true,
                onChange: _validador(),
                validador: (value) {
                  if (value!.length < 4) {
                    return 'Ingrese una clave mayor a 3 caracetes';
                  }
                  return null;
                },
              ),
            ),

            InkWell(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              
              onTap: () async {
                _validador();
                
                if(val) { 

                  var au= await dbHelper.getUsers();
                  List usuariosList =  (au.usuarios != null) ? au.usuarios!  : [];
                  existeUsuario = false;
                  
                  for (var i = 0; i < usuariosList.length; i++) {
                    if(_email.value.text == usuariosList[i].correo){
                      existeUsuario = true;
                      break;
                    }
                  }

                  if(existeUsuario == true ) {
                    await Metodos.flushbarNegativo(context, 'Ya posee una cuenta con este correo');
                  }

                  else{
                    // print('Creando usuario en la posicion ${usuariosList.length}');
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

              child: Container(
                margin: const EdgeInsets.only(right: 65, left: 65, top: 10),
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.circular(25),
                ),
                
                child: Center(
                  child: Text(
                    'Enviar',
                    style: Metodos.btnTextStyle(context, Colors.white)
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