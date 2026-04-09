import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/heart_rate_data.dart';

class HeartRateProvider extends ChangeNotifier {
  List<HeartRateData> _heartRateHistory = [];
  int? _currentHeartRate;

  List<HeartRateData> get heartRateHistory => _heartRateHistory;
  int? get currentHeartRate => _currentHeartRate;

  HeartRateProvider() {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('heartRateHistory');
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      _heartRateHistory = jsonList.map((json) => HeartRateData.fromJson(json)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = json.encode(
      _heartRateHistory.map((data) => data.toJson()).toList(),
    );
    await prefs.setString('heartRateHistory', jsonString);
  }

  void addHeartRate(int heartRate) {
    _currentHeartRate = heartRate;
    _heartRateHistory.add(HeartRateData(
      heartRate: heartRate,
      timestamp: DateTime.now(),
    ));
    _saveHistory();
    notifyListeners();
  }

  List<HeartRateData> getTodayData() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _heartRateHistory.where((data) {
      final dataDate = DateTime(data.timestamp.year, data.timestamp.month, data.timestamp.day);
      return dataDate.isAtSameMomentAs(today);
    }).toList();
  }

  HeartRateData? getLatestData() {
    if (_heartRateHistory.isEmpty) return null;
    return _heartRateHistory.last;
  }

  int? getMinHeartRateToday() {
    final todayData = getTodayData();
    if (todayData.isEmpty) return null;
    return todayData.map((data) => data.heartRate).reduce((a, b) => a < b ? a : b);
  }

  int? getMaxHeartRateToday() {
    final todayData = getTodayData();
    if (todayData.isEmpty) return null;
    return todayData.map((data) => data.heartRate).reduce((a, b) => a > b ? a : b);
  }

  double? getAverageHeartRateToday() {
    final todayData = getTodayData();
    if (todayData.isEmpty) return null;
    final sum = todayData.map((data) => data.heartRate).reduce((a, b) => a + b);
    return sum / todayData.length;
  }

  void clearHistory() {
    _heartRateHistory.clear();
    _currentHeartRate = null;
    _saveHistory();
    notifyListeners();
  }
}
