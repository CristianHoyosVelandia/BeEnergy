/// Servicio de Gestión de Mercado P2P
///
/// Maneja la creación, aceptación y gestión de ofertas P2P
/// según CREG 101 072 de 2025
library;

import '../models/p2p_offer.dart';
import '../models/p2p_models.dart';
import '../models/regulatory_models.dart';
import 'regulatory_validator.dart';

class P2PService {
  final RegulatoryValidator _validator = RegulatoryValidator();

  // Almacenamiento en memoria (simula base de datos)
  final List<P2POffer> _offers = [];
  final List<P2PContract> _contracts = [];
  final List<RegulatoryAuditLog> _auditLogs = [];

  int _nextOfferId = 1;
  int _nextContractId = 1;
  int _nextAuditId = 1;

  // ============================================================================
  // CREACIÓN DE OFERTAS
  // ============================================================================

  /// Crea una nueva oferta P2P
  ///
  /// Validaciones:
  /// - Precio dentro del rango VE ±10%
  /// - Energía disponible suficiente (Tipo 2 - PDE)
  /// - Usuario tiene NIU válido
  ///
  /// Retorna la oferta creada o lanza excepción si hay errores
  Future<P2POffer> createOffer({
    required int sellerId,
    required String sellerName,
    required int communityId,
    required String period,
    required double energyKwh,
    required double pricePerKwh,
    required VECalculation ve,
    required double type2Available, // Tipo 2 - PDE
    String? sellerNIU,
  }) async {
    // 1. Validar NIU del vendedor
    if (sellerNIU != null && sellerNIU.isNotEmpty) {
      final niuValidation = _validator.validateNIU(sellerNIU);
      if (!niuValidation.isValid) {
        throw Exception('NIU inválido: ${niuValidation.message}');
      }
    }

    // 2. Validar precio con VE
    final priceValidation = _validator.validateP2PPrice(pricePerKwh, ve);
    if (!priceValidation.isValid) {
      throw Exception('Precio fuera de rango VE: ${priceValidation.message}');
    }

    // 3. Validar disponibilidad de energía
    if (energyKwh > type2Available) {
      throw Exception(
        'Energía insuficiente. Disponible: $type2Available kWh, '
        'Solicitado: $energyKwh kWh',
      );
    }

    if (energyKwh <= 0) {
      throw Exception('La energía debe ser mayor a 0 kWh');
    }

    // 4. Crear oferta
    final offer = P2POffer(
      id: _nextOfferId++,
      sellerId: sellerId,
      sellerName: sellerName,
      communityId: communityId,
      period: period,
      energyAvailable: energyKwh,
      energyRemaining: energyKwh,
      pricePerKwh: pricePerKwh,
      status: OfferStatus.available,
      createdAt: DateTime.now(),
      validUntil: _getEndOfMonth(period),
    );

    // 5. Guardar oferta
    _offers.add(offer);

    // 6. Auditar acción
    _auditAction(
      userId: sellerId,
      actionType: AuditAction.offerCreated,
      resourceType: 'P2POffer',
      resourceId: offer.id,
      data: {
        'energyKwh': energyKwh,
        'pricePerKwh': pricePerKwh,
        've': ve.totalVE,
        'period': period,
      },
      regulationArticle: 'CREG 101 072 Art 4.2',
      complianceStatus: ComplianceStatus.compliant,
    );

    return offer;
  }

  // ============================================================================
  // ACEPTACIÓN DE OFERTAS
  // ============================================================================

