import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:footfurnace/providers/bluetooth_manager.dart'; // Import BluetoothManager

class BluetoothSettingsPage extends StatefulWidget {
  const BluetoothSettingsPage({super.key});

  @override
  _BluetoothSettingsPageState createState() => _BluetoothSettingsPageState();
}

class _BluetoothSettingsPageState extends State<BluetoothSettingsPage> {
  final List<BluetoothDevice> _devicesList = [];
  List<BluetoothCharacteristic> _characteristics = [];
  String _statusMessage = "Checking Bluetooth status...";
  late StreamSubscription _adapterStateSubscription;
  late StreamSubscription _scanResultsSubscription;
  late StreamSubscription _isScanningSubscription;
  late Timer _rescanTimer;

  final String _targetDeviceUUID = "12345678-90AB-CDEF-1234-567890ABCDEF"; // Replace with your UUID

  @override
  void initState() {
    super.initState();
    final bluetoothManager = Provider.of<BluetoothManager>(context, listen: false);

    if (bluetoothManager.connectedDevice != null) {
      // If there is an existing connection, use it
      setState(() {
        _statusMessage = "Connected to ${bluetoothManager.connectedDevice!.name}";
        _characteristics = bluetoothManager.characteristics;
      });
    } else {
      // If no connection, initialize Bluetooth for scanning
      _initializeBluetooth();
      _startPeriodicRescan();
    }
  }

  Future<void> _initializeBluetooth() async {
    if (!await FlutterBluePlus.isSupported) {
      if (mounted) {
        setState(() {
          _statusMessage = "Bluetooth not supported on this device.";
        });
      }
      return;
    }

    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      if (mounted) {
        setState(() {
          if (state == BluetoothAdapterState.off) {
            _statusMessage = "Turn on Bluetooth to connect";
            FlutterBluePlus.stopScan();
          } else if (state == BluetoothAdapterState.on) {
            _statusMessage = "Scanning for boots...";
            _startScan();
          }
        });
      }
    });
  }

  void _startPeriodicRescan() {
    _rescanTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _startScan();
      }
    });
  }

  void _startScan() {
    setState(() {
      _statusMessage = "Scanning for boots...";
    });

    _devicesList.clear();

    FlutterBluePlus.startScan(
      withServices: [Guid(_targetDeviceUUID)],
      timeout: const Duration(seconds: 10),
      androidUsesFineLocation: true,
    );

    _scanResultsSubscription = FlutterBluePlus.onScanResults.listen((results) {
      if (mounted) {
        setState(() {
          _devicesList.clear();
          _devicesList.addAll(results.map((result) => result.device));
        });
      }
    }, onError: (error) {
      if (mounted) {
        setState(() {
          _statusMessage = "Error scanning for boots: $error";
        });
      }
    });

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((isScanning) {
      if (!isScanning && mounted) {
        setState(() {
          _statusMessage =
              _devicesList.isEmpty ? "No boots found" : "Select to pair";
        });
      }
    });
  }

  void _connectToDevice(BluetoothDevice device) async {
    final bluetoothManager = Provider.of<BluetoothManager>(context, listen: false);
    try {
      await bluetoothManager.connectToDevice(device);
      setState(() {
        _statusMessage = "Connected to ${device.name}";
        _characteristics = bluetoothManager.characteristics;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = "Failed to connect: $e";
        });
      }
    }
  }

  Future<void> _readCharacteristic(BluetoothCharacteristic characteristic) async {
  final bluetoothManager = Provider.of<BluetoothManager>(context, listen: false);
  try {
    await bluetoothManager.readCharacteristic(characteristic);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Read: ${bluetoothManager.statusMessage}')),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error reading characteristic: $e')),
      );
    }
  }
}

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    _adapterStateSubscription.cancel();
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    _rescanTimer.cancel();
    super.dispose();
  }

  Widget _buildTile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          onTap: onTap,
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Container(
              padding: const EdgeInsets.all(10),
              color: Colors.blue,
              child: const Icon(Icons.smartphone, color: Colors.white, size: 30),
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(subtitle),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_statusMessage),
        const SizedBox(height: 10),
        if (Provider.of<BluetoothManager>(context).connectedDevice != null)
          Expanded(
            child: ListView.builder(
              itemCount: _characteristics.length,
              itemBuilder: (context, index) {
                BluetoothCharacteristic characteristic = _characteristics[index];
                return _buildTile(
                  title: "Characteristic: ${characteristic.uuid}",
                  subtitle: "Properties: ${characteristic.properties}",
                  onTap: () => _readCharacteristic(characteristic),
                );
              },
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: _devicesList.length,
              itemBuilder: (context, index) {
                BluetoothDevice device = _devicesList[index];
                return _buildTile(
                  title: device.platformName.isNotEmpty ? device.platformName : 'Unknown Device',
                  subtitle: 'ID: ${device.remoteId}',
                  onTap: () => _connectToDevice(device),
                );
              },
            ),
          ),
      ],
    );
  }
}
