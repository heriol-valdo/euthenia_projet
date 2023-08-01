import 'package:euthenia_project/Vues/VuesAllDiagnosticScrenn/DiagnosticButtonScreen.dart';
import 'package:euthenia_project/Vues/VuesAllDiagnosticScrenn/DiagnosticCapteurScreen.dart';
import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';

import '../Vues/VuesAllDiagnosticScrenn/DiagnosticBatteryScreen.dart';

class CapteurController extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
      // Si nous sommes sur un mobile (Android ou iOS), affiche la page de diagnostic de la batterie.
      return DiagnosticCapteurScreen();
    } else {
      // Si nous sommes sur un bureau (desktop), affiche un autre message.
      return Center(
        child: Text(
          'Le diagnostic du button  n\'est disponible que sur les appareils mobiles.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
      );
    }
  }
}






