import 'package:flutter/foundation.dart';

/// Niveles de log disponibles
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// Logger global para la aplicación BeEnergy.
///
/// Uso:
/// ```dart
/// AppLogger.debug('Mensaje de depuración');
/// AppLogger.info('Información general');
/// AppLogger.warning('Advertencia');
/// AppLogger.error('Error', error: e, stackTrace: stack);
/// ```
class AppLogger {
  static LogLevel _minLevel = kDebugMode ? LogLevel.debug : LogLevel.warning;
  static bool _enabled = true;

  /// Configura el nivel mínimo de log
  static void setMinLevel(LogLevel level) {
    _minLevel = level;
  }

  /// Habilita o deshabilita el logger
  static void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// Log de depuración (solo en modo debug)
  static void debug(String message, {String? tag}) {
    _log(LogLevel.debug, message, tag: tag);
  }

  /// Log de información general
  static void info(String message, {String? tag}) {
    _log(LogLevel.info, message, tag: tag);
  }

  /// Log de advertencia
  static void warning(String message, {String? tag, Object? error}) {
    _log(LogLevel.warning, message, tag: tag, error: error);
  }

  /// Log de error
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Método interno de logging
  static void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_enabled) return;
    if (level.index < _minLevel.index) return;

    final emoji = _getEmoji(level);
    final levelName = _getLevelName(level);
    final tagPrefix = tag != null ? '[$tag] ' : '';
    final timestamp = DateTime.now().toIso8601String().substring(11, 23);

    final buffer = StringBuffer();
    buffer.write('$emoji $timestamp $levelName $tagPrefix$message');

    if (error != null) {
      buffer.write('\n   Error: $error');
    }

    if (stackTrace != null) {
      buffer.write('\n   StackTrace: $stackTrace');
    }

    // En modo release, solo errores y warnings se muestran
    if (kDebugMode || level == LogLevel.error || level == LogLevel.warning) {
      // ignore: avoid_print
      print(buffer.toString());
    }
  }

  static String _getEmoji(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🔍';
      case LogLevel.info:
        return '💡';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
    }
  }

  static String _getLevelName(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '[DEBUG]';
      case LogLevel.info:
        return '[INFO]';
      case LogLevel.warning:
        return '[WARN]';
      case LogLevel.error:
        return '[ERROR]';
    }
  }
}
