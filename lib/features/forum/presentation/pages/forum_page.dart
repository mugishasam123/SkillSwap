import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/discussion.dart';
import '../../data/forum_repository.dart';
import 'post_details_page.dart';

class ForumPage extends StatefulWidget {
  final Function(double)? onScrollCallback;
  
  const ForumPage({super.key, this.onScrollCallback});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ForumRepository _repository = ForumRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isHeaderVisible = true;
  bool _showInputArea = false;
  double _lastScrollPosition = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _messageController.dispose();
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
    
    // Call the parent scroll callback for tab bar collapsible functionality
    if (widget.onScrollCallback != null) {
      widget.onScrollCallback!(currentPosition);
    }
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      final title = message.length > 50
          ? '${message.substring(0, 50)}...'
          : message;
      _repository.createDiscussion(title: title, description: message);
      _messageController.clear();
      // Hide input area after sending
      setState(() {
        _showInputArea = false;
      });
    }
  }

  void _toggleInputArea() {
    setState(() {
      _showInputArea = !_showInputArea;
    });
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
  Widget build(BuildContext context) {
    // Get screen dimensions and orientation
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final padding = mediaQuery.padding;
    
    // Calculate responsive values
    final headerHeight = isLandscape ? 60.0 : 80.0;
    final inputBarHeight = isLandscape ? 70.0 : 80.0;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark 
          ? const Color(0xFF121212)
          : Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Text(
                    "Community Discussions",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isLandscape ? 22 : 26,
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white 
                          : Color(0xFF121717),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ),
            
            // Discussion list with proper padding
            Expanded(
              child: _buildDiscussionList(),
            ),
            
            // Collapsible input area
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: _showInputArea ? inputBarHeight + padding.bottom + 20 : 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _showInputArea ? 1.0 : 0.0,
                child: _buildMessageInputBar(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleInputArea,
        backgroundColor: Colors.orange,
        child: Icon(
          _showInputArea ? Icons.close : Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDiscussionList() {
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
              padding: EdgeInsets.all(32),
              child: Text(
                'No discussions yet. Start the conversation!',
                style: TextStyle(
                  fontSize: 16, 
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
          controller: _scrollController,
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.only(bottom: _showInputArea ? 160 : 20), // Dynamic padding based on input area visibility
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
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.white 
                              : Colors.black,
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
                              color: Theme.of(context).brightness == Brightness.dark 
                                  ? Colors.grey[300]
                                  : Colors.black,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            _repository.getTimeAgo(discussion.timestamp),
                            style: TextStyle(
                              fontSize: 12,
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
            SizedBox(height: 14),
            Text(
              discussion.description,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white 
                    : Colors.black87,
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
                              color: Theme.of(context).brightness == Brightness.dark 
                                  ? Colors.white 
                                  : Colors.black,
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
                            color: Theme.of(context).brightness == Brightness.dark 
                                ? Colors.white 
                                : Colors.black,
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

  Widget _buildMessageInputBar() {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final padding = mediaQuery.padding;
    
    return Container(
      height: isLandscape ? 70.0 : 80.0 + padding.bottom + 20,
      padding: EdgeInsets.all(isLandscape ? 16.0 : 20.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark 
              ? const Color(0xFF2A2A2A)
              : Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black12, 
              blurRadius: 12
            )
          ],
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isLandscape ? 12.0 : 16.0),
              child: Icon(
                Icons.emoji_emotions_outlined,
                color: Colors.grey,
                size: isLandscape ? 28 : 32,
              ),
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                style: TextStyle(
                  fontSize: isLandscape ? 16 : 18,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white 
                      : Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: "Type message here...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.grey[400]
                        : Color(0xFFBDBDBD),
                    fontFamily: 'Poppins',
                    fontSize: isLandscape ? 16 : 18,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isLandscape ? 8.0 : 12.0,
                vertical: isLandscape ? 2.0 : 4.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFF1721B),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.send, 
                    color: Colors.white, 
                    size: isLandscape ? 20 : 24
                  ),
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
