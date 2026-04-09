import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../providers/ble_device_provider.dart';
import 'personal_info_page.dart';
import 'ble_device_page.dart';

class MyPage extends StatefulWidget {
  final Color themeColor;
  final ValueChanged<Color>? onThemeChanged;
  const MyPage({super.key, this.themeColor = Colors.deepPurple, this.onThemeChanged});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  String? _avatarPath;
  String _gender = '--';
  int _height = 0;
  int _age = 0;
  DateTime _birthday = DateTime.now();
  String _name = '--';
  bool _showThemePicker = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      String? avatarPath = prefs.getString('avatarPath');
      _avatarPath = avatarPath?.isEmpty ?? true ? null : avatarPath;
      _gender = prefs.getString('gender') ?? '--';
      _height = prefs.getInt('height') ?? 0;
      _age = prefs.getInt('age') ?? 0;
      final birthdayMillis = prefs.getInt('birthday');
      _birthday = birthdayMillis != null ? DateTime.fromMillisecondsSinceEpoch(birthdayMillis) : DateTime.now();
      _name = prefs.getString('name') ?? '--';
    });
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('avatarPath', _avatarPath ?? '');
    await prefs.setString('gender', _gender);
    await prefs.setInt('height', _height);
    await prefs.setInt('age', _age);
    await prefs.setInt('birthday', _birthday.millisecondsSinceEpoch);
    await prefs.setString('name', _name);
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _avatarPath = pickedFile.path;
        _saveUserData();
      });
    }
  }

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
        title: const Text('我的'),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: () async {
                if (_showThemePicker) {
                  setState(() {
                    _showThemePicker = false;
                  });
                }
                
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PersonalInfoPage(
                      avatarPath: _avatarPath,
                      gender: _gender,
                      birthday: _birthday,
                      height: _height,
                      name: _name,
                      themeColor: widget.themeColor,
                      onGenderChanged: (value) {
                        setState(() {
                          _gender = value;
                          _saveUserData();
                        });
                      },
                      onBirthdayChanged: (value) {
                        setState(() {
                          _birthday = value;
                          final now = DateTime.now();
                          _age = now.year - value.year - (now.month > value.month || (now.month == value.month && now.day >= value.day) ? 0 : 1);
                          _saveUserData();
                        });
                      },
                      onHeightChanged: (value) {
                        setState(() {
                          _height = value;
                          _saveUserData();
                        });
                      },
                      onNameChanged: (value) {
                        setState(() {
                          _name = value;
                          _saveUserData();
                        });
                      },
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 16),
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
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _pickImage();
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          color: Colors.grey[200],
                        ),
                        child: _avatarPath != null && _avatarPath!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                child: Image.file(
                                  File(_avatarPath!),
                                  fit: BoxFit.cover,
                                  width: 80,
                                  height: 80,
                                ),
                              )
                            : const Center(
                                child: Icon(Icons.person, size: 40),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.person, size: 14, color: Colors.grey),
                              Text(_gender, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                              const SizedBox(width: 12),
                              const Icon(Icons.height, size: 14, color: Colors.grey),
                              Text(_height > 0 ? '$_height厘米' : '--', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                              const SizedBox(width: 12),
                              const Icon(Icons.cake, size: 14, color: Colors.grey),
                              Text(_age > 0 ? '$_age岁' : '--', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ),

            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey[50],
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(51, 128, 128, 128),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Consumer<BLEDeviceProvider>(
                builder: (context, bleProvider, child) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              color: Colors.grey[200],
                            ),
                            child: const Center(
                              child: Icon(Icons.watch, size: 40),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bleProvider.isConnected
                                      ? bleProvider.deviceName ?? '已连接设备'
                                      : '暂无设备连接',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: bleProvider.isConnected
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const BLEDevicePage()),
                                );
                              }
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const BLEDevicePage()),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: bleProvider.isConnected
                              ? widget.themeColor
                              : Colors.grey,
                          foregroundColor: bleProvider.isConnected
                              ? (widget.themeColor.computeLuminance() > 0.5 ? Colors.black : Colors.white)
                              : Colors.white70,
                          minimumSize: const Size(double.infinity, 45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          bleProvider.isConnected ? '管理设备' : '去配对',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

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
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showThemePicker = !_showThemePicker;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color.fromARGB(26, (widget.themeColor.r * 255.0).round().clamp(0, 255), (widget.themeColor.g * 255.0).round().clamp(0, 255), (widget.themeColor.b * 255.0).round().clamp(0, 255)),
                            ),
                            child: Icon(Icons.color_lens, color: widget.themeColor),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(child: Text('主题')),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: widget.themeColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  _buildMyPageItem(Icons.info, 'App版本', 'V1.0.0'),
                  _buildMyPageItem(Icons.description, '关于', ''),
                ],
              ),
            ),

            if (_showThemePicker)
              Container(
                margin: const EdgeInsets.only(top: 16, bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(51, 128, 128, 128),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text('选择主题颜色', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildColorOption(Colors.deepPurple, '深紫色'),
                        _buildColorOption(Colors.blue, '蓝色'),
                        _buildColorOption(Colors.green, '绿色'),
                        _buildColorOption(Colors.orange, '橙色'),
                        _buildColorOption(Colors.red, '红色'),
                        _buildColorOption(Colors.pink, '粉色'),
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

  Widget _buildMyPageItem(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Color.fromARGB((0.2 * 255).round(), (widget.themeColor.r * 255.0).round().clamp(0, 255), (widget.themeColor.g * 255.0).round().clamp(0, 255), (widget.themeColor.b * 255.0).round().clamp(0, 255)),
            ),
            child: Icon(icon, color: widget.themeColor),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
          if (subtitle.isNotEmpty)
            Text(subtitle, style: const TextStyle(color: Colors.grey)),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildColorOption(Color color, String name) {
    return GestureDetector(
      onTap: () {
        widget.onThemeChanged?.call(color);
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: color,
          border: Border.all(
            color: widget.themeColor == color ? Colors.black : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }
}
