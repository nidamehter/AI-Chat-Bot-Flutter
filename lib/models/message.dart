import 'dart:convert';

enum Role {
  user,
  assistant,
}

class Message {
  final String messageId;
  final String chatId;
  final Role role;
  final StringBuffer message;
  final List<String> imagesUrls;
  final DateTime timeSent;

  // Constructor
  Message({
    required this.messageId,
    required this.chatId,
    required this.role,
    required this.message,
    required this.imagesUrls,
    required this.timeSent,
  });

  // Convert to Map (JSON için)
  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'chatId': chatId,
      'role': role.index, // Enum index olarak kaydediliyor
      'message': message.toString(),
      'imagesUrls': imagesUrls,
      'timeSent': timeSent.toIso8601String(),
    };
  }

  // JSON'dan Message objesine çevirme
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      messageId: map['messageId'] ?? '',
      chatId: map['chatId'] ?? '',
      role: Role.values[map['role']], // Enum'u geri yükler
      message: StringBuffer(map['message'] ?? ''),
      imagesUrls: List<String>.from(map['imagesUrls'] ?? []),
      timeSent: DateTime.parse(map['timeSent'] ?? DateTime.now().toIso8601String()),
    );
  }

  // `copyWith` metodu, nesneyi değiştirmeden yeni bir kopya üretmek için kullanılır
  Message copyWith({
    String? messageId,
    String? chatId,
    Role? role,
    StringBuffer? message,
    List<String>? imagesUrls,
    DateTime? timeSent,
  }) {
    return Message(
      messageId: messageId ?? this.messageId,
      chatId: chatId ?? this.chatId,
      role: role ?? this.role,
      message: message ?? StringBuffer(this.message.toString()), // StringBuffer sorunu giderildi
      imagesUrls: imagesUrls ?? List.from(this.imagesUrls),
      timeSent: timeSent ?? this.timeSent,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Message && other.messageId == messageId;
  }

  @override
  int get hashCode {
    return messageId.hashCode;
  }
}
