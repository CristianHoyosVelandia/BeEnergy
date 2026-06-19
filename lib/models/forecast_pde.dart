class ForecastOfertaPde {
  final int userId;
  final int communityId;
  final String period;
  final double consumoEstimadoKwh;
  final double generacionEstimadaComunidadKwh;
  final double pdeRecomendado;
  final double tarifaCopKwh;
  final String nivelConfianza;
  final String fuente;
  final List<ForecastEscenarioOferta> escenarios;
  final bool permiteOfertaManual;

  const ForecastOfertaPde({
    required this.userId,
    required this.communityId,
    required this.period,
    required this.consumoEstimadoKwh,
    required this.generacionEstimadaComunidadKwh,
    required this.pdeRecomendado,
    required this.tarifaCopKwh,
    required this.nivelConfianza,
    required this.fuente,
    required this.escenarios,
    required this.permiteOfertaManual,
  });

  factory ForecastOfertaPde.fromJson(Map<String, dynamic> json) {
    return ForecastOfertaPde(
      userId: json['user_id'] as int,
      communityId: json['community_id'] as int,
      period: json['period'] as String,
      consumoEstimadoKwh: (json['consumo_estimado_kwh'] as num).toDouble(),
      generacionEstimadaComunidadKwh:
          (json['generacion_estimada_comunidad_kwh'] as num).toDouble(),
      pdeRecomendado: (json['pde_recomendado'] as num).toDouble(),
      tarifaCopKwh: (json['tarifa_cop_kwh'] as num).toDouble(),
      nivelConfianza: json['nivel_confianza'] as String,
      fuente: json['fuente'] as String,
      escenarios: (json['escenarios'] as List<dynamic>? ?? [])
          .map((item) =>
              ForecastEscenarioOferta.fromJson(item as Map<String, dynamic>))
          .toList(),
      permiteOfertaManual: json['permite_oferta_manual'] as bool? ?? true,
    );
  }
}

class ForecastEscenarioOferta {
  final String id;
  final double pdePorcentaje;
  final double pdeKwh;
  final double ahorroEstimadoCop;
  final String descripcion;

  const ForecastEscenarioOferta({
    required this.id,
    required this.pdePorcentaje,
    required this.pdeKwh,
    required this.ahorroEstimadoCop,
    required this.descripcion,
  });

  factory ForecastEscenarioOferta.fromJson(Map<String, dynamic> json) {
    return ForecastEscenarioOferta(
      id: json['id'] as String,
      pdePorcentaje: (json['pde_porcentaje'] as num).toDouble(),
      pdeKwh: (json['pde_kwh'] as num).toDouble(),
      ahorroEstimadoCop: (json['ahorro_estimado_cop'] as num).toDouble(),
      descripcion: json['descripcion'] as String,
    );
  }
}

class ForecastAporteSolidario {
  final int userId;
  final int communityId;
  final String period;
  final double pdeActual;
  final double consumoEstimadoKwh;
  final double renunciaSugerida;
  final double pdeConservadoSugerido;
  final String nivelConfianza;
  final String fuente;
  final List<ForecastOpcionAporte> opciones;
  final bool permiteRenunciaManual;

  const ForecastAporteSolidario({
    required this.userId,
    required this.communityId,
    required this.period,
    required this.pdeActual,
    required this.consumoEstimadoKwh,
    required this.renunciaSugerida,
    required this.pdeConservadoSugerido,
    required this.nivelConfianza,
    required this.fuente,
    required this.opciones,
    required this.permiteRenunciaManual,
  });

  factory ForecastAporteSolidario.fromJson(Map<String, dynamic> json) {
    return ForecastAporteSolidario(
      userId: json['user_id'] as int,
      communityId: json['community_id'] as int,
      period: json['period'] as String,
      pdeActual: (json['pde_actual'] as num).toDouble(),
      consumoEstimadoKwh: (json['consumo_estimado_kwh'] as num).toDouble(),
      renunciaSugerida: (json['renuncia_sugerida'] as num).toDouble(),
      pdeConservadoSugerido:
          (json['pde_conservado_sugerido'] as num).toDouble(),
      nivelConfianza: json['nivel_confianza'] as String,
      fuente: json['fuente'] as String,
      opciones: (json['opciones'] as List<dynamic>? ?? [])
          .map((item) =>
              ForecastOpcionAporte.fromJson(item as Map<String, dynamic>))
          .toList(),
      permiteRenunciaManual: json['permite_renuncia_manual'] as bool? ?? true,
    );
  }
}

class ForecastOpcionAporte {
  final String id;
  final double renunciaPorcentaje;
  final String descripcion;

  const ForecastOpcionAporte({
    required this.id,
    required this.renunciaPorcentaje,
    required this.descripcion,
  });

  factory ForecastOpcionAporte.fromJson(Map<String, dynamic> json) {
    return ForecastOpcionAporte(
      id: json['id'] as String,
      renunciaPorcentaje: (json['renuncia_porcentaje'] as num).toDouble(),
      descripcion: json['descripcion'] as String,
    );
  }
}
