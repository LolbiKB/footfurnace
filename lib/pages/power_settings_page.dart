import 'package:flutter/material.dart';

class PowerSettingsPage extends StatelessWidget {
  const PowerSettingsPage({super.key});

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
                title: Text('Power Item ${index + 1}'),
                subtitle: Text('Details for Power item ${index + 1}'),
              );
            },
          ),
        ),
      ],
    );
  }
}
