/// Servicio de Comunidad para gestionar datos y cambios de comunidad
library;

import '../core/api/api_client.dart';
import '../core/api/api_exceptions.dart';
import '../core/utils/logger.dart';
import '../models/community_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommunityService {
  static const String _tag = 'CommunityService';
  static const String _tokenKey = 'auth_token';
  final ApiClient _apiClient = ApiClient.instance;

  Future<void> _saveToken(String token) async {
    _apiClient.setAuthToken(token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Obtiene las comunidades del usuario autenticado por token.
  Future<List<Community>> getMyCommunities() async {
    try {
      final response = await _apiClient.get('/community/me');

      AppLogger.debug('getMyCommunities response: ${response.data}', tag: _tag);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final list = data['data'] as List? ?? [];
        return list
            .map((item) => Community.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      throw ApiException(
        message: 'Error al obtener comunidades del usuario',
        statusCode: response.statusCode ?? 0,
      );
    } on ApiException catch (e) {
      AppLogger.error('Error en getMyCommunities', tag: _tag, error: e.message);
      rethrow;
    } catch (e) {
      AppLogger.error(
        'Error inesperado en getMyCommunities',
        tag: _tag,
        error: e.toString(),
      );
      throw ApiException(message: 'Error inesperado: ${e.toString()}');
    }
  }

  /// Selecciona una comunidad y guarda el JWT renovado que contiene rol/comunidad.
  Future<Community> selectCommunity(int communityId) async {
    try {
      final response = await _apiClient.post('/community/select/$communityId');

      AppLogger.debug('selectCommunity response: ${response.data}', tag: _tag);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final payload = data['data'] as Map<String, dynamic>;
        final token = payload['token'] as String?;
        final communityData = payload['community'] as Map<String, dynamic>;

        if (token != null && token.isNotEmpty) {
          await _saveToken(token);
        }

        return Community.fromJson(communityData);
      }

      throw ApiException(
        message: 'Error al seleccionar comunidad',
        statusCode: response.statusCode ?? 0,
      );
    } on ApiException catch (e) {
      AppLogger.error('Error en selectCommunity', tag: _tag, error: e.message);
      rethrow;
    } catch (e) {
      AppLogger.error(
        'Error inesperado en selectCommunity',
        tag: _tag,
        error: e.toString(),
      );
      throw ApiException(message: 'Error inesperado: ${e.toString()}');
    }
  }

  /// Obtiene los datos de una comunidad específica
  /// Retorna: topologic, primary_color, second_color, url_img, rol, description
  Future<Map<String, dynamic>> getCommunityData(int communityId) async {
    try {
      final response = await _apiClient.get(
        '/community/$communityId',
      );

      AppLogger.debug('getCommunityData response: ${response.data}', tag: _tag);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        // Si la respuesta tiene un 'data' wrapper
        if (data.containsKey('data')) {
          return data['data'] as Map<String, dynamic>;
        }

        return data;
      } else {
        throw ApiException(
          message: 'Error al obtener datos de comunidad',
          statusCode: response.statusCode ?? 0,
        );
      }
    } on ApiException catch (e) {
      AppLogger.error(
        'Error en getCommunityData',
        tag: _tag,
        error: e.message,
      );
      rethrow;
    } catch (e) {
      AppLogger.error(
        'Error inesperado en getCommunityData',
        tag: _tag,
        error: e.toString(),
      );
      throw ApiException(
        message: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Obtiene todas las comunidades (solo rol 4)
  Future<List<Map<String, dynamic>>> getAllCommunities() async {
    try {
      final response = await _apiClient.get('/community');

      AppLogger.debug('getAllCommunities response: ${response.data}',
          tag: _tag);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        // Si la respuesta tiene un 'data' wrapper
        if (data.containsKey('data')) {
          return List<Map<String, dynamic>>.from(data['data'] as List);
        }

        return <Map<String, dynamic>>[];
      } else {
        throw ApiException(
          message: 'Error al obtener comunidades',
          statusCode: response.statusCode ?? 0,
        );
      }
    } on ApiException catch (e) {
      AppLogger.error('Error en getAllCommunities',
          tag: _tag, error: e.message);
      rethrow;
    } catch (e) {
      AppLogger.error(
        'Error inesperado en getAllCommunities',
        tag: _tag,
        error: e.toString(),
      );
      throw ApiException(
        message: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Obtiene una comunidad específica (solo rol 4)
  Future<Map<String, dynamic>> getCommunityById(int communityId) async {
    try {
      final response = await _apiClient.get('/community/$communityId');

      AppLogger.debug('getCommunityById response: ${response.data}', tag: _tag);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        if (data.containsKey('data')) {
          return data['data'] as Map<String, dynamic>;
        }

        return data;
      } else {
        throw ApiException(
          message: 'Error al obtener comunidad',
          statusCode: response.statusCode ?? 0,
        );
      }
    } on ApiException catch (e) {
      AppLogger.error('Error en getCommunityById', tag: _tag, error: e.message);
      rethrow;
    } catch (e) {
      AppLogger.error(
        'Error inesperado en getCommunityById',
        tag: _tag,
        error: e.toString(),
      );
      throw ApiException(
        message: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Crea una nueva comunidad (solo rol 4)
  Future<Map<String, dynamic>> createCommunity(
      Map<String, dynamic> communityData) async {
    try {
      final response = await _apiClient.post(
        '/community',
        data: communityData,
      );

      AppLogger.debug('createCommunity response: ${response.data}', tag: _tag);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;

        if (data.containsKey('data')) {
          return data['data'] as Map<String, dynamic>;
        }

        return data;
      } else {
        throw ApiException(
          message: 'Error al crear comunidad',
          statusCode: response.statusCode ?? 0,
        );
      }
    } on ApiException catch (e) {
      AppLogger.error('Error en createCommunity', tag: _tag, error: e.message);
      rethrow;
    } catch (e) {
      AppLogger.error(
        'Error inesperado en createCommunity',
        tag: _tag,
        error: e.toString(),
      );
      throw ApiException(
        message: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Actualiza una comunidad existente (solo rol 4)
  Future<Map<String, dynamic>> updateCommunity(
    int communityId,
    Map<String, dynamic> communityData,
  ) async {
    try {
      final response = await _apiClient.put(
        '/community/$communityId',
        data: communityData,
      );

      AppLogger.debug('updateCommunity response: ${response.data}', tag: _tag);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        if (data.containsKey('data')) {
          return data['data'] as Map<String, dynamic>;
        }

        return data;
      } else {
        throw ApiException(
          message: 'Error al actualizar comunidad',
          statusCode: response.statusCode ?? 0,
        );
      }
    } on ApiException catch (e) {
      AppLogger.error('Error en updateCommunity', tag: _tag, error: e.message);
      rethrow;
    } catch (e) {
      AppLogger.error(
        'Error inesperado en updateCommunity',
        tag: _tag,
        error: e.toString(),
      );
      throw ApiException(
        message: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Elimina una comunidad (solo rol 4)
  Future<bool> deleteCommunity(int communityId) async {
    try {
      final response = await _apiClient.delete('/community/$communityId');

      AppLogger.debug('deleteCommunity response: ${response.data}', tag: _tag);

      if (response.statusCode == 200) {
        return true;
      } else {
        throw ApiException(
          message: 'Error al eliminar comunidad',
          statusCode: response.statusCode ?? 0,
        );
      }
    } on ApiException catch (e) {
      AppLogger.error('Error en deleteCommunity', tag: _tag, error: e.message);
      rethrow;
    } catch (e) {
      AppLogger.error(
        'Error inesperado en deleteCommunity',
        tag: _tag,
        error: e.toString(),
      );
      throw ApiException(
        message: 'Error inesperado: ${e.toString()}',
      );
    }
  }
}
