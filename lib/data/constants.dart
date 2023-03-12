import 'package:flutter/material.dart';


class ColorsApp {
  //azul
  static const color1 = '0070C0';
  //morado
  static const color2 = '7E57C2';
  //amarillo
  static const color3 = '26A69A';
  //verde
  static const color4 = 'FFD966';
}


// ignore: must_be_immutable
class FondoScreen extends StatefulWidget {

  final Widget body;
  double? marginBody;
  double? toolbarHeight;
  double? heightAppBar;
  double? radiusAppBar;
  double? topCircles;
  bool? showCircles;
  bool? backButton;
  Widget? leading;
  Size? sizeLogo;
  List<Widget>? actions;
  bool? showAppBar;
  Function()? backButtonPressed;

  FondoScreen({
    super.key, 
    required this.body,
    this.marginBody,
    this.toolbarHeight,
    this.heightAppBar,
    this.radiusAppBar,
    this.topCircles,
    this.showCircles,
    this.leading,
    this.actions,
    this.backButton,
    this.sizeLogo,
    this.showAppBar,
    this.backButtonPressed
  });

  @override
  State<FondoScreen> createState() => _FondoScreenState();
}

class _FondoScreenState extends State<FondoScreen> {
  //atirbutos de clase
  String result = "No data";
  bool qrEncontrado = false;

  @override
  Widget build(BuildContext context) {

    // final dragController = DragController();

    // Personalizacion objPerzonalizacion = Personalizacion();

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.4),
      ),
      child: widget.showAppBar ?? true ? Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.background,
          centerTitle: true,
          // title: objPerzonalizacion.appLogoResize(widget.sizeLogo?.width, widget.sizeLogo?.height),
          toolbarHeight: 100,
          leading: widget.leading ?? (widget.backButton?? false ? BackButton(onPressed: widget.backButtonPressed) : Container()),
          actions: widget.actions
        ),
        body: Stack(
          children: [
            widget.showCircles ?? false ?
            Positioned(
              top: widget.topCircles ?? -100,
              left: 0,
              right: 0,
              child: Container()
              // CirclesBack(
              // ),
            ) : Container(),
            Container(
              height: widget.heightAppBar ?? 0,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(widget.radiusAppBar ?? 0),
                  bottomRight: Radius.circular(widget.radiusAppBar ?? 0),
                )
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: widget.marginBody ?? 0),
              child: widget.body,
            ),
          ],
        ),
      )
      : Stack(
          children: [
            widget.showCircles ?? false ?
            Positioned(
              top: widget.topCircles ?? 0,
              left: 0,
              right: 0,
              child: Container()
              // CirclesBackIL(
              //   kupiApp: widget.myKupiApp,
              // ),
            ) : Container(),
            Container(
              height: widget.heightAppBar ?? 0,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(widget.radiusAppBar ?? 0),
                  bottomRight: Radius.circular(widget.radiusAppBar ?? 0),
                )
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: widget.marginBody ?? 0),
              child: widget.body,
            ),
          ],
        ),
    );
 }

}
