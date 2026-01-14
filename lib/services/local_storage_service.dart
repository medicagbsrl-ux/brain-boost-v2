import 'package:hive_flutter/hive_flutter.dart';
import '../models/session_history.dart';
import '../models/assessment_result.dart';
import '../models/scheduled_session.dart';
import '../models/user_profile.dart';

class LocalStorageService {
  static const String _sessionHistoryBox = 'session_history';
  static const String _assessmentResultsBox = 'assessment_results';
  static const String _scheduledSessionsBox = 'scheduled_sessions';
  static const String _userProfileBox = 'user_profile';

  // ✅ SEMPLIFICATO - Nessuna encryption, nessuna dipendenza da FlutterSecureStorage
  static Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Open boxes WITHOUT encryption (evita problemi Firebase)
    await Hive.openBox(_sessionHistoryBox);
    await Hive.openBox(_assessmentResultsBox);
    await Hive.openBox(_scheduledSessionsBox);
    await Hive.openBox(_userProfileBox);
  }

  // Get user profile box
  static Future<Box> getUserBox() async {
    if (!Hive.isBoxOpen(_userProfileBox)) {
      return await Hive.openBox(_userProfileBox);
    }
    return Hive.box(_userProfileBox);
  }

  // ========== SESSION HISTORY ==========
  
  static Future<void> saveSessionHistory(SessionHistory session) async {
    final box = Hive.box(_sessionHistoryBox);
    await box.put(session.id, session.toMap());
  }

  static Future<List<SessionHistory>> getSessionHistory(String userId) async {
    final box = Hive.box(_sessionHistoryBox);
    final sessions = <SessionHistory>[];
    
    for (var key in box.keys) {
      final map = box.get(key) as Map<dynamic, dynamic>;
      final session = SessionHistory.fromMap(Map<String, dynamic>.from(map));
      if (session.userId == userId) {
        sessions.add(session);
      }
    }
    
    // Sort by date descending
    sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    return sessions;
  }

  static Future<List<SessionHistory>> getSessionHistoryByGame(
    String userId,
    String gameId,
  ) async {
    final allSessions = await getSessionHistory(userId);
    return allSessions.where((s) => s.gameId == gameId).toList();
  }

  static Future<List<SessionHistory>> getSessionHistoryByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final allSessions = await getSessionHistory(userId);
    return allSessions.where((s) {
      return s.startTime.isAfter(startDate) && s.startTime.isBefore(endDate);
    }).toList();
  }

  /// Get ALL session history for a user (alias per compatibilità)
  static Future<List<SessionHistory>> getAllSessionHistory(String userId) async {
    return getSessionHistory(userId);
  }

  /// Get game-specific history with limit
  static Future<List<SessionHistory>> getGameHistory(
    String userId,
    String gameId, {
    int limit = 10,
  }) async {
    final allSessions = await getSessionHistory(userId);
    final gameSessions = allSessions.where((s) => s.gameId == gameId).toList();
    return gameSessions.take(limit).toList();
  }

  // ========== ASSESSMENT RESULTS ==========
  
  static Future<void> saveAssessmentResult(AssessmentResult result) async {
    final box = Hive.box(_assessmentResultsBox);
    await box.put(result.id, result.toMap());
  }

  static Future<List<AssessmentResult>> getAssessmentResults(String userId) async {
    final box = Hive.box(_assessmentResultsBox);
    final results = <AssessmentResult>[];
    
    for (var key in box.keys) {
      final map = box.get(key) as Map<dynamic, dynamic>;
      final result = AssessmentResult.fromMap(Map<String, dynamic>.from(map));
      if (result.userId == userId) {
        results.add(result);
      }
    }
    
    // Sort by date descending
    results.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return results;
  }

  static Future<AssessmentResult?> getLatestAssessment(String userId) async {
    final results = await getAssessmentResults(userId);
    return results.isNotEmpty ? results.first : null;
  }

  // ========== SCHEDULED SESSIONS ==========
  
  static Future<void> saveScheduledSession(ScheduledSession session) async {
    final box = Hive.box(_scheduledSessionsBox);
    await box.put(session.id, session.toMap());
  }

  static Future<List<ScheduledSession>> getScheduledSessions(String userId) async {
    final box = Hive.box(_scheduledSessionsBox);
    final sessions = <ScheduledSession>[];
    
    for (var key in box.keys) {
      final map = box.get(key) as Map<dynamic, dynamic>;
      final session = ScheduledSession.fromMap(Map<String, dynamic>.from(map));
      if (session.userId == userId) {
        sessions.add(session);
      }
    }
    
    // Sort by scheduled time
    sessions.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    return sessions;
  }

  static Future<List<ScheduledSession>> getUpcomingSessions(String userId) async {
    final allSessions = await getScheduledSessions(userId);
    final now = DateTime.now();
    return allSessions.where((s) {
      return !s.completed && s.scheduledTime.isAfter(now);
    }).toList();
  }

  static Future<List<ScheduledSession>> getTodaySessions(String userId) async {
    final allSessions = await getScheduledSessions(userId);
    return allSessions.where((s) => s.isToday).toList();
  }

  static Future<void> markSessionCompleted(String sessionId) async {
    final box = Hive.box(_scheduledSessionsBox);
    final map = box.get(sessionId) as Map<dynamic, dynamic>?;
    if (map != null) {
      final session = ScheduledSession.fromMap(Map<String, dynamic>.from(map));
      final updated = session.copyWith(
        completed: true,
        completedAt: DateTime.now(),
      );
      await box.put(sessionId, updated.toMap());
    }
  }

  static Future<void> deleteScheduledSession(String sessionId) async {
    final box = Hive.box(_scheduledSessionsBox);
    await box.delete(sessionId);
  }

  // ========== ADHERENCE STATS ==========
  
  static Future<AdherenceStats> calculateAdherenceStats(String userId) async {
    final sessions = await getScheduledSessions(userId);
    final now = DateTime.now();
    
    // Filter past sessions only
    final pastSessions = sessions.where((s) => 
      s.scheduledTime.isBefore(now)
    ).toList();
    
    final completed = pastSessions.where((s) => s.completed).length;
    final total = pastSessions.length;
    
    // Calculate streak
    final sortedCompleted = pastSessions
        .where((s) => s.completed)
        .toList()
      ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));
    
    int currentStreak = 0;
    DateTime? lastDate;
    
    for (var session in sortedCompleted) {
      if (lastDate == null) {
        currentStreak = 1;
        lastDate = session.completedAt!;
      } else {
        final diff = lastDate.difference(session.completedAt!).inDays;
        if (diff <= 1) {
          currentStreak++;
          lastDate = session.completedAt!;
        } else {
          break;
        }
      }
    }
    
    // Weekly completion
    final weeklyCompletion = <String, int>{};
    for (var session in sortedCompleted) {
      final week = _getWeekKey(session.completedAt!);
      weeklyCompletion[week] = (weeklyCompletion[week] ?? 0) + 1;
    }
    
    return AdherenceStats(
      totalScheduled: total,
      totalCompleted: completed,
      currentStreak: currentStreak,
      longestStreak: currentStreak, // TODO: Calculate actual longest
      adherencePercentage: total > 0 ? (completed / total * 100) : 0,
      weeklyCompletion: weeklyCompletion,
      lastSessionDate: sortedCompleted.isNotEmpty 
          ? sortedCompleted.first.completedAt!
          : DateTime.now(),
    );
  }

  static String _getWeekKey(DateTime date) {
    final weekNumber = ((date.difference(DateTime(date.year, 1, 1)).inDays) / 7).ceil();
    return '${date.year}-W$weekNumber';
  }

  // ========== USER PROFILE ==========
  
  static Future<void> saveUserProfile(UserProfile profile) async {
    final box = Hive.box(_userProfileBox);
    await box.put('current_profile', profile.toMap());
  }

  static Future<UserProfile?> getUserProfile() async {
    final box = Hive.box(_userProfileBox);
    final map = box.get('current_profile') as Map<dynamic, dynamic>?;
    if (map != null) {
      return UserProfile.fromMap(Map<String, dynamic>.from(map));
    }
    return null;
  }

  // ========== ANALYTICS ==========
  
  static Future<Map<String, double>> getDomainAverageScores(String userId) async {
    final sessions = await getSessionHistory(userId);
    final domainScores = <String, List<double>>{};
    
    for (var session in sessions) {
      if (!domainScores.containsKey(session.domain)) {
        domainScores[session.domain] = [];
      }
      domainScores[session.domain]!.add(session.percentageScore);
    }
    
    final averages = <String, double>{};
    domainScores.forEach((domain, scores) {
      averages[domain] = scores.reduce((a, b) => a + b) / scores.length;
    });
    
    return averages;
  }

  static Future<void> clearAllData() async {
    await Hive.box(_sessionHistoryBox).clear();
    await Hive.box(_assessmentResultsBox).clear();
    await Hive.box(_scheduledSessionsBox).clear();
    await Hive.box(_userProfileBox).clear();
  }
}
