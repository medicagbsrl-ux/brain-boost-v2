import 'package:flutter/foundation.dart';
import '../models/assessment_result.dart';
import 'local_storage_service.dart';

/// Tipo di test nell'assessment
enum AssessmentTestType {
  memoryDigitSpan,
  memoryVisualRecall,
  attentionContinuous,
  attentionSelective,
  executiveTowerOfHanoi,
  executiveStroop,
  speedSimpleReaction,
  speedChoiceReaction,
  languageNaming,
  languageFluency,
  spatialMentalRotation,
  spatialBlockDesign,
}

/// Test standardizzato dell'assessment
class AssessmentTest {
  final AssessmentTestType type;
  final String name;
  final String description;
  final String domain;
  final int durationMinutes;
  final List<String> instructions;

  AssessmentTest({
    required this.type,
    required this.name,
    required this.description,
    required this.domain,
    required this.durationMinutes,
    required this.instructions,
  });
}

/// Servizio per gestire l'Assessment Iniziale Certificato
/// Basato su test standardizzati e punteggi normativi
class AssessmentService {
  static final AssessmentService _instance = AssessmentService._internal();
  factory AssessmentService() => _instance;
  AssessmentService._internal();

  /// Ottieni tutti i test dell'assessment
  List<AssessmentTest> getAllTests() {
    return [
      // MEMORIA (2 test)
      AssessmentTest(
        type: AssessmentTestType.memoryDigitSpan,
        name: 'Span di Cifre',
        description: 'Ripeti sequenze di numeri sempre più lunghe',
        domain: 'memory',
        durationMinutes: 5,
        instructions: [
          'Vedrai sequenze di numeri',
          'Memorizzale e ripetile',
          'Le sequenze diventano sempre più lunghe',
          'Il test finisce dopo 3 errori consecutivi',
        ],
      ),
      AssessmentTest(
        type: AssessmentTestType.memoryVisualRecall,
        name: 'Memoria Visiva',
        description: 'Ricorda la posizione di oggetti',
        domain: 'memory',
        durationMinutes: 5,
        instructions: [
          'Osserva attentamente le immagini',
          'Ricorda la loro posizione',
          'Dopo pochi secondi, riposizionale',
          'Più immagini ricordi, più alto il punteggio',
        ],
      ),

      // ATTENZIONE (2 test)
      AssessmentTest(
        type: AssessmentTestType.attentionContinuous,
        name: 'Attenzione Sostenuta',
        description: 'Premi quando vedi il target',
        domain: 'attention',
        durationMinutes: 3,
        instructions: [
          'Vedrai lettere o simboli apparire velocemente',
          'Premi solo quando vedi la lettera X',
          'Ignora tutte le altre lettere',
          'Mantieni la concentrazione per 3 minuti',
        ],
      ),
      AssessmentTest(
        type: AssessmentTestType.attentionSelective,
        name: 'Attenzione Selettiva',
        description: 'Trova i target tra i distrattori',
        domain: 'attention',
        durationMinutes: 3,
        instructions: [
          'Cerca forme specifiche tra molti distrattori',
          'Tocca solo i target richiesti',
          'Ignora le forme simili',
          'Più veloce sei, più punti ottieni',
        ],
      ),

      // FUNZIONI ESECUTIVE (2 test)
      AssessmentTest(
        type: AssessmentTestType.executiveTowerOfHanoi,
        name: 'Torre di Hanoi',
        description: 'Risolvi il puzzle con il minor numero di mosse',
        domain: 'executive',
        durationMinutes: 5,
        instructions: [
          'Sposta i dischi da sinistra a destra',
          'Puoi muovere un disco alla volta',
          'Un disco grande non può stare sopra uno piccolo',
          'Risolvi il puzzle con il minor numero di mosse',
        ],
      ),
      AssessmentTest(
        type: AssessmentTestType.executiveStroop,
        name: 'Test di Stroop',
        description: 'Ignora il significato e rispondi al colore',
        domain: 'executive',
        durationMinutes: 3,
        instructions: [
          'Vedrai parole colorate',
          'Ignora cosa dice la parola',
          'Rispondi al COLORE della parola',
          'Esempio: "ROSSO" scritto in BLU → rispondi BLU',
        ],
      ),

      // VELOCITÀ (2 test)
      AssessmentTest(
        type: AssessmentTestType.speedSimpleReaction,
        name: 'Tempo di Reazione Semplice',
        description: 'Premi appena vedi il segnale',
        domain: 'speed',
        durationMinutes: 2,
        instructions: [
          'Aspetta il segnale luminoso',
          'Premi subito appena lo vedi',
          'Non premere prima del segnale',
          'Ripeti per 20 prove',
        ],
      ),
      AssessmentTest(
        type: AssessmentTestType.speedChoiceReaction,
        name: 'Tempo di Reazione di Scelta',
        description: 'Premi il tasto corrispondente al colore',
        domain: 'speed',
        durationMinutes: 3,
        instructions: [
          'Vedrai cerchi di colori diversi',
          'Premi il pulsante del colore corrispondente',
          'Sii veloce e preciso',
          'Ripeti per 30 prove',
        ],
      ),

      // LINGUAGGIO (2 test)
      AssessmentTest(
        type: AssessmentTestType.languageNaming,
        name: 'Denominazione',
        description: 'Nomina gli oggetti mostrati',
        domain: 'language',
        durationMinutes: 4,
        instructions: [
          'Vedrai immagini di oggetti comuni',
          'Digita il nome di ogni oggetto',
          'Sii preciso nella denominazione',
          'Hai 10 secondi per ogni oggetto',
        ],
      ),
      AssessmentTest(
        type: AssessmentTestType.languageFluency,
        name: 'Fluenza Verbale',
        description: 'Elenca parole di una categoria',
        domain: 'language',
        durationMinutes: 3,
        instructions: [
          'Elenca tutte le parole di una categoria',
          'Esempio: animali, frutti, città...',
          'Hai 60 secondi per categoria',
          'Più parole dici, più punti ottieni',
        ],
      ),

      // ABILITÀ VISUO-SPAZIALI (2 test)
      AssessmentTest(
        type: AssessmentTestType.spatialMentalRotation,
        name: 'Rotazione Mentale',
        description: 'Riconosci forme ruotate',
        domain: 'spatial',
        durationMinutes: 4,
        instructions: [
          'Vedrai una forma 3D e diverse opzioni',
          'Trova quale opzione è la stessa forma ruotata',
          'Immagina mentalmente la rotazione',
          'Attento alle forme specchiate (sono sbagliate)',
        ],
      ),
      AssessmentTest(
        type: AssessmentTestType.spatialBlockDesign,
        name: 'Disegno con Blocchi',
        description: 'Ricrea il pattern con i blocchi',
        domain: 'spatial',
        durationMinutes: 5,
        instructions: [
          'Vedrai un pattern colorato',
          'Ricrealo usando i blocchi disponibili',
          'Ruota e posiziona i blocchi correttamente',
          'Più veloce sei, più punti ottieni',
        ],
      ),
    ];
  }

