import 'package:flutter/material.dart';
import 'homepage.dart';
import 'Settings.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  // Funktion för att byta tema
  void _toggleTheme(bool isDarkMode) {
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Weather App',
      theme: ThemeData.light(),
      // Ljust tema
      darkTheme: ThemeData.dark(),
      // Mörkt tema
      themeMode: _themeMode,
      // Ändra tema baserat på ThemeMode
      home: HomePage(onThemeChanged: _toggleTheme),
      routes: {
        '/settings': (context) => Settings(onThemeChanged: _toggleTheme),
      },
    );
  }
}
