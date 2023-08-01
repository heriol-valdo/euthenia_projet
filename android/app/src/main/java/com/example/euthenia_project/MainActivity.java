package com.example.euthenia_project;

import android.Manifest;
import com.example.euthenia_project.BiometricUtils;
import android.accounts.Account;
import android.accounts.AccountManager;
import android.content.ActivityNotFoundException;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.media.AudioManager;
import android.os.Build;
import android.os.Bundle;

import io.flutter.Log;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.FlutterMain;

import android.os.BatteryManager;
import android.telephony.SubscriptionInfo;
import android.telephony.SubscriptionManager;
import android.telephony.TelephonyManager;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import androidx.core.app.ActivityCompat;

import com.google.android.gms.common.AccountPicker;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GoogleApiAvailabilityLight;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;

public class MainActivity extends FlutterFragmentActivity {

    private static final String CHANNEL_BIOMETRICS = "com.example.euthenia_project/biometric";

    private static final String VOLUME_CHANNEL_NAME = "volume_events";

    private static final String CHANNEL_DEVICE_SIM = "ISLOOKED";
    private static final String CHANNEL_DEVICE = "flutter.moumoute.dev/device";
    private static final String channelaccount = "flutter.moumoute.dev/account";

    private static final String operatorChannel = "flutter.moumoute.dev/operator";

    private static final String CHANNEL = "storage_utils";
    private static final String RAM_CHANNEL = "memory_info_channel";
    private static final String CHANNELBattery = "com.example.euthenia_project/battery_health_channel";




