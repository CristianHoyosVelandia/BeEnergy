import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/utils/metodos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../../../routes.dart';
import '../Dinero/card_screen.dart';

class TradingScreen extends StatefulWidget {
  const TradingScreen({super.key});

  @override
  State<TradingScreen> createState() => _TradingScreenState();
}

class _TradingScreenState extends State<TradingScreen> {
  Metodos metodos = Metodos();

  /// AppBar personalizado con gradiente
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0.0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              blurRadius: 6,
              color: Color(0x4B1A1F24),
              offset: Offset(0, 2),
            )
          ],
          gradient: Metodos.gradientClasic(context),
        ),
      ),
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Transferir',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w400,
          letterSpacing: 1.5
        ),
      ),
      centerTitle: true,
    );
  }

  /// Título de sección (siguiendo patrón de HomeScreen)
  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppTokens.space16,
        bottom: AppTokens.space12,
        top: AppTokens.space8,
      ),
      child: Text(
        title,
        style: context.textStyles.titleLarge?.copyWith(
          fontWeight: AppTokens.fontWeightBold,
        ),
      ),
    );
  }

  /// Imagen ilustrativa
  Widget _image() {
    return Padding(
      padding: EdgeInsets.only(
        top: AppTokens.space16,
        bottom: AppTokens.space8,
      ),
      child: Image(
        alignment: AlignmentDirectional.center,
        image: const AssetImage("assets/img/5.png"),
        width: context.width * 0.75,
        height: 200,
      ),
    );
  }

  /// Card de balance (estilo mejorado siguiendo patrón home)
  Widget _balanceCard() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppTokens.space16,
        vertical: AppTokens.space12,
      ),
      padding: EdgeInsets.all(AppTokens.space20),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black.withValues(alpha: 0.15),
            offset: const Offset(0, 4),
          )
        ],
        gradient: Metodos.gradientClasic(context),
        borderRadius: AppTokens.borderRadiusLarge,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con icono
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppTokens.space8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: AppTokens.borderRadiusSmall,
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: AppTokens.space12),
              Text(
                "Saldo Disponible",
                style: context.textStyles.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: AppTokens.fontWeightSemiBold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space20),
          // Amount
          Text(
            "\$ 333.333",
            style: context.textStyles.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: AppTokens.fontWeightBold,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: AppTokens.space24),
          Divider(color: Colors.white.withValues(alpha: 0.3), height: 1),
          SizedBox(height: AppTokens.space16),
          // Card info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tarjeta",
                    style: context.textStyles.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  SizedBox(height: AppTokens.space4),
                  Text(
                    "* **** 0149 *",
                    style: context.textStyles.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: AppTokens.fontWeightMedium,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Vence",
                    style: context.textStyles.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  SizedBox(height: AppTokens.space4),
                  Text(
                    "05/25",
                    style: context.textStyles.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: AppTokens.fontWeightMedium,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: AppTokens.space12),
          // Card holder
          Text(
            "CRISTIAN HOYOS",
            style: context.textStyles.bodyLarge?.copyWith(
              color: Colors.white,
              fontWeight: AppTokens.fontWeightSemiBold,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Botón de acción (mejorado con estilo home)
  Widget _actionButton(int action, String titulo, IconData icon, Color iconColor) {
    return Expanded(
      flex: 1,
      child: InkWell(
        onTap: () {
          switch (action) {
            case 1:
              context.push(const EEscreen());
              break;
            case 2:
              context.push(const Cardscreen());
              break;
            default:
              context.push(const TradingScreen());
              break;
          }
        },
        borderRadius: AppTokens.borderRadiusMedium,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppTokens.space12,
            vertical: AppTokens.space20,
          ),
          margin: EdgeInsets.symmetric(horizontal: AppTokens.space8),
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
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(AppTokens.space12),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: AppTokens.borderRadiusSmall,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: iconColor,
                ),
              ),
              SizedBox(height: AppTokens.space12),
              Text(
                titulo,
                style: context.textStyles.titleMedium?.copyWith(
                  fontWeight: AppTokens.fontWeightMedium,
                  fontSize:  AppTokens.fontSize14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Sección de actividades (mejorada)
  Widget _actividades() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppTokens.space8,
        vertical: AppTokens.space12,
      ),
      child: Row(
        children: [
          _actionButton(1, "Energía", Icons.energy_savings_leaf, AppTokens.energyGreen),
          _actionButton(2, "Dinero", Icons.account_balance, AppTokens.primaryBlue),
        ],
      ),
    );
  }

  /// SpeedDial flotante (mejorado con estilo rojizo)
  Widget _btnFlotante() {
    return SpeedDial(
      backgroundColor: AppTokens.primaryRed,
      foregroundColor: Colors.white,
      overlayColor: Colors.black,
      elevation: 8,
      animatedIcon: AnimatedIcons.menu_close,
      buttonSize: const Size(56, 56),
      childrenButtonSize: const Size(50, 50),
      children: [
        SpeedDialChild(
          backgroundColor: Colors.white,
          foregroundColor: AppTokens.primaryRed,
          onTap: () {
            context.showInfoSnackbar("Enviar dinero");
          },
          labelWidget: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppTokens.space12,
              vertical: AppTokens.space8,
            ),
            child: Text(
              "Enviar",
              style: context.textStyles.titleSmall?.copyWith(
                fontWeight: AppTokens.fontWeightBold,
                color: Colors.white
              ),
            ),
          ),
          child: const Icon(
            Icons.arrow_forward_ios_sharp,
            size: 18,
          ),
        ),
        SpeedDialChild(
          backgroundColor: Colors.white,
          foregroundColor: AppTokens.primaryRed,
          onTap: () {
            context.showInfoSnackbar("Retirar dinero");
          },
          labelWidget: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppTokens.space12,
              vertical: AppTokens.space8,
            ),
            child: Text(
              "Retirar",
              style: context.textStyles.titleSmall?.copyWith(
                fontWeight: AppTokens.fontWeightBold,
                color: Colors.white,
              ),
            ),
          ),
          child: const Icon(
            Icons.keyboard_arrow_down_outlined,
            size: 22,
          ),
        ),
        SpeedDialChild(
          backgroundColor: Colors.white,
          foregroundColor: AppTokens.primaryRed,
          onTap: () {
            context.showInfoSnackbar("Servicios disponibles");
          },
          labelWidget: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppTokens.space12,
              vertical: AppTokens.space8,
            ),
            child: Text(
              "Servicios",
              style: context.textStyles.titleSmall?.copyWith(
                fontWeight: AppTokens.fontWeightBold,
                color: AppTokens.white,
              ),
            ),
          ),
          child: const Icon(
            Icons.dashboard_customize_outlined,
            size: 24,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: context.colors.surfaceContainerLowest,
      body: ListView(
        padding: EdgeInsets.only(
          top: AppTokens.space8,
          bottom: 100.0,
        ),
        children: [
          _image(),
          _balanceCard(),
          _sectionTitle('Transferencias Rápidas'),
          _actividades(),
        ],
      ),
      floatingActionButton: _btnFlotante(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
