import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class StatusServer {
  final bool apiSehat;
  final bool dbSehat;
  final String waktuServer;
  final String? mysqlVersion;
  final String? detailErrorDb;
  final Duration latensi;

  const StatusServer({
    required this.apiSehat,
    required this.dbSehat,
    required this.waktuServer,
    this.mysqlVersion,
    this.detailErrorDb,
    required this.latensi,
  });
}

Future<StatusServer> cekServer({http.Client? client, String? baseUrl}) async {
  final c = client ?? http.Client();
  final targetUrl = baseUrl ?? ApiConfig.url;
  final jam = Stopwatch()..start();
  try {
    final res = await c.get(Uri.parse('$targetUrl/health')).timeout(batasWaktu);
    jam.stop();

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return StatusServer(
        apiSehat: true,
        dbSehat: data['database'] == 'ok',
        waktuServer: data['waktu_server'] as String? ?? '-',
        mysqlVersion: data['mysql_version'] as String?,
        latensi: jam.elapsed,
      );
    } else if (res.statusCode == 503) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return StatusServer(
        apiSehat: true,
        dbSehat: false,
        waktuServer: data['waktu_server'] as String? ?? '-',
        detailErrorDb: data['detail'] as String? ?? 'Database tidak dapat dihubungi',
        latensi: jam.elapsed,
      );
    } else {
      throw Exception('Server membalas kode ${res.statusCode}');
    }
  } finally {
    if (client == null) c.close();
  }
}