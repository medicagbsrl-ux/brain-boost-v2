import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '../../models/session_history.dart';
import '../../services/local_storage_service.dart';


class NumberSequenceGame extends StatefulWidget {
  final String userId;
  final int level;

  const NumberSequenceGame({
    super.key,
    required this.userId,
    this.level = 1,
  });

  @override
  State<NumberSequenceGame> createState() => _NumberSequenceGameState();
}

class _NumberSequenceGameState extends State<NumberSequenceGame> {
  late DateTime startTime;
  int currentRound = 0;
  late int totalRounds;
  int correctAnswers = 0;
  int score = 0;
  
  GamePhase gamePhase = GamePhase.showing;
  List<int> currentSequence = [];
  List<int> userInput = [];
  late int sequenceLength;
  Timer? phaseTimer;
  int displayIndex = 0;

  final random = Random();

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    totalRounds = 8 + widget.level;
    sequenceLength = 3 + (widget.level ~/ 2); // 3-8 numbers
    _startRound();
  }

  @override
  void dispose() {
    phaseTimer?.cancel();
    super.dispose();
  }

  void _startRound() {
    // Generate random sequence
    currentSequence = List.generate(
      sequenceLength,
      (_) => random.nextInt(10),
    );
    userInput = [];
    displayIndex = 0;

    setState(() {
      gamePhase = GamePhase.showing;
    });

    // Show sequence one number at a time
    _showNextNumber();
  }

  void _showNextNumber() {
    if (displayIndex < currentSequence.length) {
      setState(() {
        displayIndex++;
      });

      // Show each number for 800ms, then wait 200ms before next
      phaseTimer = Timer(const Duration(milliseconds: 1000), () {
        if (mounted) {
          _showNextNumber();
        }
      });
    } else {
      // Give extra time to see the last number before input phase
      phaseTimer = Timer(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            gamePhase = GamePhase.input;
          });
        }
      });
    }
  }

  void _handleNumberInput(int number) {
    if (gamePhase != GamePhase.input) return;

    setState(() {
      userInput.add(number);
    });

    // Check if sequence is complete
    if (userInput.length == currentSequence.length) {
      _checkAnswer();
    }
  }

  void _checkAnswer() {
    final isCorrect = _sequencesMatch();

    if (isCorrect) {
      setState(() {
        correctAnswers++;
        score += 100 + (sequenceLength * 10);
        gamePhase = GamePhase.correct;
      });
    } else {
      setState(() {
        gamePhase = GamePhase.wrong;
      });
    }

    // Move to next round
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          currentRound++;
        });

        if (currentRound >= totalRounds) {
          _gameCompleted();
        } else {
          // Increase difficulty every 3 rounds
          if (currentRound % 3 == 0 && sequenceLength < 9) {
            sequenceLength++;
          }
          _startRound();
        }
      }
    });
  }

  bool _sequencesMatch() {
    if (currentSequence.length != userInput.length) return false;
    for (int i = 0; i < currentSequence.length; i++) {
      if (currentSequence[i] != userInput[i]) return false;
    }
    return true;
  }

  void _handleClear() {
    setState(() {
      userInput.clear();
    });
  }

  Future<void> _gameCompleted() async {
    final endTime = DateTime.now();
    final accuracy = (correctAnswers / totalRounds * 100).clamp(0, 100);

    final session = SessionHistory(
      userId: widget.userId,
      gameId: 'number_sequence',
      gameName: 'Number Sequence',
      startTime: startTime,
      endTime: endTime,
      score: score,
      maxScore: totalRounds * (100 + sequenceLength * 10),
      accuracy: accuracy.toDouble(),
      level: widget.level,
      domain: 'memory',
      reactionsCorrect: correctAnswers,
      reactionsIncorrect: totalRounds - correctAnswers,
      difficulty: _getDifficulty(),
      detailedMetrics: {
        'totalRounds': totalRounds,
        'sequenceLength': sequenceLength,
        'correctAnswers': correctAnswers,
      },
    );

    await LocalStorageService.saveSessionHistory(session);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🧠 Test Completato!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Livello ${widget.level} completato!'),
            const SizedBox(height: 16),
            Text('Punteggio: $score'),
            Text('Risposte corrette: $correctAnswers/$totalRounds'),
            Text('Precisione: ${accuracy.toStringAsFixed(1)}%'),
            Text('Lunghezza sequenze: fino a $sequenceLength numeri'),
            const SizedBox(height: 8),
            _getPerformanceFeedback(accuracy.toDouble()),
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
                sequenceLength = 3 + (widget.level ~/ 2);
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

  Widget _getPerformanceFeedback(double accuracy) {
    String feedback;
    Color color;

    if (accuracy >= 90) {
      feedback = '🌟 Eccezionale! Memoria di lavoro straordinaria!';
      color = Colors.green;
    } else if (accuracy >= 75) {
      feedback = '👍 Ottimo! Memoria molto buona!';
      color = Colors.blue;
    } else if (accuracy >= 60) {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Number Sequence'),
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
            LinearProgressIndicator(
              value: currentRound / totalRounds,
              minHeight: 8,
            ),
            
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

            Expanded(
              child: Center(
                child: _buildGameArea(),
              ),
            ),

            if (gamePhase == GamePhase.input) _buildNumberPad(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _getInstructionText() {
    switch (gamePhase) {
      case GamePhase.showing:
        return 'Memorizza la sequenza...';
      case GamePhase.input:
        return 'Inserisci i numeri nell\'ordine corretto';
      case GamePhase.correct:
        return '✓ Corretto!';
      case GamePhase.wrong:
        return '✗ Sbagliato!';
    }
  }

  Widget _buildGameArea() {
    if (gamePhase == GamePhase.showing) {
      return Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 3,
          ),
        ),
        child: Center(
          child: displayIndex > 0 && displayIndex <= currentSequence.length
              ? Text(
                  currentSequence[displayIndex - 1].toString(),
                  style: TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
              : const SizedBox(),
        ),
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Wrap(
            spacing: 8,
            children: userInput.map((number) {
              return Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getPhaseColor(),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    number.toString(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (gamePhase == GamePhase.input && userInput.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: TextButton.icon(
                onPressed: _handleClear,
                icon: const Icon(Icons.clear),
                label: const Text('Cancella'),
              ),
            ),
        ],
      );
    }
  }

  Color _getPhaseColor() {
    switch (gamePhase) {
      case GamePhase.showing:
        return Theme.of(context).colorScheme.primary;
      case GamePhase.input:
        return Colors.blue;
      case GamePhase.correct:
        return Colors.green;
      case GamePhase.wrong:
        return Colors.red;
    }
  }

  Widget _buildNumberPad() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int row = 0; row < 4; row++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (int col = 0; col < 3; col++)
                    if (row == 3 && col == 1)
                      _buildNumberButton(0)
                    else if (row < 3)
                      _buildNumberButton(row * 3 + col + 1)
                    else
                      const SizedBox(width: 80, height: 60),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNumberButton(int number) {
    return SizedBox(
      width: 80,
      height: 60,
      child: ElevatedButton(
        onPressed: () => _handleNumberInput(number),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: Text(number.toString()),
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

enum GamePhase {
  showing,
  input,
  correct,
  wrong,
}
