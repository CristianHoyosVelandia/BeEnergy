/// Modelos para autenticación
/// Login, registro, recuperación de contraseña
library;

/// Datos de autenticación del usuario
class AuthUser {
  final int id;
  final String email;
  final String name;
  final String lastName;
  final String role; // 'consumer', 'prosumer', 'admin'
  final String token;
  final DateTime? tokenExpiry;

  AuthUser({
    required this.id,
    required this.email,
    required this.name,
    required this.lastName,
    required this.role,
    required this.token,
    this.tokenExpiry,
  });

  String get fullName => '$name $lastName';

  bool get isTokenValid {
    if (tokenExpiry == null) return true;
    return DateTime.now().isBefore(tokenExpiry!);
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as int,
      email: json['email'] as String,
      name: json['name'] as String,
      lastName: json['last_name'] as String,
      role: json['role'] as String,
      token: json['token'] as String,
      tokenExpiry: json['token_expiry'] != null
          ? DateTime.parse(json['token_expiry'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'last_name': lastName,
      'role': role,
      'token': token,
      'token_expiry': tokenExpiry?.toIso8601String(),
    };
  }
}

/// Credenciales de login
class LoginCredentials {
  final String email;
  final String password;

  LoginCredentials({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

/// Datos para registro de usuario
class RegisterData {
  final String email;
  final String password;
  final String name;
  final String lastName;
  final String documentType; // 'CC', 'NIT', 'CE', 'TI'
  final String documentNumber;
  final String phone;
  final String role; // 'consumer', 'prosumer'

  RegisterData({
    required this.email,
    required this.password,
    required this.name,
    required this.lastName,
    required this.documentType,
    required this.documentNumber,
    required this.phone,
    this.role = 'consumer',
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'last_name': lastName,
      'document_type': documentType,
      'document_number': documentNumber,
      'phone': phone,
      'role': role,
    };
  }
}

/// Solicitud de recuperación de contraseña
class PasswordRecoveryRequest {
  final String email;

  PasswordRecoveryRequest({required this.email});

  Map<String, dynamic> toJson() {
    return {'email': email};
  }
}

/// Solicitud de reseteo de contraseña
class PasswordResetRequest {
  final String token;
  final String newPassword;
  final String confirmPassword;

  PasswordResetRequest({
    required this.token,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'new_password': newPassword,
      'confirm_password': confirmPassword,
    };
  }
}

/// Resultado de operación de autenticación
class AuthResult {
  final bool success;
  final String message;
  final AuthUser? user;
  final String? error;

  AuthResult({
    required this.success,
    required this.message,
    this.user,
    this.error,
  });

  factory AuthResult.success({
    required AuthUser user,
    String message = 'Autenticación exitosa',
  }) {
    return AuthResult(
      success: true,
      message: message,
      user: user,
    );
  }

  factory AuthResult.failure({
    required String error,
    String message = 'Error de autenticación',
  }) {
    return AuthResult(
      success: false,
      message: message,
      error: error,
    );
  }
}

/// Resultado de operación de recuperación
class RecoveryResult {
  final bool success;
  final String message;
  final String? error;

  RecoveryResult({
    required this.success,
    required this.message,
    this.error,
  });

  factory RecoveryResult.success({
    String message = 'Correo de recuperación enviado',
  }) {
    return RecoveryResult(
      success: true,
      message: message,
    );
  }

  factory RecoveryResult.failure({
    required String error,
    String message = 'Error al enviar correo de recuperación',
  }) {
    return RecoveryResult(
      success: false,
      message: message,
      error: error,
    );
  }
}
