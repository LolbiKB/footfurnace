import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/material.dart';

class BluetoothManager extends ChangeNotifier {
  BluetoothDevice? _connectedDevice;
  List<BluetoothCharacteristic> _characteristics = [];
  Map<String, StreamSubscription<List<int>>> _subscriptions = {};
  String _statusMessage = "Not connected";

  // UUIDs for characteristics
  final String _targetServiceUUID = "12345678-90AB-CDEF-1234-567890ABCDEF";
  final String _batteryUUID = "1d61b289-e2f0-4af4-99e5-6de4370c8083";
  final String _heatingUUID = "4664c97b-ecc4-40c3-81a2-4789f8ed5e1c";
  final String _powerUUID = "923202f1-68ce-42c8-bf28-df8a38f37d86";

  // Latest values from characteristics
  Map<String, dynamic> _batteryData = {};
  Map<String, dynamic> _heatingData = {};
  Map<String, dynamic> _powerData = {};

  // Public getters
  BluetoothDevice? get connectedDevice => _connectedDevice;
  List<BluetoothCharacteristic> get characteristics =>
      List.unmodifiable(_characteristics);
  String get statusMessage => _statusMessage;

  // Component-specific getters
  Map<String, dynamic> get batteryData => _batteryData;
  Map<String, dynamic> get heatingData => _heatingData;
  Map<String, dynamic> get powerData => _powerData;

  // Detect already connected devices with the target service UUID
  Future<void> detectConnectedDevice() async {
    try {
      List<BluetoothDevice> devices =
          await FlutterBluePlus.systemDevices([Guid(_targetServiceUUID)]);
      for (var device in devices) {
        await _connectToDevice(device);
        break; // Stop after the first successful connection
      }
    } catch (e) {
      _statusMessage = "Error detecting devices: $e";
      notifyListeners();
    }
  }

  // Connect to a specific device
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await _connectToDevice(device);
    } catch (e) {
      _statusMessage = "Failed to connect: $e";
      notifyListeners();
    }
  }

  // Private method to connect, discover services, and subscribe to characteristics
// Changes in `_connectToDevice` method to read characteristic values immediately after discovery
  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      _connectedDevice = device;

      // Discover services
      List<BluetoothService> services = await device.discoverServices();
      _characteristics = [];
      print("Discovered Services:");
      for (var service in services) {
        print("Service UUID: ${service.uuid}");
        if (service.uuid.toString().toUpperCase() ==
            _targetServiceUUID.toUpperCase()) {
          for (var characteristic in service.characteristics) {
            print("  Characteristic UUID: ${characteristic.uuid}");
            _characteristics.add(characteristic);

            // Immediately read the characteristic value
            await _readAndStoreCharacteristicValue(characteristic);

            // Subscribe based on characteristic UUID
            if (characteristic.uuid.toString().toUpperCase() ==
                _batteryUUID.toUpperCase()) {
              _subscribeToCharacteristic(characteristic, "Battery");
            } else if (characteristic.uuid.toString().toUpperCase() ==
                _heatingUUID.toUpperCase()) {
              _subscribeToCharacteristic(characteristic, "Heating");
            } else if (characteristic.uuid.toString().toUpperCase() ==
                _powerUUID.toUpperCase()) {
              _subscribeToCharacteristic(characteristic, "Power");
            }
          }
        }
      }

      if (_characteristics.isNotEmpty) {
        _statusMessage = "Connected to ${device.platformName}";
      } else {
        _statusMessage = "No characteristics found for target UUID";
      }

      notifyListeners();
    } catch (e) {
      if (_connectedDevice != null) {
        await disconnect();
      }
      rethrow;
    }
  }

// Helper method to read and store the characteristic value
Future<void> _readAndStoreCharacteristicValue(
    BluetoothCharacteristic characteristic) async {
  try {
    List<int> value = await characteristic.read();
    final data = String.fromCharCodes(value);

    // Check and log UUID comparison for debugging
    final uuid = characteristic.uuid.toString().toUpperCase();
    if (uuid == _batteryUUID.toUpperCase()) {
      _batteryData = _parseCharacteristicData(data);
    } else if (uuid == _heatingUUID.toUpperCase()) {
      _heatingData = _parseCharacteristicData(data);;
    } else if (uuid == _powerUUID.toUpperCase()) {
      _powerData = _parseCharacteristicData(data);
    } else {
    }

    // Notify listeners of updates
    notifyListeners();
  } catch (e) {
    print("Error reading characteristic: $e");
  }
}


  // Subscribe to a characteristic and parse data
void _subscribeToCharacteristic(
    BluetoothCharacteristic characteristic, String characteristicName) {
  characteristic.setNotifyValue(true).then((_) {
    final subscription = characteristic.onValueReceived.listen((value) {
      final data = String.fromCharCodes(value);

      // Update specific data based on the characteristic
      switch (characteristicName) {
        case "Battery":
          _batteryData = _parseCharacteristicData(data);
          break;
        case "Heating":
          _heatingData = _parseCharacteristicData(data);
          break;
        case "Power":
          _powerData = _parseCharacteristicData(data);
          break;
      }
      notifyListeners();
    });

    // Cancel subscription when device disconnects
    _connectedDevice!.cancelWhenDisconnected(subscription);
    _subscriptions[characteristic.uuid.toString()] = subscription;
  }).catchError((e) {
    print("Failed to set notifications for $characteristicName: $e");
  });
}

  // Helper to parse JSON data from characteristic
  Map<String, dynamic> _parseCharacteristicData(String data) {
    try {
      return jsonDecode(data);
    } catch (e) {
      print("Error parsing data: $e");
      return {};
    }
  }

  // Disconnect the currently connected device
  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      _connectedDevice = null;
      _characteristics.clear();
      _subscriptions.forEach((_, subscription) => subscription.cancel());
      _subscriptions.clear();
      _batteryData = {};
      _heatingData = {};
      _powerData = {};
      _statusMessage = "Not connected";
      notifyListeners();
    }
  }

  // Read data from a characteristic
  Future<void> readCharacteristic(
      BluetoothCharacteristic characteristic) async {
    try {
      List<int> value = await characteristic.read();
      String message = String.fromCharCodes(value);
      notifyListeners();
    } catch (e) {
      notifyListeners();
    }
  }
}
