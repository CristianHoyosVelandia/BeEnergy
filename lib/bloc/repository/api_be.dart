// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'package:http/http.dart' show Client;
import '../../models/callmodels.dart';

class ApiBe{

  Client client = Client();

  final String codApp = '0';
  final String codVersion = '6.5.5'; //Estructura - Optimizaciones - mejoras visuales o errores
  static String base =  "https://kupi.com.co/ws";
  /*EMPRESAS*/
  final _baseGetEmpresas = "$base/getEmpresas";


  /*GET EMPRESAS*/
  Future<EmpresasResponse> fetchGetEmpresas() async {
    final response = await client.get(Uri.parse(_baseGetEmpresas), headers: {
      "codApp" : codApp,
      "codVersion" : codVersion,
      "buscar" : "",
      "categoria" : "",
      "codCiudad" : "4110" //Cali
      // "codCiudad" : "4136" //tulua

    });
    if(response.statusCode == 200){
      // for (var item in EmpresasResponse.fromJsonEmpresas(json.decode(response.body)).empresas) {
      //   log(item.nombre);
      // }
      // log("Response body get empresas: ${response.body}");
      return EmpresasResponse.fromJsonEmpresas(json.decode(response.body));
    }else{
      throw Exception('Error al conectar con Be');
    }
  }

}
