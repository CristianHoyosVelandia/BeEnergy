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
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';

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

    final bool isIncome = data['entrada'] == true;
    final Color borderColor = isIncome ? context.colors.primary : Colors.red;

    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        context.push(ConfirmchangeScreen(dataScreen: dataIntercmabio));
      },
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          border: Border.all(
            color: borderColor,
            width: 1.5,
          ),
          borderRadius: AppTokens.borderRadiusMedium,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(AppTokens.space8),
                      child: SvgPicture.asset(_iconCard(data['fuenteIcon'])),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Icon(
                          isIncome ? Icons.trending_up_outlined : Icons.trending_down_outlined,
                          size: 30,
                          color: borderColor,
                        ),
                        SizedBox(height: AppTokens.space8),
                        AutoSizeText(
                          data['horarioSuminsitro'],
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: context.textStyles.bodySmall?.copyWith(
                            fontWeight: AppTokens.fontWeightMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        data['nombre'].toString().split(' ').first,
                        textAlign: TextAlign.center,
                        style: context.textStyles.titleMedium?.copyWith(
                          fontWeight: AppTokens.fontWeightBold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AutoSizeText(
                          data['dinero'],
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: context.textStyles.bodyMedium?.copyWith(
                            fontWeight: AppTokens.fontWeightBold,
                            letterSpacing: 1.1,
                          ),
                        ),
                        SizedBox(height: AppTokens.space8),
                        AutoSizeText(
                          data['energia'],
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: context.textStyles.bodyMedium?.copyWith(
                            fontWeight: AppTokens.fontWeightBold,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  

  Widget _gridViewCards(var dataInter) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: AppTokens.space12),
        margin: EdgeInsets.only(top: AppTokens.space20),
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            childAspectRatio: 5 / 4,
            crossAxisSpacing: AppTokens.space12,
            mainAxisSpacing: AppTokens.space12,
            mainAxisExtent: 150,
            maxCrossAxisExtent: context.width * 0.75,
          ),
          itemCount: dataInter.length,
          itemBuilder: (context, index) {
            return _card(dataInter[index]);
          },
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
      icon: Icon(
        Icons.map,
        color: context.colors.surface,
        size: 25,
      ),
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(context.colors.primary),
        iconColor: WidgetStatePropertyAll(context.colors.surface),
      ),
      tooltip: "Ver en Mapa",
      onPressed: () async {
        if (_posicionActual.latitude == 0) {
          Metodos().alertsDialogBotonUnico(
            context,
            'Para poder utilizar el servicio de mapas es necesario habilitar la ubicación de dispositivo.',
            300, 100, 'Aceptar', 0
          );
          _permission();
        } else {
          _actualizarPosicion();
          context.push(Mapas(
            empresas: totalEmpresas,
            todasEmpresas: totalEmpresas,
            filtroDistancia: filtroComerciosCercanos,
            distancia: distanciaComercios,
            buscador: buscador,
            posicionInicial: _posicionActual,
            filtroAgrupado: filtroComerciosAgrupados,
          ));
        }
      },
    );
  }
  
  Widget _contenPrincipalCard(){
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: EdgeInsets.only(top: AppTokens.space48),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Card(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                color: context.colors.surface,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Padding(
                  padding: EdgeInsets.all(AppTokens.space4),
                  child: Container(
                    width: 60,
                    height: 60,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      "assets/img/avatar.jpg",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: AppTokens.space16),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0x40000000),
                    borderRadius: AppTokens.borderRadiusSmall,
                  ),
                  child: _leading(context, context.width),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: AppTokens.space8),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                "Cristian Hoyos V",
                style: context.textStyles.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: AppTokens.fontWeightSemiBold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: AppTokens.space8),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                'Ing. mecatrónico - ',
                style: context.textStyles.bodyMedium?.copyWith(
                  color: const Color(0xB3FFFFFF),
                  fontWeight: AppTokens.fontWeightMedium,
                ),
              ),
              Text(
                "cristiannhoyoss@gmail.com",
                style: context.textStyles.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: AppTokens.fontWeightMedium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
    
  Widget _cartaPrincipal(){
    return Container(
      width: context.width,
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
        padding: EdgeInsets.only(left: AppTokens.space20),
        child: _contenPrincipalCard(),
      ),
    );
  }
  
  Widget _ofertasSelected(){
    return Padding(
      padding: EdgeInsets.all(AppTokens.space12),
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
              borderRadius: AppTokens.borderRadiusMedium,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTokens.space16,
                  vertical: AppTokens.space12,
                ),
                margin: EdgeInsets.all(AppTokens.space8),
                decoration: BoxDecoration(
                  color: ofertas ? context.colors.primary : Colors.grey,
                  borderRadius: AppTokens.borderRadiusMedium,
                  border: Metodos.borderClasic(context),
                ),
                child: Center(
                  child: Text(
                    "Ofertas Energia",
                    style: context.textStyles.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: AppTokens.fontWeightSemiBold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: () async {
                setState(() {
                  ofertas = false;
                });
              },
              borderRadius: AppTokens.borderRadiusMedium,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTokens.space16,
                  vertical: AppTokens.space12,
                ),
                margin: EdgeInsets.all(AppTokens.space8),
                decoration: BoxDecoration(
                  color: !ofertas ? context.colors.primary : Colors.grey,
                  borderRadius: AppTokens.borderRadiusMedium,
                  border: Metodos.borderClasic(context),
                ),
                child: Center(
                  child: Text(
                    "Ofertas Dinero",
                    style: context.textStyles.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: AppTokens.fontWeightSemiBold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
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