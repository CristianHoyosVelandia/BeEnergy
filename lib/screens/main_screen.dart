// ignore_for_file: avoid_print

import 'package:be_energy/models/callmodels.dart';
import 'package:be_energy/screens/bloc/bloc_main.dart';
import 'package:flutter/material.dart';

import '../routes.dart';
import '../widgets/general_widgets.dart';

class Beenergy extends StatefulWidget {
  const Beenergy({super.key});

  @override
  State<Beenergy> createState() => _BeenergyState();
}

class _BeenergyState extends State<Beenergy> {

  //Objetos de clases
  late  Future<MyUser> myUser;
  BlocBeenergy blockBeEnergy = BlocBeenergy();
  
  //se inicializa el estado y junto a el los futuros, 
  //el futuro de usuario me trae los datos de ser el caso, de un usuario que ya se encuentre logueado dentro de la app
  @override
  void initState() {
    super.initState();
    myUser = blockBeEnergy.getUserFromDB();
    // _checkVersion();
  }
  @override
  void dispose(){
    super.dispose();
  }


  //futuro de la clase con el fin de conocer si existe un usuario logueado en la base de datos.
  Widget futureUser(){
    return FutureBuilder<MyUser>(
      future: myUser,
      // ignore: missing_return
      builder: (context, AsyncSnapshot snapshotUser) {
        switch (snapshotUser.connectionState) {
          case ConnectionState.none:
            return const MyProgressIndicator();
          case ConnectionState.waiting:
            return const MyProgressIndicator();
          case ConnectionState.active:
            return const MyProgressIndicator();
          case ConnectionState.done:
            //una vez se consumen ambos futuros, se procede a preguntar si hay un usuario logueado, 
            //de ser el caso cargamos los datos en el menu de codigo de usuario, codigo ciudad y nomCiudad y redirigimos.
            if (snapshotUser.hasData) {

              print("data Snapshot: ${snapshotUser.data.toMap()}");

              if (snapshotUser.data.idUser != 0) {
                
                print('Usuario ya logueado exitosamente');
                print(snapshotUser.data);
                return NavPages( myUser: snapshotUser.data);
                
              } else {
                //de no encontrar un usuario logueado, procedemos a cargar pintar la pantall.
                return const LoginScreen();
              }
            }

            else {
              return const LoginScreen();
            } 
        }
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    /*siempre el metodo de build debe tener un return, en el consumo el futuro de la app,
    posteriormente el del usuario y tomamos decisiones.*/
    return futureUser();
  }
}