import 'package:flutter/material.dart';

class PembayaranPage extends StatefulWidget {
  final String namaMeja;
  final String jam;
  final String namaPemesan;
  final String metode;

  const PembayaranPage({super.key, required this.namaMeja, required this.jam, required this.namaPemesan, required this.metode});

  @override
  State<PembayaranPage> createState() => _PembayaranPageState();
}

class _PembayaranPageState extends State<PembayaranPage> {
  String _statusPembayaran = 'Menunggu Pembayaran';
  Color _warnaStatus = Colors.orange;

  void _simulasiMidtrans() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    Navigator.pop(context);

    setState(() {
      _statusPembayaran = 'LUNAS (Transaksi Berhasil)';
      _warnaStatus = Colors.green;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isOnline = widget.metode.contains('Online');

    return Scaffold(
      appBar: AppBar(title: const Text('Rincian Pembayaran')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Booking: ${widget.namaMeja}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Jam: ${widget.jam}'),
            Text('Nama: ${widget.namaPemesan}'),
            Text('Metode: ${widget.metode}'),
            const Divider(height: 32),
            const Text('Total Pembayaran:', style: TextStyle(fontSize: 16)),
            const Text('Rp 50.000', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            const SizedBox(height: 16),

            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: _warnaStatus.withOpacity(0.2), borderRadius: BorderRadius.circular(8), border: Border.all(color: _warnaStatus)),
              child: Text('Status: $_statusPembayaran', style: TextStyle(color: _warnaStatus, fontWeight: FontWeight.bold)),
            ),

            const Spacer(),

            if (_statusPembayaran.contains('Menunggu')) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(
                  isOnline
                      ? 'Klik tombol di bawah untuk membuka simulasi pembayaran Midtrans. Status akan otomatis berubah menjadi Lunas.'
                      : 'Silakan lakukan pembayaran sebesar Rp 50.000 ke kasir di lokasi sebelum jam bermain dimulai.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.blueAccent),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isOnline ? _simulasiMidtrans : () => Navigator.popUntil(context, ModalRoute.withName('/home')),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: isOnline ? Colors.green : Colors.grey),
                child: Text(isOnline ? 'Bayar Sekarang (Simulasi Midtrans)' : 'Kembali ke Beranda', style: const TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/home')),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.blueAccent),
                child: const Text('Selesai - Kembali ke Beranda', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ]
          ],
        ),
      ),
    );
  }
}