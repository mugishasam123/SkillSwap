import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import '../models/swap.dart';
import '../../profile/data/image_upload_service.dart';
import 'package:flutter/material.dart';

class SwapRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImageUploadService _imageUploadService = ImageUploadService();

  // Get all active swaps
  Stream<List<Swap>> getAllSwaps() {
    return _firestore
        .collection('swaps')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Swap.fromJson(doc.data(), doc.id))
              .where((swap) => swap.isActive) // Filter in memory instead
              .toList(),
        );
  }

  // Get suggested swaps based on user preferences
  Stream<List<Swap>> getSuggestedSwaps() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('swaps')
        .orderBy('createdAt', descending: true)
        .limit(20) // Get more to filter in memory
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Swap.fromJson(doc.data(), doc.id))
              .where((swap) => swap.isActive && swap.userId != user.uid) // Filter in memory
              .take(10) // Limit to 10
              .toList(),
        );
  }

  // Create a new swap with optional image
  Future<void> createSwap({
    required String skillOffered,
    required String skillWanted,
    required String description,
    required String location,
    required List<String> tags,
    File? imageFile, // Optional image file
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data();
    final userName = userData?['name'] ?? 'Anonymous';
    final userAvatar = userData?['avatarUrl'] ?? 'assets/images/logo.png';

    // Upload image if provided
    String? imageUrl;
    if (imageFile != null) {
      try {
        imageUrl = await _imageUploadService.uploadSwapImage(imageFile);
      } catch (e) {
        print('Error uploading swap image: $e');
        // Continue without image if upload fails
      }
    }

    await _firestore.collection('swaps').add({
      'userId': user.uid,
      'userName': userName,
      'userAvatar': userAvatar,
      'skillOffered': skillOffered,
      'skillWanted': skillWanted,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
      'location': location,
      'tags': tags,
      'isActive': true,
      'views': 0,
      'requests': 0,
      'imageUrl': imageUrl, // Include image URL if available
    });
  }

  // Request a swap
  Future<void> requestSwap(
    String swapId, {
    String? platform,
    DateTime? date,
    TimeOfDay? time,
    String? learn,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('swaps').doc(swapId).update({
      'requests': FieldValue.increment(1),
    });

    // Create a swap request
    await _firestore.collection('swapRequests').add({
      'swapId': swapId,
      'requesterId': user.uid,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      if (platform != null) 'platform': platform,
      if (date != null) 'date': Timestamp.fromDate(date),
      if (time != null) 'time': '${time.hour}:${time.minute}',
      if (learn != null) 'learn': learn,
    });
  }

  // Increment view count
  Future<void> incrementViews(String swapId) async {
    await _firestore.collection('swaps').doc(swapId).update({
      'views': FieldValue.increment(1),
    });
  }

  // Get time ago from timestamp
  String getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '${years} year${years == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '${months} month${months == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  // Create sample swaps for testing
  Future<void> createSampleSwaps() async {
    final sampleSwaps = [
      {
        'userName': 'Tobi',
        'userAvatar': 'assets/images/onboarding_1.png',
        'skillOffered': 'cook',
        'skillWanted': 'designing flyers',
        'description': 'I am good at cooking and want to learn graphic design to create beautiful flyers for my events.',
        'location': 'Lagos, Nigeria',
        'tags': ['cooking', 'graphic design', 'events'],
        'imageUrl': 'assets/images/onboarding_1.png', // Add sample image
      },
      {
        'userName': 'Agnes',
        'userAvatar': 'assets/images/onboarding_2.png',
        'skillOffered': 'dance',
        'skillWanted': 'video editing',
        'description': 'I am good at dancing and want to learn video editing to create amazing dance videos.',
        'location': 'Nairobi, Kenya',
        'tags': ['dance', 'video editing', 'content creation'],
        'imageUrl': 'assets/images/onboarding_2.png', // Add sample image
      },
      {
        'userName': 'Tobi',
        'userAvatar': 'assets/images/onboarding_1.png',
        'skillOffered': 'cook',
        'skillWanted': 'designing flyers',
        'description': 'I am good at cooking and want to learn graphic design to create beautiful flyers for my events.',
        'location': 'Lagos, Nigeria',
        'tags': ['cooking', 'graphic design', 'events'],
        'imageUrl': 'assets/images/onboarding_3.png', // Add sample image
      },
      {
        'userName': 'Agnes',
        'userAvatar': 'assets/images/onboarding_2.png',
        'skillOffered': 'dance',
        'skillWanted': 'video editing',
        'description': 'I am good at dancing and want to learn video editing to create amazing dance videos.',
        'location': 'Nairobi, Kenya',
        'tags': ['dance', 'video editing', 'content creation'],
        'imageUrl': 'assets/images/onboarding_1.png', // Add sample image
      },
    ];

    for (final swapData in sampleSwaps) {
      await _firestore.collection('swaps').add({
        'userId': 'sample_user_${DateTime.now().millisecondsSinceEpoch}',
        'userName': swapData['userName'],
        'userAvatar': swapData['userAvatar'],
        'skillOffered': swapData['skillOffered'],
        'skillWanted': swapData['skillWanted'],
        'description': swapData['description'],
        'createdAt': FieldValue.serverTimestamp(),
        'location': swapData['location'],
        'tags': swapData['tags'],
        'isActive': true,
        'views': 0,
        'requests': 0,
        'imageUrl': swapData['imageUrl'], // Include image URL
      });
    }
  }
} 