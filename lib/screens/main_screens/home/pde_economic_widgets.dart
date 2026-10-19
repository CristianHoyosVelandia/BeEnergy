import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/utils/formatters.dart';
import 'package:be_energy/models/pde_cobro_resumen.dart';
import 'package:be_energy/models/pde_economic_summary.dart';
import 'package:flutter/material.dart';

// Los acentos se resuelven al construir para respetar el color de cada comunidad.
const _ink = Color(0xFF0F172A);
const _muted = Color(0xFF64748B);

String _money(double value) => Formatters.formatCurrency(value);
String _energy(double value) => Formatters.formatEnergy(value, decimals: 2);
String _percent(double rate) =>
    '${Formatters.formatNumber(rate * 100, decimals: 2)}%';

class PdeEconomicChargeContent extends StatelessWidget {
  final PdeCobroResumen charge;
  final String periodDisplayName;
  final VoidCallback onCompare;
  final VoidCallback onSimulatePayment;
  final bool isPaid;
  final bool isSubmitting;

  const PdeEconomicChargeContent({
    super.key,
    required this.charge,
    required this.periodDisplayName,
    required this.onCompare,
    required this.onSimulatePayment,
    required this.isPaid,
    required this.isSubmitting,
  });

  @override
  Widget build(BuildContext context) {
    final economics = charge.economics!;
    final bill = economics.withMarket;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Heading(title: 'Tu energía, en detalle:', subtitle: periodDisplayName),
        const SizedBox(height: 12),
        _CalculationStatus(charge: charge),
        const SizedBox(height: 20),
        _Surface(
          color: AppTokens.primaryColor,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Text('TOTAL MENSUAL',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1)),
            const SizedBox(height: 12),
            Text(_money(bill.total),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text(
                'Energía comunitaria + comercialización + red y contribución, cuando aplican.',
                style: TextStyle(color: Colors.white70, height: 1.5)),
            if (bill.total > 0) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: isSubmitting || isPaid ? null : onSimulatePayment,
                icon: isSubmitting
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppTokens.primaryColor))
                    : Icon(isPaid
                        ? Icons.check_circle_outline
                        : Icons.touch_app_outlined),
                label: Text(isPaid ? 'Simulación registrada' : 'Simular pago'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTokens.primaryColor,
                  disabledBackgroundColor: Colors.white.withValues(alpha: 0.8),
                  disabledForegroundColor: AppTokens.primaryColor,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                      borderRadius: AppTokens.borderRadiusLarge),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                  'La simulación corresponde al total mensual y no registra un pago real.',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 12, height: 1.4)),
            ],
          ]),
        ),
        const SizedBox(height: 16),
        _Surface(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _SectionTitle(
              icon: Icons.bolt_rounded,
              title: 'Así cubriste tu consumo',
              color: AppTokens.primaryColor),
          const SizedBox(height: 16),
          _ValueLine(
              label: 'Consumo del periodo',
              value: _energy(economics.energy.value('consumption_kwh'))),
          if (bill.communityUsedKwh > 0)
            _ValueLine(
                label: 'Energía comunitaria utilizada',
                value: _energy(bill.communityUsedKwh)),
          if (economics.hasFreeRight && bill.freeRightUsedKwh > 0)
            _ValueLine(
                label: 'Derecho gratuito utilizado',
                value: _energy(bill.freeRightUsedKwh),
                color: AppTokens.primaryColor),
          if (bill.communityPaidKwh > 0)
            _ValueLine(
                label: economics.hasFreeRight
                    ? 'Adicional comunitario utilizado'
                    : 'Energía comunitaria pagada',
                value: _energy(bill.communityPaidKwh)),
          if (bill.gridKwh > 0)
            _ValueLine(
                label: 'Faltante comprado a la red',
                value: _energy(bill.gridKwh)),
          if (economics.hasFreeRight && bill.freeRightUsedKwh > 0)
            const Text(
                'El derecho gratuito no tiene costo de energía; la energía utilizada sí genera comercialización.',
                style: TextStyle(color: _muted, fontSize: 12, height: 1.5)),
        ])),
        const SizedBox(height: 16),
        _Surface(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const _SectionTitle(
              icon: Icons.receipt_long_outlined, title: 'Desglose del periodo'),
          const SizedBox(height: 8),
          _BillDetails(economics: economics, bill: bill),
        ])),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: onCompare,
          icon: const Icon(Icons.bar_chart_rounded),
          label: const Text('Comparar escenarios y ahorros'),
          style: OutlinedButton.styleFrom(
              foregroundColor: AppTokens.primaryColor,
              side: BorderSide(color: AppTokens.primaryColor),
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                  borderRadius: AppTokens.borderRadiusLarge)),
        ),
        const SizedBox(height: 16),
        if (economics.energy.value('type2_surplus_kwh') > 0) ...[
          _Type2SurplusDetails(charge: charge),
          const SizedBox(height: 16),
        ],
        _AllocationDetails(economics: economics),
        const SizedBox(height: 16),
        const _CalculationNote(),
      ],
    );
  }
}

