package com.leoliang.android.LadderAssist;

import androidx.annotation.NonNull;
import androidx.core.content.FileProvider;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.module.annotations.ReactModule;

import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;

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

    @ReactMethod
    public void isPermissionGranted(Promise promise) {
        boolean allow = true;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            allow = reactContext.getPackageManager().canRequestPackageInstalls();
        } else {
            try {
                allow = Settings.Secure.getInt(
                        reactContext.getContentResolver(),
                        Settings.Secure.INSTALL_NON_MARKET_APPS
                ) == 1;
            } catch (Settings.SettingNotFoundException e) {
                e.printStackTrace();
            }
        }
        promise.resolve(allow);
    }

    @ReactMethod
    public void requestPermission() {
        Intent i;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            i = new Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                    Uri.parse("package:" + reactContext.getPackageName()));
        } else {
            i = new Intent(Settings.ACTION_SECURITY_SETTINGS);
        }
        i.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        reactContext.startActivity(i);
    }
}
