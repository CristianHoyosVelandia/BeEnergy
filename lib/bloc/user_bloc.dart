import 'package:be_energy/bloc/repository/repository_kupi.dart';
import 'package:bloc_provider/bloc_provider.dart';
import 'package:rxdart/rxdart.dart';
import '../models/callmodels.dart';

class UserBloc extends Bloc {
  
  final RespositoryBe _respositoryBe = RespositoryBe();
  final _getAppDataFetcher = PublishSubject<MyBeenergyAppResponse>();
  
  late EmpresasResponse empresasResponse;
  
  empresas() async {
    empresasResponse = await _respositoryBe.fetchGetEmpresas();
    return empresasResponse;
  }
  @override
  void dispose() {
    _getAppDataFetcher.close();
  }
}
