/// Servicio de Gestión de Ofertas de Consumidores (Enero 2026+)
///
/// Maneja la creación, cancelación y gestión de ofertas P2P creadas por consumidores
/// basadas en porcentajes del PDE.
library;

import '../models/consumer_offer.dart';
import '../models/regulatory_models.dart';
import 'regulatory_validator.dart';
import 'consumer_offer_local_storage.dart';

class ConsumerOfferService {
  final RegulatoryValidator _validator = RegulatoryValidator();
  final ConsumerOfferLocalStorage _localStorage = ConsumerOfferLocalStorage();

  // Almacenamiento en memoria (simula base de datos)
  final List<ConsumerOffer> _offers = [];

  int _nextOfferId = 1;

  // ============================================================================
  // CREACIÓN DE OFERTAS
  // ============================================================================

  /// Crea una nueva oferta de consumidor
  ///
  /// Validaciones:
  /// - Porcentaje de PDE entre 1% y 100%
  /// - Precio en rango VE+10% a Tarifa-Transporte
  /// - Consumidor tiene NIU válido
  /// - Un solo oferta pending por período
  ///
  /// Retorna la oferta creada o lanza excepción si hay errores
  Future<ConsumerOffer> createConsumerOffer({
    required int buyerId,
    required String buyerName,
    required int communityId,
    required String period,
    required double pdePercentageRequested, // 0.01-1.0
    required double pricePerKwh,
    required VECalculation ve,
    required double tarifaMax, // Tarifa total - transporte
    String? buyerNIU,
  }) async {
    // 1. Validar NIU del comprador
    if (buyerNIU != null && buyerNIU.isNotEmpty) {
      final niuValidation = _validator.validateNIU(buyerNIU);
      if (!niuValidation.isValid) {
        throw Exception('NIU inválido: ${niuValidation.message}');
      }
    }

    // 2. Validar porcentaje de PDE
    final pdeValidation = validatePDEPercentage(pdePercentageRequested);
    if (!pdeValidation.isValid) {
      throw Exception('Porcentaje inválido: ${pdeValidation.message}');
    }

    // 3. Validar precio consumidor
    final priceValidation = validateConsumerPrice(
      price: pricePerKwh,
      ve: ve,
      tarifaMax: tarifaMax,
    );
    if (!priceValidation.isValid) {
      throw Exception('Precio fuera de rango: ${priceValidation.message}');
    }

    // 4. Validar unicidad (solo 1 oferta pending por período)
    final unicityValidation = validateSingleOfferPerPeriod(
      buyerId: buyerId,
      period: period,
      existingOffers: _offers,
    );
    if (!unicityValidation.isValid) {
      throw Exception(unicityValidation.message);
    }

    // TODO: validar disponibilidad de PDE en comunidad
    // 5. Validar período no sea pasado
    // final periodValidation = validatePeriodIsNotPast(period);
    // if (!periodValidation.isValid) {
    //   throw Exception(periodValidation.message);
    // }

    // 6. Crear oferta
    final offer = ConsumerOffer(
      id: _nextOfferId++,
      buyerId: buyerId,
      buyerName: buyerName,
      communityId: communityId,
      period: period,
      pdePercentageRequested: pdePercentageRequested,
      pricePerKwh: pricePerKwh,
      energyKwhCalculated: null, // Se calcula en liquidación
      status: ConsumerOfferStatus.pending,
      createdAt: DateTime.now(),
      validUntil: _getEndOfMonth(period),
      buyerNIU: buyerNIU,
    );

    // 7. Guardar oferta en memoria
    _offers.add(offer);

    // 8. Guardar oferta en almacenamiento local
    // TODO: Reemplazar con llamada a Web Service cuando el backend esté disponible
    await _localStorage.saveOffer(offer);

    return offer;
  }

  // ============================================================================
  // CÁLCULOS Y VALIDACIONES
  // ============================================================================

  /// Calcula energía en kWh desde porcentaje de PDE
  double calculateEnergyFromPDE({
    required double pdePercentage,
    required double totalPDEAvailable,
  }) {
    return pdePercentage * totalPDEAvailable;
  }

