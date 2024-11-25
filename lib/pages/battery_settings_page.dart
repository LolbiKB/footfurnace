import 'package:flutter/material.dart';
import 'package:footfurnace/providers/bluetooth_manager.dart';
import 'package:provider/provider.dart';
import 'package:footfurnace/components/boots_settings_tile.dart';

class BatterySettingsPage extends StatelessWidget {
  const BatterySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Access BluetoothManager through Provider
    final bluetoothManager = context.watch<BluetoothManager>();

    // Default values if data is not available
    final defaultBattery = {'batteryLevel': '--', 'chargingStatus': false};

    // Fetch battery data from BluetoothManager or fallback to defaults
    final batteryData = bluetoothManager.batteryData.isNotEmpty
        ? bluetoothManager.batteryData
        : defaultBattery;

    final String currentBatteryLevel =
        batteryData['batteryLevel']?.toString() ?? "--";
    final String chargingStatus =
        batteryData['chargingStatus'] == true ? "Yes" : "No";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView(
            children: [
              BootsSettingsTile(
                icon: Icons.battery_full, // Use a battery icon
                iconContainerColor: Colors.green, // Green for full battery
                settingsTitle: 'Current Level',
                settingsSubtitle: "$currentBatteryLevel%",
                onTap: () {
                  // Optional: Add functionality to refresh or view more details
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Battery level: $currentBatteryLevel%')),
                  );
                },
              ),
              BootsSettingsTile(
                icon: Icons.power, // Use a power icon
                iconContainerColor: Colors.orange, // Orange for charging
                settingsTitle: 'Charging',
                settingsSubtitle: chargingStatus,
                onTap: () {
                  // Optional: Add functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Charging status: $chargingStatus')),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
