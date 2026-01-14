import 'package:flutter/foundation.dart';
import 'dart:math';
import '../models/session_history.dart';

/// Enum per rarità badge
enum BadgeRarity { common, rare, epic, legendary }

/// Classe Badge
class Badge {
  final String id;
  final String name;
  final String description;
  final String icon;
  final BadgeRarity rarity;
  
  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.rarity,
  });
}

/// Sistema Gamification completo
/// XP, livelli 1-100, badge 50+, streak, achievement
class GamificationService {
  static final GamificationService _instance = GamificationService._internal();
  factory GamificationService() => _instance;
  GamificationService._internal();

  // Sistema XP e Livelli
  static const int _xpPerLevel = 1000; // XP necessari per livello
  static const double _xpMultiplier = 1.2; // Moltiplicatore crescita XP

  /// Calcola XP guadagnati da una sessione
  int calculateSessionXP({
    required double score,
    required double accuracy,
    required int difficulty,
    required bool perfectScore,
    required int streakDays,
  }) {
    // Base XP: 50-150 basato su score
    double baseXP = 50 + (score / 100 * 100);
    
    // Bonus accuracy
    double accuracyBonus = accuracy > 90 ? 50 : accuracy > 80 ? 30 : accuracy > 70 ? 10 : 0;
    
    // Bonus difficulty
    double difficultyBonus = difficulty * 10.0;
    
    // Bonus perfect score
    double perfectBonus = perfectScore ? 100 : 0;
    
    // Bonus streak
    double streakBonus = min(streakDays * 5.0, 100);
    
    final totalXP = (baseXP + accuracyBonus + difficultyBonus + perfectBonus + streakBonus).toInt();
    
    if (kDebugMode) {
      debugPrint('🎮 XP Guadagnati: $totalXP (base: ${baseXP.toInt()}, accuracy: ${accuracyBonus.toInt()}, diff: ${difficultyBonus.toInt()}, perfect: ${perfectBonus.toInt()}, streak: ${streakBonus.toInt()})');
    }
    
    return totalXP;
  }

  /// Calcola livello da XP totali
  int calculateLevel(int totalXP) {
    int level = 1;
    int xpRequired = _xpPerLevel;
    int xpAccumulated = 0;
    
    while (xpAccumulated + xpRequired <= totalXP && level < 100) {
      xpAccumulated += xpRequired;
      level++;
      xpRequired = (_xpPerLevel * pow(_xpMultiplier, level - 1)).toInt();
    }
    
    return level;
  }

  /// XP richiesti per prossimo livello
  int getXPForNextLevel(int currentLevel) {
    return (_xpPerLevel * pow(_xpMultiplier, currentLevel)).toInt();
  }

  /// XP mancanti per prossimo livello
  int getXPToNextLevel(int totalXP, int currentLevel) {
    int xpAccumulated = 0;
    for (int i = 1; i < currentLevel; i++) {
      xpAccumulated += (_xpPerLevel * pow(_xpMultiplier, i - 1)).toInt();
    }
    
    final xpForNext = getXPForNextLevel(currentLevel);
    final xpInCurrentLevel = totalXP - xpAccumulated;
    
    return max(0, xpForNext - xpInCurrentLevel);
  }

  /// Progress percentuale verso prossimo livello
  double getProgressToNextLevel(int totalXP, int currentLevel) {
    final xpForNext = getXPForNextLevel(currentLevel);
    final xpToNext = getXPToNextLevel(totalXP, currentLevel);
    
    return ((xpForNext - xpToNext) / xpForNext).clamp(0.0, 1.0);
  }

  // SISTEMA BADGE (50+ badge)
  
