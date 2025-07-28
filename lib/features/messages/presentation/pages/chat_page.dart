import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/message_repository.dart';
import '../../models/message.dart';

class ChatPage extends StatefulWidget {
  final String chatId;
  final String otherUserId;
  final String otherUserName;
  final String otherUserAvatar;
  final List<String> userIds;

  const ChatPage({
    super.key,
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserAvatar,
    required this.userIds,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final MessageRepository repository = MessageRepository();
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _markChatAsRead();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _markChatAsRead();
  }

  void _markChatAsRead() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted) {
          try {
            await repository.markMessagesAsRead(widget.chatId, userId);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to mark messages as read: $e')),
            );
          }
        }
      });
    }
  }

  Future<void> _sendMessage(String text) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (text.isEmpty || userId == null) return;
    try {
      await repository.sendMessage(
        chatId: widget.chatId,
        senderId: userId,
        text: text,
        userIds: widget.userIds,
      );
      _controller.clear();
      // Mark as read for sender after sending
      await repository.markMessagesAsRead(widget.chatId, userId);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark 
          ? const Color(0xFF121212)
          : Colors.white,
      appBar: AppBar(
        leading: BackButton(
          color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.white 
              : Colors.black,
        ),
        title: Row(
          children: [
            CircleAvatar(backgroundImage: AssetImage(widget.otherUserAvatar)),
            const SizedBox(width: 8),
            Text(
              widget.otherUserName,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white 
                    : Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_none,
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.white 
                  : Colors.black,
            ),
            onPressed: () {},
          ),
        ],
        backgroundColor: Theme.of(context).brightness == Brightness.dark 
            ? const Color(0xFF121212)
            : Colors.white,
        foregroundColor: Theme.of(context).brightness == Brightness.dark 
            ? Colors.white 
            : Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: repository.getMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.grey[400]
                            : Colors.grey[600],
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!;
                return Scrollbar(
                  thumbVisibility: true,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 8,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.senderId == userId;
                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Row(
                          mainAxisAlignment: isMe
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!isMe)
                              Padding(
                                padding: const EdgeInsets.only(right: 4.0),
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundImage: AssetImage(
                                    widget.otherUserAvatar,
                                  ),
                                ),
                              ),
                            Flexible(
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isMe 
                                      ? (Theme.of(context).brightness == Brightness.dark 
                                          ? const Color(0xFF1976D2)
                                          : Colors.blue)
                                      : (Theme.of(context).brightness == Brightness.dark 
                                          ? const Color(0xFFF57C00)
                                          : Colors.orange),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Text(
                                  message.text,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            if (isMe)
                              Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundImage: AssetImage(
                                    'assets/images/logo.png',
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white 
                          : Colors.black,
                    ),
                    onSubmitted: _sendMessage,
                    decoration: InputDecoration(
                      hintText: 'Type message here...',
                      hintStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.grey[400]
                            : Colors.grey[600],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark 
                          ? const Color(0xFF2A2A2A)
                          : Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () => _sendMessage(_controller.text.trim()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

    );
  }
}
