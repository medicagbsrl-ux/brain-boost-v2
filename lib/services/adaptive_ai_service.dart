import 'package:flutter/foundation.dart';
import 'dart:math';
import '../models/session_history.dart';
import 'local_storage_service.dart';

/// Servizio AI per adattamento dinamico della difficoltà
/// Basato su performance dell'utente e algoritmo di apprendimento automatico
class AdaptiveAIService {
  static final AdaptiveAIService _instance = AdaptiveAIService._internal();
  factory AdaptiveAIService() => _instance;
  AdaptiveAIService._internal();

  /// Livello di difficoltà (1-10)
  int _currentDifficulty = 5;
  
  /// Zona di Sviluppo Prossimale (ZSP)
  /// Range ottimale: 60-80% successo
  static const double _optimalSuccessRateLow = 0.60;
  static const double _optimalSuccessRateHigh = 0.80;
  
  /// Parametri per l'algoritmo adattivo
  static const int _windowSize = 5; // Ultime 5 sessioni

  /// Calcola difficoltà adattiva per un gioco
  Future<int> calculateAdaptiveDifficulty({
    required String gameId,
    required String userId,
  }) async {
    // Recupera storico recente
    final recentSessions = await LocalStorageService.getGameHistory(userId, gameId, limit: _windowSize);
    
    if (recentSessions.isEmpty) {
      // Prima volta: difficoltà media
      return 5;
    }

    // Calcola metriche di performance
    final metrics = _calculatePerformanceMetrics(recentSessions);
    
    // Determina nuovo livello di difficoltà
    final newDifficulty = _adjustDifficulty(
      currentDifficulty: _currentDifficulty,
      successRate: metrics['successRate']!,
      avgReactionTime: metrics['avgReactionTime']!,
      consistencyScore: metrics['consistencyScore']!,
    );

    _currentDifficulty = newDifficulty;

    if (kDebugMode) {
      debugPrint('🎯 AI Adattivo - $gameId:');
      debugPrint('   Success Rate: ${(metrics['successRate']! * 100).toStringAsFixed(1)}%');
      debugPrint('   Difficoltà: $_currentDifficulty/10');
      debugPrint('   Trend: ${_getTrendEmoji(metrics['trend']!)}');
    }

    return _currentDifficulty;
  }

  /// Calcola metriche di performance dalle sessioni
  Map<String, double> _calculatePerformanceMetrics(List<SessionHistory> sessions) {
    if (sessions.isEmpty) {
      return {
        'successRate': 0.5,
        'avgReactionTime': 1000.0,
        'consistencyScore': 0.5,
        'trend': 0.0,
      };
    }

    // Success Rate (precisione media)
    final successRate = sessions.fold<double>(
      0.0,
      (sum, session) => sum + (session.accuracy / 100),
    ) / sessions.length;

    // Tempo di reazione medio
    final avgReactionTime = sessions.fold<double>(
      0.0,
      (sum, session) => sum + (session.reactionTime ?? 1000),
    ) / sessions.length;

    // Consistenza (deviazione standard inversa)
    final accuracies = sessions.map((s) => s.accuracy).toList();
    final consistencyScore = 1.0 - (_calculateStandardDeviation(accuracies) / 100);

    // Trend (miglioramento nel tempo)
    final trend = _calculateTrend(sessions);

    return {
      'successRate': successRate,
      'avgReactionTime': avgReactionTime,
      'consistencyScore': consistencyScore,
      'trend': trend,
    };
  }

  /// Algoritmo di aggiustamento difficoltà
  int _adjustDifficulty({
    required int currentDifficulty,
    required double successRate,
    required double avgReactionTime,
    required double consistencyScore,
  }) {
    int newDifficulty = currentDifficulty;

    // Zona di Sviluppo Prossimale (ZSP)
    if (successRate > _optimalSuccessRateHigh) {
      // Troppo facile → aumenta difficoltà
      final increment = _calculateIncrement(successRate, consistencyScore);
      newDifficulty = min(10, currentDifficulty + increment);
      
    } else if (successRate < _optimalSuccessRateLow) {
      // Troppo difficile → diminuisci difficoltà
      final decrement = _calculateDecrement(successRate, consistencyScore);
      newDifficulty = max(1, currentDifficulty - decrement);
    }
    
    // Se nella ZSP ottimale, mantieni difficoltà
    // (con piccole variazioni per evitare monotonia)
    else {
      // Variazione casuale minima ±1 (10% probabilità)
      if (Random().nextDouble() < 0.1) {
        newDifficulty = (currentDifficulty + (Random().nextBool() ? 1 : -1)).clamp(1, 10);
      }
    }

    return newDifficulty;
  }

