import 'package:cloud_firestore/cloud_firestore.dart';

class Reply {
  final String id;
  final String discussionId;
  final String authorId;
  final String author;
  final String authorAvatar;
  final String content;
  final DateTime timestamp;
  final int likes;
  final List<String> likedBy;

  Reply({
    required this.id,
    required this.discussionId,
    required this.authorId,
    required this.author,
    required this.authorAvatar,
    required this.content,
    required this.timestamp,
    required this.likes,
    required this.likedBy,
  });

  factory Reply.fromJson(Map<String, dynamic> json, String id) {
    return Reply(
      id: id,
      discussionId: json['discussionId'] ?? '',
      authorId: json['authorId'] ?? '',
      author: json['author'] ?? '',
      authorAvatar: json['authorAvatar'] ?? '',
      content: json['content'] ?? '',
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      likes: json['likes'] ?? 0,
      likedBy: List<String>.from(json['likedBy'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'discussionId': discussionId,
      'authorId': authorId,
      'author': author,
      'authorAvatar': authorAvatar,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'likes': likes,
      'likedBy': likedBy,
    };
  }
}
