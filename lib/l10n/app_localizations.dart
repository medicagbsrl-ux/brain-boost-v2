import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'it': {
      // App generale
      'app_name': 'Brain Boost',
      'app_subtitle': 'Riabilitazione Cognitiva Avanzata',
      
      // Navigazione
      'nav_home': 'Home',
      'nav_games': 'Giochi',
      'nav_progress': 'Progressi',
      'nav_profile': 'Profilo',
      
      // Home Screen
      'welcome': 'Benvenuto',
      'good_morning': 'Buongiorno',
      'good_afternoon': 'Buon pomeriggio',
      'good_evening': 'Buonasera',
      'brain_health_score': 'Punteggio Salute Cerebrale',
      'start_training': 'Inizia Allenamento',
      'continue_training': 'Continua Allenamento',
      'daily_goal': 'Obiettivo Giornaliero',
      'streak_days': 'Giorni Consecutivi',
      'today_session': 'Sessione di Oggi',
      
      // Domini Cognitivi
      'cognitive_domains': 'Domini Cognitivi',
      'domain_memory': 'Memoria',
      'domain_attention': 'Attenzione',
      'domain_executive': 'Funzioni Esecutive',
      'domain_speed': 'Velocità di Elaborazione',
      'domain_language': 'Linguaggio',
      'domain_spatial': 'Abilità Visuo-Spaziali',
      
      // Giochi
      'games_title': 'Giochi Cognitivi',
      'play_now': 'Gioca Ora',
      'game_memory_match': 'Memory Match',
      'game_memory_match_desc': 'Trova le coppie - Allena la memoria',
      'game_number_sequence': 'Sequenze Numeriche',
      'game_number_sequence_desc': 'Ricorda i numeri - Memoria di lavoro',
      'game_stroop': 'Test Stroop',
      'game_stroop_desc': 'Colori e parole - Attenzione selettiva',
      'game_pattern': 'Riconoscimento Pattern',
      'game_pattern_desc': 'Trova i modelli - Ragionamento logico',
      'game_reaction': 'Tempo di Reazione',
      'game_reaction_desc': 'Riflessi veloci - Velocità cognitiva',
      'game_word_association': 'Associazione Parole',
      'game_word_association_desc': 'Collega le parole - Memoria semantica',
      'game_spatial': 'Memoria Spaziale',
      'game_spatial_desc': 'Ricorda le posizioni - Abilità visuo-spaziali',
      
      // Progressi
      'progress_title': 'I Tuoi Progressi',
      'weekly_performance': 'Performance Settimanale',
      'monthly_stats': 'Statistiche Mensili',
      'achievements': 'Traguardi',
      'level': 'Livello',
      'points': 'Punti',
      'sessions_completed': 'Sessioni Completate',
      'avg_score': 'Punteggio Medio',
      'best_score': 'Miglior Punteggio',
      'improvement': 'Miglioramento',
      
      // Profilo
      'profile_title': 'Profilo Assistito',
      'profile_settings': 'Impostazioni',
      'profile_info': 'Informazioni Personali',
      'name': 'Nome',
      'age': 'Età',
      'start_date': 'Data Inizio',
      'language': 'Lingua',
      'theme': 'Tema',
      'text_size': 'Dimensione Testo',
      'contrast': 'Contrasto',
      'session_duration': 'Durata Sessione',
      'weekly_frequency': 'Frequenza Settimanale',
      'reminders': 'Promemoria',
      
      // Temi
      'theme_professional': 'Professionale',
      'theme_gamified': 'Ludico',
      'theme_minimal': 'Minimalista',
      
      // Dimensioni Testo
      'text_normal': 'Normale',
      'text_large': 'Grande',
      'text_extra_large': 'Extra Grande',
      
      // Contrasto
      'contrast_standard': 'Standard',
      'contrast_high': 'Alto Contrasto',
      
      // Pulsanti comuni
      'save': 'Salva',
      'cancel': 'Annulla',
      'continue': 'Continua',
      'back': 'Indietro',
      'next': 'Avanti',
      'finish': 'Termina',
      'skip': 'Salta',
      'retry': 'Riprova',
      
      // Messaggi
      'loading': 'Caricamento...',
      'no_data': 'Nessun dato disponibile',
      'error': 'Errore',
      'success': 'Successo',
      'saved_successfully': 'Salvato con successo',
      
      // Assessment
      'initial_assessment': 'Valutazione Iniziale',
      'assessment_intro': 'Iniziamo con una breve valutazione per personalizzare il tuo percorso',
      'assessment_complete': 'Valutazione Completata',
      'your_profile_ready': 'Il tuo profilo è pronto',
      
      // Difficoltà
      'difficulty_easy': 'Facile',
      'difficulty_medium': 'Medio',
      'difficulty_hard': 'Difficile',
      'difficulty_expert': 'Esperto',
    },
    'en': {
      // App generale
      'app_name': 'Brain Boost',
      'app_subtitle': 'Advanced Cognitive Rehabilitation',
      
      // Navigation
      'nav_home': 'Home',
      'nav_games': 'Games',
      'nav_progress': 'Progress',
      'nav_profile': 'Profile',
      
      // Home Screen
      'welcome': 'Welcome',
      'good_morning': 'Good Morning',
      'good_afternoon': 'Good Afternoon',
      'good_evening': 'Good Evening',
      'brain_health_score': 'Brain Health Score',
      'start_training': 'Start Training',
      'continue_training': 'Continue Training',
      'daily_goal': 'Daily Goal',
      'streak_days': 'Day Streak',
      'today_session': "Today's Session",
      
      // Cognitive Domains
      'cognitive_domains': 'Cognitive Domains',
      'domain_memory': 'Memory',
      'domain_attention': 'Attention',
      'domain_executive': 'Executive Functions',
      'domain_speed': 'Processing Speed',
      'domain_language': 'Language',
      'domain_spatial': 'Visual-Spatial Skills',
      
      // Games
      'games_title': 'Cognitive Games',
      'play_now': 'Play Now',
      'game_memory_match': 'Memory Match',
      'game_memory_match_desc': 'Find the pairs - Train memory',
      'game_number_sequence': 'Number Sequence',
      'game_number_sequence_desc': 'Remember numbers - Working memory',
      'game_stroop': 'Stroop Test',
      'game_stroop_desc': 'Colors and words - Selective attention',
      'game_pattern': 'Pattern Recognition',
      'game_pattern_desc': 'Find patterns - Logical reasoning',
      'game_reaction': 'Reaction Time',
      'game_reaction_desc': 'Quick reflexes - Cognitive speed',
      'game_word_association': 'Word Association',
      'game_word_association_desc': 'Connect words - Semantic memory',
      'game_spatial': 'Spatial Memory',
      'game_spatial_desc': 'Remember positions - Visual-spatial skills',
      
      // Progress
      'progress_title': 'Your Progress',
      'weekly_performance': 'Weekly Performance',
      'monthly_stats': 'Monthly Statistics',
      'achievements': 'Achievements',
      'level': 'Level',
      'points': 'Points',
      'sessions_completed': 'Sessions Completed',
      'avg_score': 'Average Score',
      'best_score': 'Best Score',
      'improvement': 'Improvement',
      
      // Profile
      'profile_title': 'User Profile',
      'profile_settings': 'Settings',
      'profile_info': 'Personal Information',
      'name': 'Name',
      'age': 'Age',
      'start_date': 'Start Date',
      'language': 'Language',
      'theme': 'Theme',
      'text_size': 'Text Size',
      'contrast': 'Contrast',
      'session_duration': 'Session Duration',
      'weekly_frequency': 'Weekly Frequency',
      'reminders': 'Reminders',
      
      // Themes
      'theme_professional': 'Professional',
      'theme_gamified': 'Gamified',
      'theme_minimal': 'Minimal',
      
      // Text Sizes
      'text_normal': 'Normal',
      'text_large': 'Large',
      'text_extra_large': 'Extra Large',
      
      // Contrast
      'contrast_standard': 'Standard',
      'contrast_high': 'High Contrast',
      
      // Common Buttons
      'save': 'Save',
      'cancel': 'Cancel',
      'continue': 'Continue',
      'back': 'Back',
      'next': 'Next',
      'finish': 'Finish',
      'skip': 'Skip',
      'retry': 'Retry',
      
      // Messages
      'loading': 'Loading...',
      'no_data': 'No data available',
      'error': 'Error',
      'success': 'Success',
      'saved_successfully': 'Saved successfully',
      
      // Assessment
      'initial_assessment': 'Initial Assessment',
      'assessment_intro': 'Let\'s start with a brief assessment to personalize your journey',
      'assessment_complete': 'Assessment Complete',
      'your_profile_ready': 'Your profile is ready',
      
      // Difficulty
      'difficulty_easy': 'Easy',
      'difficulty_medium': 'Medium',
      'difficulty_hard': 'Hard',
      'difficulty_expert': 'Expert',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['it', 'en', 'es', 'fr', 'de'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
