import 'package:flutter/material.dart';

class BatterySettingsPage extends StatelessWidget {
  const BatterySettingsPage({super.key});

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
                title: Text('Battery Item ${index + 1}'),
                subtitle: Text('Details for Battery item ${index + 1}'),
              );
            },
          ),
        ),
      ],
    );
  }
}
