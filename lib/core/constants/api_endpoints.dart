/// Constantes de endpoints del API
/// Centraliza todas las rutas de los endpoints para facilitar su mantenimiento
/// Basado en Volt Platform Services (OpenAPI 3.1, v1.0.0)
class ApiEndpoints {
  // Constructor privado para prevenir instanciación
  ApiEndpoints._();

  // ==================== AUTH ENDPOINTS ====================
  /// Endpoint para verificar conexión (ping)
  static const String ping = '/auth/ping';

  /// Endpoint para login de usuario
  static const String login = '/auth/log-in';

  /// Endpoint para registro de usuario (sign up)
  static const String signUp = '/auth/sign-up';

  /// Endpoint para registro de usuario (alias)
  static const String register = '/auth/sign-up';

  /// Endpoint para logout
  static const String logout = '/auth/logout';

  /// Endpoint para verificar token
  static const String verifyToken = '/auth/verify-token';

  /// Endpoint para refrescar token
  static const String refreshToken = '/auth/refresh-token';

  /// Endpoint para recuperar contraseña (forgot password)
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

  // ==================== COMMUNITY ENDPOINTS ====================
  /// Endpoint para obtener información de la comunidad
  static const String community = '/community';

  /// Endpoint para obtener miembros de la comunidad
  static const String communityMembers = '/community/members';

  /// Endpoint para obtener estadísticas de la comunidad
  static const String communityStats = '/community/stats';

  /// Endpoint para crear una comunidad
  static const String createCommunity = '/community/create';

  /// Endpoint para actualizar comunidad
  static String updateCommunity(int id) => '/community/update/$id';

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

  // ==================== P2P MARKET ENDPOINTS ====================
  /// Endpoint para obtener ofertas P2P disponibles
  static const String p2pOffers = '/p2p/offers';

  /// Endpoint para crear oferta P2P
  static const String createP2POffer = '/p2p/offers/create';

  /// Endpoint para aceptar oferta P2P
  static String acceptP2POffer(String id) => '/p2p/offers/$id/accept';

  /// Endpoint para cancelar oferta P2P
  static String cancelP2POffer(String id) => '/p2p/offers/$id/cancel';

  /// Endpoint para obtener contratos P2P
  static const String p2pContracts = '/p2p/contracts';

  /// Endpoint para obtener detalle de contrato P2P
  static String getP2PContract(String id) => '/p2p/contracts/$id';

  // ==================== PDE ENDPOINTS ====================
  /// Endpoint para obtener asignaciones PDE
  static const String pdeAllocations = '/pde/allocations';

  /// Endpoint para calcular asignaciones PDE
  static const String calculatePDE = '/pde/calculate';

  /// Endpoint para obtener detalle de asignación PDE
  static String getPDEAllocation(String id) => '/pde/allocation/$id';

  // ==================== BILLING ENDPOINTS ====================
  /// Endpoint para obtener facturación de usuario
  static String userBilling(int userId) => '/billing/user/$userId';

  /// Endpoint para obtener facturación de comunidad
  static const String communityBilling = '/billing/community';

  /// Endpoint para obtener costos regulados
  static const String regulatedCosts = '/billing/costs';

  /// Endpoint para obtener ahorros de comunidad
  static const String communitySavings = '/billing/savings';

  // ==================== LIQUIDATION ENDPOINTS ====================
  /// Endpoint para obtener sesiones de liquidación
  static const String liquidationSessions = '/liquidation/sessions';

  /// Endpoint para crear sesión de liquidación
  static const String createLiquidation = '/liquidation/create';

  /// Endpoint para finalizar liquidación
  static String finalizeLiquidation(String id) => '/liquidation/$id/finalize';

  /// Endpoint para obtener matches de liquidación
  static String liquidationMatches(String sessionId) => '/liquidation/$sessionId/matches';

  // ==================== CONSUMER OFFERS ENDPOINTS ====================
  /// Endpoint para obtener ofertas de consumidores
  static const String consumerOffers = '/consumer-offers';

  /// Endpoint para crear oferta de consumidor
  static const String createConsumerOffer = '/consumer-offers/create';

  /// Endpoint para aceptar oferta de consumidor
  static String acceptConsumerOffer(String id) => '/consumer-offers/$id/accept';

  // ==================== CREDITS ENDPOINTS ====================
  /// Endpoint para obtener créditos de energía
  static const String energyCredits = '/credits';

  /// Endpoint para obtener transacciones de créditos
  static const String creditTransactions = '/credits/transactions';

  /// Endpoint para crear transacción de crédito
  static const String createCreditTransaction = '/credits/transactions/create';

  // ==================== REPORTS ENDPOINTS ====================
  /// Endpoint para obtener reportes
  static const String reports = '/reports';

  /// Endpoint para generar reporte
  static const String generateReport = '/reports/generate';

  /// Endpoint para obtener reporte por tipo
  static String getReportByType(String type) => '/reports/$type';

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
