import 'package:flutter/material.dart';
class GeneralWidgets{
  

}


//clase que permite estandarizar los colores cuando se espere conection a internet
class MyProgressIndicator extends StatelessWidget{
  
  const MyProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    // Personalizacion objPerzonalizacion = Personalizacion();
    Color colApp1= Theme.of(context).scaffoldBackgroundColor;
    Color colApp2 = Theme.of(context).scaffoldBackgroundColor;
    Color colApp3 = Theme.of(context).cardColor;
    Color colApp4 = Theme.of(context).indicatorColor;

    return Scaffold(
      extendBody: true,
      backgroundColor: colApp1,
      body: Stack(
        children: <Widget>[
          Container(
            height: screenHeight,
            width: screenWidth,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colApp1,
                  colApp2,
                ],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight
              )
            ),
            child: FittedBox(
              fit: BoxFit.none,
              alignment: const Alignment(-1.5, -0.8),
              child: Container(
                width: screenHeight,
                height: screenHeight,
                decoration: BoxDecoration(
                  color: colApp3,
                  borderRadius: BorderRadius.circular(screenHeight / 2),
                ),
              ),
            ),
          ),
          Column(     
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: (screenWidth)/2, left: 25, right: 25 ),
                alignment: AlignmentDirectional.center,
                child: const Image(
                  image: AssetImage("assets/img/logo.png"),
                  width: 300.0,
                  height: 150.0,
                ),
              ),
              Container(
                alignment: AlignmentDirectional.center,
                child: CircularProgressIndicator(
                  backgroundColor: colApp4,
                )
              )
            ]
          )
        ],
      )
    
    );
  }
}