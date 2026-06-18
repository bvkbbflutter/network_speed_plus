import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_speed_plus/network_speed_plus_method_channel.dart';
import 'package:network_speed_plus/models/speed_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NetworkSpeedPlusMethodChannel', () {
    late NetworkSpeedPlusMethodChannel platform;
    late MethodChannel methodChannel;
    late EventChannel eventChannel;

    setUp(() {
      platform = NetworkSpeedPlusMethodChannel();
      methodChannel =
          const MethodChannel('com.vinay.network_speed_plus/methods');
      eventChannel = const EventChannel('com.vinay.network_speed_plus/events');
    });

    test('should have correct channel names', () {
      expect(
          platform.methodChannel.name, 'com.vinay.network_speed_plus/methods');
      expect(platform.eventChannel.name, 'com.vinay.network_speed_plus/events');
    });

    test('should start monitoring', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        methodChannel,
        (MethodCall methodCall) async {
          if (methodCall.method == 'startMonitoring') {
            final args = methodCall.arguments as Map<dynamic, dynamic>;
            expect(args['monitorTotalTraffic'], true);
            expect(args['updateIntervalSeconds'], 3);
            return true;
          }
          return null;
        },
      );

      await platform.startMonitoring(
        monitorTotalTraffic: true,
        updateIntervalSeconds: 3,
      );
    });

    test('should stop monitoring', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        methodChannel,
        (MethodCall methodCall) async {
          if (methodCall.method == 'stopMonitoring') {
            return true;
          }
          return null;
        },
      );

      await platform.stopMonitoring();
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

      final result = await platform.isMonitoring();
      expect(result, true);
    });

    test('should get monitoring mode', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        methodChannel,
        (MethodCall methodCall) async {
          if (methodCall.method == 'getMonitoringMode') {
            return 'total';
          }
          return null;
        },
      );

      final result = await platform.getMonitoringMode();
      expect(result, 'total');
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

      final result = await platform.getUpdateInterval();
      expect(result, 5);
    });

    test('should set update interval', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        methodChannel,
        (MethodCall methodCall) async {
          if (methodCall.method == 'setUpdateInterval') {
            final args = methodCall.arguments as int;
            expect(args, 10);
            return true;
          }
          return null;
        },
      );

      await platform.setUpdateInterval(10);
    });

    test('should dispose resources', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        methodChannel,
        (MethodCall methodCall) async {
          if (methodCall.method == 'dispose') {
            return true;
          }
          return null;
        },
      );

      platform.dispose();
    });

    test('should handle platform exceptions on startMonitoring', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        methodChannel,
        (MethodCall methodCall) async {
          throw PlatformException(code: 'ERROR', message: 'Test error');
        },
      );

      expect(
        () async => await platform.startMonitoring(),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle platform exceptions on stopMonitoring', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        methodChannel,
        (MethodCall methodCall) async {
          throw PlatformException(code: 'ERROR', message: 'Test error');
        },
      );

      expect(
        () async => await platform.stopMonitoring(),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle platform exceptions on isMonitoring', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        methodChannel,
        (MethodCall methodCall) async {
          throw PlatformException(code: 'ERROR', message: 'Test error');
        },
      );

      expect(
        () async => await platform.isMonitoring(),
        throwsA(isA<Exception>()),
      );
    });

    test('should return false when isMonitoring returns null', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        methodChannel,
        (MethodCall methodCall) async {
          if (methodCall.method == 'isMonitoring') {
            return null;
          }
          return null;
        },
      );

      final result = await platform.isMonitoring();
      expect(result, false);
    });

    test('should return default values when methods return null', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        methodChannel,
        (MethodCall methodCall) async {
          return null;
        },
      );

      final mode = await platform.getMonitoringMode();
      expect(mode, 'total');

      final interval = await platform.getUpdateInterval();
      expect(interval, 3);
    });
  });
}
