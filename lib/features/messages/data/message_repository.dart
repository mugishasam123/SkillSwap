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

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
    required List<String> userIds,
  }) async {
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
    await _firestore.collection('chats').doc(chatId).set({
      'userIds': userIds,
      'lastMessage': text,
      'lastMessageTime': now,
      'unreadCount': {
        for (var id in userIds)
          id: id == senderId ? 0 : FieldValue.increment(1),
      },
    }, SetOptions(merge: true));
  }

  Future<void> markMessagesAsRead(String chatId, String userId) async {
    await _firestore.collection('chats').doc(chatId).set({
      'unreadCount.$userId': 0,
    }, SetOptions(merge: true));
  }
}
