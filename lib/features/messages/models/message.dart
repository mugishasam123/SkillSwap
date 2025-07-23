import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json, String id) {
    final timestampRaw = json['timestamp'];
    DateTime timestamp;
    if (timestampRaw == null) {
      timestamp = DateTime.now();
    } else if (timestampRaw is Timestamp) {
      timestamp = timestampRaw.toDate();
    } else if (timestampRaw is DateTime) {
      timestamp = timestampRaw;
    } else {
      timestamp = DateTime.now();
    }
    return Message(
      id: id,
      senderId: json['senderId'] as String? ?? '',
      text: json['text'] as String? ?? '',
      timestamp: timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {'senderId': senderId, 'text': text, 'timestamp': timestamp};
  }
}