  /// Ottieni tutti i badge disponibili
  List<Badge> getAllBadges() {
    return [
      // Badge Progressione (5)
      Badge(id: 'first_session', name: 'Prima Sessione', description: 'Completa la tua prima sessione', icon: '🎯', rarity: BadgeRarity.common),
      Badge(id: 'level_10', name: 'Livello 10', description: 'Raggiungi il livello 10', icon: '⭐', rarity: BadgeRarity.common),
      Badge(id: 'level_25', name: 'Livello 25', description: 'Raggiungi il livello 25', icon: '🌟', rarity: BadgeRarity.rare),
      Badge(id: 'level_50', name: 'Livello 50', description: 'Raggiungi il livello 50', icon: '💫', rarity: BadgeRarity.epic),
      Badge(id: 'level_100', name: 'Maestro Cognitivo', description: 'Raggiungi il livello 100', icon: '👑', rarity: BadgeRarity.legendary),
      
      // Badge Streak (5)
      Badge(id: 'streak_7', name: 'Una Settimana', description: '7 giorni consecutivi', icon: '🔥', rarity: BadgeRarity.common),
      Badge(id: 'streak_30', name: 'Un Mese', description: '30 giorni consecutivi', icon: '🔥🔥', rarity: BadgeRarity.rare),
      Badge(id: 'streak_100', name: 'Centenario', description: '100 giorni consecutivi', icon: '🔥🔥🔥', rarity: BadgeRarity.epic),
      Badge(id: 'streak_365', name: 'Anno Perfetto', description: '365 giorni consecutivi', icon: '🏆', rarity: BadgeRarity.legendary),
      Badge(id: 'no_break', name: 'Mai Mollare', description: 'Mai saltato un giorno per 30 giorni', icon: '💪', rarity: BadgeRarity.epic),
      
      // Badge Performance (10)
      Badge(id: 'perfect_score', name: 'Punteggio Perfetto', description: '100% precisione', icon: '💯', rarity: BadgeRarity.rare),
      Badge(id: 'perfect_10', name: 'Perfezionista', description: '10 punteggi perfetti', icon: '⚡', rarity: BadgeRarity.epic),
      Badge(id: 'score_1000', name: 'Brain Boost Elite', description: 'Raggiungi 1000 Brain Boost Score', icon: '🧠', rarity: BadgeRarity.legendary),
      Badge(id: 'high_scorer', name: 'Top Performer', description: '95+ punti in una sessione', icon: '🎖️', rarity: BadgeRarity.rare),
      Badge(id: 'consistent', name: 'Consistenza', description: '10 sessioni consecutive >80%', icon: '📊', rarity: BadgeRarity.rare),
      Badge(id: 'improvement', name: 'Miglioramento', description: '+50% rispetto al primo assessment', icon: '📈', rarity: BadgeRarity.epic),
      Badge(id: 'speed_demon', name: 'Velocista', description: 'Tempo reazione <300ms', icon: '⚡', rarity: BadgeRarity.rare),
      Badge(id: 'memory_master', name: 'Maestro della Memoria', description: '100 sessioni Memory Match', icon: '🧩', rarity: BadgeRarity.epic),
      Badge(id: 'attention_ace', name: 'Asso dell\'Attenzione', description: '100 sessioni Stroop', icon: '👁️', rarity: BadgeRarity.epic),
      Badge(id: 'executive_expert', name: 'Esperto Esecutivo', description: '100 sessioni Sequenze', icon: '⚙️', rarity: BadgeRarity.epic),
      
      // Badge Dedizione (10)
      Badge(id: 'sessions_10', name: '10 Sessioni', description: 'Completa 10 sessioni', icon: '🎮', rarity: BadgeRarity.common),
      Badge(id: 'sessions_50', name: '50 Sessioni', description: 'Completa 50 sessioni', icon: '🎯', rarity: BadgeRarity.common),
      Badge(id: 'sessions_100', name: '100 Sessioni', description: 'Completa 100 sessioni', icon: '💪', rarity: BadgeRarity.rare),
      Badge(id: 'sessions_500', name: '500 Sessioni', description: 'Completa 500 sessioni', icon: '🌟', rarity: BadgeRarity.epic),
      Badge(id: 'sessions_1000', name: 'Millenario', description: 'Completa 1000 sessioni', icon: '👑', rarity: BadgeRarity.legendary),
      Badge(id: 'morning_bird', name: 'Mattiniero', description: '30 sessioni prima delle 9:00', icon: '🌅', rarity: BadgeRarity.rare),
      Badge(id: 'night_owl', name: 'Gufo Notturno', description: '30 sessioni dopo le 22:00', icon: '🦉', rarity: BadgeRarity.rare),
      Badge(id: 'weekend_warrior', name: 'Guerriero del Weekend', description: '20 weekend completi', icon: '🛡️', rarity: BadgeRarity.rare),
      Badge(id: 'marathon', name: 'Maratoneta', description: '5 ore in un giorno', icon: '🏃', rarity: BadgeRarity.epic),
      Badge(id: 'diverse', name: 'Versatile', description: 'Gioca a tutti i giochi 10+ volte', icon: '🎨', rarity: BadgeRarity.rare),
      
      // Badge Sociali (5)
      Badge(id: 'share_first', name: 'Condivisione', description: 'Condividi il tuo primo risultato', icon: '🔗', rarity: BadgeRarity.common),
      Badge(id: 'help_others', name: 'Mentore', description: 'Aiuta 5 nuovi utenti', icon: '🤝', rarity: BadgeRarity.rare),
      Badge(id: 'referral', name: 'Ambasciatore', description: 'Invita 10 amici', icon: '📧', rarity: BadgeRarity.epic),
      Badge(id: 'community', name: 'Membro Attivo', description: 'Partecipa a 20 discussioni', icon: '💬', rarity: BadgeRarity.rare),
      Badge(id: 'supporter', name: 'Sostenitore', description: 'Supporta il progetto', icon: '❤️', rarity: BadgeRarity.legendary),
      
      // Badge Speciali (15)
      Badge(id: 'early_bird', name: 'Utente Pioneer', description: 'Tra i primi 100 utenti', icon: '🚀', rarity: BadgeRarity.legendary),
      Badge(id: 'birthday', name: 'Compleanno', description: 'Gioca nel tuo compleanno', icon: '🎂', rarity: BadgeRarity.rare),
      Badge(id: 'new_year', name: 'Anno Nuovo', description: 'Gioca il 1 gennaio', icon: '🎉', rarity: BadgeRarity.rare),
      Badge(id: 'halloween', name: 'Halloween', description: 'Gioca il 31 ottobre', icon: '🎃', rarity: BadgeRarity.rare),
      Badge(id: 'christmas', name: 'Natale', description: 'Gioca il 25 dicembre', icon: '🎄', rarity: BadgeRarity.rare),
      Badge(id: 'valentine', name: 'San Valentino', description: 'Gioca il 14 febbraio', icon: '💝', rarity: BadgeRarity.rare),
      Badge(id: 'comeback', name: 'Ritorno', description: 'Torna dopo 30 giorni', icon: '↩️', rarity: BadgeRarity.rare),
      Badge(id: 'lucky_7', name: 'Fortuna 7', description: 'Completa 7 sessioni consecutive perfette', icon: '🍀', rarity: BadgeRarity.epic),
      Badge(id: 'night_streak', name: 'Nottambulo', description: '10 notti consecutive', icon: '🌙', rarity: BadgeRarity.epic),
      Badge(id: 'early_streak', name: 'Alba', description: '10 mattine consecutive', icon: '☀️', rarity: BadgeRarity.epic),
      Badge(id: 'weekend_only', name: 'Solo Weekend', description: '8 weekend consecutivi', icon: '🎈', rarity: BadgeRarity.rare),
      Badge(id: 'no_mistake', name: 'Senza Errori', description: '50 sessioni senza errori', icon: '✅', rarity: BadgeRarity.legendary),
      Badge(id: 'speed_master', name: 'Maestro di Velocità', description: 'Top 1% tempi reazione', icon: '💨', rarity: BadgeRarity.legendary),
      Badge(id: 'brain_champion', name: 'Campione Cerebrale', description: 'Top 1% Brain Boost Score', icon: '🏅', rarity: BadgeRarity.legendary),
      Badge(id: 'dedication', name: 'Dedizione Assoluta', description: '1 anno di allenamento continuo', icon: '🎖️', rarity: BadgeRarity.legendary),
    ];
  }

