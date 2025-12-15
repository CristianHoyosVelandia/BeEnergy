/// Servicio de Validación Regulatoria según CREG 101 072
///
/// Valida cumplimiento de:
/// - PDE ≤ 10% del Tipo 2 total
/// - Precios P2P dentro de VE ±10%
/// - Formato NIU válido
/// - Integridad de datos
library;

import '../models/energy_models.dart';
import '../models/p2p_models.dart';
import '../models/p2p_offer.dart';
import '../models/community_models.dart';
import '../models/regulatory_models.dart';

class RegulatoryValidator {
  // ============================================================================
  // VALIDACIÓN PDE (Programa de Distribución de Excedentes)
  // ============================================================================

  /// Valida que el PDE no exceda el límite del 10%
  ///
  /// Según CREG 101 072 Art 3.4:
  /// El PDE no puede ser mayor al 10% del total de excedentes Tipo 2
  ValidationResult validatePDELimit(PDEAllocation allocation) {
    if (allocation.sharePercentage > 0.10) {
      return ValidationResult.violation(
        message: 'PDE excede límite regulatorio del 10%',
        regulationArticle: 'CREG 101 072 Art 3.4',
        details: {
          'currentPercentage': allocation.sharePercentage * 100,
          'maxPercentage': 10.0,
          'allocatedEnergy': allocation.allocatedEnergy,
          'totalType2': allocation.surplusType2Only,
        },
      );
    }

    if (allocation.sharePercentage > 0.08) {
      return ValidationResult.warning(
        message: 'PDE cercano al límite (>80% del máximo)',
        regulationArticle: 'CREG 101 072 Art 3.4',
        details: {
          'currentPercentage': allocation.sharePercentage * 100,
          'maxPercentage': 10.0,
        },
      );
    }

    return ValidationResult.success(
      message: 'PDE cumple límite regulatorio (≤10%)',
      regulationArticle: 'CREG 101 072 Art 3.4',
      details: {
        'percentage': allocation.sharePercentage * 100,
        'allocatedEnergy': allocation.allocatedEnergy,
      },
    );
  }

  /// Valida múltiples asignaciones PDE para un período
  ///
  /// Calcula el PDE total y verifica que no exceda el 10% del Tipo 2 total
  ValidationResult validateTotalPDE({
    required List<PDEAllocation> allocations,
    required double totalType2Available,
  }) {
    final totalPDE = allocations.fold(
      0.0,
      (sum, allocation) => sum + allocation.allocatedEnergy,
    );

    final percentage = totalType2Available > 0
        ? totalPDE / totalType2Available
        : 0.0;

    if (percentage > 0.10) {
      return ValidationResult.violation(
        message: 'PDE total excede 10% del Tipo 2 disponible',
        regulationArticle: 'CREG 101 072 Art 3.4',
        details: {
          'totalPDE': totalPDE,
          'totalType2': totalType2Available,
          'percentage': percentage * 100,
          'maxPercentage': 10.0,
        },
      );
    }

    return ValidationResult.success(
      message: 'PDE total cumple límite regulatorio',
      regulationArticle: 'CREG 101 072 Art 3.4',
      details: {
        'totalPDE': totalPDE,
        'totalType2': totalType2Available,
        'percentage': percentage * 100,
      },
    );
  }

  // ============================================================================
  // VALIDACIÓN VE (Valor de Energía)
  // ============================================================================

  /// Valida que un precio esté dentro del rango VE ±10%
  ///
  /// Según CREG 101 072 Art 4.2:
  /// Los precios P2P deben estar en el rango VE ±10%
  ValidationResult validateP2PPrice(double price, VECalculation ve) {
    if (price < ve.minAllowedPrice || price > ve.maxAllowedPrice) {
      return ValidationResult.violation(
        message: 'Precio fuera del rango VE permitido (±10%)',
        regulationArticle: 'CREG 101 072 Art 4.2',
        details: {
          'price': price,
          've': ve.totalVE,
          'minAllowed': ve.minAllowedPrice,
          'maxAllowed': ve.maxAllowedPrice,
          'deviation': ve.getDeviationPercentage(price),
        },
      );
    }

    // Warning si está muy cerca de los límites
    final deviationPercent = ve.getDeviationPercentage(price).abs();
    if (deviationPercent > 8.0) {
      return ValidationResult.warning(
        message: 'Precio cercano al límite del rango VE',
        regulationArticle: 'CREG 101 072 Art 4.2',
        details: {
          'price': price,
          've': ve.totalVE,
          'deviation': ve.getDeviationPercentage(price),
        },
      );
    }

    return ValidationResult.success(
      message: 'Precio dentro del rango VE (±10%)',
      regulationArticle: 'CREG 101 072 Art 4.2',
      details: {
        'price': price,
        've': ve.totalVE,
        'deviation': ve.getDeviationPercentage(price),
      },
    );
  }

