import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/database_Helper.dart';
import '../../services/community_theme_storage.dart';
import '../../widgets/logout_confirmation_dialog.dart';
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
        final navigatorState = appNavigatorKey.currentState;
        navigatorState?.pushNamedAndRemoveUntil(
          'login',
          (Route<dynamic> route) => false,
        );

        WidgetsBinding.instance.addPostFrameCallback((_) {
          final dialogContext = appNavigatorKey.currentContext;
          if (dialogContext == null) return;

          showDialog<void>(
            context: dialogContext,
            barrierDismissible: false,
            builder: (_) => const SessionExpiredDialog(),
          );
        });
      });
    } finally {
      Future<void>.delayed(const Duration(seconds: 2), () {
        _handlingExpiredSession = false;
      });
    }
  }
}
