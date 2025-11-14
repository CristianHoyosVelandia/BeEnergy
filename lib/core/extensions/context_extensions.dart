import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

/// Extensions útiles para BuildContext
/// Simplifican el acceso a theme, mediaQuery, navigator, etc.
extension ContextExtensions on BuildContext {
  // ==================== THEME ====================

  /// Acceso rápido al ThemeData
  ThemeData get theme => Theme.of(this);

  /// Acceso rápido al ColorScheme
  ColorScheme get colors => theme.colorScheme;

  /// Acceso rápido al TextTheme
  TextTheme get textStyles => theme.textTheme;

  // ==================== COLORES RÁPIDOS ====================

  /// Color primario
  Color get primaryColor => colors.primary;

  /// Color secundario
  Color get secondaryColor => colors.secondary;

  /// Color de superficie
  Color get surfaceColor => colors.surface;

  /// Color de fondo del scaffold
  Color get scaffoldColor => theme.scaffoldBackgroundColor;

  /// Color de error
  Color get errorColor => colors.error;

  /// Color de texto principal
  Color get textColor => colors.onSurface;

  /// Color de texto secundario
  Color get textColorSecondary => colors.onSurfaceVariant;

  // ==================== MEDIA QUERY ====================

  /// Acceso rápido a MediaQueryData
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Ancho de la pantalla
  double get width => mediaQuery.size.width;

  /// Alto de la pantalla
  double get height => mediaQuery.size.height;

  /// Tamaño de la pantalla
  Size get screenSize => mediaQuery.size;

  /// Padding del sistema (status bar, navigation bar, etc.)
  EdgeInsets get padding => mediaQuery.padding;

  /// View insets (teclado, etc.)
  EdgeInsets get viewInsets => mediaQuery.viewInsets;

  /// View padding
  EdgeInsets get viewPadding => mediaQuery.viewPadding;

  /// Orientación de la pantalla
  Orientation get orientation => mediaQuery.orientation;

  /// ¿Está en modo horizontal?
  bool get isLandscape => orientation == Orientation.landscape;

  /// ¿Está en modo vertical?
  bool get isPortrait => orientation == Orientation.portrait;

  /// Brillo del sistema (light/dark)
  Brightness get brightness => mediaQuery.platformBrightness;

  /// ¿Está en modo oscuro?
  bool get isDarkMode => brightness == Brightness.dark;

  /// ¿Está en modo claro?
  bool get isLightMode => brightness == Brightness.light;

  // ==================== RESPONSIVE ====================

  /// ¿Es móvil? (< 600px)
  bool get isMobile => width < AppTokens.breakpointMobile;

  /// ¿Es tablet? (>= 600px && < 960px)
  bool get isTablet =>
      width >= AppTokens.breakpointMobile && width < AppTokens.breakpointTablet;

  /// ¿Es desktop? (>= 960px)
  bool get isDesktop => width >= AppTokens.breakpointTablet;

