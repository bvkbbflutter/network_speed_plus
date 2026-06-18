import 'package:flutter/material.dart';
import '../network_speed_plus.dart';

/// A widget that displays download and upload speeds
class SpeedDisplay extends StatelessWidget {
  final bool showLabels;
  final bool showMode;
  final bool showInterval;
  final bool displayDownload;
  final bool displayUpload;
  final double fontSize;
  final MainAxisAlignment alignment;
  final EdgeInsets padding;

  const SpeedDisplay({
    super.key,
    this.showLabels = true,
    this.showMode = true,
    this.showInterval = true,
    this.displayDownload = true,
    this.displayUpload = true,
    this.fontSize = 16,
    this.alignment = MainAxisAlignment.center,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final plugin = NetworkSpeedPlus();

    return ValueListenableBuilder<SpeedData?>(
      valueListenable: plugin.speedData,
      builder: (context, data, child) {
        if (data == null) {
          return _buildLoadingState();
        }

        return _buildSpeedDisplay(data, plugin);
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildSpeedDisplay(SpeedData data, NetworkSpeedPlus plugin) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (showLabels) ...[
            if (displayDownload)
              _buildSpeedRow(
                icon: Icons.arrow_downward,
                label: 'Download',
                speed: data.downloadSpeed,
                color: Colors.green,
                fontSize: fontSize,
              ),
            const SizedBox(height: 12),
            if (displayUpload)
              _buildSpeedRow(
                icon: Icons.arrow_upward,
                label: 'Upload',
                speed: data.uploadSpeed,
                color: Colors.orange,
                fontSize: fontSize,
              ),
          ] else ...[
            if (displayDownload)
              _buildSpeedRowCompact(
                icon: Icons.arrow_downward,
                speed: data.downloadSpeed,
                color: Colors.green,
                fontSize: fontSize,
              ),
            const SizedBox(height: 4),
            if (displayUpload)
              _buildSpeedRowCompact(
                icon: Icons.arrow_upward,
                speed: data.uploadSpeed,
                color: Colors.orange,
                fontSize: fontSize,
              ),
          ],
          if (showMode || showInterval) ...[
            const SizedBox(height: 8),
            _buildBottomInfo(plugin),
          ],
        ],
      ),
    );
  }

  Widget _buildSpeedRow({
    required IconData icon,
    required String label,
    required double speed,
    required Color color,
    required double fontSize,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: fontSize + 4),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          NetworkSpeedPlus.formatSpeed(speed),
          style: TextStyle(
            fontSize: fontSize + 2,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSpeedRowCompact({
    required IconData icon,
    required double speed,
    required Color color,
    required double fontSize,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(icon, color: color, size: fontSize),
        const SizedBox(width: 4),
        Text(
          NetworkSpeedPlus.formatSpeed(speed),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomInfo(NetworkSpeedPlus plugin) {
    return ValueListenableBuilder<bool>(
      valueListenable: plugin.isMonitoring,
      builder: (context, isMonitoring, child) {
        return ValueListenableBuilder<String>(
          valueListenable: plugin.monitoringMode,
          builder: (context, mode, child) {
            return ValueListenableBuilder<int>(
              valueListenable: plugin.updateInterval,
              builder: (context, interval, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (showMode) ...[
                      Icon(
                        mode == 'total' ? Icons.phone_android : Icons.apps,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        mode == 'total' ? 'Device Total' : 'App Only',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                    if (showMode && showInterval) const SizedBox(width: 8),
                    if (showInterval) ...[
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isMonitoring ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '⏱️ ${interval}s',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
