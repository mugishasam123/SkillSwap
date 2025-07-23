import 'package:cloud_firestore/cloud_firestore.dart';

class Discussion {
  final String id;
  final String avatar;
  final String title;
  final String author;
  final String authorId;
  final String description;
  final int likes;
  final int replies;
  final int views;
  final DateTime timestamp;
  final List<String> likedBy;
  final List<String> viewedBy;

  Discussion({
    required this.id,
    required this.avatar,
    required this.title,
    required this.author,
    required this.authorId,
    required this.description,
    required this.likes,
    required this.replies,
    required this.views,
    required this.timestamp,
    required this.likedBy,
    required this.viewedBy,
  });

  factory Discussion.fromJson(Map<String, dynamic> json, String id) {
    return Discussion(
      id: id,
      avatar: json['avatar'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      authorId: json['authorId'] ?? '',
      description: json['description'] ?? '',
      likes: json['likes'] ?? 0,
      replies: json['replies'] ?? 0,
      views: json['views'] ?? 0,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      likedBy: List<String>.from(json['likedBy'] ?? []),
      viewedBy: List<String>.from(json['viewedBy'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avatar': avatar,
      'title': title,
      'author': author,
      'authorId': authorId,
      'description': description,
      'likes': likes,
      'replies': replies,
      'views': views,
      'timestamp': Timestamp.fromDate(timestamp),
      'likedBy': likedBy,
      'viewedBy': viewedBy,
    };
  }

  Discussion copyWith({
    String? id,
    String? avatar,
    String? title,
    String? author,
    String? authorId,
    String? description,
    int? likes,
    int? replies,
    int? views,
    DateTime? timestamp,
    List<String>? likedBy,
    List<String>? viewedBy,
  }) {
    return Discussion(
      id: id ?? this.id,
      avatar: avatar ?? this.avatar,
      title: title ?? this.title,
      author: author ?? this.author,
      authorId: authorId ?? this.authorId,
      description: description ?? this.description,
      likes: likes ?? this.likes,
      replies: replies ?? this.replies,
      views: views ?? this.views,
      timestamp: timestamp ?? this.timestamp,
      likedBy: likedBy ?? this.likedBy,
      viewedBy: viewedBy ?? this.viewedBy,
    );
  }
}
