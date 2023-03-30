// ignore_for_file: file_names
import 'package:be_energy/utils/metodos.dart';
import 'package:flutter/material.dart';

import '../../../models/my_user.dart';

class MicuentaScreen extends StatefulWidget {
  final MyUser myUser;

  const MicuentaScreen({Key? key, required this.myUser}) : super(key: key);

  @override
  State<MicuentaScreen> createState() => _MicuentaScreenState();
}


class _MicuentaScreenState extends State<MicuentaScreen> {

  Metodos metodos = Metodos();

  Widget _body() {
    return const Placeholder();
  }

  IconButton _leading(BuildContext context, double width) {
    return IconButton(
      //icono de cerrar sesion
      icon: const Icon(
        Icons.access_alarm_sharp,
        size: 25,
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(Theme.of(context).primaryColor),
        iconColor: MaterialStatePropertyAll(Theme.of(context).scaffoldBackgroundColor),
      ),

      tooltip: "Cerrar Sesión",
      onPressed: () async {
        metodos.alertsDialog(context, "¿Deseas cerrar tu sesión ahora?", width, "Cancelar", 2, "Si", 3);
      }
    );
  }
  @override
  Widget build(BuildContext context) {
    return FondoScreen(
      myUser: widget.myUser,
      heightAppBar: 50,
      radiusAppBar: 90,
      leading: _leading(context, Metodos.width(context)),
      // actions: _actions(snapshotApp.data, snapshotUser.data),
      body: _body()
    );
  }
}