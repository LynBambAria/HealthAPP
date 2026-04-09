import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../providers/ble_device_provider.dart';

class BLEDevicePage extends StatefulWidget {
  const BLEDevicePage({super.key});

  @override
  State<BLEDevicePage> createState() => _BLEDevicePageState();
}

class _BLEDevicePageState extends State<BLEDevicePage> {
  StreamSubscription<List<ScanResult>>? scanSubscription;
  StreamSubscription<BluetoothConnectionState>? deviceStateSubscription;
  
  BluetoothDevice? targetDevice;
  List<ScanResult> foundDevices = [];
  List<ScanResult> _knownDevices = [];
  List<ScanResult> _unknownDevices = [];
  
  bool isScanning = false;
  String statusMessage = '准备扫描';

  @override
  void initState() {
    super.initState();
    final bleProvider = Provider.of<BLEDeviceProvider>(context, listen: false);
    if (bleProvider.isConnected) {
      targetDevice = bleProvider.connectedDevice;
    }
    _startScan();
  }

  @override
  void dispose() {
    scanSubscription?.cancel();
    deviceStateSubscription?.cancel();
    super.dispose();
  }

  void _startScan() async {
    // 检查蓝牙状态
    BluetoothAdapterState adapterState = await FlutterBluePlus.adapterState.first;
    if (adapterState != BluetoothAdapterState.on) {
      setState(() {
        statusMessage = '请开启蓝牙';
        isScanning = false;
      });
      return;
    }

    // 请求权限
    bool hasPermission = await _requestPermissions();
    if (!hasPermission) {
      setState(() {
        statusMessage = '需要权限才能扫描设备';
        isScanning = false;
      });
      return;
    }

    setState(() {
      isScanning = true;
      statusMessage = '正在扫描设备...';
      foundDevices = [];
      _knownDevices = [];
      _unknownDevices = [];
    });

    try {
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

      scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        setState(() {
          // 去重并分组已知设备和未知设备
          for (ScanResult result in results) {
            bool isNewDevice = true;
            for (ScanResult existingDevice in foundDevices) {
              if (existingDevice.device.remoteId == result.device.remoteId) {
                isNewDevice = false;
                break;
              }
            }
            if (isNewDevice) {
              foundDevices.add(result);
              if (result.device.platformName.isNotEmpty) {
                _knownDevices.add(result);
              } else {
                _unknownDevices.add(result);
              }
            }
          }
        });
      });

      FlutterBluePlus.isScanning.listen((state) {
        if (!state && isScanning) {
          setState(() {
            isScanning = false;
            if (targetDevice == null) {
              statusMessage = foundDevices.isEmpty ? '未找到设备，请点击重新扫描' : '请选择要连接的设备';
            }
          });
        }
      });
    } catch (e) {
      setState(() {
        statusMessage = '扫描失败：$e';
        isScanning = false;
      });
    }
  }

  Future<bool> _requestPermissions() async {
    // 请求位置权限（用于蓝牙扫描）
    var locationStatus = await Permission.location.status;
    if (!locationStatus.isGranted) {
      locationStatus = await Permission.location.request();
      if (!locationStatus.isGranted) {
        return false;
      }
    }

    return true;
  }

  void _foundDevice(BluetoothDevice device) {
    setState(() {
      targetDevice = device;
      statusMessage = '找到设备：${device.platformName}';
    });

    FlutterBluePlus.stopScan();
    _connectToDevice(device);
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    setState(() {
      statusMessage = '正在连接设备...';
    });

    try {
      final bleProvider = Provider.of<BLEDeviceProvider>(context, listen: false);
      bool success = await bleProvider.connectToDevice(device);
      
      deviceStateSubscription = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected && mounted) {
          setState(() {
            statusMessage = '设备已断开连接';
          });
        }
      });

      if (success && mounted) {
        setState(() {
          statusMessage = '已连接设备';
        });
      } else if (mounted) {
        setState(() {
          statusMessage = '连接失败';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          statusMessage = '连接失败：$e';
        });
      }
    }
  }

  void _disconnect() async {
    final bleProvider = Provider.of<BLEDeviceProvider>(context, listen: false);
    await bleProvider.disconnect();
    setState(() {
      statusMessage = '已断开连接';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('智能手表连接'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final bleProvider = Provider.of<BLEDeviceProvider>(context, listen: false);
              if (bleProvider.isConnected) {
                _startScan();
              } else {
                _disconnect();
                _startScan();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 固定部分
          Column(
            children: [
              // 连接状态
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Provider.of<BLEDeviceProvider>(context).isConnected ? Colors.green[100] : Colors.red[100],
                ),
                child: Text(
                  statusMessage,
                  style: TextStyle(
                    fontSize: 16,
                    color: Provider.of<BLEDeviceProvider>(context).isConnected ? Colors.green[800] : Colors.red[800],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // 操作按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!Provider.of<BLEDeviceProvider>(context).isConnected) 
                    ElevatedButton(
                      onPressed: _startScan,
                      child: const Text('重新扫描'),
                    ),
                  if (Provider.of<BLEDeviceProvider>(context).isConnected) 
                    ElevatedButton(
                      onPressed: _disconnect,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('断开连接'),
                    ),
                ],
              ),

              // 设备列表标题
              if (!Provider.of<BLEDeviceProvider>(context).isConnected && foundDevices.isNotEmpty) 
                Container(
                  margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
                  alignment: Alignment.centerLeft,
                  child: const Text('发现的设备', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
            ],
          ),

          // 可滚动部分
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 设备列表
                  if (!Provider.of<BLEDeviceProvider>(context).isConnected && foundDevices.isNotEmpty) 
                    Container(
                      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                      child: Column(
                        children: [
                          // 已知设备（有名称）
                          ..._buildKnownDevicesList(),
                          
                          // 未知设备（折叠）
                          if (_unknownDevices.isNotEmpty)
                            Container(
                               decoration: BoxDecoration(
                                 border: Border.all(color: Colors.grey[300]!),
                                 borderRadius: BorderRadius.circular(8),
                               ),
                               child: Theme(
                                 data: Theme.of(context).copyWith(
                                   dividerColor: Colors.transparent,
                                 ),
                                 child: ExpansionTile(
                                   title: const Padding(
                                     padding: EdgeInsets.only(left: 16),
                                     child: Text('未知设备'),
                                   ),
                                   initiallyExpanded: false,
                                   tilePadding: EdgeInsets.zero,
                                   childrenPadding: EdgeInsets.zero,
                                   children: [
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: _unknownDevices.length,
                                      itemBuilder: (context, index) {
                                        ScanResult result = _unknownDevices[index];
                                        return Card(
                                          child: ListTile(
                                            title: const Text('未知设备'),
                                            subtitle: Text('${result.device.remoteId}'),
                                            trailing: const Icon(Icons.chevron_right),
                                            onTap: () {
                                              _foundDevice(result.device);
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                          ),
                        ],
                      ),
                    ),

                  // 设备信息
                  if (targetDevice != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[100],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('设备信息', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('设备名称: ${targetDevice!.platformName}'),
                          Text('设备ID: ${targetDevice!.remoteId}'),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildKnownDevicesList() {
    return _knownDevices.map((result) {
      return Card(
        child: ListTile(
          title: Text(result.device.platformName),
          subtitle: Text('${result.device.remoteId}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _foundDevice(result.device);
          },
        ),
      );
    }).toList();
  }
}
