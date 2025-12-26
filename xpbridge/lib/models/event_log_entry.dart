class EventLogEntry {
  final String type;
  final DateTime timestamp;
  final String displayText;
  final String firstName;

  EventLogEntry({
    required this.type,
    required this.timestamp,
    required this.displayText,
    required this.firstName,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'displayText': displayText,
      'firstName': firstName,
    };
  }

  factory EventLogEntry.fromMap(Map<String, dynamic> map) {
    return EventLogEntry(
      type: map['type'] as String? ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      displayText: map['displayText'] as String? ?? '',
      firstName: map['firstName'] as String? ?? '',
    );
  }
}
