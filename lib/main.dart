import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:postra/src/core/theme/app_theme.dart';
import 'package:postra/src/features/landing/presentation/pages/landing_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();

  static MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppState>()!;
}

class MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Postra',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: CupertinoTheme(
        data: _themeMode == ThemeMode.light
            ? AppTheme.cupertinoLightTheme
            : AppTheme.cupertinoDarkTheme,
        child: const LandingPage(),
      ),
    );
  }
}
