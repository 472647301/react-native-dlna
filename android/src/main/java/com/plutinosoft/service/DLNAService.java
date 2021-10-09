package com.plutinosoft.service;

import android.annotation.SuppressLint;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.os.IBinder;

import androidx.annotation.RequiresApi;
import androidx.core.app.NotificationCompat;

import com.plutinosoft.event.NativeAsyncEvent;
import com.plutinosoft.instance.ServerInstance;
import com.plutinosoft.platinum.ServerParams;

import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

/**
 * Created by huzongyao on 2018/6/7.
 * The service that manage the server instance
 */

public class DLNAService extends Service {

    public static final String EXTRA_SERVER_PARAMS = "EXTRA_SERVER_PARAMS";

    private static final String TAG = "DLNAService";
    private WifiManager.MulticastLock mMulticastLock;
    private Notification mNotification;

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @RequiresApi(api = Build.VERSION_CODES.O)
    @SuppressLint("ObsoleteSdkInt")
    @Override
    public void onCreate() {
        super.onCreate();
        acquireMulticastLock();
        EventBus.getDefault().register(this);
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.JELLY_BEAN_MR2) {
            startForeground(1, new Notification());
        } else {
            String NOTIFICATION_CHANNEL_ID = "com.plutinosoft.service";
            String channelName = "DLNA Background Service";
            NotificationChannel chan = new NotificationChannel(NOTIFICATION_CHANNEL_ID, channelName, NotificationManager.IMPORTANCE_NONE);
            chan.setLightColor(Color.BLUE);
            chan.setLockscreenVisibility(Notification.VISIBILITY_PRIVATE);
            NotificationManager manager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
            assert manager != null;
            manager.createNotificationChannel(chan);

            NotificationCompat.Builder notificationBuilder = new NotificationCompat.Builder(this, NOTIFICATION_CHANNEL_ID);
            Notification notification = notificationBuilder.setOngoing(true)
                .setContentTitle("App is running in background")
                .setPriority(NotificationManager.IMPORTANCE_MIN)
                .setCategory(Notification.CATEGORY_SERVICE)
                .build();
            startForeground(2, notification);
        }
    }

    private void acquireMulticastLock() {
        WifiManager wifiManager = (WifiManager)
                getApplicationContext().getSystemService(Context.WIFI_SERVICE);
        if (wifiManager != null) {
            mMulticastLock = wifiManager.createMulticastLock(TAG);
            mMulticastLock.acquire();
        }
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (intent != null) {
            ServerParams params = intent.getParcelableExtra(EXTRA_SERVER_PARAMS);
            if (params != null) {
                ServerInstance.INSTANCE.start(params);
            }
        }
        return super.onStartCommand(intent, flags, startId);
    }

    @SuppressWarnings("UnusedDeclaration")
    @Subscribe(threadMode = ThreadMode.MAIN_ORDERED)
    public void onServerStateChange(NativeAsyncEvent event) {

    }

    @Override
    public void onDestroy() {
        if (mMulticastLock != null) {
            mMulticastLock.release();
            mMulticastLock = null;
        }
        EventBus.getDefault().unregister(this);
        ServerInstance.INSTANCE.stop();
        super.onDestroy();
    }
}
