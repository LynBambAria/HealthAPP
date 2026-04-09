import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'heart_rate_provider.dart';
import 'step_count_provider.dart';

class BLEDeviceProvider extends ChangeNotifier {
  final HeartRateProvider _heartRateProvider;
  final StepCountProvider _stepCountProvider;
  
  BluetoothDevice? _connectedDevice;
  StreamSubscription<List<int>>? _heartRateSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;
  bool _isConnected = false;

  BluetoothDevice? get connectedDevice => _connectedDevice;
  bool get isConnected => _isConnected;
  String? get deviceName => _connectedDevice?.platformName;

  BLEDeviceProvider(this._heartRateProvider, this._stepCountProvider);

  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      _connectedDevice = device;
      _isConnected = true;
      
      _connectionStateSubscription = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _isConnected = false;
          _connectedDevice = null;
          _heartRateSubscription?.cancel();
          _connectionStateSubscription?.cancel();
          notifyListeners();
        }
      });
      
      await _discoverServices(device);
      notifyListeners();
      return true;
    } catch (e) {
      print('连接失败: $e');
      _isConnected = false;
      _connectedDevice = null;
      notifyListeners();
      return false;
    }
  }

  Future<void> _discoverServices(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    
    for (BluetoothService service in services) {
      if (service.uuid.toString() == '000000ff-0000-1000-8000-00805f9b34fb' || 
          service.uuid.toString() == '00ff') {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          if (characteristic.uuid.toString() == '0000ff01-0000-1000-8000-00805f9b34fb' || 
              characteristic.uuid.toString() == 'ff01') {
            await _enableHeartRateNotifications(characteristic);
          }
          if (characteristic.uuid.toString() == '0000ff02-0000-1000-8000-00805f9b34fb' || 
              characteristic.uuid.toString() == 'ff02') {
            await _enableStepCountNotifications(characteristic);
          }
        }
      }
    }
  }

  Future<void> _enableHeartRateNotifications(BluetoothCharacteristic characteristic) async {
    await characteristic.setNotifyValue(true);
    
    _heartRateSubscription = characteristic.lastValueStream.listen((value) {
      if (value.length >= 2) {
        int heartRateValue = value[1];
        _heartRateProvider.addHeartRate(heartRateValue);
      }
    });
  }

  Future<void> _enableStepCountNotifications(BluetoothCharacteristic characteristic) async {
    await characteristic.setNotifyValue(true);
    
    _heartRateSubscription = characteristic.lastValueStream.listen((value) {
      if (value.length >= 4) {
        // 4字节大端格式
        int stepCount = (value[0] << 24) | (value[1] << 16) | (value[2] << 8) | value[3];
        _stepCountProvider.addStepCount(stepCount);
      }
    });
  }

  Future<void> disconnect() async {
    _connectionStateSubscription?.cancel();
    _heartRateSubscription?.cancel();
    await _connectedDevice?.disconnect();
    _connectedDevice = null;
    _isConnected = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _heartRateSubscription?.cancel();
    super.dispose();
  }
}