class PdeEconomicSavingsContent extends StatelessWidget {
  final PdeCobroResumen charge;
  final String periodDisplayName;

  const PdeEconomicSavingsContent(
      {super.key, required this.charge, required this.periodDisplayName});

  @override
  Widget build(BuildContext context) {
    final economics = charge.economics!;
    final totalSavings = economics.benefits.value('savings_with_market');
    final extraSavings = economics.benefits.value('additional_savings');
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _Heading(
          title: 'Tu energía en tres escenarios',
          subtitle:
              '$periodDisplayName · ${_energy(economics.energy.value('consumption_kwh'))} consumidos'),
      const SizedBox(height: 12),
      _CalculationStatus(charge: charge),
      const SizedBox(height: 16),
      const Text(
          'Comparamos el mismo consumo. Solo cambia cómo se cubre y cuánto cuesta.',
          style: TextStyle(color: _muted, height: 1.5)),
      const SizedBox(height: 20),
      _ScenarioCard(
          number: '01',
          title: 'Mercado tradicional',
          description: 'Todo tu consumo se compra a la red.',
          economics: economics,
          bill: economics.traditional,
          color: AppTokens.primaryColor),
      const SizedBox(height: 12),
      _ScenarioCard(
          number: '02',
          title: 'Comunidad sin mercado interno',
          description: 'Conservas la asignación original, sin redistribución.',
          economics: economics,
          bill: economics.withoutMarket,
          color: AppTokens.primaryColor),
      const SizedBox(height: 12),
      _ScenarioCard(
          number: '03',
          title: 'Comunidad con mercado interno',
          description: 'Usas la asignación final de este periodo.',
          economics: economics,
          bill: economics.withMarket,
          color: AppTokens.primaryColor,
          selected: true),
      const SizedBox(height: 24),
      _SectionTitle(
          icon: Icons.savings_outlined,
          title: 'Tu beneficio personal',
          color: AppTokens.primaryColor),
      const SizedBox(height: 12),
      _BenefitCard(
        title: totalSavings < 0
            ? 'Sobrecosto frente al tradicional'
            : 'Ahorro frente al tradicional',
        value: totalSavings,
        description:
            'Mercado tradicional comparado con comunidad con mercado interno.',
      ),
      const SizedBox(height: 12),
      _BenefitCard(
        title: extraSavings < 0
            ? 'Sobrecosto del mercado interno'
            : 'Ahorro adicional del mercado interno',
        value: extraSavings,
        description: extraSavings < 0
            ? 'Este periodo cuesta más que conservar la asignación original. El ahorro total se muestra por separado.'
            : 'Beneficio de la redistribución frente a comunidad sin mercado interno.',
      ),
      const SizedBox(height: 20),
      if (economics.energy.value('type2_surplus_kwh') > 0) ...[
        _Type2SurplusDetails(charge: charge),
        const SizedBox(height: 16),
      ],
      if (economics.benefits.value('supplier_revenue') > 0)
        _Surface(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _SectionTitle(
              icon: Icons.groups_outlined,
              title: 'Beneficio comunitario',
              color: AppTokens.primaryColor),
          const SizedBox(height: 8),
          Text('Beneficiario: ${economics.beneficiaryLabel}',
              style: const TextStyle(color: _muted)),
          const SizedBox(height: 16),
          _ValueLine(
              label: 'Ingreso por energía pagada',
              value: _money(economics.benefits.value('supplier_revenue'))),
          if (!charge.defaultedEconomicParameters.contains('spot_kwh')) ...[
            _ValueLine(
                label: 'Referencia de venta a bolsa',
                value: _money(
                    economics.benefits.value('supplier_spot_reference'))),
            _ValueLine(
                label: 'Diferencia frente a bolsa',
                value:
                    _money(economics.benefits.value('supplier_margin_vs_spot')),
                color: AppTokens.primaryColor),
          ],
          const SizedBox(height: 4),
          const Text(
              'Corresponde a la energía pagada de tu liquidación; no es un cobro adicional ni el total de toda la comunidad.',
              style: TextStyle(color: _muted, fontSize: 12, height: 1.5)),
        ])),
      const SizedBox(height: 16),
      const _CalculationNote(),
    ]);
  }
}

