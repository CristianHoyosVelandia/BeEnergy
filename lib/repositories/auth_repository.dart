// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';

import '../core/api/api_client.dart';
import '../core/api/api_response.dart';
import '../core/api/api_exceptions.dart';
import '../core/constants/api_endpoints.dart';
import '../core/constants/microservice_config.dart';

/// Repositorio para manejar operaciones de autenticación
class AuthRepository {
  final ApiClient _apiClient = ApiClient.instance;

  /// Realiza el login del usuario
  ///
  /// [email] - Correo electrónico del usuario
  /// [password] - Contraseña del usuario
  ///
  /// Retorna un [ApiResponse] con los datos del usuario y token
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// final repository = AuthRepository();
  /// try {
  ///   final response = await repository.login(
  ///     email: 'user@example.com',
  ///     password: 'password123',
  ///   );
  ///   if (response.success) {
  ///     final token = response.data['token'];
  ///     // Guardar token y redirigir
  ///   }
  /// } on UnauthorizedException catch (e) {
  ///   print('Credenciales incorrectas: ${e.message}');
  /// } on ApiException catch (e) {
  ///   print('Error: ${e.message}');
  /// }
  /// ```
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.postFromService(
        Microservice.auth,
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final success = data['success'] == true;
      final responseData = data['data'];
      if (success && responseData != null) {
        final token = responseData['access_token'] ?? responseData['token'];
        if (token != null) {
          _apiClient.setAuthToken(token);
        }
      }

      return ApiResponse.fromJson(
        data,
        (d) => d as Map<String, dynamic>,
      );
    } on ApiException catch (e) {
      if (kDebugMode) debugPrint('Auth login: ${e.message}');
      rethrow;
    }
  }

  /// Verificar OTP 2FA tras login exitoso con credenciales
  Future<ApiResponse<Map<String, dynamic>>> verify2fa({
    required String tempSession,
    required String otp,
  }) async {
    try {
      final response = await _apiClient.postFromService(
        Microservice.auth,
        ApiEndpoints.verify2fa,
        data: {
          'temp_session': tempSession,
          'otp': otp,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final success = data['success'] == true;
      final responseData = data['data'];
      if (success && responseData != null) {
        final token = responseData['access_token'] ?? responseData['token'];
        if (token != null) {
          _apiClient.setAuthToken(token);
        }
      }

      return ApiResponse.fromJson(
        data,
        (d) => d as Map<String, dynamic>,
      );
    } on ApiException catch (e) {
      if (kDebugMode) debugPrint('Auth verify2fa: ${e.message}');
      rethrow;
    }
  }

  /// Registra un nuevo usuario
  ///
  /// [nombre] - Nombre completo del usuario
  /// [email] - Correo electrónico
  /// [password] - Contraseña
  /// [telefono] - Número de teléfono
  /// [idCiudad] - ID de la ciudad
  ///
  /// Retorna un [ApiResponse] con los datos del usuario registrado
  /// Registro con nombre, apellido, teléfono, correo, contraseña, tipo de perfil
  Future<ApiResponse<Map<String, dynamic>>> register({
    required String nombre,
    required String apellido,
    required String email,
    required String password,
    String? telefono,
    int? idCiudad,
    int role = 1, // 1=consumidor, 2=prosumidor
  }) async {
    try {
      final response = await _apiClient.postFromService(
        Microservice.auth,
        ApiEndpoints.register,
        data: {
          'name': nombre,
          'lastname': apellido,
          'email': email,
          'password': password,
          'phone': telefono ?? '',
          'role': role,
        },
      );

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as Map<String, dynamic>,
      );
    } on ApiException catch (e) {
      if (kDebugMode) debugPrint('Auth register: ${e.message}');
      rethrow;
    }
  }

  /// Cierra la sesión (client-side: remueve token)
  Future<ApiResponse<void>> logout() async {
    _apiClient.removeAuthToken();
    return ApiResponse.success(data: null, message: 'Sesión cerrada');
  }

  /// Verificar token
  Future<ApiResponse<Map<String, dynamic>>> verifyToken() async {
    try {
      final response = await _apiClient.getFromService(
        Microservice.auth,
        ApiEndpoints.verifyToken,
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (d) => d as Map<String, dynamic>,
      );
    } on ApiException catch (e) {
      if (kDebugMode) debugPrint('Auth verifyToken: ${e.message}');
      rethrow;
    }
  }

  /// Obtener ciudades (auth_service)
  Future<ApiResponse<List<dynamic>>> getCities() async {
    try {
      final response = await _apiClient.getFromService(
        Microservice.auth,
        ApiEndpoints.cities,
      );
      final body = response.data as Map<String, dynamic>;
      final list = body['data'];
      if (list is List) {
        return ApiResponse.success(
          data: list,
          message: body['message'] ?? 'Ciudades obtenidas',
        );
      }
      return ApiResponse.success(data: <dynamic>[], message: 'Sin ciudades');
    } on ApiException catch (e) {
      if (kDebugMode) debugPrint('Auth cities: ${e.message}');
      rethrow;
    }
  }

  /// Solicita recuperación de contraseña
  ///
  /// [email] - Correo electrónico del usuario
  ///
  /// Retorna un [ApiResponse] indicando el resultado
  /// Recuperación de contraseña por correo
  Future<ApiResponse<Map<String, dynamic>>> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await _apiClient.postFromService(
        Microservice.auth,
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as Map<String, dynamic>,
      );
    } on ApiException catch (e) {
      if (kDebugMode) debugPrint('Auth forgotPassword: ${e.message}');
      rethrow;
    }
  }

  /// Resetea la contraseña del usuario con OTP
  Future<ApiResponse<Map<String, dynamic>>> resetPassword({
    required String otp,
    required String newPassword,
    String? email,
    String? document,
  }) async {
    try {
      final response = await _apiClient.postFromService(
        Microservice.auth,
        ApiEndpoints.resetPassword,
        data: {
          'otp': otp,
          'new_password': newPassword,
          if (email != null && email.isNotEmpty) 'email': email,
          if (document != null && document.isNotEmpty) 'document': document,
        },
      );

      final body = response.data;
      if (body is! Map<String, dynamic>) {
        return ApiResponse.success(
          data: <String, dynamic>{},
          message: body?.toString() ?? 'Contraseña actualizada',
        );
      }
      final success = body['success'] == true || body['status'] == true;
      final message = body['message'] ?? body['msg'];
      final data = body['data'];
      return ApiResponse<Map<String, dynamic>>(
        success: success,
        message: message is String ? message : null,
        data: data is Map<String, dynamic> ? data : <String, dynamic>{},
      );
    } on ApiException catch (e) {
      if (kDebugMode) debugPrint('Auth resetPassword: ${e.message}');
      rethrow;
    }
  }

  /// Refresca el token de autenticación
  ///
  /// [refreshToken] - Token de refresh
  ///
  /// Retorna un [ApiResponse] con el nuevo token
  Future<ApiResponse<Map<String, dynamic>>> refreshAuthToken({
    required String refreshToken,
  }) async {
    try {
      final response = await _apiClient.postFromService(
        Microservice.auth,
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      final data = response.data as Map<String, dynamic>;
      final respData = data['data'];
      if (respData != null && (respData['access_token'] ?? respData['token']) != null) {
        _apiClient.setAuthToken(respData['access_token'] ?? respData['token']);
      }

      return ApiResponse.fromJson(
        data,
        (d) => d as Map<String, dynamic>,
      );
    } on ApiException catch (e) {
      if (kDebugMode) debugPrint('Auth refreshToken: ${e.message}');
      rethrow;
    }
  }
}
