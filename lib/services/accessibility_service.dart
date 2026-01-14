import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Servizio Text-to-Speech per accessibilità
/// Fornisce supporto vocale per senior e ipovedenti
class AccessibilityService {
  static final AccessibilityService _instance = AccessibilityService._internal();
  factory AccessibilityService() => _instance;
  AccessibilityService._internal() {
    _initTTS();
  }

  final FlutterTts _tts = FlutterTts();
  bool _isEnabled = false;
  bool _isInitialized = false;
  double _speechRate = 0.5; // Velocità parlato (0.0 - 1.0, default 0.5 per senior)
  double _pitch = 1.0;
  double _volume = 1.0;

  Future<void> _initTTS() async {
    try {
      // Configura TTS
      await _tts.setLanguage('it-IT');
      await _tts.setSpeechRate(_speechRate);
      await _tts.setPitch(_pitch);
      await _tts.setVolume(_volume);
      
      _isInitialized = true;
      
      if (kDebugMode) {
        print('✅ Text-to-Speech inizializzato');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Errore inizializzazione TTS: $e');
      }
    }
  }

  /// Abilita/disabilita TTS
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    if (kDebugMode) {
      print('🔊 TTS ${enabled ? "abilitato" : "disabilitato"}');
    }
  }

  /// Parla un testo
  Future<void> speak(String text, {bool force = false}) async {
    if (!_isInitialized) await _initTTS();
    
    if (!_isEnabled && !force) return;
    
    try {
      await _tts.speak(text);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Errore TTS speak: $e');
      }
    }
  }

  /// Ferma il parlato
  Future<void> stop() async {
    await _tts.stop();
  }

  /// Imposta velocità parlato (0.0 = molto lento, 1.0 = veloce)
  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate.clamp(0.1, 1.0);
    await _tts.setSpeechRate(_speechRate);
  }

  /// Imposta pitch voce (0.5 = basso, 2.0 = alto)
  Future<void> setPitch(double pitch) async {
    _pitch = pitch.clamp(0.5, 2.0);
    await _tts.setPitch(_pitch);
  }

  /// Imposta volume (0.0 = silenzio, 1.0 = massimo)
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _tts.setVolume(_volume);
  }

  /// Annuncia punteggio
  Future<void> announceScore(double score) async {
    await speak('Punteggio: ${score.toStringAsFixed(0)}');
  }

  /// Annuncia progresso
  Future<void> announceProgress(String message) async {
    await speak(message);
  }

  /// Annuncia istruzioni gioco
  Future<void> announceGameInstructions(String gameName, List<String> instructions) async {
    await speak('Gioco: $gameName');
    await Future.delayed(const Duration(seconds: 1));
    
    for (int i = 0; i < instructions.length; i++) {
      await speak('Istruzione ${i + 1}: ${instructions[i]}');
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  /// Annuncia feedback positivo
  Future<void> announcePositiveFeedback() async {
    final feedbacks = [
      'Ottimo lavoro!',
      'Eccellente!',
      'Continua così!',
      'Molto bene!',
    ];
    final feedback = feedbacks[DateTime.now().millisecond % feedbacks.length];
    await speak(feedback);
  }

  /// Annuncia feedback negativo (gentile)
  Future<void> announceNegativeFeedback() async {
    final feedbacks = [
      'Non preoccuparti, riprova',
      'Quasi! Riprova',
      'Proviamo di nuovo',
      'Puoi farcela!',
    ];
    final feedback = feedbacks[DateTime.now().millisecond % feedbacks.length];
    await speak(feedback);
  }

  /// Annuncia completamento sessione
  Future<void> announceSessionComplete(double score, double accuracy) async {
    await speak('Sessione completata!');
    await Future.delayed(const Duration(seconds: 1));
    await speak('Punteggio finale: ${score.toStringAsFixed(0)}');
    await Future.delayed(const Duration(milliseconds: 500));
    await speak('Precisione: ${accuracy.toStringAsFixed(0)} percento');
  }

  /// Annuncia navigazione schermo
  Future<void> announceScreenNavigation(String screenName) async {
    await speak('Schermata: $screenName');
  }

  /// Annuncia pulsante
  Future<void> announceButton(String buttonLabel) async {
    await speak('Pulsante: $buttonLabel');
  }

  /// Verifica se TTS è abilitato
  bool get isEnabled => _isEnabled;
  
  /// Ottieni velocità corrente
  double get speechRate => _speechRate;
  
  /// Ottieni pitch corrente
  double get pitch => _pitch;
  
  /// Ottieni volume corrente
  double get volume => _volume;
}
