import 'package:flutter/material.dart';

class StatsRow extends StatelessWidget {
  final List<dynamic> assets;

  const StatsRow({super.key, required this.assets});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          _MiniStatCard(
            label: 'Assets',
            value: assets.length.toString(),
            color: const Color(0xFF7C3AED),
          ),
          const SizedBox(width: 12),
          _MiniStatCard(
            label: '24h Vol',
            value: '\$${(assets.fold(0.0, (sum, a) => sum + a.value) / 1000).toStringAsFixed(1)}K',
            color: const Color(0xFF14B8A6),
          ),
          const SizedBox(width: 12),
          _MiniStatCard(
            label: 'Profit',
            value: '+12.5%',
            color: const Color(0xFF22C55E),
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withAlpha(77),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0x80FFFFFF),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}