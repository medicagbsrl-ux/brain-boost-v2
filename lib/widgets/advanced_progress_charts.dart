import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/session_history.dart';
import '../services/local_storage_service.dart';

/// Widget avanzato per grafici progressi con comparazioni mensili
class AdvancedProgressCharts extends StatelessWidget {
  final String userId;

  const AdvancedProgressCharts({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SessionHistory>>(
      future: LocalStorageService.getSessionHistory(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final sessions = snapshot.data!;
        
        if (sessions.isEmpty) {
          return const Center(
            child: Text('Completa alcune sessioni per vedere i grafici'),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              _buildWeeklyChart(sessions),
              const SizedBox(height: 24),
              _buildMonthlyComparison(sessions),
              const SizedBox(height: 24),
              _buildDomainRadarChart(sessions),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeeklyChart(List<SessionHistory> sessions) {
    final now = DateTime.now();
    final last7Days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    
    final weekData = <double>[];
    for (var day in last7Days) {
      final daySessions = sessions.where((s) {
        return s.startTime.year == day.year &&
               s.startTime.month == day.month &&
               s.startTime.day == day.day;
      }).toList();
      
      if (daySessions.isEmpty) {
        weekData.add(0);
      } else {
        final avg = daySessions.map((s) => s.accuracy).reduce((a, b) => a + b) / daySessions.length;
        weekData.add(avg);
      }
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Settimanale',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}%');
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];
                          return Text(days[value.toInt() % 7]);
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        weekData.length,
                        (i) => FlSpot(i.toDouble(), weekData[i]),
                      ),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyComparison(List<SessionHistory> sessions) {
    final now = DateTime.now();
    final thisMonth = sessions.where((s) {
      return s.startTime.year == now.year && s.startTime.month == now.month;
    }).toList();
    
    final lastMonth = sessions.where((s) {
      final lastMonthDate = DateTime(now.year, now.month - 1);
      return s.startTime.year == lastMonthDate.year && 
             s.startTime.month == lastMonthDate.month;
    }).toList();

    final thisMonthAvg = thisMonth.isEmpty ? 0.0 :
        thisMonth.map((s) => s.accuracy).reduce((a, b) => a + b) / thisMonth.length;
    
    final lastMonthAvg = lastMonth.isEmpty ? 0.0 :
        lastMonth.map((s) => s.accuracy).reduce((a, b) => a + b) / lastMonth.length;

    final improvement = thisMonthAvg - lastMonthAvg;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Confronto Mensile',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMonthCard('Mese Scorso', lastMonthAvg, Colors.grey),
                _buildMonthCard('Questo Mese', thisMonthAvg, Colors.blue),
              ],
            ),
            const SizedBox(height: 16),
            if (improvement != 0)
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: improvement > 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        improvement > 0 ? Icons.trending_up : Icons.trending_down,
                        color: improvement > 0 ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${improvement > 0 ? '+' : ''}${improvement.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: improvement > 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthCard(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Text(
          '${value.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDomainRadarChart(List<SessionHistory> sessions) {
    final domainScores = <String, double>{};
    final domainCounts = <String, int>{};

    for (var session in sessions) {
      domainScores[session.domain] = (domainScores[session.domain] ?? 0) + session.accuracy;
      domainCounts[session.domain] = (domainCounts[session.domain] ?? 0) + 1;
    }

    final avgScores = domainScores.map((key, value) => 
        MapEntry(key, value / (domainCounts[key] ?? 1)));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance per Dominio',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...avgScores.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_getDomainLabel(entry.key)),
                        Text('${entry.value.toStringAsFixed(1)}%'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: entry.value / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getDomainColor(entry.key),
                      ),
                      minHeight: 8,
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

  String _getDomainLabel(String domain) {
    const labels = {
      'memory': 'Memoria',
      'attention': 'Attenzione',
      'executive': 'Funzioni Esecutive',
      'speed': 'Velocità',
      'language': 'Linguaggio',
      'spatial': 'Abilità Spaziali',
    };
    return labels[domain] ?? domain;
  }

  Color _getDomainColor(String domain) {
    const colors = {
      'memory': Colors.blue,
      'attention': Colors.orange,
      'executive': Colors.purple,
      'speed': Colors.green,
      'language': Colors.red,
      'spatial': Colors.teal,
    };
    return colors[domain] ?? Colors.grey;
  }
}
