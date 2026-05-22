import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_client.dart';
import '../api/api_exceptions.dart';
import '../constants/api_endpoints.dart';
import '../utils/logger.dart';
import '../theme/app_tokens.dart';
import '../../services/community_theme_storage.dart';

/// Servicio de autenticación para la aplicación BeEnergy
/// Integrado con Volt Platform Services API
class AuthService {
  static const String _tag = 'AuthService';
  static const String _tokenKey = 'auth_token';
  final ApiClient _apiClient = ApiClient.instance;
  final CommunityThemeStorage _themeStorage = CommunityThemeStorage();

  /// Verifica la conexión con el servidor (ping)
  ///
  /// Retorna true si el servidor está disponible
  Future<bool> ping() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.ping);
      return response.statusCode == 200;
    } on ApiException catch (e) {
      AppLogger.error('Error en ping', tag: _tag, error: e.message);
      return false;
    }
  }

  /// Realiza el login del usuario
  ///
  /// [email] - Correo electrónico del usuario
  /// [password] - Contraseña del usuario
  ///
  /// Retorna un Map con la respuesta del servidor que incluye:
  /// - success: bool
  /// - message: String
  /// - data: Map con información del usuario y token
  /// - token: String (JWT token)
  Future<Map<String, dynamic>> login(
      {required String email, required String password}) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );
      AppLogger.debug('Login response: ${response.data}', tag: _tag);
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        // Si hay token, guardarlo en el cliente
        if (data['data'] != null) {
          final userData = data['data'] as Map<String, dynamic>;
          _apiClient.setAuthToken(userData['token']);
          await _saveToken(userData['token']);

          // Persistir referencia de comunidad, pero no reconstruir el tema aquí.
          // El flujo de login decide si debe abrir selección de comunidades primero.
          await _saveThemeDataFromLogin(userData);
        }

        return {
          'success': true,
          'message': data['message'] ?? 'Login exitoso',
          'data': data['data'],
          'token': data['data']?['token'],
        };
      } else {
        return {
          'success': false,
          'message': 'Error en el login',
          'data': null,
          'token': null,
        };
      }
    } on ApiException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'data': null,
        'token': null,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error inesperado: ${e.toString()}',
        'data': null,
        'token': null,
      };
    }
  }

  /// Guarda el token en SharedPreferences
  Future<void> _saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      AppLogger.debug('Token guardado en storage', tag: _tag);
    } catch (e) {
      AppLogger.error('Error guardando token', tag: _tag, error: e.toString());
    }
  }

  /// Guarda los datos de tema de comunidad en storage durante el login
  Future<void> _saveThemeDataFromLogin(Map<String, dynamic> userData) async {
    try {
      final primaryColor = userData['primary_color'] as String? ??
          CommunityThemeStorage.defaultPrimaryColor;
      final secondColor = userData['second_color'] as String? ??
          CommunityThemeStorage.defaultSecondColor;
      final urlImg =
          userData['url_img'] as String? ?? CommunityThemeStorage.defaultUrlImg;
      final topology = userData['topologic'] as int? ??
          CommunityThemeStorage.defaultTopology;

      // Si hay comunidades, guardar la primera
      int? communityId;
      final communities = userData['communities'] as List?;
      if (communities != null && communities.isNotEmpty) {
        communityId = communities[0] as int;
      }

      await _themeStorage.saveCommunityTheme(
        primaryColor: primaryColor,
        secondColor: secondColor,
        urlImg: urlImg,
        topology: topology,
        communityId: communityId ?? 0,
      );

      AppLogger.debug(
        'Theme data saved: primary=$primaryColor, second=$secondColor',
        tag: _tag,
      );
    } catch (e) {
      AppLogger.error(
        'Error saving theme data',
        tag: _tag,
        error: e.toString(),
      );
    }
  }

  /// Registra un nuevo usuario
  ///
  /// [email] - Correo electrónico del usuario
  /// [password] - Contraseña del usuario
  /// [name] - Nombre completo del usuario (opcional)
  /// [phone] - Teléfono del usuario (opcional)
  ///
  /// Retorna un Map con la respuesta del servidor
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    String? name,
    String? phone,
  }) async {
    try {
      final data = {
        'email': email,
        'password': password,
      };

      // Agregar campos opcionales si están presentes
      if (name != null && name.isNotEmpty) {
        data['name'] = name;
      }
      if (phone != null && phone.isNotEmpty) {
        data['phone'] = phone;
      }

      final response = await _apiClient.post(
        ApiEndpoints.signUp,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data as Map<String, dynamic>;

        // Si hay token, guardarlo en el cliente
        if (responseData['token'] != null) {
          _apiClient.setAuthToken(responseData['token']);
          await _saveToken(responseData['token']);
        }

        return {
          'success': true,
          'message':
              responseData['message'] ?? 'Usuario registrado exitosamente',
          'data': responseData['data'],
          'token': responseData['token'],
        };
      } else {
        return {
          'success': false,
          'message': 'Error en el registro',
          'data': null,
          'token': null,
        };
      }
    } on ApiException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'data': null,
        'token': null,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error inesperado: ${e.toString()}',
        'data': null,
        'token': null,
      };
    }
  }

  /// Envía un correo para recuperar la contraseña
  ///
  /// [email] - Correo electrónico del usuario
  ///
  /// Retorna un Map con la respuesta del servidor
  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.forgotPassword,
        data: {
          'email': email,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        return {
          'success': true,
          'message': data['message'] ?? 'Correo de recuperación enviado',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': 'Error al enviar correo de recuperación',
          'data': null,
        };
      }
    } on ApiException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'data': null,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error inesperado: ${e.toString()}',
        'data': null,
      };
    }
  }

  /// Resetea la contraseña del usuario
  ///
  /// [token] - Token de recuperación recibido por email
  /// [newPassword] - Nueva contraseña
  ///
  /// Retorna un Map con la respuesta del servidor
  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.resetPassword,
        data: {
          'token': token,
          'new_password': newPassword,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        return {
          'success': true,
          'message': data['message'] ?? 'Contraseña actualizada exitosamente',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': 'Error al resetear contraseña',
          'data': null,
        };
      }
    } on ApiException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'data': null,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error inesperado: ${e.toString()}',
        'data': null,
      };
    }
  }

  /// Verifica si el token es válido
  ///
  /// Retorna true si el token es válido, false en caso contrario
  Future<bool> verifyToken() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.verifyToken);
      return response.statusCode == 200;
    } on ApiException catch (e) {
      AppLogger.error('Error verificando token', tag: _tag, error: e.message);
      return false;
    }
  }

  /// Cierra la sesión del usuario
  ///
  /// Retorna un Map con la respuesta del servidor
  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await _apiClient.post(ApiEndpoints.logout);

      // Remover token del cliente y storage
      _apiClient.removeAuthToken();
      await _removeToken();
      await _themeStorage.clearThemeData();
      AppTokens.resetToDefaultColors();

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        return {
          'success': true,
          'message': data['message'] ?? 'Sesión cerrada exitosamente',
        };
      } else {
        return {
          'success': true, // Consideramos exitoso aunque el servidor falle
          'message': 'Sesión cerrada localmente',
        };
      }
    } on ApiException {
      // Aunque falle, removemos el token localmente
      _apiClient.removeAuthToken();
      await _removeToken();
      await _themeStorage.clearThemeData();
      AppTokens.resetToDefaultColors();

      return {
        'success': true,
        'message': 'Sesión cerrada localmente',
      };
    } catch (_) {
      // Aunque falle, removemos el token localmente
      _apiClient.removeAuthToken();
      await _removeToken();
      await _themeStorage.clearThemeData();
      AppTokens.resetToDefaultColors();

      return {
        'success': true,
        'message': 'Sesión cerrada localmente',
      };
    }
  }

  /// Remueve el token de SharedPreferences
  Future<void> _removeToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      AppLogger.debug('Token removido del storage', tag: _tag);
    } catch (e) {
      AppLogger.error('Error removiendo token', tag: _tag, error: e.toString());
    }
  }
}
