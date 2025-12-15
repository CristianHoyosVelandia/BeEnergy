/// Modelos para auditoría y cumplimiento regulatorio CREG 101 072 de 2025
library;

/// Registro de auditoría regulatoria
///
/// Cada operación crítica del sistema (clasificación de excedentes, asignación PDE,
/// creación de ofertas, contratos P2P) genera un registro de auditoría que permite
/// demostrar cumplimiento ante XM/UPME.
class RegulatoryAuditLog {
  final int id;
  final int userId;
  final AuditAction actionType;
  final String resourceType; // 'P2PContract', 'P2POffer', 'PDEAllocation', etc.
  final int resourceId;
  final Map<String, dynamic> data; // Datos específicos de la operación
  final String regulationArticle; // Artículo CREG aplicable
  final ComplianceStatus complianceStatus;
  final DateTime createdAt;

  const RegulatoryAuditLog({
    required this.id,
    required this.userId,
    required this.actionType,
    required this.resourceType,
    required this.resourceId,
    required this.data,
    required this.regulationArticle,
    required this.complianceStatus,
    required this.createdAt,
  });

  /// Convierte el modelo a Map para persistencia
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'actionType': actionType.name,
      'resourceType': resourceType,
      'resourceId': resourceId,
      'data': data,
      'regulationArticle': regulationArticle,
      'complianceStatus': complianceStatus.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Crea una instancia desde Map
  factory RegulatoryAuditLog.fromJson(Map<String, dynamic> json) {
    return RegulatoryAuditLog(
      id: json['id'] as int,
      userId: json['userId'] as int,
      actionType: AuditAction.values.firstWhere(
        (e) => e.name == json['actionType'],
      ),
      resourceType: json['resourceType'] as String,
      resourceId: json['resourceId'] as int,
      data: Map<String, dynamic>.from(json['data'] as Map),
      regulationArticle: json['regulationArticle'] as String,
      complianceStatus: ComplianceStatus.values.firstWhere(
        (e) => e.name == json['complianceStatus'],
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  String toString() {
    return 'RegulatoryAuditLog(id: $id, action: $actionType, status: $complianceStatus, article: $regulationArticle)';
  }
}

/// Tipos de acciones auditables
enum AuditAction {
  /// Excedentes clasificados en Tipo 1 y Tipo 2
  surplusClassified,

  /// PDE asignado a consumidores
  pdeAllocated,

  /// Oferta P2P creada por prosumidor
  offerCreated,

  /// Oferta P2P aceptada por consumidor
  offerAccepted,

  /// Contrato P2P ejecutado
  contractExecuted,

  /// Mes cerrado y liquidación completada
  monthClosed,

  /// Validación de NIU
  niuValidated,

  /// Validación de precio VE
  veValidated,
}

extension AuditActionExtension on AuditAction {
  String get displayName {
    switch (this) {
      case AuditAction.surplusClassified:
        return 'Clasificación de Excedentes';
      case AuditAction.pdeAllocated:
        return 'Asignación PDE';
      case AuditAction.offerCreated:
        return 'Oferta Creada';
      case AuditAction.offerAccepted:
        return 'Oferta Aceptada';
      case AuditAction.contractExecuted:
        return 'Contrato Ejecutado';
      case AuditAction.monthClosed:
        return 'Mes Cerrado';
      case AuditAction.niuValidated:
        return 'NIU Validado';
      case AuditAction.veValidated:
        return 'VE Validado';
    }
  }
}

/// Estado de cumplimiento regulatorio
enum ComplianceStatus {
  /// Operación cumple totalmente con la regulación
  compliant,

  /// Operación cumple pero con advertencias
  warning,

  /// Operación viola la regulación
  violation,
}

extension ComplianceStatusExtension on ComplianceStatus {
  String get displayName {
    switch (this) {
      case ComplianceStatus.compliant:
        return 'Cumple';
      case ComplianceStatus.warning:
        return 'Advertencia';
      case ComplianceStatus.violation:
        return 'Violación';
    }
  }

  String get icon {
    switch (this) {
      case ComplianceStatus.compliant:
        return '✅';
      case ComplianceStatus.warning:
        return '⚠️';
      case ComplianceStatus.violation:
        return '❌';
    }
  }
}

/// Cálculo del Valor de Energía (VE) según CREG 101 072
///
/// VE = CU + MC + PCN
/// - CU: Cargo por Uso de redes (COP/kWh)
/// - MC: Costo de comercialización (COP/kWh)
/// - PCN: Precio de energía en contratos (COP/kWh)
///
/// Los precios P2P deben estar en el rango VE ±10%
class VECalculation {
  final String period; // Formato: 'YYYY-MM'
  final double cuComponent; // Cargo por Uso
  final double mcComponent; // Comercialización
  final double pcnComponent; // Precio energía
  final double totalVE; // CU + MC + PCN
  final double minAllowedPrice; // VE * 0.9
  final double maxAllowedPrice; // VE * 1.1
  final String source; // 'manual' | 'XM' | 'UPME'

  const VECalculation({
    required this.period,
    required this.cuComponent,
    required this.mcComponent,
    required this.pcnComponent,
    required this.totalVE,
    required this.minAllowedPrice,
    required this.maxAllowedPrice,
    required this.source,
  });

  /// Verifica si un precio está dentro del rango permitido VE ±10%
  bool isPriceWithinRange(double price) {
    return price >= minAllowedPrice && price <= maxAllowedPrice;
  }

  /// Calcula el porcentaje de desviación respecto al VE
  double getDeviationPercentage(double price) {
    return ((price - totalVE) / totalVE) * 100;
  }

  /// Factory para crear VE con cálculo automático
  factory VECalculation.calculate({
    required String period,
    required double cuComponent,
    required double mcComponent,
    required double pcnComponent,
    String source = 'manual',
  }) {
    final totalVE = cuComponent + mcComponent + pcnComponent;
    return VECalculation(
      period: period,
      cuComponent: cuComponent,
      mcComponent: mcComponent,
      pcnComponent: pcnComponent,
      totalVE: totalVE,
      minAllowedPrice: totalVE * 0.9,
      maxAllowedPrice: totalVE * 1.1,
      source: source,
    );
  }

  /// Convierte el modelo a Map para persistencia
  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'cuComponent': cuComponent,
      'mcComponent': mcComponent,
      'pcnComponent': pcnComponent,
      'totalVE': totalVE,
      'minAllowedPrice': minAllowedPrice,
      'maxAllowedPrice': maxAllowedPrice,
      'source': source,
    };
  }

  /// Crea una instancia desde Map
  factory VECalculation.fromJson(Map<String, dynamic> json) {
    return VECalculation(
      period: json['period'] as String,
      cuComponent: (json['cuComponent'] as num).toDouble(),
      mcComponent: (json['mcComponent'] as num).toDouble(),
      pcnComponent: (json['pcnComponent'] as num).toDouble(),
      totalVE: (json['totalVE'] as num).toDouble(),
      minAllowedPrice: (json['minAllowedPrice'] as num).toDouble(),
      maxAllowedPrice: (json['maxAllowedPrice'] as num).toDouble(),
      source: json['source'] as String,
    );
  }

  @override
  String toString() {
    return 'VECalculation(period: $period, VE: $totalVE COP/kWh, range: $minAllowedPrice-$maxAllowedPrice)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VECalculation && other.period == period;
  }

  @override
  int get hashCode => period.hashCode;
}

/// Resultado de validación regulatoria
class ValidationResult {
  final bool isValid;
  final ComplianceStatus complianceStatus;
  final String message;
  final String? regulationArticle;
  final Map<String, dynamic>? details;

