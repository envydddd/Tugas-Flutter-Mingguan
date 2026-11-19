import 'package:flutter/material.dart';
import '../data/db_helper.dart';
import '../models/kegiatan.dart';
import '../state/pengaturan.dart';
import '../utils/format.dart';
import '../widgets/kegiatan_tile.dart';
import '../widgets/ringkasan_card.dart';

class BerandaPage extends StatefulWidget {
  final Pengaturan pengaturan;

  const BerandaPage({
    super.key,
    required this.pengaturan,
  });

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  late Future<List<Kegiatan>> _futureKegiatan;
  late Future<Ringkasan> _futureRingkasan;

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

  void _muat() {
    final tanggal = tanggalHariIni();

    _futureKegiatan = DbHelper.pada(tanggal);
    _futureRingkasan = DbHelper.ringkasan(tanggal);
  }

  void _refresh() {
    if (!mounted) {
      return;
    }

    setState(() {
      _muat();
    });
  }

  Future<void> _hapus(Kegiatan kegiatan) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus kegiatan?'),
          content: Text(
            'Kegiatan "${kegiatan.judul}" akan dihapus.',
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

    if (konfirmasi == true && kegiatan.id != null) {
      await DbHelper.hapus(kegiatan.id!);
    }
  }

  void _tambah() {
    Navigator.pushNamed(
      context,
      '/form',
    );
  }

  void _ubah(Kegiatan kegiatan) {
    Navigator.pushNamed(
      context,
      '/form',
      arguments: kegiatan,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TabungKu'),
      ),
      body: FutureBuilder(
        future: Future.wait([
          _futureKegiatan,
          _futureRingkasan,
        ]),
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
                'Terjadi kesalahan: ${snapshot.error}',
              ),
            );
          }

          final data = snapshot.data!;

          final kegiatan =
          data[0] as List<Kegiatan>;
          final ringkasan =
          data[1] as Ringkasan;

          return RefreshIndicator(
            onRefresh: () async {
              setState(_muat);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  tanggalTampilan(tanggalHariIni()),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium,
                ),
                const SizedBox(height: 12),
                RingkasanCard(
                  ringkasan: ringkasan,
                  target: widget.pengaturan.target,
                ),
                const SizedBox(height: 20),
                if (kegiatan.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.inbox_outlined,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Belum ada kegiatan hari ini.',
                          ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: _tambah,
                            icon: const Icon(Icons.add),
                            label: const Text(
                              'Tambah Kegiatan',
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...kegiatan.map(
                        (item) => KegiatanTile(
                      kegiatan: item,
                      onEdit: () => _ubah(item),
                      onDelete: () => _hapus(item),
                      onChanged: (value) {
                        if (item.id != null) {
                          DbHelper.ubahSelesai(
                            item.id!,
                            value,
                          );
                        }
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambah,
        child: const Icon(Icons.add),
      ),
    );
  }
}