// ignore_for_file: avoid_print

import '../core/api/api_client.dart';
import '../core/api/api_exceptions.dart';
import '../core/constants/microservice_config.dart';
import '../models/my_empresas.dart';

/// Rutas específicas del microservicio de Empresas (Kupi)
class EmpresasEndpoints {
  EmpresasEndpoints._();
  static const String getEmpresas = '/getEmpresas';
  static String getEmpresaById(int id) => '/getEmpresa/$id';
}

/// Repositorio para el microservicio de Empresas
/// Sustituye el legado ApiBe/RespositoryBe usando la nueva arquitectura
class EmpresasRepository {
  final ApiClient _apiClient = ApiClient.instance;

  /// Obtiene la lista de empresas
  ///
  /// [buscar] - Término de búsqueda opcional
  /// [categoria] - Filtro por categoría opcional
  Future<EmpresasResponse> fetchGetEmpresas({
    String? buscar,
    String? categoria,
  }) async {
    try {
      final response = await _apiClient.getFromService(
        Microservice.empresas,
        EmpresasEndpoints.getEmpresas,
        headers: {
          'buscar': buscar ?? '',
          'categoria': categoria ?? '',
        },
      );

      return EmpresasResponse.fromJsonEmpresas(
        response.data as Map<String, dynamic>,
      );
    } on ApiException catch (e) {
      print('Error obteniendo empresas: ${e.message}');
      rethrow;
    }
  }

  /// Obtiene el detalle de una empresa por ID
  Future<EmpresasResponse> fetchGetEmpresaById(int id) async {
    try {
      final response = await _apiClient.getFromService(
        Microservice.empresas,
        EmpresasEndpoints.getEmpresaById(id),
      );

      return EmpresasResponse.fromJsonEmpresas(
        response.data as Map<String, dynamic>,
      );
    } on ApiException catch (e) {
      print('Error obteniendo empresa $id: ${e.message}');
      rethrow;
    }
  }
}
