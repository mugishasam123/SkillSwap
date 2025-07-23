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

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      final title = message.length > 50
          ? '${message.substring(0, 50)}...'
          : message;
      _repository.createDiscussion(title: title, description: message);
      _messageController.clear();
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

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                "Community Discussions",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                  color: Color(0xFF121717),
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            Expanded(child: _buildDiscussionList()),
          ],
        ),
        // Only keep the message input bar at the bottom
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildMessageInputBar(),
        ),
      ],
    );
  }

  Widget _buildDiscussionList() {
    return StreamBuilder<List<Discussion>>(
      stream: _repository.getDiscussions(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        final discussions = snapshot.data!;
        if (discussions.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'No discussions yet. Start the conversation!',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ),
          );
        }
        return Scrollbar(
          thumbVisibility: true,
          child: ListView.builder(
            padding: EdgeInsets.only(bottom: 100),
            itemCount: discussions.length,
            itemBuilder: (context, index) {
              return _buildDiscussionCard(discussions[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildDiscussionCard(Discussion discussion) {
    final currentUser = _auth.currentUser;
    final isLiked = discussion.likedBy.contains(currentUser?.uid);

    return GestureDetector(
      onTap: () => _openPostDetails(discussion),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.grey.withOpacity(0.1),
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
                  radius: 24,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        discussion.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            discussion.author,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            _repository.getTimeAgo(discussion.timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 14),
            Text(
              discussion.description,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 16),
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
                            size: 18,
                          ),
                          SizedBox(width: 6),
                          Text(
                            '${discussion.likes}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 20),
                    Row(
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 18,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 6),
                        Text(
                          '${discussion.replies}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 20),
                    Row(
                      children: [
                        Icon(
                          Icons.remove_red_eye,
                          size: 18,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 6),
                        Text(
                          '${discussion.views}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
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

  Widget _buildMessageInputBar() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12)],
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(
                Icons.emoji_emotions_outlined,
                color: Colors.grey,
                size: 32,
              ),
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                style: TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  hintText: "Type message here...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Color(0xFFBDBDBD),
                    fontFamily: 'Poppins',
                    fontSize: 18,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 4.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFF1721B),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.send, color: Colors.white, size: 24),
                  onPressed: _sendMessage,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
