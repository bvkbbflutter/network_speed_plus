import 'package:flutter/material.dart';
import '../network_speed_plus.dart';

/// Widget that provides controls for the network speed monitor
class SpeedControls extends StatelessWidget {
  final bool showModeToggle;
  final bool showIntervalSelector;
  final bool showStartStop;
  final List<int> intervalOptions;

  const SpeedControls({
    super.key,
    this.showModeToggle = true,
    this.showIntervalSelector = true,
    this.showStartStop = true,
    this.intervalOptions = const [3, 5, 10],
  });

  @override
  Widget build(BuildContext context) {
    final plugin = NetworkSpeedPlus();

    return Column(
      children: [
        if (showStartStop)
          _buildStartStopButton(plugin),
        if (showStartStop && (showModeToggle || showIntervalSelector))
          const SizedBox(height: 10),
        if (showModeToggle)
          _buildModeToggle(plugin),
        if (showModeToggle && showIntervalSelector)
          const SizedBox(height: 10),
        if (showIntervalSelector)
          _buildIntervalSelector(plugin),
      ],
    );
  }

  Widget _buildStartStopButton(NetworkSpeedPlus plugin) {
    return ValueListenableBuilder<bool>(
      valueListenable: plugin.isMonitoring,
      builder: (context, isMonitoring, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isMonitoring ? Colors.green[50] : Colors.red[50],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isMonitoring ? Colors.green : Colors.red,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isMonitoring ? Icons.play_circle_filled : Icons.stop_circle,
                color: isMonitoring ? Colors.green : Colors.red,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                isMonitoring ? '🟢 Monitoring Active' : '🔴 Monitoring Stopped',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isMonitoring ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => plugin.toggleStartStop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isMonitoring ? Colors.red : Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  isMonitoring ? '⏹ Stop' : '▶ Start',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModeToggle(NetworkSpeedPlus plugin) {
    return ValueListenableBuilder<String>(
      valueListenable: plugin.monitoringMode,
      builder: (context, mode, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: plugin.isMonitoring,
          builder: (context, isMonitoring, child) {
            final isTotal = mode == 'total';
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isTotal ? Colors.blue[100] : Colors.green[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isTotal ? Icons.phone_android : Icons.apps,
                    color: isTotal ? Colors.blue : Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isTotal ? '📶 Total Device Speed' : '📱 App Only Speed',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isTotal ? Colors.blue : Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Switch(
                    value: isTotal,
                    onChanged: isMonitoring ? (_) => plugin.toggleMonitoringMode() : null,
                    activeColor: Colors.blue,
                    inactiveThumbColor: Colors.green,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildIntervalSelector(NetworkSpeedPlus plugin) {
    return ValueListenableBuilder<int>(
      valueListenable: plugin.updateInterval,
      builder: (context, currentInterval, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: plugin.isMonitoring,
          builder: (context, isMonitoring, child) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timer, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  const Text(
                    'Update: ',
                    style: TextStyle(fontSize: 14),
                  ),
                  ...intervalOptions.map((seconds) =>
                      _buildIntervalButton(seconds, currentInterval, isMonitoring, plugin)
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildIntervalButton(
      int seconds,
      int currentInterval,
      bool isMonitoring,
      NetworkSpeedPlus plugin,
      ) {
    final isSelected = currentInterval == seconds;
    return GestureDetector(
      onTap: isMonitoring ? () => plugin.setUpdateInterval(seconds) : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey,
          ),
        ),
        child: Text(
          '${seconds}s',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}