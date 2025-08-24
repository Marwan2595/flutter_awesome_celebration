// lib/celebrations/fireworks_celebration.dart
import 'dart:math';
import 'package:flutter/material.dart';

class FireworksCelebration extends StatefulWidget {
  const FireworksCelebration({super.key, required this.onEnd});
  final VoidCallback onEnd;

  @override
  State<FireworksCelebration> createState() => _FireworksCelebrationState();
}

class _FireworkParticle {
  double x = 0;
  double y = 0;
  double velocityX = 0;
  double velocityY = 0;
  Color color = Colors.white;
  double size = 0;
  double life = 1.0;
  double gravity = 0;

  _FireworkParticle({
    required this.x,
    required this.y,
    required this.velocityX,
    required this.velocityY,
    required this.color,
    required this.size,
  }) {
    gravity = 0.1;
  }

  bool update() {
    x += velocityX;
    y += velocityY;
    velocityY += gravity;
    life -= 0.02;
    velocityX *= 0.99; // Air resistance
    velocityY *= 0.99;
    return life > 0;
  }
}

class _Firework {
  double x = 0;
  double y = 0;
  double velocityY = 0;
  bool exploded = false;
  List<_FireworkParticle> particles = [];
  Color color = Colors.white;

  _Firework(Size screenSize, Random random) {
    x = random.nextDouble() * screenSize.width;
    y = screenSize.height;
    velocityY = -(random.nextDouble() * 10 + 15); // Upward velocity
    color = Colors.primaries[random.nextInt(Colors.primaries.length)];
  }

  bool update(Size screenSize, Random random) {
    if (!exploded) {
      y += velocityY;
      velocityY += 0.3; // Gravity

      // Explode when reaching peak or random height
      if (velocityY >= 0 ||
          (y < screenSize.height * 0.3 && random.nextDouble() < 0.02)) {
        explode(random);
      }
    } else {
      // Update particles
      particles.removeWhere((particle) => !particle.update());
    }

    return !exploded || particles.isNotEmpty;
  }

  void explode(Random random) {
    exploded = true;
    // Create explosion particles
    for (int i = 0; i < 25; i++) {
      final angle = (i / 25) * 2 * pi;
      final speed = random.nextDouble() * 8 + 4;
      particles.add(_FireworkParticle(
        x: x,
        y: y,
        velocityX: cos(angle) * speed,
        velocityY: sin(angle) * speed,
        color: color,
        size: random.nextDouble() * 4 + 2,
      ));
    }
  }
}

class _FireworksCelebrationState extends State<FireworksCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Firework> _fireworks = [];
  final _random = Random();
  int _fireworksLaunched = 0;
  final int _maxFireworks = 8;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onEnd();
        }
      });

    _controller.forward();
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
        final size = MediaQuery.of(context).size;

        // Launch fireworks periodically
        if (_fireworksLaunched < _maxFireworks &&
            _controller.value > (_fireworksLaunched / _maxFireworks) * 0.7) {
          _fireworks.add(_Firework(size, _random));
          _fireworksLaunched++;
        }

        // Update fireworks
        _fireworks.removeWhere((firework) => !firework.update(size, _random));

        return CustomPaint(
          painter: _FireworksPainter(fireworks: _fireworks),
          size: Size.infinite,
        );
      },
    );
  }
}

class _FireworksPainter extends CustomPainter {
  _FireworksPainter({required this.fireworks});

  final List<_Firework> fireworks;

  @override
  void paint(Canvas canvas, Size size) {
    for (final firework in fireworks) {
      if (!firework.exploded) {
        // Draw rocket trail
        final paint = Paint()
          ..color = firework.color
          ..strokeWidth = 3;
        canvas.drawCircle(Offset(firework.x, firework.y), 3, paint);
      } else {
        // Draw explosion particles
        for (final particle in firework.particles) {
          final paint = Paint()
            ..color = particle.color.withOpacity(particle.life)
            ..strokeWidth = particle.size;
          canvas.drawCircle(
            Offset(particle.x, particle.y),
            particle.size,
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
