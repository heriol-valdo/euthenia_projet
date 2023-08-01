import 'package:euthenia_project/Controller/InfoDeviceConroller.dart';
import 'package:euthenia_project/Style/StyleText.dart';
import 'package:flutter/material.dart';

class DiagnosticScreen extends StatefulWidget {
  @override
  _DiagnosticScreenState createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends State<DiagnosticScreen> {
  final List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
  ];

  final List<String> WidgetNames = [

    'Connectivité',
    'Connectiques Test',
    'Audio',
    'Capteurs',
    'Boutons',
    'Camera',
    'Ecran',
    'Batterie/chargeur',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('DiagnosticScrenn', style: StyleText.appbarStyle),
        ),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: colors.length,
        itemBuilder: (context, index) {
          Color color = colors[index];
          String widgetName = WidgetNames[index];
          return InkWell(
            onTap: () => _navigateToScreen(index),
            child: Container(
              color: color,
              child: Center(
                child: Text(
                  widgetName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _navigateToScreen(int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/audio_route'); // Remplacez '/audio_route' par la route souhaitée pour la fonctionnalité Audio.
        break;
      case 2:
        Navigator.pushNamed(context, '/audio'); // Remplacez '/audio_route' par la route souhaitée pour la fonctionnalité Audio.
        break;
      case 3:
        Navigator.pushNamed(context, '/capteur'); // Remplacez '/camera_route' par la route souhaitée pour la fonctionnalité Camera.
        break;
      case 4:
        Navigator.pushNamed(context, '/boutton'); // Remplacez '/camera_route' par la route souhaitée pour la fonctionnalité Camera.
        break;
      case 5:
        Navigator.pushNamed(context, '/camera'); // Remplacez '/ecran_route' par la route souhaitée pour la fonctionnalité Ecran.
        break;

      case 6:
        Navigator.pushNamed(context, '/ecran'); // Remplacez '/ecran_route' par la route souhaitée pour la fonctionnalité Ecran.
        break;
      case 7:
        Navigator.pushNamed(context, '/battery'); // Remplacez '/ecran_route' par la route souhaitée pour la fonctionnalité Ecran.
        break;
    // Ajoutez des cas pour d'autres fonctionnalités en fonction des index de couleurs.
      default:
        Navigator.pushNamed(context, '/default_route'); // Remplacez '/default_route' par la route par défaut ou une route d'erreur.
        break;
    }
  }
}
