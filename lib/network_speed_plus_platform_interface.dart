import 'dart:async';
import 'package:flutter/services.dart';
import 'models/speed_data.dart';

/// The interface that platform-specific implementations must implement.
abstract class NetworkSpeedPlusPlatform {
  /// Get the event channel for streaming speed data
  EventChannel get eventChannel;

  /// Get the method channel for method calls
  MethodChannel get methodChannel;

  /// Stream of speed data
  Stream<SpeedData> get speedStream;

  /// Start monitoring network speed
  Future<void> startMonitoring({
    bool monitorTotalTraffic = true,
    int updateIntervalSeconds = 3,
  });

  /// Stop monitoring network speed
  Future<void> stopMonitoring();

  /// Check if monitoring is active
  Future<bool> isMonitoring();

  /// Get current monitoring mode
  Future<String> getMonitoringMode();

  /// Get current update interval
  Future<int> getUpdateInterval();

  /// Set update interval
  Future<void> setUpdateInterval(int seconds);

  /// Dispose resources
  void dispose();
}
