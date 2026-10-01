import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Praktikum 1',
      home: CounterPage(), // Mengubah home: menjadi const CounterPage()
    );
  }
}

// Class CounterPage berada di bawah MyApp
class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter Saya'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.flutter_dash, size: 80, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              'Halo, nama saya David Yehezkiel!',
              style: TextStyle(fontSize: 24),
            ),
            const Text(
              'NIM: 20240801013',
              style: TextStyle(fontSize: 24),
            ),
            const Text(
              'Jurusan : Teknik Informatika',
              style: TextStyle(fontSize: 20),
            ),
            const Text(
              'Hobi : Musik',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 24),
            Text(
              '$_count',
              style: const TextStyle(fontSize: 48),
            ),
          ],
        ),
      ),

      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              setState(() {
                if (_count > 0) {
                  _count--;}
              });
            },
            child: const Icon(Icons.remove),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _count++;
              });
            },
            child: const Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _count = 0;
              });
            },
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}