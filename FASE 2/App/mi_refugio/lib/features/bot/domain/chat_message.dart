enum ChatRole { user, assistant, system }

class ChatMessage {
  final String id;
  final ChatRole role;
  final String content;
  final DateTime createdAt;

  ChatMessage({required this.id, required this.role, required this.content, required this.createdAt});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id']?.toString() ?? '',
      role: _parseRole(json['role']),
      content: json['content']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  static ChatRole _parseRole(dynamic v) {
    final s = (v?.toString() ?? '').toLowerCase();
    if (s == 'user') return ChatRole.user;
    if (s == 'assistant') return ChatRole.assistant;
    return ChatRole.system;
  }
}
