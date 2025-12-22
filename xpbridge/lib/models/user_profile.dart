class UserProfile {
  final String name;
  final String track;
  final List<String> skills;
  final double availabilityHours;
  final int xp;

  const UserProfile({
    this.name = 'You',
    required this.track,
    required this.skills,
    required this.availabilityHours,
    this.xp = 120,
  });

  UserProfile copyWith({
    String? name,
    String? track,
    List<String>? skills,
    double? availabilityHours,
    int? xp,
  }) {
    return UserProfile(
      name: name ?? this.name,
      track: track ?? this.track,
      skills: skills ?? this.skills,
      availabilityHours: availabilityHours ?? this.availabilityHours,
      xp: xp ?? this.xp,
    );
  }
}
