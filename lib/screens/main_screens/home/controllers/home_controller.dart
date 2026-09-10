import 'package:be_energy/models/community_price_reference.dart';
import 'package:be_energy/models/consumer_offer.dart';
import 'package:be_energy/models/my_user.dart';
import 'package:be_energy/models/pde_period_status.dart';
import 'package:be_energy/models/pde_eligibility.dart';
import 'package:be_energy/models/pde_renuncia.dart';
import 'package:be_energy/models/user_period_history.dart';
import 'package:be_energy/repositories/domain/pde_period_repository.dart';
import 'package:be_energy/repositories/impl/pde_period_repository_api.dart';
import 'package:be_energy/services/consumer_offer_api_service.dart';
import 'package:be_energy/services/community_price_reference_service.dart';
import 'package:be_energy/services/community_service.dart' as community_config;
import 'package:be_energy/services/pde_eligibility_service.dart';
import 'package:be_energy/services/pde_renuncia_service.dart';
import 'package:flutter/foundation.dart';

class HomeController extends ChangeNotifier {
  static final Map<String, _HomeCacheEntry> _cache = {};

  final CommunityPriceReferenceService _priceReferenceService;
  final PDEPeriodRepository _pdePeriodRepository;
  final ConsumerOfferApiService _consumerOfferService;
  final PdeEligibilityService _pdeEligibilityService;
  final PdeRenunciaService _pdeRenunciaService;
  final community_config.CommunityService _communityService;

  HomeController({
    CommunityPriceReferenceService? priceReferenceService,
    PDEPeriodRepository? pdePeriodRepository,
    ConsumerOfferApiService? consumerOfferService,
    PdeEligibilityService? pdeEligibilityService,
    PdeRenunciaService? pdeRenunciaService,
    community_config.CommunityService? communityService,
  })  : _priceReferenceService =
            priceReferenceService ?? CommunityPriceReferenceService(),
        _pdePeriodRepository = pdePeriodRepository ?? PDEPeriodRepositoryApi(),
        _consumerOfferService =
            consumerOfferService ?? ConsumerOfferApiService(),
        _pdeEligibilityService =
            pdeEligibilityService ?? PdeEligibilityService(),
        _pdeRenunciaService = pdeRenunciaService ?? PdeRenunciaService(),
        _communityService =
            communityService ?? community_config.CommunityService();

  String selectedPeriod = '';
  bool isAdminView = false;

  PDEPeriodStatus? pdePeriodStatus;
  UserPeriodHistory? userPeriodHistory;
  ConsumerOffer? buyerOffer;
  PdeEligibility? pdeEligibility;
  PdeRenunciaStatus? pdeRenunciaStatus;
  Map<int, bool> strategySteps = Map<int, bool>.from(_defaultStrategySteps);

  bool isLoadingPDEStatus = false;
  bool isLoadingEnergyData = false;
  bool isLoadingPeriods = false;
  bool isLoadingBuyerOffer = false;
  bool isLoadingPdeEligibility = false;
  bool isLoadingPdeRenuncia = false;

  List<CommunityPriceReference> priceReferences = [];
  bool isLoadingPriceReferences = false;
  String? priceReferencesError;
  bool _isDisposed = false;
  String? _cacheKey;

  static const Map<int, bool> _defaultStrategySteps = {
    1: true,
    2: true,
    3: true,
    4: true,
    5: true,
    6: true,
    7: true,
  };

  bool isStrategyStepEnabled(int statusCode) {
    return strategySteps[statusCode] ?? true;
  }

  bool _boolFromJson(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value == '1' || value.toLowerCase() == 'true';
    return true;
  }

  void _notify() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> initialize({
    required MyUser? user,
    required int communityId,
    required String fallbackPeriod,
    required bool useFakeData,
    bool forceRefresh = false,
  }) async {
    _cacheKey = '${user?.idUser ?? 0}-$communityId';

    if (!forceRefresh && !useFakeData) {
      final cached = _cache[_cacheKey];
      if (cached != null) {
        _applyCache(cached);
        _notify();
        return;
      }
    }

    selectedPeriod = useFakeData ? fallbackPeriod : '';
    isLoadingEnergyData = !useFakeData;
    _notify();

    await loadUserPeriods(
      user: user,
      communityId: communityId,
      useFakeData: useFakeData,
    );
    await loadCommunityStrategy(
      communityId: communityId,
      useFakeData: useFakeData,
    );
    await loadPDEPeriodStatus(
      user: user,
      communityId: communityId,
    );

    if (!useFakeData && _cacheKey != null) {
      _cache[_cacheKey!] = _HomeCacheEntry(
        selectedPeriod: selectedPeriod,
        pdePeriodStatus: pdePeriodStatus,
        userPeriodHistory: userPeriodHistory,
        buyerOffer: buyerOffer,
        pdeEligibility: pdeEligibility,
        pdeRenunciaStatus: pdeRenunciaStatus,
        strategySteps: strategySteps,
      );
    }
  }

