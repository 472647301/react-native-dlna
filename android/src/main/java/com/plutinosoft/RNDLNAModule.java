// RNDLNAModule.java

package com.plutinosoft;

import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;

import androidx.annotation.Nullable;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.plutinosoft.event.NativeAsyncEvent;
import com.plutinosoft.event.ServerStateEvent;
import com.plutinosoft.instance.ServerInstance;
import com.plutinosoft.platinum.ServerParams;
import com.plutinosoft.service.DLNAService;
import com.plutinosoft.utils.UUIDUtils;

import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.util.List;

public class RNDLNAModule extends ReactContextBaseJavaModule {
    private final ReactApplicationContext reactContext;
    private volatile ServerInstance.State mState;

    public RNDLNAModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
        EventBus.getDefault().register(this);
    }

    @Override
    public String getName() {
        return "RNDLNA";
    }

    @ReactMethod
    public void startDLNAService(String friendlyName) {
        Intent intent = new Intent(reactContext, DLNAService.class);
        intent.putExtra(DLNAService.EXTRA_SERVER_PARAMS, new ServerParams(friendlyName, false, UUIDUtils.getRandomUUID()));
        reactContext.startService(intent);
    }

    @ReactMethod
    public void stopDLNAService() {
        Intent intent = new Intent(reactContext, DLNAService.class);
        reactContext.stopService(intent);
    }

    @ReactMethod
    public void getDLNAState(Promise promise) {
        promise.resolve(mState.toString());
    }

    @ReactMethod
    public void getAllApps(Promise promise) {
        WritableMap params = Arguments.createMap();
        // 获取已经安装的所有应用, PackageInfo　系统类，包含应用信息
        List<PackageInfo> packages = reactContext.getPackageManager().getInstalledPackages(0);
        for (int i = 0; i < packages.size(); i++) {
            PackageInfo packageInfo = packages.get(i);
            if ((packageInfo.applicationInfo.flags & ApplicationInfo.FLAG_SYSTEM) == 0) { //非系统应用
                String appName = packageInfo.applicationInfo.loadLabel(reactContext.getPackageManager()).toString();
                params.putString(packageInfo.packageName, appName);
            }
        }
        promise.resolve(params);
    }

    @ReactMethod
    public void startApp(String packageName) {
        PackageManager packageManager = reactContext.getPackageManager();
        Intent intent = packageManager.getLaunchIntentForPackage(packageName);
        reactContext.startActivity(intent);
    }

    @SuppressWarnings("UnusedDeclaration")
    @Subscribe(threadMode = ThreadMode.MAIN_ORDERED)
    public void onServerStateChange(ServerStateEvent event) {
        ServerInstance.State state = event.getState();
        mState = state;
        WritableMap params = Arguments.createMap();
        params.putString("state", state.toString());
        sendEvent("DlnaStateChange", params);
    }

    @SuppressWarnings("UnusedDeclaration")
    @Subscribe(threadMode = ThreadMode.MAIN_ORDERED)
    public void onNativeAsync(NativeAsyncEvent event) {
        WritableMap params = Arguments.createMap();
        params.putString("url", event.mediaInfo.url);
        params.putString("title", event.mediaInfo.title);
        params.putString("mediaType", event.mediaInfo.mediaType.toString());
        params.putString("albumArtURI", event.mediaInfo.albumArtURI);
        sendEvent("DlnaMediaInfo",  params);
    }

    private void sendEvent(String eventName, @Nullable Object data) {
        reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit(eventName, data);
    }
}
