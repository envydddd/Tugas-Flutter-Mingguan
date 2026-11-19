import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../services/health_service.dart';

class StatusServerPage extends StatefulWidget {
  const StatusServerPage({super.key});

  @override
  State<StatusServerPage> createState() => _StatusServerPageState();
}

class _StatusServerPageState extends State<StatusServerPage> {
  late Future<StatusServer> _future;

  @override
  void initState() {
    super.initState();
    _future = cekServer();
  }

  void _periksaUlang() {
    setState(() {
      _future = cekServer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Status Server')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<StatusServer>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final isNetworkError = snapshot.hasError;
            final data = snapshot.data;

            return ListView(
              children: [
                // Kartu Status API
                Card(
                  child: ListTile(
                    leading: Icon(
                      isNetworkError ? Icons.error : Icons.check_circle,
                      color: isNetworkError ? Colors.red : Colors.green,
                      size: 36,
                    ),
                    title: const Text('Layanan Backend API'),
                    subtitle: Text(
                      isNetworkError
                          ? 'Tidak terjangkau (${snapshot.error})'
                          : 'Terhubung • Latensi ${data!.latensi.inMilliseconds} ms',
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Kartu Status Database
                Card(
                  child: ListTile(
                    leading: Icon(
                      (!isNetworkError && data != null && data.dbSehat)
                          ? Icons.storage
                          : Icons.warning_amber_rounded,
                      color: (!isNetworkError && data != null && data.dbSehat)
                          ? Colors.green
                          : Colors.red,
                      size: 36,
                    ),
                    title: const Text('Layanan Database MySQL'),
                    subtitle: Text(
                      isNetworkError
                          ? 'Tidak dapat memeriksa (API mati)'
                          : data!.dbSehat
                          ? 'Terhubung • MySQL ${data.mysqlVersion ?? ''}'
                          : 'Database mati • ${data.detailErrorDb}',
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Informasi Alamat & Waktu
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('Alamat API Aktif'),
                        subtitle: Text(ApiConfig.url),
                      ),
                      if (!isNetworkError && data != null)
                        ListTile(
                          title: const Text('Waktu Server'),
                          subtitle: Text(data.waktuServer),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                ElevatedButton.icon(
                  onPressed: _periksaUlang,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Periksa lagi'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}