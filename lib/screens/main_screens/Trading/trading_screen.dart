import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/data/constants.dart';
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

  Widget _card() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppTokens.space16,
        vertical: AppTokens.space12,
      ),
      padding: EdgeInsets.all(AppTokens.space20),
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            blurRadius: 6,
            color: Color(0x4B1A1F24),
            offset: Offset(0, 2),
          )
        ],
        gradient: Metodos.gradientClasic(context),
        borderRadius: AppTokens.borderRadiusMedium,
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Disponible label
          Text(
            "Disponible",
            style: context.textStyles.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: AppTokens.fontWeightSemiBold,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: AppTokens.space12),
          // Amount
          Text(
            "\$ 333.333",
            style: context.textStyles.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: AppTokens.fontWeightBold,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: AppTokens.space24),
          // Card number and expiry
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "* **** 0149 *",
                style: context.textStyles.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: AppTokens.fontWeightMedium,
                ),
              ),
              Text(
                "05/25",
                style: context.textStyles.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: AppTokens.fontWeightMedium,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.space8),
          // Card holder name
          Text(
            "CRISTIAN HOYOS",
            style: context.textStyles.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: AppTokens.fontWeightSemiBold,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(int action, String titulo, IconData icon) {
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
            gradient: Metodos.gradientClasic(context),
            borderRadius: AppTokens.borderRadiusMedium,
            border: Border.all(
              color: context.colors.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: Colors.white,
              ),
              SizedBox(height: AppTokens.space12),
              Text(
                titulo,
                style: context.textStyles.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: AppTokens.fontWeightSemiBold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actividades() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppTokens.space8,
        vertical: AppTokens.space12,
      ),
      child: Row(
        children: [
          _actionButton(1, "Energia", Icons.energy_savings_leaf),
          _actionButton(2, "Dinero", Icons.transform_rounded),
        ],
      ),
    );
  }

  Widget _btnFlotante() {
    return SpeedDial(
      backgroundColor: context.colors.primary,
      foregroundColor: Colors.white,
      overlayColor: context.colors.primary,
      elevation: 15,
      animatedIcon: AnimatedIcons.menu_close,
      children: [
        SpeedDialChild(
          backgroundColor: Colors.white,
          onTap: () {},
          labelWidget: Container(
            padding: EdgeInsets.symmetric(horizontal: AppTokens.space8),
            child: Text(
              "Envia",
              style: context.textStyles.titleSmall?.copyWith(
                fontWeight: AppTokens.fontWeightBold,
              ),
            ),
          ),
          child: Icon(
            Icons.arrow_forward_ios_sharp,
            size: 15,
            color: context.colors.primary,
          ),
        ),
        SpeedDialChild(
          backgroundColor: Colors.white,
          onTap: () {},
          child: Icon(
            Icons.keyboard_arrow_down_outlined,
            size: 25,
            color: context.colors.primary,
          ),
          labelWidget: Container(
            padding: EdgeInsets.symmetric(horizontal: AppTokens.space8),
            child: Text(
              "Retira",
              style: context.textStyles.titleSmall?.copyWith(
                fontWeight: AppTokens.fontWeightBold,
              ),
            ),
          ),
        ),
        SpeedDialChild(
          backgroundColor: Colors.white,
          onTap: () {},
          child: Icon(
            Icons.dashboard_customize_outlined,
            size: 30,
            color: context.colors.primary,
          ),
          labelWidget: Container(
            padding: EdgeInsets.symmetric(horizontal: AppTokens.space8),
            child: Text(
              "Servicios",
              style: context.textStyles.titleSmall?.copyWith(
                fontWeight: AppTokens.fontWeightBold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1)),
      child: Scaffold(
        appBar: metodos.appbarSecundaria(context, "Transferir", ColorsApp.color4),
        backgroundColor: context.colors.surface,
        body: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            SingleChildScrollView(
              child: GradientBackInsideApp(
                color: context.colors.onSurfaceVariant,
                height: 85,
                opacity: 0.75,
              ),
            ),
            ListView(
              padding: EdgeInsets.only(
                top: AppTokens.space8,
                bottom: AppTokens.space24,
              ),
              children: [
                _image(),
                _card(),
                _actividades(),
              ],
            ),
          ],
        ),
        floatingActionButton: _btnFlotante(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
