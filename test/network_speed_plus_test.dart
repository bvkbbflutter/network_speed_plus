import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_speed_plus/network_speed_plus.dart';
import 'package:network_speed_plus/network_speed_plus_platform_interface.dart';
import 'package:network_speed_plus/network_speed_plus_method_channel.dart';
import 'package:network_speed_plus/models/speed_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NetworkSpeedPlus', () {
    late NetworkSpeedPlus plugin;
    late MethodChannel methodChannel;
    late EventChannel eventChannel;

    setUp(() {
      plugin = NetworkSpeedPlus();
      methodChannel =
          const MethodChannel('com.vinay.network_speed_plus/methods');
      eventChannel = const EventChannel('com.vinay.network_speed_plus/events');
    });

    tearDown(() {
      plugin.dispose();
    });

    test('should be a singleton', () {
      final instance1 = NetworkSpeedPlus();
      final instance2 = NetworkSpeedPlus();
      expect(identical(instance1, instance2), true);
    });

    test('should format speed correctly', () {
      // Test KB/s formatting
      expect(NetworkSpeedPlus.formatSpeed(500), '500.00 KB/s');
      expect(NetworkSpeedPlus.formatSpeed(1024), '1.00 MB/s');
      expect(NetworkSpeedPlus.formatSpeed(2048), '2.00 MB/s');
      expect(NetworkSpeedPlus.formatSpeed(0.5), '512 B/s');
      expect(NetworkSpeedPlus.formatSpeed(-10), '0 KB/s');
    });

    test('should initialize with default values', () {
      expect(plugin.speedData.value, isNull);
      expect(plugin.isMonitoring.value, false);
      expect(plugin.monitoringMode.value, 'total');
      expect(plugin.updateInterval.value, 3);
    });

    test('should start monitoring', () async {
      // Mock the method channel response
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        methodChannel,
        (MethodCall methodCall) async {
          if (methodCall.method == 'startMonitoring') {
            return true;
          }
          if (methodCall.method == 'isMonitoring') {
            return true;
          }
          return null;
        },
      );

      await plugin.startMonitoring(
        monitorTotalTraffic: true,
        updateIntervalSeconds: 5,
      );

      expect(plugin.isMonitoring.value, true);
      expect(plugin.monitoringMode.value, 'total');
      expect(plugin.updateInterval.value, 5);
    });

    test('should stop monitoring', () async {
      // Mock the method channel response
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        methodChannel,
        (MethodCall methodCall) async {
          if (methodCall.method == 'stopMonitoring') {
            return true;
          }
          if (methodCall.method == 'isMonitoring') {
            return false;
          }
          return null;
        },
      );

      await plugin.startMonitoring();
      await plugin.stopMonitoring();

      expect(plugin.isMonitoring.value, false);
    });

    test('should toggle monitoring mode', () async {
      // Mock the method channel responses
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        methodChannel,
        (MethodCall methodCall) async {
          if (methodCall.method == 'getMonitoringMode') {
            return 'total';
          }
          if (methodCall.method == 'startMonitoring') {
            return true;
          }
          if (methodCall.method == 'isMonitoring') {
            return true;
          }
          return null;
        },
      );

      await plugin.startMonitoring(monitorTotalTraffic: true);
      expect(plugin.monitoringMode.value, 'total');

      await plugin.toggleMonitoringMode();
      // The mode should toggle to 'app'
      expect(plugin.monitoringMode.value, 'app');
    });

    test('should toggle start/stop', () async {
      bool isMonitoring = false;

      // Mock the method channel responses
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        methodChannel,
        (MethodCall methodCall) async {
          if (methodCall.method == 'isMonitoring') {
            return isMonitoring;
          }
          if (methodCall.method == 'startMonitoring') {
            isMonitoring = true;
            return true;
          }
          if (methodCall.method == 'stopMonitoring') {
            isMonitoring = false;
            return true;
          }
          return null;
        },
      );

      // Initially not monitoring
      expect(plugin.isMonitoring.value, false);

      // Toggle to start
      await plugin.toggleStartStop();
      expect(plugin.isMonitoring.value, true);

      // Toggle to stop
      await plugin.toggleStartStop();
      expect(plugin.isMonitoring.value, false);
    });

    test('should set update interval', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        methodChannel,
        (MethodCall methodCall) async {
          if (methodCall.method == 'setUpdateInterval') {
            return true;
          }
          if (methodCall.method == 'getUpdateInterval') {
            return 10;
          }
          return null;
        },
      );

      await plugin.setUpdateInterval(10);
      expect(plugin.updateInterval.value, 10);
    });

    test('should get monitoring mode', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        methodChannel,
        (MethodCall methodCall) async {
          if (methodCall.method == 'getMonitoringMode') {
            return 'app';
          }
          return null;
        },
      );

      final mode = await plugin.getMonitoringMode();
      expect(mode, 'app');
      expect(plugin.monitoringMode.value, 'app');
    });

    test('should get update interval', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        methodChannel,
        (MethodCall methodCall) async {
          if (methodCall.method == 'getUpdateInterval') {
            return 5;
          }
          return null;
        },
      );

      final interval = await plugin.getUpdateInterval();
      expect(interval, 5);
      expect(plugin.updateInterval.value, 5);
    });

    test('should check if monitoring is active', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        methodChannel,
        (MethodCall methodCall) async {
          if (methodCall.method == 'isMonitoring') {
            return true;
          }
          return null;
        },
      );

      final isActive = await plugin.checkIsMonitoring();
      expect(isActive, true);
      expect(plugin.isMonitoring.value, true);
    });
  });

  group('SpeedData', () {
    test('should create from map', () {
      final map = {
        'downloadSpeed': 150.5,
        'uploadSpeed': 75.2,
        'timestamp': 1700000000000,
        'monitorType': 'total',
      };

      final data = SpeedData.fromMap(map);
      expect(data.downloadSpeed, 150.5);
      expect(data.uploadSpeed, 75.2);
      expect(data.monitorType, 'total');
    });

    test('should format speeds correctly', () {
      final data = SpeedData(
        downloadSpeed: 150.5,
        uploadSpeed: 75.2,
        timestamp: DateTime.now(),
      );

      expect(data.formattedDownload, '150.50 KB/s');
      expect(data.formattedUpload, '75.20 KB/s');
    });

    test('should handle missing map keys', () {
      final map = <String, dynamic>{};
      final data = SpeedData.fromMap(map);
      expect(data.downloadSpeed, 0);
      expect(data.uploadSpeed, 0);
      expect(data.monitorType, 'total');
    });

    test('should convert to string', () {
      final data = SpeedData(
        downloadSpeed: 150.5,
        uploadSpeed: 75.2,
        timestamp: DateTime.now(),
      );
      expect(data.toString(), contains('download: 150.50 KB/s'));
      expect(data.toString(), contains('upload: 75.20 KB/s'));
    });
  });
}
