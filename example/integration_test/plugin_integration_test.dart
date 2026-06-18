// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:network_speed_plus/network_speed_plus.dart';
import 'package:network_speed_plus/models/speed_data.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late NetworkSpeedPlus plugin;

  setUp(() {
    plugin = NetworkSpeedPlus();
  });

  tearDown(() {
    plugin.dispose();
  });

  group('NetworkSpeedPlus Integration Tests', () {
    testWidgets('should initialize with default values',
        (WidgetTester tester) async {
      // Wait for the plugin to initialize
      await tester.pumpAndSettle();

      expect(plugin.speedData.value, isNull);
      expect(plugin.isMonitoring.value, false);
      expect(plugin.monitoringMode.value, 'total');
      expect(plugin.updateInterval.value, 3);
    });

    testWidgets('should start and stop monitoring',
        (WidgetTester tester) async {
      // Start monitoring
      await plugin.startMonitoring(
        monitorTotalTraffic: true,
        updateIntervalSeconds: 3,
      );

      expect(plugin.isMonitoring.value, true);
      expect(plugin.monitoringMode.value, 'total');
      expect(plugin.updateInterval.value, 3);

      // Wait for some data to be received
      await tester.pump(Duration(seconds: 5));

      // Stop monitoring
      await plugin.stopMonitoring();
      expect(plugin.isMonitoring.value, false);
    });

    testWidgets('should toggle monitoring mode', (WidgetTester tester) async {
      // Start monitoring with total traffic
      await plugin.startMonitoring(
        monitorTotalTraffic: true,
        updateIntervalSeconds: 3,
      );

      expect(plugin.monitoringMode.value, 'total');

      // Toggle to app mode
      await plugin.toggleMonitoringMode();
      expect(plugin.monitoringMode.value, 'app');

      // Toggle back to total mode
      await plugin.toggleMonitoringMode();
      expect(plugin.monitoringMode.value, 'total');
    });

    testWidgets('should toggle start and stop', (WidgetTester tester) async {
      // Initially not monitoring
      expect(plugin.isMonitoring.value, false);

      // Toggle to start
      await plugin.toggleStartStop();
      expect(plugin.isMonitoring.value, true);

      // Toggle to stop
      await plugin.toggleStartStop();
      expect(plugin.isMonitoring.value, false);
    });

    testWidgets('should change update interval', (WidgetTester tester) async {
      // Start monitoring
      await plugin.startMonitoring(
        monitorTotalTraffic: true,
        updateIntervalSeconds: 3,
      );

      expect(plugin.updateInterval.value, 3);

      // Change to 5 seconds
      await plugin.setUpdateInterval(5);
      expect(plugin.updateInterval.value, 5);

      // Change to 10 seconds
      await plugin.setUpdateInterval(10);
      expect(plugin.updateInterval.value, 10);
    });

    testWidgets('should receive speed data updates',
        (WidgetTester tester) async {
      // Listen for speed data updates
      SpeedData? receivedData;

      // Use a listener to capture data
      final listener = () {
        receivedData = plugin.speedData.value;
      };

      plugin.speedData.addListener(listener);

      // Start monitoring
      await plugin.startMonitoring(
        monitorTotalTraffic: true,
        updateIntervalSeconds: 2,
      );

      // Wait for data to be received
      await tester.pump(Duration(seconds: 5));

      // Check if data was received
      expect(receivedData, isNotNull);
      if (receivedData != null) {
        expect(receivedData?.downloadSpeed, greaterThanOrEqualTo(0));
        expect(receivedData?.uploadSpeed, greaterThanOrEqualTo(0));
        expect(receivedData?.monitorType, anyOf('total', 'app'));
        expect(receivedData?.timestamp, isNotNull);
      }

      // Remove listener
      plugin.speedData.removeListener(listener);
    });

    testWidgets('should format speeds correctly', (WidgetTester tester) async {
      // Test various speed formats
      expect(NetworkSpeedPlus.formatSpeed(0), '0 KB/s');
      expect(NetworkSpeedPlus.formatSpeed(100), '100.00 KB/s');
      expect(NetworkSpeedPlus.formatSpeed(1024), '1.00 MB/s');
      expect(NetworkSpeedPlus.formatSpeed(2048), '2.00 MB/s');
      expect(NetworkSpeedPlus.formatSpeed(0.5), '512 B/s');
      expect(NetworkSpeedPlus.formatSpeed(-1), '0 KB/s');
    });

    testWidgets('should handle multiple start/stop cycles',
        (WidgetTester tester) async {
      // Start and stop multiple times
      for (int i = 0; i < 3; i++) {
        await plugin.startMonitoring(
          monitorTotalTraffic: i % 2 == 0,
          updateIntervalSeconds: 3,
        );
        expect(plugin.isMonitoring.value, true);

        await tester.pump(Duration(seconds: 2));

        await plugin.stopMonitoring();
        expect(plugin.isMonitoring.value, false);

        await tester.pump(Duration(seconds: 1));
      }
    });

    testWidgets('should handle concurrent operations',
        (WidgetTester tester) async {
      // Perform multiple operations in sequence
      await plugin.startMonitoring(
        monitorTotalTraffic: true,
        updateIntervalSeconds: 3,
      );

      expect(plugin.isMonitoring.value, true);

      // Change interval while monitoring
      await plugin.setUpdateInterval(5);
      expect(plugin.updateInterval.value, 5);

      // Toggle mode while monitoring
      await plugin.toggleMonitoringMode();
      expect(plugin.monitoringMode.value, 'app');

      // Stop monitoring
      await plugin.stopMonitoring();
      expect(plugin.isMonitoring.value, false);
    });

    testWidgets('should handle errors gracefully', (WidgetTester tester) async {
      // Try to stop monitoring when not started (should not throw)
      // Use a try-catch to handle any potential errors
      try {
        await plugin.stopMonitoring();
        expect(true, true); // Pass if no exception
      } catch (e) {
        // If an exception is thrown, the test should fail
        expect(true, false, reason: 'stopMonitoring threw an exception: $e');
      }

      // Try to toggle when not started
      try {
        await plugin.toggleMonitoringMode();
        expect(true, true); // Pass if no exception
      } catch (e) {
        expect(true, false,
            reason: 'toggleMonitoringMode threw an exception: $e');
      }

      // Try to set interval when not started
      try {
        await plugin.setUpdateInterval(5);
        expect(true, true); // Pass if no exception
      } catch (e) {
        expect(true, false, reason: 'setUpdateInterval threw an exception: $e');
      }
    });
  });

  group('SpeedData Model Integration Tests', () {
    testWidgets('should create SpeedData from map',
        (WidgetTester tester) async {
      final map = {
        'downloadSpeed': 150.5,
        'uploadSpeed': 75.2,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'monitorType': 'total',
      };

      final data = SpeedData.fromMap(map);

      expect(data.downloadSpeed, 150.5);
      expect(data.uploadSpeed, 75.2);
      expect(data.monitorType, 'total');
      expect(data.formattedDownload, '150.50 KB/s');
      expect(data.formattedUpload, '75.20 KB/s');
    });

    testWidgets('should handle missing fields in SpeedData',
        (WidgetTester tester) async {
      final map = <String, dynamic>{};

      final data = SpeedData.fromMap(map);

      expect(data.downloadSpeed, 0);
      expect(data.uploadSpeed, 0);
      expect(data.monitorType, 'total');
      expect(data.formattedDownload, '0 KB/s');
      expect(data.formattedUpload, '0 KB/s');
    });
  });
}

