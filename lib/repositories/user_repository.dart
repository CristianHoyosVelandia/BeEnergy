// ignore_for_file: avoid_print

import '../core/api/api_client.dart';
import '../core/api/api_response.dart';
import '../core/api/api_exceptions.dart';
import '../core/constants/api_endpoints.dart';
import '../core/constants/microservice_config.dart';

/// Repositorio de usuarios
class UserRepository {
  final ApiClient _apiClient = ApiClient.instance;

  /// Obtener perfil de usuario
  Future<ApiResponse<Map<String, dynamic>>> getUser(int userId) async {
    try {
      final response = await _apiClient.getFromService(
        Microservice.user,
        ApiEndpoints.userProfile(userId),
      );
      final body = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(
        body,
        (d) => (d ?? body['data']) as Map<String, dynamic>,
      );
    } on ApiException catch (e) {
      print('Error obteniendo usuario: ${e.message}');
      rethrow;
    }
  }

  /// Actualizar datos personales (teléfono, correo)
  Future<ApiResponse<Map<String, dynamic>>> updateProfile(
    int userId, {
    String? name,
    String? lastname,
    String? phone,
    String? email,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (lastname != null) data['lastname'] = lastname;
      if (phone != null) data['phone'] = phone;
      if (email != null) data['email'] = email;

      final response = await _apiClient.putFromService(
        Microservice.user,
        ApiEndpoints.updateProfile(userId),
        data: data,
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (d) => d as Map<String, dynamic>,
      );
    } on ApiException catch (e) {
      print('Error actualizando perfil: ${e.message}');
      rethrow;
    }
  }

  /// Cambiar rol (solo administrador)
  Future<ApiResponse<Map<String, dynamic>>> changeRole(
    int userId, {
    required int role,
  }) async {
    try {
      final response = await _apiClient.patchFromService(
        Microservice.user,
        ApiEndpoints.changeRole(userId),
        data: {'role': role},
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (d) => d as Map<String, dynamic>,
      );
    } on ApiException catch (e) {
      print('Error cambiando rol: ${e.message}');
      rethrow;
    }
  }
}
