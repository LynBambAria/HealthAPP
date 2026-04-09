import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/heart_rate_provider.dart';
import '../providers/step_count_provider.dart';
import 'ble_device_page.dart';
import 'heart_rate_detail_page.dart';
import 'step_count_detail_page.dart';

class HealthPage extends StatelessWidget {
  final Color themeColor;
  const HealthPage({super.key, this.themeColor = Colors.deepPurple});

  void _showAddDeviceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加设备'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.watch),
              title: const Text('智能手表 (ESP32-S3)'),
              subtitle: const Text('通过BLE连接'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BLEDevicePage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.devices),
              title: const Text('其他设备'),
              subtitle: const Text('暂不支持'),
              enabled: false,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('健康'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddDeviceDialog(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [themeColor, Color.fromARGB(178, (themeColor.r * 255.0).round().clamp(0, 255), (themeColor.g * 255.0).round().clamp(0, 255), (themeColor.b * 255.0).round().clamp(0, 255))],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromARGB(51, 255, 255, 255),
                    ),
                    child: const Center(
                      child: Text('--', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildHealthDataItem('卡路里', '--', '千卡'),
                      _buildHealthDataItem('步数', '--', '步'),
                      _buildHealthDataItem('活动', '--', '次'),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  Consumer<HeartRateProvider>(
                    builder: (context, provider, child) {
                      final latest = provider.getLatestData();
                      return _buildClickableSmallCard(
                        context,
                        Icons.favorite,
                        '心率',
                        latest != null ? '${latest.heartRate}' : '--',
                        Colors.red,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HeartRateDetailPage(),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  Consumer<StepCountProvider>(
                    builder: (context, provider, child) {
                      final latest = provider.getLatestData();
                      return _buildClickableSmallCard(
                        context,
                        Icons.directions_walk,
                        '步数',
                        latest != null ? '${latest.stepCount}' : '--',
                        themeColor,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const StepCountDetailPage(),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthDataItem(String title, String value, String unit) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text('$title ($unit)', style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  Widget _buildClickableSmallCard(
    BuildContext context,
    IconData icon,
    String title,
    String value,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