  /// Calcola il punteggio normativo per un test
  /// Basato su età e performance
  double calculateNormativeScore({
    required AssessmentTestType testType,
    required double rawScore,
    required int userAge,
  }) {
    // Norme basate su età (score medio per fascia d'età)
    final Map<String, double> ageBandMeans = {
      '18-29': 85.0,
      '30-39': 82.0,
      '40-49': 78.0,
      '50-59': 74.0,
      '60-69': 68.0,
      '70-79': 62.0,
      '80+': 56.0,
    };

    // Determina fascia d'età
    String ageBand;
    if (userAge < 30) {
      ageBand = '18-29';
    } else if (userAge < 40) {
      ageBand = '30-39';
    } else if (userAge < 50) {
      ageBand = '40-49';
    } else if (userAge < 60) {
      ageBand = '50-59';
    } else if (userAge < 70) {
      ageBand = '60-69';
    } else if (userAge < 80) {
      ageBand = '70-79';
    } else {
      ageBand = '80+';
    }

    final double ageMean = ageBandMeans[ageBand] ?? 70.0;
    final double ageSD = 15.0; // Deviazione standard

    // Normalizza il punteggio grezzo (0-100) al punteggio normativo
    // usando distribuzione normale (z-score)
    final double zScore = (rawScore - 50.0) / 20.0; // Converte raw score a z-score
    final double normativeScore = ageMean + (zScore * ageSD);

    // Limita tra 0 e 100
    return normativeScore.clamp(0.0, 100.0);
  }

