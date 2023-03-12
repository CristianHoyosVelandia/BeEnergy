import 'package:flutter/material.dart';
import 'routes.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Be Energy',
      // home: HomeScreen(),
      initialRoute: 'beEnergy',
      theme: MyThemes.maintheme,
      routes: {
        // Main Route:
        'beEnergy'        : (context) => const Beenergy(),
        //others routes
        'configuration'   : (context) => const ConfiguracionScreen(),
        'energy'          : (context) => const EnergyScreen(),
        'historial'       : (context) => const HistorialScreen(),
        'home'            : (context) => const HomeScreen(),
        'login'           : (context) => const LoginScreen(),
        'notificaciones'  : (context) => const NotificacionesScreen(),
        'register'        : (context) => const RegisterScreen(),
        'trading'         : (context) => const TradingScreen(),
        'RecuerdoMiClave' : (context) => const NoRecuerdomiclaveScreen(),

      },
    );
  }
}