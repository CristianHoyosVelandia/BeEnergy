/// Servicio API para Gestión de Ofertas de Consumidores
///
/// Maneja todas las operaciones HTTP relacionadas con consumer offers
/// Conecta con el backend FastAPI siguiendo las mejores prácticas de la industria
library;

import '../core/api/api_client.dart';
import '../core/api/api_exceptions.dart';
import '../core/constants/api_endpoints.dart';
import '../models/consumer_offer.dart';

/// Servicio para operaciones de Consumer Offers con el backend
class ConsumerOfferApiService {
  final ApiClient _apiClient = ApiClient.instance;

  // ============================================================================
  // CONSULTAS (GET)
  // ============================================================================

  /// Obtiene todas las ofertas de un comprador específico
  ///
  /// GET /consumer-offers/buyer/{buyer_id}
  ///
  /// [buyerId] - ID del comprador
  ///
  /// Retorna lista de ofertas o lanza ApiException
  Future<List<ConsumerOffer>> getBuyerOffers(int buyerId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.getConsumerOffersByBuyer(buyerId),
      );

      if (response.data['status'] == true) {
        final List<dynamic> offersData = response.data['data'] as List<dynamic>;
        return offersData
            .map((json) => ConsumerOffer.fromBackendJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ApiException(
          message: response.data['message'] ?? 'Error al obtener ofertas',
          statusCode: response.statusCode,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Error inesperado al obtener ofertas: $e',
        statusCode: 500,
      );
    }
  }

  /// Obtiene una oferta específica por ID
  ///
  /// GET /consumer-offers/{offer_id}
  ///
  /// [offerId] - ID de la oferta
  ///
  /// Retorna la oferta o lanza ApiException
  Future<ConsumerOffer> getOfferById(int offerId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.getConsumerOfferById(offerId),
      );

