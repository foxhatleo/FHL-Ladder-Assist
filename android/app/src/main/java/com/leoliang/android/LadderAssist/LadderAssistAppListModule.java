package com.leoliang.android.LadderAssist;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;
import com.facebook.react.module.annotations.ReactModule;

import android.content.pm.PackageInfo;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;

import java.util.List;

@ReactModule(name = LadderAssistAppListModule.NAME)
public class LadderAssistAppListModule extends ReactContextBaseJavaModule {
    public static final String NAME = "LadderAssistAppList";
    private final ReactApplicationContext reactContext;

    public LadderAssistAppListModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @NonNull
    @Override
    public String getName() {
        return NAME;
    }

    @ReactMethod
    public void getVersion(String packageName, Promise promise) {
        try {
            PackageInfo info = this.reactContext
                    .getPackageManager()
                    .getPackageInfo(packageName, 0);
            promise.resolve(info.versionCode);
        } catch (PackageManager.NameNotFoundException e) {
            promise.resolve(-1);
        }

    }
}
