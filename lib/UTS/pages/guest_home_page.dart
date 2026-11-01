import 'package:flutter/material.dart';
import '../models/meja.dart';
import 'guest_detail_page.dart';

class GuestHomePage extends StatefulWidget {
  const GuestHomePage({super.key});

  @override
  State<GuestHomePage> createState() => _GuestHomePageState();
}

class _GuestHomePageState extends State<GuestHomePage> {
  String lokasi = 'Lantai 1';

  final List<Meja> daftarMeja = [
    Meja(
      id: '1',
      nama: 'Meja 1',
      desc: 'Ada Diujung',
      warna: Colors.green,
    ),
    Meja(
      id: '2',
      nama: 'Meja 2',
      desc: 'Dekat Kasir',
      warna: Colors.green,
    ),
    Meja(
      id: '3',
      nama: 'Meja 3',
      desc: 'Area Tengah',
      warna: Colors.green,
    ),
    Meja(
      id: '4',
      nama: 'Meja 4',
      desc: 'Area Tengah',
      warna: Colors.green,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: const Icon(
          Icons.person_outline,
          color: Colors.white,
        ),
        title: const Text(
          'Menu Utama Guest',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Lokasi',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF172033),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: lokasi,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF172033),
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Lantai 1',
                      child: Text('Lantai 1'),
                    ),
                    DropdownMenuItem(
                      value: 'Lantai 2',
                      child: Text('Lantai 2'),
                    ),
                    DropdownMenuItem(
                      value: 'VIP Lantai 3',
                      child: Text('VIP Lantai 3'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        lokasi = value;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF5B4A4A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Text(
                      'Spesifikasi Meja\n'
                          '• 9 feet slate stone\n'
                          '• Simonis cloth',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Spesifikasi Stick\n'
                          '• Kayu premium\n'
                          '• Standard 19-21 oz',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: daftarMeja.length,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1.4,
              ),
              itemBuilder: (context, index) {
                final meja = daftarMeja[index];

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GuestDetailPage(
                          mejaData: meja,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: meja.warna,
                    ),
                    child: Center(
                      child: Text(
                        meja.nama,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}