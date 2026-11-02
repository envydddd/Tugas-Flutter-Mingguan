import 'package:flutter/material.dart';
import '../state/pengaturan.dart';
import '../utils/format.dart';

class PengaturanPage extends StatelessWidget {
  final Pengaturan pengaturan;

  const PengaturanPage({
    super.key,
    required this.pengaturan,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Pengaturan',
          style: Theme.of(context)
              .textTheme
              .headlineSmall,
        ),
        const SizedBox(height: 20),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Mode Gelap'),
                subtitle: const Text(
                  'Simpan pilihan tema setelah aplikasi ditutup',
                ),
                value: pengaturan.gelap,
                onChanged: pengaturan.ubahGelap,
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Warna Tema'),
                subtitle: Text(
                  'Warna saat ini',
                ),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    _Warna(
                      color: Colors.blue,
                      selected:
                      pengaturan.warna.toARGB32() ==
                          Colors.blue.toARGB32(),
                      onTap: () {
                        pengaturan.ubahWarna(
                          Colors.blue,
                        );
                      },
                    ),
                    _Warna(
                      color: Colors.green,
                      selected:
                      pengaturan.warna.toARGB32() ==
                          Colors.green.toARGB32(),
                      onTap: () {
                        pengaturan.ubahWarna(
                          Colors.green,
                        );
                      },
                    ),
                    _Warna(
                      color: Colors.deepPurple,
                      selected:
                      pengaturan.warna.toARGB32() ==
                          Colors.deepPurple.toARGB32(),
                      onTap: () {
                        pengaturan.ubahWarna(
                          Colors.deepPurple,
                        );
                      },
                    ),
                    _Warna(
                      color: Colors.orange,
                      selected:
                      pengaturan.warna.toARGB32() ==
                          Colors.orange.toARGB32(),
                      onTap: () {
                        pengaturan.ubahWarna(
                          Colors.orange,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Target Tabungan Harian',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  rupiah(
                    pengaturan.target.toInt(),
                  ),
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall,
                ),
                Slider(
                  min: 0,
                  max: 500000,
                  divisions: 100,
                  value: pengaturan.target
                      .clamp(0, 500000),
                  label: rupiah(
                    pengaturan.target.toInt(),
                  ),
                  onChanged: (value) {
                    pengaturan.ubahTarget(value);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Warna extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _Warna({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        backgroundColor: color,
        radius: selected ? 18 : 15,
        child: selected
            ? const Icon(
          Icons.check,
          color: Colors.white,
          size: 18,
        )
            : null,
      ),
    );
  }
}