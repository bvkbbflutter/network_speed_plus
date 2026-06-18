import Flutter
import UIKit

import Flutter
import UIKit
import Network

public class NetworkSpeedPlusPlugin: NSObject, FlutterPlugin {
    private static let METHOD_CHANNEL = "com.vinay.network_speed_plus/methods"
    private static let EVENT_CHANNEL = "com.vinay.network_speed_plus/events"

    private var methodChannel: FlutterMethodChannel?
    private var eventChannel: FlutterEventChannel?
    private var speedHandler: NetworkSpeedHandler?
    private var eventSink: FlutterEventSink?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(
            name: METHOD_CHANNEL,
            binaryMessenger: registrar.messenger()
        )
        let eventChannel = FlutterEventChannel(
            name: EVENT_CHANNEL,
            binaryMessenger: registrar.messenger()
        )
        let instance = NetworkSpeedPlusPlugin()
        instance.methodChannel = methodChannel
        instance.eventChannel = eventChannel
        instance.speedHandler = NetworkSpeedHandler()

        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        eventChannel.setStreamHandler(instance.speedHandler)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startMonitoring":
            guard let args = call.arguments as? [String: Any],
                  let monitorTotal = args["monitorTotalTraffic"] as? Bool,
                  let interval = args["updateIntervalSeconds"] as? Int else {
                result(FlutterError(code: "INVALID_ARGS",
                                   message: "Invalid arguments",
                                   details: nil))
                return
            }
            speedHandler?.startMonitoring(
                monitorTotalTraffic: monitorTotal,
                updateIntervalSeconds: interval
            )
            result(true)

        case "stopMonitoring":
            speedHandler?.stopMonitoring()
            result(true)

        case "isMonitoring":
            result(speedHandler?.isMonitoring() ?? false)

        case "getMonitoringMode":
            result(speedHandler?.getMonitoringMode() ?? "total")

        case "getUpdateInterval":
            result(speedHandler?.getUpdateInterval() ?? 3)

        case "setUpdateInterval":
            guard let seconds = call.arguments as? Int else {
                result(FlutterError(code: "INVALID_ARGS",
                                   message: "Invalid arguments",
                                   details: nil))
                return
            }
            speedHandler?.setUpdateInterval(seconds)
            result(true)

        case "dispose":
            speedHandler?.dispose()
            result(true)

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}


// public class NetworkSpeedPlusPlugin: NSObject, FlutterPlugin {
//   public static func register(with registrar: FlutterPluginRegistrar) {
//     let channel = FlutterMethodChannel(name: "network_speed_plus", binaryMessenger: registrar.messenger())
//     let instance = NetworkSpeedPlusPlugin()
//     registrar.addMethodCallDelegate(instance, channel: channel)
//   }
//
//   public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//     switch call.method {
//     case "getPlatformVersion":
//       result("iOS " + UIDevice.current.systemVersion)
//     default:
//       result(FlutterMethodNotImplemented)
//     }
//   }
// }
