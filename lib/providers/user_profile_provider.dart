import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../services/local_storage_service.dart';
import '../services/notification_service.dart';

class UserProfileProvider extends ChangeNotifier {
  UserProfile? _currentProfile;
  bool _isLoading = true;

  UserProfile? get currentProfile => _currentProfile;
  bool get isLoading => _isLoading;
  bool get hasProfile => _currentProfile != null;

  UserProfileProvider() {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Carica profilo da LocalStorage
      _currentProfile = await LocalStorageService.getUserProfile();
      
      if (kDebugMode) {
        if (_currentProfile != null) {
          debugPrint('✅ Profilo caricato: ${_currentProfile!.name}');
        } else {
          debugPrint('⚠️ Nessun profilo trovato - Mostra LoginScreen');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading profile: $e');
      }
      _currentProfile = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Set profile (called after login/register)
  void setProfile(UserProfile profile) {
    _currentProfile = profile;
    notifyListeners();
  }

  // Logout
  Future<void> logout() async {
    _currentProfile = null;
    notifyListeners();
    
    // Clear current profile from storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_profile');
    await prefs.remove('profile_data');
  }

  Future<void> updateProfile(UserProfile profile) async {
    _currentProfile = profile;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_profile', 'profile_data');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving profile: $e');
      }
    }
  }

  Future<void> updateTheme(String theme) async {
    if (_currentProfile != null) {
      _currentProfile = _currentProfile!.copyWith(theme: theme);
      notifyListeners();
      await _saveProfile();
    }
  }

  Future<void> updateTextSize(String textSize) async {
    if (_currentProfile != null) {
      _currentProfile = _currentProfile!.copyWith(textSize: textSize);
      notifyListeners();
      await _saveProfile();
    }
  }

  Future<void> updateLanguage(String language) async {
    if (_currentProfile != null) {
      _currentProfile = _currentProfile!.copyWith(language: language);
      notifyListeners();
      await _saveProfile();
    }
  }

  Future<void> updateContrast(String contrast) async {
    if (_currentProfile != null) {
      _currentProfile = _currentProfile!.copyWith(contrast: contrast);
      notifyListeners();
      await _saveProfile();
    }
  }

  Future<void> updateSessionDuration(int duration) async {
    if (_currentProfile != null) {
      _currentProfile = _currentProfile!.copyWith(sessionDuration: duration);
      notifyListeners();
      await _saveProfile();
    }
  }

  Future<void> incrementSessionsCompleted() async {
    if (_currentProfile != null) {
      _currentProfile = _currentProfile!.copyWith(
        sessionsCompleted: _currentProfile!.sessionsCompleted + 1,
      );
      notifyListeners();
      await _saveProfile();
    }
  }

  Future<void> addPoints(int points) async {
    if (_currentProfile != null) {
      _currentProfile = _currentProfile!.copyWith(
        totalPoints: _currentProfile!.totalPoints + points,
      );
      notifyListeners();
      await _saveProfile();
    }
  }

  Future<void> updateCognitiveScore(String domain, double score) async {
    if (_currentProfile != null) {
      final updatedScores = Map<String, double>.from(_currentProfile!.cognitiveScores);
      updatedScores[domain] = score;
      _currentProfile = _currentProfile!.copyWith(cognitiveScores: updatedScores);
      notifyListeners();
      await _saveProfile();
    }
  }

  Future<void> _saveProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_profile', 'profile_data');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving profile: $e');
      }
    }
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    final locale = _currentProfile?.language ?? 'it';

    if (locale == 'it') {
      if (hour < 12) return 'Buongiorno';
      if (hour < 18) return 'Buon pomeriggio';
      return 'Buonasera';
    } else {
      if (hour < 12) return 'Good Morning';
      if (hour < 18) return 'Good Afternoon';
      return 'Good Evening';
    }
  }

  /// Ricarica statistiche reali da Hive
  Future<void> refreshStatistics() async {
    if (_currentProfile == null) return;

    try {
      // Carica sessioni reali
      final sessions = await LocalStorageService.getAllSessionHistory(_currentProfile!.id);
      
      if (sessions.isEmpty) {
        // Nessuna sessione ancora, mantieni demo
        return;
      }

      // Calcola statistiche reali
      final sessionsCompleted = sessions.length;
      
      // Calcola punteggi per dominio
      final Map<String, List<double>> domainScoresMap = {};
      for (final session in sessions) {
        if (!domainScoresMap.containsKey(session.domain)) {
          domainScoresMap[session.domain] = [];
        }
        domainScoresMap[session.domain]!.add(session.accuracy);
      }
      
      final Map<String, double> cognitiveScores = {};
      domainScoresMap.forEach((domain, scores) {
        cognitiveScores[domain] = scores.isEmpty 
            ? 0.0 
            : scores.reduce((a, b) => a + b) / scores.length;
      });
      
      // Calcola streak CORRETTO - conta giorni unici consecutivi
      int streakDays = 0;
      if (sessions.isNotEmpty) {
        // Ordina sessioni dalla più recente
        final sortedSessions = [...sessions]..sort((a, b) => b.startTime.compareTo(a.startTime));
        
        // Raggruppa per giorno unico
        final Set<String> uniqueDays = {};
        for (var session in sortedSessions) {
          final dayKey = '${session.startTime.year}-${session.startTime.month}-${session.startTime.day}';
          uniqueDays.add(dayKey);
        }
        
        // Converti in lista ordinata di date
        final uniqueDates = uniqueDays.map((dayKey) {
          final parts = dayKey.split('-');
          return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
        }).toList()..sort((a, b) => b.compareTo(a));
        
        // Calcola streak consecutivi
        if (uniqueDates.isNotEmpty) {
          final today = DateTime.now();
          final todayMidnight = DateTime(today.year, today.month, today.day);
          final mostRecentDay = DateTime(uniqueDates.first.year, uniqueDates.first.month, uniqueDates.first.day);
          
          // Controlla se il giorno più recente è oggi o ieri
          final daysSinceLastSession = todayMidnight.difference(mostRecentDay).inDays;
          
          if (daysSinceLastSession <= 1) {
            // Streak attivo
            streakDays = 1;
            
            for (int i = 1; i < uniqueDates.length; i++) {
              final currentDay = DateTime(uniqueDates[i].year, uniqueDates[i].month, uniqueDates[i].day);
              final previousDay = DateTime(uniqueDates[i - 1].year, uniqueDates[i - 1].month, uniqueDates[i - 1].day);
              final daysDiff = previousDay.difference(currentDay).inDays;
              
              if (daysDiff == 1) {
                streakDays++;
              } else {
                break;
              }
            }
          } else {
            // Streak interrotto
            streakDays = 0;
          }
        }
      }
      
      // Calcola XP totali basati su accuracy reale
      final totalPoints = sessions.fold<int>(
        0,
        (sum, session) => sum + (session.accuracy * 10).round(),
      );
      
      // Calcola livello (ogni 500 XP = 1 livello, più realistico)
      final currentLevel = (totalPoints / 500).floor() + 1;
      
      // Aggiorna profilo con statistiche reali
      _currentProfile = _currentProfile!.copyWith(
        sessionsCompleted: sessionsCompleted,
        totalPoints: totalPoints,
        currentLevel: currentLevel,
        streakDays: streakDays,
        cognitiveScores: cognitiveScores.isNotEmpty 
            ? cognitiveScores 
            : _currentProfile!.cognitiveScores,
      );
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error refreshing statistics: $e');
      }
    }
  }

  // ==================== NOTIFICATION & ACHIEVEMENT METHODS ====================

  /// Check and trigger achievement notifications after session
  Future<void> checkAchievements(int oldLevel, int oldStreak) async {
    if (_currentProfile == null) return;

    final newLevel = _currentProfile!.currentLevel;
    final newStreak = _currentProfile!.streakDays;

    // Level up notification
    if (newLevel > oldLevel) {
      await NotificationService.showLevelUpNotification(newLevel);
      
      // Special milestones
      if (newLevel == 10) {
        await NotificationService.showBadgeEarnedNotification(
          'Decatleta Cerebrale',
          'Hai raggiunto il livello 10!',
        );
      } else if (newLevel == 25) {
        await NotificationService.showBadgeEarnedNotification(
          'Maestro della Mente',
          'Hai raggiunto il livello 25!',
        );
      } else if (newLevel == 50) {
        await NotificationService.showBadgeEarnedNotification(
          'Leggenda Cognitiva',
          'Hai raggiunto il livello 50!',
        );
      }
    }

    // Streak milestone notifications
    if (newStreak > oldStreak && newStreak >= 3) {
      if (newStreak == 7 || newStreak == 14 || newStreak == 30 || 
          newStreak == 50 || newStreak == 100) {
        await NotificationService.showStreakMilestoneNotification(newStreak);
      }
    }

    // Session count milestones
    final sessions = _currentProfile!.sessionsCompleted;
    if (sessions == 10) {
      await NotificationService.showMilestoneNotification(
        'Prima decina! 10 sessioni completate! 🎯',
      );
    } else if (sessions == 50) {
      await NotificationService.showMilestoneNotification(
        'Cinquantina! 50 sessioni completate! ⭐',
      );
    } else if (sessions == 100) {
      await NotificationService.showMilestoneNotification(
        'Centenario! 100 sessioni completate! 🏆',
      );
    }
  }

  /// Enable/disable daily reminders
  Future<void> setDailyReminder(bool enabled, int hour, int minute) async {
    if (_currentProfile == null) return;

    if (enabled) {
      await NotificationService.scheduleDailyReminder(
        hour: hour,
        minute: minute,
        userName: _currentProfile!.name,
      );
    } else {
      await NotificationService.cancelDailyReminder();
    }

    // Update profile
    _currentProfile = _currentProfile!.copyWith(remindersEnabled: enabled);
    notifyListeners();
    await _saveProfile();
  }

  /// Check if user should get a streak at risk notification (evening check)
  Future<void> checkStreakAtRisk() async {
    if (_currentProfile == null) return;

    final now = DateTime.now();
    final hour = now.hour;

    // Check only in the evening (after 18:00)
    if (hour < 18) return;

    // Get today's sessions
    final sessions = await LocalStorageService.getAllSessionHistory(_currentProfile!.id);
    final todaySessions = sessions.where((s) {
      final sessionDate = s.startTime;
      return sessionDate.year == now.year &&
          sessionDate.month == now.month &&
          sessionDate.day == now.day;
    }).toList();

    // If no sessions today and has active streak, warn user
    if (todaySessions.isEmpty && _currentProfile!.streakDays > 0) {
      await NotificationService.showStreakAtRiskNotification(
        _currentProfile!.streakDays,
      );
    }
  }
}

