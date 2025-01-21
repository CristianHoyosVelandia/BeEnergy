import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import '../../../bloc/user_bloc.dart';
import '../../../models/callmodels.dart';
import '../../../routes.dart';
import '../../../utils/metodos.dart';
import '../../../widgets/general_widgets.dart';

class BolsaScreen extends StatefulWidget {
  const BolsaScreen({super.key});

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
  bool ofertas = true;

  
  final dataIntercambiosEnergia = [
    {
      'numTransaccion': 1,
      'entrada': true,
      'nombre': 'Estiven Hoyos',
      'dinero':  '\$ 150.00',
      'energia':  '250 kW',
      'fecha':  '02-Mayo',
      'fuente':  'Solar-Eólica',
      'fuenteIcon': 5,
      'horarioSuminsitro':"Diurno Bloque 2 CLPE No 03-2021",
      'estado': 'En curso'
    },
    {
      'numTransaccion': 3,
      'entrada': false,
      'nombre': 'Clara Velandia',
      'dinero':  '\$ 450.00',
      'energia':  '7 kW',
      'fecha':  '28-Febrero',
      'fuente':  'Solar',
      'fuenteIcon': 1,
      'horarioSuminsitro':"Diurno Bloque 2 CLPE No 03-2021",

      'estado': 'Finalizada'

    },
    
    {
      'numTransaccion': 1,
      'entrada': true,
      'nombre': 'Daniel Hoyos',
      'dinero':  '\$ 650.00',
      'energia':  '300 kW',
      'fecha':  '25-Febrero',
      'fuente':  'Solar',
      'fuenteIcon': 1,
      'horarioSuminsitro':"Diurno Bloque 2 CLPE No 03-2021",
      'estado': 'Finalizada'
    },
    {
      'numTransaccion': 2,
      'entrada': true,
      'nombre': 'Camilo Hoyos',
      'dinero':  '\$ 240.00',
      'energia':  '15 kW',
      'fecha':  '27-Febrero',
      'fuente':  'Solar',
      'fuenteIcon': 1,
      'horarioSuminsitro':"Diurno Bloque 2 CLPE No 03-2021",
      'estado': 'Finalizada'
    },
    
    {
      'numTransaccion': 3,
      'entrada': false,
      'nombre': 'Maria Velandia',
      'dinero':  '\$ 150.00',
      'energia':  '8 kW',
      'fecha':  '28-Febrero',
      'fuente':  'Solar',
      'fuenteIcon': 1,
      'horarioSuminsitro':"Diurno Bloque 2 CLPE No 03-2021",

      'estado': 'Finalizada'

    },
    {
      'numTransaccion': 3,
      'entrada': false,
      'nombre': 'Mercedes Velandia',
      'dinero':  '\$ 150.00',
      'energia':  '8 kW',
      'fecha':  '28-Febrero',
      'fuente':  'Solar',
      'fuenteIcon': 1,
      'horarioSuminsitro':"Diurno Bloque 2 CLPE No 03-2021",

      'estado': 'Finalizada'

    }
  ];

  
  final dataIntercambiosDinero = [
    {
      'numTransaccion': 1,
      'entrada': true,
      'nombre': 'Estiven Hoyos',
      'dinero':  '\$ 250.00',
      'energia':  '25 kW',
      'fecha':  '02-Mayo',
      'fuente':  'Solar-Eólica',
      'fuenteIcon': 5,
      'horarioSuminsitro':"Diurno Bloque 2 CLPE No 03-2021",
      'estado': 'En curso'
    },
    {
      'numTransaccion': 1,
      'entrada': true,
      'nombre': 'Estiven Hoyos',
      'dinero':  '\$ 500.00',
      'energia':  '25 kW',
      'fecha':  '25-Febrero',
      'fuente':  'Solar',
      'fuenteIcon': 1,
      'horarioSuminsitro':"Diurno Bloque 2 CLPE No 03-2021",
      'estado': 'Finalizada'
    },
    {
      'numTransaccion': 2,
      'entrada': true,
      'nombre': 'Angel Hoyos',
      'dinero':  '\$ 240.00',
      'energia':  '5 kW',
      'fecha':  '27-Febrero',
      'fuente':  'Solar',
      'fuenteIcon': 1,
      'horarioSuminsitro':"Diurno Bloque 2 CLPE No 03-2021",
      'estado': 'Finalizada'
    },
    {
      'numTransaccion': 3,
      'entrada': false,
      'nombre': 'Clara Velandia',
      'dinero':  '\$ 150.00',
      'energia':  '8 kW',
      'fecha':  '28-Febrero',
      'fuente':  'Solar',
      'fuenteIcon': 1,
      'horarioSuminsitro':"Diurno Bloque 2 CLPE No 03-2021",

      'estado': 'Finalizada'

    }
  ];

