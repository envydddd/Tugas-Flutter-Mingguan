import 'package:flutter/material.dart';
import '../models/meja.dart';

class GuestDetailPage extends StatelessWidget {
  final Meja mejaData;

  const GuestDetailPage({
    super.key,
    required this.mejaData,
  });

  @override
  Widget build(BuildContext context) {
    final jadwal = [
      {
        'jam': '10:00 - 11:00',
        'status': 'BOOKED',
        'tersedia': false,
      },
      {
        'jam': '11:00 - 12:00',
        'status': 'AVAILABLE',
        'tersedia': true,
      },
      {
        'jam': '13:00 - 14:00',
        'status': 'AVAILABLE',
        'tersedia': true,
      },
      {
        'jam': '14:00 - 15:00',
        'status': 'AVAILABLE',
        'tersedia': true,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: Text(
          'Reservasi ${mejaData.nama}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 125,
              height: 115,
              color: mejaData.warna,
              alignment: Alignment.center,
              child: Text(
                mejaData.nama.toLowerCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ...jadwal.map(
                  (item) {
                final tersedia = item['tersedia'] as bool;
                final status = item['status'] as String;
                final jam = item['jam'] as String;

                return Container(
                  width: double.infinity,
                  height: 42,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: tersedia
                        ? const Color(0xFF6B5A5A)
                        : Colors.redAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          child: Text(
                            jam,
                            style: TextStyle(
                              color: Colors.white,
                              decoration: tersedia
                                  ? null
                                  : TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        color: tersedia
                            ? Colors.lightGreen
                            : Colors.red,
                        child: Text(
                          status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Login terlebih dahulu untuk melakukan reservasi.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}