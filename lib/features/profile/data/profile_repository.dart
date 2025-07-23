import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import 'image_upload_service.dart';
import 'local_image_service.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImageUploadService _imageUploadService = ImageUploadService();
  final LocalImageService _localImageService = LocalImageService();

  // Get current user profile
  Stream<UserProfile?> getCurrentUserProfile() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        try {
          return UserProfile.fromJson(doc.data()!, doc.id);
        } catch (e) {
          // If there's an error parsing the data, create a default profile
          print('Error parsing user profile: $e');
          return UserProfile(
            uid: user.uid,
            name: doc.data()?['name'] ?? 'User',
            email: doc.data()?['email'] ?? '',
            username: doc.data()?['username'],
            bio: doc.data()?['bio'],
            location: doc.data()?['location'],
            availability: '',
            skillLibrary: [],
            reviews: [],
            swapScore: doc.data()?['swapScore'] ?? 0,
            notificationsEnabled: doc.data()?['notificationsEnabled'] ?? true,
            privacySettings: {},
          );
        }
      }
      return null;
    });
  }

  // Update user profile
  Future<void> updateProfile({
    String? name,
    String? username,
    String? bio,
    String? location,
    String? availability,
    List<String>? skillLibrary,
    String? avatarUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final updateData = <String, dynamic>{};
    
    if (name != null) updateData['name'] = name;
    if (username != null) updateData['username'] = username;
    if (bio != null) updateData['bio'] = bio;
    if (location != null) updateData['location'] = location;
    if (availability != null) updateData['availability'] = availability;
    if (skillLibrary != null) updateData['skillLibrary'] = skillLibrary;
    if (avatarUrl != null) updateData['avatarUrl'] = avatarUrl;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .update(updateData);
  }

  // Add skill to library
  Future<void> addSkill(String skill) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(user.uid)
        .update({
      'skillLibrary': FieldValue.arrayUnion([skill]),
    });
  }

  // Remove skill from library
  Future<void> removeSkill(String skill) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(user.uid)
        .update({
      'skillLibrary': FieldValue.arrayRemove([skill]),
    });
  }

  // Add review
  Future<void> addReview({
    required String reviewerName,
    required String reviewText,
    required int rating,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final review = {
      'reviewerName': reviewerName,
      'reviewText': reviewText,
      'rating': rating,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection('users')
        .doc(user.uid)
        .update({
      'reviews': FieldValue.arrayUnion([review]),
    });
  }

  // Update swap score
  Future<void> updateSwapScore(int newScore) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(user.uid)
        .update({
      'swapScore': newScore,
    });
  }

  // Update notification settings
  Future<void> updateNotificationSettings(bool enabled) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(user.uid)
        .update({
      'notificationsEnabled': enabled,
    });
  }

  // Update privacy settings
  Future<void> updatePrivacySettings(Map<String, dynamic> settings) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(user.uid)
        .update({
      'privacySettings': settings,
    });
  }

  // Upload profile image with fallback to local storage
  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Compress image first
      final File compressedImage = await _localImageService.compressImage(imageFile);

      // Get current profile to delete old image
      final currentProfile = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      
      final currentData = currentProfile.data();
      final currentAvatarUrl = currentData?['avatarUrl'] as String?;

      String? imageUrl;

      // Try Firebase Storage first
      try {
        imageUrl = await _imageUploadService.uploadImage(compressedImage);
        print('Successfully uploaded to Firebase Storage: $imageUrl');
      } catch (firebaseError) {
        print('Firebase Storage upload failed: $firebaseError');
        
        // Show user-friendly error message
        if (firebaseError.toString().contains('object-not-found') || 
            firebaseError.toString().contains('storage/unauthorized')) {
          throw Exception('Firebase Storage is not configured properly. Please contact support or try again later.');
        } else if (firebaseError.toString().contains('NetworkException') || 
                   firebaseError.toString().contains('SocketException')) {
          throw Exception('Network connection failed. Please check your internet connection and try again.');
        } else {
          throw Exception('Upload failed: $firebaseError');
        }
      }

      if (imageUrl != null) {
        // Update profile with new image URL
        await _firestore
            .collection('users')
            .doc(user.uid)
            .update({
          'avatarUrl': imageUrl,
        });

        // Delete old images
        if (currentAvatarUrl != null && currentAvatarUrl.isNotEmpty) {
          if (currentAvatarUrl.startsWith('local://')) {
            // Delete old local image
            final oldPath = currentAvatarUrl.replaceFirst('local://', '');
            final oldFile = File(oldPath);
            if (await oldFile.exists()) {
              await oldFile.delete();
            }
          } else {
            // Delete old Firebase image
            try {
              await _imageUploadService.deleteOldImage(currentAvatarUrl);
            } catch (e) {
              print('Failed to delete old Firebase image: $e');
            }
          }
        }

        // Clean up old local images
        await _localImageService.deleteOldImages(user.uid);

        return imageUrl;
      }
      
      return null;
    } catch (e) {
      print('Error uploading profile image: $e');
      rethrow;
    }
  }

  // Pick and upload profile image
  Future<String?> pickAndUploadProfileImage() async {
    try {
      final imageFile = await _imageUploadService.pickImageFromGallery();
      if (imageFile != null) {
        return await uploadProfileImage(imageFile);
      }
      return null;
    } catch (e) {
      print('Error picking and uploading profile image: $e');
      return null;
    }
  }

  // Get user profile by ID (for viewing other users' profiles)
  Future<UserProfile?> getUserProfileById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserProfile.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error fetching user profile by id: $e');
      return null;
    }
  }

  // Stream all users
  Stream<List<UserProfile>> getAllUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => UserProfile.fromJson(doc.data(), doc.id)).toList();
    });
  }
} 