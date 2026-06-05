import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/utils/formatters.dart';
import 'package:be_energy/data/fake_data_january_2026.dart';
import 'package:be_energy/models/consumer_offer.dart';
import 'package:be_energy/models/pde_period_status.dart';
import 'package:be_energy/models/pde_renuncia.dart';
import 'package:flutter/material.dart';

import 'pde_progress_timeline.dart';

class PdeStateMachineCard extends StatelessWidget {
  final bool isLoadingStatus;
  final bool isLoadingOffer;
  final bool isLoadingPdeRenuncia;
  final bool isAdminView;
  final String periodDisplayName;
  final PDEPeriodStatus? status;
  final ConsumerOffer? buyerOffer;
  final PdeRenunciaStatus? pdeRenunciaStatus;
  final VoidCallback onAvailableTap;
  final VoidCallback onAdminClosedTap;
  final VoidCallback onMoveToReconciliationTap;
  final VoidCallback onCloseRenunciationFlowTap;
  final VoidCallback onSuggestedWaiverTap;
  final VoidCallback onManualWaiverTap;
  final VoidCallback onFullWaiverTap;
  final VoidCallback onKeepPdeTap;

  const PdeStateMachineCard({
    super.key,
    required this.isLoadingStatus,
    required this.isLoadingOffer,
    required this.isLoadingPdeRenuncia,
    required this.isAdminView,
    required this.periodDisplayName,
    required this.status,
    required this.buyerOffer,
    required this.pdeRenunciaStatus,
    required this.onAvailableTap,
    required this.onAdminClosedTap,
    required this.onMoveToReconciliationTap,
    required this.onCloseRenunciationFlowTap,
    required this.onSuggestedWaiverTap,
    required this.onManualWaiverTap,
    required this.onFullWaiverTap,
    required this.onKeepPdeTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoadingStatus) {
      return _LoadingCard();
    }

    final currentStatus = status;
    if (currentStatus == null) {
      return const SizedBox.shrink();
    }

    switch (currentStatus.statusCode) {
      case 1:
        return currentStatus.isPDEAvailable
            ? _AvailableCard(
                isAdminView: isAdminView,
                periodDisplayName: periodDisplayName,
                message: currentStatus.getDisplayMessage(),
                onTap: onAvailableTap,
              )
            : const SizedBox.shrink();
      case 2:
        return isAdminView
            ? _InfoCard(
                statusCode: 2,
                title: 'Periodo Cerrado',
                periodDisplayName: periodDisplayName,
                message:
                    'El periodo de ofertas ha cerrado. Puede proceder a realizar la asignación de PDE.',
                ctaLabel: 'Realizar Asignación de PDE',
                icon: Icons.assignment_turned_in,
                onTap: onAdminClosedTap,
              )
            : _ConsumerOfferCard(
                statusCode: 2,
                title: 'Periodo Cerrado',
                periodDisplayName: periodDisplayName,
                loading: isLoadingOffer,
                offer: buyerOffer,
                emptyTitle: 'Periodo Cerrado',
                emptyMessage:
                    'No alcanzaste a crear una oferta para este periodo. Te guiaremos cuando el próximo PDE esté disponible.',
                footerMessage:
                    'Se te notificará cuando se realice la asignación de PDE',
                rowsBuilder: _closedRows,
              );
      case 3:
        return isAdminView
            ? _InfoCard(
                statusCode: 3,
                title: 'Ofertas Finalizadas',
                periodDisplayName: periodDisplayName,
                message:
                    'Las ofertas han sido liquidadas. Puede proceder a cambiar el estado a En Conciliación.',
                ctaLabel: 'Pasar a Conciliación',
                icon: Icons.check_circle,
                onTap: onMoveToReconciliationTap,
              )
            : _ConsumerOfferCard(
                statusCode: 3,
                title: 'Ofertas Finalizadas',
                periodDisplayName: periodDisplayName,
                loading: isLoadingOffer,
                offer: buyerOffer,
                footerMessage:
                    'Apenas se concilie con el comercializador podrá ver el ahorro real en su tarifa energética.',
                rowsBuilder: _finalizedRows,
              );
      case 4:
        return isAdminView
            ? _InfoCard(
                statusCode: 4,
                title: 'En Conciliación',
                periodDisplayName: periodDisplayName,
                message: 'Esperando conciliación con el comercializador.',
                icon: Icons.sync,
              )
            : _ConsumerOfferCard(
                statusCode: 4,
                title: 'En Conciliación',
                periodDisplayName: periodDisplayName,
                loading: isLoadingOffer,
                offer: buyerOffer,
                footerMessage:
                    'A la espera de conciliación con el comercializador.',
                rowsBuilder: _reconciliationRows,
              );
      case 6:
        return isAdminView
            ? _InfoCard(
                statusCode: 6,
                title: 'Renuncia Voluntaria',
                periodDisplayName: periodDisplayName,
                message:
                    'Los miembros pueden renunciar PDE asignado. Al cerrar este flujo se abriran las ofertas del PDE liberado.',
                ctaLabel: 'Cerrar Renuncias y Abrir Ofertas',
                icon: Icons.volunteer_activism,
                onTap: onCloseRenunciationFlowTap,
              )
            : _VoluntaryWaiverCard(
                loading: isLoadingPdeRenuncia,
                status: pdeRenunciaStatus,
                periodDisplayName: periodDisplayName,
                onSuggestedWaiverTap: onSuggestedWaiverTap,
                onManualWaiverTap: onManualWaiverTap,
                onFullWaiverTap: onFullWaiverTap,
                onKeepPdeTap: onKeepPdeTap,
              );
      default:
        return _HistoricalCard(
          isAdminView: isAdminView,
          loading: isLoadingOffer,
          offer: buyerOffer,
        );
    }
  }

