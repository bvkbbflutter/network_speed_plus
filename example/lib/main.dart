import 'package:flutter/material.dart';
import 'package:network_speed_plus/network_speed_plus.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Network Speed Plus Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SpeedMonitorDemo(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SpeedMonitorDemo extends StatefulWidget {
  const SpeedMonitorDemo({super.key});

  @override
  State<SpeedMonitorDemo> createState() => _SpeedMonitorDemoState();
}

class _SpeedMonitorDemoState extends State<SpeedMonitorDemo> {
  final NetworkSpeedPlus _monitor = NetworkSpeedPlus();
  bool _showOverlay = true;

  @override
  void initState() {
    super.initState();
    // Start monitoring automatically
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _monitor.startMonitoring(
        monitorTotalTraffic: true,
        updateIntervalSeconds: 3,
      );
    });
  }

  @override
  void dispose() {
    _monitor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Speed Plus'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_showOverlay ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() {
                _showOverlay = !_showOverlay;
              });
            },
            tooltip: 'Toggle Overlay',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main Content
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Controls
                const SpeedControls(),

                const SizedBox(height: 20),

                // Speed Display
                const SpeedDisplay(
                  showLabels: true,
                  showMode: true,
                  showInterval: true,
                  fontSize: 16,
                ),

                const SizedBox(height: 20),

                // Status
                const SpeedStatus(
                  showProgress: true,
                  showStatusText: true,
                  showDetails: true,
                ),

                const SizedBox(height: 20),

                // Info Card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '💡 How to use',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '• Tap "Start" to begin monitoring\n'
                          '• Toggle between Total Device and App-Only speed\n'
                          '• Adjust update interval (3s, 5s, 10s)\n'
                          '• Overlay shows speed at the top right',
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),
                        ValueListenableBuilder<SpeedData?>(
                          valueListenable: _monitor.speedData,
                          builder: (context, data, child) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildInfoItem(
                                  '📥',
                                  data?.formattedDownload ?? '0 KB/s',
                                  Colors.green,
                                ),
                                _buildInfoItem(
                                  '📤',
                                  data?.formattedUpload ?? '0 KB/s',
                                  Colors.orange,
                                ),
                                _buildInfoItem(
                                  '⏱️',
                                  '${_monitor.updateInterval.value}s',
                                  Colors.blue,
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const Text(
                  'Network Speed Plus v1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // Floating Overlay
          if (_showOverlay)
            const Positioned(
              top: 80,
              right: 10,
              child: SpeedOverlay(
                showMode: true,
                showInterval: true,
                showStatus: true,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String icon, String text, Color color) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
