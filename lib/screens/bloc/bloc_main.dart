
import 'package:be_energy/models/callmodels.dart';

class BlocBeenergy {

  Future<MyUser> getUserFromDB() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    return await dbHelper.getUser();
  }

  //metodo que permite visualizar si hay una nueva version de la app en las tiendas, de ser el caso, procede a sacar un alert
  //que permita la usuario descargar la nueva version
  
  // void checkVersion(context) async{

  //   NewVersion newVersion = NewVersion(
  //     // androidId: metodos.androidID(),
  //     iOSId: metodos.ioSID(),
  //     androidId: metodos.androidID(),
  //   );

  //   final status = await newVersion.getVersionStatus();
  //   // print(status);
  //   //si la version local es menor a la version de la tienda debo actualizar
    
  //   if(status!=null){
  //     print((status.localVersion).compareTo((status.storeVersion)).isNegative);
  //     if((status.localVersion).compareTo((status.storeVersion)).isNegative){
  //       newVersion.showUpdateDialog(
  //         context: context, 
  //         versionStatus: status,
  //         dialogTitle: 'Actualización Disponible',
  //         // dialogText: 'Puedes actualizar esta app desde la versión ${status.localVersion} a la versión ${status.storeVersion}',
  //         dialogText: "Una nueva actualización está disponible en la tienda",
  //         allowDismissal: true,
  //         dismissButtonText: 'Luego',
  //         updateButtonText: 'Actualizar',
  //       );
  //     }
  //   }

  // }
  

}