import 'package:flutter/material.dart';

class StyleButton {
  static final elevatedButtonStyle = ElevatedButton.styleFrom(
    primary: Colors.blue, // Couleur de fond du bouton
    onPrimary: Colors.white, // Couleur du texte du bouton
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0), // Rayon de la bordure
      side: BorderSide(color: Colors.blue), // Couleur de la bordure
    ),
  );
}