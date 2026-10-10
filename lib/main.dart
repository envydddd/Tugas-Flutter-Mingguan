import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);
final seedColor = ValueNotifier<Color>(Colors.teal);

const pilihanWarna = [
  Colors.teal,
  Colors.blue,
  Colors.deepOrange,
  Colors.purple,
];

ThemeData buatTema(Color seed, Brightness brightness) {
  return ThemeData(
    useMaterial3: true,
    colorSchemeSeed: seed,
    brightness: brightness,
    appBarTheme: const AppBarTheme(centerTitle: true),
  );
}

class Destinasi {
  final String nama;
  final String lokasi;
  final String deskripsi;
  final IconData ikon;

  const Destinasi(this.nama, this.lokasi, this.deskripsi, this.ikon);
}

const daftarWisata = [
  Destinasi('Candi Borobudur', 'Magelang', 'Candi Buddha terbesar di dunia.', Icons.account_balance),
  Destinasi('Pantai Kuta', 'Bali', 'Pantai pasir putih dengan pemandangan matahari terbenam.', Icons.surfing),
  Destinasi('Gunung Bromo', 'Jawa Timur', 'Gunung berapi aktif dengan pemandangan matahari terbit.', Icons.landscape),
  Destinasi('Danau Toba', 'Sumatera Utara', 'Danau vulkanik terbesar di Indonesia.', Icons.water),
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final isDark = prefs.getBool('isDark') ?? false;
  themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;

  final colorValue = prefs.getInt('seedColor');
  if (colorValue != null) {
    seedColor.value = Color(colorValue);
  }

  runApp(const KatalogApp());
}

class KatalogApp extends StatelessWidget {
  const KatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([themeMode, seedColor]),
      builder: (context, _) {
        return MaterialApp(
          title: 'Katalog Wisata Interaktif',
          debugShowCheckedModeBanner: false,
          theme: buatTema(seedColor.value, Brightness.light),
          darkTheme: buatTema(seedColor.value, Brightness.dark),
          themeMode: themeMode.value,
          initialRoute: '/',
          routes: {
            '/': (context) => const UtamaShell(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/detail') {
              final destinasi = settings.arguments as Destinasi;
              return MaterialPageRoute(
                builder: (context) => DetailWisataPage(destinasi: destinasi),
                settings: settings,
              );
            }
            return null;
          },
        );
      },
    );
  }
}

class UtamaShell extends StatefulWidget {
  const UtamaShell({super.key});

  @override
  State<UtamaShell> createState() => _UtamaShellState();
}

class _UtamaShellState extends State<UtamaShell> {
  int _index = 0;

  static const _halaman = [
    KatalogTab(),
    PromoAnimasiTab(),
    PengaturanTab(),
  ];

  static const _judul = ['Katalog Wisata', 'Promo & Animasi', 'Pengaturan'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_judul[_index])),
      body: IndexedStack(index: _index, children: _halaman),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Wisata',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_offer_outlined),
            selectedIcon: Icon(Icons.local_offer),
            label: 'Promo',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}

class KatalogTab extends StatelessWidget {
  const KatalogTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: daftarWisata.length,
      itemBuilder: (context, i) {
        final item = daftarWisata[i];
        final colorScheme = Theme.of(context).colorScheme;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: ListTile(
            leading: Hero(
              tag: 'wisata-${item.nama}',
              child: CircleAvatar(
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(item.ikon, color: colorScheme.onPrimaryContainer),
              ),
            ),
            title: Text(item.nama, style: Theme.of(context).textTheme.titleMedium),
            subtitle: Text(item.lokasi, style: Theme.of(context).textTheme.bodyMedium),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pushNamed(context, '/detail', arguments: item);
            },
          ),
        );
      },
    );
  }
}

class DetailWisataPage extends StatelessWidget {
  final Destinasi destinasi;

  const DetailWisataPage({super.key, required this.destinasi});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(destinasi.nama)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Center(
              child: Hero(
                tag: 'wisata-${destinasi.nama}',
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: tema.colorScheme.primaryContainer,
                  child: Icon(destinasi.ikon, size: 70, color: tema.colorScheme.onPrimaryContainer),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(destinasi.nama, style: tema.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Chip(
              avatar: const Icon(Icons.location_on, size: 16),
              label: Text(destinasi.lokasi),
            ),
            const SizedBox(height: 16),
            Text(
              destinasi.deskripsi,
              style: tema.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class PromoAnimasiTab extends StatefulWidget {
  const PromoAnimasiTab({super.key});

  @override
  State<PromoAnimasiTab> createState() => _PromoAnimasiTabState();
}

class _PromoAnimasiTabState extends State<PromoAnimasiTab>
    with SingleTickerProviderStateMixin {
  bool _expandedPromo = false;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    // Animasi Eksplisit
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.9,
      upperBound: 1.1,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Animasi Eksplisit (Banner Diskon Pulsating)', style: tema.textTheme.titleMedium),
        const SizedBox(height: 12),
        ScaleTransition(
          scale: _pulseController,
          child: Card(
            color: tema.colorScheme.tertiaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.local_activity, size: 48, color: tema.colorScheme.onTertiaryContainer),
                  const SizedBox(height: 8),
                  Text(
                    'PROMO LIBURAN 50%',
                    style: tema.textTheme.headlineSmall?.copyWith(
                      color: tema.colorScheme.onTertiaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Divider(),
        Text('Animasi Implisit (Kupon Diskon)', style: tema.textTheme.titleMedium),
        const SizedBox(height: 12),
        Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            width: _expandedPromo ? 280 : 180,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _expandedPromo ? tema.colorScheme.primary : tema.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(_expandedPromo ? 24 : 8),
            ),
            child: Column(
              children: [
                Text(
                  _expandedPromo ? 'KUPON AKTIF: LIBURANMURAH' : 'Klik untuk klaim',
                  style: TextStyle(
                    color: _expandedPromo ? tema.colorScheme.onPrimary : tema.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: ElevatedButton(
            onPressed: () => setState(() => _expandedPromo = !_expandedPromo),
            child: Text(_expandedPromo ? 'Tutup Kupon' : 'Klaim Kupon'),
          ),
        ),
      ],
    );
  }
}

class PengaturanTab extends StatelessWidget {
  const PengaturanTab({super.key});

  Future<void> _simpanTema(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', isDark);
  }

  Future<void> _simpanWarna(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('seedColor', color.value);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([themeMode, seedColor]),
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SwitchListTile(
              title: const Text('Mode Gelap'),
              value: themeMode.value == ThemeMode.dark,
              onChanged: (v) {
                themeMode.value = v ? ThemeMode.dark : ThemeMode.light;
                _simpanTema(v);
              },
            ),
            const SizedBox(height: 12),
            Text('Warna Tema Utama', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: [
                for (final c in pilihanWarna)
                  GestureDetector(
                    onTap: () {
                      seedColor.value = c;
                      _simpanWarna(c);
                    },
                    child: CircleAvatar(
                      backgroundColor: c,
                      child: seedColor.value == c
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}