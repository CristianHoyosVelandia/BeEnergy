import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_tokens.dart';

/// Configuración completa del tema de la aplicación
/// Soporta Light Mode y Dark Mode siguiendo Material Design 3
class AppTheme {
  AppTheme._(); // Constructor privado

  // ==================== COLOR SCHEMES ====================

  /// ColorScheme para modo claro - alto contraste para legibilidad
  static const ColorScheme _lightColorScheme = ColorScheme.light(
    primary: AppTokens.primaryTeal,
    onPrimary: AppTokens.white,
    primaryContainer: Color(0xFFCCFBF1),
    onPrimaryContainer: Color(0xFF134E4A),

    secondary: AppTokens.primaryTeal,
    onSecondary: AppTokens.white,
    secondaryContainer: Color(0xFFCCFBF1),
    onSecondaryContainer: Color(0xFF134E4A),

    tertiary: AppTokens.primaryYellow,
    onTertiary: AppTokens.grey900,
    tertiaryContainer: Color(0xFFFEF3C7),
    onTertiaryContainer: Color(0xFF422C00),

    error: AppTokens.error,
    onError: AppTokens.white,
    errorContainer: Color(0xFFFEE2E2),
    onErrorContainer: Color(0xFF7F1D1D),

    surface: AppTokens.white,
    onSurface: AppTokens.grey900,
    surfaceContainerHighest: AppTokens.grey100,
    onSurfaceVariant: AppTokens.grey700,

    outline: AppTokens.grey600,
    outlineVariant: AppTokens.grey400,

    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: AppTokens.grey900,
    onInverseSurface: AppTokens.grey100,
    inversePrimary: Color(0xFF5EEAD4),
  );

  /// ColorScheme para modo oscuro - texto claro sobre fondo oscuro
  static const ColorScheme _darkColorScheme = ColorScheme.dark(
    primary: Color(0xFF5EEAD4),
    onPrimary: Color(0xFF00382F),
    primaryContainer: Color(0xFF005047),
    onPrimaryContainer: Color(0xFF5EEAD4),

    secondary: Color(0xFF5EEAD4),
    onSecondary: Color(0xFF00382F),
    secondaryContainer: Color(0xFF005047),
    onSecondaryContainer: Color(0xFFCCFBF1),

    tertiary: Color(0xFFFCD34D),
    onTertiary: Color(0xFF422C00),
    tertiaryContainer: Color(0xFF5C3D00),
    onTertiaryContainer: Color(0xFFFEF3C7),

    error: Color(0xFFFCA5A5),
    onError: Color(0xFF7F1D1D),
    errorContainer: Color(0xFF991B1B),
    onErrorContainer: Color(0xFFFEE2E2),

    surface: AppTokens.grey900,
    onSurface: AppTokens.grey100,
    surfaceContainerHighest: AppTokens.grey800,
    onSurfaceVariant: AppTokens.grey300,

    outline: AppTokens.grey500,
    outlineVariant: AppTokens.grey700,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: AppTokens.grey100,
    onInverseSurface: AppTokens.grey900,
    inversePrimary: AppTokens.primaryTeal,
  );

  // ==================== TEXT THEMES ====================

