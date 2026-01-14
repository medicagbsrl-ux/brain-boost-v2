class ScheduledSession {
  final String id;
  final String userId;
  final DateTime scheduledTime;
  final int durationMinutes;
  final List<String> plannedGames; // Game IDs to play
  final bool completed;
  final DateTime? completedAt;
  final bool reminderSent;
  final String? notes;

  ScheduledSession({
    required this.id,
    required this.userId,
    required this.scheduledTime,
    required this.durationMinutes,
    required this.plannedGames,
    this.completed = false,
    this.completedAt,
    this.reminderSent = false,
    this.notes,
  });

  bool get isOverdue => !completed && DateTime.now().isAfter(scheduledTime);
  bool get isToday {
    final now = DateTime.now();
    return scheduledTime.year == now.year &&
        scheduledTime.month == now.month &&
        scheduledTime.day == now.day;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'scheduledTime': scheduledTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'plannedGames': plannedGames,
      'completed': completed,
      'completedAt': completedAt?.toIso8601String(),
      'reminderSent': reminderSent,
      'notes': notes,
    };
  }

  factory ScheduledSession.fromMap(Map<String, dynamic> map) {
    return ScheduledSession(
      id: map['id'] as String,
      userId: map['userId'] as String,
      scheduledTime: DateTime.parse(map['scheduledTime'] as String),
      durationMinutes: map['durationMinutes'] as int,
      plannedGames: List<String>.from(map['plannedGames'] as List),
      completed: map['completed'] as bool? ?? false,
      completedAt: map['completedAt'] != null 
          ? DateTime.parse(map['completedAt'] as String)
          : null,
      reminderSent: map['reminderSent'] as bool? ?? false,
      notes: map['notes'] as String?,
    );
  }

  ScheduledSession copyWith({
    String? id,
    String? userId,
    DateTime? scheduledTime,
    int? durationMinutes,
    List<String>? plannedGames,
    bool? completed,
    DateTime? completedAt,
    bool? reminderSent,
    String? notes,
  }) {
    return ScheduledSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      plannedGames: plannedGames ?? this.plannedGames,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      reminderSent: reminderSent ?? this.reminderSent,
      notes: notes ?? this.notes,
    );
  }
}

class AdherenceStats {
  final int totalScheduled;
  final int totalCompleted;
  final int currentStreak;
  final int longestStreak;
  final double adherencePercentage;
  final Map<String, int> weeklyCompletion; // Week -> Completed sessions
  final DateTime lastSessionDate;

  AdherenceStats({
    required this.totalScheduled,
    required this.totalCompleted,
    required this.currentStreak,
    required this.longestStreak,
    required this.adherencePercentage,
    required this.weeklyCompletion,
    required this.lastSessionDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'totalScheduled': totalScheduled,
      'totalCompleted': totalCompleted,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'adherencePercentage': adherencePercentage,
      'weeklyCompletion': weeklyCompletion,
      'lastSessionDate': lastSessionDate.toIso8601String(),
    };
  }

  factory AdherenceStats.fromMap(Map<String, dynamic> map) {
    return AdherenceStats(
      totalScheduled: map['totalScheduled'] as int,
      totalCompleted: map['totalCompleted'] as int,
      currentStreak: map['currentStreak'] as int,
      longestStreak: map['longestStreak'] as int,
      adherencePercentage: (map['adherencePercentage'] as num).toDouble(),
      weeklyCompletion: Map<String, int>.from(map['weeklyCompletion'] as Map),
      lastSessionDate: DateTime.parse(map['lastSessionDate'] as String),
    );
  }

  String get adherenceLevel {
    if (adherencePercentage >= 90) return 'Eccellente';
    if (adherencePercentage >= 75) return 'Buona';
    if (adherencePercentage >= 60) return 'Discreta';
    return 'Da Migliorare';
  }
}
