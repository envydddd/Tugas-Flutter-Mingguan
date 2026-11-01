import 'package:flutter/material.dart';
import '../models/meja.dart';
import 'pembayaran_page.dart';

class DetailReservasiPage extends StatefulWidget {
  final Meja mejaData;
  const DetailReservasiPage({super.key, required this.mejaData});

  @override
  State<DetailReservasiPage> createState() => _DetailReservasiPageState();
}

class _DetailReservasiPageState extends State<DetailReservasiPage> {
  String? _jamTerpilih;

  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController(text: "David Yehezkiel (Gmail)");
  final _waController = TextEditingController();
  String _metodePembayaran = 'Cash / Offline';

  final List<Map<String, String>> _jadwal = [
    {'jam': '10:00 - 11:00', 'status': 'BOOKED'},
    {'jam': '11:00 - 12:00', 'status': 'BOOKED'},
    {'jam': '12:00 - 14:00', 'status': 'AVAILABLE'},
    {'jam': '14:00 - 16:00', 'status': 'AVAILABLE'},
  ];

  @override
  void dispose() {
    _namaController.dispose();
    _waController.dispose();
    super.dispose();
  }

  void _prosesBooking() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => PembayaranPage(
          namaMeja: widget.mejaData.nama,
          jam: _jamTerpilih!,
          namaPemesan: _namaController.text,
          metode: _metodePembayaran,
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reservasi ${widget.mejaData.nama}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Hero(
              tag: 'ikon-meja-${widget.mejaData.id}',
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                decoration: BoxDecoration(color: widget.mejaData.warna, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.table_restaurant, color: Colors.white, size: 64),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Jadwal Hari Ini (12 Juli 2026)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          ..._jadwal.map((j) {
            bool isBooked = j['status'] == 'BOOKED';
            bool isSelected = _jamTerpilih == j['jam'];
            return Card(
              color: isBooked ? Colors.red.withOpacity(0.2) : (isSelected ? Colors.green.withOpacity(0.4) : const Color(0xFF1E293B)),
              child: ListTile(
                title: Text(
                    j['jam']!,
                    style: TextStyle(decoration: isBooked ? TextDecoration.lineThrough : null)
                ),
                trailing: Chip(
                  label: Text(j['status']!,
                      style: const TextStyle(fontSize: 10)
                  ),
                  backgroundColor: isBooked ? Colors.red : Colors.green,
                ),
                onTap: isBooked ? null : () {
                  setState(() => _jamTerpilih = j['jam']);
                },
              ),
            );
          }),

          if (_jamTerpilih != null) ...[
            const SizedBox(height: 24),
            const Text('Lengkapi Data Booking', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _namaController,
                    decoration: const InputDecoration(labelText: 'Nama Pemesan', border: OutlineInputBorder()),
                    readOnly: true,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _waController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Nomor WhatsApp', border: OutlineInputBorder()),
                    validator: (v) => (v == null || v.isEmpty) ? 'Nomor WA wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _metodePembayaran,
                    decoration: const InputDecoration(labelText: 'Metode Pembayaran', border: OutlineInputBorder()),
                    items: ['Cash / Offline', 'Online (Midtrans)']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _metodePembayaran = v!),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _prosesBooking,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.blueAccent),
                    child: const Text('Booking Slot Ini', style: TextStyle(color: Colors.white, fontSize: 16)),
                  )
                ],
              ),
            )
          ]
        ],
      ),
    );
  }
}