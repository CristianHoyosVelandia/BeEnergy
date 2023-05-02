import '../../models/callmodels.dart';
import 'api_be.dart';

class RespositoryBe{
  ApiBe apiBe = ApiBe();

  /*EMPRESAS*/
  Future<EmpresasResponse> fetchGetEmpresas() => apiBe.fetchGetEmpresas();
}