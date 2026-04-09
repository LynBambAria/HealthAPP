class StepCountData {
  final int stepCount;
  final DateTime timestamp;

  StepCountData({
    required this.stepCount,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'stepCount': stepCount,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  static StepCountData fromJson(Map<String, dynamic> json) {
    return StepCountData(
      stepCount: json['stepCount'] as int,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
    );
  }
}
