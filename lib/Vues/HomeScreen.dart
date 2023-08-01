import 'package:euthenia_project/Vues/InfoDeviceScreen.dart';
import 'package:flutter/material.dart';

import '../Style/StyleButton.dart';
import '../Style/StyleText.dart';

class HomeScreem extends StatefulWidget {
  @override
  _HomeScreemState createState() => _HomeScreemState();
}

class _HomeScreemState  extends State<HomeScreem > {
  // Ajoutez ici les variables d'état et les méthodes nécessaires

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Center(child:  Text('HomeScreen',textAlign: TextAlign.center,style: StyleText.appbarStyle,) )
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(child:  Text('Vous etes ici pour faire diagnostiquer votre appareil')),
           
            Container(
              margin: EdgeInsets.all(50),
              child: ElevatedButton(
              onPressed: () { Navigator.pushNamed(context, '/infodevicescreem'); },
              style: StyleButton.elevatedButtonStyle,
              child: Text('Voir les informations du Device'),
              ),
             ),

            Container(
              margin: EdgeInsets.all(0),
              child: ElevatedButton(
                onPressed: () {Navigator.pushNamed(context, '/diagnostic');},
                style: StyleButton.elevatedButtonStyle,
                child: Text('Effectuez le diagnostic de votre Appareil'),
              ),
            )


          ],
        ),
      ),
    );
  }
}
