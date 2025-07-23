import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String id;
  final List<String> userIds;
  final String lastMessage;
  final DateTime lastMessageTime;
  final Map<String, int> unreadCount;

  Chat({
    required this.id,
    required this.userIds,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
  });

  factory Chat.fromJson(Map<String, dynamic> json, String id) {
    final lastMessageTimeRaw = json['lastMessageTime'];
    DateTime lastMessageTime;
    if (lastMessageTimeRaw == null) {
      lastMessageTime = DateTime.now();
    } else if (lastMessageTimeRaw is Timestamp) {
      lastMessageTime = lastMessageTimeRaw.toDate();
    } else if (lastMessageTimeRaw is DateTime) {
      lastMessageTime = lastMessageTimeRaw;
    } else {
      lastMessageTime = DateTime.now();
    }
    return Chat(
      id: id,
      userIds: List<String>.from(json['userIds'] as List? ?? []),
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageTime: lastMessageTime,
      unreadCount: Map<String, int>.from(json['unreadCount'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userIds': userIds,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'unreadCount': unreadCount,
    };
  }
}
