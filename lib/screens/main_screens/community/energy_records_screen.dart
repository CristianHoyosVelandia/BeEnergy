import 'package:flutter/material.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/utils/formatters.dart';
import '../../../data/fake_data.dart';
import '../../../models/energy_models.dart';

/// Pantalla de Registro Energético Mensual
/// Muestra el detalle de generación y consumo de todos los miembros - Noviembre 2025
class EnergyRecordsScreen extends StatefulWidget {
  const EnergyRecordsScreen({super.key});

  @override
  State<EnergyRecordsScreen> createState() => _EnergyRecordsScreenState();
}

class _EnergyRecordsScreenState extends State<EnergyRecordsScreen> {
  String _sortBy = 'balance'; // 'balance', 'generation', 'consumption'
  bool _ascending = false;

  List<EnergyRecord> get sortedRecords {
    var records = List<EnergyRecord>.from(FakeData.energyRecords);

    switch (_sortBy) {
      case 'generation':
        records.sort((a, b) => _ascending
          ? a.energyGenerated.compareTo(b.energyGenerated)
          : b.energyGenerated.compareTo(a.energyGenerated));
        break;
      case 'consumption':
        records.sort((a, b) => _ascending
          ? a.energyConsumed.compareTo(b.energyConsumed)
          : b.energyConsumed.compareTo(a.energyConsumed));
        break;
      case 'balance':
      default:
        records.sort((a, b) => _ascending
          ? a.netBalance.compareTo(b.netBalance)
          : b.netBalance.compareTo(a.netBalance));
        break;
    }

    return records;
  }

