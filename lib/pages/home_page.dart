import 'package:flutter/material.dart';
import 'package:footfurnace/providers/bluetooth_manager.dart';
import 'package:provider/provider.dart';
import 'package:footfurnace/components/boots_settings_tile.dart';
import 'package:footfurnace/pages/heating_settings_page.dart';
import 'package:footfurnace/pages/battery_settings_page.dart';
import 'package:footfurnace/pages/power_settings_page.dart';
import 'package:footfurnace/pages/bluetooth_settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = -1;

  // Method to update the selected index
  void _onTileTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Method to reset to the main settings menu
  void _goBack() {
    setState(() {
      _selectedIndex = -1;
    });
  }

  Widget _buildSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return const HeatingSettingsPage();
      case 1:
        return const BatterySettingsPage();
      case 2:
        return const PowerSettingsPage();
      case 3:
        return const BluetoothSettingsPage();
      default:
        return _buildMainSettingsMenu();
    }
  }

  Widget _buildMainSettingsMenu() {
    final bluetoothManager = context.watch<BluetoothManager>();

    // Default values for when no connection is detected
    final defaultHeating = {'temperature': '--', 'heatingStatus': 'OFF'};
    final defaultBattery = {'batteryLevel': '--', 'chargingStatus': false};
    final defaultPower = {'powerStatus': '--'};

    final heatingData = bluetoothManager.heatingData.isNotEmpty
        ? bluetoothManager.heatingData
        : defaultHeating;
    final batteryData = bluetoothManager.batteryData.isNotEmpty
        ? bluetoothManager.batteryData
        : defaultBattery;
    final powerData = bluetoothManager.powerData.isNotEmpty
        ? bluetoothManager.powerData
        : defaultPower;

    return ListView(
      children: [
        BootsSettingsTile(
          icon: Icons.thermostat,
          iconContainerColor: Colors.orange,
          settingsTitle: "Heating",
          settingsSubtitle:
              "Temp: ${heatingData['temperature']}°C | Heating: ${heatingData['heatingStatus']}",
          onTap: () => _onTileTapped(0),
          trailing: const Icon(Icons.chevron_right),
        ),
        BootsSettingsTile(
          icon: Icons.battery_charging_full,
          iconContainerColor: Colors.green,
          settingsTitle: "Battery",
          settingsSubtitle:
              "Level: ${batteryData['batteryLevel']}% | Charging: ${batteryData['chargingStatus'] == true ? 'Yes' : 'No'}",
          onTap: () => _onTileTapped(1),
          trailing: const Icon(Icons.chevron_right),
        ),
        BootsSettingsTile(
          icon: Icons.power_settings_new,
          iconContainerColor: Colors.red,
          settingsTitle: "Power",
          settingsSubtitle: "Power: ${powerData['powerStatus']}",
          onTap: () => _onTileTapped(2),
          trailing: const Icon(Icons.chevron_right),
        ),
        BootsSettingsTile(
          icon: Icons.bluetooth,
          iconContainerColor: Colors.blue,
          settingsTitle: "Bluetooth",
          settingsSubtitle:
              "Connected: ${bluetoothManager.connectedDevice != null ? 'Yes' : 'No'}",
          onTap: () => _onTileTapped(3),
          trailing: const Icon(Icons.chevron_right),
        ),
     ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[800],
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: [
                  Center(
                    child: Text(
                      'FootFurnace',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[50],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Image(
                    image: AssetImage('assets/boot.png'),
                    height: 250,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(
                    top: 12, left: 20, right: 20, bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30), // Adjust the radius as needed
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 50,
                      child: Row(
                        children: [
                          if (_selectedIndex != -1)
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: _goBack,
                            ),
                          Text(
                            _selectedIndex == -1
                                ? "Boots Settings"
                                : _selectedIndex == 0
                                    ? "Heating"
                                    : _selectedIndex == 1
                                        ? "Battery"
                                        : _selectedIndex == 2
                                            ? "Power"
                                            : "Bluetooth",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        switchInCurve: Curves.easeInOut,
                        switchOutCurve: Curves.easeInOut,
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1.0, 0.0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          );
                        },
                        child: _selectedIndex == -1
                            ? _buildMainSettingsMenu()
                            : _buildSelectedPage(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
