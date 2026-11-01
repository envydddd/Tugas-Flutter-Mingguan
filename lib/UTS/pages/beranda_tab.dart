import 'package:flutter/material.dart';
import '../models/meja.dart';
import 'detail_reservasi_page.dart';

class BerandaTab extends StatefulWidget {
  const BerandaTab({super.key});

  @override
  State<BerandaTab> createState() => _BerandaTabState();
}

class _BerandaTabState extends State<BerandaTab> {
  late Future<List<Meja>> _futureMeja;
  String _lantaiTerpilih = 'Lantai 1';

  @override
  void initState() {
    super.initState();
    _futureMeja = _fetchMejaDariAPI();
  }

  Future<List<Meja>> _fetchMejaDariAPI() async {
    await Future.delayed(const Duration(seconds: 2));
    return [
      Meja(id: '1', nama: 'Meja 1', desc: 'Ada Diujung', warna: Colors.green),
      Meja(id: '2', nama: 'Meja 2', desc: 'Sebelah Kiri', warna: Colors.green),
      Meja(id: '3', nama: 'Meja 3', desc: 'Sisi Jendela', warna: Colors.green),
      Meja(id: '4', nama: 'Meja 4', desc: 'Dekat Pintu', warna: Colors.green),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Billiard Reservation'),
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(backgroundColor: Colors.blueAccent, child: Icon(Icons.person, color: Colors.white)),
        ),
        actions: [IconButton(icon: const Icon(Icons.notifications), onPressed: () {})],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: _lantaiTerpilih,
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Pilih Lokasi'),
              items: ['Lantai 1', 'Lantai 2', 'VIP Lantai 3']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _lantaiTerpilih = v!),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(child: Text('Spesifikasi Meja:\n9 Feet Slate Stone\nSimonis Cloth')),
                    Expanded(child: Text('Spesifikasi Stick:\nKayu Premium\nStandard 19-21 oz')),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Meja>>(
              future: _futureMeja,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final data = snapshot.data!;
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.2
                  ),
                  itemCount: data.length,
                  itemBuilder: (context, i) {
                    final meja = data[i];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => DetailReservasiPage(mejaData: meja),
                        ));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade800),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Hero(
                              tag: 'ikon-meja-${meja.id}',
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                decoration: BoxDecoration(color: meja.warna, borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.table_restaurant, color: Colors.white, size: 32),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(meja.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(meja.desc, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}