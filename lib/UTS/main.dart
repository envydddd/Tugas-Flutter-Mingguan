import 'package:flutter/material.dart';
import 'UTS/pages/login_page.dart';
import 'UTS/pages/shell_page.dart';

void main() {
  runApp(const BilliardApp());
}

class BilliardApp extends StatelessWidget {
  const BilliardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reservasi Billiard',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorSchemeSeed: Colors.blueAccent,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E293B),
          centerTitle: true,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => const ShellPage(),
      },
    );
  }
}