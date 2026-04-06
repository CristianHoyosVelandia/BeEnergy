import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'routes.dart';
import 'core/theme/app_theme.dart';
import 'core/config/data_source_config.dart';

void main() async {
  // Inicialización de Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar locale español para formateo de fechas y números
  await initializeDateFormatting('es_ES', null);

  // Cargar variables de entorno
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // Si no existe el .env, continuar sin él
    debugPrint('⚠️ No se pudo cargar .env: $e');
  }

  // Inicializar configuración de data source (mocks vs API)
  await DataSourceConfig.initFromEnvironment();

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

        // Community Routes (nuevas pantallas):
        'communityManagement' : (context) => const CommunityManagementScreen(),
        'energyRecords'       : (context) => const EnergyRecordsScreen(),
        'pdeAllocation'       : (context) => const PDEAllocationScreen(),
        'p2pMarket'           : (context) => const P2PMarketScreen(),
        'energyCredits'       : (context) => const EnergyCreditsScreen(),
        'monthlyBilling'      : (context) => const MonthlyBillingScreen(),
        'reports'             : (context) => const ReportsScreen(),
      },
    );
  }
}