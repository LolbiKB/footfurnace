import 'package:flutter/material.dart';

class BluetoothSettingsPage extends StatelessWidget {
  const BluetoothSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: 20,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('Bluetooth Item ${index + 1}'),
                subtitle: Text('Details for Bluetooth item ${index + 1}'),
              );
            },
          ),
        ),
      ],
    );
  }
}
