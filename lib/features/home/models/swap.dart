import 'package:cloud_firestore/cloud_firestore.dart';

class Swap {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String skillOffered;
  final String skillWanted;
  final String description;
  final DateTime createdAt;
  final String location;
  final List<String> tags;
  final bool isActive;
  final int views;
  final int requests;
  final String? imageUrl; // New field for swap image

  Swap({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.skillOffered,
    required this.skillWanted,
    required this.description,
    required this.createdAt,
    required this.location,
    required this.tags,
    required this.isActive,
    required this.views,
    required this.requests,
    this.imageUrl, // Optional image URL
  });

  factory Swap.fromJson(Map<String, dynamic> json, String id) {
    return Swap(
      id: id,
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userAvatar: json['userAvatar'] ?? 'assets/images/logo.png',
      skillOffered: json['skillOffered'] ?? '',
      skillWanted: json['skillWanted'] ?? '',
      description: json['description'] ?? '',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      location: json['location'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      isActive: json['isActive'] ?? true,
      views: json['views'] ?? 0,
      requests: json['requests'] ?? 0,
      imageUrl: json['imageUrl'], // Parse image URL
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'skillOffered': skillOffered,
      'skillWanted': skillWanted,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'location': location,
      'tags': tags,
      'isActive': isActive,
      'views': views,
      'requests': requests,
      'imageUrl': imageUrl, // Include image URL in JSON
    };
  }

  Swap copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    String? skillOffered,
    String? skillWanted,
    String? description,
    DateTime? createdAt,
    String? location,
    List<String>? tags,
    bool? isActive,
    int? views,
    int? requests,
    String? imageUrl, // Add imageUrl to copyWith
  }) {
    return Swap(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      skillOffered: skillOffered ?? this.skillOffered,
      skillWanted: skillWanted ?? this.skillWanted,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      isActive: isActive ?? this.isActive,
      views: views ?? this.views,
      requests: requests ?? this.requests,
      imageUrl: imageUrl ?? this.imageUrl, // Include in copyWith
    );
  }
} 