package com.example.euthenia_project;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;

import android.media.AudioManager;
import android.os.Build;
import android.view.KeyEvent;

import androidx.annotation.NonNull;

import io.flutter.plugin.common.EventChannel;

import android.content.Context;
import android.content.pm.PackageManager;
import androidx.biometric.BiometricManager;

public class VolumeChangeStreamHandler implements EventChannel.StreamHandler {


    private final Context context;
    private final BroadcastReceiver volumeReceiver;
    private EventChannel.EventSink eventSink;

    VolumeChangeStreamHandler(Context context) {
        this.context = context;
        volumeReceiver = createVolumeReceiver();
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        eventSink = events;
        context.registerReceiver(volumeReceiver, new IntentFilter("android.media.VOLUME_CHANGED_ACTION"));
        context.registerReceiver(volumeReceiver, new IntentFilter("android.media.RINGER_MODE_CHANGED"));
    }

    @Override
    public void onCancel(Object arguments) {
        context.unregisterReceiver(volumeReceiver);
    }

    private BroadcastReceiver createVolumeReceiver() {
        return new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                String action = intent.getAction();
                if (action != null) {
                    if (action.equals("android.media.VOLUME_CHANGED_ACTION")) {
                        int volume = intent.getIntExtra("android.media.EXTRA_VOLUME_STREAM_VALUE", -1);
                        int oldVolume = intent.getIntExtra("android.media.EXTRA_PREV_VOLUME_STREAM_VALUE", -1);

                        // Comparez volume et oldVolume pour déterminer si le volume a augmenté ou diminué
                        if (volume > oldVolume) {
                            // Le volume a augmenté
                            if (eventSink != null) {
                                eventSink.success("increase");
                            }
                        } else if (volume < oldVolume) {
                            // Le volume a diminué
                            if (eventSink != null) {
                                eventSink.success("decrease");
                            }
                        }
                    } else if (action.equals("android.media.RINGER_MODE_CHANGED")) {
                        // Le mode de sonnerie a changé
                        int mode = intent.getIntExtra("android.media.EXTRA_RINGER_MODE", -1);
                        if (mode == AudioManager.RINGER_MODE_VIBRATE) {
                            // Le téléphone est en mode vibreur
                            if (eventSink != null) {
                                eventSink.success("vibrate");
                            }
                        }
                    }else if (action.equals("android.intent.action.MEDIA_BUTTON")) {
                        KeyEvent event = intent.getParcelableExtra(Intent.EXTRA_KEY_EVENT);
                        if (event != null && event.getKeyCode() == KeyEvent.KEYCODE_HEADSETHOOK) {
                            // Le bouton central a été pressé
                            if (eventSink != null) {
                                eventSink.success("centralButton");
                            }
                        }
                    }

                }
            }
        };
    }
}
