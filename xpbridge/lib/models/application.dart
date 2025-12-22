enum ApplicationStatus {
  pending,
  accepted,
  rejected,
  interviewing,
  hired,
}

class Application {
  final String id;
  final String studentId;
  final String startupId;
  final String studentName;
  final String startupName;
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
      status: status ?? this.status,
      message: message ?? this.message,
      appliedAt: appliedAt ?? this.appliedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