  /// Acepta una oferta P2P y crea un contrato
  ///
  /// Validaciones:
  /// - Oferta existe y está disponible
  /// - Energía solicitada no excede disponible
  /// - Precio sigue siendo válido
  /// - Comprador y vendedor son diferentes
  ///
  /// Retorna el contrato creado
  Future<P2PContract> acceptOffer({
    required int offerId,
    required int buyerId,
    required String buyerName,
    required double energyKwh,
    required VECalculation ve,
    String? buyerNIU,
  }) async {
    // 1. Buscar oferta
    final offerIndex = _offers.indexWhere((o) => o.id == offerId);
    if (offerIndex == -1) {
      throw Exception('Oferta no encontrada');
    }

    final offer = _offers[offerIndex];

    // 2. Validar estado de oferta
    if (!offer.isAvailable) {
      throw Exception('Oferta no disponible (${offer.status.displayName})');
    }

    if (offer.isExpired) {
      throw Exception('Oferta expirada');
    }

    // 3. Validar NIU del comprador
    if (buyerNIU != null && buyerNIU.isNotEmpty) {
      final niuValidation = _validator.validateNIU(buyerNIU);
      if (!niuValidation.isValid) {
        throw Exception('NIU comprador inválido: ${niuValidation.message}');
      }
    }

    // 4. Validar energía solicitada
    final acceptanceValidation = _validator.validateOfferAcceptance(
      offer: offer,
      requestedEnergy: energyKwh,
    );

    if (!acceptanceValidation.isValid) {
      throw Exception('Aceptación inválida: ${acceptanceValidation.message}');
    }

    // 5. Validar que comprador y vendedor sean diferentes
    if (buyerId == offer.sellerId) {
      throw Exception('No puedes comprar tu propia oferta');
    }

    // 6. Crear contrato
    final contract = P2PContract(
      id: _nextContractId++,
      sellerId: offer.sellerId,
      sellerName: offer.sellerName,
      buyerId: buyerId,
      buyerName: buyerName,
      communityId: offer.communityId,
      energyCommitted: energyKwh,
      agreedPrice: offer.pricePerKwh,
      status: 'active',
      createdAt: DateTime.now(),
      period: offer.period,
      calculatedVE: ve.totalVE,
      priceWithinVERange: ve.isPriceWithinRange(offer.pricePerKwh),
    );

    // 7. Actualizar oferta
    final newEnergyRemaining = offer.energyRemaining - energyKwh;
    final newStatus = newEnergyRemaining == 0
        ? OfferStatus.sold
        : OfferStatus.partial;

    final updatedOffer = offer.copyWith(
      energyRemaining: newEnergyRemaining,
      status: newStatus,
    );

    _offers[offerIndex] = updatedOffer;

    // 8. Guardar contrato
    _contracts.add(contract);

    // 9. Auditar aceptación
    _auditAction(
      userId: buyerId,
      actionType: AuditAction.offerAccepted,
      resourceType: 'P2POffer',
      resourceId: offer.id,
      data: {
        'seller': offer.sellerName,
        'buyer': buyerName,
        'energyKwh': energyKwh,
        'price': offer.pricePerKwh,
      },
      regulationArticle: 'CREG 101 072 Art 4.3',
      complianceStatus: ComplianceStatus.compliant,
    );

    // 10. Auditar contrato ejecutado
    _auditAction(
      userId: buyerId,
      actionType: AuditAction.contractExecuted,
      resourceType: 'P2PContract',
      resourceId: contract.id,
      data: {
        'seller': contract.sellerName,
        'buyer': buyerName,
        'energyCommitted': energyKwh,
        'agreedPrice': offer.pricePerKwh,
        'totalValue': contract.totalValue,
        've': ve.totalVE,
        'priceWithinVERange': contract.priceWithinVERange,
      },
      regulationArticle: 'CREG 101 072 Art 4.3',
      complianceStatus: ComplianceStatus.compliant,
    );

    return contract;
  }

  // ============================================================================
  // CANCELACIÓN DE OFERTAS
  // ============================================================================

  /// Cancela una oferta (solo el vendedor puede cancelar su propia oferta)
  Future<void> cancelOffer({
    required int offerId,
    required int sellerId,
    String? reason,
  }) async {
    final offerIndex = _offers.indexWhere((o) => o.id == offerId);
    if (offerIndex == -1) {
      throw Exception('Oferta no encontrada');
    }

    final offer = _offers[offerIndex];

    // Validar que sea el vendedor quien cancela
    if (offer.sellerId != sellerId) {
      throw Exception('Solo el vendedor puede cancelar su oferta');
    }

    // Validar que la oferta esté disponible o parcial
    if (offer.status != OfferStatus.available &&
        offer.status != OfferStatus.partial) {
      throw Exception('No se puede cancelar oferta en estado ${offer.status.displayName}');
    }

    // Actualizar estado
    final updatedOffer = offer.copyWith(status: OfferStatus.cancelled);
    _offers[offerIndex] = updatedOffer;

    // Auditar
    _auditAction(
      userId: sellerId,
      actionType: AuditAction.offerCreated, // Reutilizamos este tipo
      resourceType: 'P2POffer',
      resourceId: offerId,
      data: {
        'action': 'cancelled',
        'reason': reason ?? 'Sin razón especificada',
        'energyRemaining': offer.energyRemaining,
      },
      regulationArticle: 'CREG 101 072 Art 4.2',
      complianceStatus: ComplianceStatus.compliant,
    );
  }

  // ============================================================================
  // CONSULTAS
  // ============================================================================

  /// Obtiene todas las ofertas disponibles para un período
  List<P2POffer> getAvailableOffers(String period) {
    return _offers
        .where((o) => o.period == period && o.isAvailable)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Más recientes primero
  }

