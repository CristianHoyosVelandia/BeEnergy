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
      renuncia: forecast.renuncia == null
          ? null
          : PdeRenuncia.fromJson(forecast.renuncia!, percentageValues: true),
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

    return PdeRenuncia.fromJson(body['data'] as Map<String, dynamic>,
        percentageValues: true);
  }

  Future<PdeRenuncia> updateRenuncia({
    required int comunidadId,
    required String periodo,
    required double pdeRenunciado,
    required double renunciaKwh,
    String? motivo,
  }) async {
    // El endpoint canónico actualiza la decisión pendiente del mismo periodo y
    // usa puntos porcentuales, igual que al crear. Evita mezclar unidades legacy.
    final response = await _client.post(
      ApiEndpoints.pdeRenuncia,
      data: {
        'community_id': comunidadId,
        'period': periodo,
        'renuncia_porcentaje': pdeRenunciado * 100,
        'renuncia_kwh': renunciaKwh,
        'origen': 'manual',
      },
    );

    final body = response.data as Map<String, dynamic>;
    if (body['success'] != true) {
      throw Exception(body['message'] ?? 'Error actualizando renuncia PDE');
    }

    return PdeRenuncia.fromJson(body['data'] as Map<String, dynamic>,
        percentageValues: true);
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
