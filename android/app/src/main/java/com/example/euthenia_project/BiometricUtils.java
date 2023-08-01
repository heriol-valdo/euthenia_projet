package com.example.euthenia_project;
// BiometricUtils.java


import android.content.Context;
import android.content.pm.PackageManager;
import androidx.biometric.BiometricManager;

public class BiometricUtils {

    // Vérifie si l'appareil prend en charge l'authentification biométrique (empreintes digitales)
    public static boolean isBiometricSupported(Context context) {
        BiometricManager biometricManager = BiometricManager.from(context);
        int canAuthenticate = biometricManager.canAuthenticate();

        return canAuthenticate == BiometricManager.BIOMETRIC_SUCCESS;
    }



    // Vérifie si l'appareil prend en charge l'authentification biométrique (Face ID)
    public static boolean isFaceIdSupported(Context context) {
        // Vérifie si l'appareil prend en charge le matériel de reconnaissance faciale
        return context.getPackageManager().hasSystemFeature(PackageManager.FEATURE_FACE);
    }

    // Vérifie si l'appareil prend en charge l'authentification biométrique (Touch ID)
    public static boolean isTouchIdSupported(Context context) {
        // Vérifie si l'appareil prend en charge le matériel d'empreintes digitales
        return context.getPackageManager().hasSystemFeature(PackageManager.FEATURE_FINGERPRINT);
    }
}
