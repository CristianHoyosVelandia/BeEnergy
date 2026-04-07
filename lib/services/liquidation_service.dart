/// Servicio de Liquidación P2P (Enero 2026+)
///
/// Gestiona el proceso de liquidación manual donde el administrador
/// hace matching entre ofertas de consumidores y energía disponible de prosumidores.
///
/// Flujo:
/// 1. Admin crea sesión → calcula PDE disponible
/// 2. Admin ve ofertas y energía disponible
/// 3. Admin hace matching manual (uno a uno)
/// 4. Admin finaliza → se generan contratos P2P
library;

import '../core/utils/logger.dart';
import '../models/consumer_offer.dart';
import '../models/liquidation_session.dart';
import '../models/p2p_models.dart';
import '../models/energy_models.dart';
import '../models/regulatory_models.dart';
import 'consumer_offer_service.dart';
import 'p2p_service.dart';

class LiquidationService {
  final ConsumerOfferService _consumerOfferService;
  final P2PService _p2pService;

  // Almacenamiento en memoria
  final List<LiquidationSession> _sessions = [];
  final Map<String, PDEAvailabilitySnapshot> _pdeSnapshots = {};

  int _nextSessionId = 1;

  LiquidationService({
    required ConsumerOfferService consumerOfferService,
    required P2PService p2pService,
  })  : _consumerOfferService = consumerOfferService,
        _p2pService = p2pService;

  // ============================================================================
  // CREACIÓN DE SESIÓN
  // ============================================================================

  /// Crea una nueva sesión de liquidación
  ///
  /// 1. Calcula PDE disponible para el período
  /// 2. Identifica ofertas de consumidores pendientes
  /// 3. Crea sesión en estado draft
  Future<LiquidationSession> createSession({
    required String period,
    required int communityId,
    required int adminUserId,
    LiquidationMode mode = LiquidationMode.manual,
  }) async {
    // 1. Calcular disponibilidad de PDE
    final pdeSnapshot = await calculatePDEAvailability(period);

    // 2. Obtener ofertas pendientes
    final pendingOffers = _consumerOfferService.getPendingOffers(period);
    final offerIds = pendingOffers.map((o) => o.id).toList();

    // 3. Crear sesión
    final session = LiquidationSession(
      id: _nextSessionId++,
      period: period,
      communityId: communityId,
      adminUserId: adminUserId,
      mode: mode,
      status: LiquidationStatus.draft,
      totalPDEAvailable: pdeSnapshot.pdeAvailableForLiquidation,
      consumerOfferIds: offerIds,
      matches: [],
      createdAt: DateTime.now(),
    );

    // 4. Guardar sesión
    _sessions.add(session);

    // 5. Guardar snapshot de PDE
    _pdeSnapshots[period] = pdeSnapshot;

    return session;
  }

  // ============================================================================
  // MATCHING MANUAL
  // ============================================================================

  /// Crea un matching manual entre oferta de consumidor y prosumidor
  ///
  /// Validaciones:
  /// - Sesión existe y está activa
  /// - Oferta existe y está pending
  /// - Prosumidor tiene energía disponible
  /// - Energía asignada no excede disponibilidad
  Future<LiquidationMatch> createManualMatch({
    required int sessionId,
    required int consumerOfferId,
    required int prosumerId,
    required String prosumerName,
    required double energyKwh, // Admin decide cuánto
  }) async {
    // 1. Buscar sesión
    final sessionIndex = _sessions.indexWhere((s) => s.id == sessionId);
    if (sessionIndex == -1) {
      throw Exception('Sesión no encontrada');
    }

    final session = _sessions[sessionIndex];

    // 2. Validar que la sesión esté activa
    if (!session.isActive) {
      throw Exception('Sesión no está activa (${session.status.displayName})');
    }

    // 3. Buscar oferta de consumidor
    final offer = _consumerOfferService.getOfferById(consumerOfferId);
    if (offer == null) {
      throw Exception('Oferta de consumidor no encontrada');
    }

    // 4. Validar que la oferta esté pending
    if (offer.status != ConsumerOfferStatus.pending) {
      throw Exception('Oferta no está pending (${offer.status.displayName})');
    }

    // 5. Validar energía solicitada
    if (energyKwh <= 0) {
      throw Exception('Energía debe ser mayor a 0 kWh');
    }

    if (energyKwh > session.totalPDEAvailable) {
      throw Exception(
        'Energía asignada ($energyKwh kWh) excede PDE disponible (${session.totalPDEAvailable} kWh)',
      );
    }

    // 6. Calcular % de PDE cumplido
    final energyRequested = offer.calculateEnergyKwh(session.totalPDEAvailable);
    final pdePercentageFulfilled = energyRequested > 0
        ? (energyKwh / energyRequested).clamp(0.0, 1.0)
        : 0.0;

    // 7. Crear match
    final match = LiquidationMatch(
      consumerOfferId: consumerOfferId,
      buyerId: offer.buyerId,
      buyerName: offer.buyerName,
      prosumerId: prosumerId,
      prosumerName: prosumerName,
      energyKwh: energyKwh,
      pricePerKwh: offer.pricePerKwh,
      pdePercentageFulfilled: pdePercentageFulfilled,
      matchedAt: DateTime.now(),
    );

    // 8. Actualizar sesión
    final updatedMatches = [...session.matches, match];
    final updatedSession = session.copyWith(
      matches: updatedMatches,
      status: LiquidationStatus.inProgress,
    );

    _sessions[sessionIndex] = updatedSession;

    return match;
  }