  static List<MapEntry<String, String>> _closedRows(ConsumerOffer offer) => [
        MapEntry(
          'PDE Solicitado',
          '${Formatters.formatNumber(offer.pdePercentageRequested * 100, decimals: 2)}%',
        ),
        MapEntry(
          'Precio Ofertado',
          '${Formatters.formatCurrency(offer.pricePerKwh, decimals: 0, showSymbol: false)} COP/kWh',
        ),
      ];

  static List<MapEntry<String, String>> _finalizedRows(ConsumerOffer offer) {
    final totalValue = offer.energyKwhCalculated == null
        ? null
        : offer.energyKwhCalculated! * offer.pricePerKwh;

    return [
      MapEntry(
        'PDE Solicitado',
        '${Formatters.formatNumber(offer.pdePercentageRequested * 100, decimals: 2)}%',
      ),
      MapEntry(
        'PDE Asignado',
        offer.pdePercentageAssigned == null
            ? 'Pendiente'
            : '${Formatters.formatNumber(offer.pdePercentageAssigned! * 100, decimals: 2)}%',
      ),
      MapEntry(
        'Precio',
        '${Formatters.formatCurrency(offer.pricePerKwh, decimals: 0, showSymbol: false)} COP/kWh',
      ),
      if (totalValue != null)
        MapEntry('Valor Total', Formatters.formatCurrency(totalValue)),
      if (offer.liquidatedAt != null)
        MapEntry(
            'Liquidado el', Formatters.formatDateMedium(offer.liquidatedAt!)),
    ];
  }

  static List<MapEntry<String, String>> _reconciliationRows(
          ConsumerOffer offer) =>
      [
        MapEntry(
          'PDE Asignado',
          offer.pdePercentageAssigned == null
              ? 'Pendiente'
              : '${Formatters.formatNumber(offer.pdePercentageAssigned! * 100, decimals: 2)}%',
        ),
      ];
}

class _VoluntaryWaiverCard extends StatelessWidget {
  final bool loading;
  final PdeRenunciaStatus? status;
  final String periodDisplayName;
  final VoidCallback onSuggestedWaiverTap;
  final VoidCallback onManualWaiverTap;
  final VoidCallback onFullWaiverTap;
  final VoidCallback onKeepPdeTap;

  const _VoluntaryWaiverCard({
    required this.loading,
    required this.status,
    required this.periodDisplayName,
    required this.onSuggestedWaiverTap,
    required this.onManualWaiverTap,
    required this.onFullWaiverTap,
    required this.onKeepPdeTap,
  });

