
import 'package:flutter/material.dart';
import '../data/constants.dart';


class MyThemes {
  //ThemeData
  static ThemeData? maintheme = ThemeData(
    fontFamily: 'Garet',
    fontFamilyFallback: const ['Garet'],
    scaffoldBackgroundColor: Colors.white,
    colorScheme   :   const ColorScheme.light(),
    primaryColor  :   Color(int.parse("0xff${ColorsApp.color1}")),
    cardColor     :   Color(int.parse("0xff${ColorsApp.color2}")),
    canvasColor   :   Color(int.parse("0xff${ColorsApp.color3}")),
    focusColor    :  const Color(0xff212D3D),
    tabBarTheme: TabBarThemeData(
      indicatorColor: Color(int.parse("0xff${ColorsApp.color4}")),
    ),
    // focusColor: Colors.grey.shade900,
    // iconTheme: IconThemeData(color: , opacity: )
  );
}