// ignore_for_file: avoid_print

import '../core/api/api_client.dart';
import '../core/api/api_response.dart';
import '../core/api/api_exceptions.dart';
import '../core/constants/api_endpoints.dart';
import '../core/constants/microservice_config.dart';

/// Repositorio de transacciones (ofertas, contratos P2P, liquidación)
class TransactionRepository {
  final ApiClient _apiClient = ApiClient.instance;

  /// Consultar registros de energía por usuario y período
  Future<ApiResponse<List<dynamic>>> getEnergyRecords({
    required int userId,
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final response = await _apiClient.postFromService(
        Microservice.trading,
        ApiEndpoints.queryEnergyRecords,
        data: {
          'user_id': userId,
          'start': start.toIso8601String(),
          'end': end.toIso8601String(),
        },
      );
      final body = response.data as Map<String, dynamic>;
      final list = body['data'];
      if (list is List) {
        return ApiResponse.success(
          data: list,
          message: body['message'] ?? 'Registros obtenidos',
        );
      }
      return ApiResponse.success(data: [], message: 'Sin registros');
    } on ApiException catch (e) {
      print('Error obteniendo registros de energía: ${e.message}');
      rethrow;
    }
  }

  /// Crear contrato P2P (oferta)
  Future<ApiResponse<Map<String, dynamic>>> createContract({
    required int sellerId,
    required double agreedPrice,
    required double energyCommitted,
    int? buyerId,
    int? communityId,
  }) async {
    try {
      final response = await _apiClient.postFromService(
        Microservice.trading,
        ApiEndpoints.createContract,
        data: {
          'seller_id': sellerId,
          'buyer_id': buyerId,
          'community_id': communityId,
          'agreed_price': agreedPrice,
          'energy_committed': energyCommitted,
        },
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (d) => d as Map<String, dynamic>,
      );
    } on ApiException catch (e) {
      print('Error creando contrato: ${e.message}');
      rethrow;
    }
  }

  /// Listar contratos/ofertas (activas o por vendedor)
  /// Nota: requiere que el backend exponga GET /transactions/contracts
  Future<ApiResponse<List<dynamic>>> listContracts({
    int? sellerId,
    int? buyerId,
    String status = 'active',
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'status': status,
        'limit': limit,
      };
      if (sellerId != null) queryParams['seller_id'] = sellerId;
      if (buyerId != null) queryParams['buyer_id'] = buyerId;
      final response = await _apiClient.getFromService(
        Microservice.trading,
        ApiEndpoints.listContracts,
        queryParameters: queryParams,
      );
      final body = response.data as Map<String, dynamic>;
      final list = body['data'] ?? body['contracts'] ?? body;
      if (list is List) {
        return ApiResponse.success(
          data: list,
          message: body['message'] ?? 'Ofertas obtenidas',
        );
      }
      return ApiResponse.success(data: [], message: 'Sin ofertas');
    } on ApiException catch (e) {
      print('Error listando contratos: ${e.message}');
      rethrow;
    }
  }

  /// Aceptar/Rechazar/Cancelar contrato
  Future<ApiResponse<Map<String, dynamic>>> actOnContract({
    required int contractId,
    required String action,
    int? buyerId,
  }) async {
    try {
      final response = await _apiClient.postFromService(
        Microservice.trading,
        '/transactions/contracts/$contractId/action',
        data: {'action': action, 'buyer_id': buyerId},
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (d) => d as Map<String, dynamic>,
      );
    } on ApiException catch (e) {
      print('Error en acción de contrato: ${e.message}');
      rethrow;
    }
  }
}
