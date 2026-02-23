import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Identificadores de los microservicios del ecosistema BeEnergy
enum Microservice {
  /// Servicio de autenticación (login, registro, recuperar clave)
  auth,

  /// Servicio de usuarios (perfil, actualización, cambio de rol)
  user,

  /// Servicio de créditos energéticos (saldo kWh)
  credits,

  /// Servicio de energía (datos, historial, estadísticas)
  energy,

  /// Servicio de transacciones (ofertas, contratos P2P)
  trading,

  /// Servicio de notificaciones
  notifications,

  /// Servicio de monitoreo (telemetría, alertas)
  monitoring,

  /// Servicio de auditoría
  audit,

  /// Servicio de pagos
  payment,

  /// Servicio de empresas (Kupi/legacy)
  empresas,

  /// API Gateway - usa una sola URL para todos los servicios
  gateway,
}

/// Configuración centralizada de URLs de microservicios
///
/// Soporta dos modos de operación:
/// 1. **API Gateway**: Una sola BASE_URL o GATEWAY_URL para todo
/// 2. **Microservicios directos**: URLs independientes por servicio
///
/// Ejemplo .env con Gateway:
/// ```env
/// GATEWAY_URL=https://api.beenergy.com
/// ```
///
/// Ejemplo .env con microservicios:
/// ```env
/// AUTH_SERVICE_URL=https://auth.beenergy.com
/// ENERGY_SERVICE_URL=https://energy.beenergy.com
/// TRADING_SERVICE_URL=https://trading.beenergy.com
/// ```
class MicroserviceConfig {
  MicroserviceConfig._();

  static const _auth = 'AUTH_SERVICE_URL';
  static const _user = 'USER_SERVICE_URL';
  static const _credits = 'CREDITS_SERVICE_URL';
  static const _energy = 'ENERGY_SERVICE_URL';
  static const _trading = 'TRADING_SERVICE_URL';
  static const _notifications = 'NOTIFICATIONS_SERVICE_URL';
  static const _monitoring = 'MONITORING_SERVICE_URL';
  static const _audit = 'AUDIT_SERVICE_URL';
  static const _payment = 'PAYMENT_SERVICE_URL';
  static const _empresas = 'EMPRESAS_SERVICE_URL';
  static const _gateway = 'GATEWAY_URL';

  /// URLs por defecto cuando .env no carga (desarrollo local)
  static const String _localhost = 'http://localhost';

  /// URL por defecto cuando no hay configuración (legacy BASE_URL)
  static String get _defaultBase {
    final v = dotenv.env['BASE_URL'] ?? dotenv.env['GATEWAY_URL'] ?? '';
    return v.isNotEmpty ? v : '$_localhost:8000';
  }

  /// Obtiene la base URL para un microservicio
  ///
  /// Prioridad:
  /// 1. Si existe GATEWAY_URL → se usa para todos los servicios
  /// 2. Si existe URL específica del servicio → se usa esa
  /// 3. Fallback a BASE_URL
  static String getBaseUrl(Microservice service) {
    // Si hay Gateway, usarlo para todo (excepto empresas que puede ser externo)
    final gatewayUrl = dotenv.env[_gateway];
    if (gatewayUrl != null && gatewayUrl.isNotEmpty) {
      // Empresas puede tener su propia URL (ej: Kupi)
      if (service == Microservice.empresas) {
        final empresasUrl = dotenv.env[_empresas];
        if (empresasUrl != null && empresasUrl.isNotEmpty) {
          return _ensureNoTrailingSlash(empresasUrl);
        }
      }
      return _ensureNoTrailingSlash(gatewayUrl);
    }

    // Sin Gateway: usar URL específica de cada servicio (con fallbacks localhost)
    final _authUrl = dotenv.env[_auth];
    final _userUrl = dotenv.env[_user];
    switch (service) {
      case Microservice.auth:
        return _ensureNoTrailingSlash(
          (_authUrl != null && _authUrl.isNotEmpty) ? _authUrl : '$_localhost:8000',
        );
      case Microservice.user:
        return _ensureNoTrailingSlash(
          (_userUrl != null && _userUrl.isNotEmpty) ? _userUrl
              : (_authUrl != null && _authUrl.isNotEmpty) ? _authUrl
              : '$_localhost:8001',
        );
      case Microservice.credits:
        return _ensureNoTrailingSlash(
          (dotenv.env[_credits] ?? '').isNotEmpty ? dotenv.env[_credits]! : '$_localhost:8002',
        );
      case Microservice.energy:
        return _ensureNoTrailingSlash(
          (dotenv.env[_energy] ?? '').isNotEmpty ? dotenv.env[_energy]! : '$_localhost:8002',
        );
      case Microservice.trading:
        return _ensureNoTrailingSlash(
          (dotenv.env[_trading] ?? '').isNotEmpty ? dotenv.env[_trading]! : '$_localhost:8003',
        );
      case Microservice.notifications:
        return _ensureNoTrailingSlash(
          (dotenv.env[_notifications] ?? '').isNotEmpty ? dotenv.env[_notifications]! : _defaultBase,
        );
      case Microservice.monitoring:
        return _ensureNoTrailingSlash(
          (dotenv.env[_monitoring] ?? '').isNotEmpty ? dotenv.env[_monitoring]! : '$_localhost:8004',
        );
      case Microservice.audit:
        return _ensureNoTrailingSlash(
          (dotenv.env[_audit] ?? '').isNotEmpty ? dotenv.env[_audit]! : '$_localhost:8005',
        );
      case Microservice.payment:
        return _ensureNoTrailingSlash(
          (dotenv.env[_payment] ?? '').isNotEmpty ? dotenv.env[_payment]! : _defaultBase,
        );
      case Microservice.empresas:
        return _ensureNoTrailingSlash(
          dotenv.env[_empresas] ?? 'https://kupi.com.co/ws',
        );
      case Microservice.gateway:
        return _ensureNoTrailingSlash(gatewayUrl ?? _defaultBase);
    }
  }

  /// Construye la URL completa para un endpoint de un servicio
  static String buildUrl(Microservice service, String path) {
    final base = getBaseUrl(service);
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return '$base$normalizedPath';
  }

  static String _ensureNoTrailingSlash(String url) {
    if (url.endsWith('/')) {
      return url.substring(0, url.length - 1);
    }
    return url;
  }
}
