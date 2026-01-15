import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../services/local_storage_service.dart';

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
      
      // Calcola score medio
      final totalScore = sessions.fold<double>(
        0.0,
        (sum, session) => sum + session.accuracy,
      );
      final avgScore = sessionsCompleted > 0 ? totalScore / sessionsCompleted : 0.0;
      
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
      
      // Calcola streak
      int streakDays = 0;
      if (sessions.isNotEmpty) {
        final sortedSessions = [...sessions]..sort((a, b) => b.startTime.compareTo(a.startTime));
        DateTime lastDate = sortedSessions.first.startTime;
        
        for (int i = 0; i < sortedSessions.length; i++) {
          final sessionDate = sortedSessions[i].startTime;
          final daysDiff = lastDate.difference(sessionDate).inDays;
          
          if (daysDiff <= 1) {
            streakDays++;
            lastDate = sessionDate;
          } else {
            break;
          }
        }
      }
      
      // Calcola XP totali (approssimazione)
      final totalPoints = sessionsCompleted * 50;
      
      // Calcola livello (ogni 1000 XP = 1 livello)
      final currentLevel = (totalPoints / 1000).floor() + 1;
      
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
}
