import 'dart:math';
import 'package:flutter/material.dart';
import '../models/session_history.dart';
import 'local_storage_service.dart';

class BrainBoostScoreService {
  // Brain Boost Score - Algoritmo proprietario di valutazione cognitiva
  // Range: 0-1000 (diviso in 10 livelli)
  
  static const Map<String, double> domainWeights = {
    'memory': 0.20,      // 20% - Memoria
    'attention': 0.18,   // 18% - Attenzione
    'executive': 0.18,   // 18% - Funzioni Esecutive
    'speed': 0.15,       // 15% - Velocità
    'language': 0.15,    // 15% - Linguaggio
    'spatial': 0.14,     // 14% - Abilità Spaziali
  };

  // Age normalization factors (baseline = 65 years old)
  static double getAgeNormalizationFactor(int age) {
    if (age < 50) return 0.90; // Younger - lower score ceiling
    if (age < 60) return 0.95;
    if (age < 70) return 1.00; // Baseline
    if (age < 80) return 1.05;
    return 1.10; // 80+ - higher score for same performance
  }

  // Calculate comprehensive Brain Boost Score
  static Future<BrainBoostScore> calculateScore(String userId, int userAge) async {
    final sessions = await LocalStorageService.getSessionHistory(userId);
    
    if (sessions.isEmpty) {
      return BrainBoostScore.initial();
    }

    // Calculate domain scores
    final domainScores = <String, double>{};
    final domainSessions = <String, List<SessionHistory>>{};

    for (var session in sessions) {
      if (!domainSessions.containsKey(session.domain)) {
        domainSessions[session.domain] = [];
      }
      domainSessions[session.domain]!.add(session);
    }

    // Calculate weighted scores for each domain
    double totalWeightedScore = 0.0;
    
    for (var domain in domainWeights.keys) {
      if (domainSessions.containsKey(domain)) {
        final score = _calculateDomainScore(domainSessions[domain]!);
        domainScores[domain] = score;
        totalWeightedScore += score * domainWeights[domain]!;
      } else {
        domainScores[domain] = 50.0; // Default neutral score
        totalWeightedScore += 50.0 * domainWeights[domain]!;
      }
    }

    // Apply age normalization
    final ageNormalized = totalWeightedScore * getAgeNormalizationFactor(userAge);

    // Convert to 0-1000 scale
    final brainBoostScore = (ageNormalized * 10).clamp(0, 1000).toInt();

    // Calculate additional metrics
    final consistency = _calculateConsistency(sessions);
    final improvement = _calculateImprovement(sessions);
    final engagement = _calculateEngagement(sessions);

    // Determine cognitive level
    final cognitiveLevel = _getCognitiveLevel(brainBoostScore);
    
    // Generate insights
    final insights = _generateInsights(
      brainBoostScore,
      domainScores,
      consistency,
      improvement,
      engagement,
    );

    return BrainBoostScore(
      totalScore: brainBoostScore,
      domainScores: domainScores,
      consistency: consistency,
      improvement: improvement,
      engagement: engagement,
      cognitiveLevel: cognitiveLevel,
      ageGroup: _getAgeGroup(userAge),
      percentileRank: _calculatePercentile(brainBoostScore, userAge),
      lastUpdated: DateTime.now(),
      totalSessions: sessions.length,
      insights: insights,
    );
  }

  static double _calculateDomainScore(List<SessionHistory> sessions) {
    if (sessions.isEmpty) return 50.0;

    // Weight recent sessions more heavily
    final sortedSessions = sessions..sort((a, b) => b.startTime.compareTo(a.startTime));
    final recentSessions = sortedSessions.take(10).toList();

    double totalWeightedScore = 0.0;
    double totalWeight = 0.0;

    for (int i = 0; i < recentSessions.length; i++) {
      final session = recentSessions[i];
      final weight = 1.0 / (i + 1); // More recent = higher weight
      
      // Combine accuracy, speed, and score
      final accuracyScore = session.accuracy;
      final speedScore = _calculateSpeedScore(session.averageReactionTime);
      final performanceScore = session.percentageScore;
      
      final sessionScore = (accuracyScore * 0.4 + speedScore * 0.3 + performanceScore * 0.3);
      
      totalWeightedScore += sessionScore * weight;
      totalWeight += weight;
    }

    return (totalWeightedScore / totalWeight).clamp(0, 100);
  }

