import Flutter
import UIKit
import Network

class NetworkSpeedHandler: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private var timer: Timer?
    private var previousRxBytes: UInt64 = 0
    private var previousTxBytes: UInt64 = 0
    private var isMonitoringActive = false
    private var monitorTotalTraffic = true
    private var updateIntervalSeconds = 3

    func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        startMonitoring(monitorTotalTraffic: true, updateIntervalSeconds: 3)
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        stopMonitoring()
        eventSink = nil
        return nil
    }

    func startMonitoring(monitorTotalTraffic: Bool, updateIntervalSeconds: Int) {
        self.monitorTotalTraffic = monitorTotalTraffic
        self.updateIntervalSeconds = updateIntervalSeconds

        stopMonitoring()

        // iOS network monitoring
        monitorNetworkTraffic()
    }

    private func monitorNetworkTraffic() {
        isMonitoringActive = true

        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            // Simplified speed data for iOS
            self.sendSpeedData(download: 0, upload: 0)
        }
        monitor.start(queue: .main)

        timer = Timer.scheduledTimer(
            withTimeInterval: TimeInterval(updateIntervalSeconds),
            repeats: true
        ) { [weak self] _ in
            // For demo - in production use actual iOS network APIs
            let download = Double.random(in: 100...500)
            let upload = Double.random(in: 50...200)
            self?.sendSpeedData(download: download, upload: upload)
        }
    }

    private func sendSpeedData(download: Double, upload: Double) {
        guard let eventSink = eventSink else { return }

        let data: [String: Any] = [
            "downloadSpeed": download,
            "uploadSpeed": upload,
            "timestamp": Int(Date().timeIntervalSince1970 * 1000),
            "monitorType": monitorTotalTraffic ? "total" : "app"
        ]

        eventSink(data)
    }

    func stopMonitoring() {
        isMonitoringActive = false
        timer?.invalidate()
        timer = nil
    }

    func setUpdateInterval(_ seconds: Int) {
        updateIntervalSeconds = seconds
        if isMonitoringActive {
            stopMonitoring()
            startMonitoring(
                monitorTotalTraffic: monitorTotalTraffic,
                updateIntervalSeconds: seconds
            )
        }
    }

    func isMonitoring() -> Bool {
        return isMonitoringActive
    }

    func getMonitoringMode() -> String {
        return monitorTotalTraffic ? "total" : "app"
    }

    func getUpdateInterval() -> Int {
        return updateIntervalSeconds
    }

    func dispose() {
        stopMonitoring()
        eventSink = nil
    }
}