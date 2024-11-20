import 'package:flutter/material.dart';

class BootsSettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconContainerColor;
  final String settingsTitle;
  final String settingsSubtitle;
  final VoidCallback? onTap;
  final Widget? trailing; // Optional trailing widget

  const BootsSettingsTile({
    super.key,
    required this.icon,
    required this.iconContainerColor,
    required this.settingsTitle,
    required this.settingsSubtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: GestureDetector(
        onTap: onTap, // This makes the tile clickable
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Container(
                padding: const EdgeInsets.all(10),
                color: iconContainerColor,
                child: Icon(icon, color: Colors.white, size: 30),
              ),
            ),
            title: Text(
              settingsTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(settingsSubtitle),
            trailing: trailing,
          ),
        ),
      ),
    );
  }
}
