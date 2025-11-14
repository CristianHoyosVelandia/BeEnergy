import 'package:flutter/material.dart';

/// Design Tokens - Sistema de diseño centralizado
/// Contiene todos los valores de diseño reutilizables de la aplicación
class AppTokens {
  AppTokens._(); // Constructor privado para prevenir instanciación

  // ==================== COLORES ====================

  /// Paleta de colores primarios - Energía y sostenibilidad
  static const Color primaryBlue = Color(0xFF0070C0);
  static const Color primaryPurple = Color(0xFF7E57C2);
  static const Color primaryRed = Color(0xFF891427);
  static const Color primaryYellow = Color(0xFFFFD966);

  /// Escala de grises
  static const Color black = Color(0xFF212D3D);
  static const Color grey900 = Color(0xFF2C3E50);
  static const Color grey800 = Color(0xFF34495E);
  static const Color grey700 = Color(0xFF5D6D7E);
  static const Color grey600 = Color(0xFF7B8794);
  static const Color grey500 = Color(0xFF95A5A6);
  static const Color grey400 = Color(0xFFB2BEC3);
  static const Color grey300 = Color(0xFFDFE6E9);
  static const Color grey200 = Color(0xFFECF0F1);
  static const Color grey100 = Color(0xFFF5F6FA);
  static const Color white = Color(0xFFFFFFFF);

