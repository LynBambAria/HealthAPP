import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/step_count_provider.dart';
import '../providers/ble_device_provider.dart';
import 'ble_device_page.dart';
import '../models/step_count_data.dart';

class StepCountDetailPage extends StatelessWidget {
  const StepCountDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final stepCountProvider = Provider.of<StepCountProvider>(context);
    final bleProvider = Provider.of<BLEDeviceProvider>(context);
    final todayData = stepCountProvider.getTodayData();
    final latestData = stepCountProvider.getLatestData();

    return Scaffold(
      appBar: AppBar(
        title: const Text('步数'),
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
                color: Colors.blue[50],
              ),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.directions_walk,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '步数',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        latestData != null
                            ? '${latestData.stepCount}步\n${latestData.timestamp.month}月${latestData.timestamp.day}日 ${latestData.timestamp.hour}:${latestData.timestamp.minute.toString().padLeft(2, '0')}'
                            : '--步\n--',
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
                      color: Color.fromARGB(26, 128, 128, 128),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 280,
                      child: CustomPaint(
                        painter: StepCountChartPainter(todayData),
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
                    color: Color.fromARGB(26, 128, 128, 128),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
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
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.blue,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.directions_walk,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('今日概览', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                              latestData != null ? '${latestData.stepCount}' : '--',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '最新步数',
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
          ],
        ),
      ),
    );
  }
}

class StepCountChartPainter extends CustomPainter {
  final List<StepCountData> data;

  StepCountChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    final double paddingLeft = 40;
    final double paddingRight = 40;
    final double paddingTop = 20;
    final double paddingBottom = 20;
    final double chartWidth = width - paddingLeft - paddingRight;
    final chartHeight = height - paddingTop - paddingBottom;

    final gridPaint = Paint()
      ..color = Colors.grey[200]!
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      double y = paddingTop + (chartHeight / 4) * i;
      canvas.drawLine(
        Offset(paddingLeft, y),
        Offset(width - paddingRight, y),
        gridPaint,
      );
    }

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i <= 5; i++) {
      int value = (10000 ~/ 5) * (5 - i);
      double y = paddingTop + (chartHeight / 5) * i;
      textPainter.text = TextSpan(
        text: '$value',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(width - paddingRight + 8, y - textPainter.height / 2));
    }

    if (data.isEmpty) return;

    Map<int, List<Offset>> hourGroups = {};
    for (var point in data) {
      double hour = point.timestamp.hour + point.timestamp.minute / 60.0;
      double x = paddingLeft + (hour / 24.0) * chartWidth;
      int maxSteps = 10000;
      int normalizedY = point.stepCount.clamp(0, maxSteps);
      double y = paddingTop + (1 - normalizedY / maxSteps) * chartHeight;
      int hourKey = point.timestamp.hour;
      hourGroups.putIfAbsent(hourKey, () => []);
      hourGroups[hourKey]!.add(Offset(x, y));
    }

    final linePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    hourGroups.forEach((hour, points) {
      if (points.length > 1) {
        for (int i = 0; i < points.length - 1; i++) {
          canvas.drawLine(points[i], points[i + 1], linePaint);
        }
      }
    });

    final pointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    hourGroups.forEach((hour, points) {
      for (var offset in points) {
        canvas.drawCircle(offset, 4, pointPaint);
      }
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
