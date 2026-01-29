import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '健康',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  Color _themeColor = Colors.deepPurple;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentIndex == 0
          ? HealthPage(themeColor: _themeColor)
          : MyPage(
              themeColor: _themeColor,
              onThemeChanged: (color) {
                setState(() {
                  _themeColor = color;
                });
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: '健康',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}

class HealthPage extends StatelessWidget {
  final Color themeColor;
  const HealthPage({super.key, this.themeColor = Colors.deepPurple});

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
            // 健康概览卡片
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [themeColor, themeColor.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  // 环形进度图（简化版）
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: const Center(
                      child: Text('80%', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 健康数据
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildHealthDataItem('卡路里', '80', '千卡'),
                      _buildHealthDataItem('步数', '394', '步'),
                      _buildHealthDataItem('活动', '3', '次'),
                    ],
                  ),
                ],
              ),
            ),

            // 中高强度活动
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[100],
              ),
              child: Row(
                children: [
                  const Icon(Icons.fitness_center, color: Colors.blue),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('中高强度活动')),
                  const Text('0分钟'),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),

            // 小卡片网格布局
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _buildSmallCard(Icons.favorite, '心率', '88次/分', Colors.red),
                  _buildSmallCard(Icons.bloodtype, '血氧饱和度', '95%', Colors.red),
                  _buildSmallCard(Icons.directions_walk, '步数', '394步', themeColor),
                ],
              ),
            ),

            // 管理健康功能
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[100],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('管理健康功能'),
                  const Icon(Icons.chevron_right, color: Colors.grey),
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

  Widget _buildSmallCard(IconData icon, String title, String value, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[100],
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
    );
  }
}



