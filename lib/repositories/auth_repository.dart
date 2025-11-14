// ignore_for_file: avoid_print

import '../core/api/api_client.dart';
import '../core/api/api_response.dart';
import '../core/api/api_exceptions.dart';
import '../core/constants/api_endpoints.dart';

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
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: {
          'correo': email,
          'clave': password,
        },
      );

      // Si el login es exitoso, guardar el token
      if (response.data['status'] == true && response.data['token'] != null) {
        _apiClient.setAuthToken(response.data['token']);
      }

      return ApiResponse.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );
    } on ApiException catch (e) {
      print('Error en login: ${e.message}');
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
  Future<ApiResponse<Map<String, dynamic>>> register({
    required String nombre,
    required String email,
    required String password,
    required String telefono,
    required int idCiudad,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.register,
        data: {
          'nombre': nombre,
          'correo': email,
          'clave': password,
          'telefono': telefono,
          'idCiudad': idCiudad,
        },
      );

      return ApiResponse.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );
    } on ApiException catch (e) {
      print('Error en registro: ${e.message}');
      rethrow;
    }
  }

  /// Cierra la sesión del usuario
  ///
  /// Retorna un [ApiResponse] indicando el resultado
  Future<ApiResponse<void>> logout() async {
    try {
      final response = await _apiClient.post(ApiEndpoints.logout);

      // Remover el token de autenticación
      _apiClient.removeAuthToken();

      return ApiResponse.fromJson(
        response.data,
        (_) => null,
      );
    } on ApiException catch (e) {
      print('Error en logout: ${e.message}');
      rethrow;
    }
  }

  /// Solicita recuperación de contraseña
  ///
  /// [email] - Correo electrónico del usuario
  ///
  /// Retorna un [ApiResponse] indicando el resultado
  Future<ApiResponse<Map<String, dynamic>>> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.forgotPassword,
        data: {'correo': email},
      );

      return ApiResponse.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );
    } on ApiException catch (e) {
      print('Error en recuperación de contraseña: ${e.message}');
      rethrow;
    }
  }

  /// Resetea la contraseña del usuario
  ///
  /// [token] - Token de reseteo recibido por correo
  /// [newPassword] - Nueva contraseña
  ///
  /// Retorna un [ApiResponse] indicando el resultado
  Future<ApiResponse<Map<String, dynamic>>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.resetPassword,
        data: {
          'token': token,
          'nuevaClave': newPassword,
        },
      );

      return ApiResponse.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );
    } on ApiException catch (e) {
      print('Error al resetear contraseña: ${e.message}');
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
      final response = await _apiClient.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      // Actualizar el token si es exitoso
      if (response.data['status'] == true && response.data['token'] != null) {
        _apiClient.setAuthToken(response.data['token']);
      }

      return ApiResponse.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );
    } on ApiException catch (e) {
      print('Error al refrescar token: ${e.message}');
      rethrow;
    }
  }
}