  /// Valida porcentaje de PDE (debe estar entre 1% y 100%)
  ValidationResult validatePDEPercentage(double percentage) {
    if (percentage < 0.01 || percentage > 1.0) {
      return ValidationResult.violation(
        message: 'El porcentaje debe estar entre 1% y 100%',
        regulationArticle: 'Restricción del sistema',
      );
    }
    return ValidationResult.success(
      message: 'Porcentaje válido: ${(percentage * 100).toStringAsFixed(1)}%',
    );
  }

  /// Valida precio de consumidor (VE+10% a Tarifa-Transporte)
  ValidationResult validateConsumerPrice({
    required double price,
    required VECalculation ve,
    required double tarifaMax,
  }) {
    final minPrice = ve.totalVE * 1.1; // VE + 10%

    if (price < minPrice) {
      return ValidationResult.violation(
        message: 'Precio debe ser al menos VE+10% (${minPrice.toStringAsFixed(0)} COP/kWh)',
        regulationArticle: 'CREG 101 072 - Rango mínimo',
      );
    }

    if (price > tarifaMax) {
      return ValidationResult.violation(
        message: 'Precio no puede exceder Tarifa-Transporte (${tarifaMax.toStringAsFixed(0)} COP/kWh)',
        regulationArticle: 'Restricción tarifaria',
      );
    }

    return ValidationResult.success(
      message: 'Precio válido en rango ${minPrice.toStringAsFixed(0)}-${tarifaMax.toStringAsFixed(0)} COP/kWh',
    );
  }

  /// Valida que el consumidor solo tenga una oferta pending por período
  ValidationResult validateSingleOfferPerPeriod({
    required int buyerId,
    required String period,
    required List<ConsumerOffer> existingOffers,
  }) {
    final existing = existingOffers.where(
      (o) =>
          o.buyerId == buyerId &&
          o.period == period &&
          o.status == ConsumerOfferStatus.pending,
    );

    if (existing.isNotEmpty) {
      return ValidationResult.violation(
        message: 'Ya tienes una oferta pending para este período',
      );
    }
    return ValidationResult.success(message: 'Sin ofertas duplicadas');
  }

  /// Valida que el período no sea pasado
  ValidationResult validatePeriodIsNotPast(String period) {
    final now = DateTime.now();
    final periodDate = DateTime.parse('$period-01');

    if (periodDate.isBefore(DateTime(now.year, now.month, 1))) {
      return ValidationResult.violation(
        message: 'No se pueden crear ofertas para períodos pasados',
      );
    }
    return ValidationResult.success(message: 'Período válido');
  }

  // ============================================================================
  // CANCELACIÓN DE OFERTAS
  // ============================================================================

  /// Cancela una oferta (solo el comprador puede cancelar su propia oferta)
  Future<void> cancelOffer({
    required int offerId,
    required int buyerId,
    String? reason,
  }) async {
    final offerIndex = _offers.indexWhere((o) => o.id == offerId);
    if (offerIndex == -1) {
      throw Exception('Oferta no encontrada');
    }

    final offer = _offers[offerIndex];

    // Validar que sea el comprador quien cancela
    if (offer.buyerId != buyerId) {
      throw Exception('Solo el comprador puede cancelar su oferta');
    }

    // Validar que la oferta esté pending
    if (offer.status != ConsumerOfferStatus.pending) {
      throw Exception(
          'No se puede cancelar oferta en estado ${offer.status.displayName}');
    }

    // Actualizar estado
    final updatedOffer = offer.copyWith(
      status: ConsumerOfferStatus.cancelled,
    );
    _offers[offerIndex] = updatedOffer;
  }

  // ============================================================================
  // ACTUALIZACIÓN TRAS LIQUIDACIÓN
  // ============================================================================

  /// Marca oferta como matched tras liquidación
  Future<void> markAsMatched({
    required int offerId,
    required double energyKwh,
    required int prosumerId,
    required int liquidationSessionId,
    bool isPartial = false,
  }) async {
    final offerIndex = _offers.indexWhere((o) => o.id == offerId);
    if (offerIndex == -1) {
      throw Exception('Oferta no encontrada');
    }

    final offer = _offers[offerIndex];

    final updatedOffer = offer.copyWith(
      status: isPartial
          ? ConsumerOfferStatus.partialMatch
          : ConsumerOfferStatus.matched,
      energyKwhCalculated: energyKwh,
      liquidationSessionId: liquidationSessionId,
      liquidatedAt: DateTime.now(),
      matchedProsumerId: prosumerId,
    );

    _offers[offerIndex] = updatedOffer;
  }

