import 'package:uuid/uuid.dart';

class SessionHistory {
  final String id;
  final String userId;
  final String gameId;
  final String gameName;
  final DateTime startTime;
  final DateTime endTime;
  final int score;
  final int maxScore;
  final double accuracy; // 0-100%
  final int level;
  final String domain; // 'memory', 'attention', etc.
  final Map<String, dynamic> detailedMetrics; // Game-specific metrics
  final int reactionsCorrect;
  final int reactionsIncorrect;
  final double averageReactionTime; // milliseconds
  final String difficulty; // 'easy', 'medium', 'hard', 'expert'

  SessionHistory({
    String? id,
    required this.userId,
    required this.gameId,
    required this.gameName,
    required this.startTime,
    required this.endTime,
    required this.score,
    required this.maxScore,
    required this.accuracy,
    required this.level,
    required this.domain,
    Map<String, dynamic>? detailedMetrics,
    this.reactionsCorrect = 0,
    this.reactionsIncorrect = 0,
    this.averageReactionTime = 0.0,
    this.difficulty = 'medium',
  })  : id = id ?? const Uuid().v4(),
        detailedMetrics = detailedMetrics ?? {};

  Duration get duration => endTime.difference(startTime);

  double get percentageScore => (score / maxScore * 100).clamp(0, 100);

  // Getter di compatibilità per servizi
  double? get reactionTime => averageReactionTime;
  DateTime get timestamp => startTime;
  int get correctAttempts => reactionsCorrect;
  int get totalAttempts => reactionsCorrect + reactionsIncorrect;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'gameId': gameId,
      'gameName': gameName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'score': score,
      'maxScore': maxScore,
      'accuracy': accuracy,
      'level': level,
      'domain': domain,
      'detailedMetrics': detailedMetrics,
      'reactionsCorrect': reactionsCorrect,
      'reactionsIncorrect': reactionsIncorrect,
      'averageReactionTime': averageReactionTime,
      'difficulty': difficulty,
    };
  }

  factory SessionHistory.fromMap(Map<String, dynamic> map) {
    return SessionHistory(
      id: map['id'] as String,
      userId: map['userId'] as String,
      gameId: map['gameId'] as String,
      gameName: map['gameName'] as String,
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: DateTime.parse(map['endTime'] as String),
      score: map['score'] as int,
      maxScore: map['maxScore'] as int,
      accuracy: (map['accuracy'] as num).toDouble(),
      level: map['level'] as int,
      domain: map['domain'] as String,
      detailedMetrics: Map<String, dynamic>.from(map['detailedMetrics'] as Map? ?? {}),
      reactionsCorrect: map['reactionsCorrect'] as int? ?? 0,
      reactionsIncorrect: map['reactionsIncorrect'] as int? ?? 0,
      averageReactionTime: (map['averageReactionTime'] as num?)?.toDouble() ?? 0.0,
      difficulty: map['difficulty'] as String? ?? 'medium',
    );
  }

  SessionHistory copyWith({
    String? id,
    String? userId,
    String? gameId,
    String? gameName,
    DateTime? startTime,
    DateTime? endTime,
    int? score,
    int? maxScore,
    double? accuracy,
    int? level,
    String? domain,
    Map<String, dynamic>? detailedMetrics,
    int? reactionsCorrect,
    int? reactionsIncorrect,
    double? averageReactionTime,
    String? difficulty,
  }) {
    return SessionHistory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      gameId: gameId ?? this.gameId,
      gameName: gameName ?? this.gameName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      score: score ?? this.score,
      maxScore: maxScore ?? this.maxScore,
      accuracy: accuracy ?? this.accuracy,
      level: level ?? this.level,
      domain: domain ?? this.domain,
      detailedMetrics: detailedMetrics ?? this.detailedMetrics,
      reactionsCorrect: reactionsCorrect ?? this.reactionsCorrect,
      reactionsIncorrect: reactionsIncorrect ?? this.reactionsIncorrect,
      averageReactionTime: averageReactionTime ?? this.averageReactionTime,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}
