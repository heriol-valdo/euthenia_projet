
import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:euthenia_project/Style/StyleText.dart';
import 'package:flutter/material.dart';

 class DiagnosticBatteryScreen extends StatefulWidget{
   _DiagnosticBatteryScreenState createState() => _DiagnosticBatteryScreenState();
}

class _DiagnosticBatteryScreenState extends State<DiagnosticBatteryScreen>{
  final Battery _battery = Battery();
  StreamSubscription<BatteryState>? _batteryStateSubscription;
  bool _isCharging = false;

  @override
  void initState() {
    super.initState();
    _batteryStateSubscription = _battery.onBatteryStateChanged.listen(_onBatteryStateChanged);
  }

  @override
  void dispose() {
    _batteryStateSubscription?.cancel();
    super.dispose();
  }

  void _onBatteryStateChanged(BatteryState batteryState) {
    setState(() {
      _isCharging = batteryState == BatteryState.charging;
      if (_isCharging) {
        // Rediriger automatiquement après 2 secondes si le téléphone est en charge
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context); // Rediriger vers la page précédente
        });
      }
    });
  }



  String _getMessage() {
    return _isCharging
        ? 'Le circuit de charge est correct.'
        : 'Le téléphone n\'est pas en charge.\nVeuillez charger le téléphone.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DiagnosticBatteryScreen',style: StyleText.appbarStyle,),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isCharging ? Icons.check_circle : Icons.warning,
              color: _isCharging ? Colors.green : Colors.red,
              size: 100,
            ),
            SizedBox(height: 20),
            Text(
              _getMessage(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, color: _isCharging ? Colors.green : Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}