  // ============================================================================
  // CONSULTAS
  // ============================================================================

  /// Verifica si existe una oferta pending para un período específico
  Future<bool> hasOfferForPeriod(int buyerId, String period) async {
    // Verificar en almacenamiento local
    return await _localStorage.hasOfferForPeriod(buyerId, period);
  }

  /// Obtiene la oferta de un comprador para un período específico
  Future<ConsumerOffer?> getBuyerOfferForPeriod(int buyerId, String period) async {
    // Intentar obtener de almacenamiento local
    return await _localStorage.getOffer(buyerId, period);
  }

  /// Obtiene ofertas pendientes de liquidación para un período
  List<ConsumerOffer> getPendingOffers(String period) {
    return _offers
        .where((o) => o.period == period && o.isLiquidatable())
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Más recientes primero
  }

  /// Obtiene ofertas de un comprador específico
  List<ConsumerOffer> getBuyerOffers(int buyerId, String period) {
    return _offers
        .where((o) => o.buyerId == buyerId && o.period == period)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Obtiene una oferta por ID
  ConsumerOffer? getOfferById(int offerId) {
    try {
      return _offers.firstWhere((o) => o.id == offerId);
    } catch (e) {
      return null;
    }
  }

  /// Obtiene todas las ofertas para un período
  List<ConsumerOffer> getAllOffers(String period) {
    return _offers
        .where((o) => o.period == period)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // ============================================================================
  // ESTADÍSTICAS
  // ============================================================================

  /// Calcula estadísticas de ofertas de consumidores para un período
  Map<String, dynamic> getOfferStats(String period) {
    final offers = _offers.where((o) => o.period == period).toList();

    final pendingOffers =
        offers.where((o) => o.status == ConsumerOfferStatus.pending).toList();
    final matchedOffers =
        offers.where((o) => o.status == ConsumerOfferStatus.matched).toList();
    final partialOffers = offers
        .where((o) => o.status == ConsumerOfferStatus.partialMatch)
        .toList();

    final totalPdeRequested = offers.fold(
      0.0,
      (sum, o) => sum + o.pdePercentageRequested,
    );

    final avgPrice = offers.isNotEmpty
        ? offers.fold(0.0, (sum, o) => sum + o.pricePerKwh) / offers.length
        : 0.0;

    return {
      'period': period,
      'totalOffers': offers.length,
      'pendingOffers': pendingOffers.length,
      'matchedOffers': matchedOffers.length,
      'partialOffers': partialOffers.length,
      'totalPDERequested': totalPdeRequested,
      'averagePrice': avgPrice,
      'matchingRate': offers.isNotEmpty
          ? (matchedOffers.length + partialOffers.length) / offers.length
          : 0.0,
    };
  }

  // ============================================================================
  // MÉTODOS PRIVADOS
  // ============================================================================

  /// Calcula el último día del mes para un período 'YYYY-MM'
  DateTime _getEndOfMonth(String period) {
    final parts = period.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);

    // Último día del mes
    final lastDay = DateTime(year, month + 1, 0);
    return DateTime(year, month, lastDay.day, 23, 59, 59);
  }

  // ============================================================================
  // MÉTODOS DE INICIALIZACIÓN (para testing)
  // ============================================================================

  /// Inicializa el servicio con datos fake
  void initializeWithFakeData(List<ConsumerOffer> offers) {
    _offers.clear();
    _offers.addAll(offers);

    if (offers.isNotEmpty) {
      _nextOfferId = offers.map((o) => o.id).reduce((a, b) => a > b ? a : b) + 1;
    }
  }

  /// Limpia todos los datos (para testing)
  void clearAll() {
    _offers.clear();
    _nextOfferId = 1;
  }

  /// Obtiene todas las ofertas (para debugging)
  List<ConsumerOffer> getAllOffersDebug() => List.from(_offers);
}
