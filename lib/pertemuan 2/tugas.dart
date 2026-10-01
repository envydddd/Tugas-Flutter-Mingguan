import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Daftar Kontak',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const ContactPage(),
    );
  }
}

class Contact {
  final String nama;
  final String telepon;
  final String email;

  const Contact(this.nama, this.telepon, this.email);
}

const daftarkontak = [
  Contact('David', '081234567890', 'david@gmail.com'),
  Contact('Michael', '08091238423', 'mekel@gmail.com'),
  Contact('Andrew', '085711223344', 'acen@gmail.com'),
  Contact('Ferdi', '081355667788', 'ferfer@gmail.com'),
  Contact('Budi', '089644332211', 'budi@gmail.com'),
  Contact('Van', '087866778899', 'van@gmail.com'),
];

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Kontak'),
      ),
      body: ListView.builder(
        itemCount: daftarkontak.length,
        itemBuilder: (context, index) {
          final item = daftarkontak[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(item.nama[0]),
              ),
              title: Text(item.nama),
              subtitle: Text(item.telepon),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailPage(kontak: item),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final Contact kontak;

  const DetailPage({super.key, required this.kontak});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(kontak.nama),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              child: Text(
                kontak.nama[0],
                style: const TextStyle(fontSize: 32),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              kontak.nama,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('No HP: ${kontak.telepon}', style: const TextStyle(fontSize: 16)),
            Text('Email: ${kontak.email}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }
}