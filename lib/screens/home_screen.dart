import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_profile_provider.dart';
import '../l10n/app_localizations.dart';
import '../themes/app_themes.dart';
import '../services/brain_boost_score_service.dart';
import 'calendar_screen.dart';
import 'initial_assessment_screen.dart';
import 'games_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
        CircleAvatar(
          radius: 30,
          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          child: Icon(
            Icons.person,
            size: 32,
            color: Theme.of(context).colorScheme.primary,
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
        onPressed: () {
          // Navigate to games tab safely
          try {
            final tabController = DefaultTabController.of(context);
            if (tabController != null) {
              tabController.animateTo(1); // Tab Giochi
            }
          } catch (e) {
            // Fallback: navigate directly to GamesScreen
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const Scaffold(
                  body: SafeArea(child: GamesScreen()),
                ),
              ),
            );
          }
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

  void _exportPDFReport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generazione report PDF in corso...'),
        duration: Duration(seconds: 2),
      ),
    );
    // TODO: Implementa export PDF quando servizi sono integrati
  }

  void _exportCSVData(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export dati CSV in corso...'),
        duration: Duration(seconds: 2),
      ),
    );
    // TODO: Implementa export CSV quando servizi sono integrati
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
}
