import 'package:flutter/material.dart';
import 'package:footfurnace/providers/bluetooth_manager.dart';
import 'package:provider/provider.dart';

class BatterySettingsPage extends StatefulWidget {
  const BatterySettingsPage({super.key});

  @override
  State<BatterySettingsPage> createState() => _BatterySettingsPageState();
}

class _BatterySettingsPageState extends State<BatterySettingsPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getBatteryColor(String level) {
    if (level == '--') return Colors.grey;
    final numLevel = int.tryParse(level) ?? 0;
    if (numLevel > 60) return Colors.green;
    if (numLevel > 30) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothManager = context.watch<BluetoothManager>();
    final defaultBattery = {'batteryLevel': '--', 'chargingStatus': false};
    final batteryData = bluetoothManager.batteryData.isNotEmpty
        ? bluetoothManager.batteryData
        : defaultBattery;

    final currentBatteryLevel = batteryData['batteryLevel']?.toString() ?? "--";
    final isCharging = batteryData['chargingStatus'] == true;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: Card(
            elevation: isCharging ? 4 : 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              height: 180,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: isCharging ? _scaleAnimation.value : 1.0,
                            child: Opacity(
                              opacity: isCharging ? _opacityAnimation.value : 1.0,
                              child: Icon(
                                Icons.battery_full,
                                size: 48,
                                color: _getBatteryColor(currentBatteryLevel),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 1500),
                            curve: Curves.easeOutCubic,
                            tween: Tween<double>(
                              begin: 0,
                              end: double.tryParse(currentBatteryLevel) ?? 0,
                            ),
                            builder: (context, value, child) {
                              return Text(
                                '${value.toInt()}%',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: _getBatteryColor(currentBatteryLevel),
                                ),
                              );
                            },
                          ),
                          if (isCharging)
                            TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 500),
                              tween: Tween<double>(begin: 0, end: 1),
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.bolt, 
                                        color: Colors.amber[600], 
                                        size: 20
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Charging',
                                        style: TextStyle(color: Colors.amber[600]),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
