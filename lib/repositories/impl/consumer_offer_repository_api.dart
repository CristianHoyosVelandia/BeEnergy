import '../../core/api/api_client.dart';
import '../../models/consumer_offer.dart';
import '../domain/consumer_offer_repository.dart';

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
      print('🌐 [ConsumerOfferRepositoryApi] Llamando GET /consumer-offers/community/$communityId/period/$period');

      // Llamada HTTP GET al endpoint
      final response = await ApiClient.instance.get(
        '/consumer-offers/community/$communityId/period/$period',
      );

      print('📡 [ConsumerOfferRepositoryApi] Respuesta recibida:');
      print('   Status code: ${response.statusCode}');
      print('   Status: ${response.data['status']}');
      print('   Data count: ${(response.data['data'] as List?)?.length ?? 0}');

      // Validar respuesta exitosa (el backend retorna 'status', no 'success')
      if (response.statusCode == 200 && response.data['status'] == true) {
        final offersData = response.data['data'] as List<dynamic>;

        // Parsear cada oferta usando el factory con buyer info
        final offers = offersData
            .map((json) => ConsumerOffer.fromBackendJsonWithBuyerInfo(json as Map<String, dynamic>))
            .toList();

        print('✅ [ConsumerOfferRepositoryApi] ${offers.length} ofertas parseadas correctamente');
        return offers;
      } else {
        throw Exception(
          'Error obteniendo ofertas: ${response.statusMessage ?? "Error desconocido"}'
        );
      }
    } catch (e) {
      print('❌ [ConsumerOfferRepositoryApi] Error: $e');
      throw Exception('Error obteniendo ofertas de comunidad: $e');
    }
  }

  @override
  Future<ConsumerOffer?> getOfferById(int offerId) async {
    try {
      print('🌐 [ConsumerOfferRepositoryApi] Llamando GET /consumer-offers/$offerId');

      final response = await ApiClient.instance.get(
        '/consumer-offers/$offerId',
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        return ConsumerOffer.fromBackendJson(response.data['data']);
      } else {
        return null;
      }
    } catch (e) {
      print('❌ [ConsumerOfferRepositoryApi] Error obteniendo oferta: $e');
      return null;
    }
  }

  @override
  Future<ConsumerOffer> createOffer(ConsumerOffer offer) async {
    try {
      print('🌐 [ConsumerOfferRepositoryApi] Llamando POST /consumer-offers');

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
      print('❌ [ConsumerOfferRepositoryApi] Error creando oferta: $e');
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
      print('🌐 [ConsumerOfferRepositoryApi] Llamando PUT /consumer-offers/$offerId');

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
      print('❌ [ConsumerOfferRepositoryApi] Error actualizando oferta: $e');
      throw Exception('Error actualizando oferta: $e');
    }
  }

  @override
  Future<bool> cancelOffer(int offerId) async {
    try {
      print('🌐 [ConsumerOfferRepositoryApi] Llamando DELETE /consumer-offers/$offerId/cancel');

      final response = await ApiClient.instance.delete(
        '/consumer-offers/$offerId/cancel',
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('❌ [ConsumerOfferRepositoryApi] Error cancelando oferta: $e');
      return false;
    }
  }
}
