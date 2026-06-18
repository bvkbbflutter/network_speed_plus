/// Represents network speed data
class SpeedData {
  /// Download speed in KB/s
  final double downloadSpeed;

  /// Upload speed in KB/s
  final double uploadSpeed;

  /// Timestamp when the data was captured
  final DateTime timestamp;

  /// Type of monitoring (total or app)
  final String monitorType;

  SpeedData({
    required this.downloadSpeed,
    required this.uploadSpeed,
    required this.timestamp,
    this.monitorType = 'total',
  });

  /// Create from Map
  factory SpeedData.fromMap(Map<String, dynamic> map) {
    return SpeedData(
      downloadSpeed: (map['downloadSpeed'] ?? 0).toDouble(),
      uploadSpeed: (map['uploadSpeed'] ?? 0).toDouble(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (map['timestamp'] ?? 0).toInt(),
      ),
      monitorType: map['monitorType'] ?? 'total',
    );
  }

  /// Format speed for display
  String get formattedDownload => _formatSpeed(downloadSpeed);
  String get formattedUpload => _formatSpeed(uploadSpeed);

  String _formatSpeed(double kbps) {
    if (kbps < 0) return '0 KB/s';
    if (kbps >= 1024) {
      return '${(kbps / 1024).toStringAsFixed(2)} MB/s';
    } else if (kbps >= 1) {
      return '${kbps.toStringAsFixed(2)} KB/s';
    } else {
      return '${(kbps * 1024).toStringAsFixed(0)} B/s';
    }
  }

  @override
  String toString() {
    return 'SpeedData(download: $formattedDownload, upload: $formattedUpload)';
  }
}
