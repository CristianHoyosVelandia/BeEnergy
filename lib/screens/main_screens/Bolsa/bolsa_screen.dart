import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import '../../../bloc/user_bloc.dart';
import '../../../models/callmodels.dart';
import '../../../routes.dart';
import '../../../utils/metodos.dart';
import '../../../widgets/general_widgets.dart';

class BolsaScreen extends StatefulWidget {
  const BolsaScreen({Key? key}) : super(key: key);

  @override
  State<BolsaScreen> createState() => _BolsaScreenState();
}

class _BolsaScreenState extends State<BolsaScreen> {
  Metodos metodos = Metodos();
  LatLng _posicionActual = LatLng(0,0);
  late Future<EmpresasResponse> myEmpresas;
  late List<Empresa> totalEmpresas;
  bool filtroComerciosCercanos = false;
  bool filtroComerciosAgrupados = false;
  double distanciaComercios = 0.5;
  String buscador = '';



  Future<EmpresasResponse> _getEmpresas() async {
    UserBloc userBloc = UserBloc();
    return await userBloc.empresas();
  }
  _permission() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();
    _posicionActual = LatLng(locationData.latitude!, locationData.longitude!);
  }
  
  _actualizarPosicion() async {
    Location location = Location();
    LocationData locationData;

    locationData = await location.getLocation();
    _posicionActual = LatLng(locationData.latitude!, locationData.longitude!);
  }

  @override
  void initState() {
    super.initState();
    _permission();
    myEmpresas =_getEmpresas();
  }

  IconButton _leading(BuildContext context, double width) {
    return IconButton(
      //icono de cerrar sesion
      icon: Icon(
        Icons.search,
        color: Theme.of(context).scaffoldBackgroundColor,
        size: 25,
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(Theme.of(context).primaryColor),
        iconColor: MaterialStatePropertyAll(Theme.of(context).scaffoldBackgroundColor),
      ),

      tooltip: "Ver en Mapa",
      onPressed: () async {
        if(_posicionActual.latitude == 0) {
              Metodos().alertsDialogBotonUnico(
                context, 
                'Para poder utilizar el servicio de mapas es necesario habilitar la ubicación de dispositivo.',
                300, 100, 'Aceptar', 0
              );
              _permission();
            } else {
              _actualizarPosicion();
              Navigator.push(context, MaterialPageRoute(builder: (context) => Mapas(
                empresas: totalEmpresas,
                todasEmpresas: totalEmpresas,
                filtroDistancia: filtroComerciosCercanos,
                distancia: distanciaComercios,
                buscador: buscador,
                posicionInicial: _posicionActual,
                filtroAgrupado: filtroComerciosAgrupados,
              )));
            }
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
  
  List<Widget> body() {
    return [
      _cartaPrincipal(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.4),
      ),
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

          FutureBuilder<EmpresasResponse>(
          future: myEmpresas,
          // ignore: missing_return
          builder: (BuildContext context,AsyncSnapshot snapshotEmpresas) {
            switch (snapshotEmpresas.connectionState) {
              case ConnectionState.none:
                return const MyProgressIndicator();
              case ConnectionState.waiting:
                return const MyProgressIndicator();
              case ConnectionState.active:
                return const MyProgressIndicator();
              case ConnectionState.done:
                if (snapshotEmpresas.hasData) {
                  totalEmpresas = snapshotEmpresas.data.empresas!;
                  totalEmpresas.sort((a, b) => a.nombre.trim().compareTo(b.nombre.trim()));
                  return ListView(
                    children: body()
                  );
                }
                return const MyProgressIndicator();
              }
            }
          ),
        ]
      ),

      ));
  }
}