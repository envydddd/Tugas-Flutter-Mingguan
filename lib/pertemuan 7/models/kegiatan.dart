enum Tipe {
  tanpa,
  pemasukan,
  pengeluaran,
}

class Kegiatan {
  final int? id;
  final String judul;
  final String tanggal;
  final bool selesai;
  final Tipe tipe;
  final int nominal;
  final String kategori;

  const Kegiatan({
    this.id,
    required this.judul,
    required this.tanggal,
    required this.selesai,
    required this.tipe,
    required this.nominal,
    required this.kategori,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'judul': judul,
      'tanggal': tanggal,
      'selesai': selesai ? 1 : 0,
      'tipe': tipe.name,
      'nominal': nominal,
      'kategori': kategori,
    };
  }

  factory Kegiatan.fromMap(Map<String, Object?> map) {
    return Kegiatan(
      id: map['id'] as int,
      judul: map['judul'] as String,
      tanggal: map['tanggal'] as String,
      selesai: (map['selesai'] as int) == 1,
      tipe: Tipe.values.byName(map['tipe'] as String),
      nominal: map['nominal'] as int,
      kategori: map['kategori'] as String,
    );
  }
}

class Ringkasan {
  final int jumlahKegiatan;
  final int selesai;
  final int pemasukan;
  final int pengeluaran;

  const Ringkasan({
    required this.jumlahKegiatan,
    required this.selesai,
    required this.pemasukan,
    required this.pengeluaran,
  });

  int get tabungan => pemasukan - pengeluaran;
}