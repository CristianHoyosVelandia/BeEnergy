// ignore_for_file: file_names, avoid_print

import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import '../models/my_user.dart';

/* La clase database Helper es la encargada del manejo de todas las bases de datos dentro de la 
 aplicación
*/
class DatabaseHelper{

  final String tbUsuarioLogIn = "UsuarioLogIn";
  final String tbUsuarios = "Usuarios";

  //Creo una instancia de Database
  static Database? deInstance;

  //el futuro del tipo database que me obtiene los valores de la base de datos
  Future<Database?> get db async {
    deInstance ??= await initDB();
    return deInstance;
  }

  //inicializo la base de datos
  initDB() async {

    final databasesPath = await getDatabasesPath();
    //Creo la base de datos de la app
    String path = join(databasesPath, "beEnergy.db");
    var db = await openDatabase(path, version: 2, onCreate: onCreate, onUpgrade: onUpgrade);
    // var version = await db.getVersion();
    // print("-------------------> Database version: $version");

    return db;
  }

  //Crea la base de datos del usuario
  void onCreate(Database db, int version) async {
    // se crean las tablas
    await db.execute('CREATE TABLE IF NOT EXISTS $tbUsuarioLogIn(idUser INTEGER PRIMARY KEY, nombre TEXT, telefono TEXT, correo TEXT, clave TEXT, energia TEXT, dinero TEXT, idCiudad INTEGER);');
    await db.execute('CREATE TABLE IF NOT EXISTS $tbUsuarios    (idUser INTEGER PRIMARY KEY, nombre TEXT, telefono TEXT, correo TEXT, clave TEXT, energia TEXT, dinero TEXT, idCiudad INTEGER);');
  }

  //Actualiza la base de datos interna del usuario
  void onUpgrade(Database db, int oldVersion, int newVersion) async {
    // se actualizan las tablas
    // print("Version vieja: $oldVersion, version nueva: $newVersion");
    if( oldVersion < newVersion)
    {
      // print('Reset base de datos');
      //DROPSS
      await db.execute('DROP TABLE IF EXISTS $tbUsuarioLogIn');
      await db.execute('DROP TABLE IF EXISTS $tbUsuarios');
      //CREATEE
      await db.execute('CREATE TABLE IF NOT EXISTS $tbUsuarioLogIn (idUser INTEGER PRIMARY KEY, nombre TEXT, telefono TEXT, correo TEXT, clave TEXT, energia TEXT, dinero TEXT, idCiudad INTEGER);');
      await db.execute('CREATE TABLE IF NOT EXISTS $tbUsuarios (idUser INTEGER PRIMARY KEY, nombre TEXT, telefono TEXT, correo TEXT, clave TEXT, energia TEXT, dinero TEXT, idCiudad INTEGER);');
    }
  }

  ////////////////////////////////////////////////////////////////////
  //Acciones en la tabla de userLogin
  ////////////////////////////////////////////////////////////////////
    //getUser me trae un usuario si se encuentra logueado
    Future<MyUser> getUser() async {
      var dbConecction = await db;
      final List<Map<String, dynamic>> maps = await dbConecction!.query(tbUsuarioLogIn);
      // print("maps lengt: ${maps.length}");
      final emptyUser = MyUser(
        idUser: 0,
        nombre: "",
        telefono: "",
        correo: "",
        clave: "",
        energia: "",
        dinero: "",
        idCiudad: 0,
      );

      if(maps.isNotEmpty){
        return List.generate(maps.length, (i) {
          return MyUser(
            idUser    : maps[i]['idUser'],
            nombre    : maps[i]['nombre'],
            telefono  : maps[i]['telefono'],
            correo    : maps[i]['correo'],
            clave     : maps[i]['clave'],
            energia   : maps[i]['energia'],
            dinero    : maps[i]['dinero'],
            idCiudad  : maps[i]['idCiudad'],
          );
        })[0];    
      }else {
        return emptyUser;
      }
    }

    //Insert el usuario si no presenta datos en la tabla
    void insertUser(MyUser usuarioLocal) async {
      var dbConnection = await db;
      int? nUsers = Sqflite.firstIntValue(await dbConnection!.rawQuery('SELECT COUNT(*) FROM $tbUsuarioLogIn'));
      if(nUsers! < 1){
        String query = 'INSERT INTO $tbUsuarioLogIn (idUser, nombre, telefono, correo, clave, energia, dinero, idCiudad) VALUES(\'${usuarioLocal.idUser}\', \'${usuarioLocal.nombre}\', \'${usuarioLocal.telefono}\', \'${usuarioLocal.correo}\', \'${usuarioLocal.clave}\', \'${usuarioLocal.energia}\',\'${usuarioLocal.dinero}\', \'${usuarioLocal.idCiudad}\')';
        await dbConnection.transaction((transaction) async {
          return await transaction.rawInsert(query);
        });
      }
    }

