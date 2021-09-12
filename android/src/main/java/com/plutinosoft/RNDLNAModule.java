// RNDLNAModule.java

package com.plutinosoft;

import android.app.Activity;
import android.content.Intent;

import androidx.annotation.Nullable;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
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

public class RNDLNAModule extends ReactContextBaseJavaModule {
    private Activity activity;
    private final ReactApplicationContext reactContext;

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
        activity = getCurrentActivity();
        Intent intent = new Intent(activity, DLNAService.class);
        intent.putExtra(DLNAService.EXTRA_SERVER_PARAMS, new ServerParams(friendlyName, false, UUIDUtils.getRandomUUID()));
        activity.startService(intent);
    }

    @ReactMethod
    public void stopDLNAService() {
        if (activity == null) {
            return;
        }
        Intent intent = new Intent(activity, DLNAService.class);
        activity.stopService(intent);
    }

    @SuppressWarnings("UnusedDeclaration")
    @Subscribe(threadMode = ThreadMode.MAIN_ORDERED)
    public void onServerStateChange(ServerStateEvent event) {
        ServerInstance.State state = event.getState();
        sendEvent("DlnaStateChange", state);
    }

    @SuppressWarnings("UnusedDeclaration")
    @Subscribe(threadMode = ThreadMode.MAIN_ORDERED)
    public void onNativeAsync(NativeAsyncEvent event) {
        sendEvent("DlnaMediaInfo",  event.mediaInfo);
    }

    private void sendEvent(String eventName, @Nullable Object data) {
        reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit(eventName, data);
    }
}
