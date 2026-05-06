import 'package:flutter/material.dart';

class AnimatedBus extends StatefulWidget {
  final String label;
  final Color color;
  final bool isActive;

  const AnimatedBus({
    super.key,
    required this.label,
    required this.color,
    this.isActive = false,
  });

  @override
  State<AnimatedBus> createState() => _AnimatedBusState();
}

class _AnimatedBusState extends State<AnimatedBus>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 20,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.color.withOpacity(0.2),
            widget.color.withOpacity(0.6),
            widget.color.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: widget.color.withOpacity(0.5)),
      ),
      child: widget.isActive
          ? AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: BusFlowPainter(
                    color: widget.color,
                    progress: _controller.value,
                  ),
                );
              },
            )
          : Center(
              child: Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }
}

class BusFlowPainter extends CustomPainter {
  final Color color;
  final double progress;

  BusFlowPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final dashWidth = size.width / 5;
    final dashSpace = size.width / 10;
    final startX = -dashSpace + (size.width + dashSpace) * progress;

    for (double x = startX; x < size.width; x += dashWidth + dashSpace) {
      canvas.drawLine(
        Offset(x.clamp(0, size.width), size.height / 2),
        Offset((x + dashWidth).clamp(0, size.width), size.height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant BusFlowPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}