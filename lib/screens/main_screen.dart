// ignore_for_file: avoid_print

import 'package:be_energy/core/api/api_client.dart';
import 'package:be_energy/data/database_Helper.dart';
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

  /// Al iniciar la app se limpia el último inicio de sesión para que siempre
  /// se pidan email y contraseña.
  @override
  void initState() {
    super.initState();
    myUser = Future(() async {
      final dbHelper = DatabaseHelper();
      await dbHelper.clearLoginUser();
      ApiClient.instance.removeAuthToken();
      return blockBeEnergy.getUserFromDB();
    });
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
              final idUser = snapshotUser.data.idUser;
              final isLoggedIn = idUser != null && idUser != 0;
              if (isLoggedIn) {
                return NavPages(myUser: snapshotUser.data);
              }
            }
            return const LoginScreen(); 
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