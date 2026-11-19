import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Pengaturan extends ChangeNotifier {
  bool gelap = false;
  Color warna = Colors.blue;
  double target = 20000;

  Future<void> muat() async {
    final prefs = await SharedPreferences.getInstance();

    gelap = prefs.getBool('gelap') ?? false;

    final warnaValue = prefs.getInt('warna');
    if (warnaValue != null) {
      warna = Color(warnaValue);
    }

    target = prefs.getDouble('target') ?? 20000;

    notifyListeners();
  }

  Future<void> ubahGelap(bool nilai) async {
    gelap = nilai;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('gelap', nilai);

    notifyListeners();
  }

  Future<void> ubahWarna(Color nilai) async {
    warna = nilai;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('warna', nilai.toARGB32());

    notifyListeners();
  }

  Future<void> ubahTarget(double nilai) async {
    target = nilai;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('target', nilai);

    notifyListeners();
  }
}