// // This is a basic Flutter integration test.
// //
// // Since integration tests run in a full Flutter application, they can interact
// // with the host side of a plugin implementation, unlike Dart unit tests.
// //
// // For more information about Flutter integration tests, please see
// // https://flutter.dev/to/integration-testing

// import 'package:flutter_test/flutter_test.dart';
// import 'package:integration_test/integration_test.dart';
// import 'package:network_speed_plus/network_speed_plus.dart';
// import 'package:network_speed_plus/models/speed_data.dart';

// void main() {
//   IntegrationTestWidgetsFlutterBinding.ensureInitialized();

//   late NetworkSpeedPlus plugin;

//   setUp(() {
//     plugin = NetworkSpeedPlus();
//   });

//   tearDown(() {
//     plugin.dispose();
//   });

//   group('NetworkSpeedPlus Integration Tests', () {
//     testWidgets('should initialize with default values',
//         (WidgetTester tester) async {
//       // Wait for the plugin to initialize
//       await tester.pumpAndSettle();

//       expect(plugin.speedData.value, isNull);
//       expect(plugin.isMonitoring.value, false);
//       expect(plugin.monitoringMode.value, 'total');
//       expect(plugin.updateInterval.value, 3);
//     });

//     testWidgets('should start and stop monitoring',
//         (WidgetTester tester) async {
//       // Start monitoring
//       await plugin.startMonitoring(
//         monitorTotalTraffic: true,
//         updateIntervalSeconds: 3,
//       );

