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
    
    // Get screen dimensions and orientation
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    
    // Calculate responsive values
    final appBarHeight = isLandscape ? 50.0 : 56.0;
    final avatarRadius = isLandscape ? 16.0 : 20.0;
    final messagePadding = isLandscape ? 8.0 : 12.0;
    final inputHeight = isLandscape ? 45.0 : 55.0;
    
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark 
          ? const Color(0xFF121212)
          : Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: AppBar(
          leading: BackButton(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white 
                : Colors.black,
          ),
          title: Row(
            children: [
              CircleAvatar(
                radius: avatarRadius,
                backgroundImage: AssetImage(widget.otherUserAvatar),
              ),
              SizedBox(width: isLandscape ? 6 : 8),
              Expanded(
                child: Text(
                  widget.otherUserName,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white 
                        : Colors.black,
                    fontSize: isLandscape ? 16 : 18,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
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
                size: isLandscape ? 20 : 24,
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
      ),
      body: SafeArea(
        child: Column(
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
                          fontSize: isLandscape ? 14 : 16,
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
                      padding: EdgeInsets.symmetric(
                        vertical: isLandscape ? 8 : 16,
                        horizontal: isLandscape ? 4 : 8,
                      ),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMe = message.senderId == userId;
                        return Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              vertical: isLandscape ? 2 : 4,
                              horizontal: isLandscape ? 4 : 8,
                            ),
                            child: Row(
                              mainAxisAlignment: isMe
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (!isMe)
                                  Padding(
                                    padding: EdgeInsets.only(right: isLandscape ? 3.0 : 4.0),
                                    child: CircleAvatar(
                                      radius: isLandscape ? 12 : 16,
                                      backgroundImage: AssetImage(
                                        widget.otherUserAvatar,
                                      ),
                                    ),
                                  ),
                                Flexible(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isLandscape ? 12 : 16,
                                      vertical: isLandscape ? 8 : 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isMe 
                                          ? (Theme.of(context).brightness == Brightness.dark 
                                              ? const Color(0xFF1976D2)
                                              : Colors.blue)
                                          : (Theme.of(context).brightness == Brightness.dark 
                                              ? const Color(0xFFF57C00)
                                              : Colors.orange),
                                      borderRadius: BorderRadius.circular(isLandscape ? 16 : 24),
                                    ),
                                    child: Text(
                                      message.text,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isLandscape ? 13 : 14,
                                      ),
                                    ),
                                  ),
                                ),
                                if (isMe)
                                  Padding(
                                    padding: EdgeInsets.only(left: isLandscape ? 3.0 : 4.0),
                                    child: CircleAvatar(
                                      radius: isLandscape ? 12 : 16,
                                      backgroundImage: const AssetImage(
                                        'assets/images/logo.png',
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            // Responsive input area
            Container(
              height: inputHeight + 24, // Add padding
              padding: EdgeInsets.all(isLandscape ? 8.0 : 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: inputHeight,
                      child: TextField(
                        controller: _controller,
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.white 
                              : Colors.black,
                          fontSize: isLandscape ? 14 : 16,
                        ),
                        onSubmitted: _sendMessage,
                        decoration: InputDecoration(
                          hintText: 'Type message here...',
                          hintStyle: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark 
                                ? Colors.grey[400]
                                : Colors.grey[600],
                            fontSize: isLandscape ? 14 : 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(isLandscape ? 20 : 24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Theme.of(context).brightness == Brightness.dark 
                              ? const Color(0xFF2A2A2A)
                              : Colors.grey[200],
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isLandscape ? 16 : 20,
                            vertical: isLandscape ? 8 : 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: isLandscape ? 6 : 8),
                  CircleAvatar(
                    radius: isLandscape ? 20 : 24,
                    backgroundColor: Colors.orange,
                    child: IconButton(
                      icon: Icon(
                        Icons.send, 
                        color: Colors.white,
                        size: isLandscape ? 18 : 20,
                      ),
                      onPressed: () => _sendMessage(_controller.text.trim()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