  const ValidationResult({
    required this.isValid,
    required this.complianceStatus,
    required this.message,
    this.regulationArticle,
    this.details,
  });

  /// Factory para resultado exitoso
  factory ValidationResult.success({
    required String message,
    String? regulationArticle,
    Map<String, dynamic>? details,
  }) {
    return ValidationResult(
      isValid: true,
      complianceStatus: ComplianceStatus.compliant,
      message: message,
      regulationArticle: regulationArticle,
      details: details,
    );
  }

  /// Factory para advertencia
  factory ValidationResult.warning({
    required String message,
    String? regulationArticle,
    Map<String, dynamic>? details,
  }) {
    return ValidationResult(
      isValid: true,
      complianceStatus: ComplianceStatus.warning,
      message: message,
      regulationArticle: regulationArticle,
      details: details,
    );
  }

  /// Factory para violación
  factory ValidationResult.violation({
    required String message,
    String? regulationArticle,
    Map<String, dynamic>? details,
  }) {
    return ValidationResult(
      isValid: false,
      complianceStatus: ComplianceStatus.violation,
      message: message,
      regulationArticle: regulationArticle,
      details: details,
    );
  }

  @override
  String toString() {
    return 'ValidationResult(status: $complianceStatus, message: $message)';
  }
}

/// Clasificación de excedentes según CREG 101 072
class SurplusClassification {
  final String period; // 'YYYY-MM'
  final int userId;
  final double totalSurplus; // kWh
  final double type1Surplus; // Autoconsumo compensado (NO vendible)
  final double type2Surplus; // Disponible para PDE y P2P
  final DateTime classifiedAt;

  const SurplusClassification({
    required this.period,
    required this.userId,
    required this.totalSurplus,
    required this.type1Surplus,
    required this.type2Surplus,
    required this.classifiedAt,
  });

  /// Verifica que la clasificación sea válida (Tipo1 + Tipo2 = Total)
  bool get isValidClassification {
    return (type1Surplus + type2Surplus - totalSurplus).abs() < 0.01;
  }

  /// Porcentaje de Tipo 1 (debería ser ~50%)
  double get type1Percentage {
    if (totalSurplus == 0) return 0.0;
    return (type1Surplus / totalSurplus) * 100;
  }

  /// Porcentaje de Tipo 2 (debería ser ~50%)
  double get type2Percentage {
    if (totalSurplus == 0) return 0.0;
    return (type2Surplus / totalSurplus) * 100;
  }

  /// Convierte el modelo a Map para persistencia
  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'userId': userId,
      'totalSurplus': totalSurplus,
      'type1Surplus': type1Surplus,
      'type2Surplus': type2Surplus,
      'classifiedAt': classifiedAt.toIso8601String(),
    };
  }

  /// Crea una instancia desde Map
  factory SurplusClassification.fromJson(Map<String, dynamic> json) {
    return SurplusClassification(
      period: json['period'] as String,
      userId: json['userId'] as int,
      totalSurplus: (json['totalSurplus'] as num).toDouble(),
      type1Surplus: (json['type1Surplus'] as num).toDouble(),
      type2Surplus: (json['type2Surplus'] as num).toDouble(),
      classifiedAt: DateTime.parse(json['classifiedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'SurplusClassification(period: $period, userId: $userId, total: $totalSurplus kWh, type1: $type1Surplus, type2: $type2Surplus)';
  }
}
