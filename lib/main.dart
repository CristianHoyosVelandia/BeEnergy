import 'package:flutter/material.dart';

import 'routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Be Energy',
      // home: HomeScreen(),
      initialRoute: 'home',
      routes: {
        'home':(context) => const HomeScreen(),
        'login':(context) => const LoginScreen(),

      },
    );
  }
}