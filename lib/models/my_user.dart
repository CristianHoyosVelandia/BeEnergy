
class MyUser {

  final int?  idUser; 
  final String? nombre;
  final String? telefono;
  final String? correo; 
  final String? clave;
  final String? energia; 
  final String? dinero;
  final int?    idCiudad;

  //Constructor de la clase
  MyUser({
    this.idUser,
    this.nombre,
    this.telefono,
    this.correo,
    this.clave,
    this.energia,
    this.dinero,
    this.idCiudad
  });

  //Conversión a Map
  Map<String, dynamic> toMap() {
    return {
      'idUser': idUser,
      'nombre': nombre,
      'telefono': telefono,
      'correo': correo,
      'clave': clave,
      'energia': energia,
      'dinero': dinero,
      'idCiudad': idCiudad
    };
  }


}

class MyUserResponse{

  
  late bool?    _status;
  late String?  _message;
  late String?  _idUser;
  late String?  _correo;
  late String?  _clave;
  
  late String?  _nombre;
  late String?  _telefono;
  late String?  _energia;
  late String?  _dinero;
  late String?  _idCiudad;

  //ValidateUser
  MyUserResponse.fromJsonValidateUser(Map<String, dynamic> parsedJson) {
    _status   = parsedJson['status'];
    _message  = parsedJson['message'];
    _idUser   = parsedJson['idUser'];
    _correo   = parsedJson['correo'];
    _clave    = parsedJson['clave'];
  }

  //Get Data User
  MyUserResponse.fromJsonGetDataUser(Map<String, dynamic> parsedJson) {
    _status   = parsedJson['status'];
    _message  = parsedJson['message'];
    _idUser   = parsedJson['idUser'];
    _correo   = parsedJson['correo'];
    _clave    = parsedJson['clave'];
    _nombre   = parsedJson['nombre'];
    _telefono = parsedJson['telefono'];
    _energia  = parsedJson['energia'];
    _dinero   = parsedJson['dinero'];
    _idCiudad = parsedJson['idCiudad'];
  }


  MyUserResponse.fromChangePassJson(Map<String, dynamic> parsedJson) {
    _status = parsedJson['status'];
    _message = parsedJson['message'];
  }


  bool?   get status    => _status;
  String? get message => _message;
  String? get idUser    => _idUser;
  String? get correo    => _correo;
  String? get clave     => _clave;

  String? get nombre    => _nombre;
  String? get telefono  => _telefono;
  String? get energia   => _energia;
  String? get dinero    => _dinero;
  String? get idCiudad  => _idCiudad;

}

class Usuarios {
  late bool? status;
  late String? message;
  late List? usuarios;

  Usuarios({
    this.status,
    this.message,
    this.usuarios
  });

  factory Usuarios.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['usuarios'] as List;
    List<MyUserResponse> usersList = list.map((i) => MyUserResponse.fromJsonGetDataUser(i)).toList();
    return Usuarios(
        status:parsedJson['status'],
        message:parsedJson['message'],
        usuarios:usersList
    );
  }

  get getUsuarios => usuarios;
}