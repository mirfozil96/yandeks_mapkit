package com.example.yandeks_mapkit

import android.app.Application
import com.yandex.mapkit.MapKitFactory;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        MapKitFactory.setApiKey("5d6635a4-578e-47dd-b911-7221fe7c81d2")
        super.configureFlutterEngine(flutterEngine)
    }
}