import 'package:flutter/material.dart';
import '../network_speed_plus.dart';

/// A floating overlay widget that displays network speed
class SpeedOverlay extends StatelessWidget {
  final double top;
  final double right;
  final bool showMode;
  final bool showInterval;
  final bool showStatus;

  const SpeedOverlay({
    super.key,
    this.top = 80,
    this.right = 10,
    this.showMode = true,
    this.showInterval = true,
    this.showStatus = true,
  });

  @override
  Widget build(BuildContext context) {
    final plugin = NetworkSpeedPlus();

    return ValueListenableBuilder<SpeedData?>(
      valueListenable: plugin.speedData,
      builder: (context, data, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: plugin.isMonitoring,
          builder: (context, isMonitoring, child) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isMonitoring ? Colors.black87 : Colors.black54,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isMonitoring ? Colors.green : Colors.red,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSpeedRow(
                    icon: Icons.arrow_downward,
                    speed: data?.downloadSpeed ?? 0,
                    color: isMonitoring ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(height: 2),
                  _buildSpeedRow(
                    icon: Icons.arrow_upward,
                    speed: data?.uploadSpeed ?? 0,
                    color: isMonitoring ? Colors.orange : Colors.grey,
                  ),
                  if (showMode || showInterval || showStatus) ...[
                    const SizedBox(height: 2),
                    _buildInfoRow(plugin, isMonitoring),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSpeedRow({
    required IconData icon,
    required double speed,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          NetworkSpeedPlus.formatSpeed(speed),
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(NetworkSpeedPlus plugin, bool isMonitoring) {
    return ValueListenableBuilder<String>(
      valueListenable: plugin.monitoringMode,
      builder: (context, mode, child) {
        return ValueListenableBuilder<int>(
          valueListenable: plugin.updateInterval,
          builder: (context, interval, child) {
            return Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isMonitoring ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 4),
                if (showStatus)
                  Text(
                    isMonitoring ? '●' : '○',
                    style: TextStyle(
                      color: isMonitoring ? Colors.green : Colors.red,
                      fontSize: 8,
                    ),
                  ),
                if (showMode) ...[
                  const SizedBox(width: 4),
                  Text(
                    mode == 'total' ? '📶' : '📱',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 8,
                    ),
                  ),
                ],
                if (showMode && showInterval) const SizedBox(width: 2),
                if (showInterval)
                  Text(
                    '⏱️${interval}s',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 8,
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}