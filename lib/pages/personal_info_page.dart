import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  int _getDaysInMonth(int year, int month) {
    if (month == 2) {
      return _isLeapYear(year) ? 29 : 28;
    } else if ([4, 6, 9, 11].contains(month)) {
      return 30;
    } else {
      return 31;
    }
  }

  bool _isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

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
                          color: Color.fromARGB(26, 128, 128, 128),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 8),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                            color: Colors.grey[200],
                          ),
                          child: widget.avatarPath != null && widget.avatarPath!.isNotEmpty
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
                              Text(_name == '--' ? '去设置' : _name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                GestureDetector(
                  onTap: () {
                    setState(() {
                      _tempGender = '男';
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
                          color: Color.fromARGB(26, 128, 128, 128),
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
                            Text(_gender == '--' ? '去设置' : _gender, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

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
                          color: Color.fromARGB(26, 128, 128, 128),
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
                            Text(_birthday.year == DateTime.now().year && _birthday.month == DateTime.now().month && _birthday.day == DateTime.now().day ? '去设置' : '${_birthday.year}年${_birthday.month}月${_birthday.day}日', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

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
                          color: Color.fromARGB(26, 128, 128, 128),
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
                            Text(_height == 0 ? '去设置' : '$_height厘米', style: const TextStyle(fontSize: 16, color: Colors.grey)),
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
                color: Color.fromARGB(128, 0, 0, 0),
              ),
            ),

          if (_showGenderPicker)
            _buildGenderPicker(),

          if (_showBirthdayPicker)
            _buildBirthdayPicker(),

          if (_showHeightPicker)
            _buildHeightEditor(),

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
            SizedBox(
              height: 200,
              child: CupertinoPicker(
                itemExtent: 50,
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
                        _gender = _tempGender ?? _gender;
                        widget.onGenderChanged?.call(_gender);
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
    int currentYear = (_tempBirthday ?? _birthday).year;
    int currentMonth = (_tempBirthday ?? _birthday).month;
    int currentDay = (_tempBirthday ?? _birthday).day;
    int daysInMonth = _getDaysInMonth(currentYear, currentMonth);
    
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
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: CupertinoPicker(
                            itemExtent: 50,
                            scrollController: FixedExtentScrollController(initialItem: currentYear - 1900),
                            onSelectedItemChanged: (index) {
                              int newYear = 1900 + index;
                              int newDaysInMonth = _getDaysInMonth(newYear, currentMonth);
                              int newDay = currentDay > newDaysInMonth ? newDaysInMonth : currentDay;
                              setState(() {
                                _tempBirthday = DateTime(newYear, currentMonth, newDay);
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
                            scrollController: FixedExtentScrollController(initialItem: currentMonth - 1),
                            onSelectedItemChanged: (index) {
                              int newMonth = index + 1;
                              int newDaysInMonth = _getDaysInMonth(currentYear, newMonth);
                              int newDay = currentDay > newDaysInMonth ? newDaysInMonth : currentDay;
                              setState(() {
                                _tempBirthday = DateTime(currentYear, newMonth, newDay);
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
                            scrollController: FixedExtentScrollController(initialItem: currentDay - 1),
                            onSelectedItemChanged: (index) {
                              setState(() {
                                _tempBirthday = DateTime(currentYear, currentMonth, index + 1);
                              });
                            },
                            children: List.generate(daysInMonth, (index) {
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

  Widget _buildHeightEditor() {
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
            const Text('编辑身高', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: TextEditingController(text: _height > 0 ? '$_height' : ''),
                onChanged: (value) {
                  _tempHeight = int.tryParse(value) ?? _height;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: '请输入身高（厘米）',
                ),
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 3,
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
                controller: TextEditingController(text: _tempName == '--' ? '' : _tempName),
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
}
