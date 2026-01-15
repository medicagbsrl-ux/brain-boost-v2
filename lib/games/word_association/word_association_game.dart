import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/session_history.dart';
import '../../services/local_storage_service.dart';

class WordAssociationGame extends StatefulWidget {
  final String userId;
  final int level;

  const WordAssociationGame({
    super.key,
    required this.userId,
    this.level = 1,
  });

  @override
  State<WordAssociationGame> createState() => _WordAssociationGameState();
}

class _WordAssociationGameState extends State<WordAssociationGame> {
  late DateTime startTime;
  int currentRound = 0;
  late int totalRounds;
  int correctAnswers = 0;
  int score = 0;
  List<int> reactionTimes = [];
  DateTime? roundStartTime;

  late String targetWord;
  late List<String> options;
  late int correctIndex;

  final random = Random();

  // Italian word associations organized by categories
  final Map<String, List<String>> wordCategories = {
    'Animali': ['Cane', 'Gatto', 'Cavallo', 'Mucca', 'Pecora', 'Coniglio', 'Uccello', 'Pesce'],
    'Frutti': ['Mela', 'Pera', 'Banana', 'Arancia', 'Uva', 'Fragola', 'Pesca', 'Limone'],
    'Colori': ['Rosso', 'Blu', 'Verde', 'Giallo', 'Nero', 'Bianco', 'Arancione', 'Viola'],
    'Corpo': ['Mano', 'Piede', 'Testa', 'Occhio', 'Orecchio', 'Bocca', 'Naso', 'Braccio'],
    'Casa': ['Porta', 'Finestra', 'Tavolo', 'Sedia', 'Letto', 'Cucina', 'Bagno', 'Divano'],
    'Natura': ['Albero', 'Fiore', 'Erba', 'Sole', 'Luna', 'Stella', 'Mare', 'Monte'],
    'Cibo': ['Pane', 'Pasta', 'Riso', 'Carne', 'Pesce', 'Formaggio', 'Latte', 'Acqua'],
    'Vestiti': ['Camicia', 'Pantaloni', 'Scarpe', 'Cappello', 'Giacca', 'Gonna', 'Vestito', 'Calze'],
  };

  // Synonyms and associations
  final Map<String, List<String>> wordAssociations = {
    'Cane': ['Gatto', 'Animale', 'Abbaiare', 'Cuccia'],
    'Mela': ['Frutta', 'Pera', 'Rosso', 'Mangiare'],
    'Sole': ['Luna', 'Caldo', 'Giallo', 'Giorno'],
    'Mare': ['Acqua', 'Blu', 'Spiaggia', 'Estate'],
    'Casa': ['Porta', 'Tetto', 'Abitare', 'Famiglia'],
    'Libro': ['Leggere', 'Pagina', 'Storia', 'Parola'],
    'Auto': ['Strada', 'Guidare', 'Ruota', 'Veloce'],
    'Albero': ['Foglia', 'Verde', 'Bosco', 'Radice'],
  };

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    totalRounds = 12 + widget.level;
    _generateNewQuestion();
  }

  void _generateNewQuestion() {
    roundStartTime = DateTime.now();

    // Select random category
    final categories = wordCategories.keys.toList();
    final category = categories[random.nextInt(categories.length)];
    final words = wordCategories[category]!;

    // Select target word
    targetWord = words[random.nextInt(words.length)];

    // Generate options: 1 correct (from same category) + 3 distractors
    options = [];
    
    // Add correct answer (another word from same category)
    final sameCategory = words.where((w) => w != targetWord).toList();
    final correctWord = sameCategory[random.nextInt(sameCategory.length)];
    options.add(correctWord);

    // Add 3 distractors from other categories
    while (options.length < 4) {
      final otherCategory = categories.where((c) => c != category).toList()[random.nextInt(categories.length - 1)];
      final distractor = wordCategories[otherCategory]![random.nextInt(wordCategories[otherCategory]!.length)];
      if (!options.contains(distractor)) {
        options.add(distractor);
      }
    }

    options.shuffle();
    correctIndex = options.indexOf(correctWord);
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
          _generateNewQuestion();
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
      gameId: 'word_association',
      gameName: 'Word Association',
      startTime: startTime,
      endTime: endTime,
      score: score,
      maxScore: totalRounds * 150,
      accuracy: accuracy.toDouble(),
      level: widget.level,
      domain: 'language',
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
        title: const Text('💬 Test Completato!'),
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
                _generateNewQuestion();
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
      feedback = '🌟 Eccezionale! Memoria semantica straordinaria!';
      color = Colors.green;
    } else if (accuracy >= 75) {
      feedback = '👍 Ottimo! Associazioni verbali molto buone!';
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
        title: const Text('Associazione Parole'),
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
                'Quale parola è associata a:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Target word
            Container(
              padding: const EdgeInsets.all(32),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 3,
                ),
              ),
              child: Center(
                child: Text(
                  targetWord,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Options
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Limita la larghezza massima su desktop
                  final maxWidth = constraints.maxWidth > 500 ? 500.0 : constraints.maxWidth;
                  
                  return Center(
                    child: SizedBox(
                      width: maxWidth,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(24),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.5,
                        ),
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          return ElevatedButton(
                            onPressed: () => _handleAnswer(index),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.surface,
                              foregroundColor: Theme.of(context).colorScheme.onSurface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: Text(
                              options[index],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
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
