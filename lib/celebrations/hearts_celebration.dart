// lib/celebrations/hearts_celebration.dart
import 'dart:math';
import 'package:flutter/material.dart';

class HeartsCelebration extends StatefulWidget {
  const HeartsCelebration({super.key, required this.onEnd});
  final VoidCallback onEnd;

  @override
  State<HeartsCelebration> createState() => _HeartsCelebrationState();
}

class _HeartParticle {
  double x = 0;
  double y = 0;
  double size = 0;
  Color color = Colors.red;
  double speedY = 0;
  double speedX = 0;
  double wobbleOffset = 0;
  double wobbleSpeed = 0;
  double scale = 0;
  double rotation = 0;
  double rotationSpeed = 0;

  _HeartParticle(Size screenSize, Random random) {
    x = random.nextDouble() * screenSize.width;
    y = screenSize.height + 50;
    size = random.nextDouble() * 30 + 20;
    final heartColors = [
      Colors.red,
      Colors.pink,
      Colors.pinkAccent,
      Colors.redAccent,
      const Color(0xFFFF69B4), // Hot pink
      const Color(0xFFFF1493), // Deep pink
    ];
    color = heartColors[random.nextInt(heartColors.length)];
    speedY = -(random.nextDouble() * 3 + 2);
    speedX = (random.nextDouble() - 0.5) * 2;
    wobbleSpeed = random.nextDouble() * 0.1 + 0.05;
    scale = 0.0;
    rotationSpeed = (random.nextDouble() - 0.5) * 0.05;
  }

  bool update(Size screenSize, double animationValue) {
    y += speedY;
    x += speedX;
    wobbleOffset += wobbleSpeed;
    rotation += rotationSpeed;

    // Wobble effect
    x += sin(wobbleOffset) * 1.5;

    // Scale animation for appearance
    if (scale < 1.0) {
      scale = min(1.0, scale + 0.05);
    }

    // Fade out at the top
    if (y < screenSize.height * 0.2) {
      scale = max(0.0, scale - 0.02);
    }

    return y > -100 && scale > 0;
  }
}

class _HeartsCelebrationState extends State<HeartsCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_HeartParticle> _particles = [];
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
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

        // Add new hearts periodically
        if (_controller.value < 0.8 && _random.nextDouble() < 0.15) {
          _particles.add(_HeartParticle(size, _random));
        }

        // Update particles
        _particles.removeWhere(
            (particle) => !particle.update(size, _controller.value));

        return CustomPaint(
          painter: _HeartsPainter(particles: _particles),
          size: Size.infinite,
        );
      },
    );
  }
}

class _HeartsPainter extends CustomPainter {
  _HeartsPainter({required this.particles});

  final List<_HeartParticle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      canvas.save();
      canvas.translate(particle.x, particle.y);
      canvas.rotate(particle.rotation);
      canvas.scale(particle.scale);

      _drawHeart(canvas, particle.size, particle.color);

      canvas.restore();
    }
  }

  void _drawHeart(Canvas canvas, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // Heart shape using cubic bezier curves
    final heartSize = size * 0.5;

    // Start from bottom point
    path.moveTo(0, heartSize * 0.3);

    // Left curve
    path.cubicTo(
      -heartSize * 0.5,
      -heartSize * 0.1,
      -heartSize * 0.8,
      -heartSize * 0.4,
      -heartSize * 0.3,
      -heartSize * 0.7,
    );

    // Top left bump
    path.cubicTo(
      -heartSize * 0.1,
      -heartSize * 0.9,
      heartSize * 0.1,
      -heartSize * 0.9,
      heartSize * 0.3,
      -heartSize * 0.7,
    );

    // Right curve
    path.cubicTo(
      heartSize * 0.8,
      -heartSize * 0.4,
      heartSize * 0.5,
      -heartSize * 0.1,
      0,
      heartSize * 0.3,
    );

    path.close();

    // Add shadow effect
    canvas.drawShadow(path, Colors.black26, 3.0, false);
    canvas.drawPath(path, paint);

    // Add highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final highlightPath = Path();
    highlightPath.moveTo(-heartSize * 0.2, -heartSize * 0.4);
    highlightPath.cubicTo(
      -heartSize * 0.1,
      -heartSize * 0.6,
      heartSize * 0.1,
      -heartSize * 0.6,
      heartSize * 0.2,
      -heartSize * 0.4,
    );
    highlightPath.cubicTo(
      heartSize * 0.1,
      -heartSize * 0.3,
      -heartSize * 0.1,
      -heartSize * 0.3,
      -heartSize * 0.2,
      -heartSize * 0.4,
    );

    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
