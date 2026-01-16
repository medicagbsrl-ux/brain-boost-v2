import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../providers/user_profile_provider.dart';
import '../l10n/app_localizations.dart';
import '../themes/app_themes.dart';
import '../services/brain_boost_score_service.dart';
import '../services/local_storage_service.dart';
import '../services/report_export_service.dart';
import 'calendar_screen.dart';
import 'initial_assessment_screen.dart';
import 'games_screen.dart';
// Import game widgets
import '../games/memory_match/memory_match_game.dart';
import '../games/stroop_test/stroop_test_game.dart';
import '../games/number_sequence/number_sequence_game.dart';
import '../games/pattern_recognition/pattern_recognition_game.dart';
import '../games/reaction_time/reaction_time_game.dart';
import '../games/word_association/word_association_game.dart';
import '../games/spatial_memory/spatial_memory_game.dart';

class HomeScreen extends StatefulWidget {
  final TabController? tabController;
  
  const HomeScreen({super.key, this.tabController});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Ricarica statistiche quando la home viene visualizzata
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    final provider = Provider.of<UserProfileProvider>(context, listen: false);
    final profile = provider.currentProfile;
    
    if (profile == null) return;
    
    // Store old values for achievement detection
    final oldLevel = profile.currentLevel;
    final oldStreak = profile.streakDays;
    
    // Refresh statistics
    await provider.refreshStatistics();
    
    // Check for achievements
    await provider.checkAchievements(oldLevel, oldStreak);
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<UserProfileProvider>(context);
    final profile = profileProvider.currentProfile;
    final l10n = AppLocalizations.of(context);

