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
  final ScrollController _scrollController = ScrollController();
  List<Chat> _chats = [];
  String _searchQuery = '';
  bool _isLoading = true;
  int _unreadCount = 0;
  Stream<List<Chat>>? _chatStream;
  bool _isHeaderVisible = true;
  double _lastScrollPosition = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
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

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final currentPosition = _scrollController.position.pixels;
    
    // Add a small threshold to prevent jittery behavior
    const scrollThreshold = 10.0;
    
    // Show header when scrolling up, hide when scrolling down
    if (currentPosition > _lastScrollPosition + scrollThreshold && _isHeaderVisible) {
      // Scrolling down - hide header
      setState(() {
        _isHeaderVisible = false;
      });
    } else if (currentPosition < _lastScrollPosition - scrollThreshold && !_isHeaderVisible) {
      // Scrolling up - show header
      setState(() {
        _isHeaderVisible = true;
      });
    }
    
    _lastScrollPosition = currentPosition;
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

    // Get screen dimensions and orientation
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final padding = mediaQuery.padding;
    
    // Calculate responsive values
    final topPadding = isLandscape ? padding.top + 8 : padding.top + 16;
    final horizontalPadding = isLandscape ? 24.0 : 16.0;
    final headerHeight = isLandscape ? 60.0 : 80.0;
    final searchHeight = isLandscape ? 50.0 : 60.0;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark 
          ? const Color(0xFF121212)
          : Colors.white,
      body: SafeArea(
        child: Column(
        children: [
            // Collapsible header with animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: _isHeaderVisible ? headerHeight : 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _isHeaderVisible ? 1.0 : 0.0,
                child: Container(
                  padding: EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                      Expanded(
                        child: _buildHeader(context, _unreadCount, isLandscape),
                      ),
                IconButton(
                  icon: Icon(
                    _unreadCount > 0
                        ? Icons.notifications
                        : Icons.notifications_none,
                    color: _unreadCount > 0 
                        ? Colors.orange 
                        : (Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white 
                            : Colors.black),
                          size: isLandscape ? 24 : 28,
                  ),
                  onPressed: () {},
                  tooltip: 'Notifications',
                ),
              ],
            ),
          ),
              ),
            ),
            
            // Responsive spacing (only when header is visible)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _isHeaderVisible ? (isLandscape ? 12 : 20) : 0,
            ),
            
            // Collapsible search bar with animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: _isHeaderVisible ? searchHeight : 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _isHeaderVisible ? 1.0 : 0.0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: TextField(
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white 
                    : Colors.black,
                      fontSize: isLandscape ? 14 : 16,
              ),
              textInputAction: TextInputAction.search,
              keyboardType: TextInputType.text,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search here',
                hintStyle: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.grey[400]
                      : Colors.grey[600],
                        fontSize: isLandscape ? 14 : 16,
                ),
                suffixIcon: Container(
                        margin: EdgeInsets.all(isLandscape ? 4 : 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? const Color(0xFF3E8E7E)
                        : const Color(0xFF225B4B),
                          borderRadius: BorderRadius.circular(isLandscape ? 8 : 10),
                  ),
                        width: isLandscape ? 32 : 36,
                        height: isLandscape ? 32 : 36,
                        child: Icon(
                    Icons.search,
                    color: Colors.white,
                          size: isLandscape ? 18 : 22,
                  ),
                ),
                border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(isLandscape ? 12 : 16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark 
                    ? const Color(0xFF2A2A2A)
                    : Colors.grey[200],
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isLandscape ? 12 : 16,
                        vertical: isLandscape ? 8 : 12,
                      ),
                    ),
                  ),
              ),
            ),
          ),
            
            // Responsive spacing (only when header is visible)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _isHeaderVisible ? (isLandscape ? 8 : 16) : 0,
            ),
            
            // Chat list with responsive sizing and scroll controller
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredChats.isEmpty
                ? Center(
                    child: Text(
                      'No messages yet.',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.grey[400]
                            : Colors.grey[600],
                          fontSize: isLandscape ? 14 : 16,
                      ),
                    ),
                  )
                : Scrollbar(
                    thumbVisibility: true,
                      controller: _scrollController,
                    child: ListView.builder(
                        controller: _scrollController,
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
                              return Container(
                                height: isLandscape ? 70 : 80,
                                padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding,
                                  vertical: isLandscape ? 4 : 8,
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                    radius: isLandscape ? 20 : 24,
                                backgroundImage: avatar.startsWith('http')
                                    ? NetworkImage(avatar)
                                    : AssetImage(avatar) as ImageProvider,
                              ),
                              title: Text(
                                name,
                                style: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.dark 
                                      ? Colors.white 
                                      : Colors.black,
                                      fontSize: isLandscape ? 14 : 16,
                                      fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                chat.lastMessage,
                                style: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.dark 
                                      ? Colors.grey[300]
                                      : Colors.grey[600],
                                      fontSize: isLandscape ? 12 : 14,
                                ),
                                    maxLines: isLandscape ? 1 : 2,
                                    overflow: TextOverflow.ellipsis,
                              ),
                                                              trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _formatTime(chat.lastMessageTime),
                                      style: TextStyle(
                                        color: Theme.of(context).brightness == Brightness.dark 
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                          fontSize: isLandscape ? 11 : 12,
                                      ),
                                    ),
                                  if ((chat.unreadCount[userId] ?? 0) > 0)
                                    Container(
                                          margin: EdgeInsets.only(top: isLandscape ? 2 : 4),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isLandscape ? 6 : 8,
                                            vertical: isLandscape ? 1 : 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                            borderRadius: BorderRadius.circular(isLandscape ? 8 : 12),
                                      ),
                                      child: Text(
                                        '${chat.unreadCount[userId]}',
                                            style: TextStyle(
                                          color: Colors.white,
                                              fontSize: isLandscape ? 10 : 12,
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
                                ),
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _startNewChat(context, userId),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int unreadCount, bool isLandscape) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: isLandscape ? 18 : 22,
              backgroundImage: const AssetImage('assets/images/logo.png'),
            ),
            Positioned(
              bottom: isLandscape ? 1 : 2,
              right: isLandscape ? 1 : 2,
              child: Container(
                width: isLandscape ? 8 : 10,
                height: isLandscape ? 8 : 10,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white, 
                    width: isLandscape ? 1.5 : 2,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(width: isLandscape ? 8 : 12),
        Expanded(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'My Messages',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                  fontSize: isLandscape ? 16 : 20,
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white 
                    : Colors.black,
              ),
            ),
            if (unreadCount > 0)
              Text(
                '$unreadCount new message${unreadCount > 1 ? 's' : ''}',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.grey[400]
                      : const Color(0xFFB0B0B0),
                  fontWeight: FontWeight.w500,
                    fontSize: isLandscape ? 12 : 15,
                  ),
                ),
            ],
              ),
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