  // ============================================================================
  // CÁLCULO DE DISPONIBILIDAD PDE
  // ============================================================================

  /// Calcula la disponibilidad de PDE para un período
  ///
  /// Considera:
  /// - Total Tipo 2 de todos los prosumidores
  /// - PDE máximo permitido (10%)
  /// - PDE ya asignado en liquidaciones anteriores
  Future<PDEAvailabilitySnapshot> calculatePDEAvailability(
    String period, {
    List<EnergyRecord>? energyRecords,
    List<PDEAllocation>? pdeAllocations,
  }) async {
    // Por ahora usamos valores simulados
    // En producción, estos vendrían de los repositorios

    // TODO: Integrar con datos reales cuando esté disponible
    // final records = energyRecords ?? await _energyRepository.getRecords(period);
    // final allocations = pdeAllocations ?? await _pdeRepository.getAllocations(period);

    // MOCK: Valores de ejemplo basados en fake_data_phase2
    final totalType2 = 70.0; // kWh (del prosumidor María)
    final pdeMaxAllowed = totalType2 * 0.10; // 7 kWh
    final pdeAlreadyAllocated = 0.0; // Sin asignación previa
    final pdeAvailable = pdeMaxAllowed - pdeAlreadyAllocated;

    final prosumerContributions = <int, double>{
      24: 7.0, // María García contribuye 7 kWh
    };

    return PDEAvailabilitySnapshot(
      period: period,
      totalType2: totalType2,
      pdeMaxAllowed: pdeMaxAllowed,
      pdeAlreadyAllocated: pdeAlreadyAllocated,
      pdeAvailableForLiquidation: pdeAvailable,
      prosumerContributions: prosumerContributions,
    );
  }

  // ============================================================================
  // FINALIZACIÓN DE LIQUIDACIÓN
  // ============================================================================

  /// Finaliza la sesión de liquidación y genera contratos P2P
  ///
  /// 1. Valida que la sesión pueda finalizarse
  /// 2. Genera un contrato P2P por cada match
  /// 3. Actualiza ofertas de consumidores a matched
  /// 4. Marca sesión como completed
  Future<List<P2PContract>> finalizeLiquidation(int sessionId) async {
    // 1. Buscar sesión
    final sessionIndex = _sessions.indexWhere((s) => s.id == sessionId);
    if (sessionIndex == -1) {
      throw Exception('Sesión no encontrada');
    }

    final session = _sessions[sessionIndex];

    // 2. Validar que puede finalizarse
    if (!session.canFinalize) {
      throw Exception('Sesión no puede finalizarse (${session.status.displayName})');
    }

    if (session.matches.isEmpty) {
      throw Exception('No hay matches para finalizar');
    }

    // 3. Generar contratos P2P para cada match
    final contracts = <P2PContract>[];

    for (final match in session.matches) {
      try {
        // Crear contrato usando P2PService
        final contract = await _p2pService.createContractFromLiquidation(
          match: match,
          period: session.period,
        );

        contracts.add(contract);

        // Actualizar oferta de consumidor
        final isPartial = match.pdePercentageFulfilled < 1.0;
        await _consumerOfferService.markAsMatched(
          offerId: match.consumerOfferId,
          energyKwh: match.energyKwh,
          prosumerId: match.prosumerId,
          liquidationSessionId: sessionId,
          isPartial: isPartial,
        );
      } catch (e) {
        // Si falla algún contrato, registrar pero continuar
        AppLogger.error('Error creando contrato para match ${match.consumerOfferId}', tag: 'LiquidationService', error: e);
      }
    }

    // 4. Calcular estadísticas
    final totalEnergyMatched = session.matches.fold(
      0.0,
      (sum, m) => sum + m.energyKwh,
    );

    final matchingEfficiency = session.consumerOfferIds.isNotEmpty
        ? session.matches.length / session.consumerOfferIds.length
        : 0.0;

    // 5. Actualizar sesión a completed
    final updatedSession = session.copyWith(
      status: LiquidationStatus.completed,
      completedAt: DateTime.now(),
      totalOffersProcessed: session.consumerOfferIds.length,
      totalMatchesCreated: session.matches.length,
      totalEnergyMatched: totalEnergyMatched,
      matchingEfficiency: matchingEfficiency,
    );

    _sessions[sessionIndex] = updatedSession;

    return contracts;
  }

