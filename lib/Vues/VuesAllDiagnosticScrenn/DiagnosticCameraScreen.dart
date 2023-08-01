import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:battery_plus/battery_plus.dart';
import 'package:camera/camera.dart';
import 'package:euthenia_project/Style/StyleText.dart';
import 'package:exif/exif.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'dart:ui' as ui;

class DiagnosticCameraScreen extends StatefulWidget {
  _DiagnosticCameraScreenState createState() => _DiagnosticCameraScreenState();
}

class _DiagnosticCameraScreenState extends State<DiagnosticCameraScreen> {
  List<CameraDescription> cameras = [];
  CameraController? _controller;
  bool isFlashOn = true;
  double flashWorkingPercentage = 0.0;
  double imageQuality = 0.0;

  List<bool> buttonsClicked = [false, false, false];
  Color flashIconColor = Colors.white; // Couleur initiale de l'icône du flash

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      _controller = CameraController(cameras[0], ResolutionPreset.medium);
      await _controller!.initialize();
      _controller!.setFlashMode(FlashMode.torch); // Activer le flash en continu

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Erreur lors de l\'initialisation de la caméra : $e');
    }
  }

  Future<void> _testCamera(int index) async {
    if (!buttonsClicked[index]) {
      try {
        if (cameras.isNotEmpty) {
          _controller = CameraController(cameras[index], ResolutionPreset.medium);
          await _controller!.initialize();
          if (mounted) {
            setState(() {});
          }
          XFile picture = await _controller!.takePicture();
          img.Image image = img.decodeImage(File(picture.path).readAsBytesSync())!;
          imageQuality = await _calculateImageQuality(image);

          // Afficher le pourcentage de qualité du flash et de l'image dans un AlertDialog
          _showQualityDialog();

          // Marquer le bouton comme cliqué
          setState(() {
            buttonsClicked[index] = true;
          });

          // Vérifier si tous les boutons ont été cliqués
          if (buttonsClicked.every((buttonClicked) => buttonClicked)) {
            // Tous les boutons ont été cliqués, revenir automatiquement à la page précédente
            Future.delayed(Duration(seconds: 2), () {
              Navigator.pop(context);
            });
          }
        }
      } catch (e) {
        print('Erreur lors de l\'initialisation de la caméra : $e');
      }
    }
  }

  Future<double> _calculateImageQuality(img.Image image) async {
    Uint8List imageData = Uint8List.fromList(img.encodePng(image));
    int originalSize = imageData.lengthInBytes;
    Uint8List compressedImageData = await FlutterImageCompress.compressWithList(
      imageData,
      minHeight: image.height,
      minWidth: image.width,
      quality: 90,
    );
    double compressionRatio = originalSize / compressedImageData.lengthInBytes;
    double sharpness = 1.0 / compressionRatio;
    sharpness = sharpness.clamp(0.0, 1.0);
    return sharpness;
  }

  void _showQualityDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Qualité de l\'image '),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [

              Text('Score de qualité de l\'image : ${(imageQuality * 100).toStringAsFixed(2)}%'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }


  void _showQualityDialogFlash() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Qualité  du flash'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Score de qualité du flash : ${(flashWorkingPercentage).toStringAsFixed(2)}%'),

            ],
          ),
          actions: [
            TextButton(
              onPressed: () {  Navigator.pop(context);},
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
  void _toggleFlash(int index) {
     if(!buttonsClicked[index]){
       setState(() {
         isFlashOn = !isFlashOn;
         _controller!.setFlashMode(isFlashOn ? FlashMode.off : FlashMode.torch);

         buttonsClicked[index] = true;
         // Changer la couleur de l'icône du flash en fonction de l'état
         flashIconColor = isFlashOn ? Colors.yellow : Colors.white;

         if (!isFlashOn) {
           _checkFlashWorkingPercentage();
         }
       });
     }
  }

  void _checkFlashWorkingPercentage() async {
    try {
      bool flashWorking = await _isFlashWorking();
      setState(()  {

        flashWorkingPercentage = flashWorking ? 100.0 : 0.0;
        flashWorkingPercentage = flashWorkingPercentage.clamp(0.0, 100.0); // Limiter à 100%

      });

      _showQualityDialogFlash();
      // Vérifier si tous les boutons ont été cliqués
      if (buttonsClicked.every((buttonClicked) => buttonClicked)) {
        // Tous les boutons ont été cliqués, revenir automatiquement à la page précédente
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pushNamed(context, '/diagnostic');
        });
      }
    } catch (e) {
      print('Erreur lors de la vérification du bon fonctionnement du flash : $e');
    }
  }

  Future<bool> _isFlashWorking() async {
    Battery battery = Battery();
    final int batteryLevel = await battery.batteryLevel;
    final int threshold = 5; // Niveau de batterie en dessous duquel le flash ne fonctionne pas
    return batteryLevel >= threshold;
  }

  bool _canGoBack() {
    return buttonsClicked.every((clicked) => clicked);
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: Text('Test de la caméra')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('DiagnosticCameraScreen',style: StyleText.appbarStyle,)),
      body:LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double aspectRatio = constraints.maxWidth / constraints.maxHeight;
          return AspectRatio(
            aspectRatio: aspectRatio,
            child: CameraPreview(_controller!),
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => _testCamera(0),
            child: Icon(Icons.camera_rear),
            backgroundColor: buttonsClicked[0] ? Colors.grey : null,
            heroTag: null,
          ),
          SizedBox(width: 16),
          FloatingActionButton(
            onPressed: () => _testCamera(1),
            child: Icon(Icons.camera_front),
            backgroundColor: buttonsClicked[1] ? Colors.grey : null,
            heroTag: null,
          ),
          SizedBox(width: 16),
          FloatingActionButton(
            onPressed:() => _toggleFlash(2),
            child: Icon(isFlashOn ? Icons.flash_on : Icons.flash_off),
            backgroundColor:  buttonsClicked[2] ? Colors.grey : null,
            heroTag: null,
            foregroundColor: flashIconColor, // Utilisez la couleur de l'icône du flash
          ),

        ],
      ),

    );
  }

}
