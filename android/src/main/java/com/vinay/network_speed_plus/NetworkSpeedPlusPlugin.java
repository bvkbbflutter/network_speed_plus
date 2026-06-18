package com.vinay.network_speed_plus;

import android.content.Context;
import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.EventChannel;

public class NetworkSpeedPlusPlugin implements FlutterPlugin, MethodCallHandler {
    private static final String METHOD_CHANNEL = "com.vinay.network_speed_plus/methods";
    private static final String EVENT_CHANNEL = "com.vinay.network_speed_plus/events";

    private MethodChannel methodChannel;
    private EventChannel eventChannel;
    private NetworkSpeedHandler speedHandler;
    private Context context;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        context = binding.getApplicationContext();
        
        methodChannel = new MethodChannel(binding.getBinaryMessenger(), METHOD_CHANNEL);
        methodChannel.setMethodCallHandler(this);

        eventChannel = new EventChannel(binding.getBinaryMessenger(), EVENT_CHANNEL);
        speedHandler = new NetworkSpeedHandler(context);
        eventChannel.setStreamHandler(speedHandler);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "startMonitoring":
                Boolean monitorTotalTraffic = call.argument("monitorTotalTraffic");
                Integer updateIntervalSeconds = call.argument("updateIntervalSeconds");
                if (monitorTotalTraffic != null && updateIntervalSeconds != null) {
                    speedHandler.startMonitoring(monitorTotalTraffic, updateIntervalSeconds);
                    result.success(true);
                } else {
                    result.error("INVALID_ARGS", "Missing arguments", null);
                }
                break;

            case "stopMonitoring":
                speedHandler.stopMonitoring();
                result.success(true);
                break;

            case "isMonitoring":
                result.success(speedHandler.isMonitoring());
                break;

            case "getMonitoringMode":
                result.success(speedHandler.getMonitoringMode());
                break;

            case "getUpdateInterval":
                result.success(speedHandler.getUpdateInterval());
                break;

            case "setUpdateInterval":
                Integer seconds = call.arguments();
                if (seconds != null) {
                    speedHandler.setUpdateInterval(seconds);
                    result.success(true);
                } else {
                    result.error("INVALID_ARGS", "Missing seconds argument", null);
                }
                break;

            case "dispose":
                speedHandler.dispose();
                result.success(true);
                break;

            default:
                result.notImplemented();
                break;
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        if (methodChannel != null) {
            methodChannel.setMethodCallHandler(null);
            methodChannel = null;
        }
        if (eventChannel != null) {
            eventChannel.setStreamHandler(null);
            eventChannel = null;
        }
        if (speedHandler != null) {
            speedHandler.dispose();
            speedHandler = null;
        }
        context = null;
    }
}

// import io.flutter.embedding.engine.plugins.FlutterPlugin;
// import io.flutter.plugin.common.MethodCall;
// import io.flutter.plugin.common.MethodChannel;
// import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
// import io.flutter.plugin.common.MethodChannel.Result;
// import io.flutter.plugin.common.EventChannel;
// import io.flutter.plugin.common.PluginRegistry.Registrar;

// public class NetworkSpeedPlusPlugin implements FlutterPlugin, MethodCallHandler {
//   private static final String METHOD_CHANNEL = "com.vinay.network_speed_plus/methods";
//   private static final String EVENT_CHANNEL = "com.vinay.network_speed_plus/events";

//   private MethodChannel methodChannel;
//   private EventChannel eventChannel;
//   private NetworkSpeedHandler speedHandler;
//   private Context context;

//   @Override
//   public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
//     context = binding.getApplicationContext();

//     methodChannel = new MethodChannel(binding.getBinaryMessenger(), METHOD_CHANNEL);
//     methodChannel.setMethodCallHandler(this);

//     eventChannel = new EventChannel(binding.getBinaryMessenger(), EVENT_CHANNEL);
//     speedHandler = new NetworkSpeedHandler(context);
//     eventChannel.setStreamHandler(speedHandler);
//   }

//   @Override
//   public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
//     switch (call.method) {
//       case "startMonitoring":
//         boolean monitorTotalTraffic = call.argument("monitorTotalTraffic");
//         int updateIntervalSeconds = call.argument("updateIntervalSeconds");
//         speedHandler.startMonitoring(monitorTotalTraffic, updateIntervalSeconds);
//         result.success(true);
//         break;

//       case "stopMonitoring":
//         speedHandler.stopMonitoring();
//         result.success(true);
//         break;

//       case "isMonitoring":
//         result.success(speedHandler.isMonitoring());
//         break;

//       case "getMonitoringMode":
//         result.success(speedHandler.getMonitoringMode());
//         break;

//       case "getUpdateInterval":
//         result.success(speedHandler.getUpdateInterval());
//         break;

//       case "setUpdateInterval":
//         int seconds = call.arguments();
//         speedHandler.setUpdateInterval(seconds);
//         result.success(true);
//         break;

//       case "dispose":
//         speedHandler.dispose();
//         result.success(true);
//         break;

//       default:
//         result.notImplemented();
//         break;
//     }
//   }

//   @Override
//   public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
//     if (methodChannel != null) {
//       methodChannel.setMethodCallHandler(null);
//       methodChannel = null;
//     }
//     if (eventChannel != null) {
//       eventChannel.setStreamHandler(null);
//       eventChannel = null;
//     }
//     if (speedHandler != null) {
//       speedHandler.dispose();
//       speedHandler = null;
//     }
//     context = null;
//   }
// }