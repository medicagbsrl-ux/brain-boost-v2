import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Widget per animazioni di celebrazione quando utente completa un gioco
class CelebrationAnimation extends StatefulWidget {
  final String message;
  final int score;
  final VoidCallback onComplete;

  const CelebrationAnimation({
    super.key,
    required this.message,
    required this.score,
    required this.onComplete,
  });

  @override
  State<CelebrationAnimation> createState() => _CelebrationAnimationState();
}

class _CelebrationAnimationState extends State<CelebrationAnimation>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _confettiController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Scale animation for score
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    // Confetti animation
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Start animations
    _scaleController.forward();
    _confettiController.forward();

    // Auto-dismiss after animation
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Confetti particles
            Stack(
              children: List.generate(
                20,
                (index) => _buildConfettiParticle(index),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Success icon with scale animation
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Success message
            FadeTransition(
              opacity: _scaleAnimation,
              child: Column(
                children: [
                  Text(
                    widget.message,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      'Punteggio: ${widget.score}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfettiParticle(int index) {
    final random = math.Random(index);
    final startX = random.nextDouble() * 400 - 200;
    final endY = random.nextDouble() * 300 + 100;
    final color = Colors.primaries[index % Colors.primaries.length];
    final size = random.nextDouble() * 10 + 5;

    return AnimatedBuilder(
      animation: _confettiController,
      builder: (context, child) {
        final progress = _confettiController.value;
        final y = progress * endY;
        final x = startX + math.sin(progress * math.pi * 2) * 50;
        final rotation = progress * math.pi * 4;

        return Transform.translate(
          offset: Offset(x, y),
          child: Transform.rotate(
            angle: rotation,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color.withOpacity(1 - progress),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Helper function per mostrare animazione celebrazione
Future<void> showCelebrationAnimation(
  BuildContext context, {
  required String message,
  required int score,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => CelebrationAnimation(
      message: message,
      score: score,
      onComplete: () => Navigator.of(context).pop(),
    ),
  );
}
