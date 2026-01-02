import 'startup_role.dart';

class StartupProfile {
  final String id;
  final String companyName;
  final String email;
  final String? phone;
  final String description;
  final String industry;
  final List<String> requiredSkills;
  final List<StartupRole> openRoles;
  final String? websiteUrl;
  final String? logoUrl;
  final String? logoBase64;
  final String? projectDetails;
  final DateTime createdAt;

  const StartupProfile({
    required this.id,
    required this.companyName,
    required this.email,
    this.phone,
    required this.description,
    required this.industry,
    required this.requiredSkills,
    this.openRoles = const [],
    this.websiteUrl,
    this.logoUrl,
    this.logoBase64,
    this.projectDetails,
    required this.createdAt,
  });

  StartupProfile copyWith({
    String? id,
    String? companyName,
    String? email,
    String? phone,
    String? description,
    String? industry,
    List<String>? requiredSkills,
    List<StartupRole>? openRoles,
    String? websiteUrl,
    String? logoUrl,
    String? logoBase64,
    String? projectDetails,
    DateTime? createdAt,
  }) {
    return StartupProfile(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      description: description ?? this.description,
      industry: industry ?? this.industry,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      openRoles: openRoles ?? this.openRoles,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      logoUrl: logoUrl ?? this.logoUrl,
      logoBase64: logoBase64 ?? this.logoBase64,
      projectDetails: projectDetails ?? this.projectDetails,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