class _Heading extends StatelessWidget {
  final String title;
  final String subtitle;
  const _Heading({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: context.textStyles.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w600, color: _ink)),
        const SizedBox(height: 8),
        Text(subtitle, style: const TextStyle(color: _muted, height: 1.4)),
      ]);
}

class _Surface extends StatelessWidget {
  final Widget child;
  final Color color;
  final Color? borderColor;
  const _Surface(
      {required this.child, this.color = Colors.white, this.borderColor});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: color,
            borderRadius: AppTokens.borderRadiusXLarge,
            border: Border.all(color: borderColor ?? const Color(0xFFE2E8F0))),
        child: child,
      );
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  const _SectionTitle(
      {required this.icon, required this.title, this.color = _ink});

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 10),
        Expanded(
            child: Text(title,
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w700, color: color))),
      ]);
}

class _ValueLine extends StatelessWidget {
  final String label;
  final String value;
  final String? formula;
  final Color color;
  const _ValueLine(
      {required this.label,
      required this.value,
      this.formula,
      this.color = _ink});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        // Wrap permite valores largos y texto ampliado sin desbordar en teléfonos pequeños.
        child: LayoutBuilder(builder: (context, constraints) {
          final stacked = constraints.maxWidth < 300 ||
              MediaQuery.textScalerOf(context).scale(14) > 19;
          final description =
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(color: _muted, height: 1.35)),
            if (formula != null) ...[
              const SizedBox(height: 4),
              Text(formula!,
                  style: const TextStyle(
                      color: _muted, fontSize: 12, height: 1.4)),
            ],
          ]);
          final amount = Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w700, fontSize: 15));
          if (stacked) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [description, const SizedBox(height: 5), amount]);
          }
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(flex: 3, child: description),
            const SizedBox(width: 12),
            Flexible(
                flex: 2,
                child: Align(alignment: Alignment.topRight, child: amount))
          ]);
        }),
      );
}

class _BillDetails extends StatelessWidget {
  final PdeEconomicSummary economics;
  final PdeBillScenario bill;
  const _BillDetails({required this.economics, required this.bill});