  /// Valida una oferta P2P completa
  ValidationResult validateP2POffer(P2POffer offer, VECalculation ve) {
    // 1. Validar precio en rango VE
    final priceValidation = validateP2PPrice(offer.pricePerKwh, ve);
    if (!priceValidation.isValid) {
      return priceValidation;
    }

    // 2. Validar energía disponible
    if (offer.energyAvailable <= 0) {
      return ValidationResult.violation(
        message: 'Oferta sin energía disponible',
        regulationArticle: 'CREG 101 072 Art 4.2',
        details: {'energyAvailable': offer.energyAvailable},
      );
    }

    // 3. Validar que no esté expirada
    if (offer.isExpired) {
      return ValidationResult.violation(
        message: 'Oferta expirada',
        details: {
          'validUntil': offer.validUntil.toIso8601String(),
          'now': DateTime.now().toIso8601String(),
        },
      );
    }

    return ValidationResult.success(
      message: 'Oferta P2P válida',
      regulationArticle: 'CREG 101 072 Art 4.2',
      details: {
        'energy': offer.energyAvailable,
        'price': offer.pricePerKwh,
        'total': offer.totalValue,
      },
    );
  }

  /// Valida un contrato P2P
  ValidationResult validateP2PContract(P2PContract contract, VECalculation ve) {
    // 1. Validar precio
    final priceValidation = validateP2PPrice(contract.agreedPrice, ve);
    if (!priceValidation.isValid) {
      return priceValidation;
    }

    // 2. Validar energía comprometida
    if (contract.energyCommitted <= 0) {
      return ValidationResult.violation(
        message: 'Contrato sin energía comprometida',
        regulationArticle: 'CREG 101 072 Art 4.3',
        details: {'energyCommitted': contract.energyCommitted},
      );
    }

    // 3. Validar que comprador y vendedor sean diferentes
    if (contract.buyerId == contract.sellerId) {
      return ValidationResult.violation(
        message: 'Comprador y vendedor no pueden ser el mismo usuario',
        details: {
          'userId': contract.buyerId,
        },
      );
    }

    return ValidationResult.success(
      message: 'Contrato P2P válido',
      regulationArticle: 'CREG 101 072 Art 4.3',
      details: {
        'energy': contract.energyCommitted,
        'price': contract.agreedPrice,
        'total': contract.totalValue,
      },
    );
  }

  // ============================================================================
  // VALIDACIÓN NIU (Número Identificación Única)
  // ============================================================================

  /// Valida formato NIU: NIU-{COMUNIDAD}-{ID}-{AÑO}
  ///
  /// Formato esperado:
  /// - NIU: Prefijo fijo
  /// - COMUNIDAD: Código alfanumérico de la comunidad
  /// - ID: Número de 3 dígitos (con padding de ceros)
  /// - AÑO: Año de 4 dígitos
  ///
  /// Ejemplo: NIU-UAO-024-2025
  ValidationResult validateNIU(String niu) {
    final niuRegex = RegExp(r'^NIU-[A-Z0-9]+-\d{3}-\d{4}$');

    if (!niuRegex.hasMatch(niu)) {
      return ValidationResult.violation(
        message: 'Formato NIU inválido',
        regulationArticle: 'CREG 101 072 Art 2.1',
        details: {
          'niu': niu,
          'expectedFormat': 'NIU-{COMUNIDAD}-{ID}-{AÑO}',
          'example': 'NIU-UAO-024-2025',
        },
      );
    }

    return ValidationResult.success(
      message: 'NIU válido',
      regulationArticle: 'CREG 101 072 Art 2.1',
      details: {'niu': niu},
    );
  }

