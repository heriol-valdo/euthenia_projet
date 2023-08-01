package com.example.euthenia_project;

import android.app.ActivityManager;
import android.content.Context;
import android.os.BatteryManager;
import android.os.Build;

public class MemoryInfoPlugin {
    private static Context context;

    public MemoryInfoPlugin(Context context) {
        this.context = context;
    }

    public long getTotalRAM() {
        ActivityManager activityManager = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
        ActivityManager.MemoryInfo memoryInfo = new ActivityManager.MemoryInfo();
        if (activityManager != null) {
            activityManager.getMemoryInfo(memoryInfo);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
                return memoryInfo.totalMem;
            } else {
                // For older versions of Android (before API 16), use deprecated method
                return getTotalRAMDeprecated();
            }
        }
        return 0;
    }

    // Deprecated method for getting total RAM (used for Android versions before API 16)
    private long getTotalRAMDeprecated() {
        // The method below returns the total RAM in bytes
        // You can convert it to GB or MB as needed
        return Runtime.getRuntime().totalMemory();
    }

    // Dans la classe MemoryInfoPlugin





}
