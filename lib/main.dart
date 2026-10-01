import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class belanjaitem {
  String nama;
  int jumlah;
  String kategori;
  bool sudahdibeli;

  belanjaitem({
    required this.nama,
    required this.jumlah,
    required this.kategori,
    this.sudahdibeli = false,
  });
}

class belanjamodel extends ChangeNotifier {
  final List<belanjaitem> _items = [];

  List<belanjaitem> get items => List.unmodifiable(_items);

  int get jumlahBelumDibeli => _items.where((item) => !item.sudahdibeli).length;

  void tambah(String nama, int jumlah, String kategori) {
    _items.add(belanjaitem(
      nama: nama,
      jumlah: jumlah,
      kategori: kategori,
    ));
    notifyListeners();
  }

  void toggleStatus(int index) {
    _items[index].sudahdibeli = !_items[index].sudahdibeli;
    notifyListeners();
  }

  void hapus(int index) {
    _items.removeAt(index);
    notifyListeners();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => belanjamodel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Daftar Belanja',
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
      ),
      home: const DaftarBelanjaPage(),
    );
  }
}

class DaftarBelanjaPage extends StatelessWidget {
  const DaftarBelanjaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<belanjamodel>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Belum Dibeli: ${model.jumlahBelumDibeli}'),
      ),
      body: model.items.isEmpty
          ? const Center(
        child: Text(
          'Daftar belanjaan kosong',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: model.items.length,
        itemBuilder: (context, index) {
          final item = model.items[index];
          return ListTile(
            leading: Checkbox(
              value: item.sudahdibeli,
              onChanged: (_) =>
                  context.read<belanjamodel>().toggleStatus(index),
            ),
            title: Text(
              item.nama,
              style: TextStyle(
                decoration: item.sudahdibeli
                    ? TextDecoration.lineThrough
                    : null,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Jumlah: ${item.jumlah} | Kategori: ${item.kategori}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () =>
                  context.read<belanjamodel>().hapus(index),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const FormTambahPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class FormTambahPage extends StatefulWidget {
  const FormTambahPage({super.key});

  @override
  State<FormTambahPage> createState() => _FormTambahPageState();
}

class _FormTambahPageState extends State<FormTambahPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _jumlahController = TextEditingController();
  String? _kategoriTerpilih;

  final List<String> _daftarKategori = [
    'Makanan & Minuman',
    'Kebutuhan Rumah',
    'Bumbu Dapur',
    'Elektronik',
    'Lainnya',
  ];

  @override
  void dispose() {
    _namaController.dispose();
    _jumlahController.dispose();
    super.dispose();
  }

  void _simpan() {
    if (_formKey.currentState!.validate()) {
      final nama = _namaController.text.trim();
      final jumlah = int.parse(_jumlahController.text.trim());

      context.read<belanjamodel>().tambah(nama, jumlah, _kategoriTerpilih!);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Barang berhasil ditambahkan!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Belanjaan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Barang',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama barang wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _jumlahController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Jumlah wajib diisi';
                  }
                  final angka = int.tryParse(value.trim());
                  if (angka == null || angka <= 0) {
                    return 'Jumlah harus berupa angka lebih dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                items: _daftarKategori
                    .map((kategori) => DropdownMenuItem(
                  value: kategori,
                  child: Text(kategori),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _kategoriTerpilih = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pilih kategori barang';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _simpan,
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}