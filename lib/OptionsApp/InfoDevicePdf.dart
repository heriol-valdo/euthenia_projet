import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:universal_platform/universal_platform.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class InfoDevicePdf {
  // ... Code existant ...

  Future<void> savePdf(BuildContext context, Map<String, dynamic> specs) async {
    final pdf = pw.Document();
    final pw.Font ttfFont =
    pw.Font.ttf(await rootBundle.load("assets/fonts/secondary/roboto.ttf"));

    final pw.TextStyle textStyle = pw.TextStyle(
      font: ttfFont,
      fontSize: 20,
      fontFallback: [pw.Font.helvetica()],
    );

    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Container(
            child: pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: pw.FlexColumnWidth(1),
                1: pw.FlexColumnWidth(1),
                2: pw.FlexColumnWidth(1),
              },
              children: [
                pw.TableRow(children: [
                  pw.Text('Titre', style: textStyle),
                  pw.Text('Information', style: textStyle),
                ]),
                for (var entry in specs.entries)
                  pw.TableRow(children: [
                    pw.Text(entry.key, style: textStyle),
                    pw.Text(entry.value.toString(), style: textStyle),
                  ]),
              ],
            ),
          ),
        );
      },
    ));

    final output = await getTemporaryDirectory();
    final outputFile = File('${output.path}/device_info.pdf');
    await outputFile.writeAsBytes(await pdf.save());

    if (UniversalPlatform.isWeb) {
      // ... Sauvegarder le PDF pour la plateforme web (si nécessaire) ...
    } else if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
      // Pour les plates-formes mobiles, utilise le paquet flutter_email_sender pour envoyer un e-mail avec le PDF en tant que pièce jointe.

      final Email email = Email(
        body: 'Veuillez trouver ci-joint les informations du périphérique au format PDF.',
        subject: 'PDF Informations du périphérique',
        recipients: ['zeufackheriol9@gmail.com'],
        attachmentPaths: [outputFile.path],
        isHTML: false,
      );

      try {
        // Ouvrir l'application de messagerie avec le PDF en tant que pièce jointe.
        await FlutterEmailSender.send(email);
      } catch (e) {
        // Gérer les erreurs si l'e-mail ne peut pas être envoyé.
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Erreur'),
            content: Text('Une erreur est survenue lors de l\'envoi de l\'e-mail avec le PDF en tant que pièce jointe $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Fermer'),
              ),
            ],
          ),
        );
      }
    } else {
      // ... Sauvegarder le PDF pour d'autres plates-formes (si nécessaire) ...
    }
  }
}
