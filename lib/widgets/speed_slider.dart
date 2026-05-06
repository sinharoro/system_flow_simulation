import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class SpeedSlider extends StatefulWidget {
  final int speedMs;
  final ValueChanged<int> onSpeedChanged;

  const SpeedSlider({
    super.key,
    required this.speedMs,
    required this.onSpeedChanged,
  });

  @override
  State<SpeedSlider> createState() => _SpeedSliderState();
}

class _SpeedSliderState extends State<SpeedSlider> {
  double _sliderValue = 0.5;

  @override
  void initState() {
    super.initState();
    _sliderValue = _mapSpeedToSlider(widget.speedMs);
  }

  double _mapSpeedToSlider(int ms) {
    return 1.0 - ((ms - 300) / 1700.0);
  }

  int _mapSliderToSpeed(double value) {
    return (2000 - (value * 1700)).round().clamp(300, 2000);
  }

  String _getSpeedLabel(int ms) {
    if (ms >= 1500) return 'Slow';
    if (ms >= 800) return 'Medium';
    return 'Fast';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.panelDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.speed, color: AppTheme.accentCyan, size: 20),
              const SizedBox(width: 8),
              Text(
                'Speed Control',
                style: GoogleFonts.rajdhani(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                _getSpeedLabel(widget.speedMs),
                style: GoogleFonts.rajdhani(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentAmber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Slow',
                style: GoogleFonts.rajdhani(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              Expanded(
                child: Slider(
                  value: _sliderValue,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (value) {
                    setState(() {
                      _sliderValue = value;
                    });
                    widget.onSpeedChanged(_mapSliderToSpeed(value));
                  },
                  activeColor: AppTheme.accentCyan,
                  inactiveColor: AppTheme.borderColor,
                ),
              ),
              Text(
                'Fast',
                style: GoogleFonts.rajdhani(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          Center(
            child: Text(
              '${widget.speedMs}ms per step',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}