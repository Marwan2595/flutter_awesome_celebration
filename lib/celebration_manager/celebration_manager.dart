// lib/src/celebration_manager.dart
import 'package:awesome_celebration/celebrations/confetti_celebration.dart';
import 'package:awesome_celebration/celebrations/emoji_rain_celebration.dart';
import 'package:awesome_celebration/celebrations/fireworks_celebration.dart';
import 'package:awesome_celebration/celebrations/hearts_celebration.dart';
import 'package:awesome_celebration/celebrations/stars_celebration.dart';
import 'package:awesome_celebration/enums/celebration_type.dart';
import 'package:flutter/material.dart';

class CelebrationManager {
  static final Map<CelebrationType, OverlayEntry?> _activeOverlays = {};

  /// Shows a celebration overlay of the specified type
  ///
  /// [context] - The build context to show the overlay
  /// [type] - The type of celebration to show
  /// [onEnd] - Optional callback when celebration ends
  /// [dismissOnTap] - Whether to dismiss celebration on tap (default: true)
  static void show(
    BuildContext context, {
    required CelebrationType type,
    VoidCallback? onEnd,
    bool dismissOnTap = true,
  }) {
    // Dismiss any existing celebration of the same type
    dismiss(type);

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    void endCelebration() {
      dismiss(type);
      onEnd?.call();
    }

    overlayEntry = OverlayEntry(
      builder: (context) => _CelebrationOverlay(
        type: type,
        onEnd: endCelebration,
        dismissOnTap: dismissOnTap,
      ),
    );

    _activeOverlays[type] = overlayEntry;
    overlay.insert(overlayEntry);
  }

  /// Dismisses a specific celebration type
  static void dismiss(CelebrationType type) {
    final overlayEntry = _activeOverlays[type];
    if (overlayEntry != null) {
      overlayEntry.remove();
      _activeOverlays[type] = null;
    }
  }

  /// Dismisses all active celebrations
  static void dismissAll() {
    for (final type in CelebrationType.values) {
      dismiss(type);
    }
  }

  /// Checks if a celebration of the specified type is currently active
  static bool isActive(CelebrationType type) {
    return _activeOverlays[type] != null;
  }

  /// Checks if any celebration is currently active
  static bool get hasActiveCelebrations {
    return _activeOverlays.values.any((overlay) => overlay != null);
  }
}

class _CelebrationOverlay extends StatelessWidget {
  const _CelebrationOverlay({
    required this.type,
    required this.onEnd,
    required this.dismissOnTap,
  });

  final CelebrationType type;
  final VoidCallback onEnd;
  final bool dismissOnTap;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: dismissOnTap ? onEnd : null,
        child: Material(
          color: Colors.transparent,
          child: _getCelebrationWidget(type),
        ),
      ),
    );
  }

  Widget _getCelebrationWidget(CelebrationType type) {
    return switch (type) {
      CelebrationType.confetti => ConfettiCelebration(onEnd: onEnd),
      CelebrationType.emojiRain => EmojiRainCelebration(onEnd: onEnd),
      CelebrationType.fireworks => FireworksCelebration(onEnd: onEnd),
      CelebrationType.hearts => HeartsCelebration(onEnd: onEnd),
      CelebrationType.stars => StarsCelebration(onEnd: onEnd),
    };
  }
}