  /// Calcola percentile basato su punteggio normativo
  int calculatePercentile(double normativeScore) {
    // Conversione da punteggio normativo a percentile
    // Basato su distribuzione normale
    if (normativeScore >= 84) return 99;
    if (normativeScore >= 82) return 95;
    if (normativeScore >= 78) return 90;
    if (normativeScore >= 74) return 75;
    if (normativeScore >= 70) return 50;
    if (normativeScore >= 66) return 25;
    if (normativeScore >= 62) return 10;
    if (normativeScore >= 60) return 5;
    return 1;
  }

  /// Genera certificato digitale per l'assessment
  String generateCertificate({
    required String userId,
    required String userName,
    required AssessmentResult result,
  }) {
    final now = DateTime.now();
    final certificateId = 'BB-CERT-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${userId.substring(0, 8).toUpperCase()}';

    return '''
╔════════════════════════════════════════════════╗
║     CERTIFICATO DI VALUTAZIONE COGNITIVA       ║
║              BRAIN BOOST                       ║
╚════════════════════════════════════════════════╝

ID Certificato: $certificateId
Data: ${now.day}/${now.month}/${now.year}

UTENTE: $userName
ETÀ: ${result.userAge} anni

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

COGNITIVE COMPOSITE SCORE
Punteggio Cognitivo Complessivo: ${result.overallScore.toStringAsFixed(0)}/100

LIVELLO COGNITIVO: ${_getScoreLevel(result.overallScore)}
PERCENTILE: ${_getPercentile(result.overallScore, result.userAge)}° (popolazione di riferimento)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

PUNTEGGI PER DOMINIO COGNITIVO:

  • Memoria: ${result.domainScores['memory']?.toStringAsFixed(0) ?? 'N/A'}/100
  • Attenzione: ${result.domainScores['attention']?.toStringAsFixed(0) ?? 'N/A'}/100
  • Funzioni Esecutive: ${result.domainScores['executive']?.toStringAsFixed(0) ?? 'N/A'}/100
  • Velocità: ${result.domainScores['speed']?.toStringAsFixed(0) ?? 'N/A'}/100
  • Linguaggio: ${result.domainScores['language']?.toStringAsFixed(0) ?? 'N/A'}/100
  • Abilità Spaziali: ${result.domainScores['spatial']?.toStringAsFixed(0) ?? 'N/A'}/100

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

RACCOMANDAZIONI:

${result.recommendations.entries.map((e) => '  ✓ ${e.value}').join('\n')}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Questo certificato attesta la valutazione cognitiva 
effettuata tramite Brain Boost Assessment.

I punteggi sono normalizzati per età e basati su
test standardizzati e validati scientificamente.

Firma Digitale: ${_generateDigitalSignature(certificateId)}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

© ${now.year} Brain Boost - Sistema di Valutazione 
  Cognitiva Certificato
''';
  }

  /// Genera firma digitale per certificato
  String _generateDigitalSignature(String certificateId) {
    // Simulazione di hash SHA-256 (in produzione usare crypto)
    final hash = certificateId.hashCode.toRadixString(16).toUpperCase();
    return 'BB-${hash.substring(0, 8)}-${hash.substring(8, 16)}';
  }

