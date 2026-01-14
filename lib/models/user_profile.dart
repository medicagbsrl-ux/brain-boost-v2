class UserProfile {
  final String id;
  final String name;
  final int age;
  final DateTime startDate;
  final String language;
  final String theme; // 'professional', 'gamified', 'minimal'
  final String textSize; // 'normal', 'large', 'extra_large'
  final String contrast; // 'standard', 'high'
  final int sessionDuration; // in minutes
  final int weeklyFrequency;
  final bool remindersEnabled;
  final String? photoUrl;
  final Map<String, double> cognitiveScores; // Domain -> Score (0-100)
  final int currentLevel;
  final int totalPoints;
  final int sessionsCompleted;
  final int streakDays;

  UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.startDate,
    this.language = 'it',
    this.theme = 'professional',
    this.textSize = 'normal',
    this.contrast = 'standard',
    this.sessionDuration = 15,
    this.weeklyFrequency = 5,
    this.remindersEnabled = true,
    this.photoUrl,
    Map<String, double>? cognitiveScores,
    this.currentLevel = 1,
    this.totalPoints = 0,
    this.sessionsCompleted = 0,
    this.streakDays = 0,
  }) : cognitiveScores = cognitiveScores ?? {
          'memory': 50.0,
          'attention': 50.0,
          'executive': 50.0,
          'speed': 50.0,
          'language': 50.0,
          'spatial': 50.0,
        };

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'startDate': startDate.toIso8601String(),
      'language': language,
      'theme': theme,
      'textSize': textSize,
      'contrast': contrast,
      'sessionDuration': sessionDuration,
      'weeklyFrequency': weeklyFrequency,
      'remindersEnabled': remindersEnabled,
      'photoUrl': photoUrl,
      'cognitiveScores': cognitiveScores,
      'currentLevel': currentLevel,
      'totalPoints': totalPoints,
      'sessionsCompleted': sessionsCompleted,
      'streakDays': streakDays,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      name: map['name'] as String,
      age: map['age'] as int,
      startDate: DateTime.parse(map['startDate'] as String),
      language: map['language'] as String? ?? 'it',
      theme: map['theme'] as String? ?? 'professional',
      textSize: map['textSize'] as String? ?? 'normal',
      contrast: map['contrast'] as String? ?? 'standard',
      sessionDuration: map['sessionDuration'] as int? ?? 15,
      weeklyFrequency: map['weeklyFrequency'] as int? ?? 5,
      remindersEnabled: map['remindersEnabled'] as bool? ?? true,
      photoUrl: map['photoUrl'] as String?,
      cognitiveScores: Map<String, double>.from(
        map['cognitiveScores'] as Map? ?? {},
      ),
      currentLevel: map['currentLevel'] as int? ?? 1,
      totalPoints: map['totalPoints'] as int? ?? 0,
      sessionsCompleted: map['sessionsCompleted'] as int? ?? 0,
      streakDays: map['streakDays'] as int? ?? 0,
    );
  }

  UserProfile copyWith({
    String? id,
    String? name,
    int? age,
    DateTime? startDate,
    String? language,
    String? theme,
    String? textSize,
    String? contrast,
    int? sessionDuration,
    int? weeklyFrequency,
    bool? remindersEnabled,
    String? photoUrl,
    Map<String, double>? cognitiveScores,
    int? currentLevel,
    int? totalPoints,
    int? sessionsCompleted,
    int? streakDays,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      startDate: startDate ?? this.startDate,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      textSize: textSize ?? this.textSize,
      contrast: contrast ?? this.contrast,
      sessionDuration: sessionDuration ?? this.sessionDuration,
      weeklyFrequency: weeklyFrequency ?? this.weeklyFrequency,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      photoUrl: photoUrl ?? this.photoUrl,
      cognitiveScores: cognitiveScores ?? this.cognitiveScores,
      currentLevel: currentLevel ?? this.currentLevel,
      totalPoints: totalPoints ?? this.totalPoints,
      sessionsCompleted: sessionsCompleted ?? this.sessionsCompleted,
      streakDays: streakDays ?? this.streakDays,
    );
  }

  double get averageCognitiveScore {
    if (cognitiveScores.isEmpty) return 0.0;
    return cognitiveScores.values.reduce((a, b) => a + b) / cognitiveScores.length;
  }
}
