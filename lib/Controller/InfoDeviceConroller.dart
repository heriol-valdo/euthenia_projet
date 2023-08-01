
// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'dart:ui' as ui;
import 'package:battery_plus/battery_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:storage_info/storage_info.dart';
import 'package:system_info_plus/system_info_plus.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';

import 'package:system_info_plus/system_info_plus.dart';


import 'package:disk_space/disk_space.dart';
import 'package:disk_space_plus/disk_space_plus.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:upower/upower.dart';



class InfoDeviceController {

  static const  _channelDevice = MethodChannel('ISLOOKED');

  static const channelaccount = const MethodChannel('flutter.moumoute.dev/account');

  static const MethodChannel _channel = MethodChannel('storage_utils');

  static const nameoperator = const MethodChannel('flutter.moumoute.dev/operator');

  static const platform = MethodChannel('com.example.euthenia_project/battery_health_channel');
  int batteryHealth = -1;
  static Future<Map<String, dynamic>> getDeviceSpecs() async {
    Map<String, dynamic> specs = {};

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (InfoDeviceController.isAndroid()) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      specs['IMEI/Numéro de série'] = androidInfo.id;
      specs['Logiciel'] = 'OS Android';
      specs['compte google'] =await isGoogleAccountPresent();
      specs['Marque/Modèle'] = '${androidInfo.brand} ${androidInfo.model}';
      specs['Taille écran'] = await getTailleEcran();
      specs['Boote'] = await isDeviceRooted();
      specs['Version de l’OS'] = androidInfo.version.release;
      specs['Taille stockage'] =await getStorageCapacity() ;
      specs['Battery']  = await getBatteryHealth();
      specs['RAM'] = await _getAndroidRAM();
      //pour savoir si l'option de carte sim est bloquer ou debloquer
      specs['CarteSIM(bloquer/debloquer)'] = await isSimCardLocked();
     // specs['CarteSIM(presente/non presente)'] = await isSimCardPresent();

       specs['Fournisseur/Opérateur'] = await getOperatorName();
    }
    else if (InfoDeviceController.isIOS()) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      specs['IMEI/Numéro de série'] = iosInfo.identifierForVendor;
      specs['Logiciel'] = 'iOS';
      specs['Marque/Modèle'] = '${iosInfo.name} ${iosInfo.model}';
     // specs['Taille écran'] = '${iosInfo.screenSize.width} x ${iosInfo.screenSize.height} pouces';
      specs['Résolution écran'] = '${iosInfo.utsname.machine}';
      specs['Taille stockage'] = '${iosInfo.utsname.machine} octets';
      specs['Version de l’OS'] = iosInfo.systemVersion;
      specs['RAM'] = '${iosInfo.utsname.nodename} octets';
      specs['Fournisseur/Opérateur'] = 'N/A (iOS)';
    }
    else if (InfoDeviceController.isMacOS()) {
      IosDeviceInfo macosInfo = await deviceInfo.iosInfo;
      specs['Logiciel'] = 'macOS';
      specs['Système d\'exploitation'] = macosInfo.systemName;
      specs['Nom de l\'appareil'] = macosInfo.name;
      //specs['Nom de l\'utilisateur'] = macosInfo.hostName;
      specs['Nom du modèle'] = macosInfo.model;
      specs['Nom du fabricant'] = macosInfo.utsname.sysname;
    }
    else if (InfoDeviceController.isLinux()) {

      specs['Logiciel'] = 'Linux';
      specs['RAM'] = await _getLinuxRAM();
      specs['Système d\'exploitation'] = _getLinuxOSVersion();
      specs['Taille écran'] =await  _getLinuxScreenSize();
      specs['Marque/Modèle'] = _getLinuxModel();
      specs['Carte Graphique'] = _getLinuxGPU();
      specs['Capacite de la baterie'] =await _getBatteryCapacity();

      specs['Capacité du disque dur'] =await _getLinuxDiskCapacity();
      specs['Espace libre du disque dur'] =await _getLinuxFreeSpace();
      specs['Espace utilisé du disque dur'] =await _getLinuxUsedSpace();
      specs['Nom du disque dur'] = _getLinuxDiskName();
      specs['Type de disque dur'] = _getLinuxDiskType();
      specs['Processeur'] = _getLinuxProcessor();

    }
    else if (InfoDeviceController.isWindows()) {
      WindowsDeviceInfo windowsInfo = await deviceInfo.windowsInfo;
      specs['Logiciel'] = 'Windows';
    //  specs['Système d\'exploitation'] = windowsInfo.osName;
      specs['Architecture du processeur'] = windowsInfo.systemMemoryInMegabytes;
    //  specs['Nom de l\'appareil'] = windowsInfo.deviceName;
      specs['Nom de l\'utilisateur'] = windowsInfo.computerName;
    //  specs['Nom du fabricant'] = windowsInfo.manufacturer;
    }

    return specs;
  }

  //definition de la platforme
  static bool isWindows() {return Platform.isWindows;}
  static bool isMacOS() {return Platform.isMacOS;}
  static bool isLinux() {return Platform.isLinux;}
  static bool isDesktop() {return Platform.isWindows || Platform.isMacOS || Platform.isLinux;}
  static bool isAndroid() {return Platform.isAndroid;}
  static bool isIOS() {return Platform.isIOS;}


  // recupretaion des informations sous linux
  static Future<String> _getLinuxRAM() async {
    try {
      ProcessResult result = await Process.run('free', ['-m']);
      if (result.exitCode == 0) {
        String output = result.stdout;
        List<String> lines = output.split('\n');
        if (lines.length >= 2) {
          List<String> memoryInfo = lines[1].trim().split(RegExp(r'\s+'));
          if (memoryInfo.length >= 4) {
            int totalRAMInMB = int.tryParse(memoryInfo[1]) ?? 0;
            int usedRAMInMB = int.tryParse(memoryInfo[2]) ?? 0;
            return '$totalRAMInMB Mo (utilisés: $usedRAMInMB Mo)';
          }
        }
      }
    } catch (e) {
      print('Erreur lors de l\'exécution de la commande free: $e');
    }
    return 'N/A (Linux)';
  }
  static String _getLinuxOSVersion() {
    try {
      ProcessResult result = Process.runSync('lsb_release', ['-ds']);
      if (result.exitCode == 0) {
        return result.stdout.toString().trim();
      }
    } catch (e) {
      print('Erreur lors de l\'exécution de la commande lsb_release: $e');
    }
    return 'N/A (Linux)';
  }
  static Future<String> _getLinuxScreenSize() async {
    try {
      // Exécute la commande 'xrandr --query'
      ProcessResult result = await Process.run('xrandr', ['--query']);

      if (result.exitCode == 0) {
        String output = result.stdout.toString();
        List<String> lines = output.trim().split('\n');
        for (String line in lines) {
          if (line.contains(' connected')) {
            List<String> words = line.trim().split(' ');
            String resolution = words[2];
            return 'Résolution de l\'écran : $resolution';
          }
        }
      } else {
        return 'Erreur lors de la récupération de la résolution de l\'écran.';
      }
    } catch (e) {
      return 'Erreur lors de l\'exécution de la commande xrandr: $e';
    }
    return 'Résolution de l\'écran non disponible.';
  }
  static Future<String> _getBatteryCapacity() async {
    try {
      ProcessResult result = await Process.run('upower', ['-i', '/org/freedesktop/UPower/devices/battery_BAT0']);
      if (result.exitCode == 0) {
        String output = result.stdout.toString();
        RegExp chargeRegExp = RegExp(r'state:\s+(\S+)');
        Match? chargeMatch = chargeRegExp.firstMatch(output);
        if (chargeMatch != null && chargeMatch.group(1) == 'charging') {
          return 'Batterie en charge';
        } else {
          RegExp capacityRegExp = RegExp(r'capacity:\s+([\d,.]+)%');
          Match? capacityMatch = capacityRegExp.firstMatch(output);
          if (capacityMatch != null) {
            double capacity = double.parse(capacityMatch.group(1)!.replaceAll(',', '.'));
            return '$capacity%';
          }
        }
      }
    } catch (e) {
      print('Erreur lors de la récupération de l\'état de santé de la batterie: $e');
    }
    return 'N/A (Linux)';
  }
  static String _getLinuxModel() {
    try {
      ProcessResult result = Process.runSync('uname', ['-a']);
      if (result.exitCode == 0) {
        return result.stdout.toString().trim();
      }
    } catch (e) {
      print('Erreur lors de l\'exécution de la commande uname: $e');
    }
    return 'N/A (Linux)';
  }
  static Future<String> _getLinuxDiskCapacity() async {
    int totalCapacityBytes = 0;

    try {
      ProcessResult result = await Process.run('lsblk', ['-bd', '-o', 'SIZE']);
      if (result.exitCode == 0) {
        String output = result.stdout.toString();
        List<String> lines = output.trim().split('\n');

        for (int i = 1; i < lines.length; i++) {
          String capacityLine = lines[i].trim();
          int capacityBytes = int.tryParse(capacityLine) ?? 0;
          totalCapacityBytes += capacityBytes;
        }

        double totalCapacityGB = totalCapacityBytes / 1073741824;
        return '${totalCapacityGB.toStringAsFixed(2)} Go';
      }
    } catch (e) {
      print('Erreur lors de la récupération de la capacité totale du disque dur: $e');
      return 'N/A (Linux)';
    }

    return 'N/A (Linux)';
  }
  static Future<String>  _getLinuxFreeSpace() async {
    double totalFreeSpaceGB = 0.0;

    try {
      ProcessResult result = await Process.run('df', ['-B1', '--output=target,avail']);
      if (result.exitCode == 0) {
        List<String> lines = result.stdout.toString().trim().split('\n');
        for (int i = 1; i < lines.length; i++) {
          List<String> fields = lines[i].split(RegExp(r'\s+'));
          if (fields.length >= 2) {
            int freeSpaceInBytes = int.tryParse(fields[1]) ?? 0;
            double freeSpaceInGB = freeSpaceInBytes / 1073741824;
            totalFreeSpaceGB += freeSpaceInGB;
          }
        }
      }
    } catch (e) {
      print('Erreur lors de la récupération de l\'espace libre des disques: $e');
    }

    double totalFreeSpaceInGB = totalFreeSpaceGB;
    return '${totalFreeSpaceInGB.toStringAsFixed(2)} Go';


  }
  static Future<String> _getLinuxUsedSpace() async {
    int totalUsedSpaceInBytes = 0;

    try {
      ProcessResult result = await Process.run('df', ['-B1', '--output=used']);
      if (result.exitCode == 0) {
        List<String> lines = result.stdout.toString().trim().split('\n');
        for (int i = 1; i < lines.length; i++) {
          String usedSpaceInBytesString = lines[i].trim();
          int usedSpaceInBytes = int.tryParse(usedSpaceInBytesString) ?? 0;
          totalUsedSpaceInBytes += usedSpaceInBytes;
        }
      }
    } catch (e) {
      print('Erreur lors de la récupération de l\'espace utilisé des disques: $e');
      return 'N/A (Linux)';
    }

    double totalUsedSpaceInGB = totalUsedSpaceInBytes / 1073741824;
    return '${totalUsedSpaceInGB.toStringAsFixed(2)} Go';
  }
  static String _getLinuxDiskName() {
    try {
      ProcessResult result = Process.runSync('lsblk', ['-bd', '-o', 'NAME']);
      if (result.exitCode == 0) {
        return result.stdout.toString().split('\n')[1].trim();
      }
    } catch (e) {
      print('Erreur lors de la récupération du nom du disque dur: $e');
    }
    return 'N/A (Linux)';
  }
  static String _getLinuxDiskType() {
    try {
      ProcessResult result = Process.runSync('lsblk', ['-bd', '-o', 'TYPE']);
      if (result.exitCode == 0) {
        return result.stdout.toString().split('\n')[1].trim();
      }
    } catch (e) {
      print('Erreur lors de la récupération du type de disque dur: $e');
    }
    return 'N/A (Linux)';
  }
  static String _getLinuxProcessor() {
    try {
      File cpuInfoFile = File('/proc/cpuinfo');
      if (cpuInfoFile.existsSync()) {
        String cpuInfo = cpuInfoFile.readAsStringSync();
        return cpuInfo;
      } else {
        print('Le fichier /proc/cpuinfo n\'existe pas.');
      }
    } catch (e) {
      print('Erreur lors de la récupération des informations sur le processeur: $e');
    }
    return 'N/A (Linux)';
  }
  static String _getLinuxGPU() {
    try {
      ProcessResult result = Process.runSync('lspci', ['-v', '-mm']);
      if (result.exitCode == 0) {
        String output = result.stdout.toString();
        List<String> lines = output.split('\n');
        String gpuInfo = '';

        for (String line in lines) {
          if (line.contains('VGA compatible controller')) {
            gpuInfo = line;
            break;
          }
        }

        return gpuInfo;
      }
    } catch (e) {
      print('Erreur lors de la récupération des informations sur la carte graphique: $e');
    }
    return 'N/A (Linux)';
  }


  //recuperation des information sous Android
  static Future<String> getStorageCapacity() async {
    try {
      final int totalStorageInBytes = await _channel.invokeMethod('getTotalInternalStorage');
      double totalStorageInGB = totalStorageInBytes / (1024 * 1024 * 1024);

      if (totalStorageInGB <= 4) {
        return '4 Go';
      } else if (totalStorageInGB <= 8) {
        return '8 Go';
      } else if (totalStorageInGB <= 16) {
        return '16 Go';
      } else if (totalStorageInGB <= 32) {
        return '32 Go';
      } else if (totalStorageInGB <= 64) {
        return '64 Go';
      } else if (totalStorageInGB <= 128) {
        return '128 Go';
      } else if (totalStorageInGB <= 256) {
        return '256 Go';
      }  else if (totalStorageInGB > 256) {
        return '$totalStorageInGB Go';
      }
      else {
        return 'Taille de stockage inconnue';
      }
    } on PlatformException catch (e) {
      print('Erreur lors de la récupération de la taille de stockage interne: $e');
      return 'N/A';
    }
  }
  static Future<String> getTailleEcran() async {
    try {
      // Utiliser dart:ui pour obtenir la taille de l'écran
      Size size = ui.window.physicalSize;
      double width = size.width / ui.window.devicePixelRatio;
      double height = size.height / ui.window.devicePixelRatio;

      return '${width.toInt()} x ${height.toInt()} pixels';
    } catch (e) {
      return 'Impossible de récupérer la taille de l\'écran : $e';
    }
  }
  static Future<String?> _getAndroidRAM() async {
    try {
      int? deviceMemoryInMB = await SystemInfoPlus.physicalMemory;
      if (deviceMemoryInMB != null) {
        double deviceMemoryInGB = deviceMemoryInMB / 1024;
        if (deviceMemoryInGB <= 1) {
          return '1 Go';
        } else if (deviceMemoryInGB <= 2) {
          return '2 Go';
        } else if (deviceMemoryInGB <= 3) {
          return '3 Go';
        } else if (deviceMemoryInGB <= 4) {
          return '4 Go';
        } else if (deviceMemoryInGB <= 6) {
          return '6 Go';
        } else if (deviceMemoryInGB <= 8) {
          return '8 Go';
        } else if (deviceMemoryInGB <= 12) {
          return '12 Go';
        } else if (deviceMemoryInGB <= 16) {
          return '16 Go';
        }
        else if (deviceMemoryInGB <= 32) {
          return '32 Go';
        }
        else if (deviceMemoryInGB > 32) {
          return '$deviceMemoryInGB  Go';
        }else {
          return 'Taille de stockage inconnue';
        }
      } else {
        return null;
      }
    } catch (e) {
      print('Erreur lors de la récupération de la RAM: $e');
      return 'N / A (Android)';
    }
  }
  static Future<String> getBatteryHealth() async {
    try {

      String batteryHealth = await platform.invokeMethod('getBatteryHealth');
      return batteryHealth;
    } on PlatformException catch (e) {
      return 'Erreur lors de la récupération de l\'état de santé de la batterie : ${e.message}';
    }
  }
  static Future<String> getOperatorName() async {
    try {
      String result = await nameoperator.invokeMethod('getOperatorName');
      return result.isEmpty ? 'Operation non disponible' : result;
    } on PlatformException catch (e) {
      return 'Erreur lors de la récupération du nom de l\'opérateur: ${e.message}';
    }
  }
  static Future<String?> isGoogleAccountPresent() async {
    try {
      String? firstGoogleAccount = await channelaccount.invokeMethod('getFirstGoogleAccount');
      if (firstGoogleAccount != null) {

        return '$firstGoogleAccount';
      } else {
        return 'Aucun Compte Google';
      }
    } on PlatformException catch (e) {

      return 'Erreur lors de la récupération du compte Google : ${e.message}';
    }
  }
  static Future<String?> isDeviceRooted() async {
    try {
      bool? isBootloaderUnlocked = await MethodChannel('flutter.moumoute.dev/device').invokeMethod<bool>('isDeviceBootloaderUnlocked');
      if (isBootloaderUnlocked!) {
        return 'Le bootloader est déverrouillé.';
      } else {
         return 'Le bootloader n\'est pas déverrouillé.';
      }
    } on PlatformException catch (e) {

      return 'Erreur lors de la récupération etat boot : ${e.message}';
    }
  }

  static Future<String?> isSimCardLocked() async {
    try {
      bool? hasSimCard = await _channelDevice.invokeMethod<bool>('canTakeSimCard');
      if (hasSimCard == true) {
        return 'Le téléphone peut prendre en charge une carte SIM.';
      } else if (hasSimCard == false) {
        return 'Le téléphone ne peut pas prendre en charge une carte SIM.';
      } else {
        return 'Impossible de déterminer si le téléphone peut prendre une carte SIM.';
      }
    } on PlatformException catch (e) {
      print('Erreur lors de la vérification de la carte SIM : ${e.message}');
      return 'Erreur lors de la vérification de la carte SIM.';
    }
  }
  }































