// ignore_for_file: depend_on_referenced_packages, avoid_print

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Interceptor personalizado para manejar requests y responses del API
/// Agrega headers comunes y maneja errores de forma centralizada
class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Agregar headers personalizados de la aplicación
    options.headers['codApp'] = dotenv.env['APP_CODE'] ?? '0';
    options.headers['codVersion'] = dotenv.env['APP_VERSION'] ?? '1.0.0';

    // Si necesitas agregar código de ciudad por defecto
    if (!options.headers.containsKey('codCiudad')) {
      options.headers['codCiudad'] = dotenv.env['DEFAULT_CITY_CODE'] ?? '4110';
    }

    print('⬆️ REQUEST[${options.method}] => PATH: ${options.path}');
    // print('⬆️ Headers: ${options.headers}');
    if (options.data != null) {
      print('⬆️ Data: ${options.data}');
    }
    if (options.queryParameters.isNotEmpty) {
      print('⬆️ Query Parameters: ${options.queryParameters}');
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('⬇️ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    print('⬇️ Data: ${response.data}');

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('❌ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    print('❌ Message: ${err.message}');
    if (err.response != null) {
      print('❌ Response: ${err.response?.data}');
    }

    // Aquí puedes manejar errores específicos como:
    // - 401: Token expirado -> Refrescar token o redirigir a login
    // - 403: Sin permisos
    // - 500: Error del servidor

    if (err.response?.statusCode == 401) {
      // Manejar token expirado
      print('🔐 Token expirado o no autorizado');
      // TODO: Implementar lógica de refresh token o redirigir a login
    }

    super.onError(err, handler);
  }
}
