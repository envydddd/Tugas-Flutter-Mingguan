import 'package:flutter/material.dart';
import '../data/db_helper.dart';
import '../models/kegiatan.dart';
import '../state/pengaturan.dart';
import '../utils/format.dart';

class FormKegiatanPage extends StatefulWidget {
  final Pengaturan pengaturan;

  const FormKegiatanPage({
    super.key,
    required this.pengaturan,
  });

  @override
  State<FormKegiatanPage> createState() =>
      _FormKegiatanPageState();
}

class _FormKegiatanPageState
    extends State<FormKegiatanPage> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _nominalController = TextEditingController();

  DateTime _tanggal = DateTime.now();
  Tipe _tipe = Tipe.tanpa;
  String _kategori = 'Makan';
  bool _selesai = false;
  Kegiatan? _edit;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_edit != null) {
      return;
    }

    final argument = ModalRoute.of(context)?.settings.arguments;

    if (argument is Kegiatan) {
      _edit = argument;
      _judulController.text = argument.judul;
      _nominalController.text =
      argument.nominal == 0
          ? ''
          : argument.nominal.toString();

      _tanggal = DateTime.tryParse(argument.tanggal) ??
          DateTime.now();
      _tipe = argument.tipe;
      _kategori = argument.kategori == '-'
          ? 'Makan'
          : argument.kategori;
      _selesai = argument.selesai;
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _nominalController.dispose();
    super.dispose();
  }

  String _tanggalDatabase() {
    return '${_tanggal.year.toString().padLeft(4, '0')}-'
        '${_tanggal.month.toString().padLeft(2, '0')}-'
        '${_tanggal.day.toString().padLeft(2, '0')}';
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
      });
    }
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final nominal =
        int.tryParse(_nominalController.text.trim()) ?? 0;

    final kegiatan = Kegiatan(
      id: _edit?.id,
      judul: _judulController.text.trim(),
      tanggal: _tanggalDatabase(),
      selesai: _selesai,
      tipe: _tipe,
      nominal: _tipe == Tipe.tanpa ? 0 : nominal,
      kategori:
      _tipe == Tipe.pengeluaran ? _kategori : '-',
    );

    if (_edit == null) {
      await DbHelper.tambah(kegiatan);
    } else {
      await DbHelper.ubah(kegiatan);
    }

    if (!mounted) {
      return;
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final membutuhkanNominal = _tipe != Tipe.tanpa;
    final membutuhkanKategori = _tipe == Tipe.pengeluaran;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _edit == null
              ? 'Tambah Kegiatan'
              : 'Ubah Kegiatan',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _judulController,
              decoration: const InputDecoration(
                labelText: 'Nama Kegiatan',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Nama kegiatan wajib diisi';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tanggal'),
              subtitle: Text(
                tanggalTampilan(_tanggalDatabase()),
              ),
              trailing: OutlinedButton(
                onPressed: _pilihTanggal,
                child: const Text('Pilih'),
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Tipe>(
              initialValue: _tipe,
              decoration: const InputDecoration(
                labelText: 'Jenis Keuangan',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: Tipe.tanpa,
                  child: Text('Tidak melibatkan uang'),
                ),
                DropdownMenuItem(
                  value: Tipe.pemasukan,
                  child: Text('Pemasukan'),
                ),
                DropdownMenuItem(
                  value: Tipe.pengeluaran,
                  child: Text('Pengeluaran'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _tipe = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            if (membutuhkanNominal)
              TextFormField(
                controller: _nominalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nominal',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (!membutuhkanNominal) {
                    return null;
                  }

                  final nominal =
                  int.tryParse(value ?? '');

                  if (nominal == null || nominal <= 0) {
                    return 'Nominal harus lebih dari 0';
                  }

                  return null;
                },
              ),
            if (membutuhkanNominal)
              const SizedBox(height: 16),
            if (membutuhkanKategori)
              DropdownButtonFormField<String>(
                initialValue: _kategori,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Makan',
                    child: Text('Makan'),
                  ),
                  DropdownMenuItem(
                    value: 'Transport',
                    child: Text('Transport'),
                  ),
                  DropdownMenuItem(
                    value: 'Belajar',
                    child: Text('Belajar'),
                  ),
                  DropdownMenuItem(
                    value: 'Hiburan',
                    child: Text('Hiburan'),
                  ),
                  DropdownMenuItem(
                    value: 'Lainnya',
                    child: Text('Lainnya'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _kategori = value;
                    });
                  }
                },
              ),
            if (membutuhkanKategori)
              const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Sudah selesai'),
              value: _selesai,
              onChanged: (value) {
                setState(() {
                  _selesai = value;
                });
              },
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _simpan,
              icon: const Icon(Icons.save),
              label: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}