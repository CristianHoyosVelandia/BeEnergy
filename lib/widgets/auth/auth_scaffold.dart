import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/utils/metodos.dart';
import 'package:flutter/material.dart';

class AuthScaffold extends StatelessWidget {
  final List<Widget> children;
  final double heroHeight;
  final EdgeInsets contentPadding;

  const AuthScaffold({
    super.key,
    required this.children,
    this.heroHeight = 275,
    this.contentPadding = const EdgeInsets.only(bottom: AppTokens.space32),
  });

  @override
  Widget build(BuildContext context) {
    return Metodos.mediaQuery(
      context,
      Stack(
        alignment: Alignment.center,
        children: [
          const SingleChildScrollView(child: GradientBack()),
          ListView(
            padding: contentPadding,
            children: [
              _AuthHero(height: heroHeight),
              ...children,
            ],
          ),
        ],
      ),
    );
  }
}

class _AuthHero extends StatelessWidget {
  final double height;

  const _AuthHero({required this.height});

  @override
  Widget build(BuildContext context) {
    return Image(
      alignment: AlignmentDirectional.center,
      image: const AssetImage('assets/img/Login.png'),
      width: 3 / 4 * Metodos.width(context),
      height: height,
    );
  }
}