  static double _calculateSpeedScore(double avgReactionTime) {
    if (avgReactionTime == 0) return 75.0; // Default for games without reaction time
    
    // Optimal reaction time: 500ms
    // Score decreases as reaction time increases
    final speedScore = 100.0 - (avgReactionTime / 50).clamp(0, 50);
    return speedScore.clamp(0, 100);
  }

  static double _calculateConsistency(List<SessionHistory> sessions) {
    if (sessions.length < 3) return 50.0;

    final recentSessions = sessions.take(10).toList();
    final scores = recentSessions.map((s) => s.accuracy).toList();
    
    // Calculate standard deviation
    final mean = scores.reduce((a, b) => a + b) / scores.length;
    final variance = scores.map((s) => pow(s - mean, 2)).reduce((a, b) => a + b) / scores.length;
    final stdDev = sqrt(variance);

    // Lower standard deviation = higher consistency
    final consistency = 100.0 - (stdDev * 2).clamp(0, 100);
    return consistency;
  }

  static double _calculateImprovement(List<SessionHistory> sessions) {
    if (sessions.length < 5) return 50.0;

    // Compare first 5 sessions with last 5 sessions
    final sortedSessions = sessions..sort((a, b) => a.startTime.compareTo(b.startTime));
    
    final firstFive = sortedSessions.take(5).toList();
    final lastFive = sortedSessions.reversed.take(5).toList();

    final firstAvg = firstFive.map((s) => s.accuracy).reduce((a, b) => a + b) / 5;
    final lastAvg = lastFive.map((s) => s.accuracy).reduce((a, b) => a + b) / 5;

    final improvement = ((lastAvg - firstAvg) / firstAvg * 100 + 50).clamp(0, 100);
    return improvement.toDouble();
  }

  static double _calculateEngagement(List<SessionHistory> sessions) {
    if (sessions.isEmpty) return 0.0;

    // Calculate sessions per week
    final oldestSession = sessions.map((s) => s.startTime).reduce((a, b) => a.isBefore(b) ? a : b);
    final weeksSinceStart = DateTime.now().difference(oldestSession).inDays / 7;
    
    if (weeksSinceStart < 1) return 50.0;

    final sessionsPerWeek = sessions.length / weeksSinceStart;
    
    // Optimal: 4-5 sessions per week
    final engagement = (sessionsPerWeek / 5 * 100).clamp(0, 100);
    return engagement.toDouble();
  }

  static String _getCognitiveLevel(int score) {
    if (score >= 900) return 'Eccezionale';
    if (score >= 800) return 'Superiore';
    if (score >= 700) return 'Avanzato';
    if (score >= 600) return 'Intermedio+';
    if (score >= 500) return 'Intermedio';
    if (score >= 400) return 'Base+';
    if (score >= 300) return 'Base';
    if (score >= 200) return 'Iniziale+';
    if (score >= 100) return 'Iniziale';
    return 'Principiante';
  }

  static String _getAgeGroup(int age) {
    if (age < 50) return '< 50 anni';
    if (age < 60) return '50-59 anni';
    if (age < 70) return '60-69 anni';
    if (age < 80) return '70-79 anni';
    return '80+ anni';
  }

  static int _calculatePercentile(int score, int age) {
    // Simplified percentile calculation based on age group
    final basePercentile = (score / 10).clamp(0, 100).toInt();
    
    // Adjust for age
    if (age >= 80 && score >= 500) return min(basePercentile + 10, 99);
    if (age >= 70 && score >= 500) return min(basePercentile + 5, 99);
    
    return basePercentile;
  }

