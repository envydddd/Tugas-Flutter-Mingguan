import 'package:flutter/material.dart';
import '../models/kegiatan.dart';
import '../utils/format.dart';

class KegiatanTile extends StatelessWidget {
  final Kegiatan kegiatan;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onChanged;

  const KegiatanTile({
    super.key,
    required this.kegiatan,
    required this.onEdit,
    required this.onDelete,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    Color? warnaNominal;

    if (kegiatan.tipe == Tipe.pemasukan) {
      warnaNominal = Colors.green;
    } else if (kegiatan.tipe == Tipe.pengeluaran) {
      warnaNominal = Colors.red;
    }

    return Card(
      child: ListTile(
        leading: Checkbox(
          value: kegiatan.selesai,
          onChanged: (value) {
            onChanged(value ?? false);
          },
        ),
        title: Text(
          kegiatan.judul,
          style: TextStyle(
            decoration: kegiatan.selesai
                ? TextDecoration.lineThrough
                : null,
          ),
        ),
        subtitle: Text(
          '${kegiatan.tipe.name} • ${kegiatan.kategori}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (kegiatan.nominal > 0)
              Text(
                '${kegiatan.tipe == Tipe.pemasukan ? '+' : '-'}${rupiah(kegiatan.nominal)}',
                style: TextStyle(
                  color: warnaNominal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}