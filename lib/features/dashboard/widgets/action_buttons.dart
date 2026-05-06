import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _ActionButton(icon: Icons.arrow_upward_rounded, label: 'Send'),
        _ActionButton(icon: Icons.arrow_downward_rounded, label: 'Receive'),
        _ActionButton(icon: Icons.swap_horiz_rounded, label: 'Swap'),
        _ActionButton(icon: Icons.add_rounded, label: 'Add'),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(26),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0x24FFFFFF),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xB3FFFFFF),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}