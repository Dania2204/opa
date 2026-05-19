import 'package:flutter/material.dart';
import '../core/router/app_router.dart';
import 'theme.dart';

class PaeGoApp extends StatefulWidget {
  const PaeGoApp({super.key});

  @override
  State<PaeGoApp> createState() => _PaeGoAppState();
}

class _PaeGoAppState extends State<PaeGoApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PAEGo',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: _themeMode,
      onGenerateRoute: (s) =>
          AppRouter.generateRoute(s, _toggleTheme, _themeMode),
      initialRoute: AppRouter.splash,
    );
  }
}
