class StartupRole {
  final String title;
  final String? commitment;
  final String? description;

  const StartupRole({
    required this.title,
    this.commitment,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'commitment': commitment,
      'description': description,
    };
  }

  factory StartupRole.fromMap(Map<String, dynamic> map) {
    return StartupRole(
      title: map['title'] as String? ?? '',
      commitment: map['commitment'] as String?,
      description: map['description'] as String?,
    );
  }
}