  /// TextTheme optimizado para diseño Banking App
  /// Inter: Body text, UI, formularios, datos
  /// Manrope: Titles, headlines, hero text
  static TextTheme _textTheme(Color textColor) => TextTheme(
        // Display styles - Hero text, splash, onboarding (Manrope)
        displayLarge: TextStyle(
          fontFamily: AppTokens.fontFamilyDisplay, // Manrope
          fontSize: AppTokens.fontSize40,
          fontWeight: AppTokens.fontWeightBold,
          color: textColor,
          height: 1.15,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontFamily: AppTokens.fontFamilyDisplay, // Manrope
          fontSize: AppTokens.fontSize36,
          fontWeight: AppTokens.fontWeightBold,
          color: textColor,
          height: 1.2,
          letterSpacing: -0.25,
        ),
        displaySmall: TextStyle(
          fontFamily: AppTokens.fontFamilyDisplay, // Manrope
          fontSize: AppTokens.fontSize32,
          fontWeight: AppTokens.fontWeightSemiBold,
          color: textColor,
          height: 1.25,
          letterSpacing: 0,
        ),

        // Headline styles - Números grandes, KPIs, montos (Manrope)
        headlineLarge: TextStyle(
          fontFamily: AppTokens.fontFamilySecondary, // Manrope
          fontSize: AppTokens.fontSize28,
          fontWeight: AppTokens.fontWeightBold,
          color: textColor,
          height: 1.3,
          letterSpacing: 0,
        ),
        headlineMedium: TextStyle(
          fontFamily: AppTokens.fontFamilySecondary, // Manrope
          fontSize: AppTokens.fontSize24,
          fontWeight: AppTokens.fontWeightSemiBold,
          color: textColor,
          height: 1.3,
          letterSpacing: 0,
        ),
        headlineSmall: TextStyle(
          fontFamily: AppTokens.fontFamilySecondary, // Manrope
          fontSize: AppTokens.fontSize22,
          fontWeight: AppTokens.fontWeightSemiBold,
          color: textColor,
          height: 1.35,
          letterSpacing: 0,
        ),

        // Title styles - Títulos de pantalla, cards (Manrope para énfasis)
        titleLarge: TextStyle(
          fontFamily: AppTokens.fontFamilySecondary, // Manrope
          fontSize: AppTokens.fontSize20,
          fontWeight: AppTokens.fontWeightSemiBold,
          color: textColor,
          height: 1.4,
          letterSpacing: 0,
        ),
        titleMedium: TextStyle(
          fontFamily: AppTokens.fontFamilySecondary, // Manrope
          fontSize: AppTokens.fontSize18,
          fontWeight: AppTokens.fontWeightMedium,
          color: textColor,
          height: 1.4,
          letterSpacing: 0.15,
        ),
        titleSmall: TextStyle(
          fontFamily: AppTokens.fontFamilyPrimary, // Inter
          fontSize: AppTokens.fontSize16,
          fontWeight: AppTokens.fontWeightMedium,
          color: textColor,
          height: 1.45,
          letterSpacing: 0.1,
        ),

        // Body styles - Texto general, listas, descripciones (Inter)
        bodyLarge: TextStyle(
          fontFamily: AppTokens.fontFamilyPrimary, // Inter
          fontSize: AppTokens.fontSize16,
          fontWeight: AppTokens.fontWeightRegular,
          color: textColor,
          height: 1.5,
          letterSpacing: 0.15,
        ),
        bodyMedium: TextStyle(
          fontFamily: AppTokens.fontFamilyPrimary, // Inter
          fontSize: AppTokens.fontSize14,
          fontWeight: AppTokens.fontWeightRegular,
          color: textColor,
          height: 1.5,
          letterSpacing: 0.25,
        ),
        bodySmall: TextStyle(
          fontFamily: AppTokens.fontFamilyPrimary, // Inter
          fontSize: AppTokens.fontSize12,
          fontWeight: AppTokens.fontWeightRegular,
          color: textColor,
          height: 1.5,
          letterSpacing: 0.4,
        ),

        // Label styles - Botones, tabs, chips (Inter)
        labelLarge: TextStyle(
          fontFamily: AppTokens.fontFamilyPrimary, // Inter
          fontSize: AppTokens.fontSize15,
          fontWeight: AppTokens.fontWeightMedium,
          color: textColor,
          height: 1.4,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          fontFamily: AppTokens.fontFamilyPrimary, // Inter
          fontSize: AppTokens.fontSize13,
          fontWeight: AppTokens.fontWeightMedium,
          color: textColor,
          height: 1.45,
          letterSpacing: 0.5,
        ),
        labelSmall: TextStyle(
          fontFamily: AppTokens.fontFamilyPrimary, // Inter
          fontSize: AppTokens.fontSize11,
          fontWeight: AppTokens.fontWeightMedium,
          color: textColor,
          height: 1.5,
          letterSpacing: 0.5,
        ),
      );

  // ==================== THEMES ====================

  /// Tema claro de la aplicación
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _lightColorScheme,
      textTheme: _textTheme(AppTokens.grey900),
      fontFamily: AppTokens.fontFamilyPrimary,

      // Colores legacy (para compatibilidad)
      primaryColor: AppTokens.primaryTeal,
      cardColor: AppTokens.white,
      canvasColor: AppTokens.primaryTeal,
      indicatorColor: AppTokens.primaryYellow,
      focusColor: AppTokens.grey900,

      // Scaffold
      scaffoldBackgroundColor: AppTokens.white,

