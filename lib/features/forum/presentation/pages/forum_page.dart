import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/discussion.dart';
import '../../data/forum_repository.dart';
import 'post_details_page.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  final TextEditingController _messageController = TextEditingController();
  final ForumRepository _repository = ForumRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _showInputBar = false;
  final FocusNode _focusNode = FocusNode();

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      final title = message.length > 50
          ? '${message.substring(0, 50)}...'
          : message;
      _repository.createDiscussion(title: title, description: message);
      _messageController.clear();
      setState(() {
        _showInputBar = false;
      });
      _focusNode.unfocus();
    }
  }

  void _toggleLike(Discussion discussion) {
    _repository.toggleLikeDiscussion(discussion.id);
  }

  void _openPostDetails(Discussion discussion) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailsPage(discussion: discussion),
      ),
    );
  }

  void _toggleInputBar() {
    setState(() {
      _showInputBar = !_showInputBar;
    });
    if (_showInputBar) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _focusNode.requestFocus();
      });
    } else {
      _focusNode.unfocus();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark 
          ? const Color(0xFF121212)
          : Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - smaller in landscape
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20, 
              vertical: isLandscape ? 8 : 12,
            ),
            child: Text(
              "Community Discussions",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isLandscape ? 20 : 26,
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white 
                    : Color(0xFF121717),
                fontFamily: 'Poppins',
              ),
            ),
          ),
          // Discussion list
          Expanded(child: _buildDiscussionList(isLandscape)),
          // Input section - either + button or input bar
          if (_showInputBar) _buildMessageInputBar(isLandscape),
        ],
      ),
      floatingActionButton: _showInputBar 
          ? null 
          : FloatingActionButton(
              onPressed: _toggleInputBar,
              backgroundColor: Colors.yellow[600],
              child: Icon(
                Icons.add,
                color: Colors.black,
                size: 28,
              ),
            ),
    );
  }

  Widget _buildDiscussionList(bool isLandscape) {
    return StreamBuilder<List<Discussion>>(
      stream: _repository.getDiscussions(),
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
          return Center(child: CircularProgressIndicator());
        }
        final discussions = snapshot.data!;
        if (discussions.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(isLandscape ? 16 : 32),
              child: Text(
                'No discussions yet. Start the conversation!',
                style: TextStyle(
                  fontSize: isLandscape ? 14 : 16, 
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.grey[400]
                      : Colors.grey[600]
                ),
              ),
            ),
          );
        }
        return Scrollbar(
          thumbVisibility: true,
          child: ListView.builder(
            padding: EdgeInsets.only(
              bottom: _showInputBar 
                  ? (isLandscape ? 80 : 100) 
                  : (isLandscape ? 16 : 80),
            ),
            itemCount: discussions.length,
            itemBuilder: (context, index) {
              return _buildDiscussionCard(discussions[index], isLandscape);
            },
          ),
        );
      },
    );
  }

  Widget _buildDiscussionCard(Discussion discussion, bool isLandscape) {
    final currentUser = _auth.currentUser;
    final isLiked = discussion.likedBy.contains(currentUser?.uid);

    return GestureDetector(
      onTap: () => _openPostDetails(discussion),
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: isLandscape ? 8 : 14, 
          horizontal: 20,
        ),
        padding: EdgeInsets.all(isLandscape ? 12 : 20),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark 
              ? const Color(0xFF2A2A2A)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(discussion.avatar),
                  radius: isLandscape ? 18 : 24,
                ),
                SizedBox(width: isLandscape ? 12 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        discussion.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isLandscape ? 14 : 18,
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.white 
                              : Colors.black,
                        ),
                        maxLines: isLandscape ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isLandscape ? 2 : 4),
                      Row(
                        children: [
                          Text(
                            discussion.author,
                            style: TextStyle(
                              fontSize: isLandscape ? 10 : 12,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).brightness == Brightness.dark 
                                  ? Colors.grey[300]
                                  : Colors.black,
                            ),
                          ),
                          SizedBox(width: isLandscape ? 8 : 12),
                          Text(
                            _repository.getTimeAgo(discussion.timestamp),
                            style: TextStyle(
                              fontSize: isLandscape ? 10 : 12,
                              color: Theme.of(context).brightness == Brightness.dark 
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: isLandscape ? 8 : 14),
            Text(
              discussion.description,
              style: TextStyle(
                fontSize: isLandscape ? 12 : 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white 
                    : Colors.black87,
              ),
              maxLines: isLandscape ? 2 : 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: isLandscape ? 12 : 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () => _toggleLike(discussion),
                      child: Row(
                        children: [
                          Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : Colors.grey,
                            size: isLandscape ? 16 : 18,
                          ),
                          SizedBox(width: isLandscape ? 4 : 6),
                          Text(
                            '${discussion.likes}',
                            style: TextStyle(
                              fontSize: isLandscape ? 10 : 12,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).brightness == Brightness.dark 
                                  ? Colors.white 
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: isLandscape ? 16 : 20),
                    Row(
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: isLandscape ? 16 : 18,
                          color: Colors.grey,
                        ),
                        SizedBox(width: isLandscape ? 4 : 6),
                        Text(
                          '${discussion.replies}',
                          style: TextStyle(
                            fontSize: isLandscape ? 10 : 12,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).brightness == Brightness.dark 
                                ? Colors.white 
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: isLandscape ? 16 : 20),
                    Row(
                      children: [
                        Icon(
                          Icons.remove_red_eye,
                          size: isLandscape ? 16 : 18,
                          color: Colors.grey,
                        ),
                        SizedBox(width: isLandscape ? 4 : 6),
                        Text(
                          '${discussion.views}',
                          style: TextStyle(
                            fontSize: isLandscape ? 10 : 12,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).brightness == Brightness.dark 
                                ? Colors.white 
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInputBar(bool isLandscape) {
    return Container(
      padding: EdgeInsets.all(isLandscape ? 12 : 20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark 
            ? const Color(0xFF2A2A2A)
            : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : Colors.black12, 
            blurRadius: 12,
            offset: Offset(0, -2),
          )
        ],
      ),
      child: Row(
        children: [
          // Close button
          IconButton(
            onPressed: _toggleInputBar,
            icon: Icon(
              Icons.close,
              color: Colors.grey,
              size: isLandscape ? 20 : 24,
            ),
          ),
          // Emoji button
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.emoji_emotions_outlined,
              color: Colors.grey,
              size: isLandscape ? 20 : 24,
            ),
          ),
          // Text input
          Expanded(
            child: TextField(
              controller: _messageController,
              focusNode: _focusNode,
              style: TextStyle(
                fontSize: isLandscape ? 14 : 16,
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white 
                    : Colors.black,
              ),
              decoration: InputDecoration(
                hintText: "Type your post here...",
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.grey[400]
                      : Color(0xFFBDBDBD),
                  fontFamily: 'Poppins',
                  fontSize: isLandscape ? 14 : 16,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          // Send button
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFF1721B),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.send, 
                color: Colors.white, 
                size: isLandscape ? 20 : 24,
              ),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
