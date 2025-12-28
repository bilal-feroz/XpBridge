enum MessageSender { user, ai }

class AiChatMessage {
  final String id;
  final String content;
  final MessageSender sender;
  final DateTime timestamp;
  final bool isLoading;

  const AiChatMessage({
    required this.id,
    required this.content,
    required this.sender,
    required this.timestamp,
    this.isLoading = false,
  });

  AiChatMessage copyWith({
    String? id,
    String? content,
    MessageSender? sender,
    DateTime? timestamp,
    bool? isLoading,
  }) {
    return AiChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool get isUser => sender == MessageSender.user;
  bool get isAi => sender == MessageSender.ai;
}
