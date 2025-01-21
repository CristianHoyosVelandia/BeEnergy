import 'dart:async';

import 'package:flutter/material.dart';

import '../../../utils/metodos.dart';

class PauseCardWidget extends StatefulWidget {
  const PauseCardWidget({super.key});

  @override
  State<PauseCardWidget> createState() => _PauseCardWidgetState();
}

class _PauseCardWidgetState extends State<PauseCardWidget> {
  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).focusColor,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  'Pausar Tarjeta',
                  style: Metodos.textofromEditingFondoNegro(context),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Text(
                      '¿Estas seguro de pausar tu tarjeta virtual?',
                      style:  Metodos.textofromEditingFondoNegro(context),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 44),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    
                    onTap: () async {

                      await Metodos.flushbarPositivo(context, 'Correo enviado exitosamente');

                      Timer(const Duration(seconds: 2), () => Navigator.pop(context));

                      
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
                          'Enviar',
                          style: Metodos.btnTextStyleFondo(context, Colors.white)
                        ),
                      ),
                    ),
                  ), 
                  InkWell(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    
                    onTap: () async {

                      await Metodos.flushbarPositivo(context, 'Correo enviado exitosamente');

                      Timer(const Duration(seconds: 2), () => Navigator.pop(context));

                      
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
                          'Enviar',
                          style: Metodos.btnTextStyleFondo(context, Colors.white)
                        ),
                      ),
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
}
