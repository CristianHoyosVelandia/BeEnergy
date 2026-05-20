/// Servicio de Comunidad para gestionar datos y cambios de comunidad
library;

import '../core/api/api_client.dart';
import '../core/api/api_exceptions.dart';
import '../core/constants/api_endpoints.dart';
import '../core/utils/logger.dart';

class CommunityService {
  static const String _tag = 'CommunityService';
  final ApiClient _apiClient = ApiClient.instance;

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
          'Error al obtener datos de comunidad',
          statusCode: response.statusCode,
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
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }

  /// Obtiene la lista de comunidades del usuario actual
  /// Retorna lista de comunidades con sus datos
  Future<List<Map<String, dynamic>>> getUserCommunities() async {
    try {
      final response = await _apiClient.get('/community/my-communities');

      AppLogger.debug(
        'getUserCommunities response: ${response.data}',
        tag: _tag,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        // Si la respuesta tiene un 'data' wrapper
        if (data.containsKey('data')) {
          return List<Map<String, dynamic>>.from(data['data'] as List);
        }

        return <Map<String, dynamic>>[];
      } else {
        throw ApiException(
          'Error al obtener comunidades',
          statusCode: response.statusCode,
        );
      }
    } on ApiException catch (e) {
      AppLogger.error('Error en getUserCommunities', tag: _tag, error: e.message);
      rethrow;
    } catch (e) {
      AppLogger.error(
        'Error inesperado en getUserCommunities',
        tag: _tag,
        error: e.toString(),
      );
      throw ApiException('Error inesperado: ${e.toString()}');
    }
  }
}
