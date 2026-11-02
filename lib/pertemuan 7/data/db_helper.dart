import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../models/kegiatan.dart';
import 'package:flutter/foundation.dart';

final ValueNotifier<int> versiData = ValueNotifier<int>(0);

class DbHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }

    final path = p.join(
      await getDatabasesPath(),
      'tabungku.db',
    );

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE kegiatan(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            judul TEXT NOT NULL,
            tanggal TEXT NOT NULL,
            selesai INTEGER NOT NULL,
            tipe TEXT NOT NULL,
            nominal INTEGER NOT NULL,
            kategori TEXT NOT NULL
          )
        ''');
      },
    );

    return _db!;
  }

  static Future<int> tambah(Kegiatan kegiatan) async {
    final db = await database;

    final id = await db.insert(
      'kegiatan',
      kegiatan.toMap(),
    );

    versiData.value++;
    return id;
  }

  static Future<int> ubah(Kegiatan kegiatan) async {
    final db = await database;

    final hasil = await db.update(
      'kegiatan',
      kegiatan.toMap(),
      where: 'id = ?',
      whereArgs: [kegiatan.id],
    );

    versiData.value++;
    return hasil;
  }

  static Future<int> hapus(int id) async {
    final db = await database;

    final hasil = await db.delete(
      'kegiatan',
      where: 'id = ?',
      whereArgs: [id],
    );

    versiData.value++;
    return hasil;
  }

  static Future<int> ubahSelesai(
      int id,
      bool selesai,
      ) async {
    final db = await database;

    final hasil = await db.update(
      'kegiatan',
      {'selesai': selesai ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );

    versiData.value++;
    return hasil;
  }

  static Future<List<Kegiatan>> pada(
      String tanggal,
      ) async {
    final db = await database;

    final rows = await db.query(
      'kegiatan',
      where: 'tanggal = ?',
      whereArgs: [tanggal],
      orderBy: 'id DESC',
    );

    return rows.map(Kegiatan.fromMap).toList();
  }

  static Future<Ringkasan> ringkasan(
      String tanggal,
      ) async {
    final db = await database;

    final hasil = await db.rawQuery('''
      SELECT
        COUNT(*) AS jumlah,
        COALESCE(SUM(selesai), 0) AS selesai,
        COALESCE(
          SUM(
            CASE
              WHEN tipe = 'pemasukan'
              THEN nominal
              ELSE 0
            END
          ),
          0
        ) AS masuk,
        COALESCE(
          SUM(
            CASE
              WHEN tipe = 'pengeluaran'
              THEN nominal
              ELSE 0
            END
          ),
          0
        ) AS keluar
      FROM kegiatan
      WHERE tanggal = ?
    ''', [tanggal]);

    final baris = hasil.first;

    return Ringkasan(
      jumlahKegiatan: (baris['jumlah'] as int?) ?? 0,
      selesai: (baris['selesai'] as int?) ?? 0,
      pemasukan: (baris['masuk'] as int?) ?? 0,
      pengeluaran: (baris['keluar'] as int?) ?? 0,
    );
  }

  static Future<Map<String, int>> pengeluaranPerKategori(
      String tanggal,
      ) async {
    final db = await database;

    final hasil = await db.rawQuery('''
      SELECT
        kategori,
        COALESCE(SUM(nominal), 0) AS total
      FROM kegiatan
      WHERE tanggal = ?
        AND tipe = 'pengeluaran'
      GROUP BY kategori
      ORDER BY total DESC
    ''', [tanggal]);

    return {
      for (final row in hasil)
        row['kategori'] as String:
        (row['total'] as int?) ?? 0,
    };
  }

  static Future<List<Map<String, Object?>>> tujuhHariTerakhir(
      String tanggal,
      ) async {
    final db = await database;

    return db.rawQuery('''
      SELECT
        tanggal,
        COUNT(*) AS jumlah,
        COALESCE(
          SUM(
            CASE
              WHEN tipe = 'pemasukan'
              THEN nominal
              ELSE 0
            END
          ),
          0
        ) AS pemasukan,
        COALESCE(
          SUM(
            CASE
              WHEN tipe = 'pengeluaran'
              THEN nominal
              ELSE 0
            END
          ),
          0
        ) AS pengeluaran
      FROM kegiatan
      WHERE tanggal BETWEEN date(?, '-6 day') AND ?
      GROUP BY tanggal
      ORDER BY tanggal DESC
    ''', [tanggal, tanggal]);
  }

  static Future<List<Kegiatan>> cari(
      String kata,
      ) async {
    final db = await database;

    final rows = await db.query(
      'kegiatan',
      where: '''
        judul LIKE ?
        OR tipe LIKE ?
        OR kategori LIKE ?
      ''',
      whereArgs: [
        '%$kata%',
        '%$kata%',
        '%$kata%',
      ],
      orderBy: 'tanggal DESC, id DESC',
    );

    return rows.map(Kegiatan.fromMap).toList();
  }
}