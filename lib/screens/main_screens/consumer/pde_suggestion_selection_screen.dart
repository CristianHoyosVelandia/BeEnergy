import 'dart:math' as math;

import 'package:be_energy/core/api/api_exceptions.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/utils/formatters.dart';
import 'package:be_energy/data/fake_data_january_2026.dart';
import 'package:be_energy/models/my_user.dart';
import 'package:be_energy/screens/main_screens/consumer/consumer_marketplace_screen.dart';
import 'package:be_energy/services/consumer_offer_api_service.dart';
import 'package:be_energy/utils/metodos.dart';
import 'package:flutter/material.dart';

class PdeSuggestionSelectionScreen extends StatefulWidget {
  final String period;
  final MyUser myUser;
  final int communityId;
  final double energyConsumed;
  final double totalPDEAvailable;

  const PdeSuggestionSelectionScreen({
    super.key,
    required this.period,
    required this.myUser,
    required this.communityId,
    required this.energyConsumed,
    required this.totalPDEAvailable,
  });

  @override
  State<PdeSuggestionSelectionScreen> createState() => _PdeSuggestionSelectionScreenState();
}

class _PdeSuggestionSelectionScreenState extends State<PdeSuggestionSelectionScreen> {
  final ConsumerOfferApiService _apiService = ConsumerOfferApiService();
  bool _isCreatingOffer = false;
  String? _errorMessage;

  static const double _gridEnergyPrice = FakeDataJanuary2026.costoEnergia;
  static const double _maxPdePercentage = 9.99;

  double get _availablePDE => widget.totalPDEAvailable > 0
      ? widget.totalPDEAvailable
      : FakeDataJanuary2026.pdeJan2026.allocatedEnergy;

  String get _firstName {
    final name = widget.myUser.nombre?.trim();
    if (name == null || name.isEmpty) {
      return 'Usuario';
    }
    return name.split(' ').first;
  }

  List<_PdeSuggestion> get _suggestions {
    // final available = math.max(_availablePDE, 0.01);
    final available = _availablePDE*100;
    // print('Available PDE: $available kWh');
    final consumption =
        widget.energyConsumed > 0 ? widget.energyConsumed : available;
    final maxUsefulEnergy = math.min(available, consumption);

    return [
      _buildSuggestion(
        name: 'Escenario bajo',
        factor: 0.35,
        pricePerKwh: 550,
        icon: Icons.bolt_outlined,
        color: AppTokens.primaryColor,
        explanation:
            'Ideal si quieres probar el PDE con una solicitud conservadora.',
        maxUsefulEnergy: maxUsefulEnergy,
        available: available,
      ),
      _buildSuggestion(
        name: 'Escenario medio',
        factor: 0.65,
        pricePerKwh: 545.0,
        icon: Icons.offline_bolt,
        color: AppTokens.primaryColor,
        explanation:
            'Balancea ahorro y probabilidad de asignación para este periodo.',
        maxUsefulEnergy: maxUsefulEnergy,
        available: available,
      ),
      _buildSuggestion(
        name: 'Escenario alto',
        factor: 1,
        pricePerKwh: 540,
        icon: Icons.flash_on,
        color: AppTokens.primaryColor,
        explanation: 'Busca una mayor cobertura PDE aprovechando la disponibilidad actual.',
        maxUsefulEnergy: maxUsefulEnergy,
        available: available,
      ),
    ];
  }

  _PdeSuggestion _buildSuggestion({
    required String name,
    required double factor,
    required double pricePerKwh,
    required IconData icon,
    required Color color,
    required String explanation,
    required double maxUsefulEnergy,
    required double available,
  }) {
    final maxUsefulPercentage = math.min(
      (maxUsefulEnergy / available) * 100,
      _maxPdePercentage,
    );
    final pdePercentage = math.max(maxUsefulPercentage * factor, 0.01);
    final energyKwh = available * (pdePercentage / 100);
    final savings = math.max((_gridEnergyPrice - pricePerKwh) * energyKwh, 0.0);

    return _PdeSuggestion(
      name: name,
      pdePercentage: pdePercentage.clamp(0.01, _maxPdePercentage).toDouble(),
      energyKwh: energyKwh,
      pricePerKwh: pricePerKwh,
      estimatedSavings: savings,
      explanation: explanation,
      icon: icon,
      color: color,
    );
  }

