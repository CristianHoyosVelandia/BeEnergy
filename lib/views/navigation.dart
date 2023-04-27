
// ignore_for_file: prefer_const_constructors

import 'package:auto_size_text/auto_size_text.dart';
import 'package:be_energy/routes.dart';
import 'package:be_energy/utils/metodos.dart';
import 'package:flutter/material.dart';
import '../models/callmodels.dart';
import 'package:flutter_svg/flutter_svg.dart';


class NavPages extends StatefulWidget {
  final MyUser myUser;
  const NavPages({Key? key, required this.myUser}) : super(key: key);

  @override
  State<NavPages> createState() => _NavPagesState();
}


class _NavPagesState extends State<NavPages> {

  int currentIndex = 0;

  void onTap(int index){
    setState(() {
      currentIndex = index;
    });
  }

  List pages = [];

  @override
  void initState() {
    super.initState();
    pages = [
      HomeScreen(myUser: widget.myUser,),
      EnergyScreen(),
      TradingScreen(),
      NotificacionesScreen(),
      MicuentaScreen(myUser: widget.myUser,),
    ];
  }

  BottomNavigationBarItem btnNavigation(String titulo, String icono, [double? height, double? width, Color? color]) {
    
    if(height != null && width != null){
      return BottomNavigationBarItem(
        label: titulo,
        icon: SvgPicture.asset(
          icono,
          height: height,
          width: width,
        ),
        backgroundColor: (color != null) ? color : Colors.white.withOpacity(0.5),
      );
    }
    else{
      return BottomNavigationBarItem(
        label: titulo,
        icon: SvgPicture.asset(
          icono,
        ),
        backgroundColor: (color != null) ? color : Colors.white.withOpacity(0.5),
      );
    }
  }

  MaterialButton btnNavBar(int currentIndexTap, BuildContext context, String tituloBtn, IconData icon){
    return MaterialButton(
      minWidth: 20,
      onPressed: () {  
        setState(() {
          currentIndex=currentIndexTap;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: currentIndex == currentIndexTap ? Theme.of(context).canvasColor : Theme.of(context).focusColor,
          ),
          AutoSizeText(
            tituloBtn,
            maxFontSize: 20,
            minFontSize: 12,
            style: TextStyle(
              color: currentIndex == currentIndexTap ? Theme.of(context).canvasColor : Theme.of(context).focusColor,
            ),
          )
        ],
      ),
    );
  }

  Widget btnCenterHome(context){
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: Theme.of(context).scaffoldBackgroundColor,
            width: 2.0
          )
        ),
        child: FloatingActionButton(
          onPressed: (){
            setState(() {
              currentIndex=2;
            });
          },
          backgroundColor: Theme.of(context).canvasColor,
          // child: SvgPicture.asset(
          //   BeenergyIcons.climatechange,
          //   height: 30,
          //   width: 30,
          // ),
          // child: const Image(
          //   alignment: AlignmentDirectional.center,
          //   image:  AssetImage("assets/img/logo.png"),
          //   width: 30,
          //   height: 30,
          // ),
          child: Icon(
            Icons.add_outlined,
            size: 35,
            color: Theme.of(context).scaffoldBackgroundColor,
          )
        ),
      );
  }
  
  final PageStorageBucket bucket = PageStorageBucket();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      
      body: PageStorage(
        child: pages[currentIndex],
        bucket: bucket,
      ),
      
      floatingActionButton: btnCenterHome(context),
      
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: 0),
        
        child: BottomAppBar(
          //Cambiar color aqui
          color: Theme.of(context).scaffoldBackgroundColor,
          shape: const CircularNotchedRectangle(),
          notchMargin: 15,
          elevation: 20.0,
        
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                
                SizedBox(
                  width: 2*Metodos.width(context)/5,
                  child: Row(
          
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                                        
                      Expanded(
                        child: btnNavBar(0, context, 'Principal', Icons.dashboard)
                      ), 
                      
                      Expanded(
                        child: btnNavBar(1, context, 'Energia', Icons.energy_savings_leaf)
                      ),                  
                    
                    ],
                  ),
                ),
                
                Container(
                  width: Metodos.width(context)/5,
                ),
          
                SizedBox(
                  width: 2*Metodos.width(context)/5,
                  
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
          
                      Expanded(
                        child: btnNavBar(3, context, 'Alertas', Icons.notification_add), 
                      ),
                      Expanded(
                        child: btnNavBar(4, context, 'Perfil', Icons.home),
                      )
                    ],
                  ),
                )
                
              
              ]
            ),
          ),
        ),
      ),
      
    );
  }
}

