import 'package:uuid/uuid.dart';

class AssessmentResult {
  final String id;
  final String userId;
  final DateTime completedAt;
  final String assessmentType; // 'initial', 'periodic', 'final'
  final Map<String, double> domainScores; // Domain -> Score (0-100)
  final Map<String, int> domainLevels; // Domain -> Recommended Level (1-10)
  final double overallScore; // 0-100
  final String cognitiveProfile; // 'below_average', 'average', 'above_average'
  final List<String> strongDomains;
  final List<String> weakDomains;
  final Map<String, String> recommendations; // Domain -> Recommendation text
  final int ageNormalizedScore; // Compared to age group
  final bool certified; // If this is a certified assessment
  final String? notes;

  // Getter di compatibilità
  int get userAge => ageNormalizedScore; // Approximation

  AssessmentResult({
    String? id,
    required this.userId,
    required this.completedAt,
    required this.assessmentType,
    required this.domainScores,
    required this.domainLevels,
    required this.overallScore,
    required this.cognitiveProfile,
    required this.strongDomains,
    required this.weakDomains,
    required this.recommendations,
    required this.ageNormalizedScore,
    this.certified = false,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'completedAt': completedAt.toIso8601String(),
      'assessmentType': assessmentType,
      'domainScores': domainScores,
      'domainLevels': domainLevels,
      'overallScore': overallScore,
      'cognitiveProfile': cognitiveProfile,
      'strongDomains': strongDomains,
      'weakDomains': weakDomains,
      'recommendations': recommendations,
      'ageNormalizedScore': ageNormalizedScore,
      'certified': certified,
      'notes': notes,
    };
  }

  factory AssessmentResult.fromMap(Map<String, dynamic> map) {
    return AssessmentResult(
      id: map['id'] as String,
      userId: map['userId'] as String,
      completedAt: DateTime.parse(map['completedAt'] as String),
      assessmentType: map['assessmentType'] as String,
      domainScores: Map<String, double>.from(map['domainScores'] as Map),
      domainLevels: Map<String, int>.from(map['domainLevels'] as Map),
      overallScore: (map['overallScore'] as num).toDouble(),
      cognitiveProfile: map['cognitiveProfile'] as String,
      strongDomains: List<String>.from(map['strongDomains'] as List),
      weakDomains: List<String>.from(map['weakDomains'] as List),
      recommendations: Map<String, String>.from(map['recommendations'] as Map),
      ageNormalizedScore: map['ageNormalizedScore'] as int,
      certified: map['certified'] as bool? ?? false,
      notes: map['notes'] as String?,
    );
  }

  String getCognitiveProfileDescription() {
    switch (cognitiveProfile) {
      case 'below_average':
        return 'Al di sotto della media per la tua fascia d\'età';
      case 'average':
        return 'Nella media per la tua fascia d\'età';
      case 'above_average':
        return 'Al di sopra della media per la tua fascia d\'età';
      default:
        return 'Non determinato';
    }
  }

  String getRecommendationForDomain(String domain) {
    return recommendations[domain] ?? 'Continua l\'allenamento regolare';
  }
}