      // AppBar
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: _lightColorScheme.onSurface,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: _textTheme(AppTokens.grey900).titleLarge,
        toolbarHeight: 60,
      ),

      // Card
      cardTheme: CardThemeData(
        elevation: AppTokens.elevation2,
        shape: RoundedRectangleBorder(
          borderRadius: AppTokens.borderRadiusMedium,
        ),
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.all(AppTokens.spacingMedium),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: AppTokens.elevation2,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.buttonPaddingHorizontalMedium,
            vertical: AppTokens.spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppTokens.borderRadiusMedium,
          ),
          textStyle: _textTheme(AppTokens.white).labelLarge?.copyWith(fontWeight: FontWeight.w600),
          minimumSize: const Size.fromHeight(AppTokens.buttonHeightMedium),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.buttonPaddingHorizontalMedium,
            vertical: AppTokens.spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppTokens.borderRadiusMedium,
          ),
          textStyle: _textTheme(AppTokens.primaryTeal).labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.buttonPaddingHorizontalMedium,
            vertical: AppTokens.spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppTokens.borderRadiusMedium,
          ),
          side: const BorderSide(
            color: AppTokens.primaryTeal,
            width: AppTokens.borderWidthNormal,
          ),
          textStyle: _textTheme(AppTokens.primaryTeal).labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppTokens.grey100,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTokens.spacingMedium,
          vertical: AppTokens.spacingMedium,
        ),
        border: OutlineInputBorder(
          borderRadius: AppTokens.borderRadiusMedium,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppTokens.borderRadiusMedium,
          borderSide: const BorderSide(
            color: AppTokens.grey400,
            width: AppTokens.borderWidthNormal,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppTokens.borderRadiusMedium,
          borderSide: const BorderSide(
            color: AppTokens.primaryTeal,
            width: AppTokens.borderWidthThick,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppTokens.borderRadiusMedium,
          borderSide: const BorderSide(
            color: AppTokens.error,
            width: AppTokens.borderWidthNormal,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppTokens.borderRadiusMedium,
          borderSide: const BorderSide(
            color: AppTokens.error,
            width: AppTokens.borderWidthThick,
          ),
        ),
        labelStyle: _textTheme(AppTokens.grey800).bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        hintStyle: _textTheme(AppTokens.grey600).bodyMedium?.copyWith(color: AppTokens.grey600),
        errorStyle: _textTheme(AppTokens.error).bodySmall,
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTokens.white,
        selectedItemColor: AppTokens.primaryTeal,
        unselectedItemColor: AppTokens.grey600,
        elevation: AppTokens.elevation8,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppTokens.primaryTeal,
        foregroundColor: AppTokens.white,
        elevation: AppTokens.elevation6,
        shape: CircleBorder(),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: AppTokens.grey200,
        selectedColor: AppTokens.primaryTeal,
        disabledColor: AppTokens.grey300,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.spacingMedium,
          vertical: AppTokens.spacingSmall,
        ),
        labelStyle: _textTheme(AppTokens.grey900).labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: AppTokens.borderRadiusLarge,
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        elevation: AppTokens.elevation24,
        shape: RoundedRectangleBorder(
          borderRadius: AppTokens.borderRadiusXLarge,
        ),
        titleTextStyle: _textTheme(AppTokens.grey900).headlineSmall,
        contentTextStyle: _textTheme(AppTokens.grey900).bodyMedium,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppTokens.grey300,
        thickness: AppTokens.borderWidthThin,
        space: AppTokens.spacingMedium,
      ),

      // Icon
      iconTheme: const IconThemeData(
        color: AppTokens.grey800,
        size: AppTokens.iconSizeMedium,
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppTokens.primaryTeal,
        linearTrackColor: AppTokens.grey300,
        circularTrackColor: AppTokens.grey300,
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppTokens.grey900,
        contentTextStyle: _textTheme(AppTokens.white).bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: AppTokens.borderRadiusMedium,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: AppTokens.elevation6,
      ),
    );
  }

  /// Tema oscuro de la aplicación
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _darkColorScheme,
      textTheme: _textTheme(AppTokens.white),
      fontFamily: AppTokens.fontFamilyPrimary,

      // Scaffold
      scaffoldBackgroundColor: AppTokens.grey900,

      // AppBar
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: _darkColorScheme.onSurface,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: _textTheme(AppTokens.white).titleLarge,
        toolbarHeight: 60,
      ),

      // Card
      cardTheme: CardThemeData(
        elevation: AppTokens.elevation2,
        color: AppTokens.grey800,
        shape: RoundedRectangleBorder(
          borderRadius: AppTokens.borderRadiusMedium,
        ),
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.all(AppTokens.spacingMedium),
      ),

      // Similar configuration for other components...
      // (Keeping it shorter for brevity, but following same pattern)

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTokens.grey900,
        selectedItemColor: Color(0xFF5EEAD4),
        unselectedItemColor: AppTokens.grey400,
        elevation: AppTokens.elevation8,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF0D9488),
        foregroundColor: AppTokens.white,
        elevation: AppTokens.elevation6,
        shape: CircleBorder(),
      ),

      iconTheme: const IconThemeData(
        color: AppTokens.grey100,
        size: AppTokens.iconSizeMedium,
      ),
    );
  }
}
