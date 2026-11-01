import 'package:flutter/material.dart';

class RiwayatTab extends StatelessWidget {
  const RiwayatTab({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> riwayatBooking = [
      {
        'id': 'BK-1001',
        'meja': 'Meja 1',
        'tanggal': '12 Juli 2026',
        'jam': '10:00 - 11:00',
        'status': 'Menunggu Pembayaran',
        'warnaStatus': Colors.orange,
      },
      {
        'id': 'BK-1002',
        'meja': 'Meja 4',
        'tanggal': '10 Juli 2026',
        'jam': '14:00 - 16:00',
        'status': 'LUNAS',
        'warnaStatus': Colors.green,
      },
      {
        'id': 'BK-1003',
        'meja': 'Meja 2',
        'tanggal': '05 Juli 2026',
        'jam': '19:00 - 21:00',
        'status': 'DIBATALKAN',
        'warnaStatus': Colors.red,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Reservasi Saya'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: riwayatBooking.length,
        itemBuilder: (context, index) {
          final item = riwayatBooking[index];

          return Card(
            color: const Color(0xFF1E293B),
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blueAccent,
                child: Icon(
                  Icons.receipt_long,
                  color: Colors.white,
                ),
              ),
              title: Text(
                '${item['meja']} (${item['tanggal']})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'ID: ${item['id']}\nJam: ${item['jam']}',
              ),
              isThreeLine: true,
              trailing: Chip(
                label: Text(
                  item['status'],
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: item['warnaStatus'],
              ),
            ),
          );
        },
      ),
    );
  }
}