class StudentProfile {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? bio;
  final String? education;
  final List<String> skills;
  final double availabilityHours;
  final String? portfolioUrl;
  final String? profileImageUrl;
  final DateTime createdAt;

  const StudentProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.bio,
    this.education,
    required this.skills,
    required this.availabilityHours,
    this.portfolioUrl,
    this.profileImageUrl,
    required this.createdAt,
  });

  StudentProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? bio,
    String? education,
    List<String>? skills,
    double? availabilityHours,
    String? portfolioUrl,
    String? profileImageUrl,
    DateTime? createdAt,
  }) {
    return StudentProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      education: education ?? this.education,
      skills: skills ?? this.skills,
      availabilityHours: availabilityHours ?? this.availabilityHours,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
