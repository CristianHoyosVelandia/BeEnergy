/// Constantes de endpoints del API
/// Centraliza todas las rutas de los endpoints para facilitar su mantenimiento
class ApiEndpoints {
  // Constructor privado para prevenir instanciación
  ApiEndpoints._();

  // ==================== AUTH ENDPOINTS (auth_service) ====================
  /// Login con correo y contraseña
  static const String login = '/auth/log-in';

  /// Registro de usuario
  static const String register = '/auth/sign-up';

  /// Logout (client-side)
  static const String logout = '/auth/logout';

  /// Renovación de token
  static const String refreshToken = '/auth/refresh';

  /// Recuperación de contraseña por correo
  static const String forgotPassword = '/auth/forgot-password';

  /// Resetear contraseña con OTP
  static const String resetPassword = '/auth/reset-password';

  /// Verificar OTP para autenticación de dos factores
  static const String verify2fa = '/auth/verify-2fa';

  /// Verificar token
  static const String verifyToken = '/auth/verify-token';

  /// Ciudades (auth_service)
  static const String cities = '/auth/cities';

  // ==================== USER ENDPOINTS (user_service) ====================
  /// Obtener perfil de usuario
  static String userProfile(int userId) => '/users/$userId';

  /// Actualizar datos personales
  static String updateProfile(int userId) => '/users/$userId';

  /// Cambiar rol (admin)
  static String changeRole(int userId) => '/users/$userId/role';

  // ==================== EMPRESAS ENDPOINTS ====================
  /// Endpoint para obtener lista de empresas
  static const String getEmpresas = '/ws/getEmpresas';

  /// Endpoint para obtener detalle de una empresa
  static String getEmpresaById(int id) => '/ws/getEmpresa/$id';

  // ==================== CREDITS ENDPOINTS (energy_credits_service) ====================
  /// Consulta de saldo energético en kWh
  static String creditsBalance(int userId) => '/credits/$userId';

  // ==================== ENERGY/TRANSACTIONS ENDPOINTS (transaction_service) ====================
  /// Registrar energy record
  static const String createEnergyRecord = '/transactions/energy';
  /// Consultar registros de energía (POST con body)
  static const String queryEnergyRecords = '/transactions/energy/query';

  // ==================== TRANSACTIONS ENDPOINTS (transaction_service) ====================
  /// Crear contrato P2P (oferta)
  static const String createContract = '/transactions/contracts';

  /// Listar contratos/ofertas
  static const String listContracts = '/transactions/contracts';

  /// Registrar transacción
  static const String recordTransaction = '/transactions/record-transaction';

  /// Liquidar periodo
  static const String liquidate = '/transactions/liquidate';

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

  // ==================== AUDIT ENDPOINTS (audit_service) ====================
  /// Consulta de registros de auditoría
  static const String auditLogs = '/audit/logs';

  /// Generar reporte de auditoría
  static const String auditReports = '/audit/reports';

  // ==================== MONITORING ENDPOINTS (monitoring_service) ====================
  /// Última medición del dispositivo
  static const String telemetryLatest = '/telemetry/latest';

  /// Histórico de mediciones
  static const String telemetryHistory = '/telemetry/history';

  /// Listar reglas de alerta
  static const String alertRules = '/alerts/rules';

  /// Listar alertas (histórico por fechas)
  static const String alerts = '/alerts';

  /// Crear regla de alerta
  static const String createAlertRule = '/alerts/rules';

  // ==================== PAYMENT ENDPOINTS ====================
  /// Endpoint para obtener métodos de pago
  static const String paymentMethods = '/payment/methods';

  /// Endpoint para agregar método de pago
  static const String addPaymentMethod = '/payment/add';

  /// Endpoint para eliminar método de pago
  static String removePaymentMethod(String id) => '/payment/remove/$id';
}