  Widget _buildHeader() {
    final stats = FakeData.communityStats;

    return Container(
      margin: EdgeInsets.all(AppTokens.space16),
      padding: EdgeInsets.all(AppTokens.space20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTokens.primaryRed,
            AppTokens.primaryRed.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppTokens.borderRadiusLarge,
        boxShadow: [
          BoxShadow(
            color: AppTokens.primaryRed.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month_outlined, color: Colors.white, size: 32),
              SizedBox(width: AppTokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Registro Energético',
                      style: context.textStyles.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: AppTokens.fontWeightBold,
                      ),
                    ),
                    SizedBox(height: AppTokens.space4),
                    Text(
                      'Noviembre 2025 • Comunidad UAO',
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space20),
          Row(
            children: [
              Expanded(
                child: _buildHeaderStat(
                  'Total Generado',
                  Formatters.formatEnergy(stats.totalEnergyGenerated),
                  Icons.wb_sunny_outlined,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildHeaderStat(
                  'Total Consumido',
                  Formatters.formatEnergy(stats.totalEnergyConsumed),
                  Icons.flash_on_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        SizedBox(height: AppTokens.space8),
        Text(
          value,
          style: context.textStyles.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: AppTokens.fontWeightBold,
          ),
        ),
        SizedBox(height: AppTokens.space4),
        Text(
          label,
          style: context.textStyles.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSortOptions() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
      child: Row(
        children: [
          Text(
            'Ordenar por:',
            style: context.textStyles.bodyMedium?.copyWith(
              fontWeight: AppTokens.fontWeightMedium,
            ),
          ),
          SizedBox(width: AppTokens.space12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSortChip('Balance', 'balance'),
                  SizedBox(width: AppTokens.space8),
                  _buildSortChip('Generación', 'generation'),
                  SizedBox(width: AppTokens.space8),
                  _buildSortChip('Consumo', 'consumption'),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              _ascending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              color: context.colors.primary,
            ),
            onPressed: () {
              setState(() {
                _ascending = !_ascending;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = _sortBy == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _sortBy = value;
        });
      },
      backgroundColor: context.colors.surface,
      selectedColor: AppTokens.primaryRed,
      labelStyle: context.textStyles.bodyMedium?.copyWith(
        color: isSelected ? Colors.white : context.colors.onSurface,
        fontWeight: isSelected ? AppTokens.fontWeightBold : AppTokens.fontWeightMedium,
      ),
      side: BorderSide(
        color: isSelected ? AppTokens.primaryRed : context.colors.outline.withValues(alpha: 0.3),
        width: isSelected ? 2 : 1,
      ),
    );
  }

  Widget _buildRecordsList() {
    final records = sortedRecords;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: AppTokens.space16),
      itemCount: records.length,
      separatorBuilder: (context, index) => SizedBox(height: AppTokens.space12),
      itemBuilder: (context, index) {
        final record = records[index];
        return _buildRecordCard(record, index + 1);
      },
    );
  }

  Widget _buildRecordCard(EnergyRecord record, int position) {
    final member = FakeData.members.firstWhere(
      (m) => m.userId == record.userId,
      orElse: () => FakeData.members.first,
    );

    final isPositiveBalance = record.netBalance >= 0;

    return Container(
      padding: EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppTokens.borderRadiusMedium,
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con ranking y nombre
          Row(
            children: [
              // Ranking badge
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: position <= 3
                    ? AppTokens.primaryRed.withValues(alpha: 0.15)
                    : context.colors.surfaceContainerHighest,
                  borderRadius: AppTokens.borderRadiusSmall,
                ),
                child: Center(
                  child: Text(
                    '#$position',
                    style: context.textStyles.labelMedium?.copyWith(
                      color: position <= 3 ? AppTokens.primaryRed : context.colors.onSurfaceVariant,
                      fontWeight: AppTokens.fontWeightBold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppTokens.space12),
              // Nombre y tipo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.userName,
                      style: context.textStyles.titleMedium?.copyWith(
                        fontWeight: AppTokens.fontWeightBold,
                      ),
                    ),
                    SizedBox(height: AppTokens.space4),
                    Row(
                      children: [
                        Icon(
                          member.isProsumer ? Icons.solar_power : Icons.home,
                          size: 14,
                          color: context.colors.onSurfaceVariant,
                        ),
                        SizedBox(width: AppTokens.space4),
                        Text(
                          member.isProsumer ? 'Prosumidor' : 'Consumidor',
                          style: context.textStyles.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Balance badge
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTokens.space12,
                  vertical: AppTokens.space8,
                ),
                decoration: BoxDecoration(
                  color: isPositiveBalance
                    ? Colors.green.withValues(alpha: 0.1)
                    : AppTokens.error.withValues(alpha: 0.1),
                  borderRadius: AppTokens.borderRadiusMedium,
                ),
                child: Column(
                  children: [
                    Text(
                      'Balance',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: AppTokens.space4),
                    Text(
                      Formatters.formatEnergy(record.netBalance.abs()),
                      style: context.textStyles.titleSmall?.copyWith(
                        color: isPositiveBalance ? Colors.green : AppTokens.error,
                        fontWeight: AppTokens.fontWeightBold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space16),
          Divider(height: 1, color: context.colors.outline.withValues(alpha: 0.1)),
          SizedBox(height: AppTokens.space16),
          // Métricas en grid
          Row(
            children: [
              Expanded(
                child: _buildMetric(
                  'Generación',
                  Formatters.formatEnergy(record.energyGenerated),
                  Icons.wb_sunny_outlined,
                  Colors.orange,
                ),
              ),
              SizedBox(width: AppTokens.space12),
              Expanded(
                child: _buildMetric(
                  'Consumo',
                  Formatters.formatEnergy(record.energyConsumed),
                  Icons.flash_on_outlined,
                  AppTokens.error,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space12),
          Row(
            children: [
              Expanded(
                child: _buildMetric(
                  'Exportado',
                  Formatters.formatEnergy(record.energyExported),
                  Icons.upload_outlined,
                  Colors.green,
                ),
              ),
              SizedBox(width: AppTokens.space12),
              Expanded(
                child: _buildMetric(
                  'Importado',
                  Formatters.formatEnergy(record.energyImported),
                  Icons.download_outlined,
                  Colors.blue,
                ),
              ),
            ],
          ),
          if (member.isProsumer && record.energyGenerated > 0) ...[
            SizedBox(height: AppTokens.space12),
            _buildProgressBar(
              'Autoconsumo',
              record.selfConsumption,
              record.energyGenerated,
            ),
          ],
          // ⭐ NUEVO: Clasificación de Excedentes CREG 101 072
          if (member.isProsumer && record.totalSurplus > 0) ...[
            SizedBox(height: AppTokens.space16),
            Divider(height: 1, color: context.colors.outline.withValues(alpha: 0.1)),
            SizedBox(height: AppTokens.space16),
            // Header de clasificación
            Row(
              children: [
                Icon(Icons.verified_outlined, size: 16, color: AppTokens.info),
                SizedBox(width: AppTokens.space8),
                Text(
                  'Clasificación CREG 101 072',
                  style: context.textStyles.bodySmall?.copyWith(
                    color: AppTokens.info,
                    fontWeight: AppTokens.fontWeightSemiBold,
                  ),
                ),
                const Spacer(),
                _buildClassificationChip(record.classification),
              ],
            ),
            SizedBox(height: AppTokens.space12),
            // Tipo 1 y Tipo 2
            Row(
              children: [
                Expanded(
                  child: _buildSurplusMetric(
                    'Tipo 1',
                    'Autoconsumo',
                    record.surplusType1,
                    AppTokens.primaryPurple,
                  ),
                ),
                SizedBox(width: AppTokens.space12),
                Expanded(
                  child: _buildSurplusMetric(
                    'Tipo 2',
                    'PDE/P2P',
                    record.surplusType2,
                    AppTokens.energyGreen,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(AppTokens.space12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: AppTokens.borderRadiusSmall,
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: AppTokens.space8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.textStyles.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: AppTokens.space4),
                Text(
                  value,
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: AppTokens.fontWeightBold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, double value, double max) {
    final percentage = max > 0 ? (value / max) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: context.textStyles.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            Text(
              '${(percentage * 100).toStringAsFixed(0)}%',
              style: context.textStyles.bodySmall?.copyWith(
                color: AppTokens.primaryRed,
                fontWeight: AppTokens.fontWeightBold,
              ),
            ),
          ],
        ),
        SizedBox(height: AppTokens.space8),
        ClipRRect(
          borderRadius: AppTokens.borderRadiusSmall,
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: context.colors.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(AppTokens.primaryRed),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  /// Construye chip de clasificación de excedentes
  Widget _buildClassificationChip(SurplusClassificationType classification) {
    String label;
    Color color;
    IconData icon;

    switch (classification) {
      case SurplusClassificationType.mixed:
        label = 'Mixto';
        color = AppTokens.info;
        icon = Icons.swap_horiz;
        break;
      case SurplusClassificationType.type1Only:
        label = 'Solo Tipo 1';
        color = AppTokens.primaryPurple;
        icon = Icons.person;
        break;
      case SurplusClassificationType.type2Only:
        label = 'Solo Tipo 2';
        color = AppTokens.energyGreen;
        icon = Icons.groups;
        break;
      case SurplusClassificationType.none:
        label = 'Sin excedentes';
        color = context.colors.onSurfaceVariant;
        icon = Icons.remove_circle_outline;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTokens.space8,
        vertical: AppTokens.space4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppTokens.borderRadiusSmall,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: AppTokens.space4),
          Text(
            label,
            style: context.textStyles.bodySmall?.copyWith(
              color: color,
              fontWeight: AppTokens.fontWeightSemiBold,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye métrica de excedente (Tipo 1 o Tipo 2)
  Widget _buildSurplusMetric(
    String type,
    String subtitle,
    double value,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(AppTokens.space12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: AppTokens.borderRadiusSmall,
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppTokens.space4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: AppTokens.borderRadiusSmall,
                ),
                child: Icon(
                  type == 'Tipo 1' ? Icons.person : Icons.people,
                  color: color,
                  size: 16,
                ),
              ),
              SizedBox(width: AppTokens.space8),
              Text(
                type,
                style: context.textStyles.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: AppTokens.fontWeightBold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space8),
          Text(
            subtitle,
            style: context.textStyles.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppTokens.space4),
          Text(
            Formatters.formatEnergy(value),
            style: context.textStyles.titleMedium?.copyWith(
              color: color,
              fontWeight: AppTokens.fontWeightBold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro Energético'),
        elevation: 0,
        backgroundColor: context.colors.surface,
      ),
      backgroundColor: context.colors.surfaceContainerLowest,
      body: ListView(
        padding: EdgeInsets.only(bottom: AppTokens.space24),
        children: [
          SizedBox(height: AppTokens.space16),
          _buildHeader(),
          SizedBox(height: AppTokens.space16),
          _buildSortOptions(),
          SizedBox(height: AppTokens.space16),
          _buildRecordsList(),
        ],
      ),
    );
  }
}
