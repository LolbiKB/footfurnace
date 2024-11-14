import 'package:flutter/material.dart';

ThemeData lightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      surface: Colors.grey.shade200,
      primary: Colors.orange.shade400, 
      secondary: Colors.grey.shade600     
    ),
  );
}

ThemeData darkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      surface: Colors.grey.shade900,
      primary: Colors.grey.shade700,
      secondary: Colors.grey.shade500,
    ),
  );
}