// lib/celebrations/stars_celebration.dart
import 'dart:math';
import 'package:flutter/material.dart';

class StarsCelebration extends StatefulWidget {
  const StarsCelebration({super.key, required this.onEnd});
  final VoidCallback onEnd;

  @override
  State<StarsCelebration> createState() => _StarsCelebrationState();
}

class _StarParticle {
  double x = 0;
  double y = 0;
  double size = 0;
  Color color = Colors.yellow;
  double twinklePhase = 0;
  double twinkleSpeed = 0;
  double opacity = 1.0;
  double rotationSpeed = 0;
  double rotation = 0;
  double pulsePhase = 0;
  double pulseSpeed = 0;
  double life = 1.0;

  _StarParticle(Size screenSize, Random random) {
    x = random.nextDouble() * screenSize.width;
    y = random.nextDouble() * screenSize.height;
    size = random.nextDouble() * 25 + 15;
    final starColors = [
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.white,
      const Color(0xFFFFD700), // Gold
      const Color(0xFFFFA500), // Orange
      const Color(0xFFFFFF00), // Bright yellow
    ];
    color = starColors[random.nextInt(starColors.length)];
    twinkleSpeed = random.nextDouble() * 0.2 + 0.1;
    rotationSpeed = (random.nextDouble() - 0.5) * 0.1;
    pulseSpeed = random.nextDouble() * 0.15 + 0.05;
    twinklePhase = random.nextDouble() * 2 * pi;
    pulsePhase = random.nextDouble() * 2 * pi;
  }

  bool update(double animationValue) {
    twinklePhase += twinkleSpeed;
    rotation += rotationSpeed;
    pulsePhase += pulseSpeed;

    // Twinkling effect
    opacity = 0.3 + 0.7 * (sin(twinklePhase) * 0.5 + 0.5);

    // Fade out towards the end
    if (animationValue > 0.7) {
      life = max(0.0, life - 0.02);
    }

    return life > 0;
  }

  double getPulseSize() {
    return size * (0.8 + 0.4 * (sin(pulsePhase) * 0.5 + 0.5));
  }
}

class _StarsCelebrationState extends State<StarsCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_StarParticle> _particles = [];
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onEnd();
        }
      });

    // Create initial stars
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      for (int i = 0; i < 30; i++) {
        _particles.add(_StarParticle(size, _random));
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
        final size = MediaQuery.of(context).size;

        // Add more stars during the first half
        if (_controller.value < 0.5 && _random.nextDouble() < 0.1) {
          _particles.add(_StarParticle(size, _random));
        }

        // Update particles
        _particles
            .removeWhere((particle) => !particle.update(_controller.value));

        return CustomPaint(
          painter: _StarsPainter(particles: _particles),
          size: Size.infinite,
        );
      },
    );
  }
}

class _StarsPainter extends CustomPainter {
  _StarsPainter({required this.particles});

  final List<_StarParticle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      canvas.save();
      canvas.translate(particle.x, particle.y);
      canvas.rotate(particle.rotation);

      _drawStar(canvas, particle.getPulseSize(), particle.color,
          particle.opacity * particle.life);

      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, double size, Color color, double opacity) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    final path = Path();
    const points = 5;
    final outerRadius = size * 0.5;
    final innerRadius = outerRadius * 0.4;

    for (int i = 0; i < points * 2; i++) {
      final angle = (i * pi) / points;
      final radius = i.isEven ? outerRadius : innerRadius;
      final x = cos(angle - pi / 2) * radius;
      final y = sin(angle - pi / 2) * radius;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Draw glow effect
    final glowPaint = Paint()
      ..color = color.withOpacity(opacity * 0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    canvas.drawPath(path, glowPaint);

    // Draw the star
    canvas.drawPath(path, paint);

    // Add sparkle lines
    final sparkleLength = size * 0.8;
    final sparklePaint = Paint()
      ..color = Colors.white.withOpacity(opacity * 0.8)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Vertical sparkle line
    canvas.drawLine(
      Offset(0, -sparkleLength / 2),
      Offset(0, sparkleLength / 2),
      sparklePaint,
    );

    // Horizontal sparkle line
    canvas.drawLine(
      Offset(-sparkleLength / 2, 0),
      Offset(sparkleLength / 2, 0),
      sparklePaint,
    );

    // Diagonal sparkle lines
    final diagLength = sparkleLength * 0.7;
    canvas.drawLine(
      Offset(-diagLength / 2, -diagLength / 2),
      Offset(diagLength / 2, diagLength / 2),
      sparklePaint,
    );

    canvas.drawLine(
      Offset(diagLength / 2, -diagLength / 2),
      Offset(-diagLength / 2, diagLength / 2),
      sparklePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
