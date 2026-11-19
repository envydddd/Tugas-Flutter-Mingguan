import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tabungku/services/health_service.dart';

void main() {
  test('1. Kasus sehat (200): API dan database aktif', () async {
    final client = MockClient((req) async {
      expect(req.url.path, '/health');
      return http.Response(
        jsonEncode({
          'status': 'ok',
          'waktu_server': '2026-10-06T08:00:00',
          'database': 'ok',
          'mysql_version': '8.4.3',
        }),
        200,
      );
    });

    final s = await cekServer(client: client, baseUrl: 'http://localhost:8000');
    expect(s.apiSehat, true);
    expect(s.dbSehat, true);
    expect(s.mysqlVersion, '8.4.3');
  });

  test('2. Kasus 503: API hidup tetapi database mati', () async {
    final client = MockClient((req) async {
      return http.Response(
        jsonEncode({
          'status': 'degraded',
          'waktu_server': '2026-10-06T08:05:00',
          'database': 'error',
          'detail': 'Can not connect to MySQL server',
        }),
        503,
      );
    });

    final s = await cekServer(client: client, baseUrl: 'http://localhost:8000');
    expect(s.apiSehat, true);
    expect(s.dbSehat, false);
    expect(s.detailErrorDb, contains('MySQL'));
  });

  test('3. Kasus kode lain (500): Melempar Exception', () async {
    final client = MockClient((req) async {
      return http.Response('Internal Server Error', 500);
    });

    expect(
          () => cekServer(client: client, baseUrl: 'http://localhost:8000'),
      throwsException,
    );
  });
}