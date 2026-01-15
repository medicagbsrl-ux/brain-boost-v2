import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/session_history.dart';
import '../../services/local_storage_service.dart';

class PatternRecognitionGame extends StatefulWidget {
  final String userId;
  final int level;

  const PatternRecognitionGame({
    super.key,
    required this.userId,
    this.level = 1,
  });

  @override
  State<PatternRecognitionGame> createState() => _PatternRecognitionGameState();
}

class _PatternRecognitionGameState extends State<PatternRecognitionGame> {
  late DateTime startTime;
  int currentRound = 0;
  late int totalRounds;
  int correctAnswers = 0;
  int score = 0;
  List<int> reactionTimes = [];
  DateTime? roundStartTime;

  late List<PatternItem> pattern;
  late PatternItem missingItem;
  late List<PatternItem> options;
  late int correctIndex;

  final random = Random();

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    totalRounds = 10 + widget.level;
    _generateNewPattern();
  }

  void _generateNewPattern() {
    roundStartTime = DateTime.now();
    
    // Pattern types: color, shape, size sequences
    final patternType = random.nextInt(3);
    final patternLength = 4 + (widget.level ~/ 2).clamp(0, 4); // 4-8 items

    switch (patternType) {
      case 0:
        _generateColorPattern(patternLength);
        break;
      case 1:
        _generateShapePattern(patternLength);
        break;
      case 2:
        _generateSizePattern(patternLength);
        break;
    }

    // Generate options (correct + 3 distractors)
    options = [missingItem];
    while (options.length < 4) {
      final distractor = _generateDistractor();
      if (!_itemsEqual(distractor, missingItem)) {
        options.add(distractor);
      }
    }
    options.shuffle();
    correctIndex = options.indexWhere((item) => _itemsEqual(item, missingItem));
  }

  void _generateColorPattern(int length) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
    ];

    pattern = [];
    final colorSequence = <Color>[];
    
    // Create repeating color pattern
    final baseColors = colors.take(2 + random.nextInt(2)).toList();
    for (int i = 0; i < length; i++) {
      colorSequence.add(baseColors[i % baseColors.length]);
    }

    // Add one more for the missing item
    missingItem = PatternItem(
      color: baseColors[length % baseColors.length],
      shape: PatternShape.circle,
      size: 50,
    );

    // Create pattern items (all circles, varying color)
    for (var color in colorSequence) {
      pattern.add(PatternItem(
        color: color,
        shape: PatternShape.circle,
        size: 50,
      ));
    }
  }

  void _generateShapePattern(int length) {
    final shapes = PatternShape.values;
    pattern = [];
    
    final shapeSequence = <PatternShape>[];
    final baseShapes = shapes.take(2 + random.nextInt(2)).toList();
    
    for (int i = 0; i < length; i++) {
      shapeSequence.add(baseShapes[i % baseShapes.length]);
    }

    missingItem = PatternItem(
      color: Colors.blue,
      shape: baseShapes[length % baseShapes.length],
      size: 50,
    );

    for (var shape in shapeSequence) {
      pattern.add(PatternItem(
        color: Colors.blue,
        shape: shape,
        size: 50,
      ));
    }
  }

  void _generateSizePattern(int length) {
    pattern = [];
    final sizes = [30.0, 45.0, 60.0];
    
    final sizeSequence = <double>[];
    for (int i = 0; i < length; i++) {
      sizeSequence.add(sizes[i % sizes.length]);
    }

    missingItem = PatternItem(
      color: Colors.green,
      shape: PatternShape.circle,
      size: sizes[length % sizes.length],
    );

    for (var size in sizeSequence) {
      pattern.add(PatternItem(
        color: Colors.green,
        shape: PatternShape.circle,
        size: size,
      ));
    }
  }

  PatternItem _generateDistractor() {
    return PatternItem(
      color: [Colors.red, Colors.blue, Colors.green, Colors.yellow][random.nextInt(4)],
      shape: PatternShape.values[random.nextInt(PatternShape.values.length)],
      size: [30.0, 45.0, 60.0][random.nextInt(3)],
    );
  }

  bool _itemsEqual(PatternItem a, PatternItem b) {
    return a.color == b.color && a.shape == b.shape && a.size == b.size;
  }

  void _handleAnswer(int selectedIndex) {
    if (roundStartTime == null) return;

    final reactionTime = DateTime.now().difference(roundStartTime!).inMilliseconds;
    reactionTimes.add(reactionTime);

    if (selectedIndex == correctIndex) {
      setState(() {
        correctAnswers++;
        final timeBonus = max(0, 5000 - reactionTime) ~/ 20;
        score += 100 + timeBonus;
      });
    }

    setState(() {
      currentRound++;
    });

    if (currentRound >= totalRounds) {
      _gameCompleted();
    } else {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _generateNewPattern();
          setState(() {});
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

    final session = SessionHistory(
      userId: widget.userId,
      gameId: 'pattern_recognition',
      gameName: 'Riconoscimento Pattern',
      startTime: startTime,
      endTime: endTime,
      score: score,
      maxScore: totalRounds * 150,
      accuracy: accuracy.toDouble(),
      level: widget.level,
      domain: 'executive',
      reactionsCorrect: correctAnswers,
      reactionsIncorrect: totalRounds - correctAnswers,
      averageReactionTime: avgReactionTime.toDouble(),
      difficulty: _getDifficulty(),
      detailedMetrics: {
        'totalRounds': totalRounds,
        'averageReactionTime': avgReactionTime,
      },
    );

    await LocalStorageService.saveSessionHistory(session);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🧩 Test Completato!'),
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
                reactionTimes = [];
                startTime = DateTime.now();
                _generateNewPattern();
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
      feedback = '🌟 Eccezionale! Ragionamento logico straordinario!';
      color = Colors.green;
    } else if (accuracy >= 75) {
      feedback = '👍 Ottimo! Riconoscimento pattern molto buono!';
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
        title: const Text('Riconoscimento Pattern'),
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

            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Quale elemento completa la sequenza?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Pattern display
            Padding(
              padding: const EdgeInsets.all(24),
              child: Wrap(
                spacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  ...pattern.map((item) => _buildPatternItem(item)),
                  _buildQuestionMark(),
                ],
              ),
            ),

            const SizedBox(height: 32),
            const Text(
              'Seleziona la risposta corretta:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Options
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Limita la larghezza massima su desktop (opzioni 2 colonne)
                  final maxWidth = constraints.maxWidth > 500 ? 500.0 : constraints.maxWidth;
                  
                  return Center(
                    child: SizedBox(
                      width: maxWidth,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(24),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.0, // Quadrati perfetti
                        ),
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => _handleAnswer(index),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: _buildPatternItem(options[index]),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternItem(PatternItem item) {
    Widget shape;

    switch (item.shape) {
      case PatternShape.circle:
        shape = Container(
          width: item.size,
          height: item.size,
          decoration: BoxDecoration(
            color: item.color,
            shape: BoxShape.circle,
          ),
        );
        break;
      case PatternShape.square:
        shape = Container(
          width: item.size,
          height: item.size,
          decoration: BoxDecoration(
            color: item.color,
            borderRadius: BorderRadius.circular(4),
          ),
        );
        break;
      case PatternShape.triangle:
        shape = CustomPaint(
          size: Size(item.size, item.size),
          painter: TrianglePainter(item.color),
        );
        break;
      case PatternShape.star:
        shape = Icon(
          Icons.star,
          color: item.color,
          size: item.size,
        );
        break;
    }

    return shape;
  }

  Widget _buildQuestionMark() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.3),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey, width: 2),
      ),
      child: const Center(
        child: Text(
          '?',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
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

class PatternItem {
  final Color color;
  final PatternShape shape;
  final double size;

  PatternItem({
    required this.color,
    required this.shape,
    required this.size,
  });
}

enum PatternShape {
  circle,
  square,
  triangle,
  star,
}

class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
