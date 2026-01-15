import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '../../models/session_history.dart';
import '../../services/local_storage_service.dart';


class ReactionTimeGame extends StatefulWidget {
  final String userId;
  final int level;

  const ReactionTimeGame({
    super.key,
    required this.userId,
    this.level = 1,
  });

  @override
  State<ReactionTimeGame> createState() => _ReactionTimeGameState();
}

class _ReactionTimeGameState extends State<ReactionTimeGame> {
  late DateTime startTime;
  int currentRound = 0;
  late int totalRounds;
  List<int> reactionTimes = [];
  int score = 0;
  int correctReactions = 0;

  GameState gameState = GameState.waiting;
  DateTime? stimulusStartTime;
  Timer? delayTimer;
  Color targetColor = Colors.green;

  final random = Random();

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    totalRounds = 15 + widget.level; // More rounds at higher levels
    _startRound();
  }

  @override
  void dispose() {
    delayTimer?.cancel();
    super.dispose();
  }

  void _startRound() {
    setState(() {
      gameState = GameState.waiting;
      targetColor = _getRandomColor();
    });

    // Random delay between 1-4 seconds
    final delayMs = 1000 + random.nextInt(3000);

    delayTimer = Timer(Duration(milliseconds: delayMs), () {
      if (mounted) {
        setState(() {
          gameState = GameState.ready;
          stimulusStartTime = DateTime.now();
        });

        // Auto-fail if no response in 3 seconds
        Timer(const Duration(seconds: 3), () {
          if (mounted && gameState == GameState.ready) {
            _handleTooSlow();
          }
        });
      }
    });
  }

  void _handleTap() {
    if (gameState == GameState.waiting) {
      // Too early!
      setState(() {
        gameState = GameState.tooEarly;
      });
      
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _nextRound();
        }
      });
    } else if (gameState == GameState.ready) {
      // Correct!
      final reactionTime = DateTime.now().difference(stimulusStartTime!).inMilliseconds;
      reactionTimes.add(reactionTime);
      correctReactions++;

      // Score based on reaction speed
      final speedBonus = max(0, 1000 - reactionTime);
      final roundScore = 50 + (speedBonus ~/ 10);
      score += roundScore;

      setState(() {
        gameState = GameState.correct;
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _nextRound();
        }
      });
    }
  }

  void _handleTooSlow() {
    setState(() {
      gameState = GameState.tooSlow;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _nextRound();
      }
    });
  }

  void _nextRound() {
    setState(() {
      currentRound++;
    });

    if (currentRound >= totalRounds) {
      _gameCompleted();
    } else {
      _startRound();
    }
  }

  Color _getRandomColor() {
    final colors = [
      Colors.green,
      Colors.blue,
      Colors.red,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
    ];
    return colors[random.nextInt(colors.length)];
  }

  Future<void> _gameCompleted() async {
    final endTime = DateTime.now();
    final accuracy = (correctReactions / totalRounds * 100).clamp(0, 100);
    final avgReactionTime = reactionTimes.isNotEmpty
        ? reactionTimes.reduce((a, b) => a + b) / reactionTimes.length
        : 0.0;

    // Save session history
    final session = SessionHistory(
      userId: widget.userId,
      gameId: 'reaction_time',
      gameName: 'Tempo di Reazione',
      startTime: startTime,
      endTime: endTime,
      score: score,
      maxScore: totalRounds * 150, // Max possible score
      accuracy: accuracy.toDouble(),
      level: widget.level,
      domain: 'speed',
      reactionsCorrect: correctReactions,
      reactionsIncorrect: totalRounds - correctReactions,
      averageReactionTime: avgReactionTime,
      difficulty: _getDifficulty(),
      detailedMetrics: {
        'totalRounds': totalRounds,
        'averageReactionTime': avgReactionTime,
        'fastestReaction': reactionTimes.isNotEmpty ? reactionTimes.reduce(min) : 0,
        'slowestReaction': reactionTimes.isNotEmpty ? reactionTimes.reduce(max) : 0,
      },
    );

    await LocalStorageService.saveSessionHistory(session);

    if (!mounted) return;

    // Show completion dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('⚡ Test Completato!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Livello ${widget.level} completato!'),
            const SizedBox(height: 16),
            Text('Punteggio: $score'),
            Text('Reazioni corrette: $correctReactions/$totalRounds'),
            Text('Precisione: ${accuracy.toStringAsFixed(1)}%'),
            if (reactionTimes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Tempo medio: ${avgReactionTime.toStringAsFixed(0)}ms'),
              Text('Più veloce: ${reactionTimes.reduce(min)}ms'),
              Text('Più lento: ${reactionTimes.reduce(max)}ms'),
            ],
            const SizedBox(height: 8),
            _getPerformanceFeedback(avgReactionTime),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Esci'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                currentRound = 0;
                correctReactions = 0;
                score = 0;
                reactionTimes = [];
                startTime = DateTime.now();
                _startRound();
              });
            },
            child: const Text('Rigioca'),
          ),
        ],
      ),
    );
  }

  Widget _getPerformanceFeedback(double avgTime) {
    String feedback;
    Color color;

    if (avgTime < 250) {
      feedback = '🚀 Velocità incredibile! Riflessi da campione!';
      color = Colors.green;
    } else if (avgTime < 350) {
      feedback = '⚡ Ottimi riflessi! Ben fatto!';
      color = Colors.blue;
    } else if (avgTime < 500) {
      feedback = '👍 Buona velocità! Continua così!';
      color = Colors.orange;
    } else {
      feedback = '💪 Continua ad allenarti per migliorare!';
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        feedback,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _getDifficulty() {
    if (widget.level <= 2) return 'easy';
    if (widget.level <= 5) return 'medium';
    if (widget.level <= 8) return 'hard';
    return 'expert';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tempo di Reazione'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                'Livello ${widget.level}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress
            LinearProgressIndicator(
              value: currentRound / totalRounds,
              minHeight: 8,
            ),

            // Stats
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatChip('Round', '${currentRound + 1}/$totalRounds'),
                  _buildStatChip('Corrette', '$correctReactions'),
                  _buildStatChip('Punteggio', score.toString()),
                ],
              ),
            ),

            // Instructions
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                _getInstructionText(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Game Area
            Expanded(
              child: GestureDetector(
                onTap: _handleTap,
                child: Container(
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _getBackgroundColor(),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getStateIcon(),
                          size: 120,
                          color: _getIconColor(),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _getStateText(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _getIconColor(),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _getInstructionText() {
    switch (gameState) {
      case GameState.waiting:
        return 'Aspetta che lo schermo diventi verde...';
      case GameState.ready:
        return 'TOCCA ORA!';
      case GameState.correct:
        return 'Ottimo!';
      case GameState.tooEarly:
        return 'Troppo presto!';
      case GameState.tooSlow:
        return 'Troppo lento!';
    }
  }

  Color _getBackgroundColor() {
    switch (gameState) {
      case GameState.waiting:
        return Colors.red.withValues(alpha: 0.2);
      case GameState.ready:
        return targetColor.withValues(alpha: 0.3);
      case GameState.correct:
        return Colors.green.withValues(alpha: 0.3);
      case GameState.tooEarly:
        return Colors.orange.withValues(alpha: 0.3);
      case GameState.tooSlow:
        return Colors.red.withValues(alpha: 0.3);
    }
  }

  IconData _getStateIcon() {
    switch (gameState) {
      case GameState.waiting:
        return Icons.hourglass_empty;
      case GameState.ready:
        return Icons.touch_app;
      case GameState.correct:
        return Icons.check_circle;
      case GameState.tooEarly:
        return Icons.warning;
      case GameState.tooSlow:
        return Icons.timer_off;
    }
  }

  Color _getIconColor() {
    switch (gameState) {
      case GameState.waiting:
        return Colors.red;
      case GameState.ready:
        return targetColor;
      case GameState.correct:
        return Colors.green;
      case GameState.tooEarly:
        return Colors.orange;
      case GameState.tooSlow:
        return Colors.red;
    }
  }

  String _getStateText() {
    switch (gameState) {
      case GameState.waiting:
        return 'Attendi...';
      case GameState.ready:
        return 'TOCCA!';
      case GameState.correct:
        if (reactionTimes.isNotEmpty) {
          return '${reactionTimes.last}ms';
        }
        return 'Corretto!';
      case GameState.tooEarly:
        return 'Hai toccato troppo presto!';
      case GameState.tooSlow:
        return 'Tempo scaduto!';
    }
  }

  Widget _buildStatChip(String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

enum GameState {
  waiting,
  ready,
  correct,
  tooEarly,
  tooSlow,
}
