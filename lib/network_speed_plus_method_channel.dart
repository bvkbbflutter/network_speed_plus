import 'dart:async';
import 'package:flutter/services.dart';
import 'network_speed_plus_platform_interface.dart';
import 'models/speed_data.dart';

/// Method channel implementation
class NetworkSpeedPlusMethodChannel implements NetworkSpeedPlusPlatform {
  // Using com.vinay.network_speed_plus as per your package name
  static const String _eventChannelName = 'com.vinay.network_speed_plus/events';
  static const String _methodChannelName =
      'com.vinay.network_speed_plus/methods';

  @override
  final EventChannel eventChannel = const EventChannel(_eventChannelName);

  @override
  final MethodChannel methodChannel = const MethodChannel(_methodChannelName);

  Stream<SpeedData>? _stream;
  StreamSubscription? _subscription;
  final _controller = StreamController<SpeedData>.broadcast();

  @override
  Stream<SpeedData> get speedStream {
    if (_stream == null) {
      _stream = eventChannel.receiveBroadcastStream().map((event) {
        if (event is Map) {
          // Convert Map<dynamic, dynamic> to Map<String, dynamic>
          final Map<String, dynamic> map = Map<String, dynamic>.from(event);
          return SpeedData.fromMap(map);
        }
        return SpeedData(
          downloadSpeed: 0,
          uploadSpeed: 0,
          timestamp: DateTime.now(),
        );
      });

      _subscription = _stream!.listen(
        (data) {
          _controller.add(data);
        },
        onError: (error) {
          _controller.addError(error);
        },
      );
    }
    return _controller.stream;
  }

  @override
  Future<void> startMonitoring({
    bool monitorTotalTraffic = true,
    int updateIntervalSeconds = 3,
  }) async {
    try {
      await methodChannel.invokeMethod('startMonitoring', {
        'monitorTotalTraffic': monitorTotalTraffic,
        'updateIntervalSeconds': updateIntervalSeconds,
      });
    } on PlatformException catch (e) {
      throw Exception('Failed to start monitoring: ${e.message}');
    }
  }

  @override
  Future<void> stopMonitoring() async {
    try {
      await methodChannel.invokeMethod('stopMonitoring');
    } on PlatformException catch (e) {
      throw Exception('Failed to stop monitoring: ${e.message}');
    }
  }

  @override
  Future<bool> isMonitoring() async {
    try {
      return await methodChannel.invokeMethod('isMonitoring') ?? false;
    } on PlatformException catch (e) {
      throw Exception('Failed to check monitoring status: ${e.message}');
    }
  }

  @override
  Future<String> getMonitoringMode() async {
    try {
      return await methodChannel.invokeMethod('getMonitoringMode') ?? 'total';
    } on PlatformException catch (e) {
      throw Exception('Failed to get monitoring mode: ${e.message}');
    }
  }

  @override
  Future<int> getUpdateInterval() async {
    try {
      return await methodChannel.invokeMethod('getUpdateInterval') ?? 3;
    } on PlatformException catch (e) {
      throw Exception('Failed to get update interval: ${e.message}');
    }
  }

  @override
  Future<void> setUpdateInterval(int seconds) async {
    try {
      await methodChannel.invokeMethod('setUpdateInterval', seconds);
    } on PlatformException catch (e) {
      throw Exception('Failed to set update interval: ${e.message}');
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _controller.close();
    methodChannel.invokeMethod('dispose');
  }
}
