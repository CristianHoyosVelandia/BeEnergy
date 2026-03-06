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
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
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
  /// [document] - Documento de identidad del usuario
  /// [name] - Nombre del usuario
  /// [lastname] - Apellido del usuario
  /// [email] - Correo electrónico
  /// [password] - Contraseña
  /// [phone] - Número de teléfono (opcional)
  /// [role] - Rol del usuario (0=admin, 1=user, 2=moderator)
  ///
  /// Retorna un [ApiResponse] con los datos del usuario registrado
  Future<ApiResponse<Map<String, dynamic>>> register({
    required String document,
    required String name,
    required String lastname,
    required String email,
    required String password,
    String? phone,
    int role = 1,
  }) async {
    try {
      final data = {
        'document': document,
        'name': name,
        'lastname': lastname,
        'email': email,
        'password': password,
        'role': role,
      };

      // Agregar phone solo si no es null
      if (phone != null && phone.isNotEmpty) {
        data['phone'] = phone;
      }

      final response = await _apiClient.post(
        ApiEndpoints.register,
        data: data,
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
        (_) {},
      );
    } on ApiException catch (e) {
      print('Error en logout: ${e.message}');
      rethrow;
    }
  }

  /// Solicita recuperación de contraseña
  ///
  /// [document] - Documento de identidad del usuario
  ///
  /// Retorna un [ApiResponse] indicando el resultado
  Future<ApiResponse<Map<String, dynamic>>> forgotPassword({
    required String document,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.forgotPassword,
        data: {'document': document},
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
  /// [document] - Documento de identidad del usuario
  /// [otp] - Código OTP recibido por correo
  /// [newPassword] - Nueva contraseña
  ///
  /// Retorna un [ApiResponse] indicando el resultado
  Future<ApiResponse<Map<String, dynamic>>> resetPassword({
    required String document,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.resetPassword,
        data: {
          'document': document,
          'otp': otp,
          'new_password': newPassword,
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
