enum ApplicationStatus { pending, accepted, rejected, interviewing, hired }

class Application {
  final String id;
  final String studentId;
  final String startupId;
  final String studentName;
  final String startupName;
  final String? roleTitle;
  final ApplicationStatus status;
  final String? message;
  final DateTime appliedAt;
  final DateTime? updatedAt;

  const Application({
    required this.id,
    required this.studentId,
    required this.startupId,
    required this.studentName,
    required this.startupName,
    this.roleTitle,
    required this.status,
    this.message,
    required this.appliedAt,
    this.updatedAt,
  });

  Application copyWith({
    String? id,
    String? studentId,
    String? startupId,
    String? studentName,
    String? startupName,
    String? roleTitle,
    ApplicationStatus? status,
    String? message,
    DateTime? appliedAt,
    DateTime? updatedAt,
  }) {
    return Application(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      startupId: startupId ?? this.startupId,
      studentName: studentName ?? this.studentName,
      startupName: startupName ?? this.startupName,
      roleTitle: roleTitle ?? this.roleTitle,
      status: status ?? this.status,
      message: message ?? this.message,
      appliedAt: appliedAt ?? this.appliedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
