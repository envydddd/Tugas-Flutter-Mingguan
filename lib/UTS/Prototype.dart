import 'package:flutter/material.dart';

void main() {
  runApp(const BilliardApp());
}

class BilliardApp extends StatelessWidget {
  const BilliardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reservasi Billiard',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorSchemeSeed: Colors.blueAccent,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E293B),
          centerTitle: true,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => const ShellPage(),
      },
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.pool, size: 100, color: Colors.blueAccent),
              const SizedBox(height: 24),
              Text(
                'Selamat Datang di Billiard',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Reservasi Meja Anda Kini Lebih Mudah', textAlign: TextAlign.center),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                icon: const Icon(Icons.login),
                label: const Text('Sign In with Google'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                child: const Text('Lanjutkan sebagai Tamu', style: TextStyle(color: Colors.grey)),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int _index = 0;
  final List<Widget> _halaman = const [
    BerandaTab(),
    Center(child: Text('Riwayat Booking Kosong')),
    Center(child: Text('Profil Pengguna')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _halaman),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: 'Riwayat'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Akun'),
        ],
      ),
    );
  }
}

class BerandaTab extends StatefulWidget {
  const BerandaTab({super.key});

  @override
  State<BerandaTab> createState() => _BerandaTabState();
}

class _BerandaTabState extends State<BerandaTab> {
  late Future<List<Map<String, dynamic>>> _futureMeja;
  String _lantaiTerpilih = 'Lantai 1';

  @override
  void initState() {
    super.initState();
    _futureMeja = _fetchMejaDariAPI();
  }

  Future<List<Map<String, dynamic>>> _fetchMejaDariAPI() async {
    await Future.delayed(const Duration(seconds: 2));
    return [
      {'id': '1', 'nama': 'Meja 1', 'desc': 'Ada Diujung', 'warna': Colors.green},
      {'id': '2', 'nama': 'Meja 2', 'desc': 'Sebelah Kiri', 'warna': Colors.green},
      {'id': '3', 'nama': 'Meja 3', 'desc': 'Sisi Jendela', 'warna': Colors.green},
      {'id': '4', 'nama': 'Meja 4', 'desc': 'Dekat Pintu', 'warna': Colors.green},
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
                    Expanded(child: Text('Spesifikasi Meja:\n- 9 Feet Slate Stone\n- Simonis Cloth')),
                    Expanded(child: Text('Spesifikasi Stick:\n- Kayu Premium\n- Standard 19-21 oz')),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
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
                              tag: 'ikon-meja-${meja['id']}',
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                decoration: BoxDecoration(color: meja['warna'], borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.table_restaurant, color: Colors.white, size: 32),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(meja['nama'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(meja['desc'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
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

class DetailReservasiPage extends StatefulWidget {
  final Map<String, dynamic> mejaData;
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

  final List<Map<String, dynamic>> _jadwal = [
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
          namaMeja: widget.mejaData['nama'],
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
      appBar: AppBar(title: Text('Reservasi ${widget.mejaData['nama']}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Hero(
              tag: 'ikon-meja-${widget.mejaData['id']}',
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                decoration: BoxDecoration(color: widget.mejaData['warna'], borderRadius: BorderRadius.circular(12)),
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
                title: Text(j['jam'], style: TextStyle(decoration: isBooked ? TextDecoration.lineThrough : null)),
                trailing: Chip(
                  label: Text(j['status'], style: const TextStyle(fontSize: 10)),
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