//       expect(plugin.isMonitoring.value, true);
//       expect(plugin.monitoringMode.value, 'total');
//       expect(plugin.updateInterval.value, 3);

//       // Wait for some data to be received
//       await tester.pump(Duration(seconds: 5));

//       // Stop monitoring
//       await plugin.stopMonitoring();
//       expect(plugin.isMonitoring.value, false);
//     });

//     testWidgets('should toggle monitoring mode', (WidgetTester tester) async {
//       // Start monitoring with total traffic
//       await plugin.startMonitoring(
//         monitorTotalTraffic: true,
//         updateIntervalSeconds: 3,
//       );

//       expect(plugin.monitoringMode.value, 'total');

//       // Toggle to app mode
//       await plugin.toggleMonitoringMode();
//       expect(plugin.monitoringMode.value, 'app');

//       // Toggle back to total mode
//       await plugin.toggleMonitoringMode();
//       expect(plugin.monitoringMode.value, 'total');
//     });

//     testWidgets('should toggle start and stop', (WidgetTester tester) async {
//       // Initially not monitoring
//       expect(plugin.isMonitoring.value, false);

//       // Toggle to start
//       await plugin.toggleStartStop();
//       expect(plugin.isMonitoring.value, true);

//       // Toggle to stop
//       await plugin.toggleStartStop();
//       expect(plugin.isMonitoring.value, false);
//     });

//     testWidgets('should change update interval', (WidgetTester tester) async {
//       // Start monitoring
//       await plugin.startMonitoring(
//         monitorTotalTraffic: true,
//         updateIntervalSeconds: 3,
//       );

//       expect(plugin.updateInterval.value, 3);

//       // Change to 5 seconds
//       await plugin.setUpdateInterval(5);
//       expect(plugin.updateInterval.value, 5);

//       // Change to 10 seconds
//       await plugin.setUpdateInterval(10);
//       expect(plugin.updateInterval.value, 10);
//     });

//     testWidgets('should receive speed data updates',
//         (WidgetTester tester) async {
//       // Listen for speed data updates
//       SpeedData? receivedData;

//       final subscription = plugin.speedData.addListener(() {
//         receivedData = plugin.speedData.value;
//       });

//       // Start monitoring
//       await plugin.startMonitoring(
//         monitorTotalTraffic: true,
//         updateIntervalSeconds: 2,
//       );

//       // Wait for data to be received
//       await tester.pump(Duration(seconds: 5));

