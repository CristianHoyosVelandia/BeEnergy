import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'routes.dart';
import 'core/theme/app_theme.dart';

void main() async {
  // Inicialización de Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno (raíz del proyecto o desde assets)
  bool envLoaded = false;
  try {
    await dotenv.load(fileName: ".env");
    envLoaded = true;
  } catch (_) {}
  if (!envLoaded) {
    try {
      await dotenv.load(fileName: "assets/.env");
      envLoaded = true;
    } catch (_) {}
  }
  if (!envLoaded) {
    debugPrint('⚠️ No se encontró .env. Copia .env.example a .env y configura las URLs de los microservicios.');
    debugPrint('   En emulador Android usa 10.0.2.2 en lugar de localhost.');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Be Energy',

      // Nuevo tema usando AppTheme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Respeta la preferencia del sistema

      // Rutas
      initialRoute: 'beEnergy',
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
        'resetPassword'   : (context) => const ResetPasswordScreen(),
      },
    );
  }
}