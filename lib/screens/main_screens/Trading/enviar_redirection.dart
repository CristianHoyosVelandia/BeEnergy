import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../routes.dart';
import '../../../utils/metodos.dart';


class OnboardingWidget extends StatefulWidget {
  const OnboardingWidget({Key? key}) : super(key: key);

  @override
  State<OnboardingWidget> createState() => _OnboardingWidgetState();
}

class _OnboardingWidgetState extends State<OnboardingWidget> {

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  
  Widget _info(){
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 15, 20, 12),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
            child: Center(
              child: Text(
                "Intercambio Creado",
                style: TextStyle(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  fontSize: 25.0,
                  fontFamily:"SEGOEUI",
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.10,
                )
              ),
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _btn() {
   return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      
      onTap: () async {
        Navigator.push(context,MaterialPageRoute(builder: (context) => const IntercambiosEnergyScreen()));
      },

      child: Container(
        margin: const EdgeInsets.only(right: 65, left: 65, top: 15),
        height: 50,
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.circular(25),
        ),
        
        child: Center(
          child: Text(
            'Ir a intercambios',
            style: Metodos.btnTextStyleFondo(context, Colors.white)
          ),
        ),
      ),
    );     
  
  }
     
  Widget _infoS(){
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 15, 20, 12),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
            child: Center(
              child: Text(                
                "Gracias por contribuir a salvar el mundo, recuerda que juntos, hacemos más.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w200,
                  height: 1.5,
                  letterSpacing: 1.10,
                )
              ),
            ),
          ),
        ],
      ),
    );
  }
  

  Widget tittle(){
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5), 
      child: SizedBox(
        height: 60,
        width: Metodos.width(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Image(
              alignment: AlignmentDirectional.center,
              image:  AssetImage("assets/img/logo.png"),
              width: 50,
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0),
              child: Text(
                "Be Energy",
                style: TextStyle(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                ),
              ),
            )
          ],
        )
      )
    );
  }

  Widget imgSucess(){
    return Container(
      margin: const EdgeInsets.only(top: 120.0, bottom: 15.0),
      width: 250,
      height: 250,
      alignment: Alignment.center,
      child: SvgPicture.asset(Beenergysvg.success)
    );

  }
  List<Widget> body(){
    return [
      tittle(),
      imgSucess(),
      _info(),
      _infoS(),
      _btn()
    ];
  }
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.4),
      ),
      child: Scaffold(
      backgroundColor: Theme.of(context).focusColor,
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          ListView(
            children: body()
          ),
        ]
      ),
      
      // floatingActionButton: _btnFlotante(),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat
      ));

  }
}
