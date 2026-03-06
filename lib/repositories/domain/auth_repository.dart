/// Repositorio para autenticación y gestión de usuarios
/// Login, registro, recuperación de contraseña, logout
library;

import 'package:be_energy/models/auth_models.dart';

/// Interfaz abstracta para el repositorio de autenticación
abstract class AuthRepository {
  /// Inicia sesión con email y contraseña
  ///
  /// [credentials] - Credenciales de login (email y password)
  /// Retorna [AuthResult] con el usuario autenticado o error
  Future<AuthResult> login(LoginCredentials credentials);

  /// Registra un nuevo usuario
  ///
  /// [data] - Datos del usuario a registrar
  /// Retorna [AuthResult] con el usuario creado o error
  Future<AuthResult> register(RegisterData data);

  /// Cierra la sesión del usuario actual
  ///
  /// Limpia el token y datos de sesión
  Future<void> logout();

  /// Solicita recuperación de contraseña
  ///
  /// Envía un correo con el token de recuperación
  /// [request] - Email del usuario
  /// Retorna [RecoveryResult] indicando éxito o error
  Future<RecoveryResult> requestPasswordRecovery(PasswordRecoveryRequest request);

  /// Resetea la contraseña usando el token de recuperación
  ///
  /// [request] - Token y nueva contraseña
  /// Retorna [RecoveryResult] indicando éxito o error
  Future<RecoveryResult> resetPassword(PasswordResetRequest request);

  /// Verifica si hay un usuario autenticado
  ///
  /// Retorna true si hay una sesión activa
  Future<bool> isAuthenticated();

  /// Obtiene el usuario actual de la sesión
  ///
  /// Retorna el [AuthUser] si hay sesión activa, null si no
  Future<AuthUser?> getCurrentUser();

  /// Refresca el token de autenticación
  ///
  /// Retorna un nuevo [AuthUser] con token actualizado
  Future<AuthResult> refreshToken();

  /// Valida si un token es válido
  ///
  /// [token] - Token a validar
  /// Retorna true si el token es válido
  Future<bool> validateToken(String token);

  /// Cambia la contraseña del usuario actual
  ///
  /// [oldPassword] - Contraseña actual
  /// [newPassword] - Nueva contraseña
  /// Retorna [RecoveryResult] indicando éxito o error
  Future<RecoveryResult> changePassword({
    required String oldPassword,
    required String newPassword,
  });
}
