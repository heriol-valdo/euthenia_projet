import 'package:euthenia_project/Controller/AudioController.dart';
import 'package:euthenia_project/Controller/BatteryController.dart';
import 'package:euthenia_project/Controller/ButtonController.dart';
import 'package:euthenia_project/Controller/CameraController.dart';
import 'package:euthenia_project/Controller/CapteurController.dart';
import 'package:euthenia_project/Controller/EcranController.dart';
import 'package:euthenia_project/Style/StyleText.dart';
import 'package:euthenia_project/Vues/HomeScreen.dart';
import 'package:euthenia_project/Vues/InfoDeviceScreen.dart';
import 'package:euthenia_project/Vues/VuesAllDiagnosticScrenn/DiagnosticEcranScreen.dart';
import 'package:flutter/material.dart';

import 'Vues/DiagnosticScreen.dart';
import 'Vues/VuesAllDiagnosticScrenn/DiagnosticBatteryScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  Widget _defaultRoute() {
    return Scaffold(
      appBar: AppBar(title: Center( child: Text('Page 404',style: StyleText.appbarStyle,))),
      body: Center(
        child: Text('Une erreur est survenue.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mon Application',
      initialRoute: '/', // Route initiale de l'application
      routes: {
        '/': (context) => HomeScreem(),
        '/infodevicescreem': (context) => InfoDeviceScreen(),
        '/diagnostic':  (context) => DiagnosticScreen(),
        '/battery':  (context) => BatteryController(),
        '/ecran':  (context) => EcranController(),
        '/camera':  (context) => CameraController(),
        '/boutton':  (context) => ButtonController(),
        '/capteur':  (context) => CapteurController(),
        '/audio':  (context) => AudioController(),


      },
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => _defaultRoute(),
        );
      },
    );
  }
}
