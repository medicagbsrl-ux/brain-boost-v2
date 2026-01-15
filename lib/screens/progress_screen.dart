import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/user_profile_provider.dart';
import '../l10n/app_localizations.dart';
import '../services/local_storage_service.dart';
import '../services/report_export_service.dart';
import '../models/session_history.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  void initState() {
    super.initState();
    // Ricarica statistiche quando la schermata viene aperta
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    final provider = Provider.of<UserProfileProvider>(context, listen: false);
    await provider.refreshStatistics();
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<UserProfileProvider>(context);
    final profile = profileProvider.currentProfile;
    final l10n = AppLocalizations.of(context)!;

    if (profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                title: Text(l10n.translate('progress_title')),
                centerTitle: true,
                actions: [
                  // Export CSV Button
                  IconButton(
                    icon: const Icon(Icons.table_chart),
                    onPressed: () => _exportCSV(profile.id, profile.name),
                    tooltip: 'Esporta CSV',
                  ),
                  // Export PDF Button
                  IconButton(
                    icon: const Icon(Icons.picture_as_pdf),
                    onPressed: () => _exportPDF(profile.id, profile.name, profile.age),
                    tooltip: 'Esporta PDF',
                  ),
                  // Refresh Button
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _refreshData,
                    tooltip: 'Aggiorna',
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildStatsCards(context, profile, l10n),
                    const SizedBox(height: 24),
                    _buildWeeklyChart(context, profile, l10n),
                    const SizedBox(height: 24),
                    _buildCognitiveDomainsChart(context, profile, l10n),
                    const SizedBox(height: 24),
                    _buildAchievements(context, profile, l10n),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, dynamic profile, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            l10n.translate('sessions_completed'),
            profile.sessionsCompleted.toString(),
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            l10n.translate('avg_score'),
            '${profile.averageCognitiveScore.toInt()}%',
            Icons.trending_up,
            Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context, dynamic profile, AppLocalizations l10n) {
    return FutureBuilder<List<SessionHistory>>(
      future: LocalStorageService.getAllSessionHistory(profile.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    l10n.translate('weekly_performance'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  const Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
          );
        }

        final sessions = snapshot.data!;
        
        // Calcola dati ultimi 7 giorni
        final now = DateTime.now();
        final weekData = <int, double>{};
        
        for (int i = 0; i < 7; i++) {
          final day = now.subtract(Duration(days: 6 - i));
          final daySessions = sessions.where((s) {
            return s.startTime.year == day.year &&
                   s.startTime.month == day.month &&
                   s.startTime.day == day.day;
          }).toList();
          
          if (daySessions.isNotEmpty) {
            final avgScore = daySessions.fold<double>(
              0.0,
              (sum, s) => sum + s.accuracy,
            ) / daySessions.length;
            weekData[i] = avgScore;
          } else {
            weekData[i] = 0;
          }
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.translate('weekly_performance'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (sessions.isEmpty)
                      Text(
                        'Nessun dato',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 200,
                  child: sessions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.bar_chart, size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 8),
                              Text(
                                'Completa alcune sessioni per vedere il grafico',
                                style: TextStyle(color: Colors.grey[600]),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: true),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  getTitlesWidget: (value, meta) {
                                    return Text('${value.toInt()}');
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    const days = ['L', 'M', 'M', 'G', 'V', 'S', 'D'];
                                    if (value.toInt() >= 0 && value.toInt() < days.length) {
                                      return Text(days[value.toInt()]);
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: weekData.entries
                                    .map((e) => FlSpot(e.key.toDouble(), e.value))
                                    .toList(),
                                isCurved: true,
                                color: Theme.of(context).colorScheme.primary,
                                barWidth: 3,
                                dotData: const FlDotData(show: true),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                ),
                              ),
                            ],
                            minY: 0,
                            maxY: 100,
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildCognitiveDomainsChart(BuildContext context, dynamic profile, AppLocalizations l10n) {
    final domainScores = profile.cognitiveScores as Map<String, dynamic>;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Domini Cognitivi',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Analisi dettagliata delle tue abilità cognitive',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ...domainScores.entries.map((entry) {
              final domainName = _getDomainName(entry.key);
              final score = (entry.value as num).toDouble();
              final color = _getDomainColor(entry.key);
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          domainName,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          '${score.toInt()}/100',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: score / 100,
                        minHeight: 12,
                        backgroundColor: color.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
  
  String _getDomainName(String key) {
    switch (key) {
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
        return key;
    }
  }
  
  Color _getDomainColor(String key) {
    switch (key) {
      case 'memory':
        return const Color(0xFF4A90E2);
      case 'attention':
        return const Color(0xFFF5A623);
      case 'executive':
        return const Color(0xFF7B68EE);
      case 'speed':
        return const Color(0xFF50E3C2);
      case 'language':
        return const Color(0xFFE84855);
      case 'spatial':
        return const Color(0xFF9B59B6);
      default:
        return Colors.grey;
    }
  }

  Widget _buildAchievements(BuildContext context, dynamic profile, AppLocalizations l10n) {
    final achievements = [
      {
        'title': 'Primo Passo',
        'desc': 'Completata la prima sessione',
        'icon': Icons.star,
        'unlocked': true,
      },
      {
        'title': 'Settimana Perfetta',
        'desc': '7 giorni consecutivi',
        'icon': Icons.local_fire_department,
        'unlocked': true,
      },
      {
        'title': 'Allenatore',
        'desc': '10 sessioni completate',
        'icon': Icons.fitness_center,
        'unlocked': true,
      },
      {
        'title': 'Esperto',
        'desc': '50 sessioni completate',
        'icon': Icons.emoji_events,
        'unlocked': false,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.translate('achievements'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ...achievements.map((achievement) => _buildAchievementCard(
              context,
              achievement['title'] as String,
              achievement['desc'] as String,
              achievement['icon'] as IconData,
              achievement['unlocked'] as bool,
            )),
      ],
    );
  }

  Widget _buildAchievementCard(
    BuildContext context,
    String title,
    String desc,
    IconData icon,
    bool unlocked,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: unlocked
                    ? Colors.amber.withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: unlocked ? Colors.amber : Colors.grey,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: unlocked ? null : Colors.grey,
                        ),
                  ),
                  Text(
                    desc,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
            if (unlocked)
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 24,
              )
            else
              Icon(
                Icons.lock,
                color: Colors.grey[400],
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  // Export PDF Report
  Future<void> _exportPDF(String userId, String userName, int age) async {
    try {
      // Show loading indicator
      if (!mounted) return;
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

      // Get date range (last 30 days)
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 30));

      // Export PDF using web download
      final exportService = ReportExportService.instance;
      await exportService.exportPDFForWeb(
        userId: userId,
        userName: userName,
        userAge: age,
        startDate: startDate,
        endDate: endDate,
      );

      if (!mounted) return;
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 16),
              Expanded(child: Text('❌ Errore: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  // Export CSV Report
  Future<void> _exportCSV(String userId, String userName) async {
    try {
      // Show loading indicator
      if (!mounted) return;
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

      // Get date range (last 30 days)
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 30));

      // Export CSV using web download
      final exportService = ReportExportService.instance;
      await exportService.exportCSVForWeb(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      if (!mounted) return;
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 16),
              Expanded(child: Text('❌ Errore: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}
