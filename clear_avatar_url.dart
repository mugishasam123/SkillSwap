// Temporary script to clear invalid avatar URL
// Run this once to fix the current issue

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> clearInvalidAvatarUrl() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'avatarUrl': ''});
      print('Successfully cleared invalid avatar URL for user: ${user.uid}');
    } else {
      print('No user is currently authenticated');
    }
  } catch (e) {
    print('Error clearing avatar URL: $e');
  }
} 