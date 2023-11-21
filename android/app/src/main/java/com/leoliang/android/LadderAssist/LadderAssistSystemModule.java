package com.leoliang.android.LadderAssist;

import android.content.ComponentName;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;

import androidx.annotation.NonNull;
import androidx.core.content.FileProvider;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.module.annotations.ReactModule;

import java.io.File;

@ReactModule(name = LadderAssistSystemModule.NAME)
public class LadderAssistSystemModule extends ReactContextBaseJavaModule {
    public static final String NAME = "LadderAssistSystem";
    private final ReactApplicationContext reactContext;

    public LadderAssistSystemModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @NonNull
    @Override
    public String getName() {
        return NAME;
    }

    @ReactMethod
    public void restart() {
        PackageManager packageManager = reactContext.getPackageManager();
        Intent intent = packageManager.getLaunchIntentForPackage(reactContext.getPackageName());
        ComponentName componentName = intent.getComponent();
        Intent mainIntent = Intent.makeRestartActivityTask(componentName);
        // Required for API 34 and later
        // Ref: https://developer.android.com/about/versions/14/behavior-changes-14#safer-intents
        mainIntent.setPackage(reactContext.getPackageName());
        reactContext.startActivity(mainIntent);
        Runtime.getRuntime().exit(0);
    }
}
