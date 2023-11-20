package com.leoliang.android.LadderAssist;

import androidx.annotation.NonNull;
import androidx.core.content.FileProvider;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.module.annotations.ReactModule;

import android.content.Intent;
import android.net.Uri;

import java.io.File;

@ReactModule(name = LadderAssistApkInstallerModule.NAME)
public class LadderAssistApkInstallerModule extends ReactContextBaseJavaModule {
    public static final String NAME = "LadderAssistApkInstaller";
    private final ReactApplicationContext reactContext;

    public LadderAssistApkInstallerModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @NonNull
    @Override
    public String getName() {
        return NAME;
    }

    @ReactMethod
    public void installApp(String path) {
        File file = new File(reactContext.getCacheDir(), path);
        Uri data = FileProvider
                .getUriForFile(reactContext, BuildConfig.APPLICATION_ID + ".provider", file);
        Intent promptInstall = new Intent(Intent.ACTION_VIEW)
                .setDataAndType(data, "application/vnd.android.package-archive")
                .setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_GRANT_READ_URI_PERMISSION);
        reactContext.startActivity(promptInstall);
    }
}
