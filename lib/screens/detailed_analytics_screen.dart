import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/user_profile_provider.dart';
import '../services/local_storage_service.dart';
import '../services/brain_boost_score_service.dart';
import '../models/session_history.dart';

class DetailedAnalyticsScreen extends StatefulWidget {
  const DetailedAnalyticsScreen({super.key});

  @override
  State<DetailedAnalyticsScreen> createState() => _DetailedAnalyticsScreenState();
}

class _DetailedAnalyticsScreenState extends State<DetailedAnalyticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedDomain = 'all';
  List<SessionHistory> sessions = [];
  bool isLoading = true;

  final Map<String, String> domainNames = {
    'all': 'Tutti i Domini',
    'memory': 'Memoria',
    'attention': 'Attenzione',
    'executive': 'Funzioni Esecutive',
    'speed': 'Velocità',
    'language': 'Linguaggio',
    'spatial': 'Abilità Spaziali',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSessions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSessions() async {
    setState(() => isLoading = true);
    
    final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
    final userId = profileProvider.currentProfile?.id ?? 'demo_user';
    
    final allSessions = await LocalStorageService.getSessionHistory(userId);
    
    setState(() {
      sessions = allSessions;
      isLoading = false;
    });
  }

  List<SessionHistory> get filteredSessions {
    if (selectedDomain == 'all') return sessions;
    return sessions.where((s) => s.domain == selectedDomain).toList();
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<UserProfileProvider>(context);
    final profile = profileProvider.currentProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dettagliato'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.timeline), text: 'Progressi'),
            Tab(icon: Icon(Icons.history), text: 'Storico'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDashboardTab(profile),
                _buildProgressTab(),
                _buildHistoryTab(),
              ],
            ),
    );
  }

  Widget _buildDashboardTab(dynamic profile) {
    return FutureBuilder<BrainBoostScore>(
      future: BrainBoostScoreService.calculateScore(profile.id, profile.age),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final score = snapshot.data!;

        return RefreshIndicator(
          onRefresh: _loadSessions,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overall Brain Boost Score Card
                _buildOverallScoreCard(score),
                const SizedBox(height: 24),

                // Domain Scores Grid
                _buildSectionTitle('Score per Dominio'),
                const SizedBox(height: 12),
                _buildDomainScoresGrid(score.domainScores),
                const SizedBox(height: 24),

                // Performance Metrics
                _buildSectionTitle('Metriche Performance'),
                const SizedBox(height: 12),
                _buildPerformanceMetrics(score),
                const SizedBox(height: 24),

                // Insights
                _buildSectionTitle('Insights Personalizzati'),
                const SizedBox(height: 12),
                ...score.insights.map((insight) => _buildInsightCard(insight)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverallScoreCard(BrainBoostScore score) {
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
              'Brain Boost Score Totale',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              score.cognitiveLevel,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: score.totalScore / 1000,
                        strokeWidth: 10,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            score.totalScore.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            '/1000',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildScoreStat('Percentile', '${score.percentileRank}°', Icons.trending_up),
                    const SizedBox(height: 8),
                    _buildScoreStat('Categoria', score.scoreCategory, Icons.category),
                    const SizedBox(height: 8),
                    _buildScoreStat('Sessioni', '${score.totalSessions}', Icons.fitness_center),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              score.ageGroup,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreStat(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDomainScoresGrid(Map<String, double> domainScores) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: domainScores.entries.map((entry) {
        return _buildDomainScoreCard(entry.key, entry.value);
      }).toList(),
    );
  }

  Widget _buildDomainScoreCard(String domain, double score) {
    final color = _getDomainColor(domain);
    final icon = _getDomainIcon(domain);
    final name = domainNames[domain] ?? domain;

    return Card(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedDomain = domain;
            _tabController.animateTo(2); // Go to history tab
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                '${score.toInt()}%',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceMetrics(BrainBoostScore score) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Costanza',
            score.consistency,
            Icons.check_circle_outline,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            'Miglioramento',
            score.improvement,
            Icons.trending_up,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            'Impegno',
            score.engagement,
            Icons.favorite,
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String label, double value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              '${value.toInt()}%',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(String insight) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.lightbulb_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                insight,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTab() {
    if (filteredSessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timeline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Nessuna sessione registrata',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Domain filter
          _buildDomainFilter(),
          const SizedBox(height: 24),

          // Progress chart
          _buildSectionTitle('Andamento nel Tempo'),
          const SizedBox(height: 16),
          _buildProgressChart(),
          const SizedBox(height: 24),

          // Stats by game
          _buildSectionTitle('Performance per Gioco'),
          const SizedBox(height: 16),
          _buildGameStats(),
        ],
      ),
    );
  }

  Widget _buildDomainFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: domainNames.entries.map((entry) {
          final isSelected = selectedDomain == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(entry.value),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedDomain = entry.key;
                });
              },
              backgroundColor: isSelected ? _getDomainColor(entry.key).withValues(alpha: 0.2) : null,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProgressChart() {
    final chartSessions = filteredSessions.take(20).toList().reversed.toList();
    
    if (chartSessions.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('Dati insufficienti per il grafico')),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}%', style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < chartSessions.length) {
                            return Text(
                              '${value.toInt() + 1}',
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: chartSessions.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.accuracy);
                      }).toList(),
                      isCurved: true,
                      color: _getDomainColor(selectedDomain),
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: _getDomainColor(selectedDomain).withValues(alpha: 0.1),
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
  }

  Widget _buildGameStats() {
    final gameStats = <String, List<SessionHistory>>{};
    
    for (var session in filteredSessions) {
      if (!gameStats.containsKey(session.gameId)) {
        gameStats[session.gameId] = [];
      }
      gameStats[session.gameId]!.add(session);
    }

    return Column(
      children: gameStats.entries.map((entry) {
        final gameSessions = entry.value;
        final avgAccuracy = gameSessions.map((s) => s.accuracy).reduce((a, b) => a + b) / gameSessions.length;
        final bestScore = gameSessions.map((s) => s.percentageScore).reduce((a, b) => a > b ? a : b);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getDomainColor(gameSessions.first.domain).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getGameIcon(entry.key),
                color: _getDomainColor(gameSessions.first.domain),
              ),
            ),
            title: Text(gameSessions.first.gameName),
            subtitle: Text('${gameSessions.length} sessioni'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${avgAccuracy.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Best: ${bestScore.toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHistoryTab() {
    if (filteredSessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Nessuna sessione nello storico',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildDomainFilter(),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredSessions.length,
            itemBuilder: (context, index) {
              return _buildSessionCard(filteredSessions[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSessionCard(SessionHistory session) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getDomainColor(session.domain).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getGameIcon(session.gameId),
            color: _getDomainColor(session.domain),
          ),
        ),
        title: Text(session.gameName),
        subtitle: Text(_formatDateTime(session.startTime)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${session.percentageScore.toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Livello ${session.level}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Precisione', '${session.accuracy.toStringAsFixed(1)}%'),
                _buildDetailRow('Punteggio', '${session.score}/${session.maxScore}'),
                _buildDetailRow('Durata', '${session.duration.inSeconds}s'),
                _buildDetailRow('Risposte Corrette', '${session.reactionsCorrect}'),
                _buildDetailRow('Risposte Errate', '${session.reactionsIncorrect}'),
                if (session.averageReactionTime > 0)
                  _buildDetailRow('Tempo Medio', '${session.averageReactionTime.toStringAsFixed(0)}ms'),
                _buildDetailRow('Difficoltà', session.difficulty.toUpperCase()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Color _getDomainColor(String domain) {
    const colors = {
      'all': Color(0xFF9E9E9E),
      'memory': Color(0xFF4A90E2),
      'attention': Color(0xFFF5A623),
      'executive': Color(0xFF7B68EE),
      'speed': Color(0xFF50E3C2),
      'language': Color(0xFFE84855),
      'spatial': Color(0xFF9B59B6),
    };
    return colors[domain] ?? Colors.grey;
  }

  IconData _getDomainIcon(String domain) {
    const icons = {
      'all': Icons.dashboard,
      'memory': Icons.lightbulb_outline,
      'attention': Icons.visibility_outlined,
      'executive': Icons.account_tree_outlined,
      'speed': Icons.speed,
      'language': Icons.chat_bubble_outline,
      'spatial': Icons.view_in_ar_outlined,
    };
    return icons[domain] ?? Icons.star_outline;
  }

  IconData _getGameIcon(String gameId) {
    const icons = {
      'memory_match': Icons.grid_view,
      'number_sequence': Icons.format_list_numbered,
      'stroop': Icons.palette,
      'pattern': Icons.category,
      'reaction': Icons.touch_app,
      'word_association': Icons.link,
      'spatial_memory': Icons.location_on,
    };
    return icons[gameId] ?? Icons.sports_esports;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