  /// Calcola incremento difficoltà
  int _calculateIncrement(double successRate, double consistencyScore) {
    // Più alta la performance, maggiore l'incremento
    final excessSuccess = successRate - _optimalSuccessRateHigh;
    
    if (excessSuccess > 0.15 && consistencyScore > 0.8) {
      return 2; // Grande salto
    } else if (excessSuccess > 0.10) {
      return 1; // Salto medio
    } else {
      return 1; // Salto piccolo
    }
  }

  /// Calcola decremento difficoltà
  int _calculateDecrement(double successRate, double consistencyScore) {
    // Più bassa la performance, maggiore il decremento
    final deficit = _optimalSuccessRateLow - successRate;
    
    if (deficit > 0.20) {
      return 2; // Grande riduzione
    } else if (deficit > 0.10) {
      return 1; // Riduzione media
    } else {
      return 1; // Riduzione piccola
    }
  }

  /// Calcola deviazione standard
  double _calculateStandardDeviation(List<double> values) {
    if (values.isEmpty) return 0.0;
    
    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance = values.fold<double>(
      0.0,
      (sum, value) => sum + pow(value - mean, 2),
    ) / values.length;
    
    return sqrt(variance);
  }

  /// Calcola trend di miglioramento
  double _calculateTrend(List<SessionHistory> sessions) {
    if (sessions.length < 2) return 0.0;

    // Confronta prima metà con seconda metà
    final halfIndex = sessions.length ~/ 2;
    final firstHalf = sessions.sublist(0, halfIndex);
    final secondHalf = sessions.sublist(halfIndex);

    final avgFirst = firstHalf.fold<double>(0.0, (sum, s) => sum + s.score) / firstHalf.length;
    final avgSecond = secondHalf.fold<double>(0.0, (sum, s) => sum + s.score) / secondHalf.length;

    // Normalizza tra -1 e 1
    return ((avgSecond - avgFirst) / max(avgFirst, 1)).clamp(-1.0, 1.0);
  }

  String _getTrendEmoji(double trend) {
    if (trend > 0.1) return '📈 Miglioramento';
    if (trend < -0.1) return '📉 Calo';
    return '➡️ Stabile';
  }

  /// Predice performance futura
  Future<Map<String, dynamic>> predictFuturePerformance({
    required String gameId,
    required String userId,
  }) async {
    final sessions = await LocalStorageService.getGameHistory(userId, gameId, limit: 10);
    
    if (sessions.length < 3) {
      return {
        'predictedScore': 0.0,
        'confidence': 0.0,
        'recommendation': 'Completa più sessioni per ottenere previsioni accurate',
      };
    }

    // Regressione lineare semplice
    final trend = _calculateTrend(sessions);
    final lastScore = sessions.last.score;
    final predictedScore = (lastScore + (trend * 100)).clamp(0.0, 100.0);
    
    // Confidenza basata su consistenza
    final accuracies = sessions.map((s) => s.accuracy).toList();
    final consistency = 1.0 - (_calculateStandardDeviation(accuracies) / 100);
    
    String recommendation;
    if (trend > 0.2) {
      recommendation = 'Ottimo progresso! Continua così';
    } else if (trend < -0.2) {
      recommendation = 'Prendi una pausa e riprova domani';
    } else {
      recommendation = 'Performance stabile, aumentiamo la difficoltà';
    }

    return {
      'predictedScore': predictedScore,
      'confidence': consistency,
      'recommendation': recommendation,
      'trend': trend,
    };
  }

  /// Raccomandazioni personalizzate di allenamento
  Future<List<String>> getPersonalizedRecommendations({
    required String userId,
  }) async {
    final recommendations = <String>[];

    // Analizza performance per dominio cognitivo
    final memoryGames = ['memory_match', 'spatial_memory'];
    final attentionGames = ['stroop_test', 'reaction_time'];
    final executiveGames = ['number_sequence', 'pattern_recognition'];
    final languageGames = ['word_association'];

    // Memoria
    final memoryPerf = await _getDomainPerformance(userId, memoryGames);
    if (memoryPerf < 60) {
      recommendations.add('🧠 Potenzia la MEMORIA: allenati 15 min/giorno con Memory Match');
    }

    // Attenzione
    final attentionPerf = await _getDomainPerformance(userId, attentionGames);
    if (attentionPerf < 60) {
      recommendations.add('👁️ Migliora l\'ATTENZIONE: esercizi Stroop quotidiani');
    }

    // Funzioni esecutive
    final executivePerf = await _getDomainPerformance(userId, executiveGames);
    if (executivePerf < 60) {
      recommendations.add('⚙️ Rafforza le FUNZIONI ESECUTIVE: giochi di strategia');
    }

    // Linguaggio
    final languagePerf = await _getDomainPerformance(userId, languageGames);
    if (languagePerf < 60) {
      recommendations.add('💬 Sviluppa il LINGUAGGIO: giochi di parole e associazioni');
    }

    // Raccomandazioni generali
    if (recommendations.isEmpty) {
      recommendations.add('🌟 Eccellente! Mantieni l\'allenamento regolare');
    }
    
    recommendations.add('📅 Obiettivo: 20-30 min/giorno, 5 giorni/settimana');

    return recommendations;
  }

