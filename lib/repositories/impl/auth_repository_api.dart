/// Implementación API del repositorio de autenticación
/// Consume endpoints reales del backend
library;

import 'package:be_energy/core/api/api_client.dart';
import 'package:be_energy/core/constants/api_endpoints.dart';
import 'package:be_energy/models/auth_models.dart';
import 'package:be_energy/repositories/domain/auth_repository.dart';

/// Implementación con API real para autenticación
class AuthRepositoryApi implements AuthRepository {
  final ApiClient _client = ApiClient.instance;
  AuthUser? _currentUser;

  @override
  Future<AuthResult> login(LoginCredentials credentials) async {
    try {
      final response = await _client.post(
        ApiEndpoints.login,
        data: credentials.toJson(),
      );

      final user = AuthUser.fromJson(response.data as Map<String, dynamic>);
      _currentUser = user;

      // Guardar token en el API client
      _client.setAuthToken(user.token);

      return AuthResult.success(
        user: user,
        message: 'Inicio de sesión exitoso',
      );
    } catch (e) {
      return AuthResult.failure(
        error: e.toString(),
        message: 'Error al iniciar sesión',
      );
    }
  }

  @override
  Future<AuthResult> register(RegisterData data) async {
    try {
      final response = await _client.post(
        ApiEndpoints.signUp,
        data: data.toJson(),
      );

      final user = AuthUser.fromJson(response.data as Map<String, dynamic>);
      _currentUser = user;

      // Guardar token en el API client
      _client.setAuthToken(user.token);

      return AuthResult.success(
        user: user,
        message: 'Registro exitoso',
      );
    } catch (e) {
      return AuthResult.failure(
        error: e.toString(),
        message: 'Error al registrar usuario',
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _client.post(ApiEndpoints.logout);
    } catch (e) {
      // Continuar con logout local incluso si el server falla
    } finally {
      _currentUser = null;
      _client.removeAuthToken();
    }
  }

  @override
  Future<RecoveryResult> requestPasswordRecovery(
    PasswordRecoveryRequest request,
  ) async {
    try {
      await _client.post(
        ApiEndpoints.forgotPassword,
        data: request.toJson(),
      );

      return RecoveryResult.success(
        message: 'Correo de recuperación enviado',
      );
    } catch (e) {
      return RecoveryResult.failure(
        error: e.toString(),
        message: 'Error al enviar correo de recuperación',
      );
    }
  }

  @override
  Future<RecoveryResult> resetPassword(PasswordResetRequest request) async {
    try {
      await _client.post(
        ApiEndpoints.resetPassword,
        data: request.toJson(),
      );

      return RecoveryResult.success(
        message: 'Contraseña restablecida exitosamente',
      );
    } catch (e) {
      return RecoveryResult.failure(
        error: e.toString(),
        message: 'Error al restablecer contraseña',
      );
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    if (_currentUser == null) return false;
    if (!_currentUser!.isTokenValid) return false;

    // Validar token con el servidor
    return await validateToken(_currentUser!.token);
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<AuthResult> refreshToken() async {
    try {
      final response = await _client.post(
        ApiEndpoints.verifyToken,
        data: {
          'token': _currentUser?.token,
        },
      );

      final user = AuthUser.fromJson(response.data as Map<String, dynamic>);
      _currentUser = user;

      // Actualizar token en el API client
      _client.setAuthToken(user.token);

      return AuthResult.success(
        user: user,
        message: 'Token actualizado',
      );
    } catch (e) {
      return AuthResult.failure(
        error: e.toString(),
        message: 'Error al actualizar token',
      );
    }
  }

  @override
  Future<bool> validateToken(String token) async {
    try {
      final response = await _client.post(
        ApiEndpoints.verifyToken,
        data: {'token': token},
      );

      return response.data['valid'] as bool;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<RecoveryResult> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _client.post(
        ApiEndpoints.changePassword,
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
        },
      );

      return RecoveryResult.success(
        message: 'Contraseña cambiada exitosamente',
      );
    } catch (e) {
      return RecoveryResult.failure(
        error: e.toString(),
        message: 'Error al cambiar contraseña',
      );
    }
  }
}
