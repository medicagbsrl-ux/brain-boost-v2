import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/session_history.dart';
import '../../services/local_storage_service.dart';
import '../../providers/user_profile_provider.dart';
import '../../widgets/celebration_animation.dart';

class MemoryMatchGame extends StatefulWidget {
  final String userId;
  final int level;

  const MemoryMatchGame({
    super.key,
    required this.userId,
    this.level = 1,
  });

  @override
  State<MemoryMatchGame> createState() => _MemoryMatchGameState();
}

class _MemoryMatchGameState extends State<MemoryMatchGame> {
  late int gridSize;
  late List<MemoryCard> cards;
  List<int> selectedIndices = [];
  int matches = 0;
  int attempts = 0;
  bool canPlay = true;
  late DateTime startTime;
  int score = 0;
  
  // Round system
  int currentRound = 0;
  int totalRounds = 3; // 3 round per sessione
  
  // ✅ Contatori globali per statistiche finali
  int totalMatches = 0;
  int totalAttempts = 0;

  // Card symbols
  final List<IconData> symbols = [
    Icons.favorite,
    Icons.star,
    Icons.lightbulb,
    Icons.wb_sunny,
    Icons.pets,
    Icons.local_florist,
    Icons.cake,
    Icons.music_note,
    Icons.sports_soccer,
    Icons.directions_car,
    Icons.airplanemode_active,
    Icons.home,
    Icons.restaurant,
    Icons.shopping_cart,
    Icons.phone,
    Icons.camera_alt,
  ];

