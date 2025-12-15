// Modelos para Mercado P2P y Créditos Energéticos
// Basado en la tesis de Cristian Hoyos y Esteban Viveros

class P2PContract {
  final int id;
  final int sellerId;
  final String sellerName;
  final int buyerId;
  final String buyerName;
  final int communityId;
  final double energyCommitted; // kWh
  final double agreedPrice; // COP/kWh
  final String status; // 'active', 'completed', 'cancelled'
  final DateTime createdAt;

  // ⭐ NUEVO: Campos regulatorios CREG 101 072
  final String period; // 'YYYY-MM' - Período del contrato
  final double calculatedVE; // VE del período (COP/kWh)
  final bool priceWithinVERange; // Precio cumple VE ±10%
  final DateTime? completedAt; // Fecha de completado

  P2PContract({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.buyerId,
    required this.buyerName,
    required this.communityId,
    required this.energyCommitted,
    required this.agreedPrice,
    required this.status,
    required this.createdAt,
    this.period = '',
    this.calculatedVE = 450.0,
    this.priceWithinVERange = true,
    this.completedAt,
  });

  double get totalValue => energyCommitted * agreedPrice;

  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  /// Valida que el precio esté en rango VE ±10%
  bool validateVECompliance() {
    final minPrice = calculatedVE * 0.9;
    final maxPrice = calculatedVE * 1.1;
    return agreedPrice >= minPrice && agreedPrice <= maxPrice;
  }

  factory P2PContract.fromJson(Map<String, dynamic> json) {
    return P2PContract(
      id: json['id'] as int,
      sellerId: json['seller_id'] as int,
      sellerName: json['seller_name'] as String,
      buyerId: json['buyer_id'] as int,
      buyerName: json['buyer_name'] as String,
      communityId: json['community_id'] as int,
      energyCommitted: (json['energy_committed'] as num).toDouble(),
      agreedPrice: (json['agreed_price'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      period: json['period'] as String? ?? '',
      calculatedVE: (json['calculated_ve'] as num?)?.toDouble() ?? 450.0,
      priceWithinVERange: json['price_within_ve_range'] as bool? ?? true,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seller_id': sellerId,
      'seller_name': sellerName,
      'buyer_id': buyerId,
      'buyer_name': buyerName,
      'community_id': communityId,
      'energy_committed': energyCommitted,
      'agreed_price': agreedPrice,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'period': period,
      'calculated_ve': calculatedVE,
      'price_within_ve_range': priceWithinVERange,
      'completed_at': completedAt?.toIso8601String(),
    };
  }
}

class EnergyCredit {
  final int id;
  final int userId;
  final String userName;
  final double balance; // COP
  final DateTime createdAt;
  final DateTime updatedAt;

  EnergyCredit({
    required this.id,
    required this.userId,
    required this.userName,
    required this.balance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EnergyCredit.fromJson(Map<String, dynamic> json) {
    return EnergyCredit(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      userName: json['user_name'] as String,
      balance: (json['balance'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'balance': balance,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class CreditTransaction {
  final int id;
  final int userId;
  final String userName;
  final double amount; // COP
  final String type; // 'credit' (ingreso) o 'debit' (gasto)
  final String description;
  final DateTime transactionDate;

  CreditTransaction({
    required this.id,
    required this.userId,
    required this.userName,
    required this.amount,
    required this.type,
    required this.description,
    required this.transactionDate,
  });

  bool get isCredit => type == 'credit';
  bool get isDebit => type == 'debit';

  factory CreditTransaction.fromJson(Map<String, dynamic> json) {
    return CreditTransaction(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      userName: json['user_name'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      description: json['description'] as String,
      transactionDate: DateTime.parse(json['transaction_date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'amount': amount,
      'type': type,
      'description': description,
      'transaction_date': transactionDate.toIso8601String(),
    };
  }
}

/// Ranking de vendedores en el mercado P2P
class SellerRanking {
  final int userId;
  final String userName;
  final double totalEnergySold;
  final double totalRevenue;
  final int contractsCompleted;

  SellerRanking({
    required this.userId,
    required this.userName,
    required this.totalEnergySold,
    required this.totalRevenue,
    required this.contractsCompleted,
  });

  factory SellerRanking.fromJson(Map<String, dynamic> json) {
    return SellerRanking(
      userId: json['user_id'] as int,
      userName: json['user_name'] as String,
      totalEnergySold: (json['total_energy_sold'] as num).toDouble(),
      totalRevenue: (json['total_revenue'] as num).toDouble(),
      contractsCompleted: json['contracts_completed'] as int,
    );
  }
}