  /// Obtener valor responsive según tamaño de pantalla
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }

  // ==================== NAVIGATION ====================

  /// Navigator del contexto actual
  NavigatorState get navigator => Navigator.of(this);

  /// Ir a una ruta
  Future<T?> push<T>(Widget page) {
    return navigator.push<T>(MaterialPageRoute(builder: (_) => page));
  }

  /// Ir a una ruta con nombre
  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    return navigator.pushNamed<T>(routeName, arguments: arguments);
  }

  /// Reemplazar ruta actual
  Future<T?> pushReplacement<T, TO>(Widget page) {
    return navigator.pushReplacement<T, TO>(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  /// Reemplazar ruta actual con ruta nombrada
  Future<T?> pushReplacementNamed<T, TO>(
    String routeName, {
    Object? arguments,
  }) {
    return navigator.pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
    );
  }

  /// Ir a ruta y remover todas las anteriores
  Future<T?> pushAndRemoveUntil<T>(
    Widget page, {
    bool Function(Route<dynamic>)? predicate,
  }) {
    return navigator.pushAndRemoveUntil<T>(
      MaterialPageRoute(builder: (_) => page),
      predicate ?? (route) => false,
    );
  }

  /// Ir a ruta nombrada y remover todas las anteriores
  Future<T?> pushNamedAndRemoveUntil<T>(
    String routeName, {
    bool Function(Route<dynamic>)? predicate,
    Object? arguments,
  }) {
    return navigator.pushNamedAndRemoveUntil<T>(
      routeName,
      predicate ?? (route) => false,
      arguments: arguments,
    );
  }

  /// Regresar a la ruta anterior
  void pop<T>([T? result]) {
    navigator.pop<T>(result);
  }

  /// ¿Puede regresar?
  bool get canPop => navigator.canPop();

  // ==================== DIALOGS Y SNACKBARS ====================

  /// Mostrar diálogo
  Future<T?> showAppDialog<T>({
    required Widget child,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: this,
      barrierDismissible: barrierDismissible,
      builder: (_) => child,
    );
  }

  /// Mostrar bottom sheet
  Future<T?> showAppBottomSheet<T>({
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: this,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTokens.radiusXLarge),
        ),
      ),
      builder: (_) => child,
    );
  }

  /// Mostrar snackbar
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackbar({
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    Color? backgroundColor,
  }) {
    return ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
        backgroundColor: backgroundColor,
      ),
    );
  }

  /// Mostrar snackbar de éxito
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSuccessSnackbar(
    String message,
  ) {
    return showSnackbar(
      message: message,
      backgroundColor: AppTokens.success,
    );
  }

  /// Mostrar snackbar de error
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showErrorSnackbar(
    String message,
  ) {
    return showSnackbar(
      message: message,
      backgroundColor: AppTokens.error,
    );
  }

  /// Mostrar snackbar de info
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showInfoSnackbar(
    String message,
  ) {
    return showSnackbar(
      message: message,
      backgroundColor: AppTokens.info,
    );
  }

  /// Mostrar snackbar de advertencia
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showWarningSnackbar(
    String message,
  ) {
    return showSnackbar(
      message: message,
      backgroundColor: AppTokens.warning,
    );
  }

  // ==================== FOCUS ====================

  /// FocusScope del contexto actual
  FocusScopeNode get focusScope => FocusScope.of(this);

  /// Quitar foco del elemento actual
  void unfocus() {
    focusScope.unfocus();
  }

  /// Mover foco al siguiente elemento
  void nextFocus() {
    focusScope.nextFocus();
  }

  /// Mover foco al elemento anterior
  void previousFocus() {
    focusScope.previousFocus();
  }

  // ==================== SCAFFOLD ====================

  /// ScaffoldMessenger del contexto actual
  ScaffoldMessengerState get scaffoldMessenger => ScaffoldMessenger.of(this);

  /// Scaffold del contexto actual (si existe)
  ScaffoldState? get scaffold {
    try {
      return Scaffold.of(this);
    } catch (e) {
      return null;
    }
  }

  /// Abrir drawer
  void openDrawer() {
    scaffold?.openDrawer();
  }

  /// Abrir end drawer
  void openEndDrawer() {
    scaffold?.openEndDrawer();
  }

  /// Cerrar drawer
  void closeDrawer() {
    scaffold?.closeDrawer();
  }

  /// Cerrar end drawer
  void closeEndDrawer() {
    scaffold?.closeEndDrawer();
  }

  // ==================== UTILIDADES ====================

  /// Ocultar teclado
  void hideKeyboard() {
    unfocus();
  }

  /// Mostrar teclado
  void showKeyboard() {
    focusScope.requestFocus();
  }

  /// Padding seguro (evita status bar, navigation bar, notch, etc.)
  EdgeInsets get safePadding => EdgeInsets.only(
        top: padding.top,
        bottom: padding.bottom,
        left: padding.left,
        right: padding.right,
      );

  /// Padding seguro solo arriba
  double get safeTop => padding.top;

  /// Padding seguro solo abajo
  double get safeBottom => padding.bottom;

  /// Ancho disponible (considerando padding)
  double get availableWidth => width - padding.left - padding.right;

  /// Alto disponible (considerando padding y teclado)
  double get availableHeight =>
      height - padding.top - padding.bottom - viewInsets.bottom;
}
