import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class PyramidWidget extends StatefulWidget {
  final List<PyramidLevel> levels;
  final int? activeLevel;
  final bool isAnimating;

  const PyramidWidget({
    super.key,
    required this.levels,
    this.activeLevel,
    this.isAnimating = false,
  });

  @override
  State<PyramidWidget> createState() => _PyramidWidgetState();
}

class _PyramidWidgetState extends State<PyramidWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(_pulseController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: List.generate(widget.levels.length, (index) {
          final reversedIndex = widget.levels.length - 1 - index;
          final level = widget.levels[reversedIndex];
          final widthFactor = 0.3 + (reversedIndex * 0.18);
          final isActive = widget.activeLevel == reversedIndex;
          
          return Positioned(
            bottom: reversedIndex * 52.0,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 280 * widthFactor,
                  height: 44,
                  transform: Matrix4.identity()
                    ..scale(isActive ? _pulseAnimation.value : 1.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        level.color,
                        level.color.withOpacity(0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isActive ? level.color : level.color.withOpacity(0.3),
                      width: isActive ? 3 : 1,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: level.color.withOpacity(0.6),
                              blurRadius: 16,
                              spreadRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isActive)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.8),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            level.name,
                            style: GoogleFonts.rajdhani(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${level.size} | ${level.latency}',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 9,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}

class PyramidLevel {
  final String name;
  final String size;
  final String latency;
  final Color color;

  PyramidLevel({
    required this.name,
    required this.size,
    required this.latency,
    required this.color,
  });
}