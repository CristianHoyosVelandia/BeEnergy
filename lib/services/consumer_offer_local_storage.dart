/// Servicio de Almacenamiento Local para Ofertas de Consumidores
///
/// Maneja la persistencia de ofertas en local usando SharedPreferences.
/// Almacena: PDE percentage, precio, y período.
///
/// TODO: Reemplazar con llamadas a Web Service cuando el backend esté disponible.
library;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/consumer_offer.dart';

class ConsumerOfferLocalStorage {
  static const String _keyPrefix = 'consumer_offers_';
  static const String _keyCurrentPeriod = 'current_period_offer_';

  /// Guarda una oferta en almacenamiento local
  ///
  /// Almacena datos clave:
  /// - PDE percentage requested
  /// - Precio por kWh
  /// - Período
  Future<void> saveOffer(ConsumerOffer offer) async {
    final prefs = await SharedPreferences.getInstance();

    // Guardar oferta completa en formato JSON
    final offerKey = '$_keyPrefix${offer.buyerId}_${offer.period}';
    final offerJson = jsonEncode(offer.toJson());
    await prefs.setString(offerKey, offerJson);

    // Guardar referencia de oferta actual para periodo actual
    final currentOfferKey = '$_keyCurrentPeriod${offer.buyerId}';
    await prefs.setString(currentOfferKey, offer.period);
  }

  /// Obtiene una oferta por buyerId y período
  Future<ConsumerOffer?> getOffer(int buyerId, String period) async {
    final prefs = await SharedPreferences.getInstance();
    final offerKey = '$_keyPrefix${buyerId}_$period';
    final offerJsonString = prefs.getString(offerKey);

    if (offerJsonString == null) return null;

    try {
      final offerJson = jsonDecode(offerJsonString) as Map<String, dynamic>;
      return ConsumerOffer.fromJson(offerJson);
    } catch (e) {
      // Error al parsear, retornar null
      return null;
    }
  }

  /// Verifica si existe una oferta para un buyerId y período específicos
  Future<bool> hasOfferForPeriod(int buyerId, String period) async {
    final offer = await getOffer(buyerId, period);
    return offer != null && offer.status == ConsumerOfferStatus.pending;
  }

  /// Obtiene todas las ofertas de un comprador
  Future<List<ConsumerOffer>> getBuyerOffers(int buyerId) async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();

    final offerKeys = allKeys
        .where((key) => key.startsWith('$_keyPrefix$buyerId'))
        .toList();

    final offers = <ConsumerOffer>[];

    for (final key in offerKeys) {
      final offerJsonString = prefs.getString(key);
      if (offerJsonString != null) {
        try {
          final offerJson = jsonDecode(offerJsonString) as Map<String, dynamic>;
          offers.add(ConsumerOffer.fromJson(offerJson));
        } catch (e) {
          // Ignorar ofertas con errores de parsing
          continue;
        }
      }
    }

    // Ordenar por fecha de creación (más recientes primero)
    offers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return offers;
  }

  /// Actualiza el estado de una oferta
  Future<void> updateOfferStatus(
    int buyerId,
    String period,
    ConsumerOfferStatus newStatus,
  ) async {
    final offer = await getOffer(buyerId, period);
    if (offer == null) return;

    final updatedOffer = offer.copyWith(status: newStatus);
    await saveOffer(updatedOffer);
  }

  /// Elimina una oferta del almacenamiento local
  Future<void> deleteOffer(int buyerId, String period) async {
    final prefs = await SharedPreferences.getInstance();
    final offerKey = '$_keyPrefix${buyerId}_$period';
    await prefs.remove(offerKey);

    // Limpiar referencia de oferta actual si corresponde
    final currentOfferKey = '$_keyCurrentPeriod$buyerId';
    final currentPeriod = prefs.getString(currentOfferKey);
    if (currentPeriod == period) {
      await prefs.remove(currentOfferKey);
    }
  }

  /// Limpia todas las ofertas de un comprador (útil para testing)
  Future<void> clearBuyerOffers(int buyerId) async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();

    final offerKeys = allKeys
        .where((key) =>
            key.startsWith('$_keyPrefix$buyerId') ||
            key.startsWith('$_keyCurrentPeriod$buyerId'))
        .toList();

    for (final key in offerKeys) {
      await prefs.remove(key);
    }
  }

  /// Limpia todo el almacenamiento de ofertas (útil para testing)
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();

    final offerKeys = allKeys
        .where((key) =>
            key.startsWith(_keyPrefix) ||
            key.startsWith(_keyCurrentPeriod))
        .toList();

    for (final key in offerKeys) {
      await prefs.remove(key);
    }
  }

  /// Obtiene estadísticas de ofertas almacenadas localmente
  Future<Map<String, dynamic>> getStorageStats() async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();

    final offerKeys =
        allKeys.where((key) => key.startsWith(_keyPrefix)).toList();

    return {
      'totalOffers': offerKeys.length,
      'storageKeys': offerKeys,
    };
  }
}
