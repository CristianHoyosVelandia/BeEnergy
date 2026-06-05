import 'package:be_energy/core/api/api_client.dart';
import 'package:be_energy/models/pde_renuncia.dart';

class PdeRenunciaService {
  final ApiClient _client;

  PdeRenunciaService({ApiClient? client})
      : _client = client ?? ApiClient.instance;

  Future<PdeRenunciaStatus> getUserStatus({
    required int comunidadId,
    required int usuarioId,
    required String periodo,
  }) async {
    final response = await _client.get(
      '/community/pde-renuncias/user',
      queryParameters: {
        'comunidad_id': comunidadId,
        'usuario_id': usuarioId,
        'periodo': periodo,
      },
    );

    final body = response.data as Map<String, dynamic>;
    if (body['success'] != true) {
      throw Exception(body['message'] ?? 'Error obteniendo renuncia PDE');
    }

    return PdeRenunciaStatus.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<PdeRenuncia> createRenuncia({
    required int comunidadId,
    required int usuarioId,
    required String periodo,
    required double pdeRenunciado,
    String? motivo,
  }) async {
    final response = await _client.post(
      '/community/pde-renuncias',
      data: {
        'comunidad_id': comunidadId,
        'usuario_id': usuarioId,
        'periodo': periodo,
        'pde_renunciado': pdeRenunciado,
        'motivo': motivo,
        'creado_por': usuarioId,
      },
    );

    final body = response.data as Map<String, dynamic>;
    if (body['success'] != true) {
      throw Exception(body['message'] ?? 'Error creando renuncia PDE');
    }

    return PdeRenuncia.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<PdeRenuncia> updateRenuncia({
    required int renunciaId,
    required int usuarioId,
    required double pdeRenunciado,
    String? motivo,
  }) async {
    final response = await _client.put(
      '/community/pde-renuncias/$renunciaId',
      data: {
        'pde_renunciado': pdeRenunciado,
        'motivo': motivo,
        'actualizado_por': usuarioId,
      },
    );

    final body = response.data as Map<String, dynamic>;
    if (body['success'] != true) {
      throw Exception(body['message'] ?? 'Error actualizando renuncia PDE');
    }

    return PdeRenuncia.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<void> closeFlow({
    required int comunidadId,
    required String periodo,
    required int adminId,
  }) async {
    final response = await _client.post(
      '/community/pde-renuncias/cerrar',
      data: {
        'comunidad_id': comunidadId,
        'periodo': periodo,
        'admin_id': adminId,
      },
    );

    final body = response.data as Map<String, dynamic>;
    if (body['success'] != true) {
      throw Exception(body['message'] ?? 'Error cerrando renuncias PDE');
    }
  }
}