    private Context context;
    MemoryInfoPlugin memoryInfoPlugin = new MemoryInfoPlugin(context);

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);


        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    if (call.method.equals("getTotalInternalStorage")) {
                        long totalStorage = StorageUtils.getTotalInternalStorage();
                        result.success(totalStorage);
                    } else {
                        result.notImplemented();
                    }
                });

        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), RAM_CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    if (call.method.equals("getTotalRAM")) {
                        long totalRAM = memoryInfoPlugin.getTotalRAM(); // Utilisez la méthode getTotalRAM du plugin MemoryInfoPlugin
                        result.success(totalRAM);
                    } else {
                        result.notImplemented();
                    }
                });

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNELBattery)
                .setMethodCallHandler((call, result) -> {
                    if (call.method.equals("getBatteryHealth")) {
                        String batteryHealth = getBatteryHealth(); // Utilisez la méthode getBatteryHealthString du plugin MemoryInfoPlugin
                        result.success(batteryHealth);
                    } else {
                        result.notImplemented();
                    }
                });

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), operatorChannel).setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("getOperatorName")) {
                        String operatorName = getOperatorName();
                        result.success(operatorName);
                    } else {
                        result.notImplemented();
                    }
                }
        );

        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), channelaccount).setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("getFirstGoogleAccount")) {
                        String accountName = getFirstGoogleAccount();
                        result.success(accountName);
                    } else {
                        result.notImplemented();
                    }
                }
        );

        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL_DEVICE).setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("isDeviceRooted")) {
                        boolean isRooted = isDeviceRooted();
                        result.success(isRooted);
                    } else if (call.method.equals("isDeviceBootloaderUnlocked")) {
                        boolean isUnlocked = isDeviceBootloaderUnlocked();
                        result.success(isUnlocked);
                    } else {
                        result.notImplemented();
                    }
                }
        );

        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL_DEVICE_SIM)
                .setMethodCallHandler((call, result) -> {
                    if (call.method.equals("canTakeSimCard")) {
                        boolean canTakeSimCard = SimCardUtil.canTakeSimCard(getApplicationContext());
                        result.success(canTakeSimCard);
                    } else {
                        result.notImplemented();
                    }
                });


        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL_BIOMETRICS).setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("isBiometricSupported")) {
                        boolean isBiometricSupported = BiometricUtils.isBiometricSupported(this);
                        result.success(isBiometricSupported);
                    } else if (call.method.equals("isFaceIdSupported")) {
                        boolean isFaceIdSupported = BiometricUtils.isFaceIdSupported(this);
                        result.success(isFaceIdSupported);
                    } else if (call.method.equals("isTouchIdSupported")) {
                        boolean isTouchIdSupported = BiometricUtils.isTouchIdSupported(this);
                        result.success(isTouchIdSupported);
                    } else {
                        result.notImplemented();
                    }
                }
        );



        new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), VOLUME_CHANNEL_NAME)
                .setStreamHandler(new VolumeChangeStreamHandler(this));

    }








    private boolean isDeviceRooted() {
        // Vérifiez si l'appareil est rooté en appelant les méthodes checkRootMethod1(), checkRootMethod2(), etc.
        return checkRootMethod1() || checkRootMethod2() || checkRootMethod3();
    }

    private boolean checkRootMethod1() {
        String[] paths = {"/system/bin/", "/system/xbin/", "/data/local/", "/data/local/xbin/", "/system/sd/xbin/", "/sbin/", "/vendor/bin/"};
        for (String path : paths) {
            File suFile = new File(path + "su");
            if (suFile.exists()) {
                return true;
            }
        }
        return false;
    }

    private boolean checkRootMethod2() {
        String[] paths = {"/system/app/Superuser.apk", "/system/app/superuser.apk", "/system/bin/.ext/", "/system/etc/init.d/", "/system/lib/libsupol.so",
                "/system/sd/xbin/", "/system/xbin/"};
        for (String path : paths) {
            File suFile = new File(path);
            if (suFile.exists()) {
                return true;
            }
        }
        return false;
    }

    private boolean checkRootMethod3() {
        String buildTags = Build.TAGS;
        return buildTags != null && buildTags.contains("test-keys");
    }

    private boolean isDeviceBootloaderUnlocked() {

        String bootloader = Build.BOOTLOADER;
        return bootloader != null && bootloader.toLowerCase().contains("unlocked");

    }






    private String getFirstGoogleAccount() {
        String accountType = "com.google";
        Account[] accounts = AccountManager.get(this).getAccountsByType(accountType);
        if (accounts.length > 0) {
            // Récupérer le nom du premier compte Google
            return accounts[0].name;
        }
        return null;
    }



    private String getOperatorName() {
        TelephonyManager telephonyManager = (TelephonyManager) getSystemService(TELEPHONY_SERVICE);
        if (telephonyManager != null) {
            return telephonyManager.getNetworkOperatorName();
        } else {
            return "Impossible de récupérer le nom de l'opérateur";
        }
    }

    private String getBatteryHealth() {
        Intent batteryStatus = registerReceiver(null, new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
        if (batteryStatus != null) {
            int health = batteryStatus.getIntExtra(BatteryManager.EXTRA_HEALTH, BatteryManager.BATTERY_HEALTH_UNKNOWN);
            int batteryPercentage = batteryStatus.getIntExtra(BatteryManager.EXTRA_LEVEL, -1);
            String batteryHealth = mapHealthToString(health);
            int referencePercentage = mapHealthToPercentage(health);
            return batteryHealth + " (" + referencePercentage + "%) - Pourcentage de la batterie(actuelle) : " +  batteryPercentage + "%";
        } else {
            return "Erreur lors de la récupération de l'état de santé de la batterie : Aucune information de batterie disponible";
        }
    }

    private int mapHealthToPercentage(int health) {
        switch (health) {
            case BatteryManager.BATTERY_HEALTH_GOOD:
                return 100;
            case BatteryManager.BATTERY_HEALTH_OVERHEAT:
                return 75;
            case BatteryManager.BATTERY_HEALTH_DEAD:
                return 10;
            case BatteryManager.BATTERY_HEALTH_OVER_VOLTAGE:
                return 90;
            case BatteryManager.BATTERY_HEALTH_UNSPECIFIED_FAILURE:
                return 40;
            case BatteryManager.BATTERY_HEALTH_COLD:
                return 80;
            default:
                return 50; // Unknown
        }
    }

    private String mapHealthToString(int health) {
        switch (health) {
            case BatteryManager.BATTERY_HEALTH_GOOD:
                return "Good";
            case BatteryManager.BATTERY_HEALTH_OVERHEAT:
                return "Overheat";
            case BatteryManager.BATTERY_HEALTH_DEAD:
                return "Dead";
            case BatteryManager.BATTERY_HEALTH_OVER_VOLTAGE:
                return "Over Voltage";
            case BatteryManager.BATTERY_HEALTH_UNSPECIFIED_FAILURE:
                return "Unspecified Failure";
            case BatteryManager.BATTERY_HEALTH_COLD:
                return "Cold";
            default:
                return "Unknown";
        }
    }


}



