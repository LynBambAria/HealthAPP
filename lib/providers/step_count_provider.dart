import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/step_count_data.dart';

class StepCountProvider extends ChangeNotifier {
  List<StepCountData> _stepCountHistory = [];
  int? _currentStepCount;

  List<StepCountData> get stepCountHistory => _stepCountHistory;
  int? get currentStepCount => _currentStepCount;

  StepCountProvider() {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('stepCountHistory');
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      _stepCountHistory = jsonList.map((json) => StepCountData.fromJson(json)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = json.encode(
      _stepCountHistory.map((data) => data.toJson()).toList(),
    );
    await prefs.setString('stepCountHistory', jsonString);
  }

  void addStepCount(int stepCount) {
    _currentStepCount = stepCount;
    _stepCountHistory.add(StepCountData(
      stepCount: stepCount,
      timestamp: DateTime.now(),
    ));
    _saveHistory();
    notifyListeners();
  }

  List<StepCountData> getTodayData() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _stepCountHistory.where((data) {
      final dataDate = DateTime(data.timestamp.year, data.timestamp.month, data.timestamp.day);
      return dataDate.isAtSameMomentAs(today);
    }).toList();
  }

  StepCountData? getLatestData() {
    if (_stepCountHistory.isEmpty) return null;
    return _stepCountHistory.last;
  }

  void clearHistory() {
    _stepCountHistory.clear();
    _currentStepCount = null;
    _saveHistory();
    notifyListeners();
  }
}
