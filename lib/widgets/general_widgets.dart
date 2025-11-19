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

    // Paleta de colores moderna rojo-blanco
    const Color primaryRed = Color(0xFFD32F2F); // Rojo Material profundo
    const Color accentRed = Color(0xFFF44336); // Rojo vibrante
    const Color lightRed = Color(0xFFFFEBEE); // Rojo muy suave
    const Color bgWhite = Color(0xFFFFFFFF); // Blanco puro

    return Scaffold(
      extendBody: true,
      backgroundColor: bgWhite,
      body: Stack(
        children: <Widget>[
          // Fondo con degradado radial moderno
          Container(
            height: screenHeight,
            width: screenWidth,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.5,
                colors: [
                  lightRed,
                  bgWhite,
                  lightRed.withValues(alpha: 0.3),
                ],
                stops: const [0.0, 0.5, 1.0],
              )
            ),
          ),
          // Elementos decorativos con glassmorphism
          Positioned(
            top: -screenHeight * 0.1,
            left: -screenWidth * 0.2,
            child: Container(
              width: screenWidth * 0.6,
              height: screenWidth * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accentRed.withValues(alpha: 0.15),
                    accentRed.withValues(alpha: 0.05),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -screenHeight * 0.15,
            right: -screenWidth * 0.25,
            child: Container(
              width: screenWidth * 0.7,
              height: screenWidth * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primaryRed.withValues(alpha: 0.12),
                    primaryRed.withValues(alpha: 0.03),
                  ],
                ),
              ),
            ),
          ),
          // Contenido principal
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Logo con efecto de elevación
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: bgWhite,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: primaryRed.withValues(alpha: 0.1),
                        blurRadius: 40,
                        offset: const Offset(0, 10),
                        spreadRadius: -5,
                      ),
                    ],
                  ),
                  child: const Image(
                    image: AssetImage("assets/img/logo.png"),
                    width: 240.0,
                    height: 120.0,
                  ),
                ),
                const SizedBox(height: 60),
                // Progress indicator moderno con neumorphism
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Círculo exterior decorativo
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            lightRed.withValues(alpha: 0.3),
                            lightRed.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                    // Progress indicator
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: CircularProgressIndicator(
                        strokeWidth: 4.5,
                        valueColor: AlwaysStoppedAnimation<Color>(primaryRed),
                        backgroundColor: lightRed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Texto moderno
                Text(
                  'Cargando...',
                  style: TextStyle(
                    color: primaryRed.withValues(alpha: 0.8),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          )
        ],
      )

    );
  }
}