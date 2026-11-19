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

            final isError = snapshot.hasError;
            final data = snapshot.data;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(
                          isError ? Icons.error : Icons.check_circle,
                          color: isError ? Colors.red : Colors.green,
                          size: 64,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isError ? 'Server tidak terjangkau' : 'Server terhubung',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          title: const Text('Alamat API'),
                          subtitle: Text(apiUrl),
                        ),
                        if (!isError && data != null) ...[
                          ListTile(
                            title: const Text('Waktu Server'),
                            subtitle: Text(data.waktuServer),
                          ),
                          ListTile(
                            title: const Text('Latensi'),
                            subtitle: Text('${data.latensi.inMilliseconds} ms'),
                          ),
                        ] else ...[
                          ListTile(
                            title: const Text('Detail Galat'),
                            subtitle: Text(
                              '${snapshot.error}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ],
                    ),
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