import 'package:intl/intl.dart';

/// Formateadores para números, fechas, moneda, energía, etc.
class Formatters {
  Formatters._(); // Constructor privado

  // ==================== NÚMEROS ====================

  /// Formatea un número con separadores de miles
  /// Ejemplo: 1500000 -> "1.500.000"
  static String formatNumber(num value, {int? decimals}) {
    final formatter = NumberFormat('#,##0${decimals != null ? '.${'0' * decimals}' : ''}', 'es_ES');
    return formatter.format(value).replaceAll(',', '.');
  }

  /// Formatea un número entero desde String
  /// Ejemplo: "1500000" -> "1.500.000"
  static String formatNumberFromString(String value) {
    final number = int.tryParse(value);
    if (number == null) return value;
    return formatNumber(number);
  }

  // ==================== MONEDA ====================

  /// Formatea un valor como moneda (pesos colombianos por defecto)
  /// Ejemplo: 15000 -> "\$ 15.000"
  static String formatCurrency(
    num value, {
    String symbol = '\$',
    int decimals = 0,
    bool showSymbol = true,
  }) {
    final formatted = formatNumber(value, decimals: decimals);
    return showSymbol ? '$symbol $formatted' : formatted;
  }

  /// Formatea un valor de String como moneda
  /// Ejemplo: "15000" -> "\$ 15.000"
  static String formatCurrencyFromString(
    String value, {
    String symbol = '\$',
    int decimals = 0,
    bool showSymbol = true,
  }) {
    final number = num.tryParse(value);
    if (number == null) return value;
    return formatCurrency(
      number,
      symbol: symbol,
      decimals: decimals,
      showSymbol: showSymbol,
    );
  }

  // ==================== ENERGÍA ====================

  /// Formatea un valor de energía
  /// Ejemplo: 1500 -> "1.500 kWh"
  static String formatEnergy(
    num value, {
    String unit = 'kWh',
    int decimals = 0,
  }) {
    final formatted = formatNumber(value, decimals: decimals);
    return '$formatted $unit';
  }

  /// Formatea un valor de energía desde String
  /// Ejemplo: "1500" -> "1.500 kWh"
  static String formatEnergyFromString(
    String value, {
    String unit = 'kWh',
    int decimals = 0,
  }) {
    final number = num.tryParse(value);
    if (number == null) return value;
    return formatEnergy(number, unit: unit, decimals: decimals);
  }

  /// Formatea potencia
  /// Ejemplo: 10 -> "10 kW"
  static String formatPower(
    num value, {
    String unit = 'kW',
    int decimals = 1,
  }) {
    final formatted = formatNumber(value, decimals: decimals);
    return '$formatted $unit';
  }

  // ==================== FECHAS ====================

  /// Formatea una fecha en formato corto
  /// Ejemplo: DateTime(2024, 2, 25) -> "25-Feb"
  static String formatDateShort(DateTime date) {
    return DateFormat('dd-MMM', 'es').format(date);
  }

  /// Formatea una fecha en formato medio
  /// Ejemplo: DateTime(2024, 2, 25) -> "25 Feb 2024"
  static String formatDateMedium(DateTime date) {
    return DateFormat('dd MMM yyyy', 'es').format(date);
  }

  /// Formatea una fecha en formato largo
  /// Ejemplo: DateTime(2024, 2, 25) -> "25 de febrero de 2024"
  static String formatDateLong(DateTime date) {
    return DateFormat('dd \'de\' MMMM \'de\' yyyy', 'es').format(date);
  }

  /// Formatea una fecha y hora
  /// Ejemplo: DateTime(2024, 2, 25, 14, 30) -> "25/02/2024 14:30"
  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm', 'es').format(date);
  }

  /// Formatea solo la hora
  /// Ejemplo: DateTime(2024, 2, 25, 14, 30) -> "14:30"
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm', 'es').format(date);
  }

  /// Formatea fecha relativa (hace 2 días, hace 1 hora, etc.)
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return 'Hace $years ${years == 1 ? 'año' : 'años'}';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'Hace $months ${months == 1 ? 'mes' : 'meses'}';
    } else if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} ${difference.inDays == 1 ? 'día' : 'días'}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} ${difference.inHours == 1 ? 'hora' : 'horas'}';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} ${difference.inMinutes == 1 ? 'minuto' : 'minutos'}';
    } else {
      return 'Hace un momento';
    }
  }

  // ==================== PORCENTAJES ====================

  /// Formatea un porcentaje
  /// Ejemplo: 0.75 -> "75%"
  static String formatPercentage(double value, {int decimals = 0}) {
    final percentage = value * 100;
    return '${formatNumber(percentage, decimals: decimals)}%';
  }

  /// Formatea un porcentaje desde un valor directo
  /// Ejemplo: 75 -> "75%"
  static String formatPercentageDirect(num value, {int decimals = 0}) {
    return '${formatNumber(value, decimals: decimals)}%';
  }

  // ==================== TELÉFONOS ====================

  /// Formatea un número telefónico colombiano
  /// Ejemplo: "3001234567" -> "300 123 4567"
  static String formatPhone(String phone) {
    if (phone.length != 10) return phone;
    return '${phone.substring(0, 3)} ${phone.substring(3, 6)} ${phone.substring(6)}';
  }

  // ==================== DISTANCIAS ====================

  /// Formatea una distancia en metros o kilómetros
  /// Ejemplo: 1500 -> "1.5 km", 500 -> "500 m"
  static String formatDistance(double meters) {
    if (meters >= 1000) {
      final km = meters / 1000;
      return '${formatNumber(km, decimals: 1)} km';
    } else {
      return '${formatNumber(meters, decimals: 0)} m';
    }
  }

  // ==================== TAMAÑOS DE ARCHIVO ====================

  /// Formatea un tamaño de archivo en bytes
  /// Ejemplo: 1500000 -> "1.43 MB"
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  // ==================== COMPACTO ====================

  /// Formatea números grandes de forma compacta
  /// Ejemplo: 1500000 -> "1.5M"
  static String formatCompact(num value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}B';
    } else if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toString();
    }
  }

  // ==================== DURACIÓN ====================

  /// Formatea una duración
  /// Ejemplo: Duration(hours: 2, minutes: 30) -> "2h 30m"
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }
}
