String rupiah(int angka) {
  final teks = angka.abs().toString();
  final hasil = <String>[];

  for (int i = teks.length; i > 0; i -= 3) {
    final mulai = i - 3 < 0 ? 0 : i - 3;
    hasil.insert(0, teks.substring(mulai, i));
  }

  final nilai = hasil.join('.');

  return angka < 0 ? '-Rp $nilai' : 'Rp $nilai';
}

String tanggalHariIni() {
  final now = DateTime.now();

  return '${now.year.toString().padLeft(4, '0')}-'
      '${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}';
}

String tanggalTampilan(String tanggal) {
  final bagian = tanggal.split('-');

  if (bagian.length != 3) {
    return tanggal;
  }

  const bulan = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  final nomorBulan = int.tryParse(bagian[1]);

  if (nomorBulan == null ||
      nomorBulan < 1 ||
      nomorBulan > 12) {
    return tanggal;
  }

  return '${int.parse(bagian[2])} '
      '${bulan[nomorBulan - 1]} '
      '${bagian[0]}';
}