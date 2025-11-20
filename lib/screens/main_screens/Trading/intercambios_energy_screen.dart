import 'package:auto_size_text/auto_size_text.dart';
import 'package:be_energy/models/callmodels.dart';
import 'package:be_energy/utils/metodos.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../routes.dart';

class IntercambiosEnergyScreen extends StatefulWidget {
  const IntercambiosEnergyScreen({super.key});

  @override
  State<IntercambiosEnergyScreen> createState() => _IntercambiosEnergyScreenState();
}

 
class _IntercambiosEnergyScreenState extends State<IntercambiosEnergyScreen> {
    
  Metodos metodos = Metodos();
  bool valBuscar= false;

  final dataIntercambios = [
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

  Widget _image() {
    return Padding(
      padding: EdgeInsets.only(
        top: AppTokens.space16,
        bottom: AppTokens.space8,
      ),
      child: Image(
        alignment: AlignmentDirectional.center,
        image: const AssetImage("assets/img/5.png"),
        width: context.width * 0.75,
        height: 150,
      ),
    );
  }

  Widget _contenPrincipalCard(){
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: EdgeInsets.only(top: AppTokens.space12),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: AppTokens.space16),
                    child: _leadingBack(context, context.width),
                  ),
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
                ],
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
      ],
    );
  }

  IconButton _leading(BuildContext context, double width) {
    return IconButton(
      icon: Icon(
        Icons.search,
        color: context.colors.surface,
        size: 25,
      ),
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(context.colors.primary),
        iconColor: WidgetStatePropertyAll(context.colors.surface),
      ),
      tooltip: "Buscar",
      onPressed: () async {
        setState(() {
          valBuscar = !valBuscar;
        });
      },
    );
  }
    
  IconButton _leadingBack(BuildContext context, double width) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios_new,
        color: context.colors.surface,
        size: 25,
      ),
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(context.colors.primary),
        iconColor: WidgetStatePropertyAll(context.colors.surface),
      ),
      tooltip: "Volver",
      onPressed: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Beenergy()),
          (Route<dynamic> route) => false,
        );
      },
    );
  }
    
  Widget _cartaPrincipal(){
    return Container(
      width: context.width,
      height: 90,
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
      child: _contenPrincipalCard(),
    );
  }
  
  Widget _info(){
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppTokens.space20,
        vertical: AppTokens.space12,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
            child: Text(
              "Sus intercambios de energía son:",
              style: context.textStyles.titleLarge?.copyWith(
                fontWeight: AppTokens.fontWeightSemiBold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _btnCrear() {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Beenergy()),
          (Route<dynamic> route) => false,
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 65,
          vertical: AppTokens.space16,
        ),
        height: 50,
        decoration: BoxDecoration(
          color: context.colors.primary,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: Text(
            'Finalizar',
            style: context.textStyles.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: AppTokens.fontWeightBold,
            ),
          ),
        ),
      ),
    );
  }
  
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
        context.push(ErecordScreen(dataScreen: dataIntercmabio));
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
                          data['estado'],
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
  Widget _gridViewCards() {
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
          itemCount: dataIntercambios.length,
          itemBuilder: (context, index) {
            return _card(dataIntercambios[index]);
          },
        ),
      ),
    );
  }
  Widget body() {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        ListView(
          children: <Widget>[
            _cartaPrincipal(),
            ( valBuscar==true ) ? _image() : Container(),
            _info(),
            _gridViewCards(),
            _btnCrear()
          ]
        )
      ]
    );

  }
  
  @override
  Widget build(BuildContext context) {
        
    return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1)),
      child: Scaffold(
        body: body(),
      )
    );
  }
}