    if (profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con saluto
              _buildHeader(context, profile, profileProvider, l10n!),
              const SizedBox(height: 30),

              // Brain Health Score
              _buildBrainHealthScore(context, profile, l10n),
              const SizedBox(height: 24),

              // Stats rapide
              _buildQuickStats(context, profile, l10n),
              const SizedBox(height: 24),

              // Pulsante Start Training
              _buildStartTrainingButton(context, l10n),
              const SizedBox(height: 16),
              
              // Quick Actions
              _buildQuickActions(context, l10n),
              const SizedBox(height: 32),

              // Domini Cognitivi
              _buildCognitiveDomains(context, profile, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    dynamic profile,
    UserProfileProvider provider,
    AppLocalizations l10n,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              provider.getGreeting(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              profile.name,
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            // Naviga alla schermata Profilo
            Navigator.pushNamed(context, '/profile');
          },
          child: CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            child: Icon(
              Icons.person,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBrainHealthScore(
    BuildContext context,
    dynamic profile,
    AppLocalizations l10n,
  ) {
    return FutureBuilder<BrainBoostScore>(
      future: BrainBoostScoreService.calculateScore(profile.id, profile.age),
      builder: (context, snapshot) {
        final score = snapshot.data ?? BrainBoostScore.initial();
        
        return Card(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  score.getScoreColor(),
                  score.getScoreColor().withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'Brain Boost Score',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  score.cognitiveLevel,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: CircularProgressIndicator(
                        value: score.totalScore / 1000,
                        strokeWidth: 12,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          score.totalScore.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          '/1000',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (score.totalSessions > 0)
                  Text(
                    'Percentile: ${score.percentileRank}° | ${score.ageGroup}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickStats(
    BuildContext context,
    dynamic profile,
    AppLocalizations l10n,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            Icons.local_fire_department,
            profile.streakDays.toString(),
            l10n.translate('streak_days'),
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            Icons.emoji_events,
            profile.currentLevel.toString(),
            l10n.translate('level'),
            Colors.amber,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            Icons.stars,
            profile.totalPoints.toString(),
            l10n.translate('points'),
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartTrainingButton(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          // Start AI-powered adaptive training
          if (kDebugMode) {
            print('🚀 DEBUG: Pulsante "Inizia Allenamento" premuto');
          }
          await _startAdaptiveTraining(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow_rounded, size: 28),
            const SizedBox(width: 8),
            Text(
              l10n.translate('start_training'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Azioni Rapide',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: Icons.assessment,
                label: 'Assessment',
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InitialAssessmentScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: Icons.calendar_month,
                label: 'Calendario',
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CalendarScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: Icons.download,
                label: 'Report PDF',
                color: Colors.red,
                onTap: () {
                  _exportPDFReport(context);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: Icons.table_chart,
                label: 'Export CSV',
                color: Colors.orange,
                onTap: () {
                  _exportCSVData(context);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportPDFReport(BuildContext context) async {
    final provider = Provider.of<UserProfileProvider>(context, listen: false);
    final profile = provider.currentProfile;
    
    if (profile == null) return;
    
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 16),
              Text('📄 Generazione PDF in corso...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 30));

      final exportService = ReportExportService.instance;
      await exportService.exportPDFForWeb(
        userId: profile.id,
        userName: profile.name,
        userAge: profile.age,
        startDate: startDate,
        endDate: endDate,
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 16),
              Expanded(child: Text('✅ PDF generato! Controlla i download del browser')),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Errore: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _exportCSVData(BuildContext context) async {
    final provider = Provider.of<UserProfileProvider>(context, listen: false);
    final profile = provider.currentProfile;
    
    if (profile == null) return;
    
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 16),
              Text('📊 Generazione CSV in corso...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 30));

      final exportService = ReportExportService.instance;
      await exportService.exportCSVForWeb(
        userId: profile.id,
        startDate: startDate,
        endDate: endDate,
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 16),
              Expanded(child: Text('✅ CSV generato! Controlla i download del browser')),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Errore: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildCognitiveDomains(
    BuildContext context,
    dynamic profile,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.translate('cognitive_domains'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ...profile.cognitiveScores.entries.map((entry) {
          return _buildDomainCard(context, entry.key, entry.value, l10n);
        }),
      ],
    );
  }

  Widget _buildDomainCard(
    BuildContext context,
    String domain,
    double score,
    AppLocalizations l10n,
  ) {
    final color = AppThemes.cognitiveColors[domain] ?? Colors.blue;
    final domainName = l10n.translate('domain_$domain');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getDomainIcon(domain),
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    domainName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: score / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '${score.toInt()}%',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getDomainIcon(String domain) {
    switch (domain) {
      case 'memory':
        return Icons.lightbulb_outline;
      case 'attention':
        return Icons.visibility_outlined;
      case 'executive':
        return Icons.account_tree_outlined;
      case 'speed':
        return Icons.speed;
      case 'language':
        return Icons.chat_bubble_outline;
      case 'spatial':
        return Icons.view_in_ar_outlined;
      default:
        return Icons.star_outline;
    }
  }

  /// 🤖 AI-POWERED ADAPTIVE TRAINING SYSTEM
  /// Analizza Brain Boost Score e domini cognitivi per creare
  /// un ciclo personalizzato di allenamento
  Future<void> _startAdaptiveTraining(BuildContext context) async {
    final provider = Provider.of<UserProfileProvider>(context, listen: false);
    final profile = provider.currentProfile;
    
    if (profile == null) return;

    // 🔍 CHECK: È il primo utilizzo? (Nessuna sessione completata)
    // Controlla sia sessionsCompleted che lo storico reale
    final sessions = await LocalStorageService.getAllSessionHistory(profile.id);
    final isFirstUse = profile.sessionsCompleted == 0 && sessions.isEmpty;
    
    // Debug in console
    if (kDebugMode) {
      print('🔍 DEBUG Assessment Check:');
      print('   User: ${profile.name} (ID: ${profile.id})');
      print('   SessionsCompleted: ${profile.sessionsCompleted}');
      print('   History Sessions: ${sessions.length}');
      print('   IsFirstUse: $isFirstUse');
    }
    
    // TEMPORANEO: Assessment ha solo mockup, avviamo training diretto
    // TODO: Implementare assessment con giochi veri
    if (isFirstUse) {
      final shouldStart = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.info, color: Colors.blue, size: 28),
              SizedBox(width: 12),
              Text('👋 Primo Allenamento'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Benvenuto in Brain Boost!\n\nPoiché sei un nuovo utente, inizieremo con un allenamento introduttivo a difficoltà media.',
                style: TextStyle(fontSize: 15),
              ),
              SizedBox(height: 16),
              Text(
                'Il sistema si adatterà automaticamente al tuo livello dopo le prime sessioni.',
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('🚀 Inizia'),
            ),
          ],
        ),
      );
      
      if (shouldStart != true) return;
      // Continua con training adattivo normale
    }
    
    if (false) { // DISABILITA assessment vecchio
      // PRIMO UTILIZZO → Proponi Valutazione Iniziale
      final shouldAssess = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.assessment, color: Colors.blue, size: 28),
              SizedBox(width: 12),
              Expanded(child: Text('👋 Benvenuto in Brain Boost!')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Prima di iniziare l\'allenamento personalizzato, ho bisogno di valutare il tuo livello cognitivo attuale.',
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.timer, size: 18, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Durata: 10-15 minuti',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.psychology, size: 18, color: Colors.blue),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '6 test cognitivi brevi',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.insights, size: 18, color: Colors.blue),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Profilo cognitivo personalizzato',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '📊 La valutazione iniziale mi permetterà di:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              const Text('• Calcolare il tuo Brain Boost Score'),
              const Text('• Identificare i tuoi punti di forza'),
              const Text('• Creare allenamenti personalizzati'),
              const Text('• Adattare la difficoltà dei giochi'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Salta'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('🚀 Inizia Valutazione'),
            ),
          ],
        ),
      );

      if (shouldAssess == true) {
        // Naviga a Initial Assessment
        if (!mounted) return;
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const InitialAssessmentScreen(),
          ),
        );
        
        // Dopo assessment, refresh e riavvia training
        if (!mounted) return;
        await provider.refreshStatistics();
        
        // Mostra congratulazioni
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Text('🎉'),
                SizedBox(width: 8),
                Text('Valutazione Completata!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Ottimo lavoro! Ora posso creare allenamenti personalizzati per te.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle, size: 48, color: Colors.green),
                      const SizedBox(height: 8),
                      Text(
                        'Brain Boost Score: ${profile.totalPoints}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ora premi "Inizia Allenamento" per il tuo primo ciclo personalizzato!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Perfetto!'),
              ),
            ],
          ),
        );
        
        return; // Non avviare training, utente vedrà nuovo Brain Boost Score
      } else {
        // Utente ha saltato → usa valori default e continua
        // (opzionale: potremmo impedire training senza assessment)
      }
    }

    // Step 1: Analyze cognitive domains
    final cognitiveScores = profile.cognitiveScores;
    
    // Step 2: Identify weakest domains (priorità AI)
    final sortedDomains = cognitiveScores.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    
    final weakestDomains = sortedDomains.take(3).map((e) => e.key).toList();
    
    // Step 3: Build adaptive game sequence
    final adaptiveSequence = _buildAdaptiveSequence(
      weakestDomains: weakestDomains,
      currentLevel: profile.currentLevel,
      brainBoostScore: profile.totalPoints,
    );

    // Step 4: Show training plan dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.psychology, color: Colors.purple, size: 28),
            SizedBox(width: 12),
            Text('🧠 Allenamento Personalizzato'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ho analizzato il tuo Brain Boost Score e preparato un ciclo adattivo per te:',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.timer, size: 18, color: Colors.purple),
                      const SizedBox(width: 8),
                      Text(
                        'Durata: ${adaptiveSequence.length * 2}-${adaptiveSequence.length * 3} minuti',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.fitness_center, size: 18, color: Colors.purple),
                      const SizedBox(width: 8),
                      Text(
                        '${adaptiveSequence.length} giochi personalizzati',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.trending_up, size: 18, color: Colors.purple),
                      const SizedBox(width: 8),
                      Text(
                        'Focus: ${_getDomainName(weakestDomains.first)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('📋 Sequenza giochi:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...adaptiveSequence.asMap().entries.map((entry) {
              final index = entry.key;
              final game = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        game['name'],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getDomainColor(game['domain']).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Lv.${game['level']}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getDomainColor(game['domain']),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            child: const Text('🚀 Inizia Ora'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Step 5: Start training sequence
    if (!mounted) return;
    await _executeTrainingSequence(context, adaptiveSequence);
  }

  /// Costruisce sequenza adattiva basata su AI
  List<Map<String, dynamic>> _buildAdaptiveSequence({
    required List<String> weakestDomains,
    required int currentLevel,
    required int brainBoostScore,
  }) {
    // Mappa giochi per dominio
    final gamesByDomain = {
      'memory': ['memory_match', 'number_sequence', 'spatial_memory'],
      'attention': ['stroop_test', 'reaction_time'],
      'executive': ['pattern_recognition', 'word_association'],
      'speed': ['reaction_time', 'stroop_test'],
      'language': ['word_association'],
      'spatial': ['spatial_memory', 'pattern_recognition'],
    };

    final gameNames = {
      'memory_match': 'Memory Match - Trova le Coppie',
      'stroop_test': 'Test di Stroop',
      'number_sequence': 'Sequenze Numeriche',
      'pattern_recognition': 'Riconoscimento Pattern',
      'reaction_time': 'Tempo di Reazione',
      'word_association': 'Associazione Parole',
      'spatial_memory': 'Memoria Spaziale',
    };

    final sequence = <Map<String, dynamic>>[];
    final usedGames = <String>{};

    // Calcola livello adattivo (basato su Brain Boost Score)
    final adaptiveLevel = (brainBoostScore / 500).floor().clamp(1, 5);

    // Aggiungi 1-2 giochi per ogni dominio debole
    for (final domain in weakestDomains) {
      final domainGames = gamesByDomain[domain] ?? [];
      
      for (final gameId in domainGames) {
        if (usedGames.contains(gameId)) continue;
        if (sequence.length >= 5) break; // Max 5 giochi
        
        sequence.add({
          'id': gameId,
          'name': gameNames[gameId] ?? gameId,
          'domain': domain,
          'level': adaptiveLevel,
        });
        usedGames.add(gameId);
        
        if (sequence.length >= 2) break; // Max 2 per dominio
      }
    }

    // Se meno di 3 giochi, aggiungi giochi generici
    if (sequence.length < 3) {
      final defaultGames = ['memory_match', 'stroop_test', 'reaction_time'];
      for (final gameId in defaultGames) {
        if (usedGames.contains(gameId)) continue;
        if (sequence.length >= 5) break;
        
        sequence.add({
          'id': gameId,
          'name': gameNames[gameId] ?? gameId,
          'domain': 'memory',
          'level': adaptiveLevel,
        });
        usedGames.add(gameId);
      }
    }

    return sequence;
  }

  /// Esegue la sequenza di allenamento
  Future<void> _executeTrainingSequence(
    BuildContext context,
    List<Map<String, dynamic>> sequence,
  ) async {
    final provider = Provider.of<UserProfileProvider>(context, listen: false);
    final userId = provider.currentProfile?.id ?? '';

    int completedGames = 0;
    int totalXP = 0;

    for (final game in sequence) {
      if (!mounted) return;

      // Naviga al gioco
      final result = await _navigateToGame(context, game['id'] as String, game['level'] as int, userId);
      
      if (result == null) break; // User canceled
      
      completedGames++;
      totalXP += (result['xp'] as num).toInt();
    }

    // Show completion dialog
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Text('🎉'),
            SizedBox(width: 8),
            Text('Sessione Completata!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Hai completato $completedGames/${sequence.length} giochi',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.stars, size: 48, color: Colors.amber),
                  const SizedBox(height: 8),
                  Text(
                    '+$totalXP XP',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Refresh statistics
              provider.refreshStatistics();
            },
            child: const Text('Chiudi'),
          ),
        ],
      ),
    );
  }

  /// Naviga a un gioco specifico
  Future<Map<String, dynamic>?> _navigateToGame(
    BuildContext context,
    String gameId,
    int level,
    String userId,
  ) async {
    // Navigate to game and get result
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: SafeArea(
            child: _buildGameWidget(gameId, level, userId),
          ),
        ),
      ),
    );

    // If game returned a result, use it; otherwise simulate XP
    if (result != null && result['completed'] == true) {
      return result;
    }
    
    // If user backed out or no result, return null (sequence stops)
    return null;
  }

  /// Build game widget dynamically
  Widget _buildGameWidget(String gameId, int level, String userId) {
    switch (gameId) {
      case 'memory_match':
        return MemoryMatchGame(userId: userId, level: level);
      case 'stroop_test':
        return StroopTestGame(userId: userId, level: level);
      case 'number_sequence':
        return NumberSequenceGame(userId: userId, level: level);
      case 'pattern_recognition':
        return PatternRecognitionGame(userId: userId, level: level);
      case 'reaction_time':
        return ReactionTimeGame(userId: userId, level: level);
      case 'word_association':
        return WordAssociationGame(userId: userId, level: level);
      case 'spatial_memory':
        return SpatialMemoryGame(userId: userId, level: level);
      default:
        return const Center(child: Text('Gioco non trovato'));
    }
  }

  String _getDomainName(String domain) {
    switch (domain) {
      case 'memory': return 'Memoria';
      case 'attention': return 'Attenzione';
      case 'executive': return 'Funzioni Esecutive';
      case 'speed': return 'Velocità';
      case 'language': return 'Linguaggio';
      case 'spatial': return 'Abilità Spaziali';
      default: return domain;
    }
  }

  Color _getDomainColor(String domain) {
    switch (domain) {
      case 'memory': return Colors.blue;
      case 'attention': return Colors.orange;
      case 'executive': return Colors.purple;
      case 'speed': return Colors.red;
      case 'language': return Colors.green;
      case 'spatial': return Colors.teal;
      default: return Colors.grey;
    }
  }
}
