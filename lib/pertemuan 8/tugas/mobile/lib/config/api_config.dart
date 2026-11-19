import 'package:shared_preferences/shared_preferences.dart';

const _defaultApiUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://10.0.2.2:8000',
);

const batasWaktu = Duration(seconds: 10);

class ApiConfig {
  static const _keyUrl = 'api_url';
  static String _urlSaatIni = _defaultApiUrl;

  static String get url => _urlSaatIni;

  static Future<void> muat() async {
    final prefs = await SharedPreferences.getInstance();
    _urlSaatIni = prefs.getString(_keyUrl) ?? _defaultApiUrl;
  }

  static Future<void> simpanUrl(String urlBaru) async {
    final bersih = urlBaru.trim().replaceAll(RegExp(r'/+$'), '');
    _urlSaatIni = bersih;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUrl, bersih);
  }
}