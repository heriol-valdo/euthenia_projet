import 'package:euthenia_project/OptionsApp/InfoDevicePdf.dart';
import 'package:flutter/material.dart';
import '../Controller/InfoDeviceConroller.dart';
import '../Style/StyleText.dart';

class InfoDeviceScreen extends StatefulWidget {
  @override
  _InfoDeviceScreenState createState() => _InfoDeviceScreenState();
}

class _InfoDeviceScreenState extends State<InfoDeviceScreen> {
  // Ajoutez ici les variables d'état et les méthodes nécessaires

  Future<void> generateAndShowPdf() async {
    Map<String, dynamic>? specs = await InfoDeviceController.getDeviceSpecs();
    InfoDevicePdf pdfGenerator = InfoDevicePdf();
    await pdfGenerator.savePdf(context, specs!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: generateAndShowPdf,
          ),
        ],
        title: const Center(
          child: Text(
            'InfoDevice',
            textAlign: TextAlign.center,
            style: StyleText.appbarStyle,
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: InfoDeviceController.getDeviceSpecs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasData) {
            Map<String, dynamic>? specs = snapshot.data;
            return ListView.builder(
              itemCount: specs?.length,
              itemBuilder: (context, index) {
                String key = specs!.keys.elementAt(index);
                String value = specs[key].toString();
                return ListTile(
                  title: Text(key),
                  subtitle: Text(value),
                );
              },
            );
          } else {
            return Center(
              child: Text('Impossible de récupérer les informations du smartphone.'),
            );
          }
        },
      ),
    );
  }
}
