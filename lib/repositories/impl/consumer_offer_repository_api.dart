import '../../core/api/api_client.dart';
import '../../core/utils/logger.dart';
import '../../models/consumer_offer.dart';
import '../domain/consumer_offer_repository.dart';

const String _tag = 'ConsumerOfferRepo';

/// Implementación del repositorio de ofertas de consumidores usando API REST.
///
/// Se conecta a los endpoints:
/// - GET /consumer-offers/community/{community_id}/period/{period}
/// - GET /consumer-offers/{offer_id}
/// - POST /consumer-offers
/// - PUT /consumer-offers/{offer_id}
/// - DELETE /consumer-offers/{offer_id}/cancel
class ConsumerOfferRepositoryApi implements ConsumerOfferRepository {
  @override
  Future<List<ConsumerOffer>> getCommunityPeriodOffers({ required int communityId, required String period, }) async {
    try {
      AppLogger.debug('GET /consumer-offers/community/$communityId/period/$period', tag: _tag);

      // Llamada HTTP GET al endpoint
      final response = await ApiClient.instance.get(
        '/consumer-offers/community/$communityId/period/$period',
      );

      AppLogger.debug('Response: status=${response.statusCode}, count=${(response.data['data'] as List?)?.length ?? 0}', tag: _tag);

      // Validar respuesta exitosa (el backend retorna 'status', no 'success')
      if (response.statusCode == 200 && response.data['status'] == true) {
        final offersData = response.data['data'] as List<dynamic>;

        // Parsear cada oferta usando el factory con buyer info
        final offers = offersData
            .map((json) => ConsumerOffer.fromBackendJsonWithBuyerInfo(json as Map<String, dynamic>))
            .toList();

        AppLogger.info('${offers.length} ofertas parseadas correctamente', tag: _tag);
        return offers;
      } else {
        throw Exception(
          'Error obteniendo ofertas: ${response.statusMessage ?? "Error desconocido"}'
        );
      }
    } catch (e) {
      AppLogger.error('Error obteniendo ofertas', tag: _tag, error: e);
      throw Exception('Error obteniendo ofertas de comunidad: $e');
    }
  }

  @override
  Future<ConsumerOffer?> getOfferById(int offerId) async {
    try {
      AppLogger.debug('GET /consumer-offers/$offerId', tag: _tag);

      final response = await ApiClient.instance.get(
        '/consumer-offers/$offerId',
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        return ConsumerOffer.fromBackendJson(response.data['data']);
      } else {
        return null;
      }
    } catch (e) {
      AppLogger.error('Error obteniendo oferta', tag: _tag, error: e);
      return null;
    }
  }

  @override
  Future<ConsumerOffer> createOffer(ConsumerOffer offer) async {
    try {
      AppLogger.debug('POST /consumer-offers', tag: _tag);

      final response = await ApiClient.instance.post(
        '/consumer-offers',
        data: offer.toBackendJson(),
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        return ConsumerOffer.fromBackendJson(response.data['data']);
      } else {
        throw Exception(
          'Error creando oferta: ${response.statusMessage ?? "Error desconocido"}'
        );
      }
    } catch (e) {
      AppLogger.error('Error creando oferta', tag: _tag, error: e);
      throw Exception('Error creando oferta: $e');
    }
  }

  @override
  Future<ConsumerOffer> updateOffer({
    required int offerId,
    double? pdePercentageRequested,
    double? pricePerKwh,
  }) async {
    try {
      AppLogger.debug('PUT /consumer-offers/$offerId', tag: _tag);

      final data = <String, dynamic>{};
      if (pdePercentageRequested != null) {
        // Convertir de decimal (0.0-1.0) a porcentaje (0.01-99.99)
        data['pde_percentage_requested'] = pdePercentageRequested * 100;
      }
      if (pricePerKwh != null) {
        data['price_per_kwh'] = pricePerKwh;
      }

      final response = await ApiClient.instance.put(
        '/consumer-offers/$offerId',
        data: data,
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        return ConsumerOffer.fromBackendJson(response.data['data']);
      } else {
        throw Exception(
          'Error actualizando oferta: ${response.statusMessage ?? "Error desconocido"}'
        );
      }
    } catch (e) {
      AppLogger.error('Error actualizando oferta', tag: _tag, error: e);
      throw Exception('Error actualizando oferta: $e');
    }
  }

  @override
  Future<bool> cancelOffer(int offerId) async {
    try {
      AppLogger.debug('DELETE /consumer-offers/$offerId/cancel', tag: _tag);

      final response = await ApiClient.instance.delete(
        '/consumer-offers/$offerId/cancel',
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      AppLogger.error('Error cancelando oferta', tag: _tag, error: e);
      return false;
    }
  }
}
