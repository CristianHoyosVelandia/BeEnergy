/// Implementación fake del repositorio de autenticación
library;

import 'package:be_energy/core/utils/logger.dart';
import 'package:be_energy/models/auth_models.dart';
import 'package:be_energy/repositories/domain/auth_repository.dart';

/// Implementación con fake data para autenticación
/// Simula respuestas del servidor para desarrollo y testing
class AuthRepositoryFake implements AuthRepository {
  // Usuarios fake para testing
  static final List<Map<String, dynamic>> _fakeUsers = [
    {
      'id': 24,
      'email': 'maria@beenergy.com',
      'password': '123456',
      'name': 'María',
      'last_name': 'García',
      'role': 'prosumer',
    },
    {
      'id': 13,
      'email': 'ana@beenergy.com',
      'password': '123456',
      'name': 'Ana',
      'last_name': 'López',
      'role': 'consumer',
    },
    {
      'id': 1,
      'email': 'admin@beenergy.com',
      'password': 'admin123',
      'name': 'Admin',
      'last_name': 'UAO',
      'role': 'admin',
    },
  ];

  // Almacenamiento en memoria del usuario actual
  AuthUser? _currentUser;

  // Tokens de recuperación fake (en memoria)
  final Map<String, String> _recoveryTokens = {};

  @override
  Future<AuthResult> login(LoginCredentials credentials) async {
    // Simular latencia de red
    await Future.delayed(const Duration(milliseconds: 800));

    // Buscar usuario en fake data
    final userMap = _fakeUsers.firstWhere(
      (user) =>
          user['email'] == credentials.email &&
          user['password'] == credentials.password,
      orElse: () => {},
    );

    if (userMap.isEmpty) {
      return AuthResult.failure(
        error: 'Credenciales inválidas',
        message: 'Email o contraseña incorrectos',
      );
    }

    // Crear usuario autenticado
    final user = AuthUser(
      id: userMap['id'] as int,
      email: userMap['email'] as String,
      name: userMap['name'] as String,
      lastName: userMap['last_name'] as String,
      role: userMap['role'] as String,
      token: _generateFakeToken(userMap['email'] as String),
      tokenExpiry: DateTime.now().add(const Duration(hours: 24)),
    );

    _currentUser = user;

    return AuthResult.success(
      user: user,
      message: 'Bienvenido ${user.fullName}',
    );
  }

  @override
  Future<AuthResult> register(RegisterData data) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    // Verificar si el email ya existe
    final exists = _fakeUsers.any((user) => user['email'] == data.email);

    if (exists) {
      return AuthResult.failure(
        error: 'Email ya registrado',
        message: 'Este email ya está en uso',
      );
    }

    // Crear nuevo usuario
    final newUser = AuthUser(
      id: _fakeUsers.length + 1,
      email: data.email,
      name: data.name,
      lastName: data.lastName,
      role: data.role,
      token: _generateFakeToken(data.email),
      tokenExpiry: DateTime.now().add(const Duration(hours: 24)),
    );

    // Agregar a fake data (solo en memoria)
    _fakeUsers.add({
      'id': newUser.id,
      'email': newUser.email,
      'password': data.password,
      'name': newUser.name,
      'last_name': newUser.lastName,
      'role': newUser.role,
    });

    _currentUser = newUser;

    return AuthResult.success(
      user: newUser,
      message: 'Registro exitoso. Bienvenido ${newUser.fullName}',
    );
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
  }

  @override
  Future<RecoveryResult> requestPasswordRecovery(
      PasswordRecoveryRequest request) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Verificar si el email existe
    final exists = _fakeUsers.any((user) => user['email'] == request.email);

    if (!exists) {
      return RecoveryResult.failure(
        error: 'Email no encontrado',
        message: 'No existe una cuenta con este email',
      );
    }

    // Generar token de recuperación fake
    final token = _generateRecoveryToken(request.email);
    _recoveryTokens[token] = request.email;

    // En producción, aquí se enviaría un email
    AppLogger.info('Email de recuperación enviado a ${request.email}', tag: 'AuthFake');
    AppLogger.debug('Token de recuperación (testing): $token', tag: 'AuthFake');

    return RecoveryResult.success(
      message:
          'Correo de recuperación enviado. Revisa tu bandeja de entrada.',
    );
  }

  @override
  Future<RecoveryResult> resetPassword(PasswordResetRequest request) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Verificar token
    if (!_recoveryTokens.containsKey(request.token)) {
      return RecoveryResult.failure(
        error: 'Token inválido o expirado',
        message: 'El token de recuperación no es válido',
      );
    }

    // Verificar que las contraseñas coincidan
    if (request.newPassword != request.confirmPassword) {
      return RecoveryResult.failure(
        error: 'Las contraseñas no coinciden',
        message: 'La nueva contraseña y su confirmación deben ser iguales',
      );
    }

    final email = _recoveryTokens[request.token]!;

    // Actualizar contraseña en fake data
    final userIndex = _fakeUsers.indexWhere((u) => u['email'] == email);
    if (userIndex != -1) {
      _fakeUsers[userIndex]['password'] = request.newPassword;
      _recoveryTokens.remove(request.token); // Invalidar token usado
    }

    return RecoveryResult.success(
      message: 'Contraseña actualizada exitosamente',
    );
  }

  @override
  Future<bool> isAuthenticated() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _currentUser != null && _currentUser!.isTokenValid;
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _currentUser;
  }

  @override
  Future<AuthResult> refreshToken() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (_currentUser == null) {
      return AuthResult.failure(
        error: 'No hay sesión activa',
        message: 'Debes iniciar sesión primero',
      );
    }

    // Renovar token
    final refreshedUser = AuthUser(
      id: _currentUser!.id,
      email: _currentUser!.email,
      name: _currentUser!.name,
      lastName: _currentUser!.lastName,
      role: _currentUser!.role,
      token: _generateFakeToken(_currentUser!.email),
      tokenExpiry: DateTime.now().add(const Duration(hours: 24)),
    );

    _currentUser = refreshedUser;

    return AuthResult.success(
      user: refreshedUser,
      message: 'Token renovado',
    );
  }

  @override
  Future<bool> validateToken(String token) async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (_currentUser == null) return false;
    if (_currentUser!.token != token) return false;
    return _currentUser!.isTokenValid;
  }

  @override
  Future<RecoveryResult> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (_currentUser == null) {
      return RecoveryResult.failure(
        error: 'No hay sesión activa',
        message: 'Debes iniciar sesión primero',
      );
    }

    // Verificar contraseña actual
    final userMap = _fakeUsers.firstWhere(
      (user) => user['email'] == _currentUser!.email,
      orElse: () => {},
    );

    if (userMap.isEmpty || userMap['password'] != oldPassword) {
      return RecoveryResult.failure(
        error: 'Contraseña actual incorrecta',
        message: 'La contraseña actual no es correcta',
      );
    }

    // Actualizar contraseña
    final userIndex =
        _fakeUsers.indexWhere((u) => u['email'] == _currentUser!.email);
    if (userIndex != -1) {
      _fakeUsers[userIndex]['password'] = newPassword;
    }

    return RecoveryResult.success(
      message: 'Contraseña cambiada exitosamente',
    );
  }

  // Helper methods

  String _generateFakeToken(String email) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'fake_token_${email.split('@')[0]}_$timestamp';
  }

  String _generateRecoveryToken(String email) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'recovery_${email.split('@')[0]}_$timestamp';
  }
}
