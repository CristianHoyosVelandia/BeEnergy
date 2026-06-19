import 'package:be_energy/core/api/api_client.dart';
import 'package:be_energy/core/api/api_exceptions.dart';
import 'package:be_energy/core/constants/api_endpoints.dart';
import 'package:be_energy/models/forecast_pde.dart';

class ForecastApiService {
  final ApiClient _client;

  ForecastApiService({ApiClient? client})
      : _client = client ?? ApiClient.instance;

  Future<ForecastOfertaPde> getOfertaPde({
    required int communityId,
    required String period,
    int? userId,
  }) async {
    try {
      final response = await _client.get(
        ApiEndpoints.forecastOfertaPde,
        queryParameters: {
          'community_id': communityId,
          'period': period,
          if (userId != null) 'user_id': userId,
        },
      );

      final body = response.data as Map<String, dynamic>;
      if (body['success'] == true) {
        return ForecastOfertaPde.fromJson(body['data'] as Map<String, dynamic>);
      }

      throw ApiException(
        message: body['message'] as String? ?? 'Error obteniendo forecast PDE',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Error inesperado obteniendo forecast PDE: $e',
        statusCode: 500,
      );
    }
  }

  Future<ForecastAporteSolidario> getAporteSolidario({
    required int communityId,
    required String period,
    int? userId,
  }) async {
    try {
      final response = await _client.get(
        ApiEndpoints.forecastAporteSolidario,
        queryParameters: {
          'community_id': communityId,
          'period': period,
          if (userId != null) 'user_id': userId,
        },
      );

      final body = response.data as Map<String, dynamic>;
      if (body['success'] == true) {
        return ForecastAporteSolidario.fromJson(
          body['data'] as Map<String, dynamic>,
        );
      }

      throw ApiException(
        message: body['message'] as String? ?? 'Error obteniendo aporte PDE',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Error inesperado obteniendo aporte PDE: $e',
        statusCode: 500,
      );
    }
  }
}
