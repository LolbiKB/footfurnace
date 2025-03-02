import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:footfurnace/components/boots_settings_tile.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:footfurnace/providers/bluetooth_manager.dart'; // Import BluetoothManager

class BluetoothSettingsPage extends StatefulWidget {
  const BluetoothSettingsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BluetoothSettingsPageState createState() => _BluetoothSettingsPageState();
}

class _BluetoothSettingsPageState extends State<BluetoothSettingsPage> {
  final List<BluetoothDevice> _devicesList = [];
  List<BluetoothCharacteristic> _characteristics = [];
  String _statusMessage = "Checking Bluetooth status...";
  bool _showDetails = false;
  final Map<String, bool> _loadingStates = {};
  late StreamSubscription _adapterStateSubscription;
  late StreamSubscription _scanResultsSubscription;
  late StreamSubscription _isScanningSubscription;

  final String _targetDeviceUUID =
      "12345678-90AB-CDEF-1234-567890ABCDEF"; // Replace with your UUID

  @override
  void initState() {
    super.initState();
    final bluetoothManager =
        Provider.of<BluetoothManager>(context, listen: false);

    if (bluetoothManager.connectedDevice != null) {
      // If there is an existing connection, use it
      setState(() {
        _statusMessage =
            "Connected to ${bluetoothManager.connectedDevice!.name}";
        _characteristics = bluetoothManager.characteristics;
      });
    } else {
      // If no connection, initialize Bluetooth for scanning
      _initializeBluetooth();
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
            _startScan();
          }
        });
      }
    });
  }

  void _startScan() async {
    // Check if scanning is already in progress
    final isScanningNow = await FlutterBluePlus.isScanning.first;
    if (isScanningNow) return;

    setState(() {
      _statusMessage = "Scanning for boots...";
    });

    _devicesList.clear();

    // Start scanning with a timeout
    FlutterBluePlus.startScan(
      withServices: [Guid(_targetDeviceUUID)],
      timeout: const Duration(seconds: 3),
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

    // Listen for when scanning stops
    FlutterBluePlus.isScanning.listen((isScanning) {
      if (mounted) {
        setState(() {
          if (!isScanning) {
            final bluetoothManager =
                Provider.of<BluetoothManager>(context, listen: false);

            _statusMessage = bluetoothManager.connectedDevice == null
                ? (_devicesList.isEmpty
                    ? "No boots found"
                    : "Select a device to connect")
                : "Connected to ${bluetoothManager.connectedDevice!.name}";
          }
        });
      }
    });
  }

void _connectToDevice(BluetoothDevice device) async {
  final bluetoothManager =
      Provider.of<BluetoothManager>(context, listen: false);

  setState(() {
    _loadingStates[device.remoteId.toString()] = true; // Set the device to loading
  });

  try {
    await bluetoothManager.connectToDevice(device);

    setState(() {
      _statusMessage = "Connected to ${device.platformName}";
      _characteristics = bluetoothManager.characteristics;
    });
  } catch (e) {
    if (mounted) {
      setState(() {
        _statusMessage = "Failed to connect: $e";
      });
    }
  } finally {
    setState(() {
      _loadingStates[device.remoteId.toString()] = false; // Reset loading state
    });
  }
}

  Future<void> _readCharacteristic(
      BluetoothCharacteristic characteristic) async {
    final bluetoothManager =
        Provider.of<BluetoothManager>(context, listen: false);
    try {
      dynamic readableData = await bluetoothManager
          .readCharacteristic(characteristic); // Get readable data
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$readableData")),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothManager = Provider.of<BluetoothManager>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _statusMessage,
                style: const TextStyle(fontSize: 16),
              ),
              StreamBuilder<bool>(
                stream: FlutterBluePlus.isScanning,
                initialData: false,
                builder: (context, snapshot) {
                  final isScanning = snapshot.data ?? false;
          
                  if (bluetoothManager.connectedDevice != null) {
                    return ElevatedButton(
                      onPressed: () async {
                        final shouldDisconnect = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Disconnect"),
                                content: const Text(
                                    "Are you sure you want to disconnect?"),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text("Cancel",
                                        style: TextStyle(color: Colors.black)),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text("Confirm",
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            ) ??
                            false;
          
                        if (shouldDisconnect) {
                          await bluetoothManager.disconnect();
                          setState(() {
                            _statusMessage = bluetoothManager.statusMessage;
                            _characteristics.clear();
                            _showDetails =
                                false; // Reset show details on disconnect
                          });
                        }
                      },
                      child: const Text("Disconnect",
                          style: TextStyle(color: Colors.red)),
                    );
                  } else {
                    return ElevatedButton(
                      onPressed: isScanning ? null : _startScan,
                      child: Text(isScanning ? "Scanning..." : "Scan",
                          style: const TextStyle(color: Colors.blue)),
                    );
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        StreamBuilder<bool>(
          stream: FlutterBluePlus.isScanning,
          initialData: false,
          builder: (context, snapshot) {
            final isScanning = snapshot.data ?? false;
            if (isScanning) {
              return const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                ),
              );
            }

            if (bluetoothManager.connectedDevice != null) {
              return Flexible(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _showDetails = !_showDetails; // Toggle visibility
                            });
                          },
                          child: Text(
                            _showDetails ? "Hide details" : "Show details",
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (_showDetails)
                      Expanded(
                        child: ListView.builder(
                          itemCount: _characteristics.length,
                          itemBuilder: (context, index) {
                            final characteristic = _characteristics[index];
                            return BootsSettingsTile(
                              icon: Icons.data_object,
                              iconContainerColor: Colors
                                  .green, // Customize icon container color
                              settingsTitle: characteristic.uuid.toString(),
                              settingsSubtitle:
                                  "Tap to read", // Add a helpful subtitle
                              onTap: () => _readCharacteristic(characteristic),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              );
            } else {
              return Flexible(
                child: ListView.builder(
                  itemCount: _devicesList.length,
                  itemBuilder: (context, index) {
                    final device = _devicesList[index];
                    return BootsSettingsTile(
                      icon: Icons.devices, // Customize icon if needed
                      iconContainerColor:
                          Colors.blue, // Customize color if needed
                      settingsTitle: device.platformName.isNotEmpty
                          ? device.platformName
                          : 'Unknown Device',
                      settingsSubtitle: 'ID: ${device.remoteId}',
                      onTap: () => _connectToDevice(device),
                      isLoading: _loadingStates[device.remoteId.toString()] ??
                          false, // Check loading state
                    );
                  },
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
