class PdeRenunciaStatus {
  final int comunidadId;
  final int usuarioId;
  final String periodo;
  final double pdeActual;
  final double consumoKwh;
  final double pdeSugeridoRenuncia;
  final double pdeSugeridoConservado;
  final PdeRenuncia? renuncia;

  const PdeRenunciaStatus({
    required this.comunidadId,
    required this.usuarioId,
    required this.periodo,
    required this.pdeActual,
    required this.consumoKwh,
    required this.pdeSugeridoRenuncia,
    required this.pdeSugeridoConservado,
    this.renuncia,
  });

  factory PdeRenunciaStatus.fromJson(Map<String, dynamic> json) {
    return PdeRenunciaStatus(
      comunidadId: json['comunidad_id'] as int,
      usuarioId: json['usuario_id'] as int,
      periodo: json['periodo'] as String,
      pdeActual: (json['pde_actual'] as num).toDouble(),
      consumoKwh: (json['consumo_kwh'] as num).toDouble(),
      pdeSugeridoRenuncia: (json['pde_sugerido_renuncia'] as num).toDouble(),
      pdeSugeridoConservado:
          (json['pde_sugerido_conservado'] as num).toDouble(),
      renuncia: json['renuncia'] == null
          ? null
          : PdeRenuncia.fromJson(json['renuncia'] as Map<String, dynamic>),
    );
  }
}

class PdeRenuncia {
  final int id;
  final int comunidadId;
  final int usuarioId;
  final String periodo;
  final double pdeOriginal;
  final double pdeRenunciado;
  final double pdeConservado;
  final double? consumoKwh;
  final double? pdeSugeridoRenuncia;
  final String estado;
  final String? motivo;

  const PdeRenuncia({
    required this.id,
    required this.comunidadId,
    required this.usuarioId,
    required this.periodo,
    required this.pdeOriginal,
    required this.pdeRenunciado,
    required this.pdeConservado,
    this.consumoKwh,
    this.pdeSugeridoRenuncia,
    required this.estado,
    this.motivo,
  });

  factory PdeRenuncia.fromJson(Map<String, dynamic> json) {
    return PdeRenuncia(
      id: json['id'] as int,
      comunidadId: json['comunidad_id'] as int,
      usuarioId: json['usuario_id'] as int,
      periodo: json['periodo'] as String,
      pdeOriginal: (json['pde_original'] as num).toDouble(),
      pdeRenunciado: (json['pde_renunciado'] as num).toDouble(),
      pdeConservado: (json['pde_conservado'] as num).toDouble(),
      consumoKwh: (json['consumo_kwh'] as num?)?.toDouble(),
      pdeSugeridoRenuncia: (json['pde_sugerido_renuncia'] as num?)?.toDouble(),
      estado: json['estado'] as String,
      motivo: json['motivo'] as String?,
    );
  }
}
