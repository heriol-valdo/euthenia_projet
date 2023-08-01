import 'dart:async';
import 'package:euthenia_project/Style/StyleText.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:vibration/vibration.dart';

class DiagnosticCapteurScreen extends StatefulWidget {
  _DiagnosticCapteurScreenState createState() => _DiagnosticCapteurScreenState();
}

class _DiagnosticCapteurScreenState extends State<DiagnosticCapteurScreen> {
  static final LocalAuthentication _localAuthentication = LocalAuthentication();
  bool _isBiometricSupported = false;
  bool _isFingerprintSupported = false;
  bool _isFaceIdSupported = false;

  bool _isVibration = false;
  bool _isLogger = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricSupport();
  }

  Future<void> _checkBiometricSupport() async {
    try {
      _isBiometricSupported = await _checkBiometricJavaSupport();
      _isFingerprintSupported = await _checkTouchIdSupport();
      _isFaceIdSupported = await _checkFaceIdSupport(); // Utilise la fonction pour vérifier Face ID
    } catch (e) {
      print('Erreur lors de la vérification de la prise en charge biométrique : $e');
    }

    if (!mounted) return;

    setState(() {});
  }

  static Future<bool> _checkFaceIdSupport() async {
    try {
      const platform = const MethodChannel('com.example.euthenia_project/biometric');
      bool isFaceIdSupported = await platform.invokeMethod('isFaceIdSupported');
      return isFaceIdSupported;
    } catch (e) {
      print('Erreur lors de la vérification de la prise en charge de Face ID : $e');
      return false;
    }
  }

  static Future<bool> _checkTouchIdSupport() async {
    try {
      const platform = const MethodChannel('com.example.euthenia_project/biometric');
      bool isFaceIdSupported = await platform.invokeMethod('isTouchIdSupported');
      return isFaceIdSupported;
    } catch (e) {
      print('Erreur lors de la vérification de la prise en charge du Touch ID : $e');
      return false;
    }
   }

  static Future<bool> _checkBiometricJavaSupport() async {
    try {
      const platform = const MethodChannel('com.example.euthenia_project/biometric');
      bool isFaceIdSupported = await platform.invokeMethod('isBiometricSupported');
      return isFaceIdSupported;
    } catch (e) {
      print('Erreur lors de la vérification de la prise en charge de la biometrie : $e');
      return false;
    }
  }

  static void showCustomSnackbar(BuildContext context, String message) {
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

  Future<void> _authenticate(BuildContext context) async {
    try {
      bool isAuthenticated = await _localAuthentication.authenticate(
        localizedReason: 'Veuillez placer votre doigt sur le capteur d\'empreintes digitales pour vous authentifier.',
          options: const AuthenticationOptions(
              biometricOnly: true,  // Restreindre l'authentification aux empreintes digitales uniquement
              useErrorDialogs: true,
              stickyAuth: true, // Si vous voulez que l'authentification persiste jusqu'à ce que l'utilisateur réussisse ou annule

          ),
        );




      if (isAuthenticated) {
        print('Authentification réussie !');
        showCustomSnackbar(context, 'Authentification réussie !');
        setState(() {
          _isLogger = true;
        });
      } else {
        print('Authentification échouée !');
        showCustomSnackbar(context, 'Authentification échouée !');
      }

      _goback(context);
    } catch (e) {
      print('Erreur lors de l\'authentification : $e');
    }
  }

  void _goback(BuildContext context) {
    if (_isVibration == true && _isLogger == true) {
      Navigator.pop(context);
    }
  }

  void testVibration() async {
    // Vibrate pendant 5 secondes (5000 millisecondes)
    await Vibration.vibrate(duration: 5000);

    setState(() {
      _isVibration = true;
    });

    _goback(context);

    // Si vous voulez émettre des vibrations avec un modèle spécifique, vous pouvez le faire ainsi :
    // await Vibration.vibrate(pattern: [500, 1000, 500, 2000]); // Répète 4 fois: vibre pendant 500 ms, attend 1000 ms, vibre pendant 500 ms, attend 2000 ms
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test de Vibration et Authentification',style: StyleText.appbarStyle,),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Prise en charge de l\'authentification biométrique : ${_isBiometricSupported ? 'Oui' : 'Non'}'),
            Text('Prise en charge de l\'empreinte digitale : ${_isFingerprintSupported ? 'Oui' : 'Non'}'),
            Text('Prise en charge de Face ID : ${_isFaceIdSupported  ? 'Oui' : 'Non'}'),
            ElevatedButton(
              onPressed: _isBiometricSupported ? () => _authenticate(context) : null,
              child: Text('Authentifier avec l\'empreinte digitale'),
            ),
            ElevatedButton(
              onPressed: testVibration,
              child: Text('Effectuer le test de vibration'),
            ),
          ],
        ),
      ),
    );
  }
}
