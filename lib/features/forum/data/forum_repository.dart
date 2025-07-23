import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/discussion.dart';
import '../models/reply.dart';

class ForumRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get all discussions ordered by timestamp
  Stream<List<Discussion>> getDiscussions() {
    return _firestore
        .collection('discussions')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Discussion.fromJson(doc.data(), doc.id))
              .toList(),
        );
  }

  // Create a new discussion
  Future<void> createDiscussion({
    required String title,
    required String description,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data();
    final userName = userData?['name'] ?? 'Anonymous';
    final userAvatar = userData?['avatarUrl'] ?? 'assets/images/logo.png';

    await _firestore.collection('discussions').add({
      'title': title,
      'description': description,
      'author': userName,
      'authorId': user.uid,
      'avatar': userAvatar,
      'likes': 0,
      'replies': 0,
      'views': 0,
      'timestamp': FieldValue.serverTimestamp(),
      'likedBy': [],
      'viewedBy': [],
    });
  }

  // Calculate time ago from timestamp
  String getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
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

  // Get replies for a specific discussion
  Stream<List<Reply>> getReplies(String discussionId) {
    return _firestore
        .collection('replies')
        .where('discussionId', isEqualTo: discussionId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            return <Reply>[];
          }
          try {
            return snapshot.docs
                .map((doc) => Reply.fromJson(doc.data(), doc.id))
                .toList();
          } catch (e) {
            print('Error parsing replies: $e');
            return <Reply>[];
          }
        })
        .handleError((error) {
          print('Error getting replies: $error');
          return <Reply>[];
        });
  }

  // Add a reply to a discussion
  Future<void> addReply({
    required String discussionId,
    required String content,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data();
    final userName = userData?['name'] ?? 'Anonymous';
    final userAvatar = userData?['avatarUrl'] ?? 'assets/images/logo.png';

    // Add the reply
    await _firestore.collection('replies').add({
      'discussionId': discussionId,
      'authorId': user.uid,
      'author': userName,
      'authorAvatar': userAvatar,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
      'likes': 0,
      'likedBy': [],
    });

    // Increment reply count on the discussion
    await _firestore.collection('discussions').doc(discussionId).update({
      'replies': FieldValue.increment(1),
    });
  }

  // Like/unlike a discussion
  Future<void> toggleLikeDiscussion(String discussionId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final discussionDoc = await _firestore
        .collection('discussions')
        .doc(discussionId)
        .get();

    if (!discussionDoc.exists) return;

    final discussion = Discussion.fromJson(discussionDoc.data()!, discussionId);
    final likedBy = List<String>.from(discussion.likedBy);

    if (likedBy.contains(user.uid)) {
      // Unlike
      likedBy.remove(user.uid);
      await _firestore.collection('discussions').doc(discussionId).update({
        'likes': FieldValue.increment(-1),
        'likedBy': likedBy,
      });
    } else {
      // Like
      likedBy.add(user.uid);
      await _firestore.collection('discussions').doc(discussionId).update({
        'likes': FieldValue.increment(1),
        'likedBy': likedBy,
      });
    }
  }

  // Increment view count
  Future<void> incrementViews(String discussionId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final discussionRef = _firestore
        .collection('discussions')
        .doc(discussionId);
    final discussionDoc = await discussionRef.get();

    if (!discussionDoc.exists) return;

    final discussion = Discussion.fromJson(discussionDoc.data()!, discussionId);
    final viewedBy = List<String>.from(discussion.viewedBy);

    if (!viewedBy.contains(user.uid)) {
      viewedBy.add(user.uid);
      await discussionRef.update({
        'views': FieldValue.increment(1),
        'viewedBy': viewedBy,
      });
    }
  }

  // Get a single discussion by ID
  Future<Discussion?> getDiscussion(String discussionId) async {
    final doc = await _firestore
        .collection('discussions')
        .doc(discussionId)
        .get();
    if (doc.exists) {
      return Discussion.fromJson(doc.data()!, doc.id);
    }
    return null;
  }
}