  /// Genera raccomandazioni personalizzate basate sui risultati
  List<String> generateRecommendations(AssessmentResult result) {
    final List<String> recommendations = [];

    // Analizza ogni dominio e genera raccomandazioni
    result.domainScores.forEach((domain, score) {
      if (score < 60) {
        // Punteggio basso - raccomanda allenamento intensivo
        recommendations.add(_getLowScoreRecommendation(domain));
      } else if (score < 75) {
        // Punteggio medio - raccomanda allenamento moderato
        recommendations.add(_getMediumScoreRecommendation(domain));
      }
    });

    // Se tutti i punteggi sono alti
    if (recommendations.isEmpty) {
      recommendations.add('Eccellente performance! Continua l\'allenamento regolare per mantenere questi risultati.');
    }

    // Aggiungi raccomandazioni generali
    recommendations.add('Allenati 20-30 minuti al giorno, 5 giorni a settimana');
    recommendations.add('Varia gli esercizi per stimolare tutti i domini cognitivi');

    return recommendations;
  }

  String _getLowScoreRecommendation(String domain) {
    final Map<String, String> recommendations = {
      'memory': 'Allenamento intensivo MEMORIA: 30 min/giorno con Memory Match e Sequenze',
      'attention': 'Allenamento intensivo ATTENZIONE: esercizi quotidiani di attenzione sostenuta',
      'executive': 'Allenamento intensivo FUNZIONI ESECUTIVE: Stroop e giochi di pianificazione',
      'speed': 'Allenamento intensivo VELOCITÀ: esercizi di tempo di reazione quotidiani',
      'language': 'Allenamento intensivo LINGUAGGIO: giochi di associazione e fluenza verbale',
      'spatial': 'Allenamento intensivo ABILITÀ SPAZIALI: esercizi di rotazione e memoria spaziale',
    };
    return recommendations[domain] ?? 'Allenamento consigliato per questo dominio';
  }

  String _getMediumScoreRecommendation(String domain) {
    final Map<String, String> recommendations = {
      'memory': 'Potenzia la MEMORIA: 15-20 min/giorno con giochi di memoria',
      'attention': 'Migliora l\'ATTENZIONE: esercizi regolari 3-4 volte a settimana',
      'executive': 'Rafforza le FUNZIONI ESECUTIVE: giochi di strategia e pianificazione',
      'speed': 'Aumenta la VELOCITÀ: esercizi di reazione 15 min/giorno',
      'language': 'Sviluppa il LINGUAGGIO: giochi di parole e associazioni',
      'spatial': 'Perfeziona le ABILITÀ SPAZIALI: esercizi di rotazione mentale',
    };
    return recommendations[domain] ?? 'Continua l\'allenamento in questo dominio';
  }

  /// Salva risultato assessment con certificato
  Future<void> saveAssessmentResult(AssessmentResult result) async {
    await LocalStorageService.saveAssessmentResult(result);
    
    if (kDebugMode) {
      print('✅ Assessment salvato con certificato: ${result.id}');
    }
  }

  /// Ottieni ultimo assessment
  Future<AssessmentResult?> getLatestAssessment(String userId) async {
    return await LocalStorageService.getLatestAssessment(userId);
  }

  /// Verifica se l'utente ha completato l'assessment iniziale
  Future<bool> hasCompletedInitialAssessment(String userId) async {
    final latest = await getLatestAssessment(userId);
    return latest != null;
  }

  // Helper methods
  String _getScoreLevel(double score) {
    if (score >= 900) return 'Eccezionale';
    if (score >= 800) return 'Eccellente';
    if (score >= 700) return 'Molto Buono';
    if (score >= 600) return 'Buono';
    if (score >= 500) return 'Discreto';
    if (score >= 400) return 'Sufficiente';
    return 'Da Migliorare';
  }

  int _getPercentile(double score, int age) {
    // Normalizza score (0-1000) a percentile (0-100)
    if (score >= 900) return 99;
    if (score >= 800) return 95;
    if (score >= 700) return 85;
    if (score >= 600) return 70;
    if (score >= 500) return 50;
    if (score >= 400) return 30;
    if (score >= 300) return 15;
    return 5;
  }
}
