import 'package:flutter/material.dart';

const orangeColor = Color(0xFFFF6B00);

final lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: orangeColor,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: orangeColor,
    foregroundColor: Colors.white,
  ),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: orangeColor,
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
  ),
);
