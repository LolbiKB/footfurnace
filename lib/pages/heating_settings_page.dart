import 'package:flutter/material.dart';

class HeatingSettingsPage extends StatelessWidget {
  const HeatingSettingsPage({super.key});

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
                title: Text('Heating Item ${index + 1}'),
                subtitle: Text('Details for Heating item ${index + 1}'),
              );
            },
          ),
        ),
      ],
    );
  }
}
