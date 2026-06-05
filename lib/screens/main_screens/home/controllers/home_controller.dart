import 'package:be_energy/models/community_price_reference.dart';
import 'package:be_energy/models/consumer_offer.dart';
import 'package:be_energy/models/my_user.dart';
import 'package:be_energy/models/pde_period_status.dart';
import 'package:be_energy/models/pde_renuncia.dart';
import 'package:be_energy/models/user_period_history.dart';
import 'package:be_energy/repositories/domain/pde_period_repository.dart';
import 'package:be_energy/repositories/impl/pde_period_repository_api.dart';
import 'package:be_energy/services/consumer_offer_api_service.dart';
import 'package:be_energy/services/community_price_reference_service.dart';
import 'package:be_energy/services/pde_renuncia_service.dart';
import 'package:flutter/foundation.dart';

class HomeController extends ChangeNotifier {
  final CommunityPriceReferenceService _priceReferenceService;
  final PDEPeriodRepository _pdePeriodRepository;
  final ConsumerOfferApiService _consumerOfferService;
  final PdeRenunciaService _pdeRenunciaService;

  HomeController({
    CommunityPriceReferenceService? priceReferenceService,
    PDEPeriodRepository? pdePeriodRepository,
    ConsumerOfferApiService? consumerOfferService,
    PdeRenunciaService? pdeRenunciaService,
  })  : _priceReferenceService =
            priceReferenceService ?? CommunityPriceReferenceService(),
        _pdePeriodRepository = pdePeriodRepository ?? PDEPeriodRepositoryApi(),
        _consumerOfferService =
            consumerOfferService ?? ConsumerOfferApiService(),
        _pdeRenunciaService = pdeRenunciaService ?? PdeRenunciaService();

  String selectedPeriod = '';
  bool isAdminView = false;

  PDEPeriodStatus? pdePeriodStatus;
  UserPeriodHistory? userPeriodHistory;
  ConsumerOffer? buyerOffer;
  PdeRenunciaStatus? pdeRenunciaStatus;

  bool isLoadingPDEStatus = false;
  bool isLoadingPeriods = false;
  bool isLoadingBuyerOffer = false;
  bool isLoadingPdeRenuncia = false;

  List<CommunityPriceReference> priceReferences = [];
  bool isLoadingPriceReferences = false;
  String? priceReferencesError;

  Future<void> initialize({
    required MyUser? user,
    required int communityId,
    required String fallbackPeriod,
    required bool useFakeData,
  }) async {
    selectedPeriod = fallbackPeriod;
    await loadUserPeriods(
      user: user,
      communityId: communityId,
      useFakeData: useFakeData,
    );
    await loadPDEPeriodStatus(
      user: user,
      communityId: communityId,
    );
  }

  Future<void> loadUserPeriods({
    required MyUser? user,
    required int communityId,
    required bool useFakeData,
  }) async {
    if (useFakeData) {
      isLoadingPeriods = false;
      notifyListeners();
      return;
    }

    isLoadingPeriods = true;
    notifyListeners();

    try {
      final history = await _pdePeriodRepository.getUserPeriodHistory(
        userId: user?.idUser ?? 1,
        communityId: communityId,
        limit: 4,
      );

      userPeriodHistory = history;
      selectedPeriod = history.currentPeriod;
    } finally {
      isLoadingPeriods = false;
      notifyListeners();
    }
  }

  Future<void> loadPDEPeriodStatus({
    required MyUser? user,
    required int communityId,
  }) async {
    isLoadingPDEStatus = true;
    notifyListeners();

    try {
      pdePeriodStatus = await _pdePeriodRepository.getPeriodStatus(
        communityId: communityId,
        period: selectedPeriod,
      );
    } finally {
      isLoadingPDEStatus = false;
      notifyListeners();
    }

    if (pdePeriodStatus?.statusCode == 6) {
      await loadPdeRenunciaStatus(user: user, communityId: communityId);
    } else {
      pdeRenunciaStatus = null;
      await loadBuyerOffer(user: user);
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
    notifyListeners();

    try {
      pdeRenunciaStatus = await _pdeRenunciaService.getUserStatus(
        comunidadId: communityId,
        usuarioId: userId,
        periodo: selectedPeriod,
      );
    } finally {
      isLoadingPdeRenuncia = false;
      notifyListeners();
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
    notifyListeners();

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
      notifyListeners();
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
    notifyListeners();

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
      notifyListeners();
    }
  }

  Future<void> loadBuyerOffer({required MyUser? user}) async {
    final userId = user?.idUser;
    if (userId == null) {
      buyerOffer = null;
      return;
    }

    isLoadingBuyerOffer = true;
    notifyListeners();

    try {
      buyerOffer = await _consumerOfferService.getBuyerOfferForPeriod(
        userId,
        selectedPeriod,
      );
    } finally {
      isLoadingBuyerOffer = false;
      notifyListeners();
    }
  }

  Future<void> changePeriod({
    required String period,
    required MyUser? user,
    required int communityId,
    required bool shouldLoadPriceReferences,
  }) async {
    selectedPeriod = period;
    notifyListeners();

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
    notifyListeners();
    return updatedStatus;
  }

  void toggleAdminView() {
    isAdminView = !isAdminView;
    notifyListeners();
  }

  Future<void> loadPriceReferences({
    required int communityId,
    required String period,
  }) async {
    isLoadingPriceReferences = true;
    priceReferencesError = null;
    notifyListeners();

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
      notifyListeners();
    }
  }
}
