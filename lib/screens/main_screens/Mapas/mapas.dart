import 'dart:async';

// import 'package:be_energy/screens/main_screens/Mapas/map_marker.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

import '../../../models/callmodels.dart';
import '../../../utils/metodos.dart';


class Mapas extends StatefulWidget {
  const Mapas({
    super.key, 
    required this.empresas, 
    required this.filtroDistancia,
    required this.distancia,
    required this.todasEmpresas,
    required this.buscador,
    required this.posicionInicial,
    this.filtroAgrupado = false
  });

  final List<Empresa> empresas;
  final List<Empresa> todasEmpresas;
  final bool filtroDistancia;
  final double distancia;
  final String buscador;
  final bool filtroAgrupado;
  final LatLng posicionInicial;

  @override
  State<Mapas> createState() => _MapasState();
}

class _MapasState extends State<Mapas> {

  // final PopupController _popupLayerController = PopupController();
  late Timer timer;
  late List<Empresa> empresas;

  bool esDispose = true;
  LatLng? _posicionActual;

  @override
  void initState() {
    super.initState();
    empresas = widget.empresas;
    _posicionActual = widget.posicionInicial;
  }

  _actualizarPosicion() async {
    Location location = Location();
    LocationData locationData;

    locationData = await location.getLocation();
    _posicionActual = LatLng(locationData.latitude!, locationData.longitude!);
  }

  _actualizarMarcas(){
     timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      _actualizarPosicion();
      empresas = widget.todasEmpresas.where((u) => (u.nombre.toLowerCase().contains(widget.buscador.toLowerCase())) || (u.palabrasClaves.toLowerCase().contains((widget.buscador.toLowerCase())))).toList();
      if(widget.filtroDistancia){
        empresas = empresas.where((element) => element.agrupado == '0' && element.latEmpresa != '' && element.lonEmpresa != '').toList();
        empresas = empresas.where((element) =>
          Metodos.distancia(
            _posicionActual?.latitude ?? 0, 
            _posicionActual?.longitude ?? 0, 
            double.parse(element.latEmpresa), 
            double.parse(element.lonEmpresa), 
            widget.distancia
          )).toList();
      }
      if(widget.filtroAgrupado){
        empresas = widget.empresas;
      }
      if(esDispose){
        // print('Nro Comercios: ${empresas.length} - Time: ${DateTime.now()}' );
        setState(() {});
      }
    });
  }

  IconButton _leading(BuildContext context, double width) {
    return IconButton(
      //icono de cerrar sesion
      icon: Icon(
        Icons.arrow_back_ios_rounded,
        color: Theme.of(context).scaffoldBackgroundColor,
        size: 25,
      ),
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(Theme.of(context).primaryColor),
        iconColor: WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor),
      ),

      tooltip: "Volver",
      onPressed: () {
        Navigator.pop(context);
        // metodos.alertsDialog(context, "¿Deseas ver en mapa los peers en tu ciudad?", width, "Cancelar", 2, "Si", 5);
      }
    );
  }
  
  Widget _contenPrincipalCard(){
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 50, 0, 0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //Image
              Card(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                color: Theme.of(context).scaffoldBackgroundColor,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                  child: Container(
                    width: 60,
                    height: 60,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      "assets/img/avatar.jpg",
                    ),
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 16, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0x40000000),
                          borderRadius:
                              BorderRadius.circular(8),
                        ),
                        child: _leading(context, Metodos.width(context))
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                "Cristian Hoyos V",
                style: TextStyle(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                )
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            const Padding(
              padding:
                  EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
              child: Text(
                'Ing. mecatrónico - ',
                style: TextStyle(
                  fontFamily: 'Lexend',
                  color: Color(0xB3FFFFFF),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(4, 8, 0, 0),
              child: Text(
                "cristiannhoyoss@gmail.com",
                style: TextStyle(
                  fontFamily: 'Lexend',
                  color: Theme.of(context).scaffoldBackgroundColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
    
      
  Widget _cartaPrincipal(){
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 200,
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            blurRadius: 6,
            color: Color(0x4B1A1F24),
            offset: Offset(0, 2),
          )
        ],
        gradient: Metodos.gradientClasic(context),
        borderRadius: BorderRadius.circular(0),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 0, 0),
        child: _contenPrincipalCard()
      ),
    );
            
  }
  
  @override
  void dispose() {
    timer.cancel();
    esDispose = false;
    super.dispose();
  }
  List<Widget> body(){
    return [
      _cartaPrincipal(),
      _body()
    ];
  }
  @override
  Widget build(BuildContext context) {
    _actualizarMarcas();
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(0.8)),
      child: Scaffold(
      // appBar: metodos.appbarSecundaria(context, "Transferir", ColorsApp.color4),
      // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SingleChildScrollView(
            // ignore: prefer_const_constructors
            child: GradientBackInsideApp(
              color: Theme.of(context).focusColor,
              height: 85,
              opacity: 0.75,
            )
          ),
          ListView(
            children: body()
          ),
        ]
      ),
    ));
  }

  // List<Marker> _marcasMapa() {
  //   List<Marker> marcas = [];
  //   if(_posicionActual!=null){
  //     marcas.add(Marker(
  //       point: LatLng(_posicionActual!.latitude, _posicionActual!.longitude),
  //       child: (BuildContext context) => const Icon(Icons.location_history, size: 40, color: Colors.red)
  //     ));
  //   }
  //   for (var empresa in empresas) {
  //     if(empresa.agrupado == '1'){
  //       for(var empresaAgrupada in empresa.empresas){
  //         if(empresaAgrupada.latEmpresa != '' && empresaAgrupada.lonEmpresa != '') {
  //           marcas.add(MapMarker(empresasAgrupadas: empresaAgrupada, esAgrupado: true));
  //         }
  //       }
  //     } else {
  //       if(empresa.latEmpresa != '' && empresa.lonEmpresa != ''){
  //         marcas.add(MapMarker(empresa: empresa));
  //       }
  //     }
  //   }

  //   return marcas;
  // }

  Widget _body() {

    return Placeholder();
    // return FlutterMap(
    //   options: MapOptions(
    //     center: _posicionActual,
    //     zoom: 15,
    //     interactiveFlags: InteractiveFlag.all,
    //     onTap: (_, __) => _popupLayerController.hideAllPopups(),
    //   ),
    //   children: <Widget>[
    //     TileLayerWidget(
    //       options: TileLayerOptions(
    //         urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
    //         subdomains: <String>['a', 'b', 'c'],
    //       ),
    //     ),
      
        // PopupMarkerLayerWidget(
        //   options: PopupMarkerLayerOptions(
        //     markers: _marcasMapa(),
        //     popupController: _popupLayerController,
        //     popupBuilder: (_, Marker marker) {
        //       if (marker is MapMarker) {
        //         return MapMarkerPopup(
        //           empresa: marker.empresa, 
        //           empresaAgrupada: marker.empresasAgrupadas,
        //           esAgrupado: marker.esAgrupado,
        //           ubicacionActual: _posicionActual!,
        //         );
        //       }
        //       return _cartaUsario();
        //     },
        //   ),
        // ),
      
      // ],
    // );
  }

  // Widget _cartaUsario() {
  //   return Card(
  //     margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  //     child: Padding(
  //       padding: const EdgeInsets.all(10.0),
  //       child: Text(
  //         '¡Estás aquí!', 
  //         style: Metodos.descripcionTextStyle(context)
  //       ),
  //     ),
  //   );
  // }

}