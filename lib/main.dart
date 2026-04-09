import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/heart_rate_provider.dart';
import 'providers/step_count_provider.dart';
import 'providers/ble_device_provider.dart';
import 'pages/health_page.dart';
import 'pages/my_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => HeartRateProvider()),
        ChangeNotifierProvider(create: (context) => StepCountProvider()),
        ChangeNotifierProvider(create: (context) => BLEDeviceProvider(
          Provider.of<HeartRateProvider>(context, listen: false),
          Provider.of<StepCountProvider>(context, listen: false),
        )),
      ],
      child: MaterialApp(
        title: '健康',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MainPage(),
      ),
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