    // Agrega el usuario para mantenerlo Log
    Future<void> addUser(MyUser usuarioLocal) async {
      final Database? dbConnection = await db;
      int? nUsers = Sqflite.firstIntValue(await dbConnection!.rawQuery('SELECT COUNT(*) FROM $tbUsuarioLogIn'));
      final user = await getUser();
      // final users = await getUsers();
      // print("--> ${users.usuarios.toMap()}");
      // print("---> ${user.toMap()}");
      // print("---> ${usuarioLocal.toMap()}");
      // print("---> $nUsers");
      if(nUsers! < 1){
        await dbConnection.insert(
          tbUsuarioLogIn,
          usuarioLocal.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } 
      if (nUsers == 1) {
        if(user.idUser == 0) {
          // print("-----> Borrando registros");
          await dbConnection.delete(
            tbUsuarioLogIn,
            where: "idUser = 0"
          );

          // print("-----> Creando nuevo registros");
          await dbConnection.insert(
            tbUsuarioLogIn,
            usuarioLocal.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    }

    // Acualiza los datos del usuario
    void updateUserLoginLocal(MyUser usuarioLocal) async {
      // print('Usuario actualizaco en la base de datos local');
      final dbConnection = await db;
      await dbConnection!.update(
        tbUsuarioLogIn, 
        usuarioLocal.toMap(), 
        where: "idUser = ?", 
        whereArgs: [usuarioLocal.idUser],
      );
    }

    // Elimino la data de usuario al cerrar sec
    void deleteUserLocal(int? idUser) async {
      final dbConnection = await db;
      await dbConnection!.delete(
        tbUsuarioLogIn,
        where: "idUser = ?",
        whereArgs: [idUser],
      );
    }

  ////////////////////////////////////////////////////////////////////
  //Fin Acciones en la tabla de userLogin
  ////////////////////////////////////////////////////////////////////
  





  ////////////////////////////////////////////////////////////////////
  //Acciones en la tabla de usuarios
  ////////////////////////////////////////////////////////////////////
    //getUser me trae un usuario si se encuentra logueado
    Future<Usuarios> getUsers() async {
      var dbConecction = await db;
      final List<Map<String, dynamic>> maps = await dbConecction!.query(tbUsuarios);
      
      final emptyUser = MyUser(
        idUser: 0,
        nombre: "",
        telefono: "",
        correo: "",
        clave: "",
        energia: "",
        dinero: "",
        idCiudad: 0,
      );

      if(maps.isNotEmpty){

        List<MyUser> usersList = [];
        
        for (var i = 0; i < maps.length; i++) {
          
          MyUser usuario = MyUser(
            idUser    : maps[i]['idUser'],
            nombre    : maps[i]['nombre'],
            telefono  : maps[i]['telefono'],
            correo    : maps[i]['correo'],
            clave     : maps[i]['clave'],
            energia   : maps[i]['energia'],
            dinero    : maps[i]['dinero'],
            idCiudad  : maps[i]['idCiudad'],
          );
          usersList.add(usuario);
        }
  
        return Usuarios(
          status: false,
          message:'Con usuarios registrados',
          usuarios: usersList,
        );  
      }
      
      else {
        List<MyUser> usersList = [];
        usersList.add(emptyUser);
        // print('Sin usuarios registrados');
        return Usuarios(
          status: false,
          message:'Sin usuarios registrados',
          usuarios: usersList,
        );
      }
    }

    // Agrega el usuario a la tabla de usuarios
    Future<void> addUsertbUsuarios(MyUser usuarioLocal) async {
      final Database? dbConnection = await db;
      int? nUsers = Sqflite.firstIntValue(await dbConnection!.rawQuery('SELECT COUNT(*) FROM $tbUsuarios'));
      print(nUsers);
      // print("----> creando usuarios nuevo insert");
      await dbConnection.insert( tbUsuarios, usuarioLocal.toMap());

    }

    // Acualiza los datos del usuario
    void updateUserBase(MyUser usuarioLocal) async {
    final dbConnection = await db;

    await dbConnection?.update(
      tbUsuarios, 
      usuarioLocal.toMap(), 
      where: "idUser = ?",
      whereArgs: [usuarioLocal.idUser],
    );
  }

  ////////////////////////////////////////////////////////////////////
  // Fin Acciones en la tabla de usuarios
  ////////////////////////////////////////////////////////////////////
}


  