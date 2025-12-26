class StartupRole {
  final String title;
  final String? commitment;
  final String? description;
  final String learningOutcome;
  final int? estimatedHours;
  final int? durationWeeks;

  const StartupRole({
    required this.title,
    this.commitment,
    this.description,
    this.learningOutcome = 'Outcome coming soon',
    this.estimatedHours,
    this.durationWeeks,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'commitment': commitment,
      'description': description,
      'learningOutcome': learningOutcome,
      'estimatedHours': estimatedHours,
      'durationWeeks': durationWeeks,
    };
  }

  factory StartupRole.fromMap(Map<String, dynamic> map) {
    return StartupRole(
      title: map['title'] as String? ?? '',
      commitment: map['commitment'] as String?,
      description: map['description'] as String?,
      learningOutcome: map['learningOutcome'] as String? ?? '',
      estimatedHours: map['estimatedHours'] as int?,
      durationWeeks: map['durationWeeks'] as int?,
    );
  }
}
