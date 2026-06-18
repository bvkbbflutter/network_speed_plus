package com.vinay.network_speed_plus;

import android.content.Context;
import android.net.TrafficStats;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicLong;

import io.flutter.plugin.common.EventChannel;

public class NetworkSpeedHandler implements EventChannel.StreamHandler {
    private static final String TAG = "NetworkSpeedPlus";

    private final Context context;
    private ScheduledExecutorService scheduler;
    private Handler mainHandler;
    private AtomicLong previousRxBytes = new AtomicLong(0);
    private AtomicLong previousTxBytes = new AtomicLong(0);
    private AtomicBoolean isRunning = new AtomicBoolean(false);
    private AtomicBoolean isMonitoring = new AtomicBoolean(false);
    private int appUid = -1;
    private boolean monitorTotalTraffic = true;
    private int updateIntervalSeconds = 3;

    private EventChannel.EventSink eventSink;

    public NetworkSpeedHandler(Context context) {
        this.context = context;
        appUid = android.os.Process.myUid();
        mainHandler = new Handler(Looper.getMainLooper());
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        eventSink = events;
        startMonitoring(true, 3);
    }

    @Override
    public void onCancel(Object arguments) {
        stopMonitoring();
        eventSink = null;
    }

    public void startMonitoring(boolean monitorTotal, int updateInterval) {
        this.monitorTotalTraffic = monitorTotal;
        this.updateIntervalSeconds = updateInterval;

        if (isRunning.get()) {
            stopMonitoring();
        }

        // Initialize with current values
        if (monitorTotalTraffic) {
            long totalRx = TrafficStats.getTotalRxBytes();
            long totalTx = TrafficStats.getTotalTxBytes();
            if (totalRx != TrafficStats.UNSUPPORTED) {
                previousRxBytes.set(totalRx);
            }
            if (totalTx != TrafficStats.UNSUPPORTED) {
                previousTxBytes.set(totalTx);
            }
        } else {
            long uidRx = TrafficStats.getUidRxBytes(appUid);
            long uidTx = TrafficStats.getUidTxBytes(appUid);
            if (uidRx != TrafficStats.UNSUPPORTED) {
                previousRxBytes.set(uidRx);
            }
            if (uidTx != TrafficStats.UNSUPPORTED) {
                previousTxBytes.set(uidTx);
            }
        }

        scheduler = Executors.newSingleThreadScheduledExecutor();
        isRunning.set(true);
        isMonitoring.set(true);

        scheduler.scheduleAtFixedRate(new Runnable() {
            @Override
            public void run() {
                if (!isRunning.get()) return;

                long currentRxBytes;
                long currentTxBytes;

                if (monitorTotalTraffic) {
                    currentRxBytes = TrafficStats.getTotalRxBytes();
                    currentTxBytes = TrafficStats.getTotalTxBytes();
                } else {
                    currentRxBytes = TrafficStats.getUidRxBytes(appUid);
                    currentTxBytes = TrafficStats.getUidTxBytes(appUid);
                }

                // Handle UNSUPPORTED case
                if (currentRxBytes == TrafficStats.UNSUPPORTED || 
                    currentTxBytes == TrafficStats.UNSUPPORTED) {
                    return;
                }

                final double downloadSpeed = Math.max(0, 
                    (currentRxBytes - previousRxBytes.get()) / 1024.0);
                final double uploadSpeed = Math.max(0, 
                    (currentTxBytes - previousTxBytes.get()) / 1024.0);

                previousRxBytes.set(currentRxBytes);
                previousTxBytes.set(currentTxBytes);

                mainHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        if (eventSink != null) {
                            Map<String, Object> data = new HashMap<>();
                            data.put("downloadSpeed", downloadSpeed);
                            data.put("uploadSpeed", uploadSpeed);
                            data.put("timestamp", System.currentTimeMillis());
                            data.put("monitorType", monitorTotalTraffic ? "total" : "app");
                            eventSink.success(data);
                        }
                    }
                });
            }
        }, 0, updateIntervalSeconds, TimeUnit.SECONDS);

        Log.d(TAG, "Started monitoring: " + (monitorTotalTraffic ? "Total" : "App") + 
              " traffic with " + updateIntervalSeconds + "s interval");
    }

    public void stopMonitoring() {
        isRunning.set(false);
        isMonitoring.set(false);
        if (scheduler != null && !scheduler.isShutdown()) {
            scheduler.shutdown();
            scheduler = null;
        }
        Log.d(TAG, "Monitoring stopped");
    }

    public void setUpdateInterval(int seconds) {
        this.updateIntervalSeconds = seconds;
        if (isRunning.get()) {
            // Restart with new interval
            boolean wasMonitoring = monitorTotalTraffic;
            stopMonitoring();
            // Small delay to ensure cleanup
            try {
                Thread.sleep(100);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
            startMonitoring(wasMonitoring, seconds);
        }
    }

    public boolean isMonitoring() {
        return isMonitoring.get();
    }

    public String getMonitoringMode() {
        return monitorTotalTraffic ? "total" : "app";
    }

    public int getUpdateInterval() {
        return updateIntervalSeconds;
    }

    public void dispose() {
        stopMonitoring();
        if (mainHandler != null) {
            mainHandler.removeCallbacksAndMessages(null);
            mainHandler = null;
        }
        eventSink = null;
    }
}

