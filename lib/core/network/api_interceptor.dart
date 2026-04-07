import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../utils/logger.dart';

/// Interceptor personalizado para manejar requests y responses del API
/// Agrega headers comunes y maneja errores de forma centralizada
class ApiInterceptor extends Interceptor {
  static const String _tag = 'API';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Agregar headers personalizados de la aplicación
    options.headers['codApp'] = dotenv.env['APP_CODE'] ?? '0';
    options.headers['codVersion'] = dotenv.env['APP_VERSION'] ?? '1.0.0';

    // Si necesitas agregar código de ciudad por defecto
    if (!options.headers.containsKey('codCiudad')) {
      options.headers['codCiudad'] = dotenv.env['DEFAULT_CITY_CODE'] ?? '4110';
    }

    AppLogger.debug('REQUEST[${options.method}] => PATH: ${options.path}', tag: _tag);
    if (options.data != null) {
      AppLogger.debug('Data: ${options.data}', tag: _tag);
    }
    if (options.queryParameters.isNotEmpty) {
      AppLogger.debug('Query Parameters: ${options.queryParameters}', tag: _tag);
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.debug('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}', tag: _tag);
    AppLogger.debug('Data: ${response.data}', tag: _tag);

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error(
      'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
      tag: _tag,
      error: err.message,
    );
    if (err.response != null) {
      AppLogger.error('Response: ${err.response?.data}', tag: _tag);
    }

    // Aquí puedes manejar errores específicos como:
    // - 401: Token expirado -> Refrescar token o redirigir a login
    // - 403: Sin permisos
    // - 500: Error del servidor

    if (err.response?.statusCode == 401) {
      // Manejar token expirado
      AppLogger.warning('Token expirado o no autorizado', tag: _tag);
      // TODO: Implementar lógica de refresh token o redirigir a login
    }

    super.onError(err, handler);
  }
}