  @override
  Widget build(BuildContext context) {
    final p = economics.parameters;
    String formula(double quantity, double price) =>
        '${_energy(quantity)} × ${_money(price)}/kWh';
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (bill.freeRightUsedKwh > 0)
        _ValueLine(
            label: 'Energía por derecho comunitario',
            value: _money(0),
            formula: '${_energy(bill.freeRightUsedKwh)} sin costo de energía',
            color: AppTokens.primaryColor),
      if (bill.communityPaidKwh > 0)
        _ValueLine(
            label: economics.hasFreeRight
                ? 'Energía comunitaria adicional'
                : 'Energía comunitaria',
            value: _money(bill.communityEnergyValue),
            formula: formula(bill.communityPaidKwh, p.value('price_per_kwh'))),
      if (bill.communityUsedKwh > 0)
        _ValueLine(
            label: 'Comercialización',
            value: _money(bill.commercializationValue),
            formula: formula(bill.communityUsedKwh,
                p.value('commercialization_cost_per_kwh'))),
      if (bill.gridSubsidizedKwh > 0)
        _ValueLine(
            label: 'Red subsidiada',
            value: _money(bill.gridSubsidizedValue),
            formula: formula(bill.gridSubsidizedKwh,
                p.value('subsidized_grid_price_per_kwh'))),
      if (bill.gridFullKwh > 0)
        _ValueLine(
            label: 'Red a tarifa plena',
            value: _money(bill.gridFullValue),
            formula: formula(bill.gridFullKwh, p.value('grid_price_per_kwh'))),
      if (p.value('solidarity_contribution_rate') > 0) ...[
        const Divider(height: 24),
        _ValueLine(label: 'Subtotal', value: _money(bill.subtotal)),
        _ValueLine(
            label:
                'Contribución solidaria · ${_percent(p.value('solidarity_contribution_rate'))}',
            value: _money(bill.contributionValue),
            formula:
                '${_money(bill.subtotal)} × ${_percent(p.value('solidarity_contribution_rate'))}'),
      ],
      const Divider(height: 24),
      _ValueLine(
          label: 'Total mensual',
          value: _money(bill.total),
          color: AppTokens.primaryColor),
    ]);
  }
}

class _ScenarioCard extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  final PdeEconomicSummary economics;
  final PdeBillScenario bill;
  final Color color;
  final bool selected;
  const _ScenarioCard(
      {required this.number,
      required this.title,
      required this.description,
      required this.economics,
      required this.bill,
      required this.color,
      this.selected = false});

  @override
  Widget build(BuildContext context) => _Surface(
        color: selected
            ? AppTokens.primaryColor.withValues(alpha: 0.06)
            : Colors.white,
        borderColor:
            selected ? AppTokens.primaryColor.withValues(alpha: 0.4) : null,
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12)),
                child: Text(number,
                    style:
                        TextStyle(color: color, fontWeight: FontWeight.w800))),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title,
                      style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w800,
                          fontSize: 17)),
                  const SizedBox(height: 6),
                  Text(description,
                      style: const TextStyle(
                          color: _muted, fontSize: 13, height: 1.4)),
                ])),
          ]),
          const SizedBox(height: 18),
          Text(_money(bill.total),
              style: TextStyle(
                  color: color, fontSize: 30, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
              '${_energy(bill.communityUsedKwh)} comunitarios · ${_energy(bill.gridKwh)} de red',
              style: const TextStyle(color: _muted, fontSize: 12, height: 1.4)),
          const SizedBox(height: 8),
          Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                title: Text('Ver desglose',
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
                children: [_BillDetails(economics: economics, bill: bill)],
              )),
        ]),
      );
}

class _BenefitCard extends StatelessWidget {
  final String title;
  final double value;
  final String description;
  const _BenefitCard(
      {required this.title, required this.value, required this.description});

  @override
  Widget build(BuildContext context) {
    final color = value < 0 ? AppTokens.warning : AppTokens.primaryColor;
    return _Surface(
        color: color.withValues(alpha: 0.07),
        borderColor: color.withValues(alpha: 0.2),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: TextStyle(color: color, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          // El título identifica el sobrecosto; el importe se muestra positivo para su lectura.
          Text(_money(value.abs()),
              style: TextStyle(
                  color: color, fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(description,
              style: const TextStyle(color: _muted, height: 1.5, fontSize: 13)),
        ]));
  }
}

class _Type2SurplusDetails extends StatelessWidget {
  final PdeCobroResumen charge;
  const _Type2SurplusDetails({required this.charge});

