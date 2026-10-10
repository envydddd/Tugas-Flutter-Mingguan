import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const ExpensePage(),
    );
  }
}

class Expense {
  final int? id;
  final String name;
  final double amount;
  final String category;
  final String date;

  const Expense({
    this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.date,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'category': category,
      'date': date,
    };
  }

  factory Expense.fromMap(Map<String, Object?> map) {
    return Expense(
      id: map['id'] as int,
      name: map['name'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      date: map['date'] as String,
    );
  }
}

class DbHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }

    final path = p.join(
      await getDatabasesPath(),
      'expense_tracker.db',
    );

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE expenses('
              'id INTEGER PRIMARY KEY AUTOINCREMENT, '
              'name TEXT NOT NULL, '
              'amount REAL NOT NULL, '
              'category TEXT NOT NULL, '
              'date TEXT NOT NULL)',
        );
      },
    );

    return _db!;
  }

  static Future<int> tambah(Expense expense) async {
    final db = await database;

    return db.insert(
      'expenses',
      expense.toMap(),
    );
  }

  static Future<List<Expense>> semua() async {
    final db = await database;

    final rows = await db.query(
      'expenses',
      orderBy: 'date DESC, id DESC',
    );

    return rows.map(Expense.fromMap).toList();
  }

  static Future<int> ubah(Expense expense) async {
    final db = await database;

    return db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  static Future<int> hapus(int id) async {
    final db = await database;

    return db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  late Future<List<Expense>> _future;

  bool _showTotal = true;

  @override
  void initState() {
    super.initState();

    _future = DbHelper.semua();

    _loadPreference();
  }

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();

    final showTotal = prefs.getBool('show_total');

    if (showTotal != null) {
      setState(() {
        _showTotal = showTotal;
      });
    }
  }

  Future<void> _savePreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      'show_total',
      value,
    );
  }

  void _muat() {
    setState(() {
      _future = DbHelper.semua();
    });
  }

  Future<void> _bukaForm([Expense? expense]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExpenseFormPage(
          expense: expense,
        ),
      ),
    );

    if (!mounted) return;

    _muat();
  }

  Future<void> _hapus(Expense expense) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Pengeluaran'),
          content: Text(
            'Yakin ingin menghapus "${expense.name}"?',
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

    if (konfirmasi != true) return;

    await DbHelper.hapus(expense.id!);

    if (!mounted) return;

    _muat();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pengeluaran berhasil dihapus'),
      ),
    );
  }

  String _rupiah(double value) {
    return 'Rp ${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          IconButton(
            onPressed: () async {
              final value = !_showTotal;

              await _savePreference(value);

              setState(() {
                _showTotal = value;
              });
            },
            icon: Icon(
              _showTotal
                  ? Icons.visibility
                  : Icons.visibility_off,
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Expense>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Galat: ${snapshot.error}',
              ),
            );
          }

          final data = snapshot.data ?? [];

          double total = 0;

          for (final expense in data) {
            total += expense.amount;
          }

          if (data.isEmpty) {
            return Column(
              children: [
                if (_showTotal)
                  Card(
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Pengeluaran',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _rupiah(total),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Belum ada pengeluaran',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              if (_showTotal)
                Card(
                  margin: const EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    8,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Pengeluaran',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _rupiah(total),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final expense = data[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: ListTile(
                        title: Text(
                          expense.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${expense.category} • ${expense.date}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _rupiah(expense.amount),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _bukaForm(expense);
                                }

                                if (value == 'delete') {
                                  _hapus(expense);
                                }
                              },
                              itemBuilder: (context) {
                                return const [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Edit'),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Hapus'),
                                  ),
                                ];
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _bukaForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ExpenseFormPage extends StatefulWidget {
  final Expense? expense;

  const ExpenseFormPage({
    super.key,
    this.expense,
  });

  @override
  State<ExpenseFormPage> createState() =>
      _ExpenseFormPageState();
}

class _ExpenseFormPageState
    extends State<ExpenseFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late String _category;
  late DateTime _date;

  final List<String> _categories = [
    'Makanan',
    'Transportasi',
    'Belanja',
    'Hiburan',
    'Tagihan',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.expense?.name ?? '',
    );

    _amountController = TextEditingController(
      text: widget.expense?.amount.toString() ?? '',
    );

    _category = widget.expense?.category ??
        _categories.first;

    _date = widget.expense != null
        ? DateTime.parse(widget.expense!.date)
        : DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();

    super.dispose();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$year-$month-$day';
  }

  Future<void> _pilihTanggal() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (result == null) return;

    setState(() {
      _date = result;
    });
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.tryParse(
      _amountController.text.trim(),
    );

    if (amount == null || amount <= 0) {
      return;
    }

    final expense = Expense(
      id: widget.expense?.id,
      name: _nameController.text.trim(),
      amount: amount,
      category: _category,
      date: _formatDate(_date),
    );

    if (widget.expense == null) {
      await DbHelper.tambah(expense);
    } else {
      await DbHelper.ubah(expense);
    }

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final baru = widget.expense == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          baru
              ? 'Tambah Pengeluaran'
              : 'Edit Pengeluaran',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Pengeluaran',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Nama wajib diisi';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType:
              const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Jumlah',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Jumlah wajib diisi';
                }

                final amount = double.tryParse(
                  value.trim(),
                );

                if (amount == null) {
                  return 'Jumlah harus berupa angka';
                }

                if (amount <= 0) {
                  return 'Jumlah harus lebih dari 0';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  _category = value;
                });
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tanggal'),
              subtitle: Text(
                _formatDate(_date),
              ),
              trailing: OutlinedButton(
                onPressed: _pilihTanggal,
                child: const Text('Pilih'),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _simpan,
              child: Text(
                baru
                    ? 'Simpan Pengeluaran'
                    : 'Simpan Perubahan',
              ),
            ),
          ],
        ),
      ),
    );
  }
}