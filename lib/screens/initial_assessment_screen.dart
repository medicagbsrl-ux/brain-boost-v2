import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/assessment_service.dart';
import '../models/assessment_result.dart';
import '../providers/user_profile_provider.dart';
import 'dart:math';

/// Schermata Assessment Iniziale Certificato
class InitialAssessmentScreen extends StatefulWidget {
  const InitialAssessmentScreen({super.key});

  @override
  State<InitialAssessmentScreen> createState() => _InitialAssessmentScreenState();
}

class _InitialAssessmentScreenState extends State<InitialAssessmentScreen> {
  final AssessmentService _assessmentService = AssessmentService();
  
  int _currentTestIndex = 0;
  bool _showInstructions = true;
  bool _testInProgress = false;
  bool _assessmentCompleted = false;
  
  // Risultati test (raw scores 0-100)
  final Map<AssessmentTestType, double> _testResults = {};
  
  // Test corrente
  late List<AssessmentTest> _allTests;
  
  // Simulazione test in corso
  int _currentTrialNumber = 0;
  int _totalTrials = 10;
  double _currentTestScore = 0;

  @override
  void initState() {
    super.initState();
    _allTests = _assessmentService.getAllTests();
  }

  @override
  Widget build(BuildContext context) {
    if (_assessmentCompleted) {
      return _buildCompletionScreen();
    }

    final currentTest = _allTests[_currentTestIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment Cognitivo Certificato'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _showInstructions
          ? _buildInstructionsView(currentTest)
          : _buildTestView(currentTest),
    );
  }