class MyPage extends StatefulWidget {
  final Color themeColor;
  final ValueChanged<Color>? onThemeChanged;
  const MyPage({super.key, this.themeColor = Colors.deepPurple, this.onThemeChanged});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  String? _avatarPath;
  String _gender = '男';
  int _height = 178;
  int _age = 21;
  DateTime _birthday = DateTime(2004, 8, 22);
  String _name = '凛竹九歌';
  bool _showThemePicker = false;

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
            // 用户信息（可自定义）
            GestureDetector(
              onTap: () async {
                // 导航到其他页面前关闭主题选择器
                if (_showThemePicker) {
                  setState(() {
                    _showThemePicker = false;
                  });
                }
                
                final result = await Navigator.push(
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
                        });
                      },
                      onBirthdayChanged: (value) {
                        setState(() {
                          _birthday = value;
                          // 计算年龄
                          final now = DateTime.now();
                          _age = now.year - value.year - (now.month > value.month || (now.month == value.month && now.day >= value.day) ? 0 : 1);
                        });
                      },
                      onHeightChanged: (value) {
                        setState(() {
                          _height = value;
                        });
                      },
                      onNameChanged: (value) {
                        setState(() {
                          _name = value;
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
                      color: Colors.grey.withOpacity(0.1),
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
                        child: _avatarPath != null
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
                              Text('$_height厘米', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                              const SizedBox(width: 12),
                              const Icon(Icons.cake, size: 14, color: Colors.grey),
                              Text('$_age岁', style: const TextStyle(fontSize: 14, color: Colors.grey)),
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



            // 设备信息
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey[50],
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
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
                            const Text('小米手环8 NFC版', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const Text('已连接，距上次充满已2天', style: TextStyle(fontSize: 14, color: Colors.grey)),
                            const Text('电量60%', style: TextStyle(fontSize: 14, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.themeColor,
                      foregroundColor: widget.themeColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('同步', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),

            // 底部的主题、App版本和关于
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
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
                              color: widget.themeColor.withOpacity(0.1),
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

            // 主题颜色选择器
            if (_showThemePicker)
              Container(
                margin: const EdgeInsets.only(top: 16, bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text('选择主题颜色', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildColorOption(Colors.deepPurple, '深紫色'),
                        _buildColorOption(Colors.blue, '蓝色'),
                        _buildColorOption(Colors.green, '绿色'),
                        _buildColorOption(Colors.red, '红色'),
                        _buildColorOption(Colors.orange, '橙色'),
                        _buildColorOption(Colors.pink, '粉色'),
                        _buildColorOption(Colors.teal, '青色'),
                        _buildColorOption(Colors.indigo, '靛蓝色'),
                      ],
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
              color: widget.themeColor.withOpacity(0.1),
            ),
            child: Icon(icon, color: widget.themeColor),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
          if (subtitle.isNotEmpty)
            Text(subtitle, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _avatarPath = pickedFile.path;
      });
    }
  }

  Widget _buildColorOption(Color color, String name) {
    return GestureDetector(
      onTap: () {
        widget.onThemeChanged?.call(color);
        setState(() {
          _showThemePicker = false;
        });
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class PersonalInfoPage extends StatefulWidget {
  final String? avatarPath;
  final String gender;
  final DateTime birthday;
  final int height;
  final String name;
  final Color themeColor;
  final ValueChanged<String>? onGenderChanged;
  final ValueChanged<DateTime>? onBirthdayChanged;
  final ValueChanged<int>? onHeightChanged;
  final ValueChanged<String?>? onAvatarPathChanged;
  final ValueChanged<String>? onNameChanged;

  const PersonalInfoPage({
    super.key,
    this.avatarPath,
    required this.gender,
    required this.birthday,
    required this.height,
    required this.name,
    this.themeColor = Colors.deepPurple,
    this.onGenderChanged,
    this.onBirthdayChanged,
    this.onHeightChanged,
    this.onAvatarPathChanged,
    this.onNameChanged,
  });

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  late String _gender;
  late DateTime _birthday;
  late int _height;
  late String _name;
  DateTime? _tempBirthday;
  String? _tempGender;
  int? _tempHeight;
  bool _showGenderPicker = false;
  bool _showBirthdayPicker = false;
  bool _showHeightPicker = false;
  bool _showNameEditor = false;
  String _tempName = '';

  @override
  void initState() {
    super.initState();
    _gender = widget.gender;
    _birthday = widget.birthday;
    _height = widget.height;
    _name = widget.name;
    _tempGender = widget.gender;
    _tempHeight = widget.height;
    _tempName = _name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人信息'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 用户头像和名称
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  color: Colors.grey[300],
                                ),
                                margin: const EdgeInsets.only(bottom: 16),
                              ),
                              ListTile(
                                leading: const Icon(Icons.image),
                                title: const Text('从相册选择头像'),
                                onTap: () async {
                                  Navigator.pop(context);
                                  final pickedFile = await ImagePicker().pickImage(
                                    source: ImageSource.gallery,
                                    imageQuality: 80,
                                  );
                                  if (pickedFile != null) {
                                    setState(() {
                                      widget.onAvatarPathChanged?.call(pickedFile.path);
                                    });
                                  }
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.edit),
                                title: const Text('修改昵称'),
                                onTap: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    _tempName = _name;
                                    _showNameEditor = true;
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 8), // 头像右移
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                            color: Colors.grey[200],
                          ),
                          child: widget.avatarPath != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(40),
                                  child: Image.file(
                                    File(widget.avatarPath!),
                                    fit: BoxFit.cover,
                                    width: 80,
                                    height: 80,
                                  ),
                                )
                              : const Center(
                                  child: Icon(Icons.person, size: 40),
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 性别
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _tempGender = _gender;
                      _showGenderPicker = true;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('性别', style: TextStyle(fontSize: 16)),
                        Row(
                          children: [
                            Text(_gender, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 生日
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _tempBirthday = _birthday;
                      _showBirthdayPicker = true;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('生日', style: TextStyle(fontSize: 16)),
                        Row(
                          children: [
                            Text('${_birthday.year}年${_birthday.month}月${_birthday.day}日', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 身高
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _tempHeight = _height;
                      _showHeightPicker = true;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('身高', style: TextStyle(fontSize: 16)),
                        Row(
                          children: [
                            Text('$_height厘米', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 遮罩层
          if (_showGenderPicker || _showBirthdayPicker || _showHeightPicker || _showNameEditor)
            GestureDetector(
              onTap: () {
                setState(() {
                  _tempGender = _gender;
                  _tempBirthday = _birthday;
                  _tempHeight = _height;
                  _tempName = _name;
                  _showGenderPicker = false;
                  _showBirthdayPicker = false;
                  _showHeightPicker = false;
                  _showNameEditor = false;
                });
              },
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),

          // 性别选择器
          if (_showGenderPicker)
            _buildGenderPicker(),

          // 生日选择器
          if (_showBirthdayPicker)
            _buildBirthdayPicker(),

          // 身高选择器
          if (_showHeightPicker)
            _buildHeightPicker(),

          // 昵称编辑
          if (_showNameEditor)
            _buildNameEditor(),
        ],
      ),
    );
  }

  Widget _buildGenderPicker() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('性别', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Container(
              height: 200,
              child: CupertinoPicker(
                itemExtent: 50,
                scrollController: FixedExtentScrollController(initialItem: _gender == '男' ? 0 : 1),
                onSelectedItemChanged: (index) {
                  setState(() {
                    _tempGender = index == 0 ? '男' : '女';
                  });
                },
                children: const [
                  Center(child: Text('男')),
                  Center(child: Text('女')),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _tempGender = _gender;
                        _showGenderPicker = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('取消', style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onGenderChanged?.call(_tempGender ?? _gender);
                      setState(() {
                        _gender = _tempGender ?? _gender;
                        _showGenderPicker = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.themeColor,
                      foregroundColor: widget.themeColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('确定'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBirthdayPicker() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('生日', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Container(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: CupertinoPicker(
                            itemExtent: 50,
                            scrollController: FixedExtentScrollController(initialItem: _birthday.year - 1900),
                            onSelectedItemChanged: (index) {
                              setState(() {
                                _tempBirthday = DateTime(1900 + index, (_tempBirthday ?? _birthday).month, (_tempBirthday ?? _birthday).day);
                              });
                            },
                            children: List.generate(DateTime.now().year - 1900 + 1, (index) {
                              return Center(child: Text('${1900 + index}'));
                            }),
                          ),
                        ),
                        const Text('年', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: CupertinoPicker(
                            itemExtent: 50,
                            scrollController: FixedExtentScrollController(initialItem: _birthday.month - 1),
                            onSelectedItemChanged: (index) {
                              setState(() {
                                _tempBirthday = DateTime((_tempBirthday ?? _birthday).year, index + 1, (_tempBirthday ?? _birthday).day);
                              });
                            },
                            children: List.generate(12, (index) {
                              return Center(child: Text('${index + 1}'));
                            }),
                          ),
                        ),
                        const Text('月', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: CupertinoPicker(
                            itemExtent: 50,
                            scrollController: FixedExtentScrollController(initialItem: _birthday.day - 1),
                            onSelectedItemChanged: (index) {
                              setState(() {
                                _tempBirthday = DateTime((_tempBirthday ?? _birthday).year, (_tempBirthday ?? _birthday).month, index + 1);
                              });
                            },
                            children: List.generate(31, (index) {
                              return Center(child: Text('${index + 1}'));
                            }),
                          ),
                        ),
                        const Text('日', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _tempBirthday = _birthday;
                        _showBirthdayPicker = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('取消', style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onBirthdayChanged?.call(_tempBirthday ?? _birthday);
                      setState(() {
                        _birthday = _tempBirthday ?? _birthday;
                        _showBirthdayPicker = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.themeColor ?? Colors.deepPurple,
                      foregroundColor: (widget.themeColor ?? Colors.deepPurple).computeLuminance() > 0.5 ? Colors.black : Colors.white,
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('确定'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeightPicker() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('身高', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Container(
              height: 200,
              child: CupertinoPicker(
                itemExtent: 50,
                onSelectedItemChanged: (index) {
                  setState(() {
                    _tempHeight = 100 + index;
                  });
                },
                children: List.generate(150, (index) {
                  int height = 100 + index;
                  return Center(child: Text('$height厘米'));
                }),
                scrollController: FixedExtentScrollController(initialItem: _height - 100),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _tempHeight = _height;
                        _showHeightPicker = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('取消', style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onHeightChanged?.call(_tempHeight ?? _height);
                      setState(() {
                        _height = _tempHeight ?? _height;
                        _showHeightPicker = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.themeColor ?? Colors.deepPurple,
                      foregroundColor: (widget.themeColor ?? Colors.deepPurple).computeLuminance() > 0.5 ? Colors.black : Colors.white,
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('确定'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameEditor() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('编辑昵称', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: TextEditingController(text: _tempName),
                onChanged: (value) {
                  _tempName = value;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: '请输入昵称',
                ),
                textAlign: TextAlign.center,
                maxLength: 10,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _tempName = _name;
                        _showNameEditor = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('取消', style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onNameChanged?.call(_tempName);
                      setState(() {
                        _name = _tempName;
                        _showNameEditor = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.themeColor ?? Colors.deepPurple,
                      foregroundColor: (widget.themeColor ?? Colors.deepPurple).computeLuminance() > 0.5 ? Colors.black : Colors.white,
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('确定'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void _showAddDeviceDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('添加设备'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      );
    },
  );
}
