import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/database_Helper.dart';
import '../../services/community_theme_storage.dart';
import '../theme/app_tokens.dart';
import '../utils/logger.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> appScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class AppSessionManager {
  AppSessionManager._();

  static const String _tag = 'SessionManager';
  static const String _tokenKey = 'auth_token';
  static bool _handlingExpiredSession = false;

  static Future<void> handleExpiredSession({
    void Function()? onClearAuthHeader,
  }) async {
    if (_handlingExpiredSession) return;
    _handlingExpiredSession = true;

    try {
      onClearAuthHeader?.call();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await CommunityThemeStorage().clearThemeData();
      AppTokens.resetToDefaultColors();

      try {
        final dbHelper = DatabaseHelper();
        final dbConnection = await dbHelper.db;
        await dbConnection?.delete(dbHelper.tbUsuarioLogIn);
      } catch (e) {
        AppLogger.warning(
          'No se pudo limpiar el usuario local',
          tag: _tag,
          error: e.toString(),
        );
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        appScaffoldMessengerKey.currentState
          ?..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Tu sesión ha expirado'),
              behavior: SnackBarBehavior.floating,
            ),
          );

        appNavigatorKey.currentState?.pushNamedAndRemoveUntil(
          'login',
          (Route<dynamic> route) => false,
        );
      });
    } finally {
      Future<void>.delayed(const Duration(seconds: 2), () {
        _handlingExpiredSession = false;
      });
    }
  }
}
