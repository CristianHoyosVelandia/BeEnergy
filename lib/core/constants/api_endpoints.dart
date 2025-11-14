/// Constantes de endpoints del API
/// Centraliza todas las rutas de los endpoints para facilitar su mantenimiento
class ApiEndpoints {
  // Constructor privado para prevenir instanciación
  ApiEndpoints._();

  // ==================== AUTH ENDPOINTS ====================
  /// Endpoint para login de usuario
  static const String login = '/auth/login';

  /// Endpoint para registro de usuario
  static const String register = '/auth/register';

  /// Endpoint para logout
  static const String logout = '/auth/logout';

  /// Endpoint para refrescar token
  static const String refreshToken = '/auth/refresh';

  /// Endpoint para recuperar contraseña
  static const String forgotPassword = '/auth/forgot-password';

  /// Endpoint para resetear contraseña
  static const String resetPassword = '/auth/reset-password';

  // ==================== USER ENDPOINTS ====================
  /// Endpoint para obtener perfil de usuario
  static const String userProfile = '/user/profile';

  /// Endpoint para actualizar perfil de usuario
  static const String updateProfile = '/user/update';

  /// Endpoint para cambiar contraseña
  static const String changePassword = '/user/change-password';

  // ==================== EMPRESAS ENDPOINTS ====================
  /// Endpoint para obtener lista de empresas
  static const String getEmpresas = '/ws/getEmpresas';

  /// Endpoint para obtener detalle de una empresa
  static String getEmpresaById(int id) => '/ws/getEmpresa/$id';

  // ==================== ENERGY ENDPOINTS ====================
  /// Endpoint para obtener datos de energía del usuario
  static const String energyData = '/energy/data';

  /// Endpoint para obtener historial de energía
  static const String energyHistory = '/energy/history';

  /// Endpoint para obtener estadísticas de energía
  static const String energyStats = '/energy/stats';

  // ==================== TRADING ENDPOINTS ====================
  /// Endpoint para crear una transacción de energía
  static const String createTransaction = '/trading/create';

  /// Endpoint para obtener transacciones del usuario
  static const String userTransactions = '/trading/transactions';

  /// Endpoint para obtener detalle de una transacción
  static String getTransactionById(String id) => '/trading/transaction/$id';

  /// Endpoint para cancelar una transacción
  static String cancelTransaction(String id) => '/trading/cancel/$id';

  // ==================== INTERCAMBIO ENDPOINTS ====================
  /// Endpoint para obtener intercambios disponibles
  static const String availableExchanges = '/exchange/available';

  /// Endpoint para crear un intercambio
  static const String createExchange = '/exchange/create';

  /// Endpoint para aceptar un intercambio
  static String acceptExchange(String id) => '/exchange/accept/$id';

  /// Endpoint para rechazar un intercambio
  static String rejectExchange(String id) => '/exchange/reject/$id';

  // ==================== NOTIFICATIONS ENDPOINTS ====================
  /// Endpoint para obtener notificaciones del usuario
  static const String notifications = '/notifications';

  /// Endpoint para marcar notificación como leída
  static String markNotificationAsRead(String id) => '/notifications/read/$id';

  /// Endpoint para marcar todas las notificaciones como leídas
  static const String markAllNotificationsAsRead = '/notifications/read-all';

  // ==================== LOCATION ENDPOINTS ====================
  /// Endpoint para obtener ciudades
  static const String getCities = '/location/cities';

  /// Endpoint para obtener ciudad por ID
  static String getCityById(int id) => '/location/city/$id';

  // ==================== PAYMENT ENDPOINTS ====================
  /// Endpoint para obtener métodos de pago
  static const String paymentMethods = '/payment/methods';

  /// Endpoint para agregar método de pago
  static const String addPaymentMethod = '/payment/add';

  /// Endpoint para eliminar método de pago
  static String removePaymentMethod(String id) => '/payment/remove/$id';
}
