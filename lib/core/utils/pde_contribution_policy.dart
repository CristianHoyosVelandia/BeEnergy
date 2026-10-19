/// La selección puede llegar a todo el PDE. El movimiento conserva una reserva
/// técnica de 0,01 puntos porcentuales (0,0001 como fracción).
class PdeContributionPolicy {
  static const double technicalReserve = 0.0001;

  static double applied(double current, double requested) {
    final maximum = (current - technicalReserve).clamp(0.0, current).toDouble();
    return requested.clamp(0.0, maximum).toDouble();
  }
}
