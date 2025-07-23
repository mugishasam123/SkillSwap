

class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String? username;
  final String? bio;
  final String? location;
  final String? availability;
  final List<String> skillsOffered;
  final List<String> skillsWanted;
  final List<Map<String, dynamic>> reviews;
  final int swapScore;
  final bool notificationsEnabled;
  final Map<String, dynamic> privacySettings;
  final String? avatarUrl;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.username,
    this.bio,
    this.location,
    this.availability,
    required this.skillsOffered,
    required this.skillsWanted,
    required this.reviews,
    required this.swapScore,
    required this.notificationsEnabled,
    required this.privacySettings,
    this.avatarUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json, String id) {
    // Handle availability field which might be a List or String
    String? availability;
    if (json['availability'] != null) {
      if (json['availability'] is List) {
        availability = (json['availability'] as List).join(', ');
      } else {
        availability = json['availability'].toString();
      }
    }

    return UserProfile(
      uid: id,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      username: json['username'],
      bio: json['bio'],
      location: json['location'],
      availability: availability,
      skillsOffered: List<String>.from(json['skillsOffered'] ?? []),
      skillsWanted: List<String>.from(json['skillsWanted'] ?? []),
      reviews: List<Map<String, dynamic>>.from(json['reviews'] ?? []),
      swapScore: json['swapScore'] ?? 0,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      privacySettings: Map<String, dynamic>.from(json['privacySettings'] ?? {}),
      avatarUrl: json['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'username': username,
      'bio': bio,
      'location': location,
      'availability': availability,
      'skillsOffered': skillsOffered,
      'skillsWanted': skillsWanted,
      'reviews': reviews,
      'swapScore': swapScore,
      'notificationsEnabled': notificationsEnabled,
      'privacySettings': privacySettings,
      'avatarUrl': avatarUrl,
    };
  }

  UserProfile copyWith({
    String? uid,
    String? name,
    String? email,
    String? username,
    String? bio,
    String? location,
    String? availability,
    List<String>? skillsOffered,
    List<String>? skillsWanted,
    List<Map<String, dynamic>>? reviews,
    int? swapScore,
    bool? notificationsEnabled,
    Map<String, dynamic>? privacySettings,
    String? avatarUrl,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      availability: availability ?? this.availability,
      skillsOffered: skillsOffered ?? this.skillsOffered,
      skillsWanted: skillsWanted ?? this.skillsWanted,
      reviews: reviews ?? this.reviews,
      swapScore: swapScore ?? this.swapScore,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      privacySettings: privacySettings ?? this.privacySettings,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
} 