  /// Vista istruzioni test
  Widget _buildInstructionsView(AssessmentTest test) {
    final progress = (_currentTestIndex + 1) / _allTests.length;
    
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Test ${_currentTestIndex + 1} di ${_allTests.length}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey[300],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Icona dominio
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _getDomainColor(test.domain).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _getDomainIcon(test.domain),
                size: 40,
                color: _getDomainColor(test.domain),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Nome test
            Text(
              test.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Descrizione
            Text(
              test.description,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Durata
            Row(
              children: [
                Icon(Icons.timer_outlined, size: 20, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Durata: ${test.durationMinutes} minuti',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Istruzioni
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      Text(
                        'Istruzioni',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...test.instructions.map((instruction) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: Colors.blue[700],
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            instruction,
                            style: const TextStyle(fontSize: 16, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Pulsante inizia
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _startTest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Inizia il Test',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Vista esecuzione test (simulata)
  Widget _buildTestView(AssessmentTest test) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        test.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Prova $_currentTrialNumber di $_totalTrials',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                CircularProgressIndicator(
                  value: _currentTrialNumber / _totalTrials,
                  backgroundColor: Colors.grey[300],
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Area test (simulazione)
            Expanded(
              child: Center(
                child: _testInProgress
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getDomainIcon(test.domain),
                            size: 100,
                            color: _getDomainColor(test.domain),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Test in corso...',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Simulazione prova $_currentTrialNumber',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 32),
                          const CircularProgressIndicator(),
                        ],
                      )
                    : ElevatedButton.icon(
                        onPressed: _simulateTestTrial,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Esegui Prova'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Vista completamento assessment
  Widget _buildCompletionScreen() {
    final profile = Provider.of<UserProfileProvider>(context, listen: false);
    final userAge = profile.currentProfile?.age ?? 65;
    
    // Calcola punteggi normalizzati per dominio
    final Map<String, double> domainScores = {};
    final Map<String, Map<String, double>> testsByDomain = {
      'memory': {},
      'attention': {},
      'executive': {},
      'speed': {},
      'language': {},
      'spatial': {},
    };

    // Raggruppa test per dominio e calcola punteggi normativi
    _testResults.forEach((testType, rawScore) {
      final test = _allTests.firstWhere((t) => t.type == testType);
      final normativeScore = _assessmentService.calculateNormativeScore(
        testType: testType,
        rawScore: rawScore,
        userAge: userAge,
      );
      
      testsByDomain[test.domain]![test.name] = normativeScore;
    });

    // Media per dominio
    testsByDomain.forEach((domain, tests) {
      if (tests.isNotEmpty) {
        domainScores[domain] = tests.values.reduce((a, b) => a + b) / tests.length;
      }
    });

    // Calcola Brain Boost Score complessivo (media semplice per ora)
    final overallScore = domainScores.values.isEmpty
        ? 0.0
        : domainScores.values.reduce((a, b) => a + b) / domainScores.length;
    
    // Determina domini forti e deboli
    final strongDomains = domainScores.entries
        .where((e) => e.value >= 70)
        .map((e) => e.key)
        .toList();
    
    final weakDomains = domainScores.entries
        .where((e) => e.value < 60)
        .map((e) => e.key)
        .toList();
    
    // Calcola livelli per dominio
    final domainLevels = domainScores.map((k, v) => MapEntry(k, _getDomainLevelInt(v)));
    
    // Determina profilo cognitivo
    final cognitiveProfile = overallScore >= 75
        ? 'above_average'
        : overallScore >= 60
            ? 'average'
            : 'below_average';
    
    // Genera raccomandazioni per dominio
    final recommendationsMap = <String, String>{};
    weakDomains.forEach((domain) {
      recommendationsMap[domain] = _getRecommendationForDomain(domain);
    });
    
    // Crea AssessmentResult
    final result = AssessmentResult(
      id: 'assessment_${DateTime.now().millisecondsSinceEpoch}',
      userId: profile.currentProfile!.id,
      completedAt: DateTime.now(),
      assessmentType: 'initial',
      domainScores: domainScores,
      domainLevels: domainLevels,
      overallScore: overallScore,
      cognitiveProfile: cognitiveProfile,
      strongDomains: strongDomains,
      weakDomains: weakDomains,
      recommendations: recommendationsMap,
      ageNormalizedScore: overallScore.toInt(),
      certified: true,
    );

    // Genera certificato
    final certificate = _assessmentService.generateCertificate(
      userId: profile.currentProfile!.id,
      userName: profile.currentProfile!.name,
      result: result,
    );

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Icona successo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 80,
                  color: Colors.green,
                ),
              ),
              
              const SizedBox(height: 24),
              
              Text(
                'Assessment Completato!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Brain Boost Score
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Brain Boost Score',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      overallScore.toStringAsFixed(0),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getScoreLevel(overallScore),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Percentile: ${_getPercentile(overallScore, userAge)}°',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Punteggi per dominio
              ...domainScores.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildDomainScoreCard(entry.key, entry.value),
                );
              }),
              
              const SizedBox(height: 24),
              
              // Certificato
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.verified, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Certificato Digitale Generato',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      certificate.split('\n').take(10).join('\n') + '\n...',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Pulsanti
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // Salva risultato
                    await _assessmentService.saveAssessmentResult(result);
                    
                    if (context.mounted) {
                      // Torna alla home
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Assessment salvato con successo!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Salva e Continua'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDomainScoreCard(String domain, double score) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getDomainColor(domain).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getDomainIcon(domain),
              color: _getDomainColor(domain),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getDomainName(domain),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: score / 100,
                    minHeight: 6,
                    backgroundColor: Colors.grey[300],
                    color: _getDomainColor(domain),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '${score.toStringAsFixed(0)}/100',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  void _startTest() {
    setState(() {
      _showInstructions = false;
      _currentTrialNumber = 0;
      _totalTrials = 10;
    });
  }

  void _simulateTestTrial() async {
    setState(() {
      _testInProgress = true;
    });

    // Simula esecuzione prova (1-2 secondi)
    await Future.delayed(Duration(milliseconds: 1000 + Random().nextInt(1000)));

    setState(() {
      _currentTrialNumber++;
      _testInProgress = false;
      
      // Accumula punteggio (random per simulazione)
      _currentTestScore += 60 + Random().nextDouble() * 40;
    });

    // Se completate tutte le prove
    if (_currentTrialNumber >= _totalTrials) {
      _completeTest();
    }
  }

  void _completeTest() {
    final currentTest = _allTests[_currentTestIndex];
    final avgScore = _currentTestScore / _totalTrials;
    
    // Salva risultato test
    _testResults[currentTest.type] = avgScore;

    // Passa al test successivo o completa assessment
    if (_currentTestIndex < _allTests.length - 1) {
      setState(() {
        _currentTestIndex++;
        _showInstructions = true;
        _currentTestScore = 0;
      });
    } else {
      setState(() {
        _assessmentCompleted = true;
      });
    }
  }

  Color _getDomainColor(String domain) {
    switch (domain) {
      case 'memory':
        return Colors.purple;
      case 'attention':
        return Colors.orange;
      case 'executive':
        return Colors.blue;
      case 'speed':
        return Colors.green;
      case 'language':
        return Colors.pink;
      case 'spatial':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getDomainIcon(String domain) {
    switch (domain) {
      case 'memory':
        return Icons.psychology;
      case 'attention':
        return Icons.visibility;
      case 'executive':
        return Icons.functions;
      case 'speed':
        return Icons.speed;
      case 'language':
        return Icons.chat_bubble;
      case 'spatial':
        return Icons.aspect_ratio;
      default:
        return Icons.star;
    }
  }

  String _getDomainName(String domain) {
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

  int _getDomainLevelInt(double score) {
    if (score >= 90) return 10;
    if (score >= 80) return 9;
    if (score >= 70) return 8;
    if (score >= 60) return 7;
    if (score >= 50) return 6;
    if (score >= 40) return 5;
    if (score >= 30) return 4;
    if (score >= 20) return 3;
    if (score >= 10) return 2;
    return 1;
  }

  String _getRecommendationForDomain(String domain) {
    const recommendations = {
      'memory': 'Allenamento intensivo MEMORIA: 30 min/giorno con Memory Match',
      'attention': 'Allenamento intensivo ATTENZIONE: esercizi quotidiani Stroop',
      'executive': 'Allenamento intensivo FUNZIONI ESECUTIVE: giochi di strategia',
      'speed': 'Allenamento intensivo VELOCIT\u00c0: esercizi tempo di reazione',
      'language': 'Allenamento intensivo LINGUAGGIO: giochi di parole',
      'spatial': 'Allenamento intensivo ABILIT\u00c0 SPAZIALI: esercizi di rotazione',
    };
    return recommendations[domain] ?? 'Continua l\'allenamento';
  }

  String _getScoreLevel(double score) {
    if (score >= 90) return 'Eccellente';
    if (score >= 80) return 'Molto Buono';
    if (score >= 70) return 'Buono';
    if (score >= 60) return 'Discreto';
    if (score >= 50) return 'Sufficiente';
    return 'Da Migliorare';
  }

  int _getPercentile(double score, int age) {
    // Semplificato: basato solo su score
    if (score >= 90) return 95;
    if (score >= 80) return 85;
    if (score >= 70) return 70;
    if (score >= 60) return 50;
    if (score >= 50) return 30;
    if (score >= 40) return 15;
    return 5;
  }
}
