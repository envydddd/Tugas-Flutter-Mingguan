import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/db_helper.dart';
import '../models/kegiatan.dart';
import '../utils/format.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  DateTime _tanggal = DateTime.now();

  late Future<Ringkasan> _futureRingkasan;
  late Future<Map<String, int>> _futureKategori;
  late Future<List<Map<String, Object?>>>
  _futureTujuhHari;

  @override
  void initState() {
    super.initState();
    _muat();
    versiData.addListener(_refresh);
  }

  @override
  void dispose() {
    versiData.removeListener(_refresh);
    super.dispose();
  }

  String _tanggalDatabase() {
    return '${_tanggal.year.toString().padLeft(4, '0')}-'
        '${_tanggal.month.toString().padLeft(2, '0')}-'
        '${_tanggal.day.toString().padLeft(2, '0')}';
  }

  void _muat() {
    final tanggal = _tanggalDatabase();

    _futureRingkasan = DbHelper.ringkasan(tanggal);
    _futureKategori =
        DbHelper.pengeluaranPerKategori(tanggal);
    _futureTujuhHari =
        DbHelper.tujuhHariTerakhir(tanggal);
  }

  void _refresh() {
    if (!mounted) {
      return;
    }

    setState(_muat);
  }

  Future<void> _pilihTanggal() async {
    final hasil = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (hasil != null) {
      setState(() {
        _tanggal = hasil;
        _muat();
      });
    }
  }

  Future<void> _export() async {
    final ringkasan = await _futureRingkasan;
    final kategori = await _futureKategori;

    final buffer = StringBuffer();

    buffer.writeln(
      'Laporan TabungKu - ${tanggalTampilan(_tanggalDatabase())}',
    );
    buffer.writeln('');
    buffer.writeln(
      'Jumlah kegiatan: ${ringkasan.jumlahKegiatan}',
    );
    buffer.writeln(
      'Selesai: ${ringkasan.selesai}',
    );
    buffer.writeln(
      'Pemasukan: ${rupiah(ringkasan.pemasukan)}',
    );
    buffer.writeln(
      'Pengeluaran: ${rupiah(ringkasan.pengeluaran)}',
    );
    buffer.writeln(
      'Tabungan: ${rupiah(ringkasan.tabungan)}',
    );

    if (kategori.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('Pengeluaran per kategori:');

      for (final item in kategori.entries) {
        buffer.writeln(
          '${item.key}: ${rupiah(item.value)}',
        );
      }
    }

    await Clipboard.setData(
      ClipboardData(
        text: buffer.toString(),
      ),
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Laporan berhasil disalin'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan'),
        actions: [
          IconButton(
            onPressed: _export,
            icon: const Icon(Icons.copy),
            tooltip: 'Salin laporan',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          OutlinedButton.icon(
            onPressed: _pilihTanggal,
            icon: const Icon(Icons.calendar_month),
            label: Text(
              tanggalTampilan(_tanggalDatabase()),
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<Ringkasan>(
            future: _futureRingkasan,
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Text(
                  'Error: ${snapshot.error}',
                );
              }

              final data = snapshot.data!;

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ringkasan',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Kegiatan: ${data.selesai}/${data.jumlahKegiatan}',
                      ),
                      Text(
                        'Pemasukan: ${rupiah(data.pemasukan)}',
                      ),
                      Text(
                        'Pengeluaran: ${rupiah(data.pengeluaran)}',
                      ),
                      Text(
                        'Tabungan: ${rupiah(data.tabungan)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: data.tabungan < 0
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          FutureBuilder<Map<String, int>>(
            future: _futureKategori,
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final kategori = snapshot.data ?? {};

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pengeluaran per Kategori',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge,
                      ),
                      const SizedBox(height: 12),
                      if (kategori.isEmpty)
                        const Text(
                          'Belum ada pengeluaran.',
                        )
                      else
                        ...kategori.entries.map(
                              (item) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(item.key),
                            trailing: Text(
                              rupiah(item.value),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          FutureBuilder<
              List<Map<String, Object?>>>(
            future: _futureTujuhHari,
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final data = snapshot.data ?? [];

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        '7 Hari Terakhir',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge,
                      ),
                      const SizedBox(height: 12),
                      if (data.isEmpty)
                        const Text(
                          'Belum ada data.',
                        )
                      else
                        ...data.map(
                              (item) {
                            final tanggal =
                            item['tanggal'] as String;
                            final pemasukan =
                                (item['pemasukan'] as int?) ??
                                    0;
                            final pengeluaran =
                                (item['pengeluaran'] as int?) ??
                                    0;

                            return ListTile(
                              contentPadding:
                              EdgeInsets.zero,
                              title: Text(
                                tanggalTampilan(tanggal),
                              ),
                              subtitle: Text(
                                'Pemasukan ${rupiah(pemasukan)} • '
                                    'Pengeluaran ${rupiah(pengeluaran)}',
                              ),
                              trailing: Text(
                                rupiah(
                                  pemasukan -
                                      pengeluaran,
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}