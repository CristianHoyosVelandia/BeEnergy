// ignore_for_file: file_names
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/utils/metodos.dart';
import 'package:flutter/material.dart';
import '../../../models/my_user.dart';

class AprendeScreen extends StatefulWidget {
  final MyUser myUser;

  const AprendeScreen({super.key, required this.myUser});

  @override
  State<AprendeScreen> createState() => _AprendeScreenState();
}

class _AprendeScreenState extends State<AprendeScreen> with SingleTickerProviderStateMixin {
  Metodos metodos = Metodos();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  PreferredSizeWidget _appbar() {
    return AppBar(
      backgroundColor: Theme.of(context).focusColor,
      automaticallyImplyLeading: false,
      leading: InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () async {
          Navigator.pop(context);
        },
        child: Icon(
          Icons.chevron_left_rounded,
          color: Theme.of(context).scaffoldBackgroundColor,
          size: 32,
        ),
      ),
      title: Text(
        "Centro de Aprendizaje",
        style: Metodos.btnTextStyle(context),
      ),
      centerTitle: false,
      elevation: 0,
      bottom: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: Theme.of(context).scaffoldBackgroundColor,
        unselectedLabelColor: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.6),
        indicatorColor: Theme.of(context).scaffoldBackgroundColor,
        labelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        tabs: const [
          Tab(text: 'CREG 101 072'),
          Tab(text: 'Estrategia'),
          Tab(text: 'Renovables'),
          Tab(text: 'Solar'),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> content,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppTokens.space16,
        vertical: AppTokens.space8,
      ),
      padding: EdgeInsets.all(AppTokens.space20),
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
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppTokens.space12),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: AppTokens.borderRadiusSmall,
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              SizedBox(width: AppTokens.space12),
              Expanded(
                child: Text(
                  title,
                  style: context.textStyles.titleLarge?.copyWith(
                    fontWeight: AppTokens.fontWeightBold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space16),
          Divider(height: 1),
          SizedBox(height: AppTokens.space16),
          ...content,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTokens.space12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 4),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: context.colors.primary,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: AppTokens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.textStyles.bodyMedium?.copyWith(
                    fontWeight: AppTokens.fontWeightSemiBold,
                  ),
                ),
                if (value.isNotEmpty) ...[
                  SizedBox(height: AppTokens.space4),
                  Text(
                    value,
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tab 1: Resolución CREG 101 072
  Widget _tabCREG() {
    return ListView(
      padding: EdgeInsets.symmetric(vertical: AppTokens.space16),
      children: [
        _buildSectionCard(
          title: '¿Qué es CREG 101 072 de 2025?',
          icon: Icons.description_outlined,
          iconColor: AppTokens.info,
          content: [
            Text(
              'La Resolución CREG 101 072 de 2025 es el marco regulatorio colombiano que establece las reglas para el funcionamiento de comunidades energéticas con generación distribuida y esquemas de intercambio peer-to-peer (P2P) de energía eléctrica.',
              style: context.textStyles.bodyMedium,
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: AppTokens.space16),
            _buildInfoRow(
              'Organismo Emisor',
              'Comisión de Regulación de Energía y Gas (CREG)',
            ),
            _buildInfoRow('Vigencia', 'Desde enero 2025'),
            _buildInfoRow('Alcance', 'Nacional - Colombia'),
          ],
        ),
        _buildSectionCard(
          title: 'Objetivos Principales',
          icon: Icons.flag_outlined,
          iconColor: AppTokens.energyGreen,
          content: [
            _buildInfoRow(
              'Autogeneración Renovable',
              'Fomentar la autogeneración con fuentes renovables',
            ),
            _buildInfoRow(
              'Intercambios P2P',
              'Permitir intercambios entre prosumidores y consumidores',
            ),
            _buildInfoRow(
              'Solidaridad Energética (PDE)',
              'Establecer un programa de solidaridad energética',
            ),
            _buildInfoRow(
              'Precios Justos',
              'Garantizar precios justos basados en el Valor de Energía (VE)',
            ),
            _buildInfoRow(
              'Trazabilidad',
              'Asegurar trazabilidad y cumplimiento regulatorio',
            ),
          ],
        ),
        _buildSectionCard(
          title: 'Conceptos Clave',
          icon: Icons.lightbulb_outline,
          iconColor: AppTokens.primaryPurple,
          content: [
            _buildInfoRow(
              'Excedentes Tipo 1',
              'Energía destinada al autoconsumo compensado (NO vendible)',
            ),
            _buildInfoRow(
              'Excedentes Tipo 2',
              'Energía disponible para PDE e intercambios P2P (vendible)',
            ),
            _buildInfoRow(
              'PDE (≤10%)',
              'Programa de Distribución de Excedentes - máximo 10% del Tipo 2',
            ),
            _buildInfoRow(
              'VE (Valor de Energía)',
              'Precio de referencia = CU + MC + PCN (±10% para P2P)',
            ),
            _buildInfoRow(
              'NIU',
              'Número de Identificación Única por usuario (ej: NIU-UAO-024-2025)',
            ),
          ],
        ),
      ],
    );
  }

  // Tab 2: Estrategia de Comunidades Energéticas
  Widget _tabEstrategia() {
    return ListView(
      padding: EdgeInsets.symmetric(vertical: AppTokens.space16),
      children: [
        _buildSectionCard(
          title: 'Comunidad Energética UAO',
          icon: Icons.groups_outlined,
          iconColor: AppTokens.primaryBlue,
          content: [
            Text(
              'La comunidad energética UAO está conformada por 15 usuarios del campus universitario que participan en un esquema de generación distribuida con paneles solares fotovoltaicos.',
              style: context.textStyles.bodyMedium,
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: AppTokens.space16),
            _buildInfoRow('Ubicación', 'Campus UAO, Cali, Valle del Cauca, Colombia'),
            _buildInfoRow('Miembros', '15 usuarios (prosumidores y consumidores)'),
            _buildInfoRow('Capacidad Instalada', '~5 kW promedio por prosumidor'),
            _buildInfoRow('Tecnología', 'Paneles solares fotovoltaicos'),
            _buildInfoRow('Medición', 'Medidores bidireccionales (AMI)'),
          ],
        ),
        _buildSectionCard(
          title: 'Proceso Mensual P2P',
          icon: Icons.autorenew_outlined,
          iconColor: AppTokens.energyGreen,
          content: [
            _buildInfoRow(
              'Paso 1: Clasificación',
              'Sistema clasifica excedentes en Tipo 1 (50%) y Tipo 2 (50%)',
            ),
            _buildInfoRow(
              'Paso 2: Asignación PDE',
              'Administrador asigna máximo 10% del Tipo 2 a consumidores',
            ),
            _buildInfoRow(
              'Paso 3: Disponibilidad',
              'Sistema calcula energía disponible P2P = Tipo 2 - PDE cedido',
            ),
            _buildInfoRow(
              'Paso 4: Ofertas',
              'Prosumidores publican ofertas en el marketplace',
            ),
            _buildInfoRow(
              'Paso 5: Marketplace',
              'Consumidores ven y comparan ofertas disponibles',
            ),
            _buildInfoRow(
              'Paso 6: Contratos',
              'Consumidores aceptan ofertas y se crean contratos bilaterales',
            ),
            _buildInfoRow(
              'Paso 7: Liquidación',
              'Sistema liquida mensualmente y calcula ahorros',
            ),
          ],
        ),
        _buildSectionCard(
          title: 'Beneficios del Esquema P2P',
          icon: Icons.trending_up_outlined,
          iconColor: Colors.green,
          content: [
            _buildInfoRow(
              'Ahorro Económico',
              'Entre 10-15% vs tarifa regulada tradicional',
            ),
            _buildInfoRow(
              'Solidaridad Energética',
              'PDE gratuito para consumidores sin generación',
            ),
            _buildInfoRow(
              'Ingresos para Prosumidores',
              'Monetización de excedentes energéticos',
            ),
            _buildInfoRow(
              'Sostenibilidad',
              'Promoción de energía solar renovable',
            ),
            _buildInfoRow(
              'Transparencia',
              'Auditoría completa y trazabilidad regulatoria',
            ),
          ],
        ),
      ],
    );
  }

  // Tab 3: Energía Renovable
  Widget _tabRenovables() {
    return ListView(
      padding: EdgeInsets.symmetric(vertical: AppTokens.space16),
      children: [
        _buildSectionCard(
          title: '¿Qué son las Energías Renovables?',
          icon: Icons.eco_outlined,
          iconColor: Colors.green,
          content: [
            Text(
              'Las energías renovables son fuentes de energía limpia e inagotables que se obtienen de recursos naturales como el sol, el viento, el agua o la biomasa. A diferencia de los combustibles fósiles, no generan emisiones de CO₂ y ayudan a combatir el cambio climático.',
              style: context.textStyles.bodyMedium,
              textAlign: TextAlign.justify,
            ),
          ],
        ),
        _buildSectionCard(
          title: 'Tipos de Energías Renovables',
          icon: Icons.wb_sunny_outlined,
          iconColor: Colors.orange,
          content: [
            _buildInfoRow(
              'Energía Solar',
              'Generación mediante paneles fotovoltaicos (usado en UAO)',
            ),
            _buildInfoRow(
              'Energía Eólica',
              'Generación mediante turbinas de viento',
            ),
            _buildInfoRow(
              'Energía Hidráulica',
              'Generación mediante centrales hidroeléctricas',
            ),
            _buildInfoRow(
              'Biomasa',
              'Energía de materia orgánica renovable',
            ),
            _buildInfoRow(
              'Geotérmica',
              'Energía del calor interno de la Tierra',
            ),
          ],
        ),
        _buildSectionCard(
          title: 'Ventajas de las Renovables',
          icon: Icons.check_circle_outline,
          iconColor: AppTokens.energyGreen,
          content: [
            _buildInfoRow('Cero Emisiones', 'No contaminan ni emiten CO₂'),
            _buildInfoRow('Inagotables', 'Recursos naturales ilimitados'),
            _buildInfoRow('Ahorro a Largo Plazo', 'Menores costos operativos'),
            _buildInfoRow('Independencia Energética', 'Menor dependencia de combustibles fósiles'),
            _buildInfoRow('Generación Distribuida', 'Producción local y descentralizada'),
          ],
        ),
        _buildSectionCard(
          title: 'Contexto en Colombia',
          icon: Icons.flag_outlined,
          iconColor: AppTokens.primaryRed,
          content: [
            Text(
              'Colombia tiene un gran potencial renovable gracias a su ubicación geográfica. La Ley 1715 de 2014 y la Ley 2099 de 2021 promueven la integración de energías renovables no convencionales y la transición energética del país.',
              style: context.textStyles.bodyMedium,
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: AppTokens.space12),
            _buildInfoRow('Ley 1715 de 2014', 'Integración de energías renovables'),
            _buildInfoRow('Ley 2099 de 2021', 'Transición energética y generación distribuida'),
            _buildInfoRow('Meta 2030', 'Aumentar participación de renovables en la matriz energética'),
          ],
        ),
      ],
    );
  }

  // Tab 4: Energía Solar
  Widget _tabSolar() {
    return ListView(
      padding: EdgeInsets.symmetric(vertical: AppTokens.space16),
      children: [
        _buildSectionCard(
          title: '¿Cómo Funciona la Energía Solar?',
          icon: Icons.wb_sunny,
          iconColor: Colors.orange,
          content: [
            Text(
              'Los paneles solares fotovoltaicos convierten la luz del sol en electricidad mediante el efecto fotoeléctrico. Cuando los fotones de luz solar golpean las celdas solares, liberan electrones que generan corriente eléctrica continua (DC), la cual se convierte en corriente alterna (AC) mediante un inversor.',
              style: context.textStyles.bodyMedium,
              textAlign: TextAlign.justify,
            ),
          ],
        ),
        _buildSectionCard(
          title: 'Componentes de un Sistema Solar',
          icon: Icons.solar_power_outlined,
          iconColor: AppTokens.energyGreen,
          content: [
            _buildInfoRow(
              'Paneles Fotovoltaicos',
              'Captan la luz solar y generan electricidad DC',
            ),
            _buildInfoRow(
              'Inversor',
              'Convierte corriente DC en corriente AC utilizable',
            ),
            _buildInfoRow(
              'Medidor Bidireccional',
              'Mide energía generada, consumida, importada y exportada',
            ),
            _buildInfoRow(
              'Estructura de Montaje',
              'Soporta y orienta los paneles hacia el sol',
            ),
            _buildInfoRow(
              'Protecciones Eléctricas',
              'Breakers, fusibles y dispositivos de seguridad',
            ),
          ],
        ),
        _buildSectionCard(
          title: 'Beneficios de la Energía Solar',
          icon: Icons.savings_outlined,
          iconColor: Colors.amber,
          content: [
            _buildInfoRow(
              'Ahorro en Factura',
              'Reducción de hasta 80% en costos de energía',
            ),
            _buildInfoRow(
              'Cero Emisiones',
              'Energía limpia sin contaminación ni CO₂',
            ),
            _buildInfoRow(
              'Independencia Energética',
              'Generación propia y autónoma',
            ),
            _buildInfoRow(
              'Bajo Mantenimiento',
              'Paneles con vida útil de 25+ años',
            ),
            _buildInfoRow(
              'Excedentes Vendibles',
              'Posibilidad de vender energía sobrante (P2P)',
            ),
          ],
        ),
        _buildSectionCard(
          title: 'Energía Solar en la UAO',
          icon: Icons.school_outlined,
          iconColor: AppTokens.primaryBlue,
          content: [
            Text(
              'La Universidad Autónoma de Occidente cuenta con instalaciones solares fotovoltaicas distribuidas en el campus. Los usuarios de la comunidad energética UAO tienen sistemas de ~5 kW promedio, generando energía limpia y participando en intercambios P2P bajo la regulación CREG 101 072.',
              style: context.textStyles.bodyMedium,
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: AppTokens.space12),
            _buildInfoRow('Capacidad Individual', '~5 kW por prosumidor'),
            _buildInfoRow('Tecnología', 'Paneles fotovoltaicos monocristalinos'),
            _buildInfoRow('Generación Promedio', '320 kWh/mes por prosumidor'),
            _buildInfoRow('Excedentes', 'Clasificados en Tipo 1 y Tipo 2 según CREG'),
          ],
        ),
      ],
    );
  }

  Widget _body() {
    return TabBarView(
      controller: _tabController,
      children: [
        _tabCREG(),
        _tabEstrategia(),
        _tabRenovables(),
        _tabSolar(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbar(),
      backgroundColor: Theme.of(context).focusColor,
      body: _body(),
    );
  }
}