  @override
  Widget build(BuildContext context) {
    if (loading || status == null) {
      return _LoadingCard();
    }

    final data = status!;
    final renuncia = data.renuncia;
    final rows = [
      MapEntry('PDE actual', _formatPercent(data.pdeActual)),
      MapEntry('Consumo del mes', Formatters.formatEnergy(data.consumoKwh)),
      MapEntry('Renuncia sugerida', _formatPercent(data.pdeSugeridoRenuncia)),
      MapEntry('PDE conservado sugerido',
          _formatPercent(data.pdeSugeridoConservado)),
    ];

    if (renuncia != null) {
      rows.addAll([
        MapEntry('Renuncia registrada', _formatPercent(renuncia.pdeRenunciado)),
        MapEntry('Estado', renuncia.estado),
      ]);
    }

    return _GradientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(
            icon: Icons.volunteer_activism,
            title: 'Renuncia Voluntaria PDE',
            subtitle: periodDisplayName,
          ),
          SizedBox(height: AppTokens.space20),
          const PdeProgressTimeline(currentStatus: 6),
          SizedBox(height: AppTokens.space16),
          _MessageBox(
            message: renuncia == null
                ? 'Puedes liberar parte de tu PDE para que otros miembros oferten por el cuando el admin abra el periodo.'
                : 'Tu renuncia fue registrada y queda pendiente de revision del administrador.',
          ),
          SizedBox(height: AppTokens.space16),
          _RowsBox(rows: rows),
          if (renuncia == null) ...[
            SizedBox(height: AppTokens.space16),
            _WaiverActionButton(
              label: 'Renunciar sugerido',
              description: _formatPercent(data.pdeSugeridoRenuncia),
              onTap: data.pdeSugeridoRenuncia > 0 ? onSuggestedWaiverTap : null,
            ),
            SizedBox(height: AppTokens.space8),
            _WaiverActionButton(
              label: 'Renunciar manualmente',
              description: 'Elegir porcentaje',
              onTap: onManualWaiverTap,
            ),
            SizedBox(height: AppTokens.space8),
            _WaiverActionButton(
              label: 'Renunciar todo',
              description: _formatPercent(data.pdeActual),
              onTap: data.pdeActual > 0 ? onFullWaiverTap : null,
            ),
            SizedBox(height: AppTokens.space8),
            _WaiverActionButton(
              label: 'Conservar todo mi PDE',
              description: 'No liberar porcentaje',
              onTap: onKeepPdeTap,
            ),
          ],
        ],
      ),
    );
  }

  String _formatPercent(double value) {
    return '${Formatters.formatNumber(value * 100, decimals: 2)}%';
  }
}

class _WaiverActionButton extends StatelessWidget {
  final String label;
  final String description;
  final VoidCallback? onTap;

