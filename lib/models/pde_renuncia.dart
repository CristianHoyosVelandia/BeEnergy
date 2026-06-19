class PdeRenunciaStatus {
  final int comunidadId;
  final int usuarioId;
  final String periodo;
  final double pdeActual;
  final double consumoKwh;
  final double pdeSugeridoRenuncia;
  final double pdeSugeridoConservado;
  final String? fuente;
  final String? nivelConfianza;
  final List<PdeRenunciaOption> opciones;
  final bool permiteRenunciaManual;
  final PdeRenuncia? renuncia;

  const PdeRenunciaStatus({
    required this.comunidadId,
    required this.usuarioId,
    required this.periodo,
    required this.pdeActual,
    required this.consumoKwh,
    required this.pdeSugeridoRenuncia,
    required this.pdeSugeridoConservado,
    this.fuente,
    this.nivelConfianza,
    this.opciones = const [],
    this.permiteRenunciaManual = true,
    this.renuncia,
  });

  factory PdeRenunciaStatus.fromJson(Map<String, dynamic> json) {
    final consumo = json['consumo_kwh'] as num? ??
        json['consumo_estimado_kwh'] as num? ??
        0;
    final renuncia = json['pde_sugerido_renuncia'] as num? ??
        json['renuncia_sugerida'] as num? ??
        0;
    final conservado = json['pde_sugerido_conservado'] as num? ??
        json['pde_conservado_sugerido'] as num? ??
        0;

    return PdeRenunciaStatus(
      comunidadId: json['comunidad_id'] as int,
      usuarioId: json['usuario_id'] as int,
      periodo: json['periodo'] as String,
      pdeActual: (json['pde_actual'] as num).toDouble(),
      consumoKwh: consumo.toDouble(),
      pdeSugeridoRenuncia: renuncia.toDouble(),
      pdeSugeridoConservado: conservado.toDouble(),
      fuente: json['fuente'] as String?,
      nivelConfianza: json['nivel_confianza'] as String?,
      opciones: (json['opciones'] as List<dynamic>? ?? [])
          .map((item) =>
              PdeRenunciaOption.fromJson(item as Map<String, dynamic>))
          .toList(),
      permiteRenunciaManual: json['permite_renuncia_manual'] as bool? ?? true,
      renuncia: json['renuncia'] == null
          ? null
          : PdeRenuncia.fromJson(json['renuncia'] as Map<String, dynamic>),
    );
  }
}

class PdeRenunciaOption {
  final String id;
  final double renunciaPorcentaje;
  final String descripcion;

  const PdeRenunciaOption({
    required this.id,
    required this.renunciaPorcentaje,
    required this.descripcion,
  });

  factory PdeRenunciaOption.fromJson(Map<String, dynamic> json) {
    return PdeRenunciaOption(
      id: json['id'] as String,
      renunciaPorcentaje: (json['renuncia_porcentaje'] as num).toDouble(),
      descripcion: json['descripcion'] as String,
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
  final double? renunciaKwh;
  final String? origen;
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
    this.renunciaKwh,
    this.origen,
    required this.estado,
    this.motivo,
  });

  factory PdeRenuncia.fromJson(Map<String, dynamic> json) {
    final usesPercentFields = json.containsKey('pde_actual') ||
        json.containsKey('renuncia_porcentaje');
    final pdeOriginal =
        json['pde_original'] as num? ?? json['pde_actual'] as num? ?? 0;
    final pdeRenunciado = json['pde_renunciado'] as num? ??
        json['renuncia_porcentaje'] as num? ??
        0;
    final pdeConservado = json['pde_conservado'] as num? ??
        (pdeOriginal.toDouble() - pdeRenunciado.toDouble())
            .clamp(0, pdeOriginal.toDouble());

    return PdeRenuncia(
      id: json['id'] as int,
      comunidadId: json['comunidad_id'] as int? ?? json['community_id'] as int,
      usuarioId: json['usuario_id'] as int? ?? json['user_id'] as int,
      periodo: json['periodo'] as String? ?? json['period'] as String,
      pdeOriginal: usesPercentFields
          ? pdeOriginal.toDouble() / 100
          : pdeOriginal.toDouble(),
      pdeRenunciado: usesPercentFields
          ? pdeRenunciado.toDouble() / 100
          : pdeRenunciado.toDouble(),
      pdeConservado: usesPercentFields
          ? pdeConservado.toDouble() / 100
          : pdeConservado.toDouble(),
      consumoKwh: (json['consumo_kwh'] as num?)?.toDouble(),
      pdeSugeridoRenuncia: (json['pde_sugerido_renuncia'] as num?)?.toDouble(),
      renunciaKwh: (json['renuncia_kwh'] as num?)?.toDouble(),
      origen: json['origen'] as String?,
      estado: json['estado'] as String,
      motivo: json['motivo'] as String?,
    );
  }
}
