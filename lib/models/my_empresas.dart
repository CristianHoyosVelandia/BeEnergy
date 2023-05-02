
// ignore_for_file: prefer_typing_uninitialized_variables

class Empresa{

  var nombre;
  var promedio;
  var nit;
  var direccion;
  var descripcion;
  var urlImagen;
  var urlIcon;
  var codEmpresa;
  // var url_icon;
  var telEmpresa;
  var latEmpresa;
  var lonEmpresa;
  var urlWeb;
  var whatsapp;
  var id;
  var type ;
  var agrupado;
  var empresas;
  var palabrasClaves;
  //List<CategoriasAsociadas> categorias_asociadas;

  Empresa({
    this.nombre,
    this.promedio,
    this.nit,
    this.direccion,
    this.descripcion,
    this.urlImagen,
    this.urlIcon,
    this.codEmpresa,
    // this.url_icon,
    this.telEmpresa,
    this.latEmpresa,
    this.lonEmpresa,
    this.urlWeb,
    this.whatsapp,
    this.id,
    this.type ,
    this.agrupado,
    this.empresas,
    this.palabrasClaves
    //this.categorias_asociadas,
  });

  factory Empresa.fromJson(Map<String, dynamic> parsedJson){
    //var list = parsedJson['categorias_asociadas'] as List;
    List<EmpresasAgrupadas> empresaschiquitas = [];
    if(parsedJson['agrupado']=="1"){
      var list = parsedJson['empresas'] as List;
      empresaschiquitas = list.map((i) => EmpresasAgrupadas.fromJson(i)).toList();
    }
    
    return Empresa(
        agrupado:parsedJson['agrupado'],
        nombre:parsedJson['nombre'],
        promedio:parsedJson['promedio'],
        nit:parsedJson['nit'],
        direccion:parsedJson['direccion'],
        descripcion:parsedJson['descripcion'],
        urlImagen:parsedJson['urlImagen'],
        urlIcon:parsedJson['urlIcon'],
        codEmpresa:parsedJson['codEmpresa'],
        // url_icon:parsedJson['url_icon'],
        telEmpresa:parsedJson['telEmpresa'],
        latEmpresa:parsedJson['latEmpresa'],
        lonEmpresa:parsedJson['lonEmpresa'],
        urlWeb:parsedJson['urlWeb'],
        whatsapp:parsedJson['whatsapp'],
        id:parsedJson['id'],
        type:parsedJson['type'],
        palabrasClaves: parsedJson['palabrasClaves'],
        empresas: empresaschiquitas
        
    );
  }
}


class EmpresasAgrupadas{
  var nombre;
  var promedio;
  var nit;
  var direccion;
  var descripcion;
  var urlImagen;
  var urlIcon;
  var codEmpresa;
  // var url_icon;
  var telEmpresa;
  var latEmpresa;
  var lonEmpresa;
  var urlWeb;
  var whatsapp;
  var id;
  var type ;
  var agrupado;
  //List<CategoriasAsociadas> categorias_asociadas;
  var empresas;
  // List<EmpresasAgrupadas> empresas;
  
  EmpresasAgrupadas({
    this.nombre,
    this.promedio,
    this.nit,
    this.direccion,
    this.descripcion,
    this.urlImagen,
    this.urlIcon,
    this.codEmpresa,
    // this.url_icon,
    this.telEmpresa,
    this.latEmpresa,
    this.lonEmpresa,
    this.urlWeb,
    this.whatsapp,
    this.id,
    this.type ,
    this.agrupado,
    //this.categorias_asociadas,
  });

  factory EmpresasAgrupadas.fromJson(Map<String, dynamic> parsedJson){
    //var list = parsedJson['categorias_asociadas'] as List;
    //List<CategoriasAsociadas> categoriasAsociadasList = list.map((i) => CategoriasAsociadas.fromJson(i)).toList();
    return EmpresasAgrupadas(
        agrupado:parsedJson['agrupado'],
        nombre:parsedJson['nombre'],
        promedio:parsedJson['promedio'],
        nit:parsedJson['nit'],
        direccion:parsedJson['direccion'],
        descripcion:parsedJson['descripcion'],
        urlImagen:parsedJson['urlImagen'],
        urlIcon:parsedJson['urlIcon'],
        codEmpresa:parsedJson['codEmpresa'],
        // url_icon:parsedJson['url_icon'],
        telEmpresa:parsedJson['telEmpresa'],
        latEmpresa:parsedJson['latEmpresa'],
        lonEmpresa:parsedJson['lonEmpresa'],
        urlWeb:parsedJson['urlWeb'],
        whatsapp:parsedJson['whatsapp'],
        id:parsedJson['id'],
        type:parsedJson['type'],        
    );
  }
}


class EmpresasResponse {
  // bool status;
  // String message;
  // List<Empresa> empresas;
  // List<Pregunta> preguntas;
  // List<Empresa> sucursalesempresas;

  var status;
  var message;
  var empresas;
  var preguntas;
  var sucursalesempresas;


  EmpresasResponse({
    this.status,
    this.message,
    this.empresas,
    this.preguntas,
    this.sucursalesempresas
  });

  factory EmpresasResponse.fromJsonEmpresas(Map<String, dynamic> parsedJson) {
    if(parsedJson['status']){
      var list = parsedJson['empresas'] as List;
      List<Empresa> empresasList = list.map((i) => Empresa.fromJson(i)).toList();
      return EmpresasResponse(
        status:parsedJson['status'],
        message:parsedJson['message'],
        empresas:empresasList,
      );
    }else{
      return EmpresasResponse(
        status:parsedJson['status'],
        message:parsedJson['message'],
        empresas:null,
        preguntas: null
      );
    }
  }
}