  const _WaiverActionButton({
    required this.label,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppTokens.borderRadiusMedium,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppTokens.space12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: onTap == null ? 0.08 : 0.16),
          borderRadius: AppTokens.borderRadiusMedium,
          border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: AppTokens.fontWeightBold,
                    ),
                  ),
                  SizedBox(height: AppTokens.space4),
                  Text(
                    description,
                    style: context.textStyles.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color:
                  Colors.white.withValues(alpha: onTap == null ? 0.25 : 0.75),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
      padding: EdgeInsets.all(AppTokens.space20),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _AvailableCard extends StatelessWidget {
  final bool isAdminView;
  final String periodDisplayName;
  final String message;
  final VoidCallback onTap;

  const _AvailableCard({
    required this.isAdminView,
    required this.periodDisplayName,
    required this.message,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final minValue =
        FakeDataJanuary2026.pdeConstantsJan2026.mcmValorEnergiaPromedio * 1.1;
    final maxValue = (FakeDataJanuary2026.pdeConstantsJan2026.costoEnergia -
            FakeDataJanuary2026.pdeConstantsJan2026.costoComercializacion) *
        0.95;

    return _GradientCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(
            icon: isAdminView ? Icons.list_alt : Icons.bolt,
            title: isAdminView ? 'Revisar Ofertas' : message,
            subtitle: isAdminView
                ? '$periodDisplayName - Gestión Comunitaria'
                : '$periodDisplayName - Modelo de Ofertas',
            showArrow: true,
          ),
          SizedBox(height: AppTokens.space20),
          const PdeProgressTimeline(currentStatus: 1),
          SizedBox(height: AppTokens.space16),
          Row(
            children: [
              Expanded(
                child: _MetricBox(
                  label: 'Precio Mercado',
                  value:
                      '${Formatters.formatCurrency(FakeDataJanuary2026.pdeConstantsJan2026.costoEnergia, decimals: 2)} COP',
                ),
              ),
              SizedBox(width: AppTokens.space12),
              Expanded(
                child: _MetricBox(
                  label: 'Rango Precio',
                  value:
                      '${Formatters.formatCurrency(minValue, decimals: 2, showSymbol: false)} - ${Formatters.formatCurrency(maxValue, decimals: 2, showSymbol: false)} COP',
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space16),
          _Cta(
              label: isAdminView
                  ? 'Revisar Ofertas Comunitarias'
                  : 'Crear Oferta de PDE'),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final int statusCode;
  final String title;
  final String periodDisplayName;
  final String message;
  final IconData icon;
  final String? ctaLabel;
  final VoidCallback? onTap;

  const _InfoCard({
    required this.statusCode,
    required this.title,
    required this.periodDisplayName,
    required this.message,
    required this.icon,
    this.ctaLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _GradientCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(
            icon: icon,
            title: title,
            subtitle: periodDisplayName,
            showArrow: onTap != null,
          ),
          SizedBox(height: AppTokens.space20),
          PdeProgressTimeline(currentStatus: statusCode),
          SizedBox(height: AppTokens.space16),
          _MessageBox(message: message),
          if (ctaLabel != null) ...[
            SizedBox(height: AppTokens.space16),
            _Cta(label: ctaLabel!),
          ],
        ],
      ),
    );
  }
}

class _ConsumerOfferCard extends StatelessWidget {
  final int statusCode;
  final String title;
  final String periodDisplayName;
  final bool loading;
  final ConsumerOffer? offer;
  final String? emptyTitle;
  final String? emptyMessage;
  final String footerMessage;
  final List<MapEntry<String, String>> Function(ConsumerOffer offer)
      rowsBuilder;

  const _ConsumerOfferCard({
    required this.statusCode,
    required this.title,
    required this.periodDisplayName,
    required this.loading,
    required this.offer,
    required this.footerMessage,
    required this.rowsBuilder,
    this.emptyTitle,
    this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return _LoadingCard();
    }

    final currentOffer = offer;
    if (currentOffer == null) {
      if (emptyMessage == null) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
        padding: EdgeInsets.all(AppTokens.space20),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest,
          borderRadius: AppTokens.borderRadiusLarge,
          border:
              Border.all(color: context.colors.outline.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              emptyTitle ?? title,
              style: context.textStyles.titleMedium?.copyWith(
                fontWeight: AppTokens.fontWeightBold,
              ),
            ),
            SizedBox(height: AppTokens.space12),
            Text(
              emptyMessage!,
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppTokens.space16),
            PdeProgressTimeline(currentStatus: statusCode, onDark: false),
          ],
        ),
      );
    }

    return _GradientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(icon: Icons.timer, title: title, subtitle: periodDisplayName),
          SizedBox(height: AppTokens.space20),
          PdeProgressTimeline(currentStatus: statusCode),
          SizedBox(height: AppTokens.space16),
          _RowsBox(rows: rowsBuilder(currentOffer)),
          SizedBox(height: AppTokens.space16),
          _MessageBox(message: footerMessage),
        ],
      ),
    );
  }
}

class _HistoricalCard extends StatelessWidget {
  final bool isAdminView;
  final bool loading;
  final ConsumerOffer? offer;

  const _HistoricalCard({
    required this.isAdminView,
    required this.loading,
    required this.offer,
  });

