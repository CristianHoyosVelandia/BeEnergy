/// Configuración de fuente de datos
/// Permite cambiar entre fake data y API mediante variable de entorno o .env
library;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:be_energy/repositories/domain/energy_stats_repository.dart';
import 'package:be_energy/repositories/domain/transaction_repository.dart';
import 'package:be_energy/repositories/domain/community_repository.dart';
import 'package:be_energy/repositories/domain/auth_repository.dart';
import 'package:be_energy/repositories/impl/energy_stats_repository_fake.dart';
import 'package:be_energy/repositories/impl/energy_stats_repository_api.dart';
import 'package:be_energy/repositories/impl/transaction_repository_fake.dart';
import 'package:be_energy/repositories/impl/transaction_repository_api.dart';
import 'package:be_energy/repositories/impl/community_repository_fake.dart';
import 'package:be_energy/repositories/impl/community_repository_api.dart';
import 'package:be_energy/repositories/impl/auth_repository_fake.dart';
import 'package:be_energy/repositories/impl/auth_repository_api.dart';

/// Tipo de fuente de datos
enum DataSourceType {
  /// Datos fake locales (para desarrollo y testing)
  fake,
  /// API REST (para producción)
  api,
}

/// Configuración global de fuente de datos
class DataSourceConfig {
  /// Tipo de fuente de datos activa
  static DataSourceType _currentSource = DataSourceType.fake;
  /// URL base del API (leído desde .env)
  static String _apiBaseUrl = '';
  /// Obtiene el tipo de fuente de datos actual
  static DataSourceType get currentSource => _currentSource;
  /// Establece el tipo de fuente de datos
  static void setDataSource(DataSourceType source) {
    _currentSource = source;
  }

  /// Establece la URL base del API
  static void setApiBaseUrl(String url) {
    _apiBaseUrl = url;
  }

  /// Obtiene la URL base del API
  static String get apiBaseUrl => _apiBaseUrl;

  /// Inicializa la configuración desde .env
  ///
  /// Lee ENABLE_MOCKS desde .env para determinar si usar fake data o API real
  /// Lee BASE_URL desde .env para configurar el endpoint del API
  /// Por defecto usa fake data si no se especifica ENABLE_MOCKS
  static Future<void> initFromEnvironment() async {
    try {
      // Cargar .env si no está cargado
      if (!dotenv.isInitialized) {
        await dotenv.load(fileName: '.env');
      }

      // Leer BASE_URL desde .env
      _apiBaseUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:8000';

      // Leer ENABLE_MOCKS desde .env (runtime)
      final enableMocks = dotenv.env['ENABLE_MOCKS']?.toLowerCase() ?? 'true';

      // Determinar fuente de datos según ENABLE_MOCKS
      if (enableMocks == 'true') {
        _currentSource = DataSourceType.fake;
      } else {
        _currentSource = DataSourceType.api;
      }

      // Log para debugging
      print('🎭 [DataSourceConfig] ENABLE_MOCKS=$enableMocks');
      print('🔧 [DataSourceConfig] Using: $_currentSource');
      print('🌐 [DataSourceConfig] API Base URL: $_apiBaseUrl');
    } catch (e) {
      print('⚠️ [DataSourceConfig] Error loading .env: $e');
      print('📌 [DataSourceConfig] Using default configuration (fake data)');
      _currentSource = DataSourceType.fake;
      _apiBaseUrl = 'http://10.0.2.2:8000';
    }
  }

  /// Verifica si está usando datos fake
  static bool get isFake => _currentSource == DataSourceType.fake;

  /// Verifica si está usando API
  static bool get isApi => _currentSource == DataSourceType.api;
}

/// Factory para crear repositorios según la configuración
class RepositoryFactory {
  /// Crea una instancia del repositorio de estadísticas de energía
  static EnergyStatsRepository createEnergyStatsRepository() {
    switch (DataSourceConfig.currentSource) {
      case DataSourceType.fake:
        return EnergyStatsRepositoryFake();

      case DataSourceType.api:
        return EnergyStatsRepositoryApi();
    }
  }

  /// Crea una instancia del repositorio de transacciones
  static TransactionRepository createTransactionRepository() {
    switch (DataSourceConfig.currentSource) {
      case DataSourceType.fake:
        return TransactionRepositoryFake();

      case DataSourceType.api:
        return TransactionRepositoryApi();
    }
  }

  /// Crea una instancia del repositorio de comunidad
  static CommunityRepository createCommunityRepository() {
    switch (DataSourceConfig.currentSource) {
      case DataSourceType.fake:
        return CommunityRepositoryFake();

      case DataSourceType.api:
        return CommunityRepositoryApi();
    }
  }

  /// Crea una instancia del repositorio de autenticación
  static AuthRepository createAuthRepository() {
    switch (DataSourceConfig.currentSource) {
      case DataSourceType.fake:
        return AuthRepositoryFake();

      case DataSourceType.api:
        return AuthRepositoryApi();
    }
  }
}
