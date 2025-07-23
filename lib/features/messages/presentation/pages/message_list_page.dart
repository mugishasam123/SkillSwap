import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/message_repository.dart';
import '../../models/chat.dart';
import 'chat_page.dart';

class MessageListPage extends StatefulWidget {
  const MessageListPage({super.key});

  @override
  State<MessageListPage> createState() => _MessageListPageState();
}

class _MessageListPageState extends State<MessageListPage> {
  final MessageRepository repository = MessageRepository();
  List<Chat> _chats = [];
  String _searchQuery = '';
  bool _isLoading = true;
  int _unreadCount = 0;
  Stream<List<Chat>>? _chatStream;

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      _chatStream = repository.getUserChats(userId);
      _chatStream!.listen(
        (chats) {
          if (!mounted) return;
          setState(() {
            _chats = chats;
            _isLoading = false;
            _unreadCount = chats
                .map((chat) => chat.unreadCount[userId] ?? 0)
                .fold(0, (prev, count) => prev + count);
          });
        },
        onError: (e) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to load chats: $e')));
        },
      );
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>?> _getUserInfo(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load user info: $e')));
      return null;
    }
  }

  Future<void> _startNewChat(BuildContext context, String currentUserId) async {
    showDialog(
      context: context,
      builder: (context) {
        return _UserSearchDialog(
          currentUserId: currentUserId,
          onUserSelected: (userId, name, avatarUrl) async {
            Navigator.of(context).pop();
            try {
              // Check if chat exists
              final chatQuery = await FirebaseFirestore.instance
                  .collection('chats')
                  .where('userIds', arrayContains: currentUserId)
                  .get();
              String? chatId;
              for (var doc in chatQuery.docs) {
                final userIds = List<String>.from(doc['userIds']);
                if (userIds.contains(userId) && userIds.length == 2) {
                  chatId = doc.id;
                  break;
                }
              }
              if (chatId == null) {
                chatId = await repository.createChat(
                  userIds: [currentUserId, userId],
                );
                if (chatId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to create chat.')),
                  );
                  return;
                }
              }
              if (!mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    chatId: chatId!,
                    otherUserId: userId,
                    otherUserName: name,
                    otherUserAvatar: avatarUrl,
                    userIds: [currentUserId, userId],
                  ),
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to start chat: $e')),
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return const Center(child: Text('Not logged in'));
    }
    final filteredChats = _chats
        .where(
          (chat) => chat.lastMessage.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ),
        )
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 36, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, _unreadCount),
                IconButton(
                  icon: Icon(
                    _unreadCount > 0
                        ? Icons.notifications
                        : Icons.notifications_none,
                    color: _unreadCount > 0 ? Colors.orange : Colors.black,
                    size: 28,
                  ),
                  onPressed: () {},
                  tooltip: 'Notifications',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search here',
                suffixIcon: Container(
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF225B4B),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: 36,
                  height: 36,
                  child: const Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredChats.isEmpty
                ? const Center(child: Text('No messages yet.'))
                : Scrollbar(
                    thumbVisibility: true,
                    child: ListView.builder(
                      itemCount: filteredChats.length,
                      itemBuilder: (context, index) {
                        final chat = filteredChats[index];
                        final otherUserId = chat.userIds.firstWhere(
                          (id) => id != userId,
                        );
                        return FutureBuilder<Map<String, dynamic>?>(
                          future: _getUserInfo(otherUserId),
                          builder: (context, userSnapshot) {
                            final userData = userSnapshot.data;
                            final avatar =
                                userData?['avatarUrl'] ??
                                'assets/images/logo.png';
                            final name = userData?['name'] ?? 'User';
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: avatar.startsWith('http')
                                    ? NetworkImage(avatar)
                                    : AssetImage(avatar) as ImageProvider,
                              ),
                              title: Text(name),
                              subtitle: Text(chat.lastMessage),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(_formatTime(chat.lastMessageTime)),
                                  if ((chat.unreadCount[userId] ?? 0) > 0)
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${chat.unreadCount[userId]}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatPage(
                                      chatId: chat.id,
                                      otherUserId: otherUserId,
                                      otherUserName: name,
                                      otherUserAvatar: avatar,
                                      userIds: chat.userIds,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _startNewChat(context, userId),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              // Already on messages
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/settings');
              break;
          }
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int unreadCount) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundImage: AssetImage('assets/images/logo.png'),
            ),
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Messages',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black,
              ),
            ),
            if (unreadCount > 0)
              Text(
                '$unreadCount new message${unreadCount > 1 ? 's' : ''}',
                style: const TextStyle(
                  color: Color(0xFFB0B0B0),
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
          ],
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.difference(time).inDays == 0) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else if (now.difference(time).inDays == 1) {
      return 'Yesterday';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}

class _UserSearchDialog extends StatefulWidget {
  final String currentUserId;
  final void Function(String userId, String name, String avatarUrl)
  onUserSelected;
  const _UserSearchDialog({
    required this.currentUserId,
    required this.onUserSelected,
  });

  @override
  State<_UserSearchDialog> createState() => _UserSearchDialogState();
}

class _UserSearchDialogState extends State<_UserSearchDialog> {
  String _search = '';
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Start New Chat'),
      content: SizedBox(
        width: 300,
        height: 400,
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(hintText: 'Search users...'),
              onChanged: (val) =>
                  setState(() => _search = val.trim().toLowerCase()),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data!.docs
                      .where((doc) => doc.id != widget.currentUserId)
                      .toList();
                  final filtered = _search.isEmpty
                      ? docs
                      : docs
                            .where(
                              (doc) => (doc['name'] as String)
                                  .toLowerCase()
                                  .contains(_search),
                            )
                            .toList();
                  if (filtered.isEmpty) {
                    return const Center(child: Text('No users found.'));
                  }
                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final user = filtered[index];
                      final data = user.data() as Map<String, dynamic>;
                      final name = data['name'] ?? 'User';
                      final avatar = data.containsKey('avatarUrl')
                          ? data['avatarUrl']
                          : 'assets/images/logo.png';
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: avatar.startsWith('http')
                              ? NetworkImage(avatar)
                              : AssetImage(avatar) as ImageProvider,
                        ),
                        title: Text(name),
                        onTap: () =>
                            widget.onUserSelected(user.id, name, avatar),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
