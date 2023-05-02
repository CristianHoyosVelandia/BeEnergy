// ignore_for_file: prefer_typing_uninitialized_variables

class MyBeenergyAppResponse {
  var status;
  var message;
  var app;

  MyBeenergyAppResponse({this.status, this.message, this.app});

  factory MyBeenergyAppResponse.fromJson(Map<String, dynamic> parsedJson) {
    MyBeenergyAppResponse myBeenergyAppResponse = MyBeenergyAppResponse(
      message: parsedJson['message'],
      app: AppBe.fromJson(parsedJson['app']),
      status: parsedJson['status']
    );
    return myBeenergyAppResponse;
  }
}


class AppBe {
  var codApp;
  var nomApp;
  var codEmpresa;
  var imgLogo;
  var imgHead;
  var colApp1;
  var colApp2;
  var colApp3;
  var colApp4;
  var colApp5;
  var colApp6;
  var retiroSaldo;
  var campo2;
  var campo3;
  var campo4;
  var campo5;
  var suscripciones;
  var paquetes;
  var compromisos;
  var soat;
  var pasacupo;
  var recargas;
  var usrCreacion;
  var fecCreacion;
  var usrEdicion;
  var fecEdicion;
  var registrar;

  AppBe({
    this.codApp,
    this.nomApp,
    this.codEmpresa,
    this.imgLogo,
    this.imgHead,
    this.colApp1,
    this.colApp2,
    this.colApp3,
    this.colApp4,
    this.colApp5,
    this.colApp6,
    this.retiroSaldo,
    this.campo2,
    this.campo3,
    this.campo4,
    this.campo5,
    this.compromisos,
    this.suscripciones,
    this.paquetes,
    this.soat,
    this.pasacupo,
    this.recargas,
    this.usrCreacion,
    this.fecCreacion,
    this.usrEdicion,
    this.fecEdicion,
    this.registrar
  });

  factory AppBe.fromJson(Map<String, dynamic> parsedJson) {
    AppBe appBe = AppBe(
      codApp: parsedJson['codApp'],
      nomApp: parsedJson['nomApp'],
      codEmpresa: parsedJson['codEmpresa '],
      imgLogo: parsedJson['imgLogo'],
      imgHead: parsedJson['imgHead'],
      colApp1: parsedJson['colApp1'],
      colApp2: parsedJson['colApp2'],
      colApp3: parsedJson['colApp3'],
      colApp4: parsedJson['colApp4'],
      colApp5: parsedJson['colApp5'],
      colApp6: parsedJson['colApp6'],
      retiroSaldo: parsedJson['retiroSaldo'],
      campo2: parsedJson['campo2'],
      campo3: parsedJson['campo3'],
      campo4: parsedJson['campo4'],
      campo5: parsedJson['campo5'],
      compromisos: parsedJson['compromisos'],
      suscripciones: parsedJson['suscripciones'],
      paquetes: parsedJson['paquetes'],
      soat: parsedJson['soat'],
      pasacupo: parsedJson['pasacupo'],
      recargas: parsedJson['recargas'],
      usrCreacion: parsedJson['usrCreacion'],
      fecCreacion: parsedJson['fecCreacion'],
      usrEdicion: parsedJson['usrEdicion'],
      fecEdicion: parsedJson['fecEdicion'],
      registrar: parsedJson['registrar']
    );
    return appBe;
  }
}