  static List<String> _generateInsights(
    int totalScore,
    Map<String, double> domainScores,
    double consistency,
    double improvement,
    double engagement,
  ) {
    final insights = <String>[];

    // Overall performance insight
    if (totalScore >= 700) {
      insights.add('🌟 Prestazioni cognitive eccellenti! Continua così!');
    } else if (totalScore >= 500) {
      insights.add('👍 Buone prestazioni cognitive. Hai margini di miglioramento!');
    } else {
      insights.add('💪 Continua ad allenarti regolarmente per migliorare!');
    }

    // Domain-specific insights
    final sortedDomains = domainScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final strongestDomain = sortedDomains.first;
    final weakestDomain = sortedDomains.last;

    insights.add('🎯 Punto di forza: ${_getDomainName(strongestDomain.key)} (${strongestDomain.value.toInt()}%)');
    
    if (weakestDomain.value < 60) {
      insights.add('📚 Area di miglioramento: ${_getDomainName(weakestDomain.key)} - Concentrati su questi esercizi!');
    }

    // Consistency insight
    if (consistency >= 80) {
      insights.add('✅ Ottima costanza nelle prestazioni!');
    } else if (consistency < 50) {
      insights.add('⚠️ Prestazioni altalenanti - cerca di mantenere una routine regolare');
    }

    // Improvement insight
    if (improvement >= 70) {
      insights.add('📈 Ottimi progressi nel tempo! Continua così!');
    } else if (improvement < 40) {
      insights.add('💡 Suggerimento: Varia gli esercizi per stimolare diverse aree cognitive');
    }

    // Engagement insight
    if (engagement >= 70) {
      insights.add('🔥 Eccellente impegno! Stai seguendo il programma con dedizione');
    } else if (engagement < 40) {
      insights.add('📅 Aumenta la frequenza delle sessioni per risultati migliori (obiettivo: 4-5 a settimana)');
    }

    return insights;
  }

  static String _getDomainName(String domain) {
    switch (domain) {
      case 'memory':
        return 'Memoria';
      case 'attention':
        return 'Attenzione';
      case 'executive':
        return 'Funzioni Esecutive';
      case 'speed':
        return 'Velocità';
      case 'language':
        return 'Linguaggio';
      case 'spatial':
        return 'Abilità Spaziali';
      default:
        return domain;
    }
  }
}

class BrainBoostScore {
  final int totalScore; // 0-1000
  final Map<String, double> domainScores; // 0-100 per domain
  final double consistency; // 0-100
  final double improvement; // 0-100
  final double engagement; // 0-100
  final String cognitiveLevel;
  final String ageGroup;
  final int percentileRank; // 0-99
  final DateTime lastUpdated;
  final int totalSessions;
  final List<String> insights;

  BrainBoostScore({
    required this.totalScore,
    required this.domainScores,
    required this.consistency,
    required this.improvement,
    required this.engagement,
    required this.cognitiveLevel,
    required this.ageGroup,
    required this.percentileRank,
    required this.lastUpdated,
    required this.totalSessions,
    required this.insights,
  });

  factory BrainBoostScore.initial() {
    return BrainBoostScore(
      totalScore: 500,
      domainScores: {
        'memory': 50.0,
        'attention': 50.0,
        'executive': 50.0,
        'speed': 50.0,
        'language': 50.0,
        'spatial': 50.0,
      },
      consistency: 50.0,
      improvement: 50.0,
      engagement: 0.0,
      cognitiveLevel: 'Intermedio',
      ageGroup: 'Non definito',
      percentileRank: 50,
      lastUpdated: DateTime.now(),
      totalSessions: 0,
      insights: ['🎯 Inizia il tuo percorso di allenamento cognitivo!'],
    );
  }

  String get scoreCategory {
    if (totalScore >= 800) return 'Eccellente';
    if (totalScore >= 600) return 'Buono';
    if (totalScore >= 400) return 'Medio';
    if (totalScore >= 200) return 'Base';
    return 'Iniziale';
  }

  Color getScoreColor() {
    if (totalScore >= 800) return Color(0xFF4CAF50);
    if (totalScore >= 600) return Color(0xFF2196F3);
    if (totalScore >= 400) return Color(0xFFFF9800);
    return Color(0xFFF44336);
  }
}