  void _applyCache(_HomeCacheEntry cached) {
    selectedPeriod = cached.selectedPeriod;
    pdePeriodStatus = cached.pdePeriodStatus;
    userPeriodHistory = cached.userPeriodHistory;
    buyerOffer = cached.buyerOffer;
    pdeEligibility = cached.pdeEligibility;
    pdeRenunciaStatus = cached.pdeRenunciaStatus;
    strategySteps = Map<int, bool>.from(cached.strategySteps);
    isLoadingPDEStatus = false;
    isLoadingEnergyData = false;
    isLoadingPeriods = false;
    isLoadingBuyerOffer = false;
    isLoadingPdeEligibility = false;
    isLoadingPdeRenuncia = false;
  }

  Future<void> loadCommunityStrategy({
    required int communityId,
    required bool useFakeData,
  }) async {
    if (useFakeData) {
      strategySteps = Map<int, bool>.from(_defaultStrategySteps);
      return;
    }

    try {
      final data = await _communityService.getCommunityData(communityId);
      strategySteps = {
        1: _boolFromJson(data['strategy_step_available']),
        2: _boolFromJson(data['strategy_step_closed']),
        3: _boolFromJson(data['strategy_step_assigned']),
        4: _boolFromJson(data['strategy_step_reconciliation']),
        5: _boolFromJson(data['strategy_step_historical']),
        6: _boolFromJson(data['strategy_step_contribution']),
        7: _boolFromJson(data['strategy_step_payment']),
      };
    } catch (_) {
      strategySteps = Map<int, bool>.from(_defaultStrategySteps);
    }
    _notify();
  }

  Future<void> loadUserPeriods({
    required MyUser? user,
    required int communityId,
    required bool useFakeData,
  }) async {
    if (useFakeData) {
      isLoadingEnergyData = false;
      isLoadingPeriods = false;
      _notify();
      return;
    }

    isLoadingEnergyData = true;
    isLoadingPeriods = true;
    _notify();

    try {
      final history = await _pdePeriodRepository.getUserPeriodHistory(
        userId: user?.idUser ?? 1,
        communityId: communityId,
        limit: 4,
      );

      userPeriodHistory = history;
      selectedPeriod = history.currentPeriod;
    } finally {
      isLoadingEnergyData = false;
      isLoadingPeriods = false;
      _notify();
    }
  }

  Future<void> loadPDEPeriodStatus({
    required MyUser? user,
    required int communityId,
  }) async {
    isLoadingPDEStatus = true;
    _notify();

    try {
      pdePeriodStatus = await _pdePeriodRepository.getPeriodStatus(
        communityId: communityId,
        period: selectedPeriod,
      );
    } finally {
      isLoadingPDEStatus = false;
      _notify();
    }

    final statusCode = pdePeriodStatus?.statusCode;
    if (statusCode == 1 || statusCode == 6) {
      await loadPdeEligibility(
        communityId: communityId,
        phase: statusCode == 6 ? 'contribution' : 'available',
      );
      await loadBuyerOffer(user: user);
    } else {
      pdeEligibility = null;
      pdeRenunciaStatus = null;
      await loadBuyerOffer(user: user);
    }
  }

  Future<void> loadPdeEligibility({
    required int communityId,
    required String phase,
  }) async {
    if (selectedPeriod.isEmpty) {
      pdeEligibility = null;
      return;
    }

    isLoadingPdeEligibility = true;
    _notify();

    try {
      pdeEligibility = await _pdeEligibilityService.getEligibility(
        communityId: communityId,
        period: selectedPeriod,
        phase: phase,
      );
    } catch (_) {
      pdeEligibility = null;
    } finally {
      isLoadingPdeEligibility = false;
      _notify();
    }
  }