  /// Performance media per dominio cognitivo
  Future<double> _getDomainPerformance(String userId, List<String> gameIds) async {
    double totalScore = 0;
    int count = 0;

    for (final gameId in gameIds) {
      final sessions = await LocalStorageService.getGameHistory(userId, gameId, limit: 5);
      if (sessions.isNotEmpty) {
        totalScore += sessions.fold<double>(0.0, (sum, s) => sum + s.score) / sessions.length;
        count++;
      }
    }

    return count > 0 ? totalScore / count : 50.0;
  }

  /// Bilanciamento automatico dei domini
  Future<Map<String, int>> getBalancedTrainingPlan(String userId) async {
    // Analizza tutti i domini
    final domains = {
      'memory': ['memory_match', 'spatial_memory'],
      'attention': ['stroop_test', 'reaction_time'],
      'executive': ['number_sequence', 'pattern_recognition'],
      'language': ['word_association'],
    };

    final domainPerformance = <String, double>{};
    for (final entry in domains.entries) {
      domainPerformance[entry.key] = await _getDomainPerformance(userId, entry.value);
    }

    // Ordina per performance (dal più basso al più alto)
    final sorted = domainPerformance.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    // Assegna più sessioni ai domini più deboli
    final trainingPlan = <String, int>{};
    trainingPlan[sorted[0].key] = 5; // Dominio più debole: 5 sessioni
    trainingPlan[sorted[1].key] = 3; // Secondo più debole: 3 sessioni
    trainingPlan[sorted[2].key] = 2; // Terzo più debole: 2 sessioni
    trainingPlan[sorted[3].key] = 1; // Più forte: 1 sessione

    if (kDebugMode) {
      debugPrint('📊 Piano di allenamento bilanciato:');
      trainingPlan.forEach((domain, sessions) {
        debugPrint('   $domain: $sessions sessioni (score: ${domainPerformance[domain]?.toStringAsFixed(0)})');
      });
    }

    return trainingPlan;
  }

  /// Configura parametri gioco basati su difficoltà
  Map<String, dynamic> getGameParameters({
    required String gameId,
    required int difficulty,
  }) {
    switch (gameId) {
      case 'memory_match':
        return {
          'gridSize': _getMemoryGridSize(difficulty),
          'timeLimit': _getMemoryTimeLimit(difficulty),
          'pairs': _getMemoryPairs(difficulty),
        };
        
      case 'stroop_test':
        return {
          'rounds': 15 + (difficulty * 2),
          'timePerRound': max(1500 - (difficulty * 100), 800),
          'congruentRatio': max(0.7 - (difficulty * 0.05), 0.3),
        };
        
      case 'reaction_time':
        return {
          'trials': 15 + (difficulty * 2),
          'minDelay': 1000 + (difficulty * 200),
          'maxDelay': 3000 + (difficulty * 300),
        };
        
      case 'number_sequence':
        return {
          'sequenceLength': 3 + difficulty,
          'displayTime': max(2000 - (difficulty * 150), 800),
          'rounds': 10 + difficulty,
        };
        
      case 'pattern_recognition':
        return {
          'patternSize': 3 + (difficulty ~/ 2),
          'displayTime': max(3000 - (difficulty * 200), 1000),
          'rounds': 10 + difficulty,
        };
        
      case 'spatial_memory':
        return {
          'gridSize': 4 + (difficulty ~/ 3),
          'itemsToRemember': 2 + (difficulty ~/ 2),
          'displayTime': max(3000 - (difficulty * 200), 1500),
        };
        
      case 'word_association':
        return {
          'wordCount': 8 + difficulty,
          'timeLimit': max(60 - (difficulty * 3), 30),
          'categoryDifficulty': difficulty,
        };
        
      default:
        return {
          'difficulty': difficulty,
        };
    }
  }

  int _getMemoryGridSize(int difficulty) {
    if (difficulty <= 3) return 2; // 2x2
    if (difficulty <= 6) return 3; // 3x3
    return 4; // 4x4
  }

  int _getMemoryTimeLimit(int difficulty) {
    return max(120 - (difficulty * 10), 60); // 120s → 60s
  }

  int _getMemoryPairs(int difficulty) {
    final gridSize = _getMemoryGridSize(difficulty);
    return (gridSize * gridSize) ~/ 2;
  }

  /// Reset difficoltà
  void resetDifficulty() {
    _currentDifficulty = 5;
  }

  /// Ottieni livello corrente
  int getCurrentDifficulty() => _currentDifficulty;
}
