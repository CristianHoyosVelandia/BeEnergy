// ignore_for_file: file_names

import 'package:be_energy/utils/metodos.dart';
import 'package:flutter/material.dart';

class NoRecuerdomiclaveScreen extends StatefulWidget {
  const NoRecuerdomiclaveScreen({Key? key}) : super(key: key);

  @override
  State<NoRecuerdomiclaveScreen> createState() => _NoRecuerdomiclaveScreenState();
}

class _NoRecuerdomiclaveScreenState extends State<NoRecuerdomiclaveScreen> {
  final TextEditingController _email = TextEditingController();

  Widget _volveraLogin(){

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 50),
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
        width: 3*Metodos.width(context)/4,
        height: 300,
      ),
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
            flex: 5,
            child: Container(
              padding: const EdgeInsets.only(right: 5, left: 20),
              child: Text(
                '¿Olvidaste la Clave?',
                style: Metodos.textStyle(
                  context,
                  Metodos.colorTitulos(context),
                  20,
                  FontWeight.bold,
                  1.5
                ),
              ),
            ),
          ),
          const Expanded(
            flex: 2,
            child: SizedBox.shrink(),
          ),
        ],
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
          20,
          FontWeight.bold,
          1.5
        ),
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
            
            _cajasText('Email'),
            
            // 
            Container(
              margin: const EdgeInsets.only(left: 60, right: 60, top: 10),
              child: InputTextFieldWidget(
                context: context,
                labelText: 'Ingresa tu correo aqui',
                controller: _email,
                readOnly: false, 
                validador: (value) {
                  return null;
                },
              ),
            ),

            InkWell(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              
              onTap: () async {
                //el navigator me permite dirigirme a la ruta para realizar el ingreso a mi cuenta
                //pasando el atributo de myKupiApp
                // Navigator.push(context,MaterialPageRoute(builder: (context) => SignInKupi()));
              },

              child: Container(
                margin: const EdgeInsets.only(right: 65, left: 65, top: 45),
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