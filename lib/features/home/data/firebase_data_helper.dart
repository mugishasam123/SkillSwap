import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDataHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Add sample swaps to Firebase
  static Future<void> addSampleSwaps() async {
    try {
      final sampleSwaps = [
        {
          'userId': 'tobi_123',
          'userName': 'Tobi',
          'userAvatar': 'assets/images/onboarding_1.png',
          'skillOffered': 'cook',
          'skillWanted': 'designing flyers',
          'description': 'I am good at cooking and want to learn graphic design to create beautiful flyers for my events.',
          'createdAt': FieldValue.serverTimestamp(),
          'location': 'Lagos, Nigeria',
          'tags': ['cooking', 'graphic design', 'events'],
          'isActive': true,
          'views': 15,
          'requests': 3,
        },
        {
          'userId': 'agnes_456',
          'userName': 'Agnes',
          'userAvatar': 'assets/images/onboarding_2.png',
          'skillOffered': 'dance',
          'skillWanted': 'video editing',
          'description': 'I am good at dancing and want to learn video editing to create amazing dance videos.',
          'createdAt': FieldValue.serverTimestamp(),
          'location': 'Nairobi, Kenya',
          'tags': ['dance', 'video editing', 'content creation'],
          'isActive': true,
          'views': 8,
          'requests': 1,
        },
        {
          'userId': 'john_789',
          'userName': 'John',
          'userAvatar': 'assets/images/onboarding_3.png',
          'skillOffered': 'coding',
          'skillWanted': 'cooking',
          'description': 'I am good at coding and want to learn how to cook delicious meals.',
          'createdAt': FieldValue.serverTimestamp(),
          'location': 'Accra, Ghana',
          'tags': ['coding', 'cooking', 'software'],
          'isActive': true,
          'views': 12,
          'requests': 2,
        },
        {
          'userId': 'sarah_012',
          'userName': 'Sarah',
          'userAvatar': 'assets/images/onboarding_1.png',
          'skillOffered': 'photography',
          'skillWanted': 'web design',
          'description': 'I am good at photography and want to learn web design to showcase my portfolio better.',
          'createdAt': FieldValue.serverTimestamp(),
          'location': 'Cape Town, South Africa',
          'tags': ['photography', 'web design', 'portfolio'],
          'isActive': true,
          'views': 6,
          'requests': 0,
        },
      ];

      // Add each swap to Firestore
      for (final swapData in sampleSwaps) {
        await _firestore.collection('swaps').add(swapData);
      }

      print('✅ Successfully added ${sampleSwaps.length} sample swaps to Firebase');
    } catch (e) {
      print('❌ Error adding sample swaps: $e');
      rethrow;
    }
  }

  /// Clear all swaps from Firebase (for testing)
  static Future<void> clearAllSwaps() async {
    try {
      final querySnapshot = await _firestore.collection('swaps').get();
      final batch = _firestore.batch();
      
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      print('✅ Successfully cleared all swaps from Firebase');
    } catch (e) {
      print('❌ Error clearing swaps: $e');
      rethrow;
    }
  }

  /// Get all swaps from Firebase (for debugging)
  static Future<List<Map<String, dynamic>>> getAllSwaps() async {
    try {
      final querySnapshot = await _firestore.collection('swaps').get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('❌ Error getting swaps: $e');
      rethrow;
    }
  }
} 