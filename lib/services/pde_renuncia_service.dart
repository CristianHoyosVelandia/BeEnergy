import 'package:be_energy/core/api/api_client.dart';
import 'package:be_energy/core/constants/api_endpoints.dart';
import 'package:be_energy/models/pde_renuncia.dart';
import 'package:be_energy/services/forecast_api_service.dart';

class PdeRenunciaService {
  final ApiClient _client;
  final ForecastApiService _forecastService;

  PdeRenunciaService({ApiClient? client})
      : _client = client ?? ApiClient.instance,
        _forecastService = ForecastApiService(client: client);

  Future<PdeRenunciaStatus> getUserStatus({
    required int comunidadId,
    required int usuarioId,
    required String periodo,
  }) async {
    final forecast = await _forecastService.getAporteSolidario(
      communityId: comunidadId,
      userId: usuarioId,
      period: periodo,
    );

    return PdeRenunciaStatus(
      comunidadId: forecast.communityId,
      usuarioId: forecast.userId,
      periodo: forecast.period,
      pdeActual: forecast.pdeActual / 100,
      consumoKwh: forecast.consumoEstimadoKwh,
      pdeSugeridoRenuncia: forecast.renunciaSugerida / 100,
      pdeSugeridoConservado: forecast.pdeConservadoSugerido / 100,
      fuente: forecast.fuente,
      nivelConfianza: forecast.nivelConfianza,
      opciones: forecast.opciones
          .map((option) => PdeRenunciaOption(
                id: option.id,
                renunciaPorcentaje: option.renunciaPorcentaje,
                descripcion: option.descripcion,
              ))
          .toList(),
      permiteRenunciaManual: forecast.permiteRenunciaManual,
    );
  }

  Future<PdeRenuncia> createRenuncia({
    required int comunidadId,
    required int usuarioId,
    required String periodo,
    required double pdeRenunciado,
    double? renunciaKwh,
    String? motivo,
  }) async {
    final response = await _client.post(
      ApiEndpoints.pdeRenuncia,
      data: {
        'community_id': comunidadId,
        'period': periodo,
        'renuncia_porcentaje': pdeRenunciado * 100,
        'renuncia_kwh': renunciaKwh ?? (pdeRenunciado * 100),
        'origen': 'forecast',
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
