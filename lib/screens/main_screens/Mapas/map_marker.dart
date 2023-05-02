import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../models/callmodels.dart';
import '../../../utils/metodos.dart';

class MapMarker extends Marker {
  MapMarker({
    this.empresa, 
    this.empresasAgrupadas, 
    this.esAgrupado = false
  })
  : super(
      point: LatLng(
        double.parse(empresa?.latEmpresa ?? empresasAgrupadas?.latEmpresa), 
        double.parse(empresa?.lonEmpresa ?? empresasAgrupadas?.lonEmpresa)
      ),
      builder: (context) => const Image(
                  alignment: AlignmentDirectional.center,
                  image: AssetImage("assets/img/logo.png"),
                  width: 30.0,
                  height: 30.0,
                ),
    );

  final Empresa? empresa;
  final EmpresasAgrupadas? empresasAgrupadas;
  final bool esAgrupado;
}

class MapMarkerPopup extends StatelessWidget {
  const MapMarkerPopup({
    Key? key, 
    required this.ubicacionActual,
    this.empresa, 
    this.empresaAgrupada, 
    this.esAgrupado = false,
  }) : super(key: key);

  final Empresa? empresa;
  final EmpresasAgrupadas? empresaAgrupada;
  final bool esAgrupado;
  final LatLng ubicacionActual;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: (){
        if (kDebugMode) {
          print(esAgrupado);
        }
      },
      child: SizedBox(
        width: 200,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            padding: const EdgeInsets.all(5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image.network(empresa?.urlImagen ?? empresaAgrupada?.urlImagen, width: 200),
                Text(
                  empresa?.nombre ?? empresaAgrupada?.nombre, 
                  style: Metodos.descripcionTextStyle(context),
                  textAlign: TextAlign.center,
                ),
                // Text('${empresa.latEmpresa}-${empresa.lonEmpresa}'),
                Text(
                  '${empresa?.direccion ?? empresaAgrupada?.direccion}', 
                  style: Metodos.subtitulosInformativos(context),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}