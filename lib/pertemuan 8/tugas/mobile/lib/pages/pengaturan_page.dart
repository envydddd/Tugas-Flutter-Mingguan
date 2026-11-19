import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../state/pengaturan.dart';
import '../utils/format.dart';

class PengaturanPage extends StatefulWidget {
  final Pengaturan pengaturan;

  const PengaturanPage({
    super.key,
    required this.pengaturan,
  });

  @override
  State<PengaturanPage> createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> {
  Future<void> _dialogUbahUrl(BuildContext context) async {
    final controller = TextEditingController(text: ApiConfig.url);
    final formKey = GlobalKey<FormState>();

    final disimpan = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Alamat Server API'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'URL Backend',
              hintText: 'http://10.0.2.2:8000',
              border: OutlineInputBorder(),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Alamat URL wajib diisi';
              }
              final uri = Uri.tryParse(val.trim());
              if (uri == null ||
                  !uri.hasScheme ||
                  (!uri.isScheme('http') && !uri.isScheme('https')) ||
                  uri.host.isEmpty) {
                return 'Format URL tidak valid (gunakan http:// atau https://)';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await ApiConfig.simpanUrl(controller.text);
                if (ctx.mounted) Navigator.pop(ctx, true);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (disimpan == true && mounted) {
      setState(() {}); // Perbarui teks subtitle URL di halaman Pengaturan
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Alamat API disimpan: ${ApiConfig.url}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pengaturan = widget.pengaturan;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Pengaturan',
          style: Theme.of(context).textTheme.headlineSmall,
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
                subtitle: const Text(
                  'Warna saat ini',
                ),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    _Warna(
                      color: Colors.blue,
                      selected: pengaturan.warna.toARGB32() ==
                          Colors.blue.toARGB32(),
                      onTap: () {
                        pengaturan.ubahWarna(
                          Colors.blue,
                        );
                      },
                    ),
                    _Warna(
                      color: Colors.green,
                      selected: pengaturan.warna.toARGB32() ==
                          Colors.green.toARGB32(),
                      onTap: () {
                        pengaturan.ubahWarna(
                          Colors.green,
                        );
                      },
                    ),
                    _Warna(
                      color: Colors.deepPurple,
                      selected: pengaturan.warna.toARGB32() ==
                          Colors.deepPurple.toARGB32(),
                      onTap: () {
                        pengaturan.ubahWarna(
                          Colors.deepPurple,
                        );
                      },
                    ),
                    _Warna(
                      color: Colors.orange,
                      selected: pengaturan.warna.toARGB32() ==
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Target Tabungan Harian',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  rupiah(
                    pengaturan.target.toInt(),
                  ),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Slider(
                  min: 0,
                  max: 500000,
                  divisions: 100,
                  value: pengaturan.target.clamp(0, 500000),
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
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('Alamat Server API'),
                subtitle: Text(ApiConfig.url),
                trailing: const Icon(Icons.edit),
                onTap: () => _dialogUbahUrl(context),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.cloud_done_outlined),
                title: const Text('Status server'),
                subtitle: const Text('Cek koneksi API dan Database'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(context, '/status'),
              ),
            ],
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