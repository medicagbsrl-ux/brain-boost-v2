import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '../../models/session_history.dart';
import '../../services/local_storage_service.dart';


class StroopTestGame extends StatefulWidget {
  final String userId;
  final int level;

  const StroopTestGame({
    super.key,
    required this.userId,
    this.level = 1,
  });

  @override
  State<StroopTestGame> createState() => _StroopTestGameState();
}

class _StroopTestGameState extends State<StroopTestGame> {
  late DateTime startTime;
  int currentRound = 0;
  int totalRounds = 20;
  int correctAnswers = 0;
  int score = 0;
  List<int> reactionTimes = [];
  DateTime? roundStartTime;

  late String currentWord;
  late Color currentTextColor;
  late String correctAnswer;

  final Map<String, Color> colorMap = {
    'ROSSO': Colors.red,
    'BLU': Colors.blue,
    'VERDE': Colors.green,
    'GIALLO': Colors.yellow,
    'VIOLA': Colors.purple,
    'ARANCIONE': Colors.orange,
  };

  final List<String> colorNames = [
    'ROSSO',
    'BLU',
    'VERDE',
    'GIALLO',
    'VIOLA',
    'ARANCIONE',
  ];

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    totalRounds = 10 + (widget.level * 2); // More rounds at higher levels
    _generateNewStimulus();
  }

  void _generateNewStimulus() {
    roundStartTime = DateTime.now();
    final random = Random();
    
    // Select random word
    currentWord = colorNames[random.nextInt(colorNames.length)];
    
    // Decide if congruent or incongruent (50/50 chance)
    final isCongruent = random.nextBool();
    
    if (isCongruent) {
      // Word and color match
      currentTextColor = colorMap[currentWord]!;
      correctAnswer = currentWord;
    } else {
      // Word and color don't match (Stroop interference)
      String differentColor;
      do {
        differentColor = colorNames[random.nextInt(colorNames.length)];
      } while (differentColor == currentWord);
      
      currentTextColor = colorMap[differentColor]!;
      correctAnswer = differentColor; // Answer is the color, not the word
    }
  }

  void _handleAnswer(String answer) {
    if (roundStartTime == null) return;

    final reactionTime = DateTime.now().difference(roundStartTime!).inMilliseconds;
    reactionTimes.add(reactionTime);

    if (answer == correctAnswer) {
      setState(() {
        correctAnswers++;
        // Faster reactions get more points
        final timeBonus = max(0, 2000 - reactionTime) ~/ 10;
        score += 100 + timeBonus;
      });
    }

    setState(() {
      currentRound++;
    });

    if (currentRound >= totalRounds) {
      _gameCompleted();
    } else {
      // Small delay before next stimulus
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _generateNewStimulus();
          });
        }
      });
    }
  }

  Future<void> _gameCompleted() async {
    final endTime = DateTime.now();
    final accuracy = (correctAnswers / totalRounds * 100).clamp(0, 100);
    final avgReactionTime = reactionTimes.isNotEmpty
        ? reactionTimes.reduce((a, b) => a + b) / reactionTimes.length
        : 0.0;

    // Save session history
    final session = SessionHistory(
      userId: widget.userId,
      gameId: 'stroop_test',
      gameName: 'Test di Stroop',
      startTime: startTime,
      endTime: endTime,
      score: score,
      maxScore: totalRounds * 100,
      accuracy: accuracy.toDouble(),
      level: widget.level,
      domain: 'attention',
      reactionsCorrect: correctAnswers,
      reactionsIncorrect: totalRounds - correctAnswers,
      averageReactionTime: avgReactionTime.toDouble(),
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
        title: const Text('🎯 Test Completato!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Livello ${widget.level} completato!'),
            const SizedBox(height: 16),
            Text('Punteggio: $score'),
            Text('Risposte corrette: $correctAnswers/$totalRounds'),
            Text('Precisione: ${accuracy.toStringAsFixed(1)}%'),
            Text('Tempo medio: ${avgReactionTime.toStringAsFixed(0)}ms'),
            const SizedBox(height: 8),
            _getPerformanceFeedback(accuracy.toDouble(), avgReactionTime.toDouble()),
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
                correctAnswers = 0;
                score = 0;
                reactionTimes = [];
                startTime = DateTime.now();
                _generateNewStimulus();
              });
            },
            child: const Text('Rigioca'),
          ),
        ],
      ),
    );
  }

  Widget _getPerformanceFeedback(double accuracy, double avgTime) {
    String feedback;
    Color color;

    if (accuracy >= 90 && avgTime < 1000) {
      feedback = '🌟 Eccezionale! Attenzione e velocità straordinarie!';
      color = Colors.green;
    } else if (accuracy >= 80 && avgTime < 1500) {
      feedback = '👍 Ottimo lavoro! Attenzione molto buona!';
      color = Colors.blue;
    } else if (accuracy >= 70) {
      feedback = '💪 Buon lavoro! Continua ad allenarti!';
      color = Colors.orange;
    } else {
      feedback = '📚 Continua a praticare per migliorare!';
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
    if (currentRound >= totalRounds) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test di Stroop'),
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
                  _buildStatChip('Corrette', '$correctAnswers'),
                  _buildStatChip('Punteggio', score.toString()),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Instructions
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Seleziona il COLORE del testo, non la parola!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 48),

            // Stimulus
            Expanded(
              child: Center(
                child: Text(
                  currentWord,
                  style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: currentTextColor,
                  ),
                ),
              ),
            ),

            // Answer Buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: colorNames.map((colorName) {
                  return SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: () => _handleAnswer(colorName),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorMap[colorName],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        colorName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
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
