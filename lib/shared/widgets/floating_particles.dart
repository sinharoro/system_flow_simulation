import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class FloatingParticles extends StatefulWidget {
  final int count;
  final Widget child;

  const FloatingParticles({
    super.key,
    this.count = 15,
    required this.child,
  });

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<FloatingParticles>
    with TickerProviderStateMixin {
  late List<Particle> _particles;
  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _particles = List.generate(widget.count, (_) => Particle());
    _controllers = _particles.map((p) {
      final controller = AnimationController(
        duration: Duration(milliseconds: p.duration),
        vsync: this,
      )..repeat(reverse: true);
      return controller;
    }).toList();
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ..._particles.asMap().entries.map((entry) {
          final index = entry.key;
          final particle = entry.value;
          return AnimatedBuilder(
            animation: _controllers[index],
            builder: (context, child) {
              final value = _controllers[index].value;
              return Positioned(
                left: particle.x,
                top: particle.y + (value * 20 - 10),
                child: Opacity(
                  opacity: particle.opacity * (0.5 + value * 0.5),
                  child: Container(
                    width: particle.size,
                    height: particle.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: particle.color,
                    ),
                  ),
                ),
              );
            },
          );
        }),
        widget.child,
      ],
    );
  }
}

class Particle {
  final double x;
  final double y;
  final double size;
  final double opacity;
  final int duration;
  final Color color;

  Particle()
      : x = Random().nextDouble() * 400,
        y = Random().nextDouble() * 800,
        size = Random().nextDouble() * 4 + 2,
        opacity = Random().nextDouble() * 0.5 + 0.1,
        duration = Random().nextInt(4000) + 3000,
        color = Random().nextBool() ? AppColors.primaryPurple : AppColors.primaryTeal;
}