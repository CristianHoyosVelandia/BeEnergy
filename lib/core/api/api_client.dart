import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../network/api_interceptor.dart';
import 'api_exceptions.dart';

/// Cliente HTTP principal para realizar peticiones al API
/// Implementa el patrón Singleton para garantizar una única instancia
class ApiClient {
  static ApiClient? _instance;
  late Dio _dio;

  // Constructor privado para patrón Singleton
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['BASE_URL'] ?? '',
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

    // Agregar interceptor de logs en modo debug
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
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
  /// [endpoint] - Ruta del endpoint (sin incluir base URL)
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

  /// Realiza una petición POST
  ///
  /// [endpoint] - Ruta del endpoint (sin incluir base URL)
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

  /// Actualiza la base URL (útil para cambios dinámicos de ambiente)
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }
}