  Future<void> _createSuggestedOffer(_PdeSuggestion suggestion) async {
    final userId = widget.myUser.idUser;
    if (userId == null) {
      setState(() => _errorMessage = 'No se pudo identificar el usuario.');
      return;
    }

    setState(() {
      _isCreatingOffer = true;
      _errorMessage = null;
    });

    try {
      await _apiService.createOffer(
        buyerId: userId,
        communityId: widget.communityId,
        period: widget.period,
        pdePercentageRequested: suggestion.pdePercentage,
        pricePerKwh: suggestion.pricePerKwh,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ConsumerMarketplaceScreen(
            period: widget.period,
            myUser: widget.myUser,
            communityId: widget.communityId,
          ),
        ),
      );
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.message);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Error inesperado: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isCreatingOffer = false);
      }
    }
  }

  void _continueManual() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ConsumerMarketplaceScreen(
          period: widget.period,
          myUser: widget.myUser,
          communityId: widget.communityId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = _suggestions;
    final recommendedSavings = suggestions[1].estimatedSavings;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        title: const Text(
          'Selecciona tu PDE',
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: Metodos.gradientClasic(context),
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(AppTokens.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroCard(recommendedSavings),
                SizedBox(height: AppTokens.space16),
                Text(
                  'Opciones recomendadas',
                  style: context.textStyles.titleMedium?.copyWith(
                    fontWeight: AppTokens.fontWeightBold,
                  ),
                ),
                SizedBox(height: AppTokens.space12),
                ...suggestions.map(_buildSuggestionCard),
                SizedBox(height: AppTokens.space8),
                _buildManualOption(),
                if (_errorMessage != null) ...[
                  SizedBox(height: AppTokens.space16),
                  _buildErrorMessage(),
                ],
                SizedBox(height: AppTokens.space32),
              ],
            ),
          ),
          if (_isCreatingOffer)
            Container(
              color: Colors.black.withValues(alpha: 0.25),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(double recommendedSavings) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTokens.space20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTokens.borderRadiusLarge,
        boxShadow: AppTokens.shadowMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppTokens.space12),
                decoration: BoxDecoration(
                  color: AppTokens.primaryColor.withValues(alpha: 0.1),
                  borderRadius: AppTokens.borderRadiusMedium,
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: AppTokens.primaryColor,
                ),
              ),
              SizedBox(width: AppTokens.space12),
              Expanded(
                child: Text(
                  Formatters.formatPeriodToDisplayName(widget.period),
                  style: context.textStyles.titleSmall?.copyWith(
                    fontWeight: AppTokens.fontWeightBold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space16),
          Text(
            'Hola $_firstName, de acuerdo con tu consumo y la generación comunitaria disponible, para este periodo te recomendamos solicitar un PDE que podría generarte un ahorro aproximado de ${Formatters.formatCurrency(recommendedSavings, decimals: 0)}.',
            style: context.textStyles.bodyLarge?.copyWith(
              height: 1.4,
              color: AppTokens.grey800,
            ),
          ),
          SizedBox(height: AppTokens.space16),
          Row(
            children: [
              Expanded(
                child: _buildMetric(
                  'Consumo',
                  Formatters.formatEnergy(widget.energyConsumed),
                ),
              ),
              SizedBox(width: AppTokens.space8),
              Expanded(
                child: _buildMetric(
                  'PDE disponible',
                  Formatters.formatEnergy(_availablePDE),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Container(
      padding: EdgeInsets.all(AppTokens.space12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F9),
        borderRadius: AppTokens.borderRadiusMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.textStyles.bodySmall?.copyWith(
              color: AppTokens.grey600,
            ),
          ),
          SizedBox(height: AppTokens.space4),
          Text(
            value,
            style: context.textStyles.bodyMedium?.copyWith(
              fontWeight: AppTokens.fontWeightBold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(_PdeSuggestion suggestion) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTokens.space8),
      child: Material(
        color: Colors.white,
        borderRadius: AppTokens.borderRadiusLarge,
        child: InkWell(
          onTap:
              _isCreatingOffer ? null : () => _createSuggestedOffer(suggestion),
          borderRadius: AppTokens.borderRadiusLarge,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppTokens.space16,
              vertical: AppTokens.space12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppTokens.borderRadiusLarge,
              border: Border.all(color: AppTokens.grey300),
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: suggestion.color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    suggestion.icon,
                    color: suggestion.color,
                    size: 28,
                  ),
                ),
                SizedBox(width: AppTokens.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        suggestion.name,
                        style: context.textStyles.bodySmall?.copyWith(
                          color: AppTokens.grey600,
                          fontWeight: AppTokens.fontWeightSemiBold,
                        ),
                      ),
                      Text(
                        '${Formatters.formatNumber(suggestion.pdePercentage, decimals: 2)}% PDE',
                        style: context.textStyles.titleSmall?.copyWith(
                          fontWeight: AppTokens.fontWeightBold,
                          color: suggestion.color,
                        ),
                      ),
                      SizedBox(height: AppTokens.space4),
                      Text(
                        'Ahorro ${Formatters.formatCurrency(suggestion.estimatedSavings, decimals: 0)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textStyles.bodySmall?.copyWith(
                          color: AppTokens.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppTokens.space12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      Formatters.formatCurrency(
                        suggestion.pricePerKwh,
                        decimals: 0,
                      ),
                      style: context.textStyles.titleMedium?.copyWith(
                        fontWeight: AppTokens.fontWeightBold,
                        color: AppTokens.grey900,
                      ),
                    ),
                    SizedBox(height: AppTokens.space4),
                    Text(
                      'COP/kWh',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: AppTokens.grey600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildManualOption() {
    return Container(
      padding: EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTokens.borderRadiusLarge,
        border: Border.all(color: AppTokens.grey300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Si ninguna de estas opciones se ajusta a tus necesidades, recuerda que también puedes crear tu oferta de manera manual.',
            style: context.textStyles.bodyMedium?.copyWith(
              color: AppTokens.grey700,
              height: 1.35,
            ),
          ),
          SizedBox(height: AppTokens.space12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isCreatingOffer ? null : _continueManual,
              icon: const Icon(Icons.tune),
              label: const Text('Crear oferta manualmente'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTokens.primaryColor,
                side: BorderSide(color: AppTokens.primaryColor),
                padding: EdgeInsets.symmetric(vertical: AppTokens.space16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTokens.space12),
      decoration: BoxDecoration(
        color: AppTokens.error.withValues(alpha: 0.1),
        borderRadius: AppTokens.borderRadiusMedium,
        border: Border.all(color: AppTokens.error.withValues(alpha: 0.3)),
      ),
      child: Text(
        _errorMessage!,
        style: context.textStyles.bodyMedium?.copyWith(color: AppTokens.error),
      ),
    );
  }
}

class _PdeSuggestion {
  final String name;
  final double pdePercentage;
  final double energyKwh;
  final double pricePerKwh;
  final double estimatedSavings;
  final String explanation;
  final IconData icon;
  final Color color;

  const _PdeSuggestion({
    required this.name,
    required this.pdePercentage,
    required this.energyKwh,
    required this.pricePerKwh,
    required this.estimatedSavings,
    required this.explanation,
    required this.icon,
    required this.color,
  });
}
