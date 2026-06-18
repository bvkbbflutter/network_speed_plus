library network_speed_plus;

export 'models/speed_data.dart';
export 'widgets/speed_display.dart';
export 'widgets/speed_overlay.dart';
export 'widgets/speed_controls.dart';
export 'widgets/speed_status.dart';

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'network_speed_plus_method_channel.dart';
import 'network_speed_plus_platform_interface.dart';
import 'models/speed_data.dart';

/// Main plugin class for monitoring network speed
class NetworkSpeedPlus {
  static final NetworkSpeedPlus _instance = NetworkSpeedPlus._internal();

  factory NetworkSpeedPlus() => _instance;

  NetworkSpeedPlus._internal() {
    _init();
  }

  // ValueNotifier for reactive updates
  final ValueNotifier<SpeedData?> speedData = ValueNotifier<SpeedData?>(null);
  final ValueNotifier<bool> isMonitoring = ValueNotifier<bool>(false);
  final ValueNotifier<String> monitoringMode = ValueNotifier<String>('total');
  final ValueNotifier<int> updateInterval = ValueNotifier<int>(3);

  final NetworkSpeedPlusPlatform _platform = NetworkSpeedPlusMethodChannel();
  StreamSubscription? _subscription;

  void _init() {
    _subscription = _platform.speedStream.listen(
      (data) {
        speedData.value = data;
        isMonitoring.value = true;
        monitoringMode.value = data.monitorType;
      },
      onError: (error) {
        debugPrint('NetworkSpeedPlus error: $error');
      },
    );
  }

  /// Start monitoring network speed
  ///
  /// [monitorTotalTraffic] - If true, monitors total device traffic.
  ///                         If false, monitors only the app's traffic.
  /// [updateIntervalSeconds] - How often to update (in seconds). Default is 3.
  Future<void> startMonitoring({
    bool monitorTotalTraffic = true,
    int updateIntervalSeconds = 3,
  }) async {
    await _platform.startMonitoring(
      monitorTotalTraffic: monitorTotalTraffic,
      updateIntervalSeconds: updateIntervalSeconds,
    );
    isMonitoring.value = true;
    monitoringMode.value = monitorTotalTraffic ? 'total' : 'app';
    updateInterval.value = updateIntervalSeconds;
  }

  /// Stop monitoring network speed
  Future<void> stopMonitoring() async {
    await _platform.stopMonitoring();
    isMonitoring.value = false;
  }

  /// Check if monitoring is active
  Future<bool> checkIsMonitoring() async {
    final status = await _platform.isMonitoring();
    isMonitoring.value = status;
    return status;
  }

  /// Get current monitoring mode ('total' or 'app')
  Future<String> getMonitoringMode() async {
    final mode = await _platform.getMonitoringMode();
    monitoringMode.value = mode;
    return mode;
  }

  /// Get current update interval in seconds
  Future<int> getUpdateInterval() async {
    final interval = await _platform.getUpdateInterval();
    updateInterval.value = interval;
    return interval;
  }

  /// Set update interval in seconds
  Future<void> setUpdateInterval(int seconds) async {
    await _platform.setUpdateInterval(seconds);
    updateInterval.value = seconds;
  }

  /// Toggle between total and app monitoring
  Future<void> toggleMonitoringMode() async {
    final currentMode = await getMonitoringMode();
    final newMode = currentMode == 'total' ? 'app' : 'total';
    final interval = updateInterval.value;
    await startMonitoring(
      monitorTotalTraffic: newMode == 'total',
      updateIntervalSeconds: interval,
    );
  }

  /// Toggle start/stop
  Future<void> toggleStartStop() async {
    final status = await checkIsMonitoring();
    if (status) {
      await stopMonitoring();
    } else {
      await startMonitoring(
        monitorTotalTraffic: monitoringMode.value == 'total',
        updateIntervalSeconds: updateInterval.value,
      );
    }
  }

  /// Format speed for display
  static String formatSpeed(double kbps) {
    if (kbps < 0) return '0 KB/s';
    if (kbps >= 1024) {
      return '${(kbps / 1024).toStringAsFixed(2)} MB/s';
    } else if (kbps >= 1) {
      return '${kbps.toStringAsFixed(2)} KB/s';
    } else {
      return '${(kbps * 1024).toStringAsFixed(0)} B/s';
    }
  }

  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
    _platform.dispose();
    speedData.dispose();
    isMonitoring.dispose();
    monitoringMode.dispose();
    updateInterval.dispose();
  }
}
