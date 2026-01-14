import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import '../models/session_history.dart';
import 'local_storage_service.dart';

/// Servizio per export report in PDF e CSV
class ReportExportService {
  static final ReportExportService _instance = ReportExportService._internal();
  factory ReportExportService() => _instance;
  ReportExportService._internal();

  /// Esporta report completo in PDF
  Future<String> exportPDFReport({
    required String userId,
    required String userName,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final pdf = pw.Document();

    // Carica dati
    final sessions = await LocalStorageService.getAllSessionHistory(userId);
    final assessment = await LocalStorageService.getLatestAssessment(userId);
    
    // Filtra sessioni per date range
    final filteredSessions = sessions.where((s) {
      return s.timestamp.isAfter(startDate) && s.timestamp.isBefore(endDate);
    }).toList();

    // Calcola statistiche
    final totalSessions = filteredSessions.length;
    final avgScore = totalSessions > 0
        ? filteredSessions.fold<double>(0, (sum, s) => sum + s.score) / totalSessions
        : 0.0;
    final avgAccuracy = totalSessions > 0
        ? filteredSessions.fold<double>(0, (sum, s) => sum + s.accuracy) / totalSessions
        : 0.0;

    // Crea PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          // Header
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Brain Boost - Report Clinico',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Divider(thickness: 2),
              ],
            ),
          ),
          
          pw.SizedBox(height: 20),
          
          // Informazioni paziente
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'INFORMAZIONI PAZIENTE',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Nome: $userName'),
                          pw.SizedBox(height: 4),
                          pw.Text('ID: ${userId.substring(0, 12)}...'),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Periodo: ${_formatDate(startDate)} - ${_formatDate(endDate)}'),
                          pw.SizedBox(height: 4),
                          pw.Text('Report generato: ${_formatDate(DateTime.now())}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          pw.SizedBox(height: 20),
          
          // Brain Boost Score
          if (assessment != null) ...[
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    'BRAIN BOOST SCORE',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Text(
                    assessment.overallScore.toStringAsFixed(0),
                    style: pw.TextStyle(
                      fontSize: 48,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                  pw.Text(
                    _getScoreLevel(assessment.overallScore),
                    style: const pw.TextStyle(
                      fontSize: 16,
                      color: PdfColors.blue700,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Percentile: ${_getPercentile(assessment.overallScore, assessment.userAge)}°',
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            
            pw.SizedBox(height: 20),
            
            // Punteggi per dominio
            pw.Text(
              'PUNTEGGI PER DOMINIO COGNITIVO',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 12),
            pw.TableHelper.fromTextArray(
              headers: ['Dominio', 'Punteggio', 'Valutazione'],
              data: assessment.domainScores.entries.map((entry) {
                return [
                  _getDomainName(entry.key),
                  '${entry.value.toStringAsFixed(0)}/100',
                  _getScoreEvaluation(entry.value),
                ];
              }).toList(),
              border: pw.TableBorder.all(color: PdfColors.grey400),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
            ),
            
            pw.SizedBox(height: 20),
          ],
          
          // Statistiche generali
          pw.Text(
            'STATISTICHE GENERALI',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.TableHelper.fromTextArray(
            headers: ['Metrica', 'Valore'],
            data: [
              ['Sessioni Completate', '$totalSessions'],
              ['Punteggio Medio', avgScore.toStringAsFixed(1)],
              ['Precisione Media', '${avgAccuracy.toStringAsFixed(1)}%'],
              ['Giorni di Allenamento', '${_getTrainingDays(filteredSessions)}'],
            ],
            border: pw.TableBorder.all(color: PdfColors.grey400),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          
          pw.SizedBox(height: 20),
          
          // Dettaglio sessioni per gioco
          pw.Text(
            'PERFORMANCE PER GIOCO',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          ...(_getGameStats(filteredSessions)).entries.map((entry) {
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 12),
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    _getGameName(entry.key),
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Sessioni: ${entry.value['count']}'),
                      pw.Text('Media: ${entry.value['avgScore'].toStringAsFixed(1)}'),
                      pw.Text('Precisione: ${entry.value['avgAccuracy'].toStringAsFixed(1)}%'),
                    ],
                  ),
                ],
              ),
            );
          }),
          
          pw.SizedBox(height: 20),
          
          // Footer
          pw.Divider(thickness: 2),
          pw.SizedBox(height: 8),
          pw.Text(
            '© ${DateTime.now().year} Brain Boost - Sistema di Riabilitazione Cognitiva',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
          pw.Text(
            'Report generato automaticamente • Documento riservato',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
        ],
      ),
    );

    // Salva PDF
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/brain_boost_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());

    if (kDebugMode) {
      print('✅ Report PDF salvato: ${file.path}');
    }

    return file.path;
  }

  /// Esporta dati in CSV
  Future<String> exportCSVData({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final sessions = await LocalStorageService.getAllSessionHistory(userId);
    
    // Filtra sessioni
    final filteredSessions = sessions.where((s) {
      return s.timestamp.isAfter(startDate) && s.timestamp.isBefore(endDate);
    }).toList();

    // Prepara dati CSV
    final List<List<dynamic>> rows = [
      // Header
      [
        'Data',
        'Orario',
        'Gioco',
        'Punteggio',
        'Precisione (%)',
        'Tentativi Corretti',
        'Tentativi Totali',
        'Tempo Reazione (ms)',
        'Durata (min)',
      ],
      // Data rows
      ...filteredSessions.map((session) => [
        _formatDate(session.timestamp),
        _formatTime(session.timestamp),
        _getGameName(session.gameId),
        session.score.toStringAsFixed(1),
        session.accuracy.toStringAsFixed(1),
        session.correctAttempts,
        session.totalAttempts,
        session.reactionTime?.toStringAsFixed(0) ?? 'N/A',
        session.duration.inMinutes.toString(),
      ]),
    ];

    // Converti in CSV
    final String csvData = const ListToCsvConverter().convert(rows);

    // Salva file
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/brain_boost_data_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csvData);

    if (kDebugMode) {
      print('✅ Dati CSV salvati: ${file.path}');
    }

    return file.path;
  }

  Map<String, Map<String, dynamic>> _getGameStats(List<SessionHistory> sessions) {
    final Map<String, List<SessionHistory>> byGame = {};
    
    for (final session in sessions) {
      byGame.putIfAbsent(session.gameId, () => []).add(session);
    }

    final Map<String, Map<String, dynamic>> stats = {};
    
    byGame.forEach((gameId, gameSessions) {
      stats[gameId] = {
        'count': gameSessions.length,
        'avgScore': gameSessions.fold<double>(0, (sum, s) => sum + s.score) / gameSessions.length,
        'avgAccuracy': gameSessions.fold<double>(0, (sum, s) => sum + s.accuracy) / gameSessions.length,
      };
    });

    return stats;
  }

  int _getTrainingDays(List<SessionHistory> sessions) {
    final uniqueDays = sessions.map((s) => DateTime(s.timestamp.year, s.timestamp.month, s.timestamp.day)).toSet();
    return uniqueDays.length;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _getDomainName(String domain) {
    const names = {
      'memory': 'Memoria',
      'attention': 'Attenzione',
      'executive': 'Funzioni Esecutive',
      'speed': 'Velocità',
      'language': 'Linguaggio',
      'spatial': 'Abilità Spaziali',
    };
    return names[domain] ?? domain;
  }

  String _getGameName(String gameId) {
    const names = {
      'memory_match': 'Memory Match',
      'stroop_test': 'Test di Stroop',
      'reaction_time': 'Tempo di Reazione',
      'number_sequence': 'Sequenze Numeriche',
      'pattern_recognition': 'Riconoscimento Pattern',
      'word_association': 'Associazione Parole',
      'spatial_memory': 'Memoria Spaziale',
    };
    return names[gameId] ?? gameId;
  }

  String _getScoreEvaluation(double score) {
    if (score >= 80) return 'Eccellente';
    if (score >= 70) return 'Buono';
    if (score >= 60) return 'Sufficiente';
    if (score >= 50) return 'Da migliorare';
    return 'Critico';
  }

  String _getScoreLevel(double score) {
    if (score >= 900) return 'Eccezionale';
    if (score >= 800) return 'Eccellente';
    if (score >= 700) return 'Molto Buono';
    if (score >= 600) return 'Buono';
    if (score >= 500) return 'Discreto';
    return 'Sufficiente';
  }

  int _getPercentile(double score, int age) {
    if (score >= 900) return 99;
    if (score >= 800) return 95;
    if (score >= 700) return 85;
    if (score >= 600) return 70;
    if (score >= 500) return 50;
    return 30;
  }
}
