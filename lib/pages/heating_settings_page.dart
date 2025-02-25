import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:footfurnace/providers/bluetooth_manager.dart';

class HeatingSettingsPage extends StatefulWidget {
  const HeatingSettingsPage({super.key});

  @override
  State<HeatingSettingsPage> createState() => _HeatingSettingsPageState();
}

class _HeatingSettingsPageState extends State<HeatingSettingsPage> with SingleTickerProviderStateMixin {
  late double targetTemp;
  bool _isAdjusting = false; // Add flag to track user adjustments
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  double _previousTemp = 0.0;
  bool _previousHeatingStatus = false;
  String _previousStatus = 'OFF';
  // Add cached values
  late String _cachedStatus;
  late double _cachedCurrentTemp;

  @override
  void initState() {
    super.initState();
    targetTemp = 25.0;
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _triggerAnimation() {
    _animationController.reset();
    _animationController.forward();
  }

  // Add helper method for heating status color and text
  (Color, String) _getHeatingStatusInfo(String status, double currentTemp, double targetTemp) {
    final difference = (targetTemp - currentTemp).abs();
    
    switch (status) {
      case 'ON':
        return (Colors.orange, 'Heating Active');
      case 'MTN':
        return (Colors.green, 'Maintaining ${targetTemp.toStringAsFixed(1)}°C');
      case 'OFF':
        return (Colors.blue, 'Heating Inactive');
      default:
        return (Colors.grey, 'Status Unknown');
    }
  }

  // Update the status icon based on the new states
  Widget _buildStatusIcon(String status, bool animate) {
    IconData icon;
    Color color;
    
    switch (status) {
      case 'ON':
        icon = Icons.local_fire_department;
        color = Colors.orange;
        break;
      case 'MTN':
        icon = Icons.thermostat;
        color = Colors.green;
        break;
      case 'OFF':
        icon = Icons.ac_unit;
        color = Colors.blue;
        break;
      default:
        icon = Icons.error_outline;
        color = Colors.grey;
    }

    return Transform.scale(
      scale: animate ? _scaleAnimation.value : 1.0,
      child: Icon(icon, color: color, size: 28),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothManager = context.watch<BluetoothManager>();
    final heatingData = bluetoothManager.heatingData;
    
    final currentTemp = (heatingData['temperature'] ?? 0.0).toDouble();
    final bleTargetTemp = (heatingData['targetTemperature'] ?? 0.0).toDouble();
    final status = heatingData['heatingStatus'] as String? ?? 'OFF';

    // Cache values when not adjusting
    if (!_isAdjusting) {
      _cachedStatus = status;
      _cachedCurrentTemp = currentTemp;
    }

    // Only update from BLE if user is not adjusting
    if (targetTemp != bleTargetTemp && !_isAdjusting) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          targetTemp = bleTargetTemp;
        });
      });
    }

    return ListView(
      children: [
        // Use cached values when adjusting
        _buildCurrentTempCard(
          _isAdjusting ? _cachedCurrentTemp : currentTemp,
          _isAdjusting ? _cachedStatus : status,
        ),
        _buildTemperatureControl(),
      ],
    );
  }

  // Update method signature to accept status directly
  Widget _buildCurrentTempCard(double currentTemp, String status) {
    final (statusColor, statusText) = _getHeatingStatusInfo(
      status, 
      currentTemp, 
      targetTemp
    );

    // Only trigger animation if not adjusting
    if (!_isAdjusting && (currentTemp != _previousTemp || status != _previousStatus)) {
      _triggerAnimation();
      _previousTemp = currentTemp;
      _previousStatus = status;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Current Temperature',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: Text(
                        '${currentTemp.toStringAsFixed(1)}°C',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: statusColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatusIcon(status, status == 'ON' || status == 'MTN'),
                      const SizedBox(width: 8),
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 300),
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Text(
                              statusText,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: statusColor,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
              // Add temperature difference indicator
              if (status == 'MTN')
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Within ±1°C of target',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemperatureControl() {
    final bluetoothManager = context.watch<BluetoothManager>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('Temperature Control'),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Target: ${targetTemp.toStringAsFixed(0)}°C',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () async {
                              if (targetTemp > 15) {
                                setState(() {
                                  _isAdjusting = true; // Set flag before adjustment
                                  targetTemp -= 1.0;
                                });
                                try {
                                  await bluetoothManager.setTargetTemperature(targetTemp);
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                } finally {
                                  // Add longer delay to ensure stable UI
                                  Future.delayed(const Duration(milliseconds: 1000), () {
                                    if (mounted) {
                                      setState(() {
                                        _isAdjusting = false;
                                      });
                                    }
                                  });
                                }
                              }
                            },
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          IconButton(
                            onPressed: () async {
                              if (targetTemp < 30) {
                                setState(() {
                                  _isAdjusting = true; // Set flag before adjustment
                                  targetTemp += 1.0;
                                });
                                try {
                                  await bluetoothManager.setTargetTemperature(targetTemp);
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                } finally {
                                  // Add longer delay to ensure stable UI
                                  Future.delayed(const Duration(milliseconds: 1000), () {
                                    if (mounted) {
                                      setState(() {
                                        _isAdjusting = false;
                                      });
                                    }
                                  });
                                }
                              }
                            },
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
