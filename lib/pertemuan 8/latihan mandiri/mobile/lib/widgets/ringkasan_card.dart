import 'package:flutter/material.dart';
import '../models/kegiatan.dart';
import '../utils/format.dart';

class RingkasanCard extends StatelessWidget {
  final Ringkasan ringkasan;
  final double target;

  const RingkasanCard({
    super.key,
    required this.ringkasan,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final progress = target <= 0
        ? 0.0
        : (ringkasan.tabungan / target).clamp(0.0, 1.0);

    final tercapai =
        ringkasan.tabungan >= target && target > 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ringkasan Hari Ini',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _Item(
                    label: 'Kegiatan',
                    value:
                    '${ringkasan.selesai}/${ringkasan.jumlahKegiatan}',
                  ),
                ),
                Expanded(
                  child: _Item(
                    label: 'Pemasukan',
                    value: rupiah(ringkasan.pemasukan),
                  ),
                ),
                Expanded(
                  child: _Item(
                    label: 'Pengeluaran',
                    value: rupiah(ringkasan.pengeluaran),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Tabungan',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              rupiah(ringkasan.tabungan),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ringkasan.tabungan < 0
                    ? Colors.red
                    : Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            TweenAnimationBuilder<double>(
              tween: Tween(
                begin: 0,
                end: progress,
              ),
              duration: const Duration(milliseconds: 700),
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 10,
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              tercapai
                  ? 'Target tercapai! Bagus.'
                  : 'Target ${rupiah(target.toInt())}',
              style: TextStyle(
                color: ringkasan.tabungan < 0
                    ? Colors.red
                    : null,
              ),
            ),
            if (ringkasan.tabungan < 0) ...[
              const SizedBox(height: 8),
              const Text(
                'Pengeluaran lebih besar daripada pemasukan.',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final String label;
  final String value;

  const _Item({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}