// package com.vinay.network_speed_plus;

// import android.content.Context;
// import android.net.TrafficStats;
// import android.os.Handler;
// import android.os.Looper;
// import android.util.Log;

// import java.util.HashMap;
// import java.util.Map;
// import java.util.concurrent.Executors;
// import java.util.concurrent.ScheduledExecutorService;
// import java.util.concurrent.TimeUnit;
// import java.util.concurrent.atomic.AtomicBoolean;
// import java.util.concurrent.atomic.AtomicLong;

// import io.flutter.plugin.common.EventChannel;

// public class NetworkSpeedHandler implements EventChannel.StreamHandler {
//     private static final String TAG = "NetworkSpeedPlus";

//     private final Context context;
//     private ScheduledExecutorService scheduler;
//     private Handler mainHandler;
//     private AtomicLong previousRxBytes = new AtomicLong(0);
//     private AtomicLong previousTxBytes = new AtomicLong(0);
//     private AtomicBoolean isRunning = new AtomicBoolean(false);
//     private AtomicBoolean isMonitoring = new AtomicBoolean(false);
//     private int appUid = -1;
//     private boolean monitorTotalTraffic = true;
//     private int updateIntervalSeconds = 3;

//     private EventChannel.EventSink eventSink;

//     public NetworkSpeedHandler(Context context) {
//         this.context = context;
//         appUid = android.os.Process.myUid();
//         mainHandler = new Handler(Looper.getMainLooper());
//     }

//     @Override
//     public void onListen(Object arguments, EventChannel.EventSink events) {
//         eventSink = events;
//         startMonitoring(true, 3);
//     }

//     @Override
//     public void onCancel(Object arguments) {
//         stopMonitoring();
//         eventSink = null;
//     }

//     public void startMonitoring(boolean monitorTotal, int updateInterval) {
//         this.monitorTotalTraffic = monitorTotal;
//         this.updateIntervalSeconds = updateInterval;

//         if (isRunning.get()) {
//             stopMonitoring();
//         }

//         if (monitorTotalTraffic) {
//             previousRxBytes.set(TrafficStats.getTotalRxBytes());
//             previousTxBytes.set(TrafficStats.getTotalTxBytes());
//         } else {
//             previousRxBytes.set(TrafficStats.getUidRxBytes(appUid));
//             previousTxBytes.set(TrafficStats.getUidTxBytes(appUid));
//         }

//         scheduler = Executors.newSingleThreadScheduledExecutor();
//         isRunning.set(true);
//         isMonitoring.set(true);

//         scheduler.scheduleAtFixedRate(new Runnable() {
//             @Override
//             public void run() {
//                 if (!isRunning.get()) return;

//                 long currentRxBytes;
//                 long currentTxBytes;

//                 if (monitorTotalTraffic) {
//                     currentRxBytes = TrafficStats.getTotalRxBytes();
//                     currentTxBytes = TrafficStats.getTotalTxBytes();
//                 } else {
//                     currentRxBytes = TrafficStats.getUidRxBytes(appUid);
//                     currentTxBytes = TrafficStats.getUidTxBytes(appUid);
//                 }

//                 final double downloadSpeed = Math.max(0,
//                         (currentRxBytes - previousRxBytes.get()) / 1024.0);
//                 final double uploadSpeed = Math.max(0,
//                         (currentTxBytes - previousTxBytes.get()) / 1024.0);

//                 previousRxBytes.set(currentRxBytes);
//                 previousTxBytes.set(currentTxBytes);

//                 mainHandler.post(new Runnable() {
//                     @Override
//                     public void run() {
//                         if (eventSink != null) {
//                             Map<String, Object> data = new HashMap<>();
//                             data.put("downloadSpeed", downloadSpeed);
//                             data.put("uploadSpeed", uploadSpeed);
//                             data.put("timestamp", System.currentTimeMillis());
//                             data.put("monitorType", monitorTotalTraffic ? "total" : "app");
//                             eventSink.success(data);
//                         }
//                     }
//                 });
//             }
//         }, 0, updateIntervalSeconds, TimeUnit.SECONDS);

//         Log.d(TAG, "Started monitoring: " + (monitorTotalTraffic ? "Total" : "App") +
//                 " traffic with " + updateIntervalSeconds + "s interval");
//     }

//     public void stopMonitoring() {
//         isRunning.set(false);
//         isMonitoring.set(false);
//         if (scheduler != null && !scheduler.isShutdown()) {
//             scheduler.shutdown();
//             scheduler = null;
//         }
//         Log.d(TAG, "Monitoring stopped");
//     }

//     public void setUpdateInterval(int seconds) {
//         this.updateIntervalSeconds = seconds;
//         if (isRunning.get()) {
//             stopMonitoring();
//             startMonitoring(monitorTotalTraffic, seconds);
//         }
//     }

//     public boolean isMonitoring() {
//         return isMonitoring.get();
//     }

//     public String getMonitoringMode() {
//         return monitorTotalTraffic ? "total" : "app";
//     }

//     public int getUpdateInterval() {
//         return updateIntervalSeconds;
//     }

//     public void dispose() {
//         stopMonitoring();
//         if (mainHandler != null) {
//             mainHandler.removeCallbacksAndMessages(null);
//             mainHandler = null;
//         }
//         eventSink = null;
//     }
// }