  Future<void> loadPdeRenunciaStatus({
    required MyUser? user,
    required int communityId,
  }) async {
    final userId = user?.idUser;
    if (userId == null) {
      pdeRenunciaStatus = null;
      return;
    }

    isLoadingPdeRenuncia = true;
    _notify();

    try {
      pdeRenunciaStatus = await _pdeRenunciaService.getUserStatus(
        comunidadId: communityId,
        usuarioId: userId,
        periodo: selectedPeriod,
      );
    } finally {
      isLoadingPdeRenuncia = false;
      _notify();
    }
  }

  Future<void> createPdeRenuncia({
    required MyUser? user,
    required int communityId,
    required double pdeRenunciado,
    String? motivo,
  }) async {
    final userId = user?.idUser;
    if (userId == null) {
      throw Exception('Usuario no identificado');
    }

    isLoadingPdeRenuncia = true;
    _notify();

    try {
      await _pdeRenunciaService.createRenuncia(
        comunidadId: communityId,
        usuarioId: userId,
        periodo: selectedPeriod,
        pdeRenunciado: pdeRenunciado,
        motivo: motivo,
      );
      pdeRenunciaStatus = await _pdeRenunciaService.getUserStatus(
        comunidadId: communityId,
        usuarioId: userId,
        periodo: selectedPeriod,
      );
    } finally {
      isLoadingPdeRenuncia = false;
      _notify();
    }
  }

  Future<void> closePdeRenunciaFlow({
    required MyUser? user,
    required int communityId,
  }) async {
    final adminId = user?.idUser;
    if (adminId == null) {
      throw Exception('Administrador no identificado');
    }

    isLoadingPdeRenuncia = true;
    _notify();

    try {
      await _pdeRenunciaService.closeFlow(
        comunidadId: communityId,
        periodo: selectedPeriod,
        adminId: adminId,
      );
      pdePeriodStatus = await _pdePeriodRepository.getPeriodStatus(
        communityId: communityId,
        period: selectedPeriod,
      );
    } finally {
      isLoadingPdeRenuncia = false;
      _notify();
    }
  }

  Future<void> loadBuyerOffer({required MyUser? user}) async {
    final userId = user?.idUser;
    if (userId == null) {
      buyerOffer = null;
      return;
    }

    isLoadingBuyerOffer = true;
    _notify();

    try {
      buyerOffer = await _consumerOfferService.getBuyerOfferForPeriod(
        userId,
        selectedPeriod,
      );
    } finally {
      isLoadingBuyerOffer = false;
      _notify();
    }
  }

  Future<void> changePeriod({
    required String period,
    required MyUser? user,
    required int communityId,
    required bool shouldLoadPriceReferences,
  }) async {
    selectedPeriod = period;
    _notify();

    await loadPDEPeriodStatus(user: user, communityId: communityId);

    if (shouldLoadPriceReferences) {
      await loadPriceReferences(communityId: communityId, period: period);
    }
  }

  Future<PDEPeriodStatus> updatePeriodStatus({
    required int communityId,
    required int newStatusCode,
  }) async {
    final updatedStatus = await _pdePeriodRepository.updatePeriodStatus(
      communityId: communityId,
      period: selectedPeriod,
      newStatusCode: newStatusCode,
    );

    pdePeriodStatus = updatedStatus;
    _notify();
    return updatedStatus;
  }

  void toggleAdminView() {
    isAdminView = !isAdminView;
    _notify();
  }

  Future<void> loadPriceReferences({
    required int communityId,
    required String period,
  }) async {
    isLoadingPriceReferences = true;
    priceReferencesError = null;
    _notify();

    try {
      priceReferences = await _priceReferenceService.getPriceReferences(
        communityId: communityId,
        period: period,
      );
    } catch (e) {
      priceReferences = [];
      priceReferencesError = e.toString();
    } finally {
      isLoadingPriceReferences = false;
      _notify();
    }
  }
}

class _HomeCacheEntry {
  final String selectedPeriod;
  final PDEPeriodStatus? pdePeriodStatus;
  final UserPeriodHistory? userPeriodHistory;
  final ConsumerOffer? buyerOffer;
  final PdeEligibility? pdeEligibility;
  final PdeRenunciaStatus? pdeRenunciaStatus;
  final Map<int, bool> strategySteps;

  const _HomeCacheEntry({
    required this.selectedPeriod,
    required this.pdePeriodStatus,
    required this.userPeriodHistory,
    required this.buyerOffer,
    required this.pdeEligibility,
    required this.pdeRenunciaStatus,
    required this.strategySteps,
  });
}
