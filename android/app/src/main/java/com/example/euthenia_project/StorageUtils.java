package com.example.euthenia_project;

import android.os.Environment;

import java.io.File;

public class StorageUtils {
    public static long getTotalInternalStorage() {
        File internalStorage = Environment.getDataDirectory();
        return internalStorage.getTotalSpace();
    }
}
