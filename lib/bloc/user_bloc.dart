import 'package:be_energy/repositories/empresas_repository.dart';
import 'package:bloc_provider/bloc_provider.dart';
import 'package:rxdart/rxdart.dart';
import '../models/callmodels.dart';

class UserBloc extends Bloc {
  
  final EmpresasRepository _empresasRepository = EmpresasRepository();
  final _getAppDataFetcher = PublishSubject<MyBeenergyAppResponse>();
  
  late EmpresasResponse empresasResponse;
  
  empresas() async {
    empresasResponse = await _empresasRepository.fetchGetEmpresas();
    return empresasResponse;
  }
  @override
  void dispose() {
    _getAppDataFetcher.close();
  }
}
