import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../providers/heart_rate_provider.dart';
import '../providers/ble_device_provider.dart';
import 'ble_device_page.dart';
import '../models/heart_rate_data.dart';

class HeartRateDetailPage extends StatefulWidget {
  const HeartRateDetailPage({super.key});

  @override
  State<HeartRateDetailPage> createState() => _HeartRateDetailPageState();
}

class _HeartRateDetailPageState extends State<HeartRateDetailPage> {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _shouldVibrate = true;

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'heart_rate_alert',
      '心率异常提醒',
      channelDescription: '当心率过高时发送提醒',
      importance: Importance.max,
      priority: Priority.high,
      color: Colors.red,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await _notificationsPlugin.show(
      0,
      '心率过高异常',
      '心率过高异常，请降低运动强度',
      platformChannelSpecifics,
    );
  }

  static const int vibrationMsPerSecond = 10;
  static const int vibrationIntervalMs = 50;

  Future<void> _vibratePattern() async {
    _shouldVibrate = true;
    for (int i = 0; i < 3; i++) {
      if (!_shouldVibrate) break;
      for (int j = 0; j < (5000 ~/ vibrationIntervalMs); j++) {
        if (!_shouldVibrate) break;
        HapticFeedback.heavyImpact();
        await Future.delayed(Duration(milliseconds: vibrationIntervalMs));
      }
      if (i < 2 && _shouldVibrate) {
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  void _stopVibration() {
    _shouldVibrate = false;
  }

  void _triggerAbnormalHeartRate() {
    final heartRateProvider = Provider.of<HeartRateProvider>(context, listen: false);
    final random = Random();
    int abnormalHeartRate = 120 + random.nextInt(61);
    heartRateProvider.addHeartRate(abnormalHeartRate);

    _showNotification();
    _vibratePattern();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('心率异常'),
          ],
        ),
        content: const Text('心率过高异常，请降低运动强度'),
        actions: [
          TextButton(
            onPressed: () {
              _stopVibration();
              Navigator.pop(context);
            },
            child: const Text('我知道了'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final heartRateProvider = Provider.of<HeartRateProvider>(context);
    final bleProvider = Provider.of<BLEDeviceProvider>(context);
    final todayData = heartRateProvider.getTodayData();
    final latestData = heartRateProvider.getLatestData();
    final minRate = heartRateProvider.getMinHeartRateToday();
    final maxRate = heartRateProvider.getMaxHeartRateToday();
    final avgRate = heartRateProvider.getAverageHeartRateToday();

    return Scaffold(
      appBar: AppBar(
        title: const Text('心率'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!bleProvider.isConnected)
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BLEDevicePage()),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.orange[100],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange),
                      SizedBox(width: 12),
                      Text(
                        '设备未连接',
                        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            if (!bleProvider.isConnected)
              const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.red[50],
              ),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '心率',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        latestData != null
                            ? '${latestData.heartRate}次/分\n${latestData.timestamp.month}月${latestData.timestamp.day}日 ${latestData.getFormattedTime()}'
                            : '--次/分\n--',
                        style: TextStyle(
                          fontSize: 28,
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (todayData.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(25, 158, 158, 158),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 280,
                      child: CustomPaint(
                        painter: HeartRateChartPainter(todayData),
                        size: const Size(double.infinity, 280),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '00:00',
                          style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                        ),
                        Text(
                          '24:00',
                          style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(25, 158, 158, 158),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '今日概览',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              minRate != null && maxRate != null
                                  ? '$minRate-$maxRate'
                                  : '--',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '心率范围',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              avgRate != null ? avgRate.toStringAsFixed(0) : '--',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '平均心率',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _triggerAbnormalHeartRate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '异常心率检测',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HeartRateChartPainter extends CustomPainter {
  final List<HeartRateData> data;

  HeartRateChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    final double paddingLeft = 40;
    final double paddingRight = 40;
    final double paddingTop = 20;
    final double paddingBottom = 20;
    final double chartWidth = width - paddingLeft - paddingRight;
    final double chartHeight = height - paddingTop - paddingBottom;

    final gridPaint = Paint()
      ..color = Colors.grey[200]!
      ..strokeWidth = 1;

    int maxHeartRate = 100;
    if (data.isNotEmpty) {
      int maxInData = data.map((e) => e.heartRate).reduce((a, b) => a > b ? a : b);
      maxHeartRate = ((maxInData + 19) ~/ 20) * 20;
      maxHeartRate = maxHeartRate < 100 ? 100 : maxHeartRate;
    }

    int gridLines = 5;
    for (int i = 0; i <= gridLines; i++) {
      double y = paddingTop + (chartHeight / gridLines) * i;
      canvas.drawLine(
        Offset(paddingLeft, y),
        Offset(width - paddingRight, y),
        gridPaint,
      );
    }

    for (int i = 0; i <= 4; i++) {
      double x = paddingLeft + (chartWidth / 4) * i;
      canvas.drawLine(
        Offset(x, paddingTop),
        Offset(x, height - paddingBottom),
        gridPaint,
      );
    }

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i <= gridLines; i++) {
      int value = ((maxHeartRate ~/ gridLines) * (gridLines - i)).toInt();
      double y = paddingTop + (chartHeight / gridLines) * i;
      textPainter.text = TextSpan(
        text: '$value',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(8 - textPainter.width, y - textPainter.height / 2),
      );
    }

    if (data.isEmpty) return;

    Map<int, List<HeartRatePoint>> hourGroups = {};
    for (var point in data) {
      double hour = point.timestamp.hour + point.timestamp.minute / 60.0;
      double x = paddingLeft + (hour / 24.0) * chartWidth;
      int normalizedY = point.heartRate.clamp(0, maxHeartRate);
      double y = paddingTop + (1 - normalizedY / maxHeartRate) * chartHeight;
      int hourKey = point.timestamp.hour;
      bool isAbnormal = point.heartRate >= 120;
      hourGroups.putIfAbsent(hourKey, () => []);
      hourGroups[hourKey]!.add(HeartRatePoint(Offset(x, y), isAbnormal));
    }

    final linePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final abnormalLinePaint = Paint()
      ..color = Colors.purple
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    hourGroups.forEach((hour, points) {
      if (points.length > 1) {
        for (int i = 0; i < points.length - 1; i++) {
          if (points[i].isAbnormal || points[i + 1].isAbnormal) {
            canvas.drawLine(points[i].offset, points[i + 1].offset, abnormalLinePaint);
          } else {
            canvas.drawLine(points[i].offset, points[i + 1].offset, linePaint);
          }
        }
      }
    });

    final pointPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final abnormalPointPaint = Paint()
      ..color = Colors.purple
      ..style = PaintingStyle.fill;

    hourGroups.forEach((hour, points) {
      for (var point in points) {
        if (point.isAbnormal) {
          canvas.drawCircle(point.offset, 6, abnormalPointPaint);
        } else {
          canvas.drawCircle(point.offset, 4, pointPaint);
        }
      }
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class HeartRatePoint {
  final Offset offset;
  final bool isAbnormal;

  HeartRatePoint(this.offset, this.isAbnormal);
}
