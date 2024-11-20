import 'package:flutter/material.dart';
import 'package:footfurnace/components/boots_settings_tile.dart'; // Import BootsSettingsTile

class BatterySettingsPage extends StatelessWidget {
  const BatterySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Replace these with actual values from your BluetoothManager
    final String currentBatteryLevel = "85%"; 
    final String timeLeft = "2h 30m";

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
                settingsSubtitle: currentBatteryLevel,
                onTap: () {}, // Add functionality if needed
              ),
              BootsSettingsTile(
                icon: Icons.access_time, // Use a clock icon
                iconContainerColor: Colors.orange, // Orange for time
                settingsTitle: 'Time Left',
                settingsSubtitle: timeLeft,
                onTap: () {}, // Add functionality if needed
              ),
            ],
          ),
        ),
      ],
    );
  }
}
