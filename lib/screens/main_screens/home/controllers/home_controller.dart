import 'package:be_energy/models/community_price_reference.dart';
import 'package:be_energy/services/community_price_reference_service.dart';

class HomeController {
  final CommunityPriceReferenceService _priceReferenceService;

  HomeController({CommunityPriceReferenceService? priceReferenceService})
      : _priceReferenceService =
            priceReferenceService ?? CommunityPriceReferenceService();

  List<CommunityPriceReference> priceReferences = [];
  bool isLoadingPriceReferences = false;
  String? priceReferencesError;

  Future<void> loadPriceReferences({
    required int communityId,
    required String period,
  }) async {
    isLoadingPriceReferences = true;
    priceReferencesError = null;

    try {
      // El Home solo necesita precios activos del periodo seleccionado.
      priceReferences = await _priceReferenceService.getPriceReferences(
        communityId: communityId,
        period: period,
      );
    } catch (e) {
      priceReferences = [];
      priceReferencesError = e.toString();
    } finally {
      isLoadingPriceReferences = false;
    }
  }
}