  String _iconCard(int numero) {
    var au = 'assets/icons/CleanWater.svg';
    
    switch (numero) {
      case 1:
        au = BeenergyIcons.solarPanel;
      break;
      case 5:
        au = BeenergyIcons.ecoHouse;
      break;
      default:
      au = au;
    }

    return au;
  }
  

  Widget _card(var data){
    Intercambio dataIntercmabio = Intercambio(
      numTransaccion: data['numTransaccion'], 
      entrada: data['entrada'], 
      nombre: data['nombre'], 
      dinero: data['dinero'], 
      energia: data['energia'], 
      fecha: data['fecha'], 
      fuente: data['fuente'], 
      fuenteIcon: data['fuenteIcon'], 
      horarioSuminsitro: data['horarioSuminsitro'], 
      estado: data['estado']
    );
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        Navigator.push(context,MaterialPageRoute(builder: (context) => ConfirmchangeScreen(dataScreen: dataIntercmabio,)));
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: (data['entrada'] == true )?Theme.of(context).canvasColor: Colors.red,
            width: 1
          ),
          borderRadius: BorderRadius.circular(15.0)
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: SvgPicture.asset(_iconCard(data['fuenteIcon'])),
                  )
                ),
                Expanded(
                  child: Column(
                  children: [
        
                  Icon(
                    (data['entrada'] == false )? Icons.trending_down_outlined: Icons.trending_up_outlined,
                    size: 30,
                    color: (data['entrada'] == false )? Colors.red: Theme.of(context).canvasColor,
                  ),
    
                  const SizedBox(height: 5.0),
    
                  AutoSizeText(
                    data['horarioSuminsitro'],
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: Metodos.subtitulosInformativosFondoNegro(context)
                  ),
              ],
            ),
        
                ),
              ],
              )
            ),
            
            Expanded(
              child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      data['nombre'].toString().split(' ').first,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).scaffoldBackgroundColor
                      ),
                    ),
                  )
                ),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      
                      AutoSizeText(
                        data['dinero'],
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          fontSize: 12.0,
                          fontFamily:"SEGOEUI",
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.10,
                        )
                      ),
                                    
                      const SizedBox(height: 5.0),
    
                      AutoSizeText(
                        data['energia'],
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          fontSize: 12.0,
                          fontFamily:"SEGOEUI",
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.10,
                        )
                      ),
                    
    
                    ],
                  ),
    
                ),
              ],
              )
            ),
            
          ],
        ),
      ),
    );
  }
  

  Widget _gridViewCards(var dataInter) {
    return  Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        margin: const EdgeInsets.only(top: 20),
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            childAspectRatio: 5/4,
            crossAxisSpacing: 10, // espaciado horizontal
            mainAxisSpacing: 10, // espaciado vertical
            mainAxisExtent: 150,
            maxCrossAxisExtent: 3*Metodos.width(context) / 4,
          ),
          itemCount: dataInter.length,
          itemBuilder: (context, index){
            return _card(dataInter[index]);
          }
        ),
      ),
    );
  }
  
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
        Icons.map,
        color: Theme.of(context).scaffoldBackgroundColor,
        size: 25,
      ),
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(Theme.of(context).primaryColor),
        iconColor: WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor),
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
  
  Widget _ofertasSelected(){
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: () async {
                setState(() {
                  ofertas = true;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric( horizontal: 15, vertical: 10),
                margin: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: (ofertas==true)?Theme.of(context).canvasColor:Colors.grey,
                  borderRadius: BorderRadius.circular(15.0),
                  border: Metodos.borderClasic(context)
                  // border: Border.all(
                  //   width: 0.25,
                  //   color: Theme.of(context).focusColor
                  // )
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
                      child: Text(
                        "Ofertas Energia",
                        style: Metodos.subtitulosInformativosFondoNegro(context),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ),

          Expanded(
            flex: 1,
            child: InkWell(
              onTap: () async {
                setState(() {
                  ofertas = false;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric( horizontal: 15, vertical: 10),
                margin: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: (ofertas==false)?Theme.of(context).canvasColor:Colors.grey,
                  borderRadius: BorderRadius.circular(15.0),
                  border: Metodos.borderClasic(context)
                  // border: Border.all(
                  //   width: 0.25,
                  //   color: Theme.of(context).focusColor
                  // )
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
                      child: Text(
                        "Ofertas Dinero",
                        style: Metodos.subtitulosInformativosFondoNegro(context),
                      ),
                    ),
                  ],
                ),
              ),
            )
          )
        
        ],
      ),
    );
  }
  List<Widget> body() {
    return [
      _cartaPrincipal(),
      _ofertasSelected(),
      (ofertas==true)?_gridViewCards(dataIntercambiosDinero):_gridViewCards(dataIntercambiosEnergia),

    ];
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1)),
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