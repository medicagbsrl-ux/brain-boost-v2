import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/session_history.dart';
import '../../services/local_storage_service.dart';

class SpatialMemoryGame extends StatefulWidget {
  final String userId;
  final int level;

  const SpatialMemoryGame({
    super.key,
    required this.userId,
    this.level = 1,
  });

  @override
  State<SpatialMemoryGame> createState() => _SpatialMemoryGameState();
}

class _SpatialMemoryGameState extends State<SpatialMemoryGame> {
  late DateTime startTime;
  int currentRound = 0;
  late int totalRounds;
  int correctAnswers = 0;
  int score = 0;

  GamePhase gamePhase = GamePhase.showing;
  late int gridSize;
  List<int> highlightedCells = [];
  List<int> userSelected = [];
  int currentHighlightIndex = 0;
  Timer? phaseTimer;

  final random = Random();

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    totalRounds = 8 + widget.level;
    gridSize = 3 + (widget.level ~/ 3).clamp(0, 2); // 3x3 to 5x5
    _startRound();
  }

  @override
  void dispose() {
    phaseTimer?.cancel();
    super.dispose();
  }

  void _startRound() {
    final sequenceLength = 3 + (widget.level ~/ 2).clamp(0, 5); // 3-8 cells

    // Generate random cell positions
    highlightedCells = [];
    final totalCells = gridSize * gridSize;
    
    while (highlightedCells.length < sequenceLength) {
      final cell = random.nextInt(totalCells);
      if (!highlightedCells.contains(cell)) {
        highlightedCells.add(cell);
      }
    }

    userSelected = [];
    currentHighlightIndex = 0;

    setState(() {
      gamePhase = GamePhase.showing;
    });

    _showNextCell();
  }

  void _showNextCell() {
    if (currentHighlightIndex < highlightedCells.length) {
      setState(() {
        currentHighlightIndex++;
      });

      phaseTimer = Timer(const Duration(milliseconds: 1000), () {
        if (mounted) {
          _showNextCell();
        }
      });
    } else {
      // All cells shown, start recall phase
      phaseTimer = Timer(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            gamePhase = GamePhase.recall;
            currentHighlightIndex = 0;
          });
        }
      });
    }
  }

  void _handleCellTap(int cellIndex) {
    if (gamePhase != GamePhase.recall) return;
    if (userSelected.contains(cellIndex)) return;

    setState(() {
      userSelected.add(cellIndex);
    });

    // Check if selection is complete
    if (userSelected.length == highlightedCells.length) {
      _checkAnswer();
    }
  }

  void _checkAnswer() {
    // Check if all correct cells were selected (order doesn't matter)
    final isCorrect = highlightedCells.every((cell) => userSelected.contains(cell)) &&
        userSelected.every((cell) => highlightedCells.contains(cell));

    if (isCorrect) {
      setState(() {
        correctAnswers++;
        score += 100 + (highlightedCells.length * 20);
        gamePhase = GamePhase.correct;
      });
    } else {
      setState(() {
        gamePhase = GamePhase.wrong;
      });
    }

    // Move to next round
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          currentRound++;
        });

        if (currentRound >= totalRounds) {
          _gameCompleted();
        } else {
          _startRound();
        }
      }
    });
  }

  void _handleClear() {
    setState(() {
      userSelected.clear();
    });
  }

  Future<void> _gameCompleted() async {
    final endTime = DateTime.now();
    final accuracy = (correctAnswers / totalRounds * 100).clamp(0, 100);

    final session = SessionHistory(
      userId: widget.userId,
      gameId: 'spatial_memory',
      gameName: 'Memoria Spaziale',
      startTime: startTime,
      endTime: endTime,
      score: score,
      maxScore: totalRounds * (100 + highlightedCells.length * 20),
      accuracy: accuracy.toDouble(),
      level: widget.level,
      domain: 'spatial',
      reactionsCorrect: correctAnswers,
      reactionsIncorrect: totalRounds - correctAnswers,
      difficulty: _getDifficulty(),
      detailedMetrics: {
        'totalRounds': totalRounds,
        'gridSize': gridSize,
        'sequenceLength': highlightedCells.length,
      },
    );

    await LocalStorageService.saveSessionHistory(session);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('📍 Test Completato!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Livello ${widget.level} completato!'),
            const SizedBox(height: 16),
            Text('Punteggio: $score'),
            Text('Risposte corrette: $correctAnswers/$totalRounds'),
            Text('Precisione: ${accuracy.toStringAsFixed(1)}%'),
            Text('Griglia: ${gridSize}x$gridSize'),
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
      feedback = '🌟 Eccezionale! Memoria spaziale straordinaria!';
      color = Colors.green;
    } else if (accuracy >= 75) {
      feedback = '👍 Ottimo! Memoria visuo-spaziale molto buona!';
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
        title: const Text('Memoria Spaziale'),
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
                child: _buildGrid(),
              ),
            ),

            if (gamePhase == GamePhase.recall && userSelected.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: _handleClear,
                  icon: const Icon(Icons.clear),
                  label: const Text('Cancella Selezione'),
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _getInstructionText() {
    switch (gamePhase) {
      case GamePhase.showing:
        return 'Memorizza le posizioni evidenziate...';
      case GamePhase.recall:
        return 'Tocca le celle che erano evidenziate';
      case GamePhase.correct:
        return '✓ Corretto!';
      case GamePhase.wrong:
        return '✗ Sbagliato!';
    }
  }

  Widget _buildGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Limita dimensione massima su desktop
        final maxSize = constraints.maxWidth > 600 ? 600.0 : constraints.maxWidth;
        
        return Center(
          child: SizedBox(
            width: maxSize,
            height: maxSize,
            child: Container(
              margin: const EdgeInsets.all(24),
              child: GridView.builder(
                shrinkWrap: true, // ✅ FIT: grid dimensionata al contenuto
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridSize,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.0, // Celle quadrate
                ),
                itemCount: gridSize * gridSize,
                itemBuilder: (context, index) {
                  return _buildCell(index);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCell(int index) {
    final isHighlighted = gamePhase == GamePhase.showing &&
        currentHighlightIndex > 0 &&
        highlightedCells.take(currentHighlightIndex).contains(index);
    
    final isUserSelected = userSelected.contains(index);
    final shouldShowCorrect = gamePhase == GamePhase.correct && highlightedCells.contains(index);
    final shouldShowWrong = gamePhase == GamePhase.wrong;

    Color cellColor;
    if (shouldShowCorrect) {
      cellColor = Colors.green;
    } else if (shouldShowWrong && isUserSelected && !highlightedCells.contains(index)) {
      cellColor = Colors.red;
    } else if (shouldShowWrong && highlightedCells.contains(index)) {
      cellColor = Colors.green.withValues(alpha: 0.5);
    } else if (isHighlighted) {
      cellColor = Theme.of(context).colorScheme.primary;
    } else if (isUserSelected) {
      cellColor = Colors.blue;
    } else {
      cellColor = Theme.of(context).colorScheme.surface;
    }

    return GestureDetector(
      onTap: () => _handleCellTap(index),
      child: Container(
        decoration: BoxDecoration(
          color: cellColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
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

enum GamePhase {
  showing,
  recall,
  correct,
  wrong,
}
