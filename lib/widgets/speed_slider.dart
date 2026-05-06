import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class SpeedSlider extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const SpeedSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<SpeedSlider> createState() => _SpeedSliderState();
}

class _SpeedSliderState extends State<SpeedSlider> {
  double _currentValue = 1.0;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: AppTheme.panelDecoration,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.speed, color: AppTheme.accentCyan, size: 20),
          const SizedBox(width: 8),
          Text(
            'Speed',
            style: GoogleFonts.rajdhani(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          _buildSpeedButton(0.5, 'Slow'),
          _buildSpeedButton(1.0, 'Normal'),
          _buildSpeedButton(2.0, 'Fast'),
        ],
      ),
    );
  }

  Widget _buildSpeedButton(double speed, String label) {
    final isSelected = _currentValue == speed;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: () {
          setState(() {
            _currentValue = speed;
          });
          widget.onChanged(speed);
        },
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.accentCyan.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSelected ? AppTheme.accentCyan : AppTheme.borderColor,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.rajdhani(
              fontSize: 12,
              color: isSelected ? AppTheme.accentCyan : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}