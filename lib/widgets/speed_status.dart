import 'package:flutter/material.dart';
import '../network_speed_plus.dart';

/// Widget that displays the monitoring status
class SpeedStatus extends StatelessWidget {
  final bool showProgress;
  final bool showStatusText;
  final bool showDetails;

  const SpeedStatus({
    super.key,
    this.showProgress = true,
    this.showStatusText = true,
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    final plugin = NetworkSpeedPlus();

    return Column(
      children: [
        if (showStatusText)
          _buildStatusText(plugin),
        if (showProgress) ...[
          const SizedBox(height: 8),
          _buildProgressIndicator(plugin),
        ],
        if (showDetails) ...[
          const SizedBox(height: 4),
          _buildDetails(plugin),
        ],
      ],
    );
  }

  Widget _buildStatusText(NetworkSpeedPlus plugin) {
    return ValueListenableBuilder<bool>(
      valueListenable: plugin.isMonitoring,
      builder: (context, isMonitoring, child) {
        return ValueListenableBuilder<String>(
          valueListenable: plugin.monitoringMode,
          builder: (context, mode, child) {
            final statusText = isMonitoring
                ? '✅ Monitoring active (${mode.toUpperCase()})'
                : '⏸️ Monitoring stopped - Tap start to begin';
            final color = isMonitoring ? Colors.green : Colors.orange;

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isMonitoring ? Icons.wifi : Icons.wifi_off,
                  color: color,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 14,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildProgressIndicator(NetworkSpeedPlus plugin) {
    return ValueListenableBuilder<SpeedData?>(
      valueListenable: plugin.speedData,
      builder: (context, data, child) {
        final hasActivity = (data?.downloadSpeed ?? 0) > 0 || (data?.uploadSpeed ?? 0) > 0;
        return LinearProgressIndicator(
          value: hasActivity ? 0.5 : 0,
          backgroundColor: Colors.grey[200],
          color: hasActivity ? Colors.green : Colors.grey,
          minHeight: 6,
        );
      },
    );
  }

  Widget _buildDetails(NetworkSpeedPlus plugin) {
    return ValueListenableBuilder<SpeedData?>(
      valueListenable: plugin.speedData,
      builder: (context, data, child) {
        if (data == null) return const SizedBox.shrink();

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '📊 ${data.formattedDownload} ↓',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '${data.formattedUpload} ↑',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        );
      },
    );
  }
}