import 'package:flutter/material.dart';
import 'state/pengaturan.dart';
import 'pages/shell_page.dart';
import 'pages/form_kegiatan_page.dart';

void main() {
  runApp(const TabungKuApp());
}

class TabungKuApp extends StatefulWidget {
  const TabungKuApp({super.key});

  @override
  State<TabungKuApp> createState() => _TabungKuAppState();
}

class _TabungKuAppState extends State<TabungKuApp> {
  final Pengaturan pengaturan = Pengaturan();

  @override
  void initState() {
    super.initState();
    pengaturan.muat();
  }

  @override
  void dispose() {
    pengaturan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pengaturan,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'TabungKu',
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: pengaturan.warna,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: pengaturan.warna,
            brightness: Brightness.dark,
          ),
          themeMode:
          pengaturan.gelap ? ThemeMode.dark : ThemeMode.light,
          initialRoute: '/',
          routes: {
            '/': (context) => ShellPage(
              pengaturan: pengaturan,
            ),
            '/form': (context) => FormKegiatanPage(
              pengaturan: pengaturan,
            ),
          },
        );
      },
    );
  }
}