class HeartRateData {
  final int heartRate;
  final DateTime timestamp;

  HeartRateData({
    required this.heartRate,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'heartRate': heartRate,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  static HeartRateData fromJson(Map<String, dynamic> json) {
    return HeartRateData(
      heartRate: json['heartRate'] as int,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
    );
  }

  String getFormattedTime() {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