      if (response.data['status'] == true) {
        return ConsumerOffer.fromBackendJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw ApiException(
          message: response.data['message'] ?? 'Oferta no encontrada',
          statusCode: response.statusCode,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Error inesperado al obtener oferta: $e',
        statusCode: 500,
      );
    }
  }

  /// Obtiene ofertas por período
  ///
  /// GET /consumer-offers/period/{period}
  ///
  /// [period] - Período en formato YYYY-MM
  ///
  /// Retorna lista de ofertas o lanza ApiException
  Future<List<ConsumerOffer>> getOffersByPeriod(String period) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.getConsumerOffersByPeriod(period),
      );

      if (response.data['status'] == true) {
        final List<dynamic> offersData = response.data['data'] as List<dynamic>;
        return offersData
            .map((json) => ConsumerOffer.fromBackendJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ApiException(
          message: response.data['message'] ?? 'Error al obtener ofertas',
          statusCode: response.statusCode,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Error inesperado al obtener ofertas por período: $e',
        statusCode: 500,
      );
    }
  }

  /// Obtiene ofertas de una comunidad en un período específico
  ///
  /// GET /consumer-offers/community/{community_id}/period/{period}
  ///
  /// [communityId] - ID de la comunidad
  /// [period] - Período en formato YYYY-MM
  ///
  /// Retorna lista de ofertas o lanza ApiException
  Future<List<ConsumerOffer>> getOffersByCommunityAndPeriod(
    int communityId,
    String period,
  ) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.getConsumerOffersByCommunityAndPeriod(communityId, period),
      );

      if (response.data['status'] == true) {
        final List<dynamic> offersData = response.data['data'] as List<dynamic>;
        return offersData
            .map((json) => ConsumerOffer.fromBackendJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ApiException(
          message: response.data['message'] ?? 'Error al obtener ofertas',
          statusCode: response.statusCode,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Error inesperado al obtener ofertas de comunidad: $e',
        statusCode: 500,
      );
    }
  }

  // ============================================================================
  // CREACIÓN (POST)
  // ============================================================================

  /// Crea una nueva oferta de consumidor
  ///
  /// POST /consumer-offers
  ///
  /// [buyerId] - ID del comprador
  /// [communityId] - ID de la comunidad
  /// [period] - Período en formato YYYY-MM (ej: "2026-01")
  /// [pdePercentageRequested] - Porcentaje del PDE (0.01 - 99.99)
  /// [pricePerKwh] - Precio por kWh en COP
  ///
  /// Retorna la oferta creada o lanza ApiException
  Future<ConsumerOffer> createOffer({
    required int buyerId,
    required int communityId,
    required String period,
    required double pdePercentageRequested,
    required double pricePerKwh,
  }) async {
    try {
      final requestData = {
        'buyer_id': buyerId,
        'community_id': communityId,
        'period': period,
        'pde_percentage_requested': pdePercentageRequested,
        'price_per_kwh': pricePerKwh,
      };

      final response = await _apiClient.post(
        ApiEndpoints.createConsumerOffer,
        data: requestData,
      );

      if (response.data['status'] == true) {
        return ConsumerOffer.fromBackendJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw ApiException(
          message: response.data['message'] ?? 'Error al crear oferta',
          statusCode: response.statusCode,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Error inesperado al crear oferta: $e',
        statusCode: 500,
      );
    }
  }

  // ============================================================================
  // ACTUALIZACIÓN (PUT)
  // ============================================================================

  /// Actualiza una oferta existente (solo si está en estado pending)
  ///
  /// PUT /consumer-offers/{offer_id}
  ///
  /// [offerId] - ID de la oferta a actualizar
  /// [pdePercentageRequested] - Nuevo porcentaje del PDE (opcional)
  /// [pricePerKwh] - Nuevo precio por kWh (opcional)
  ///
  /// Retorna la oferta actualizada o lanza ApiException
  Future<ConsumerOffer> updateOffer({
    required int offerId,
    double? pdePercentageRequested,
    double? pricePerKwh,
  }) async {
    try {
      final requestData = <String, dynamic>{};

      if (pdePercentageRequested != null) {
        requestData['pde_percentage_requested'] = pdePercentageRequested;
      }

      if (pricePerKwh != null) {
        requestData['price_per_kwh'] = pricePerKwh;
      }

      if (requestData.isEmpty) {
        throw ApiException(
          message: 'Debe proporcionar al menos un campo para actualizar',
          statusCode: 400,
        );
      }

      final response = await _apiClient.put(
        ApiEndpoints.updateConsumerOffer(offerId),
        data: requestData,
      );

      if (response.data['status'] == true) {
        return ConsumerOffer.fromBackendJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw ApiException(
          message: response.data['message'] ?? 'Error al actualizar oferta',
          statusCode: response.statusCode,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Error inesperado al actualizar oferta: $e',
        statusCode: 500,
      );
    }
  }

  // ============================================================================
  // CANCELACIÓN (DELETE)
  // ============================================================================

  /// Cancela una oferta existente (solo si está en estado pending)
  ///
  /// DELETE /consumer-offers/{offer_id}/cancel
  ///
  /// [offerId] - ID de la oferta a cancelar
  ///
  /// Retorna true si se canceló exitosamente o lanza ApiException
  Future<bool> cancelOffer(int offerId) async {
    try {
      final response = await _apiClient.delete(
        ApiEndpoints.cancelConsumerOffer(offerId),
      );

      if (response.data['status'] == true) {
        return response.data['data']['success'] == true;
      } else {
        throw ApiException(
          message: response.data['message'] ?? 'Error al cancelar oferta',
          statusCode: response.statusCode,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Error inesperado al cancelar oferta: $e',
        statusCode: 500,
      );
    }
  }

  // ============================================================================
  // LIQUIDACIÓN (POST - Admin only)
  // ============================================================================

  /// Liquida una oferta (solo para administradores)
  ///
  /// POST /consumer-offers/{offer_id}/liquidate
  ///
  /// [offerId] - ID de la oferta a liquidar
  /// [liquidationSessionId] - ID de la sesión de liquidación
  ///
  /// Retorna true si se liquidó exitosamente o lanza ApiException
  Future<bool> liquidateOffer(int offerId, int liquidationSessionId) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.liquidateConsumerOffer(offerId),
        data: {'liquidation_session_id': liquidationSessionId},
      );

      if (response.data['status'] == true) {
        return response.data['data']['success'] == true;
      } else {
        throw ApiException(
          message: response.data['message'] ?? 'Error al liquidar oferta',
          statusCode: response.statusCode,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Error inesperado al liquidar oferta: $e',
        statusCode: 500,
      );
    }
  }

  // ============================================================================
  // UTILIDADES
  // ============================================================================

  /// Verifica si un comprador tiene una oferta para un período específico
  ///
  /// [buyerId] - ID del comprador
  /// [period] - Período en formato YYYY-MM
  ///
  /// Retorna true si tiene oferta, false si no
  Future<bool> hasOfferForPeriod(int buyerId, String period) async {
    try {
      final offers = await getBuyerOffers(buyerId);
      return offers.any((offer) => offer.period == period && offer.status == ConsumerOfferStatus.pending);
    } catch (e) {
      return false;
    }
  }

  /// Obtiene la oferta de un comprador para un período específico
  ///
  /// [buyerId] - ID del comprador
  /// [period] - Período en formato YYYY-MM
  ///
  /// Retorna la oferta o null si no existe
  Future<ConsumerOffer?> getBuyerOfferForPeriod(int buyerId, String period) async {
    try {
      final offers = await getBuyerOffers(buyerId);
      return offers.firstWhere(
        (offer) => offer.period == period,
        orElse: () => throw Exception('No encontrada'),
      );
    } catch (e) {
      return null;
    }
  }
}
