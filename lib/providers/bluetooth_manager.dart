import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothManager extends ChangeNotifier {
  BluetoothDevice? _connectedDevice;
  List<BluetoothCharacteristic> _characteristics = [];
  String _statusMessage = "Not connected";

  BluetoothDevice? get connectedDevice => _connectedDevice;
  List<BluetoothCharacteristic> get characteristics => _characteristics;
  String get statusMessage => _statusMessage;

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      _connectedDevice = device;

      // Discover services and characteristics
      List<BluetoothService> services = await device.discoverServices();
      _characteristics = [];
      for (BluetoothService service in services) {
        _characteristics.addAll(service.characteristics);
      }

      _statusMessage = "Connected to ${device.name}";
      notifyListeners();
    } catch (e) {
      _statusMessage = "Failed to connect: $e";
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      _connectedDevice = null;
      _characteristics.clear();
      _statusMessage = "Not connected";
      notifyListeners();
    }
  }

  Future<void> readCharacteristic(BluetoothCharacteristic characteristic) async {
    try {
      List<int> value = await characteristic.read();
      String message = String.fromCharCodes(value);
      _statusMessage = "Read: $message";
      notifyListeners();
    } catch (e) {
      _statusMessage = "Error reading characteristic: $e";
      notifyListeners();
    }
  }
}
