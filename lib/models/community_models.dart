class Community {
  final int id;
  final String name;
  final String description;
  final String location;
  final DateTime createdAt;

  Community({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.createdAt,
  });

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class CommunityMember {
  final int id;
  final int communityId;
  final int userId;
  final String userName;
  final String userLastName;
  final String role; // 'consumer' o 'prosumer'
  final double installedCapacity; // kW
  final double pdeShare; // Porcentaje de participación en PDE (0.0 - 1.0)
  final bool isActive;

  // ⭐ NUEVO: Identificación regulatoria CREG 101 072
  final String niu; // Número Identificación Única (NIU-{COMUNIDAD}-{ID}-{AÑO})
  final String documentType; // 'CC', 'NIT', 'CE', 'TI'
  final String documentNumber; // Número de documento
  final MemberCategory category; // Categoría del miembro
  final DateTime registrationDate; // Fecha de registro

  CommunityMember({
    required this.id,
    required this.communityId,
    required this.userId,
    required this.userName,
    required this.userLastName,
    required this.role,
    required this.installedCapacity,
    required this.pdeShare,
    this.isActive = true,
    this.niu = '',
    this.documentType = 'CC',
    this.documentNumber = '',
    this.category = MemberCategory.consumer,
    DateTime? registrationDate,
  }) : registrationDate = registrationDate ?? DateTime.now();

  String get fullName => '$userName $userLastName';

  bool get isConsumer => role == 'consumer';
  bool get isProsumer => role == 'prosumer';

  /// Valida formato NIU: NIU-{COMUNIDAD}-{ID}-{AÑO}
  bool get hasValidNIU {
    return RegExp(r'^NIU-[A-Z0-9]+-\d{3}-\d{4}$').hasMatch(niu);
  }

  factory CommunityMember.fromJson(Map<String, dynamic> json) {
    return CommunityMember(
      id: json['id'] as int,
      communityId: json['community_id'] as int,
      userId: json['user_id'] as int,
      userName: json['user_name'] as String,
      userLastName: json['user_lastname'] as String,
      role: json['role'] as String,
      installedCapacity: (json['installed_capacity'] as num).toDouble(),
      pdeShare: (json['pde_share'] as num).toDouble(),
      isActive: json['is_active'] as bool? ?? true,
      niu: json['niu'] as String? ?? '',
      documentType: json['document_type'] as String? ?? 'CC',
      documentNumber: json['document_number'] as String? ?? '',
      category: json['category'] != null
          ? MemberCategory.values.firstWhere(
              (e) => e.name == json['category'],
              orElse: () => MemberCategory.consumer,
            )
          : MemberCategory.consumer,
      registrationDate: json['registration_date'] != null
          ? DateTime.parse(json['registration_date'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'community_id': communityId,
      'user_id': userId,
      'user_name': userName,
      'user_lastname': userLastName,
      'role': role,
      'installed_capacity': installedCapacity,
      'pde_share': pdeShare,
      'is_active': isActive,
      'niu': niu,
      'document_type': documentType,
      'document_number': documentNumber,
      'category': category.name,
      'registration_date': registrationDate.toIso8601String(),
    };
  }
}

/// Categoría de miembro según su relación con generación/consumo
enum MemberCategory {
  /// Solo genera energía (raro en práctica)
  producer,

  /// Solo consume energía (sin generación)
  consumer,

  /// Genera y consume energía
  prosumer,
}

/// Estadísticas generales de la comunidad
class CommunityStats {
  final int totalMembers;
  final int totalProsumers;
  final int totalConsumers;
  final double totalInstalledCapacity;
  final double totalEnergyGenerated;
  final double totalEnergyConsumed;
  final double totalEnergyExported;
  final double totalEnergyImported;
  final int activeContracts;

  CommunityStats({
    required this.totalMembers,
    required this.totalProsumers,
    required this.totalConsumers,
    required this.totalInstalledCapacity,
    required this.totalEnergyGenerated,
    required this.totalEnergyImported,
    required this.totalEnergyConsumed,
    required this.totalEnergyExported,
    required this.activeContracts,
  });

  factory CommunityStats.fromJson(Map<String, dynamic> json) {
    return CommunityStats(
      totalMembers: json['total_members'] as int,
      totalProsumers: json['total_prosumers'] as int,
      totalConsumers: json['total_consumers'] as int,
      totalInstalledCapacity: (json['total_installed_capacity'] as num).toDouble(),
      totalEnergyGenerated: (json['total_energy_generated'] as num).toDouble(),
      totalEnergyImported: (json['total_energy_imported'] as num).toDouble(),
      totalEnergyConsumed: (json['total_energy_consumed'] as num).toDouble(),
      totalEnergyExported: (json['total_energy_exported'] as num).toDouble(),
      activeContracts: json['active_contracts'] as int,
    );
  }
}
