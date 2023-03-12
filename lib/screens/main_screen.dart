import 'package:be_energy/screens/bloc/bloc_main.dart';
import 'package:flutter/material.dart';

import '../utils/metodos.dart';

class Beenergy extends StatefulWidget {
  const Beenergy({Key? key}) : super(key: key);

  @override
  State<Beenergy> createState() => _BeenergyState();
}

class _BeenergyState extends State<Beenergy> {

  Metodos metodos = Metodos();
  BlocBeenergy blockBeEnergy = BlocBeenergy();
  
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}