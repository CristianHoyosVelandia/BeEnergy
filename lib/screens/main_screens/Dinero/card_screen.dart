import 'package:be_energy/screens/main_screens/Dinero/pausecard_screen.dart';
import 'package:flutter/material.dart';

import '../../../utils/metodos.dart';

class Cardscreen extends StatefulWidget {
  const Cardscreen({super.key});

  @override
  State<Cardscreen> createState() => _CardscreenState();
}

class _CardscreenState extends State<Cardscreen> {
  
  PreferredSizeWidget _appbarEditarPerfil() {
    return AppBar(
      backgroundColor: Theme.of(context).focusColor,
      automaticallyImplyLeading: false,
      leading: InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () async {
          Navigator.pop(context);
        },
        child: Icon(
          Icons.chevron_left_rounded,
          color: Theme.of(context).scaffoldBackgroundColor,
          size: 32,
        ),
      ),
      title: Text(
        "Mi Tarjeta Virtual",
        style: Metodos.btnTextStyle(context),
      ),
      centerTitle: false,
      elevation: 0,
    );
  }
  
  
  Widget _card() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
      // height: 250,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 16),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                blurRadius: 6,
                color: Color(0x4B1A1F24),
                offset: Offset(0, 2),
              )
              
            ],
            gradient: Metodos.gradientClasic(context),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).focusColor,
              width: 0.25
            )
          ),
          child: _subtitleText()
        )
      ),
    );  
  
  
  }
    
  Widget _subtitleText(){
    // Generated code for this Column Widget...
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          margin: const EdgeInsets.only( top: 25.0, bottom: 15.0),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  "Disponible",
                  style: TextStyle(
                    fontFamily: 'Roboto Mono',
                    color: Theme.of(context).scaffoldBackgroundColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 15.0),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 4, 20, 0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  "\$ 333.333",
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    color: Theme.of(context).scaffoldBackgroundColor,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.5
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 15, 20, 12),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "* **** 0149 *",
                style: TextStyle(
                  fontFamily: 'Roboto Mono',
                  fontSize: 18.0,
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
              Text(
                "05/25 ",
                style: TextStyle(
                  fontFamily: 'Roboto Mono',
                  fontSize: 18.0,
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
              ),           
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 4, 20, 12),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "CRISTIAN HOYOS",
                style: TextStyle(
                  fontFamily: 'Roboto Mono',
                  fontSize: 18.0,
                  color: Theme.of(context).scaffoldBackgroundColor,
                  letterSpacing: 1.5
                ),
              )           
            ],
          ),
        ),
      
      ],
    );

  }

  Widget incomings() {
    return  Padding(
    padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
    child: Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.44,
          decoration: BoxDecoration(
            color: Theme.of(context).focusColor,
            border: Border.all(
              color: Theme.of(context).scaffoldBackgroundColor,
              width: 0.25
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                 "Ingreso",
                  textAlign: TextAlign.start,
                  style: Metodos.subtitulosInformativosFondoNegro(context),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 12),
                  child: Text(
                    "+\$12,402",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Theme.of(context).canvasColor,
                      fontSize: 25.0,
                      fontFamily:"SEGOEUI",
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.10,
                    )
                  ),
                ),
                Container(
                  width: 80,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0x4D39D2C0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        " 4.5% ",
                        textAlign: TextAlign.start,
                        style: Metodos.subtitulosInformativosFondoNegro(context),
                      ),
                      Icon(
                        Icons.trending_up_rounded,
                        color: Theme.of(context).canvasColor,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.44,
          decoration: BoxDecoration(
            color: Theme.of(context).focusColor,
            border: Border.all(
              color: Theme.of(context).scaffoldBackgroundColor,
              width: 0.25
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gastos',
                  textAlign: TextAlign.start,
                  style: Metodos.subtitulosInformativosFondoNegro(context),
                ),
                const Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 8, 0, 12),
                  child: Text(
                    '-\$8,392',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 25.0,
                      fontFamily:"SEGOEUI",
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.10,
                    )
                  ),
                ),
                Container(
                  width: 80,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0x9AF06A6A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '4.5%',
                        textAlign: TextAlign.start,
                        style: Metodos.subtitulosInformativosFondoNegro(context)
                      ),
                      const Icon(
                        Icons.trending_up_rounded,
                        color: Colors.red,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    ),
  );

  }
  
  Widget columns() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                'Servicio rapido',
                style: Metodos.btnTextStyle(context),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.44,
                height: 100,
                decoration: BoxDecoration(
                  color: Theme.of(context).focusColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Metodos.borderClasicFondoNegro(context)
                ),
                child: InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    // await Navigator.push(
                    //   context,
                    // );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.swap_horiz_rounded,
                        color: Theme.of(context).canvasColor,
                        size: 40,
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                        child: Text(
                          'Transferir',
                          style: Metodos.btnTextStyle(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.44,
                height: 100,
                decoration: BoxDecoration(
                  color: Theme.of(context).focusColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Metodos.borderClasicFondoNegro(context)
                ),
                child: InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    await showModalBottomSheet(
                      isScrollControlled: true,
                      backgroundColor: const Color(0x00000000),
                      barrierColor: const Color(0x00000000),
                      context: context,
                      builder: (bottomSheetContext) {
                        return Padding(
                          padding: MediaQuery.of(bottomSheetContext).viewInsets,
                          child: const SizedBox(
                            height: 220,
                            child: PauseCardWidget(),
                          ),
                        );
                      },
                    ).then((value) => setState(() {}));
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.pause_rounded,
                        color: Theme.of(context).canvasColor,
                        size: 40,
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                        child: Text(
                          'Pausar Tarjeta',
                          style: Metodos.btnTextStyleFondo(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 12),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                'Transaction',
                style: Metodos.btnTextStyleFondo(context),
              ),
            ],
          ),
        ),
      ],
    );

  }
  List<Widget> _body() {
    return [
      _card(),
      incomings(),
      columns()
    ];
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbarEditarPerfil(),
      backgroundColor: Theme.of(context).focusColor,
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          ListView(
            children: _body()
          ),
        ]
      ),
    );
  }
  
}