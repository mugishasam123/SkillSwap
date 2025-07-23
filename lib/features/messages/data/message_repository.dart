import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';
import '../models/chat.dart';

class MessageRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Chat>> getUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('userIds', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Chat.fromJson(doc.data(), doc.id))
              .toList(),
        );
  }

  Stream<List<Message>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Message.fromJson(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<String?> createChat({required List<String> userIds}) async {
    try {
      final newChatRef = _firestore.collection('chats').doc();
      final unreadCount = {for (final id in userIds) id: 0};
      await newChatRef.set({
        'userIds': userIds,
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount': unreadCount,
      });
      return newChatRef.id;
    } catch (e) {
      return null;
    }
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
    required List<String> userIds,
  }) async {
    try {
      final messageRef = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc();
      final now = FieldValue.serverTimestamp();
      await messageRef.set({
        'senderId': senderId,
        'text': text,
        'timestamp': now,
      });

      // Increment unreadCount for all users except sender
      final unreadCountUpdates = <String, dynamic>{};
      for (final id in userIds) {
        if (id != senderId) {
          unreadCountUpdates['unreadCount.$id'] = FieldValue.increment(1);
        }
      }
      // Always set sender's unreadCount to 0
      unreadCountUpdates['unreadCount.$senderId'] = 0;

      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': text,
        'lastMessageTime': now,
        ...unreadCountUpdates,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'unreadCount.$userId': 0,
      });
    } catch (e) {
      rethrow;
    }
  }
}
