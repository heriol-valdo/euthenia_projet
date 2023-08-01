import 'dart:async';
import 'dart:math';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';

class DiagnosticEcranScreen extends StatefulWidget {
  _DiagnosticEcranScreenState createState() => _DiagnosticEcranScreenState();
}

class _DiagnosticEcranScreenState extends State<DiagnosticEcranScreen> {
  final int rowCount = 12;
  final int colCount = 8;
  List<List<Color>> _gridColors = [];
  int _clickedCount = 0;

  Color _getRandomColor() {
    Random random = Random();
    int r = random.nextInt(256);
    int g = random.nextInt(256);
    int b = random.nextInt(256);
    return Color.fromARGB(255, r, g, b);
  }

  void _onGridTapped(int row, int col) {
    setState(() {
      if (_gridColors[row][col] == Colors.grey[300]) {
        _gridColors[row][col] = _getRandomColor();
        _clickedCount++;
      }
    });

    double percentage = (_clickedCount / (rowCount * colCount) * 100);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pourcentage de clics : ${percentage.toStringAsFixed(1)}%'),
        duration: Duration(seconds: 2),
      ),
    );

    if (percentage >= 100.0) {
      // Si le pourcentage est égal ou supérieur à 100%, on retourne à la page précédente.
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    _calculateGridColors();
    Timer(Duration(milliseconds: 500), () => _showAlertDialog());
  }

  void _calculateGridColors() {
    _gridColors = List.generate(rowCount, (_) => List.filled(colCount, Colors.grey[300]!));
  }

  void _showAlertDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Bienvenue'),
          content: Text('Appuyez sur une case pour changer sa couleur.\n'
              'Les cases déjà colorées resteront inchangées. vous aurez un pourcentage de progression une fois a 100% vous sortirez de la page'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              double cellWidth = constraints.maxWidth / colCount;
              double cellHeight = constraints.maxHeight / rowCount;

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: colCount,
                  crossAxisSpacing: 0.9,
                  mainAxisSpacing: 0.9,
                  childAspectRatio: cellWidth / cellHeight,
                ),
                itemBuilder: (context, index) {
                  int row = index ~/ colCount;
                  int col = index % colCount;
                  return GestureDetector(
                    onTap: () => _onGridTapped(row, col),
                    child: Container(
                      color: _gridColors[row][col],
                    ),
                  );
                },
                itemCount: rowCount * colCount,
              );
            },
          ),
        ),
      ),
    );
  }
}
