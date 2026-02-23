// ignore_for_file: depend_on_referenced_packages

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../constants/microservice_config.dart';
import '../network/api_interceptor.dart';
import 'api_exceptions.dart';

/// Cliente HTTP principal para realizar peticiones al API
/// Implementa el patrón Singleton para garantizar una única instancia
class ApiClient {
  static ApiClient? _instance;
  late Dio _dio;

  // Constructor privado para patrón Singleton
  ApiClient._internal() {
    final baseUrl = dotenv.env['BASE_URL']?.trim().isNotEmpty == true
        ? dotenv.env['BASE_URL']!
        : MicroserviceConfig.getBaseUrl(Microservice.auth);
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Agregar interceptor personalizado
    _dio.interceptors.add(ApiInterceptor());

    // Logs desactivados para reducir ruido; usar ApiInterceptor en debug
  }

  /// Obtiene la instancia única del ApiClient
  static ApiClient get instance {
    _instance ??= ApiClient._internal();
    return _instance!;
  }

  /// Obtiene la instancia de Dio para casos especiales
  Dio get dio => _dio;

  /// Realiza una petición GET
  ///
  /// [endpoint] - Ruta del endpoint o URL completa (si empieza con http)
  /// [queryParameters] - Parámetros de consulta opcionales
  /// [headers] - Headers adicionales opcionales
  ///
  /// Retorna un Future con la respuesta o lanza ApiException en caso de error
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return response;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Realiza una petición GET a un microservicio específico
  ///
  /// [service] - El microservicio destino (auth, energy, trading, etc.)
  /// [endpoint] - Ruta del endpoint (ej: /auth/login)
  /// [queryParameters] - Parámetros de consulta opcionales
  /// [headers] - Headers adicionales opcionales
  Future<Response> getFromService(
    Microservice service,
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    final url = MicroserviceConfig.buildUrl(service, endpoint);
    return get(url, queryParameters: queryParameters, headers: headers);
  }

  /// Realiza una petición POST a un microservicio específico
  Future<Response> postFromService(
    Microservice service,
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    final url = MicroserviceConfig.buildUrl(service, endpoint);
    return post(url, data: data, queryParameters: queryParameters, headers: headers);
  }

  /// Realiza una petición PUT a un microservicio específico
  Future<Response> putFromService(
    Microservice service,
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    final url = MicroserviceConfig.buildUrl(service, endpoint);
    return put(url, data: data, queryParameters: queryParameters, headers: headers);
  }

  /// Realiza una petición PATCH a un microservicio específico
  Future<Response> patchFromService(
    Microservice service,
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    final url = MicroserviceConfig.buildUrl(service, endpoint);
    return patch(url, data: data, queryParameters: queryParameters, headers: headers);
  }

  /// Realiza una petición DELETE a un microservicio específico
  Future<Response> deleteFromService(
    Microservice service,
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    final url = MicroserviceConfig.buildUrl(service, endpoint);
    return delete(url, data: data, queryParameters: queryParameters, headers: headers);
  }

  /// Realiza una petición POST
  ///
  /// [endpoint] - Ruta del endpoint o URL completa (si empieza con http)
  /// [data] - Datos a enviar en el body
  /// [queryParameters] - Parámetros de consulta opcionales
  /// [headers] - Headers adicionales opcionales
  ///
  /// Retorna un Future con la respuesta o lanza ApiException en caso de error
  Future<Response> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return response;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Realiza una petición PUT
  ///
  /// [endpoint] - Ruta del endpoint (sin incluir base URL)
  /// [data] - Datos a enviar en el body
  /// [queryParameters] - Parámetros de consulta opcionales
  /// [headers] - Headers adicionales opcionales
  ///
  /// Retorna un Future con la respuesta o lanza ApiException en caso de error
  Future<Response> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return response;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Realiza una petición PATCH
  ///
  /// [endpoint] - Ruta del endpoint (sin incluir base URL)
  /// [data] - Datos a enviar en el body
  /// [queryParameters] - Parámetros de consulta opcionales
  /// [headers] - Headers adicionales opcionales
  ///
  /// Retorna un Future con la respuesta o lanza ApiException en caso de error
  Future<Response> patch(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return response;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Realiza una petición DELETE
  ///
  /// [endpoint] - Ruta del endpoint (sin incluir base URL)
  /// [data] - Datos opcionales a enviar en el body
  /// [queryParameters] - Parámetros de consulta opcionales
  /// [headers] - Headers adicionales opcionales
  ///
  /// Retorna un Future con la respuesta o lanza ApiException en caso de error
  Future<Response> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return response;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Actualiza el token de autenticación en los headers por defecto
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Elimina el token de autenticación de los headers
  void removeAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// Obtiene el token actual (Bearer sin el prefijo) o null si no hay
  String? getAuthToken() {
    final auth = _dio.options.headers['Authorization'];
    if (auth is String && auth.startsWith('Bearer ')) {
      return auth.substring(7);
    }
    return null;
  }

  /// Actualiza la base URL (útil para cambios dinámicos de ambiente)
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }
}
