// lib/src/confetti_celebration.dart
import 'dart:math';
import 'package:flutter/material.dart';

class ConfettiCelebration extends StatefulWidget {
  const ConfettiCelebration({super.key, required this.onEnd});
  final VoidCallback onEnd;

  @override
  State<ConfettiCelebration> createState() => _ConfettiCelebrationState();
}

class _ConfettiParticle {
  double x = 0;
  double y = 0;
  double size = 0;
  Color color = Colors.white;
  double speedY = 0;
  double speedX = 0;
  double gravity = 0;

  _ConfettiParticle(Size screenSize) {
    x = Random().nextDouble() * screenSize.width;
    y = Random().nextDouble() * screenSize.height - screenSize.height;
    size = Random().nextDouble() * 8 + 4;
    color = Colors.primaries[Random().nextInt(Colors.primaries.length)];
    speedY = Random().nextDouble() * 8 + 6;
    speedX = (Random().nextDouble() - 0.5) * 4;
    gravity = 0.2;
  }

  bool update(Size screenSize) {
    y += speedY;
    x += speedX;
    speedY += gravity;
    return y < screenSize.height;
  }
}

class _ConfettiCelebrationState extends State<ConfettiCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_ConfettiParticle> _particles = [];
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onEnd();
        }
      });

    // Initialize particles
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.sizeOf(context);
      for (var i = 0; i < 100; i++) {
        _particles.add(_ConfettiParticle(size));
      }
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ConfettiPainter(
              particles: _particles, animationValue: _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.particles, required this.animationValue});

  final List<_ConfettiParticle> particles;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      particle.update(size);
      final paint = Paint()..color = particle.color;
      canvas.drawRect(
        Rect.fromCenter(
            center: Offset(particle.x, particle.y),
            width: particle.size,
            height: particle.size),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}