  /// Controlla e assegna badge guadagnati
  Future<List<Badge>> checkAndAwardBadges({
    required String userId,
    required List<SessionHistory> sessions,
    required int currentLevel,
    required int streakDays,
    required double brainBoostScore,
  }) async {
    final earnedBadges = <Badge>[];
    final allBadges = getAllBadges();
    
    // Badge progressione
    if (currentLevel >= 10 && !await _hasBadge(userId, 'level_10')) {
      earnedBadges.add(allBadges.firstWhere((b) => b.id == 'level_10'));
    }
    if (currentLevel >= 25 && !await _hasBadge(userId, 'level_25')) {
      earnedBadges.add(allBadges.firstWhere((b) => b.id == 'level_25'));
    }
    if (currentLevel >= 50 && !await _hasBadge(userId, 'level_50')) {
      earnedBadges.add(allBadges.firstWhere((b) => b.id == 'level_50'));
    }
    if (currentLevel >= 100 && !await _hasBadge(userId, 'level_100')) {
      earnedBadges.add(allBadges.firstWhere((b) => b.id == 'level_100'));
    }
    
    // Badge streak
    if (streakDays >= 7 && !await _hasBadge(userId, 'streak_7')) {
      earnedBadges.add(allBadges.firstWhere((b) => b.id == 'streak_7'));
    }
    if (streakDays >= 30 && !await _hasBadge(userId, 'streak_30')) {
      earnedBadges.add(allBadges.firstWhere((b) => b.id == 'streak_30'));
    }
    if (streakDays >= 100 && !await _hasBadge(userId, 'streak_100')) {
      earnedBadges.add(allBadges.firstWhere((b) => b.id == 'streak_100'));
    }
    if (streakDays >= 365 && !await _hasBadge(userId, 'streak_365')) {
      earnedBadges.add(allBadges.firstWhere((b) => b.id == 'streak_365'));
    }
    
    // Badge sessioni
    if (sessions.length >= 10 && !await _hasBadge(userId, 'sessions_10')) {
      earnedBadges.add(allBadges.firstWhere((b) => b.id == 'sessions_10'));
    }
    if (sessions.length >= 50 && !await _hasBadge(userId, 'sessions_50')) {
      earnedBadges.add(allBadges.firstWhere((b) => b.id == 'sessions_50'));
    }
    if (sessions.length >= 100 && !await _hasBadge(userId, 'sessions_100')) {
      earnedBadges.add(allBadges.firstWhere((b) => b.id == 'sessions_100'));
    }
    if (sessions.length >= 500 && !await _hasBadge(userId, 'sessions_500')) {
      earnedBadges.add(allBadges.firstWhere((b) => b.id == 'sessions_500'));
    }
    if (sessions.length >= 1000 && !await _hasBadge(userId, 'sessions_1000')) {
      earnedBadges.add(allBadges.firstWhere((b) => b.id == 'sessions_1000'));
    }
    
    // Badge Brain Boost Score
    if (brainBoostScore >= 1000 && !await _hasBadge(userId, 'score_1000')) {
      earnedBadges.add(allBadges.firstWhere((b) => b.id == 'score_1000'));
    }
    
    // Salva badge guadagnati
    for (final badge in earnedBadges) {
      await _saveBadge(userId, badge.id);
    }
    
    if (earnedBadges.isNotEmpty && kDebugMode) {
      debugPrint('🏆 Nuovi badge guadagnati: ${earnedBadges.map((b) => b.name).join(", ")}');
    }
    
    return earnedBadges;
  }

  Future<bool> _hasBadge(String userId, String badgeId) async {
    // TODO: Implementa storage badge
    return false;
  }

  Future<void> _saveBadge(String userId, String badgeId) async {
    // TODO: Implementa storage badge
  }
}