  // ============================================================================
  // CONSULTAS
  // ============================================================================

  /// Obtiene una sesión por ID
  LiquidationSession? getSessionById(int sessionId) {
    try {
      return _sessions.firstWhere((s) => s.id == sessionId);
    } catch (e) {
      return null;
    }
  }

  /// Obtiene todas las sesiones para un período
  List<LiquidationSession> getSessionsByPeriod(String period) {
    return _sessions
        .where((s) => s.period == period)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Obtiene la sesión activa para un período (si existe)
  LiquidationSession? getActiveSession(String period) {
    try {
      return _sessions.firstWhere(
        (s) => s.period == period && s.isActive,
      );
    } catch (e) {
      return null;
    }
  }

  /// Obtiene resumen de una sesión
  Map<String, dynamic> getSessionSummary(int sessionId) {
    final session = getSessionById(sessionId);
    if (session == null) {
      throw Exception('Sesión no encontrada');
    }

    final offersSatisfied = session.matches
        .where((m) => m.pdePercentageFulfilled >= 1.0)
        .length;

    final offersPartial = session.matches
        .where((m) => m.pdePercentageFulfilled < 1.0)
        .length;

    return {
      'sessionId': session.id,
      'period': session.period,
      'status': session.status.displayName,
      'totalOffers': session.consumerOfferIds.length,
      'totalMatches': session.matches.length,
      'offersSatisfied': offersSatisfied,
      'offersPartial': offersPartial,
      'totalEnergyMatched': session.totalEnergyMatched,
      'totalValue': session.totalValue,
      'matchingEfficiency': session.matchingEfficiency * 100,
      'createdAt': session.createdAt,
      'completedAt': session.completedAt,
    };
  }

  /// Obtiene snapshot de PDE para un período
  PDEAvailabilitySnapshot? getPDESnapshot(String period) {
    return _pdeSnapshots[period];
  }

  // ============================================================================
  // VALIDACIONES
  // ============================================================================

  /// Valida que el PDE total no exceda el 10% regulatorio
  ValidationResult validateTotalPDEAllocation({
    required double totalAllocated,
    required double totalType2,
  }) {
    final percentage = (totalAllocated / totalType2) * 100;
    if (percentage > 10.0) {
      return ValidationResult.violation(
        message: 'PDE total ($percentage%) excede límite regulatorio (10%)',
        regulationArticle: 'CREG 101 072 Art 3.4',
      );
    }
    return ValidationResult.success(
      message: 'PDE cumple límite: $percentage% <= 10%',
      regulationArticle: 'CREG 101 072 Art 3.4',
    );
  }

  // ============================================================================
  // CANCELACIÓN
  // ============================================================================

  /// Cancela una sesión de liquidación
  Future<void> cancelSession(int sessionId, String reason) async {
    final sessionIndex = _sessions.indexWhere((s) => s.id == sessionId);
    if (sessionIndex == -1) {
      throw Exception('Sesión no encontrada');
    }

    final session = _sessions[sessionIndex];

    if (session.status == LiquidationStatus.completed) {
      throw Exception('No se puede cancelar una sesión completada');
    }

    final updatedSession = session.copyWith(
      status: LiquidationStatus.cancelled,
    );

    _sessions[sessionIndex] = updatedSession;
  }

  // ============================================================================
  // MÉTODOS DE INICIALIZACIÓN (para testing)
  // ============================================================================

  /// Inicializa el servicio con datos fake
  void initializeWithFakeData(List<LiquidationSession> sessions) {
    _sessions.clear();
    _sessions.addAll(sessions);

    if (sessions.isNotEmpty) {
      _nextSessionId =
          sessions.map((s) => s.id).reduce((a, b) => a > b ? a : b) + 1;
    }
  }

  /// Limpia todos los datos (para testing)
  void clearAll() {
    _sessions.clear();
    _pdeSnapshots.clear();
    _nextSessionId = 1;
  }

  /// Obtiene todas las sesiones (para debugging)
  List<LiquidationSession> getAllSessionsDebug() => List.from(_sessions);
}