  /// Obtiene ofertas de un vendedor específico
  List<P2POffer> getSellerOffers(int sellerId, String period) {
    return _offers
        .where((o) => o.sellerId == sellerId && o.period == period)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Obtiene una oferta por ID
  P2POffer? getOfferById(int offerId) {
    try {
      return _offers.firstWhere((o) => o.id == offerId);
    } catch (e) {
      return null;
    }
  }

  /// Obtiene contratos de un usuario (como comprador o vendedor)
  List<P2PContract> getUserContracts(int userId, String period) {
    return _contracts
        .where((c) =>
            (c.buyerId == userId || c.sellerId == userId) &&
            c.period == period)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Obtiene contratos como vendedor
  List<P2PContract> getSalesContracts(int sellerId, String period) {
    return _contracts
        .where((c) => c.sellerId == sellerId && c.period == period)
        .toList();
  }

  /// Obtiene contratos como comprador
  List<P2PContract> getPurchaseContracts(int buyerId, String period) {
    return _contracts
        .where((c) => c.buyerId == buyerId && c.period == period)
        .toList();
  }

  /// Obtiene registros de auditoría
  List<RegulatoryAuditLog> getAuditLogs({
    int? userId,
    String? period,
    AuditAction? actionType,
  }) {
    var logs = _auditLogs;

    if (userId != null) {
      logs = logs.where((log) => log.userId == userId).toList();
    }

    // Filter by period if provided (assuming audit logs have period in data)
    if (period != null) {
      logs = logs.where((log) {
        final data = log.data;
        return data['period'] == period;
      }).toList();
    }

    if (actionType != null) {
      logs = logs.where((log) => log.actionType == actionType).toList();
    }

    return logs..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // ============================================================================
  // ESTADÍSTICAS
  // ============================================================================

  /// Calcula estadísticas del mercado P2P para un período
  Map<String, dynamic> getMarketStats(String period) {
    final offers = _offers.where((o) => o.period == period).toList();
    final contracts = _contracts.where((c) => c.period == period).toList();

    final totalOffered = offers.fold(
      0.0,
      (sum, o) => sum + o.energyAvailable,
    );

    final totalTraded = contracts.fold(
      0.0,
      (sum, c) => sum + c.energyCommitted,
    );

    final totalValue = contracts.fold(
      0.0,
      (sum, c) => sum + c.totalValue,
    );

    final avgPrice = contracts.isNotEmpty
        ? contracts.fold(0.0, (sum, c) => sum + c.agreedPrice) / contracts.length
        : 0.0;

    return {
      'period': period,
      'totalOffers': offers.length,
      'availableOffers': offers.where((o) => o.isAvailable).length,
      'totalContracts': contracts.length,
      'totalEnergyOffered': totalOffered,
      'totalEnergyTraded': totalTraded,
      'totalValue': totalValue,
      'averagePrice': avgPrice,
      'tradingEfficiency': totalOffered > 0
          ? (totalTraded / totalOffered) * 100
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

  /// Registra una acción en auditoría regulatoria
  void _auditAction({
    required int userId,
    required AuditAction actionType,
    required String resourceType,
    required int resourceId,
    required Map<String, dynamic> data,
    required String regulationArticle,
    required ComplianceStatus complianceStatus,
  }) {
    final auditLog = RegulatoryAuditLog(
      id: _nextAuditId++,
      userId: userId,
      actionType: actionType,
      resourceType: resourceType,
      resourceId: resourceId,
      data: data,
      regulationArticle: regulationArticle,
      complianceStatus: complianceStatus,
      createdAt: DateTime.now(),
    );

    _auditLogs.add(auditLog);
  }

  // ============================================================================
  // MÉTODOS DE INICIALIZACIÓN (para testing)
  // ============================================================================

  /// Inicializa el servicio con datos fake
  void initializeWithFakeData(List<P2POffer> offers, List<P2PContract> contracts) {
    _offers.clear();
    _contracts.clear();
    _auditLogs.clear();

    _offers.addAll(offers);
    _contracts.addAll(contracts);

    if (offers.isNotEmpty) {
      _nextOfferId = offers.map((o) => o.id).reduce((a, b) => a > b ? a : b) + 1;
    }
    if (contracts.isNotEmpty) {
      _nextContractId = contracts.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1;
    }
  }

  /// Limpia todos los datos (para testing)
  void clearAll() {
    _offers.clear();
    _contracts.clear();
    _auditLogs.clear();
    _nextOfferId = 1;
    _nextContractId = 1;
    _nextAuditId = 1;
  }
}
