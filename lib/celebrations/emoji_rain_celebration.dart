// lib/src/emoji_rain_celebration.dart
import 'dart:math';
import 'package:flutter/material.dart';

class EmojiRainCelebration extends StatefulWidget {
  const EmojiRainCelebration({super.key, required this.onEnd});
  final VoidCallback onEnd;

  @override
  State<EmojiRainCelebration> createState() => _EmojiRainCelebrationState();
}

class _EmojiParticle {
  double x = 0;
  double y = 0;
  String emoji = '🎉';
  double speed = 0;
  double wobble = 0;

  _EmojiParticle(Size screenSize, Random random) {
    final emojis = ['🎉', '🥳', '🤩', '🤯', '🎊', '👏'];
    x = random.nextDouble() * screenSize.width;
    y = random.nextDouble() * screenSize.height - screenSize.height;
    emoji = emojis[random.nextInt(emojis.length)];
    speed = random.nextDouble() * 5 + 3;
    wobble = random.nextDouble() * 2 - 1; // Value between -1 and 1
  }

  bool update(Size screenSize) {
    y += speed;
    x += wobble; // Creates the left-right wobbling effect
    return y < screenSize.height;
  }
}

class _EmojiRainCelebrationState extends State<EmojiRainCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_EmojiParticle> _particles = [];
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onEnd();
        }
      });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.sizeOf(context);
      for (var i = 0; i < 40; i++) {
        _particles.add(_EmojiParticle(size, _random));
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
        return Stack(
          children: _particles.map((particle) {
            particle.update(MediaQuery.sizeOf(context));
            return Positioned(
              left: particle.x,
              top: particle.y,
              child: Text(
                particle.emoji,
                style: const TextStyle(fontSize: 24),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
