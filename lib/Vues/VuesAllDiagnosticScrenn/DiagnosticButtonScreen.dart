import 'dart:async';

import 'package:euthenia_project/Style/StyleText.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DiagnosticButtonScreen extends StatefulWidget {
  _DiagnosticButtonScreenState createState() => _DiagnosticButtonScreenState();
}

class _DiagnosticButtonScreenState extends State<DiagnosticButtonScreen> {
  final EventChannel _volumeChannel = EventChannel('volume_events');
  late StreamSubscription _volumeSubscription;
  bool _isVolumeChangedAddVoulume = false;
  bool _isVolumeChangedDeleteVoulume = false;
  bool _isVolumeChangedMuetVoulume = false;// Flag to track volume change

  @override
  void initState() {
    super.initState();
    _volumeSubscription = _volumeChannel.receiveBroadcastStream().listen(_onVolumeChange);
  }

  void checkAndGoBack() {
    if (_isVolumeChangedAddVoulume && _isVolumeChangedDeleteVoulume && _isVolumeChangedMuetVoulume) {
      // Tous les éléments sont true, revenir à la page précédente
      Navigator.pop(context);
    } else {
      // Afficher un message d'avertissement si nécessaire
      // Ici, nous utilisons un SnackBar pour afficher le message
      showCustomSnackbar(context, "Veuillez effectuer toutes les actions requises.");
    }
  }


  void showCustomSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(seconds: 1), // Duration to display the Snackbar
      action: SnackBarAction(
        label: 'OK',
        onPressed: () {
          // Action to perform when the user clicks on the action button
          // You can add operations here if necessary
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _onVolumeChange(dynamic event) {
    if (event == "increase") {
      print("Le volume a augmenté !");
     // showCustomSnackbar(context, "Le volume a augmenté !");
      setState(() {
        _isVolumeChangedAddVoulume = true;
      });
    } else if (event == "decrease") {
      print("Le volume a diminué !");
      //showCustomSnackbar(context, "Le volume a diminué !");
      setState(() {
        _isVolumeChangedDeleteVoulume = true;
      });
    } else if (event == "vibrate") {
      print("Le téléphone est en mode vibreur  !");
      //showCustomSnackbar(context, "Le téléphone est en mode vibreur !");
      setState(() {
        _isVolumeChangedMuetVoulume = true;
      });
    } else if (event == "centralButton") {
      print("Le bouton central a été activé  !");
      //showCustomSnackbar(context, "Le bouton central a été activé !");
    }

    // Vérifier si tous les éléments sont true et revenir à la page précédente si nécessaire
    checkAndGoBack();
  }

  @override
  void dispose() {
    _volumeSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("DiagnosticButtonScreen",style: StyleText.appbarStyle,)),
      body: Center(
       child: Column(
         children: [
           Container(
             margin: EdgeInsets.all(20),
             child: Center ( child:Text("Effectuez les taches suivantes Augmenter/Diminuer le volume et mettre le telephone en mode vibreur")),
           ),
            Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               VolumeRow(
                 icon:  Icons.volume_up,
                 text: "Volume augmenté",
                 isVolumeChanged: _isVolumeChangedAddVoulume,
               ),
               VolumeRow(
                 icon:  Icons.volume_down,
                 text: "Volume diminué",
                 isVolumeChanged: _isVolumeChangedDeleteVoulume,
               ),
               VolumeRow(
                 icon: Icons.volume_off,
                 text: "Mode vibreur activé",
                 isVolumeChanged: _isVolumeChangedMuetVoulume,
               ),
             ],
           ),
         ],
       ),
      ),
    );
  }
}

class VolumeRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isVolumeChanged;

  VolumeRow({required this.icon, required this.text, required this.isVolumeChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        isVolumeChanged
            ? Icon(Icons.add_circle, color: Colors.green) // Show green arrow if volume changed
            : CircularProgressIndicator(), // Show circular progress indicator otherwise
        SizedBox(width: 16, height: 40),
        Icon(icon, size: 60),
        SizedBox(width: 16, height: 40),
        Text(
          text,
          style: StyleText.IconStyle,
        ),
      ],
    );
  }
}
