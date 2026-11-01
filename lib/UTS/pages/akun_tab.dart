import 'package:flutter/material.dart';

class AkunTab extends StatefulWidget {
  const AkunTab({super.key});

  @override
  State<AkunTab> createState() => _AkunTabState();
}

class _AkunTabState extends State<AkunTab> {
  String _nama = "David Yehezkiel";
  String _email = "david.yehezkiel@gmail.com";
  String _noWhatsApp = "081234567890";

  final _waController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _waController.text = _noWhatsApp;
  }

  @override
  void dispose() {
    _waController.dispose();
    super.dispose();
  }

  void _simpanProfil() {
    setState(() {
      _noWhatsApp = _waController.text;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil berhasil diperbarui!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Pengguna')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
          ),
          const SizedBox(height: 32),
          TextFormField(
            initialValue: _nama,
            decoration: const InputDecoration(
              labelText: 'Nama Lengkap',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
            readOnly: true,
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _email,
            decoration: const InputDecoration(
              labelText: 'Email Gmail',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email_outlined),
            ),
            readOnly: true,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _waController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Nomor WhatsApp',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone_android),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _simpanProfil,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Simpan Perubahan', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            label: const Text('Keluar Akun (Logout)', style: TextStyle(color: Colors.redAccent)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              side: const BorderSide(color: Colors.redAccent),
            ),
          )
        ],
      ),
    );
  }
}