import '../../models/consumer_offer.dart';

/// Repositorio abstracto para operaciones de ofertas de consumidores.
///
/// Define el contrato para obtener y gestionar ofertas PDE de consumidores
/// desde el backend.
abstract class ConsumerOfferRepository {
  /// Obtiene todas las ofertas de una comunidad en un período específico.
  ///
  /// Retorna ofertas con información completa del comprador (JOINs con users, roles, energy_records).
  ///
  /// [communityId]: ID de la comunidad energética
  /// [period]: Periodo en formato YYYY-MM
  ///
  /// Returns: Lista de [ConsumerOffer] con información completa del comprador
  Future<List<ConsumerOffer>> getCommunityPeriodOffers({
    required int communityId,
    required String period,
  });

  /// Obtiene una oferta por su ID.
  ///
  /// [offerId]: ID de la oferta
  ///
  /// Returns: [ConsumerOffer] o null si no existe
  Future<ConsumerOffer?> getOfferById(int offerId);

  /// Crea una nueva oferta de consumidor.
  ///
  /// [offer]: Datos de la oferta a crear
  ///
  /// Returns: [ConsumerOffer] creada con ID asignado
  Future<ConsumerOffer> createOffer(ConsumerOffer offer);

  /// Actualiza una oferta existente (solo si está pendiente).
  ///
  /// [offerId]: ID de la oferta
  /// [pdePercentageRequested]: Nuevo porcentaje solicitado (opcional)
  /// [pricePerKwh]: Nuevo precio por kWh (opcional)
  ///
  /// Returns: [ConsumerOffer] actualizada
  Future<ConsumerOffer> updateOffer({
    required int offerId,
    double? pdePercentageRequested,
    double? pricePerKwh,
  });

  /// Cancela una oferta.
  ///
  /// [offerId]: ID de la oferta
  ///
  /// Returns: true si se canceló exitosamente
  Future<bool> cancelOffer(int offerId);
}
