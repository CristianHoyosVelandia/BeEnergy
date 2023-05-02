import 'dart:async';

import 'package:be_energy/screens/main_screens/Mapas/map_marker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

import '../../../models/callmodels.dart';
import '../../../utils/metodos.dart';


class Mapas extends StatefulWidget {
  const Mapas({
    Key? key, 
    required this.empresas, 
    required this.filtroDistancia,
    required this.distancia,
    required this.todasEmpresas,
    required this.buscador,
    required this.posicionInicial,
    this.filtroAgrupado = false
  }) : super(key: key);

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

  final PopupController _popupLayerController = PopupController();
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

  @override
  void dispose() {
    timer.cancel();
    esDispose = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _actualizarMarcas();
    return FondoScreen(
      showCircles: true,
      backButton: true,
      marginBody: 20,
      heightAppBar: 20,
      radiusAppBar: 20,
      body: _body(),
      backButtonPressed: () {
        Navigator.pop(context);
      },
    );
  }

  List<Marker> _marcasMapa() {
    List<Marker> marcas = [];
    if(_posicionActual!=null){
      marcas.add(Marker(
        point: LatLng(_posicionActual!.latitude, _posicionActual!.longitude),
        builder: (BuildContext context) => const Icon(Icons.location_history, size: 40, color: Colors.red)
      ));
    }
    for (var empresa in empresas) {
      if(empresa.agrupado == '1'){
        for(var empresaAgrupada in empresa.empresas){
          if(empresaAgrupada.latEmpresa != '' && empresaAgrupada.lonEmpresa != '') {
            marcas.add(MapMarker(empresasAgrupadas: empresaAgrupada, esAgrupado: true));
          }
        }
      } else {
        if(empresa.latEmpresa != '' && empresa.lonEmpresa != ''){
          marcas.add(MapMarker(empresa: empresa));
        }
      }
    }

    return marcas;
  }

  Widget _body() {
    return FlutterMap(
      options: MapOptions(
        center: _posicionActual,
        zoom: 15,
        interactiveFlags: InteractiveFlag.all,
        onTap: (_, __) => _popupLayerController.hideAllPopups(),
      ),
      children: <Widget>[
        TileLayerWidget(
          options: TileLayerOptions(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: <String>['a', 'b', 'c'],
          ),
        ),
        PopupMarkerLayerWidget(
          options: PopupMarkerLayerOptions(
            markers: _marcasMapa(),
            popupController: _popupLayerController,
            popupBuilder: (_, Marker marker) {
              if (marker is MapMarker) {
                return MapMarkerPopup(
                  empresa: marker.empresa, 
                  empresaAgrupada: marker.empresasAgrupadas,
                  esAgrupado: marker.esAgrupado,
                  ubicacionActual: _posicionActual!,
                );
              }
              return _cartaUsario();
            },
          ),
        ),
      ],
    );
  }

  Widget _cartaUsario() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          '¡Estás aquí!', 
          style: Metodos.descripcionTextStyle(context)
        ),
      ),
    );
  }

}