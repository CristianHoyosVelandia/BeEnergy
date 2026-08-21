import 'package:be_energy/core/api/api_exceptions.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/utils/formatters.dart';
import 'package:be_energy/models/forecast_pde.dart';
import 'package:be_energy/models/my_user.dart';
import 'package:be_energy/screens/main_screens/consumer/consumer_marketplace_screen.dart';
import 'package:be_energy/services/consumer_offer_api_service.dart';
import 'package:be_energy/services/forecast_api_service.dart';
import 'package:be_energy/utils/metodos.dart';
import 'package:flutter/material.dart';

class PdeSuggestionSelectionScreen extends StatefulWidget {
  final String period;
  final MyUser myUser;
  final int communityId;
  final double energyConsumed;
  final double totalPDEAvailable;
  final double? communityAverageGenerationKwh;

  const PdeSuggestionSelectionScreen({
    super.key,
    required this.period,
    required this.myUser,
    required this.communityId,
    required this.energyConsumed,
    required this.totalPDEAvailable,
    this.communityAverageGenerationKwh,
  });

  @override
  State<PdeSuggestionSelectionScreen> createState() =>
      _PdeSuggestionSelectionScreenState();
}

class _PdeSuggestionSelectionScreenState
    extends State<PdeSuggestionSelectionScreen> {
  final ConsumerOfferApiService _apiService = ConsumerOfferApiService();
  final ForecastApiService _forecastService = ForecastApiService();
  ForecastOfertaPde? _forecast;
  bool _isLoadingForecast = true;
  bool _isCreatingOffer = false;
  String? _errorMessage;
  int _selectedSuggestionIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadForecast();
  }

  Future<void> _loadForecast() async {
    try {
      final forecast = await _forecastService.getOfertaPde(
        communityId: widget.communityId,
        userId: widget.myUser.idUser,
        period: widget.period,
      );
      if (mounted) {
        setState(() {
          _forecast = forecast;
          _isLoadingForecast = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _isLoadingForecast = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error inesperado: $e';
          _isLoadingForecast = false;
        });
      }
    }
  }

  String get _firstName {
    final name = widget.myUser.nombre?.trim();
    if (name == null || name.isEmpty) {
      return 'Usuario';
    }
    return name.split(' ').first;
  }

  List<_PdeSuggestion> get _suggestions {
    final forecast = _forecast;
    if (forecast == null) return const [];

    final suggestions = forecast.escenarios.map((scenario) {
      final additionalPde = (scenario.pdePorcentaje - forecast.pdeActual)
          .clamp(0, scenario.pdePorcentaje)
          .toDouble();
      return _PdeSuggestion(
        id: scenario.id,
        name: _scenarioName(scenario.id),
        currentPdePercentage: forecast.pdeActual,
        additionalPdePercentage: additionalPde,
        pdePercentage: scenario.pdePorcentaje,
        energyKwh: scenario.pdeKwh,
        pricePerKwh: forecast.tarifaCopKwh,
        estimatedSavings: scenario.ahorroEstimadoCop,
        explanation: scenario.descripcion,
        icon: _scenarioIcon(scenario.id),
        color: AppTokens.primaryColor,
      );
    }).toList();

    return _uniqueSuggestions(suggestions);
  }

  List<_PdeSuggestion> _uniqueSuggestions(List<_PdeSuggestion> suggestions) {
    final seen = <String>{};
    final sorted = [...suggestions]..sort((a, b) {
        if (a.id == 'medio') return -1;
        if (b.id == 'medio') return 1;
        return a.id.compareTo(b.id);
      });

    return sorted.where((suggestion) {
      final key = [
        suggestion.additionalPdePercentage.toStringAsFixed(4),
        suggestion.pdePercentage.toStringAsFixed(4),
        suggestion.estimatedSavings.toStringAsFixed(0),
      ].join('|');
      return seen.add(key);
    }).toList();
  }

  _PdeSuggestion? _selectedSuggestion(List<_PdeSuggestion> suggestions) {
    if (suggestions.isEmpty) return null;
    final index = _selectedSuggestionIndex.clamp(0, suggestions.length - 1);
    return suggestions[index];
  }

  double _estimatedEnergyKwh(_PdeSuggestion suggestion) {
    final communityEnergy = widget.communityAverageGenerationKwh ??
        _forecast?.generacionEstimadaComunidadKwh ??
        widget.totalPDEAvailable;
    if (communityEnergy > 0) {
      return communityEnergy * (suggestion.pdePercentage / 100);
    }
    return suggestion.energyKwh;
  }

  String _scenarioName(String id) {
    switch (id) {
      case 'bajo':
        return 'Escenario conservador';
      case 'alto':
        return 'Escenario alto';
      default:
        return 'Escenario recomendado';
    }
  }

  String _scenarioActionName(String id) {
    switch (id) {
      case 'alto':
      case 'maxima':
        return 'Solicitar máximo';
      case 'bajo':
        return 'Solicitar conservador';
      default:
        return 'Solicitar recomendado';
    }
  }

  IconData _scenarioIcon(String id) {
    switch (id) {
      case 'bajo':
        return Icons.bolt_outlined;
      case 'alto':
        return Icons.flash_on;
      default:
        return Icons.offline_bolt;
    }
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
      await _apiService.createPdeOffer(
        communityId: widget.communityId,
        period: widget.period,
        pdePercentage: suggestion.pdePercentage,
        pdeKwh: _estimatedEnergyKwh(suggestion),
        pricePerKwh: suggestion.pricePerKwh,
        origen: 'forecast',
        escenarioId: suggestion.id,
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
    final selectedSuggestion = _selectedSuggestion(suggestions);

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
          if (_isLoadingForecast)
            const Center(child: CircularProgressIndicator())
          else
            SingleChildScrollView(
              padding: EdgeInsets.all(AppTokens.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroCard(selectedSuggestion),
                  SizedBox(height: AppTokens.space16),
                  Text(
                    'Tu oferta',
                    style: context.textStyles.titleMedium?.copyWith(
                      color: AppTokens.primaryColor,
                      fontWeight: AppTokens.fontWeightBold,
                    ),
                  ),
                  SizedBox(height: AppTokens.space12),
                  _buildSuggestionChips(suggestions),
                  if (selectedSuggestion != null) ...[
                    SizedBox(height: AppTokens.space12),
                    _buildSelectedOfferSummary(selectedSuggestion),
                  ],
                  if (selectedSuggestion != null) ...[
                    SizedBox(height: AppTokens.space12),
                    _buildSelectedAction(selectedSuggestion),
                    SizedBox(height: AppTokens.space8),
                  ],
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

  Widget _buildHeroCard(_PdeSuggestion? selectedSuggestion) {
    final forecast = _forecast;

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
              Expanded(
                child: Text(
                  Formatters.formatPeriodToDisplayName(widget.period),
                  style: context.textStyles.titleMedium?.copyWith(
                    color: AppTokens.primaryColor,
                    fontWeight: AppTokens.fontWeightBold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space16),
          Text(
            forecast == null || selectedSuggestion == null
                ? 'Hola $_firstName, revisa las opciones para este periodo.'
                : 'Hola $_firstName, puedes solicitar más PDE para este periodo.',
            style: context.textStyles.bodySmall?.copyWith(
              height: 1.4,
              color: context.colors.onSurfaceVariant,
            ),
          ),
          if (forecast != null && selectedSuggestion != null) ...[
            SizedBox(height: AppTokens.space16),
            _OfferPdeBar(
              currentPde: forecast.pdeActual,
              additionalPde: selectedSuggestion.additionalPdePercentage,
              maxPde: 10,
            ),
            SizedBox(height: AppTokens.space12),
            Text(
              'PDE',
              style: context.textStyles.labelLarge?.copyWith(
                color: AppTokens.grey900,
                fontWeight: AppTokens.fontWeightBold,
              ),
            ),
            SizedBox(height: AppTokens.space4),
            _OfferMetricStrip(items: [
              _OfferMetricItem('Actual', _formatPde(forecast.pdeActual)),
              _OfferMetricItem('Solicitado',
                  _formatPde(selectedSuggestion.additionalPdePercentage)),
              _OfferMetricItem(
                  'Final', _formatPde(selectedSuggestion.pdePercentage)),
            ]),
            SizedBox(height: AppTokens.space12),
            _EstimatedEnergyBlock(
              value: Formatters.formatEnergy(
                _estimatedEnergyKwh(selectedSuggestion),
                decimals: 2,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSuggestionChips(List<_PdeSuggestion> suggestions) {
    return Wrap(
      spacing: AppTokens.space8,
      runSpacing: AppTokens.space8,
      children: [
        for (var i = 0; i < suggestions.length; i++)
          ChoiceChip(
            label: Text(
              suggestions[i].additionalPdePercentage > 0
                  ? _scenarioActionName(suggestions[i].id)
                  : 'Mantener actual',
            ),
            selected: i == _selectedSuggestionIndex,
            selectedColor: AppTokens.primaryColor.withValues(alpha: 0.14),
            checkmarkColor: AppTokens.white,
            labelStyle: context.textStyles.bodySmall?.copyWith(
              color: i == _selectedSuggestionIndex
                  ? AppTokens.white
                  : AppTokens.grey700,
              fontWeight: AppTokens.fontWeightSemiBold,
            ),
            side: BorderSide(
              color: i == _selectedSuggestionIndex
                  ? AppTokens.primaryColor
                  : AppTokens.grey300,
            ),
            onSelected: _isCreatingOffer
                ? null
                : (_) => setState(() => _selectedSuggestionIndex = i),
          ),
      ],
    );
  }

  Widget _buildSelectedOfferSummary(_PdeSuggestion suggestion) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTokens.borderRadiusLarge,
        border:
            Border.all(color: AppTokens.primaryColor.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OfferMetricStrip(items: [
            _OfferMetricItem(
              'Solicitas',
              _formatPde(suggestion.additionalPdePercentage),
            ),
            _OfferMetricItem('PDE final', _formatPde(suggestion.pdePercentage)),
            _OfferMetricItem(
              'Estimado',
              Formatters.formatEnergy(_estimatedEnergyKwh(suggestion),
                  decimals: 2),
            ),
          ]),
          SizedBox(height: AppTokens.space12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ahorro estimado',
                style: context.textStyles.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              Text(
                Formatters.formatCurrency(suggestion.estimatedSavings,
                    decimals: 0),
                style: context.textStyles.titleMedium?.copyWith(
                  color: AppTokens.primaryColor,
                  fontWeight: AppTokens.fontWeightBold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedAction(_PdeSuggestion suggestion) {
    final enabled = suggestion.additionalPdePercentage > 0 && !_isCreatingOffer;

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: enabled ? () => _createSuggestedOffer(suggestion) : null,
        style: FilledButton.styleFrom(
          backgroundColor: AppTokens.primaryColor,
          padding: EdgeInsets.symmetric(vertical: AppTokens.space12),
          shape: RoundedRectangleBorder(
            borderRadius: AppTokens.borderRadiusMedium,
          ),
        ),
        child: Text(
          enabled
              ? 'Crear oferta con esta opción'
              : 'No necesitas crear oferta',
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
            '¿Quieres ajustar el porcentaje?',
            style: context.textStyles.bodyMedium?.copyWith(
              color: AppTokens.grey900,
              fontWeight: AppTokens.fontWeightBold,
            ),
          ),
          SizedBox(height: AppTokens.space8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isCreatingOffer ? null : _continueManual,
              icon: const Icon(Icons.tune),
              label: const Text('Elegir otro valor'),
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

  String _formatPde(double value) {
    return '${Formatters.formatNumber(value, decimals: 2)}%';
  }
}

class _PdeSuggestion {
  final String id;
  final String name;
  final double currentPdePercentage;
  final double additionalPdePercentage;
  final double pdePercentage;
  final double energyKwh;
  final double pricePerKwh;
  final double estimatedSavings;
  final String explanation;
  final IconData icon;
  final Color color;

  const _PdeSuggestion({
    required this.id,
    required this.name,
    required this.currentPdePercentage,
    required this.additionalPdePercentage,
    required this.pdePercentage,
    required this.energyKwh,
    required this.pricePerKwh,
    required this.estimatedSavings,
    required this.explanation,
    required this.icon,
    required this.color,
  });
}

class _OfferMetricItem {
  final String label;
  final String value;

  const _OfferMetricItem(this.label, this.value);
}

class _OfferMetricStrip extends StatelessWidget {
  final List<_OfferMetricItem> items;

  const _OfferMetricStrip({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTokens.space12,
        vertical: AppTokens.space12,
      ),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.32),
        borderRadius: AppTokens.borderRadiusMedium,
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    items[i].label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.bodySmall?.copyWith(
                      color: AppTokens.grey700,
                      fontWeight: AppTokens.fontWeightSemiBold,
                    ),
                  ),
                  SizedBox(height: AppTokens.space4),
                  Text(
                    items[i].value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: AppTokens.grey900,
                      fontWeight: AppTokens.fontWeightBold,
                    ),
                  ),
                ],
              ),
            ),
            if (i != items.length - 1)
              Container(
                width: 1,
                height: 34,
                margin: EdgeInsets.symmetric(horizontal: AppTokens.space8),
                color: context.colors.outline.withValues(alpha: 0.12),
              ),
          ],
        ],
      ),
    );
  }
}

class _EstimatedEnergyBlock extends StatelessWidget {
  final String value;

  const _EstimatedEnergyBlock({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppTokens.space12,
        vertical: AppTokens.space12,
      ),
      decoration: BoxDecoration(
        color: AppTokens.primaryColor.withValues(alpha: 0.06),
        borderRadius: AppTokens.borderRadiusMedium,
        border: Border.all(
          color: AppTokens.primaryColor.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estimado (kWh)',
            style: context.textStyles.bodySmall?.copyWith(
              color: AppTokens.grey700,
              fontWeight: AppTokens.fontWeightSemiBold,
            ),
          ),
          SizedBox(height: AppTokens.space4),
          Text(
            value,
            style: context.textStyles.displaySmall?.copyWith(
              color: AppTokens.grey900,
              fontWeight: AppTokens.fontWeightBold,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferPdeBar extends StatelessWidget {
  final double currentPde;
  final double additionalPde;
  final double maxPde;

  const _OfferPdeBar({
    required this.currentPde,
    required this.additionalPde,
    this.maxPde = 10,
  });

  @override
  Widget build(BuildContext context) {
    final safeCurrent = currentPde < 0 ? 0.0 : currentPde;
    final safeAdditional = additionalPde < 0 ? 0.0 : additionalPde;
    final safeMax = maxPde <= 0 ? 10.0 : maxPde;
    final total = safeMax;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PDE actual',
              style: context.textStyles.labelMedium?.copyWith(
                color: AppTokens.primaryColor,
                fontWeight: AppTokens.fontWeightBold,
              ),
            ),
            Text(
              '10% máximo',
              style: context.textStyles.labelMedium?.copyWith(
                color: AppTokens.grey700,
                fontWeight: AppTokens.fontWeightBold,
              ),
            ),
          ],
        ),
        SizedBox(height: AppTokens.space8),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final currentWidth = width * (safeCurrent / total).clamp(0.0, 1.0);
            final additionalWidth =
                width * (safeAdditional / total).clamp(0.0, 1.0);

            return ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: double.infinity,
                height: 22,
                decoration: BoxDecoration(
                  color: AppTokens.primaryColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppTokens.primaryColor.withValues(alpha: 0.28),
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: currentWidth,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppTokens.primaryColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    Positioned(
                      left: currentWidth,
                      child: Container(
                        width: additionalWidth,
                        height: 22,
                        color: AppTokens.primaryColor.withValues(alpha: 0.38),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