  final List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.amber,
  ];

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    _initializeGame();
  }

  void _initializeGame() {
    // Grid size based on level (2x2, 3x2, 4x2, 4x3, 4x4, 5x4, 6x4)
    if (widget.level <= 2) {
      gridSize = 4; // 2x2 (2 coppie)
    } else if (widget.level <= 4) {
      gridSize = 6; // 3x2 (3 coppie)
    } else if (widget.level <= 6) {
      gridSize = 8; // 4x2 (4 coppie) - FIXATO: era 9 (dispari!)
    } else if (widget.level <= 8) {
      gridSize = 12; // 4x3 (6 coppie)
    } else {
      gridSize = 16; // 4x4 (8 coppie)
    }

    final pairCount = gridSize ~/ 2;
    final selectedSymbols = (symbols..shuffle()).take(pairCount).toList();
    
    // Create pairs
    final List<MemoryCard> tempCards = [];
    for (int i = 0; i < pairCount; i++) {
      final color = colors[i % colors.length];
      tempCards.add(MemoryCard(
        id: i,
        symbol: selectedSymbols[i],
        color: color,
      ));
      tempCards.add(MemoryCard(
        id: i,
        symbol: selectedSymbols[i],
        color: color,
      ));
    }

    // Shuffle cards
    tempCards.shuffle();
    cards = tempCards;
    selectedIndices = [];
    matches = 0;
    attempts = 0;
    canPlay = true;
  }

  void _onCardTap(int index) {
    if (!canPlay || cards[index].isMatched || selectedIndices.contains(index)) {
      return;
    }

    setState(() {
      cards[index].isFaceUp = true;
      selectedIndices.add(index);
    });

    if (selectedIndices.length == 2) {
      attempts++;
      canPlay = false;

      final firstCard = cards[selectedIndices[0]];
      final secondCard = cards[selectedIndices[1]];

      if (firstCard.id == secondCard.id) {
        // Match found
        final roundComplete = (matches + 1) == gridSize ~/ 2;
        
        setState(() {
          cards[selectedIndices[0]].isMatched = true;
          cards[selectedIndices[1]].isMatched = true;
          matches++;
          totalMatches++; // ✅ Incrementa contatore globale
          score += 100;
          selectedIndices = [];
          // ⚠️ NON riabilitare input se il round è completo!
          canPlay = !roundComplete;
        });

        // Check if round is complete
        if (roundComplete) {
          // ✅ Controlla PRIMA di incrementare currentRound
          if (currentRound + 1 >= totalRounds) {
            // Game completed after all rounds
            currentRound++; // Incrementa per mostrare correttamente 3/3
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                _gameCompleted();
              }
            });
          } else {
            // Next round (con delay di 500ms per mostrare l'ultima coppia)
            currentRound++;
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                _nextRound();
              }
            });
          }
        }
      } else {
        // No match
        Timer(const Duration(milliseconds: 800), () {
          setState(() {
            cards[selectedIndices[0]].isFaceUp = false;
            cards[selectedIndices[1]].isFaceUp = false;
            selectedIndices = [];
            canPlay = true;
          });
        });
      }
    }
  }
  
  void _nextRound() {
    // Salva attempts prima di resettare
    totalAttempts += attempts;
    
    // Mostra SnackBar immediatamente
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎯 Round ${currentRound + 1}/$totalRounds'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.green,
      ),
    );
    
    // Short celebration before next round
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          matches = 0;
          attempts = 0;
          _initializeGame();
          canPlay = true; // ✅ Riabilita input dopo inizializzazione
        });
      }
    });
  }

  Future<void> _gameCompleted() async {
    // ✅ Salva attempts finali prima di calcolare
    totalAttempts += attempts;
    
    final endTime = DateTime.now();
    // ✅ Usa contatori globali per accuracy corretta
    final accuracy = totalAttempts > 0 
        ? (totalMatches / totalAttempts * 100).clamp(0, 100).toDouble()
        : 100.0; // Se nessun tentativo (impossibile), 100%

    // Save session history
    final session = SessionHistory(
      userId: widget.userId,
      gameId: 'memory_match',
      gameName: 'Memory Match - Trova le Coppie',
      startTime: startTime,
      endTime: endTime,
      score: score,
      maxScore: totalMatches * 100, // ✅ Usa total matches
      accuracy: accuracy,
      level: widget.level,
      domain: 'memory',
      reactionsCorrect: totalMatches,
      reactionsIncorrect: totalAttempts - totalMatches,
      difficulty: _getDifficulty(),
      detailedMetrics: {
        'gridSize': gridSize,
        'totalAttempts': totalAttempts,
        'totalMatches': totalMatches,
        'rounds': totalRounds,
      },
    );

    await LocalStorageService.saveSessionHistory(session);

    if (!mounted) return;

    // Show celebration animation first
    await showCelebrationAnimation(
      context,
      message: '🎉 Complimenti!',
      score: score,
    );

    if (!mounted) return;

    // Show completion dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Complimenti!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Livello ${widget.level} completato!'),
            const SizedBox(height: 16),
            Text('Punteggio: $score'),
            Text('Tentativi: $totalAttempts'),
            Text('Precisione: ${accuracy.toStringAsFixed(1)}%'),
            Text('Tempo: ${endTime.difference(startTime).inSeconds}s'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              
              // Aggiorna statistiche
              final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
              await profileProvider.refreshStatistics();
            },
            child: const Text('Esci'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                currentRound = 0;
                matches = 0;
                attempts = 0;
                totalMatches = 0; // ✅ Reset contatori globali
                totalAttempts = 0;
                _initializeGame();
                startTime = DateTime.now();
                score = 0;
              });
            },
            child: const Text('Rigioca'),
          ),
        ],
      ),
    );
  }

  String _getDifficulty() {
    if (widget.level <= 2) return 'easy';
    if (widget.level <= 5) return 'medium';
    if (widget.level <= 8) return 'hard';
    return 'expert';
  }

  int get crossAxisCount {
    if (gridSize == 4) return 2;  // 2x2
    if (gridSize == 6) return 3;  // 3x2
    if (gridSize == 8) return 4;  // 4x2
    if (gridSize == 12) return 4; // 4x3
    return 4; // Default 4x4
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Match - Trova le Coppie'),
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
            // Stats
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatChip('Round', '${currentRound + 1}/$totalRounds', Icons.repeat),
                  _buildStatChip('Punteggio', score.toString(), Icons.star),
                  _buildStatChip('Trovate', '$matches/${gridSize ~/ 2}', Icons.check_circle),
                ],
              ),
            ),

            // Game Grid
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Limita la larghezza massima su desktop
                  final maxWidth = constraints.maxWidth > 600 ? 600.0 : constraints.maxWidth;
                  
                  return Center(
                    child: SizedBox(
                      width: maxWidth,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1.0, // Carte quadrate
                          ),
                          itemCount: cards.length,
                          itemBuilder: (context, index) {
                            return _buildCard(index);
                          },
                        ),
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

  Widget _buildStatChip(String label, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(int index) {
    final card = cards[index];
    final isSelected = selectedIndices.contains(index);

    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: card.isFaceUp || card.isMatched
              ? card.color.withValues(alpha: 0.8)
              : Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.secondary
                : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: card.isFaceUp || card.isMatched
            ? Center(
                child: Icon(
                  card.symbol,
                  size: 40, // Dimensione ottimale per carte quadrate
                  color: Colors.white,
                ),
              )
            : Center(
                child: Icon(
                  Icons.help_outline, // Icona neutra "?"
                  size: 40,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
      ),
    );
  }
}

class MemoryCard {
  final int id;
  final IconData symbol;
  final Color color;
  bool isFaceUp;
  bool isMatched;

  MemoryCard({
    required this.id,
    required this.symbol,
    required this.color,
    this.isFaceUp = false,
    this.isMatched = false,
  });
}