  /// Colores semánticos
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);

  /// Colores de energía (específicos de la app)
  static const Color energyGreen = Color(0xFF2ECC71);
  static const Color energySolar = Color(0xFFF39C12);
  static const Color energyWind = Color(0xFF00BCD4);
  static const Color energyBattery = Color(0xFF9C27B0);

  // ==================== ESPACIADO ====================

  /// Sistema de espaciado basado en 4px
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;
  static const double space64 = 64.0;

  /// Aliases para spacing común
  static const double spacingTiny = space4;
  static const double spacingSmall = space8;
  static const double spacingMedium = space16;
  static const double spacingLarge = space24;
  static const double spacingXLarge = space32;
  static const double spacingXXLarge = space48;

  // ==================== TIPOGRAFÍA ====================

  /// Tamaños de fuente - Optimizados para diseño tipo Banking App
  /// Caption/Labels (datos pequeños, hints)
  static const double fontSize10 = 10.0;
  static const double fontSize11 = 11.0;

  /// Body Small/Caption (textos secundarios, metadatos)
  static const double fontSize12 = 12.0;
  static const double fontSize13 = 13.0;

  /// Body Medium (texto principal, listas, formularios)
  static const double fontSize14 = 14.0;
  static const double fontSize15 = 15.0;

  /// Body Large (texto destacado, botones)
  static const double fontSize16 = 16.0;

  /// Subtitle (subtítulos, tabs)
  static const double fontSize17 = 17.0;
  static const double fontSize18 = 18.0;

  /// Title Small (títulos de cards, secciones)
  static const double fontSize20 = 20.0;

  /// Title Medium (títulos de pantalla)
  static const double fontSize22 = 22.0;
  static const double fontSize24 = 24.0;

  /// Headline (números grandes, montos, KPIs)
  static const double fontSize28 = 28.0;
  static const double fontSize32 = 32.0;

  /// Display (hero text, splash, onboarding)
  static const double fontSize36 = 36.0;
  static const double fontSize40 = 40.0;

  /// Pesos de fuente
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;
  static const FontWeight fontWeightExtraBold = FontWeight.w800;

  /// Familias de fuente
  /// Inter: Fuente primaria para UI/UX, cuerpo de texto, datos, formularios
  /// Manrope: Fuente display para títulos grandes, headlines, hero text
  static const String fontFamilyPrimary = 'Inter';      // Body text, UI, forms
  static const String fontFamilySecondary = 'Manrope';  // Titles, subtitles
  static const String fontFamilyDisplay = 'Manrope';    // Headlines, hero

  // Legacy fonts (mantener para compatibilidad temporal)
  static const String fontFamilyLegacyGaret = 'Garet';
  static const String fontFamilyLegacySegoeUI = 'SEGOEUI';
  static const String fontFamilyLegacyLilitaOne = 'LilitaOne';

  // ==================== BORDES Y RADIOS ====================

  /// Radios de borde
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  static const double radiusCircular = 9999.0;

  /// Border radius predefinidos
  static BorderRadius get borderRadiusSmall => BorderRadius.circular(radiusSmall);
  static BorderRadius get borderRadiusMedium => BorderRadius.circular(radiusMedium);
  static BorderRadius get borderRadiusLarge => BorderRadius.circular(radiusLarge);
  static BorderRadius get borderRadiusXLarge => BorderRadius.circular(radiusXLarge);
  static BorderRadius get borderRadiusCircular => BorderRadius.circular(radiusCircular);

  /// Anchos de borde
  static const double borderWidthThin = 0.5;
  static const double borderWidthNormal = 1.0;
  static const double borderWidthThick = 2.0;
  static const double borderWidthExtra = 3.0;

  // ==================== ELEVACIONES Y SOMBRAS ====================

  /// Elevaciones
  static const double elevation0 = 0.0;
  static const double elevation1 = 1.0;
  static const double elevation2 = 2.0;
  static const double elevation4 = 4.0;
  static const double elevation6 = 6.0;
  static const double elevation8 = 8.0;
  static const double elevation12 = 12.0;
  static const double elevation16 = 16.0;
  static const double elevation24 = 24.0;

  /// Sombras predefinidas
  static List<BoxShadow> get shadowSmall => [
        const BoxShadow(
          color: Color(0x1A000000),
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get shadowMedium => [
        const BoxShadow(
          color: Color(0x26000000),
          blurRadius: 8,
          offset: Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get shadowLarge => [
        const BoxShadow(
          color: Color(0x33000000),
          blurRadius: 16,
          offset: Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get shadowCard => [
        const BoxShadow(
          blurRadius: 6,
          color: Color(0x4B1A1F24),
          offset: Offset(0, 2),
        ),
      ];

  // ==================== DURACIONES DE ANIMACIÓN ====================

  /// Duraciones estándar para animaciones
  static const Duration durationInstant = Duration(milliseconds: 0);
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
  static const Duration durationVerySlow = Duration(milliseconds: 700);

  // ==================== CURVAS DE ANIMACIÓN ====================

  /// Curvas de animación
  static const Curve curveStandard = Curves.easeInOut;
  static const Curve curveDecelerate = Curves.easeOut;
  static const Curve curveAccelerate = Curves.easeIn;
  static const Curve curveEmphasized = Curves.easeInOutCubic;

  // ==================== TAMAÑOS DE ICONOS ====================

  /// Tamaños de iconos
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;
  static const double iconSizeXXLarge = 64.0;

  // ==================== TAMAÑOS DE BOTONES ====================

  /// Alturas de botones
  static const double buttonHeightSmall = 32.0;
  static const double buttonHeightMedium = 48.0;
  static const double buttonHeightLarge = 56.0;

  /// Padding horizontal de botones
  static const double buttonPaddingHorizontalSmall = 12.0;
  static const double buttonPaddingHorizontalMedium = 24.0;
  static const double buttonPaddingHorizontalLarge = 32.0;

  // ==================== TAMAÑOS DE AVATAR ====================

  /// Tamaños de avatar
  static const double avatarSizeSmall = 32.0;
  static const double avatarSizeMedium = 48.0;
  static const double avatarSizeLarge = 64.0;
  static const double avatarSizeXLarge = 96.0;

  // ==================== OPACIDADES ====================

  /// Niveles de opacidad
  static const double opacityDisabled = 0.38;
  static const double opacityMedium = 0.54;
  static const double opacityHigh = 0.87;
  static const double opacityFull = 1.0;

  // ==================== GRADIENTES ====================

  /// Gradientes predefinidos
  static LinearGradient get gradientPrimary => const LinearGradient(
        colors: [primaryRed, black],
        begin: AlignmentDirectional(0.94, -1),
        end: AlignmentDirectional(-0.94, 1),
      );

  static LinearGradient get gradientEnergy => const LinearGradient(
        colors: [energyGreen, energySolar],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get gradientCard => LinearGradient(
        colors: [primaryRed, grey900],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // ==================== BREAKPOINTS ====================

  /// Breakpoints para responsive design
  static const double breakpointMobile = 600.0;
  static const double breakpointTablet = 960.0;
  static const double breakpointDesktop = 1280.0;

  // ==================== LÍMITES Y MÁXIMOS ====================

  /// Anchos máximos de contenido
  static const double maxWidthMobile = 600.0;
  static const double maxWidthTablet = 960.0;
  static const double maxWidthDesktop = 1280.0;
  static const double maxWidthContent = 1440.0;

  // ==================== Z-INDEX ====================

  /// Capas de profundidad
  static const int zIndexBase = 0;
  static const int zIndexDropdown = 1000;
  static const int zIndexSticky = 1020;
  static const int zIndexFixed = 1030;
  static const int zIndexModalBackdrop = 1040;
  static const int zIndexModal = 1050;
  static const int zIndexPopover = 1060;
  static const int zIndexTooltip = 1070;
}
