import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';

import '../Vues/VuesAllDiagnosticScrenn/DiagnosticBatteryScreen.dart';
import '../Vues/VuesAllDiagnosticScrenn/DiagnosticEcranScreen.dart';

class EcranController extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
      // Si nous sommes sur un mobile (Android ou iOS), affiche la page de diagnostic de la batterie.
      return DiagnosticEcranScreen();
    } else {
      // Si nous sommes sur un bureau (desktop), affiche un autre message.
      return Center(
        child: Text(
          'Le diagnostic ecran n\'est disponible que sur les appareils mobiles.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
      );
    }
  }
}






