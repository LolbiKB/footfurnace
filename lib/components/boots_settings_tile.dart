import 'package:flutter/material.dart';

class BootsSettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconContainerColor;
  final String settingsTitle;
  final String settingsSubtitle;
  final VoidCallback? onTap;
  final Widget? trailing; // Optional trailing widget
  final bool isLoading; // Loading state

  const BootsSettingsTile({
    super.key,
    required this.icon,
    required this.iconContainerColor,
    required this.settingsTitle,
    required this.settingsSubtitle,
    this.onTap,
    this.trailing,
    this.isLoading = false, // Default is not loading
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: GestureDetector(
        onTap: isLoading ? null : onTap, // Disable interaction if loading
        child: Container(
          decoration: BoxDecoration(
            color: isLoading ? Colors.grey[200] : Colors.white, // Subtle change when loading
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: isLoading
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      color: Colors.grey[300],
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.blue,
                      ),
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      color: iconContainerColor,
                      child: Icon(icon, color: Colors.white, size: 30),
                    ),
                  ),
            title: isLoading
                ? Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  )
                : Text(
                    settingsTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
            subtitle: isLoading
                ? Container(
                    height: 12,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  )
                : Text(settingsSubtitle),
            trailing: isLoading
                ? null
                : trailing,
          ),
        ),
      ),
    );
  }
}
