import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

// ======================================================
// APP
// ======================================================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Catatan Saya',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const CatatanPage(),
    );
  }
}

// ======================================================
// BAGIAN B - MODEL
// ======================================================

class Catatan {
  final int? id;
  final String judul;
  final String isi;
  final String created;

  const Catatan({
    this.id,
    required this.judul,
    required this.isi,
    required this.created,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'judul': judul,
      'isi': isi,
      'created': created,
    };
  }

  factory Catatan.fromMap(Map<String, Object?> m) {
    return Catatan(
      id: m['id'] as int,
      judul: m['judul'] as String,
      isi: m['isi'] as String,
      created: m['created'] as String,
    );
  }
}

// ======================================================
// BAGIAN B - DATABASE
// ======================================================

class DbHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }

    final path = p.join(
      await getDatabasesPath(),
      'catatan.db',
    );

    _db = await openDatabase(
      path,

      // LATIHAN MANDIRI:
      // Naik dari version 1 menjadi version 2
      version: 2,

      // Database pertama kali dibuat
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE catatan('
              'id INTEGER PRIMARY KEY AUTOINCREMENT, '
              'judul TEXT NOT NULL, '
              'isi TEXT NOT NULL, '
              'created TEXT NOT NULL)',
        );
      },

      // LATIHAN MANDIRI:
      // Upgrade database version 1 -> 2
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE catatan '
                'ADD COLUMN created TEXT NOT NULL DEFAULT ""',
          );
        }
      },
    );

    return _db!;
  }

  // ====================================================
  // CREATE
  // ====================================================

  static Future<int> tambah(Catatan c) async {
    final db = await database;

    return db.insert(
      'catatan',
      c.toMap(),
    );
  }

  // ====================================================
  // READ
  // ====================================================

  static Future<List<Catatan>> semua({
    String keyword = '',
    bool terbaru = true,
  }) async {
    final db = await database;

    final rows = await db.query(
      'catatan',

      // LATIHAN MANDIRI:
      // Search menggunakan LIKE ?
      where: keyword.isEmpty ? null : 'judul LIKE ? OR isi LIKE ?',

      whereArgs: keyword.isEmpty
          ? null
          : ['%$keyword%', '%$keyword%'],

      // LATIHAN MANDIRI:
      // Sorting berdasarkan created
      orderBy: terbaru
          ? 'created DESC'
          : 'created ASC',
    );

    return rows.map(Catatan.fromMap).toList();
  }

  // ====================================================
  // UPDATE
  // ====================================================

  static Future<int> ubah(Catatan c) async {
    final db = await database;

    return db.update(
      'catatan',
      c.toMap(),
      where: 'id = ?',
      whereArgs: [c.id],
    );
  }

  // ====================================================
  // DELETE
  // ====================================================

  static Future<int> hapus(int id) async {
    final db = await database;

    return db.delete(
      'catatan',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

// ======================================================
// BAGIAN C + D
// ======================================================

class CatatanPage extends StatefulWidget {
  const CatatanPage({super.key});

  @override
  State<CatatanPage> createState() => _CatatanPageState();
}

class _CatatanPageState extends State<CatatanPage> {
  late Future<List<Catatan>> _future;

  final TextEditingController _searchController =
  TextEditingController();

  bool _terbaru = true;

  @override
  void initState() {
    super.initState();

    _loadSortPreference();
    _muat();
  }

  // ====================================================
  // LATIHAN MANDIRI:
  // SharedPreferences untuk sorting
  // ====================================================

  Future<void> _loadSortPreference() async {
    final prefs = await SharedPreferences.getInstance();

    final terbaru = prefs.getBool('sort_terbaru');

    if (terbaru != null) {
      setState(() {
        _terbaru = terbaru;
      });
    }

    _muat();
  }

  Future<void> _saveSortPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      'sort_terbaru',
      value,
    );
  }

  // ====================================================
  // LOAD DATA
  // ====================================================

  void _muat() {
    _future = DbHelper.semua(
      keyword: _searchController.text.trim(),
      terbaru: _terbaru,
    );
  }

  void _refresh() {
    setState(() {
      _muat();
    });
  }

  // ====================================================
  // SEARCH
  // ====================================================

  void _search(String value) {
    setState(() {
      _future = DbHelper.semua(
        keyword: value.trim(),
        terbaru: _terbaru,
      );
    });
  }

  // ====================================================
  // SORTING
  // ====================================================

  Future<void> _ubahSorting() async {
    final value = !_terbaru;

    await _saveSortPreference(value);

    setState(() {
      _terbaru = value;
      _muat();
    });
  }

  // ====================================================
  // BUKA FORM
  // ====================================================

  Future<void> _buka([Catatan? catatan]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormCatatanPage(
          catatan: catatan,
        ),
      ),
    );

    if (!mounted) return;

    _refresh();
  }

  // ====================================================
  // LATIHAN MANDIRI:
  // KONFIRMASI DELETE
  // ====================================================

  Future<void> _konfirmasiHapus(Catatan catatan) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Catatan?'),
          content: Text(
            'Apakah kamu yakin ingin menghapus '
                '"${catatan.judul}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (result != true) return;

    await DbHelper.hapus(catatan.id!);

    if (!mounted) return;

    _refresh();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Catatan berhasil dihapus'),
      ),
    );
  }

  // ====================================================
  // BUILD
  // ====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Saya'),
        actions: [
          IconButton(
            tooltip: _terbaru
                ? 'Terlama ke Terbaru'
                : 'Terbaru ke Terlama',
            onPressed: _ubahSorting,
            icon: Icon(
              _terbaru
                  ? Icons.arrow_downward
                  : Icons.arrow_upward,
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // ==================================================
          // SEARCH
          // ==================================================

          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _search,
              decoration: InputDecoration(
                labelText: 'Cari catatan',
                hintText: 'Cari judul atau isi...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _search('');
                  },
                  icon: const Icon(Icons.clear),
                )
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
          ),

          // ==================================================
          // LIST DATA
          // ==================================================

          Expanded(
            child: FutureBuilder<List<Catatan>>(
              future: _future,

              builder: (context, snapshot) {
                // Loading
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // Error
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Galat: ${snapshot.error}',
                    ),
                  );
                }

                final data = snapshot.data ?? [];

                // Empty
                if (data.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada catatan',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: data.length,

                  itemBuilder: (context, i) {
                    final c = data[i];

                    return ListTile(
                      title: Text(c.judul),

                      subtitle: Text(
                        '${c.isi}\nDibuat: ${c.created}',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),

                      onTap: () => _buka(c),

                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete,
                        ),
                        onPressed: () {
                          _konfirmasiHapus(c);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // ====================================================
      // BAGIAN D - TAMBAH CATATAN
      // ====================================================

      floatingActionButton: FloatingActionButton(
        onPressed: () => _buka(),

        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// ======================================================
// BAGIAN D - FORM TAMBAH / EDIT
// ======================================================

class FormCatatanPage extends StatefulWidget {
  final Catatan? catatan;

  const FormCatatanPage({
    super.key,
    this.catatan,
  });

  @override
  State<FormCatatanPage> createState() =>
      _FormCatatanPageState();
}

class _FormCatatanPageState
    extends State<FormCatatanPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _judul;
  late final TextEditingController _isi;

  @override
  void initState() {
    super.initState();

    _judul = TextEditingController(
      text: widget.catatan?.judul ?? '',
    );

    _isi = TextEditingController(
      text: widget.catatan?.isi ?? '',
    );
  }

  @override
  void dispose() {
    _judul.dispose();
    _isi.dispose();

    super.dispose();
  }

  // ====================================================
  // SIMPAN
  // ====================================================

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final c = Catatan(
      id: widget.catatan?.id,
      judul: _judul.text.trim(),
      isi: _isi.text.trim(),

      // created hanya dibuat saat tambah
      created: widget.catatan?.created ??
          DateTime.now().toIso8601String(),
    );

    // TAMBAH
    if (widget.catatan == null) {
      await DbHelper.tambah(c);
    }

    // UPDATE
    else {
      await DbHelper.ubah(c);
    }

    if (!mounted) return;

    Navigator.pop(context);
  }

  // ====================================================
  // BUILD
  // ====================================================

  @override
  Widget build(BuildContext context) {
    final baru = widget.catatan == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          baru
              ? 'Catatan Baru'
              : 'Ubah Catatan',
        ),
      ),

      body: Form(
        key: _formKey,

        child: ListView(
          padding: const EdgeInsets.all(16),

          children: [
            // JUDUL
            TextFormField(
              controller: _judul,

              decoration: const InputDecoration(
                labelText: 'Judul',
                border: OutlineInputBorder(),
              ),

              validator: (v) {
                if (v == null ||
                    v.trim().isEmpty) {
                  return 'Judul wajib diisi';
                }

                return null;
              },
            ),

            const SizedBox(height: 12),

            // ISI
            TextFormField(
              controller: _isi,

              maxLines: 6,

              decoration: const InputDecoration(
                labelText: 'Isi catatan',
                border: OutlineInputBorder(),
              ),

              validator: (v) {
                if (v == null ||
                    v.trim().isEmpty) {
                  return 'Isi wajib diisi';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            // SIMPAN
            ElevatedButton(
              onPressed: _simpan,
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}