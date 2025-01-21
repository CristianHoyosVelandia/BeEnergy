import 'package:be_energy/utils/metodos.dart';
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
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
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
            child: Text(
              "Log-In",
              style: Metodos.textStyle(
                context,
                Metodos.colorTitulos(context),
                30,
                FontWeight.bold,
                1.5
              ),
            ),
          ),
          const Expanded(
            flex: 3,
            child: SizedBox.shrink(),
          ),
        ],
        
      ),
        
        
    );
  }

  Widget _cajasText(String text){

    return Container(
      width:  Metodos.width(context),
      margin: const EdgeInsets.only(left: 60, top: 10),
      child:  Text(
        text,
        style: Metodos.textStyle(
          context,
          Metodos.colorInverso(context),
          16,
          FontWeight.bold,
          1.5
        ),
      ),
    );
  }

  Widget _noRecuerdomiClave(){

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      height: 30,
      child: Row(
        children: [
          const Expanded(
            flex: 2,
            child: SizedBox.shrink(),
          ),
          Expanded(
            flex: 3,
            child: InkWell(
              onTap: () async {
                //el navigator me permite dirigirme a la ruta para realizar el ingreso a mi cuenta
                Navigator.push(context,MaterialPageRoute(builder: (context) => const NoRecuerdomiclaveScreen()));
              },
              child: Text(
                '¿Olvidaste la clave?',
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
        ],
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
  

  Widget _ingresarAmiCuenta(context){
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      
      onTap: () async {
        
        _validador();

        if(val) {
          DatabaseHelper dbHelper = DatabaseHelper();
          final au= await dbHelper.getUsers();
          List usuariosList =  (au.usuarios != null) ? au.usuarios!  : [];
          for (var i = 0; i < usuariosList.length; i++) {
            if(_email.value.text == usuariosList[i].correo){

              if(_clave.value.text== usuariosList[i].clave){
                iniciarSesion(usuariosList[i]);
                await Metodos.flushbarPositivo(context, 'Ingresando a App');
                Navigator.of(context).pushAndRemoveUntil( 
                  MaterialPageRoute(
                    builder: (context) => NavPages(myUser: usuariosList[i],)
                  ),
                  (Route<dynamic> route) => false
                );
                     
              }

              else{
                Metodos.flushbarNegativo(context, 'Clave Incorrecta, intente nuevamente');
              }
            } else{
              Metodos.flushbarNegativo(context, 'Usuario no encontrado en la base de datos, por favor registrese.');
            }
          }
          // print(usuariosList.length);
        }
      },

      child: Container(
        margin: const EdgeInsets.only(right: 65, left: 65, top: 15),
        height: 50,
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.circular(25),
        ),
        
        child: Center(
          child: Text(
            'Ingresar a mi cuenta',
            style: Metodos.btnTextStyle(context, Colors.white)
          ),
        ),
      ),
    );     
  }

  Widget _noTienesCuenta(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[

        Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.only(top: 25, bottom: 20),
          child: Text(
            "¿No tienes una cuenta ?",
            /*Esta validacion se hara en todos los textos blancos, en el caso de que 
            salga una marca blanca con blanco de fondo*/
            style: Metodos.textStyle(context, Theme.of(context).focusColor, 15)
          ),
        ),


        Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.only(top: 25, left: 10, bottom: 20),
            child: InkWell(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              child: Text(
                "Registrate",
                style: Metodos.textStyle(context, Theme.of(context).primaryColor, 22, FontWeight.bold)
              ),
              onTap: () {
                Navigator.push(context,MaterialPageRoute(builder: (context) => const RegisterScreen()));
              },
            )
        )

        
      ],
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
            
            _cajasText('Email'),
            
            // // 
            Container(
              margin: const EdgeInsets.only(left: 60, right: 60, top: 10),
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
              margin: const EdgeInsets.only(left: 60, right: 60, top: 10),
              child: InputTextFieldWidget(
                context: context,
                labelText: 'Ingresa tu clave',
                controller: _clave,
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