  @override
  Widget build(BuildContext context) {
    if (loading && !isAdminView) {
      return _LoadingCard();
    }

    final rows = <MapEntry<String, String>>[];
    final currentOffer = offer;
    if (!isAdminView && currentOffer != null) {
      final energy = currentOffer.energyKwhCalculated;
      final totalValue =
          energy == null ? null : energy * currentOffer.pricePerKwh;
      final estimatedSavings = energy == null
          ? null
          : (FakeDataJanuary2026.costoEnergia - currentOffer.pricePerKwh) *
              energy;

      rows.addAll([
        MapEntry(
          'PDE solicitado',
          '${Formatters.formatNumber(currentOffer.pdePercentageRequested * 100, decimals: 2)}%',
        ),
        MapEntry(
          'PDE asignado',
          currentOffer.pdePercentageAssigned == null
              ? 'Pendiente'
              : '${Formatters.formatNumber(currentOffer.pdePercentageAssigned! * 100, decimals: 2)}%',
        ),
        if (energy != null)
          MapEntry('Energía asignada', Formatters.formatEnergy(energy)),
        MapEntry(
          'Precio ofertado',
          '${Formatters.formatCurrency(currentOffer.pricePerKwh, decimals: 0)} COP/kWh',
        ),
        if (totalValue != null)
          MapEntry('Valor pagado', Formatters.formatCurrency(totalValue)),
        if (estimatedSavings != null)
          MapEntry(
              'Ahorro estimado', Formatters.formatCurrency(estimatedSavings)),
      ]);
    }

    return _GradientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(
            icon: Icons.history,
            title: rows.isEmpty ? 'Periodo Histórico' : 'Tu resultado PDE',
            subtitle: rows.isEmpty ? '' : 'Resumen financiero',
          ),
          SizedBox(height: AppTokens.space16),
          const PdeProgressTimeline(currentStatus: 5),
          SizedBox(height: AppTokens.space16),
          Text(
            rows.isEmpty
                ? 'Este periodo ya finalizó. Puedes usarlo como referencia para revisar resultados y próximos ciclos comunitarios.'
                : 'Este periodo ya finalizó. Aquí tienes el resumen financiero de tu participación.',
            style: context.textStyles.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.95),
              height: 1.35,
            ),
          ),
          if (rows.isNotEmpty) ...[
            SizedBox(height: AppTokens.space16),
            _RowsBox(rows: rows),
          ],
        ],
      ),
    );
  }
}

class _GradientCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _GradientCard({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    final content = Container(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
      padding: EdgeInsets.all(AppTokens.space20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTokens.primaryColor,
            AppTokens.primaryColor.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppTokens.borderRadiusLarge,
        boxShadow: [
          BoxShadow(
            color: AppTokens.primaryColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );

    return onTap == null
        ? content
        : GestureDetector(onTap: onTap, child: content);
  }
}

class _Header extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool showArrow;

  const _Header({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(AppTokens.space12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: AppTokens.borderRadiusSmall,
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        SizedBox(width: AppTokens.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.textStyles.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: AppTokens.fontWeightBold,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                SizedBox(height: AppTokens.space4),
                Text(
                  subtitle,
                  style: context.textStyles.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (showArrow)
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.white.withValues(alpha: 0.7),
            size: 20,
          ),
      ],
    );
  }
}

class _MetricBox extends StatelessWidget {
  final String label;
  final String value;

  const _MetricBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTokens.space12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: AppTokens.borderRadiusSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 11,
            ),
          ),
          SizedBox(height: AppTokens.space4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _RowsBox extends StatelessWidget {
  final List<MapEntry<String, String>> rows;

  const _RowsBox({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: AppTokens.borderRadiusMedium,
      ),
      child: Column(
        children: rows
            .map(
              (row) => Padding(
                padding: EdgeInsets.symmetric(vertical: AppTokens.space4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      row.key,
                      style:
                          TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                    ),
                    Text(
                      row.value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _MessageBox extends StatelessWidget {
  final String message;

  const _MessageBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTokens.space12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: AppTokens.borderRadiusMedium,
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.white, size: 20),
          SizedBox(width: AppTokens.space8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: 13,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Cta extends StatelessWidget {
  final String label;

  const _Cta({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: AppTokens.space12,
        horizontal: AppTokens.space16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTokens.borderRadiusMedium,
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: context.textStyles.bodyMedium?.copyWith(
          color: AppTokens.primaryColor,
          fontWeight: AppTokens.fontWeightBold,
        ),
      ),
    );
  }
}
