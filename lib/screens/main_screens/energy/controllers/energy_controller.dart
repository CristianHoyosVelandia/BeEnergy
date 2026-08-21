import 'package:be_energy/models/my_user.dart';
import 'package:be_energy/models/user_period_history.dart';
import 'package:be_energy/repositories/domain/pde_period_repository.dart';
import 'package:be_energy/repositories/impl/pde_period_repository_api.dart';
import 'package:flutter/foundation.dart';

class EnergyController extends ChangeNotifier {
  final PDEPeriodRepository _repository;

  EnergyController({PDEPeriodRepository? repository})
      : _repository = repository ?? PDEPeriodRepositoryApi();

  bool isLoading = false;
  String? errorMessage;
  UserPeriodHistory? history;

  bool _isDisposed = false;

  UserCurrentSummary? get summary => history?.summary;

  UserPeriodItem? get currentPeriod {
    final loadedHistory = history;
    if (loadedHistory == null) return null;
    return loadedHistory.getPeriodByKey(loadedHistory.currentPeriod);
  }

  Future<void> load({
    required MyUser? user,
    required int communityId,
  }) async {
    final userId = user?.idUser;
    if (userId == null) {
      errorMessage = 'No se pudo identificar el usuario actual.';
      _notify();
      return;
    }

    isLoading = true;
    errorMessage = null;
    _notify();

    try {
      history = await _repository.getUserPeriodHistory(
        userId: userId,
        communityId: communityId,
        limit: 6,
      );
    } catch (e) {
      history = null;
      errorMessage = 'No se pudieron cargar los datos energéticos.';
    } finally {
      isLoading = false;
      _notify();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _notify() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }
}