  @override
  Widget build(BuildContext context) {
    final economics = charge.economics!;
    final quantity = economics.energy.value('type2_surplus_kwh');
    final spot = economics.parameters.value('spot_price_per_kwh');
    final hasSpot = !charge.defaultedEconomicParameters.contains('spot_kwh');
    return _Surface(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionTitle(
          icon: Icons.solar_power_outlined,
          title: 'Excedentes tipo II',
          color: AppTokens.primaryColor),
      const SizedBox(height: 12),
      _ValueLine(
          label: 'Remanente de tu asignación final',
          value: _energy(quantity),
          formula:
              '${_energy(economics.energy.value('final_allocation_kwh'))} asignados − ${_energy(economics.energy.value('consumption_kwh'))} consumidos'),
      if (hasSpot) ...[
        _ValueLine(label: 'Precio de bolsa', value: '${_money(spot)}/kWh'),
        _ValueLine(
            label: 'Valor de excedentes tipo II',
            value: _money(economics.benefits.value('type2_surplus_value')),
            formula: '${_energy(quantity)} × ${_money(spot)}/kWh',
            color: AppTokens.primaryColor),
      ] else
        const Text(
            'Falta configurar el precio de bolsa para valorar este remanente.',
            style: TextStyle(color: _muted, height: 1.5)),
      const SizedBox(height: 8),
      Text(
          'Beneficiario: ${economics.beneficiaryLabel}. Este valor es independiente del aporte aplicado al PDE y no se descuenta de tu total mensual.',
          style: const TextStyle(color: _muted, fontSize: 12, height: 1.5)),
    ]));
  }
}

class _AllocationDetails extends StatelessWidget {
  final PdeEconomicSummary economics;
  const _AllocationDetails({required this.economics});

  @override
  Widget build(BuildContext context) => _Surface(
          child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          title: const Text('Tu asignación de energía',
              style: TextStyle(fontWeight: FontWeight.w700, color: _ink)),
          subtitle: const Text('Consulta el detalle del periodo',
              style: TextStyle(fontSize: 12, color: _muted)),
          children: [
            _ValueLine(
                label: 'Asignación original',
                value:
                    _energy(economics.energy.value('original_allocation_kwh'))),
            _ValueLine(
                label: 'Asignación final',
                value: _energy(economics.energy.value('final_allocation_kwh'))),
            if (economics.allocation.flag('renunciation_applied') &&
                economics.energy.value('contributed_kwh') > 0)
              _ValueLine(
                  label: 'Aporte aplicado al PDE',
                  value: _energy(economics.energy.value('contributed_kwh'))),
            if (economics.allocation.flag('renunciation_pending_application'))
              const Text(
                  'Hay un aporte aceptado que no coincide con la asignación aplicada. El detalle usa la asignación registrada; se debe revisar ese movimiento.',
                  style: TextStyle(color: _muted, height: 1.5, fontSize: 12)),
            if (economics.hasFreeRight)
              const Text(
                  'Tu derecho no tiene costo de energía. La energía utilizada sí genera comercialización. Consumir menos no reduce tu PDE: el remanente se muestra aparte como excedente tipo II.',
                  style: TextStyle(color: _muted, height: 1.5, fontSize: 12)),
          ],
        ),
      ));
}

class _CalculationStatus extends StatelessWidget {
  final PdeCobroResumen charge;
  const _CalculationStatus({required this.charge});

  @override
  Widget build(BuildContext context) {
    final status = charge.calculationStatus == 'definitive'
        ? 'Cálculo definitivo'
        : charge.calculationStatus == 'reconciled'
            ? 'Cálculo conciliado'
            : 'Cálculo estimado';
    return Wrap(spacing: 8, runSpacing: 8, children: [
      _Badge(label: status, icon: Icons.calculate_outlined),
      if (charge.defaultedEconomicParameters.isNotEmpty)
        const _Badge(
            label: 'Con parámetros de referencia', icon: Icons.info_outline),
    ]);
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final IconData icon;
  const _Badge({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
            color: AppTokens.primaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 15, color: AppTokens.primaryColor),
          const SizedBox(width: 6),
          Flexible(
              child: Text(label,
                  style: TextStyle(
                      color: AppTokens.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)))
        ]),
      );
}

class _CalculationNote extends StatelessWidget {
  const _CalculationNote();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Text(
            'El total mensual incluye los conceptos desglosados. Los ingresos por excedentes se muestran por separado y no reemplazan la factura del comercializador.',
            style: TextStyle(color: _muted, fontSize: 12, height: 1.5)),
      );
}
