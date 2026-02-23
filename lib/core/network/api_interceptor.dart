// ignore_for_file: depend_on_referenced_packages, avoid_print

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../api/api_client.dart';
import '../api/api_exceptions.dart';
import '../constants/api_endpoints.dart';
import '../constants/microservice_config.dart';
import '../../repositories/auth_repository.dart';

/// Interceptor personalizado para manejar requests y responses del API
/// Agrega headers comunes, maneja errores 401 con renovación de token
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

    final uri = options.uri;
    print('⬆️ REQUEST[${options.method}] => ${uri.toString()}');
    print('⬆️ Headers: ${options.headers}');
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

    // Ante 401, intentar renovar token y repetir la petición
    if (err.response?.statusCode == 401) {
      _handle401(err, handler);
      return;
    }

    super.onError(err, handler);
  }

  Future<void> _handle401(DioException err, ErrorInterceptorHandler handler) async {
    final uri = err.requestOptions.uri.toString();
    // No intentar refresh si la petición fallida es la de refresh
    if (uri.contains('refresh') || uri.contains(ApiEndpoints.refreshToken)) {
      super.onError(err, handler);
      return;
    }

    final token = ApiClient.instance.getAuthToken();
    if (token == null || token.isEmpty) {
      super.onError(err, handler);
      return;
    }

    try {
      final resp = await AuthRepository().refreshAuthToken(refreshToken: token);
      if (!resp.success || ApiClient.instance.getAuthToken() == null) {
        super.onError(err, handler);
        return;
      }
      final newToken = ApiClient.instance.getAuthToken()!;
      err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
      final response = await ApiClient.instance.dio.fetch(err.requestOptions);
      handler.resolve(response);
    } on ApiException {
      super.onError(err, handler);
    } catch (_) {
      super.onError(err, handler);
    }
  }
}
