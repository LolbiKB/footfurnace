import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:footfurnace/theme/theme.dart';
import 'package:footfurnace/pages/home_page.dart';
import 'package:footfurnace/providers/bluetooth_manager.dart'; // Import BluetoothManager

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BluetoothManager()), // Provide BluetoothManager
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const HomePage(),
        theme: lightTheme(),
        darkTheme: darkTheme(),
      ),
    );
  }
}