  /// Valida que un miembro tenga NIU válido
  ValidationResult validateMemberNIU(CommunityMember member) {
    if (member.niu.isEmpty) {
      return ValidationResult.violation(
        message: 'Miembro sin NIU asignado',
        regulationArticle: 'CREG 101 072 Art 2.1',
        details: {
          'userId': member.userId,
          'userName': member.fullName,
        },
      );
    }

    return validateNIU(member.niu);
  }

  // ============================================================================
  // VALIDACIONES COMBINADAS
  // ============================================================================

  /// Valida disponibilidad de energía para crear oferta P2P
  ///
  /// Verifica que el prosumidor tenga suficiente Tipo 2 disponible
  /// después de su contribución al PDE
  ValidationResult validateOfferAvailability({
    required double type2Total,
    required double pdeContributed,
    required double offeredEnergy,
  }) {
    final available = type2Total - pdeContributed;

    if (offeredEnergy > available) {
      return ValidationResult.violation(
        message: 'Energía ofertada excede disponibilidad',
        regulationArticle: 'CREG 101 072 Art 4.2',
        details: {
          'type2Total': type2Total,
          'pdeContributed': pdeContributed,
          'available': available,
          'offered': offeredEnergy,
          'excess': offeredEnergy - available,
        },
      );
    }

    return ValidationResult.success(
      message: 'Energía disponible para oferta',
      details: {
        'type2Total': type2Total,
        'pdeContributed': pdeContributed,
        'available': available,
        'offered': offeredEnergy,
        'remaining': available - offeredEnergy,
      },
    );
  }

  /// Valida que una aceptación de oferta no exceda energía disponible
  ValidationResult validateOfferAcceptance({
    required P2POffer offer,
    required double requestedEnergy,
  }) {
    if (requestedEnergy > offer.energyRemaining) {
      return ValidationResult.violation(
        message: 'Energía solicitada excede disponibilidad de oferta',
        details: {
          'requested': requestedEnergy,
          'available': offer.energyRemaining,
          'excess': requestedEnergy - offer.energyRemaining,
        },
      );
    }

    if (requestedEnergy <= 0) {
      return ValidationResult.violation(
        message: 'Energía solicitada debe ser mayor a 0',
        details: {'requested': requestedEnergy},
      );
    }

    return ValidationResult.success(
      message: 'Aceptación válida',
      details: {
        'requested': requestedEnergy,
        'available': offer.energyRemaining,
        'remaining': offer.energyRemaining - requestedEnergy,
      },
    );
  }

  // ============================================================================
  // REPORTES DE CUMPLIMIENTO
  // ============================================================================

  /// Genera un reporte de cumplimiento regulatorio completo
  Map<String, dynamic> generateComplianceReport({
    required List<PDEAllocation> pdeAllocations,
    required List<P2PContract> p2pContracts,
    required List<CommunityMember> members,
    required VECalculation ve,
    required double totalType2,
  }) {
    final violations = <String>[];
    final warnings = <String>[];
    final compliant = <String>[];

    // 1. Validar PDE
    final pdeValidation = validateTotalPDE(
      allocations: pdeAllocations,
      totalType2Available: totalType2,
    );

    if (pdeValidation.complianceStatus == ComplianceStatus.violation) {
      violations.add('PDE: ${pdeValidation.message}');
    } else if (pdeValidation.complianceStatus == ComplianceStatus.warning) {
      warnings.add('PDE: ${pdeValidation.message}');
    } else {
      compliant.add('PDE: ${pdeValidation.message}');
    }

    // 2. Validar contratos P2P
    for (final contract in p2pContracts) {
      final contractValidation = validateP2PContract(contract, ve);
      if (contractValidation.complianceStatus == ComplianceStatus.violation) {
        violations.add('Contrato #${contract.id}: ${contractValidation.message}');
      } else if (contractValidation.complianceStatus == ComplianceStatus.warning) {
        warnings.add('Contrato #${contract.id}: ${contractValidation.message}');
      }
    }

    // 3. Validar NIUs
    for (final member in members) {
      final niuValidation = validateMemberNIU(member);
      if (niuValidation.complianceStatus == ComplianceStatus.violation) {
        violations.add('NIU ${member.fullName}: ${niuValidation.message}');
      }
    }

    return {
      'isCompliant': violations.isEmpty,
      'violations': violations,
      'warnings': warnings,
      'compliant': compliant,
      'totalIssues': violations.length + warnings.length,
      'compliancePercentage': violations.isEmpty ? 100.0 : 0.0,
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }
}
