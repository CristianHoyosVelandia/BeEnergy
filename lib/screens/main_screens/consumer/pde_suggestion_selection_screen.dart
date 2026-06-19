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

  const PdeSuggestionSelectionScreen({
    super.key,
    required this.period,
    required this.myUser,
    required this.communityId,
    required this.energyConsumed,
    required this.totalPDEAvailable,
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

    return forecast.escenarios.map((scenario) {
      return _PdeSuggestion(
        id: scenario.id,
        name: _scenarioName(scenario.id),
        pdePercentage: scenario.pdePorcentaje,
        energyKwh: scenario.pdeKwh,
        pricePerKwh: forecast.tarifaCopKwh,
        estimatedSavings: scenario.ahorroEstimadoCop,
        explanation: scenario.descripcion,
        icon: _scenarioIcon(scenario.id),
        color: AppTokens.primaryColor,
      );
    }).toList();
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
        pdeKwh: suggestion.energyKwh,
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
    final recommendedSavings = suggestions.isEmpty
        ? 0.0
        : suggestions[(suggestions.length / 2).floor()].estimatedSavings;

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
                  _buildHeroCard(recommendedSavings),
                  SizedBox(height: AppTokens.space16),
                  Text(
                    'Opciones recomendadas',
                    style: context.textStyles.titleMedium?.copyWith(
                      fontWeight: AppTokens.fontWeightBold,
                    ),
                  ),
                  SizedBox(height: AppTokens.space12),
                  for (var i = 0; i < suggestions.length; i++)
                    _buildSuggestionCard(
                      suggestions[i],
                      highlight: suggestions[i].id == 'medio',
                    ),
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
            'Hola $_firstName, de acuerdo con tu consumo y la generación comunitaria disponible, para este periodo te recomendamos solicitar un PDE de:',
            style: context.textStyles.bodyMedium?.copyWith(
              height: 1.4,
              color: AppTokens.black,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(
    _PdeSuggestion suggestion, {
    bool highlight = false,
  }) {
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
              border: Border.all(
                color: highlight ? AppTokens.primaryColor : AppTokens.grey300,
                width: highlight ? 2 : 1,
              ),
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
                          color: AppTokens.black,
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
                        '${Formatters.formatCurrency(suggestion.pricePerKwh, decimals: 0)} COP/kWh',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textStyles.bodySmall?.copyWith(
                          color: AppTokens.black,
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
                        suggestion.estimatedSavings,
                        decimals: 0,
                      ),
                      style: context.textStyles.titleMedium?.copyWith(
                        fontWeight: AppTokens.fontWeightBold,
                        color: AppTokens.primaryColor,
                      ),
                    ),
                    SizedBox(height: AppTokens.space4),
                    Text(
                      'Ahorro Potencial',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: AppTokens.black,
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
  final String id;
  final String name;
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
    required this.pdePercentage,
    required this.energyKwh,
    required this.pricePerKwh,
    required this.estimatedSavings,
    required this.explanation,
    required this.icon,
    required this.color,
  });
}
