import 'package:be_energy/screens/main_screens/Login/register_screen.dart';
import 'package:flutter/material.dart';

import 'routes.dart';

void main() {
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
      initialRoute: 'home',
      routes: {
        'configuration':(context) => const ConfiguracionScreen(),
        'energy':(context) => const EnergyScreen(),
        'historial':(context) => const HistorialScreen(),
        'home':(context) => const HomeScreen(),
        'login':(context) => const LoginScreen(),
        'notificaciones':(context) => const NotificacionesScreen(),
        'register':(context) => const RegisterScreen(),
        'trading':(context) => const TradingScreen(),
      },
    );
  }
}