//       // Check if data was received
//       expect(receivedData, isNotNull);
//       if (receivedData != null) {
//         expect(receivedData.downloadSpeed, greaterThanOrEqualTo(0));
//         expect(receivedData.uploadSpeed, greaterThanOrEqualTo(0));
//         expect(receivedData.monitorType, anyOf('total', 'app'));
//         expect(receivedData.timestamp, isNotNull);
//       }

//       subscription.dispose();
//     });

//     testWidgets('should format speeds correctly', (WidgetTester tester) async {
//       // Test various speed formats
//       expect(NetworkSpeedPlus.formatSpeed(0), '0 KB/s');
//       expect(NetworkSpeedPlus.formatSpeed(100), '100.00 KB/s');
//       expect(NetworkSpeedPlus.formatSpeed(1024), '1.00 MB/s');
//       expect(NetworkSpeedPlus.formatSpeed(2048), '2.00 MB/s');
//       expect(NetworkSpeedPlus.formatSpeed(0.5), '512 B/s');
//       expect(NetworkSpeedPlus.formatSpeed(-1), '0 KB/s');
//     });

//     testWidgets('should handle multiple start/stop cycles',
//         (WidgetTester tester) async {
//       // Start and stop multiple times
//       for (int i = 0; i < 3; i++) {
//         await plugin.startMonitoring(
//           monitorTotalTraffic: i % 2 == 0,
//           updateIntervalSeconds: 3,
//         );
//         expect(plugin.isMonitoring.value, true);

//         await tester.pump(Duration(seconds: 2));

//         await plugin.stopMonitoring();
//         expect(plugin.isMonitoring.value, false);

//         await tester.pump(Duration(seconds: 1));
//       }
//     });

//     testWidgets('should handle concurrent operations',
//         (WidgetTester tester) async {
//       // Perform multiple operations in sequence
//       await plugin.startMonitoring(
//         monitorTotalTraffic: true,
//         updateIntervalSeconds: 3,
//       );

//       expect(plugin.isMonitoring.value, true);

//       // Change interval while monitoring
//       await plugin.setUpdateInterval(5);
//       expect(plugin.updateInterval.value, 5);

//       // Toggle mode while monitoring
//       await plugin.toggleMonitoringMode();
//       expect(plugin.monitoringMode.value, 'app');

//       // Stop monitoring
//       await plugin.stopMonitoring();
//       expect(plugin.isMonitoring.value, false);
//     });

//     testWidgets('should handle errors gracefully', (WidgetTester tester) async {
//       // Try to stop monitoring when not started (should not throw)
//       expect(() => plugin.stopMonitoring(), isNot(throwsException));

//       // Try to toggle when not started
//       expect(() => plugin.toggleMonitoringMode(), isNot(throwsException));

//       // Try to set interval when not started
//       expect(() => plugin.setUpdateInterval(5), isNot(throwsException));
//     });
//   });

//   group('SpeedData Model Integration Tests', () {
//     testWidgets('should create SpeedData from map',
//         (WidgetTester tester) async {
//       final map = {
//         'downloadSpeed': 150.5,
//         'uploadSpeed': 75.2,
//         'timestamp': DateTime.now().millisecondsSinceEpoch,
//         'monitorType': 'total',
//       };

//       final data = SpeedData.fromMap(map);

//       expect(data.downloadSpeed, 150.5);
//       expect(data.uploadSpeed, 75.2);
//       expect(data.monitorType, 'total');
//       expect(data.formattedDownload, '150.50 KB/s');
//       expect(data.formattedUpload, '75.20 KB/s');
//     });

//     testWidgets('should handle missing fields in SpeedData',
//         (WidgetTester tester) async {
//       final map = <String, dynamic>{};

//       final data = SpeedData.fromMap(map);

//       expect(data.downloadSpeed, 0);
//       expect(data.uploadSpeed, 0);
//       expect(data.monitorType, 'total');
//       expect(data.formattedDownload, '0 KB/s');
//       expect(data.formattedUpload, '0 KB/s');
//     });
//   });
// }
