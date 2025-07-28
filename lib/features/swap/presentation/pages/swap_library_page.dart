import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../features/home/data/email_service.dart';

class SwapLibraryPage extends StatefulWidget {
  const SwapLibraryPage({super.key});

  @override
  State<SwapLibraryPage> createState() => _SwapLibraryPageState();
}

class _SwapLibraryPageState extends State<SwapLibraryPage> with SingleTickerProviderStateMixin {
  String _search = '';
  int _selectedIndex = 2;
  late TabController _tabController;
  int _currentTabIndex = 0; // 0 for Swap Received, 1 for Swap Sent

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: _currentTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/home');
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed('/messages');
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed('/profile');
        break;
      case 3:
        Navigator.of(context).pushReplacementNamed('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark 
          ? const Color(0xFF121212)
          : Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark 
            ? const Color(0xFF121212)
            : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back, 
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white 
                : Colors.black
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Stack(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.notifications_none, 
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white 
                        : Colors.black
                  ),
                  onPressed: () {},
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Swap Library',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white 
                    : Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Who has sent you a Swap?',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white 
                    : const Color(0xFF222222),
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 12),
            // Toggle button for Swap Received/Swap Sent
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7, // Reduced width to 70%
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? const Color(0xFF2A2A2A)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.grey[400]
                      : const Color(0xFF617D8A),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                  indicator: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? const Color(0xFF3E8E7E)
                        : const Color(0xFF225B4B),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  onTap: (index) {
                    setState(() {
                      _currentTabIndex = index;
                    });
                  },
                  tabs: const [
                    Tab(text: 'Swap Received'),
                    Tab(text: 'Swap Sent'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white 
                    : Colors.black,
              ),
              decoration: InputDecoration(
                hintText: 'Search here',
                hintStyle: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.grey[400]
                      : const Color(0xFFBDBDBD), 
                  fontFamily: 'Poppins'
                ),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark 
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              ),
              onChanged: (value) => setState(() => _search = value.trim().toLowerCase()),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: currentUser == null
                  ? const Center(child: Text('Please log in'))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        // Swap Received Tab
                        _buildSwapReceivedTab(currentUser.uid),
                        // Swap Sent Tab
                        _buildSwapSentTab(currentUser.uid),
                      ],
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark 
              ? const Color(0xFF1E1E1E)
              : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF000000)
                  : const Color(0x11000000),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: _selectedIndex,
          onTap: _onTabTapped,
          selectedItemColor: Theme.of(context).brightness == Brightness.dark 
              ? const Color(0xFF3E8E7E)
              : const Color(0xFF225B4B),
          unselectedItemColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.white70
              : Colors.black,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  // Build Swap Received Tab
  Widget _buildSwapReceivedTab(String currentUserId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('swapRequests')
          .where('receiverId', isEqualTo: currentUserId)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No swaps received yet.',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.grey[400]
                    : Colors.grey[600],
              ),
            ),
          );
        }
        final requests = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data == null) return false;
          final senderName = (data['senderName'] ?? '').toString().toLowerCase();
          final learn = (data['learn'] ?? '').toString().toLowerCase();
          return senderName.contains(_search) || learn.contains(_search);
        }).toList();
        if (requests.isEmpty) {
          return Center(
            child: Text(
              'No swaps match your search.',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.grey[400]
                    : Colors.grey[600],
              ),
            ),
          );
        }
        return ListView.separated(
          itemCount: requests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 18),
          itemBuilder: (context, i) {
            final doc = requests[i];
            final data = doc.data() as Map<String, dynamic>?;
            if (data == null) {
              return const SizedBox(height: 100, child: Center(child: Text('Invalid data')));
            }
            final senderName = data['senderName'] ?? 'Unknown';
            final senderAvatar = data['senderAvatar'];
            final learn = data['learn'] ?? '';
            final status = data['status'] ?? 'pending';
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: senderAvatar != null ? NetworkImage(senderAvatar) : null,
                  child: senderAvatar == null ? Text(
                    senderName[0], 
                    style: TextStyle(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    )
                  ) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        senderName,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.white 
                              : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Builder(
                        builder: (context) {
                          // Use the skills stored in the swap request document
                          final skillsOffered = data['senderSkillsOffered'] ?? 'various skills';
                          final skillsWanted = data['senderSkillsWanted'] ?? 'various skills';
                          
                          // Get date and time information
                          String dateTimeInfo = '';
                          final date = data['date'];
                          final time = data['time'];
                          
                          if (date != null && time != null) {
                            if (date is Timestamp) {
                              final dateTime = date.toDate();
                              final formattedDate = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
                              dateTimeInfo = ' • $formattedDate at $time';
                            }
                          }
                          
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$senderName wants to learn $learn and is good at $skillsOffered',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                  color: Theme.of(context).brightness == Brightness.dark 
                                      ? Colors.grey[300]
                                      : Colors.grey[600],
                                ),
                              ),
                              if (dateTimeInfo.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    dateTimeInfo.replaceFirst(' • ', ''),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'Poppins',
                                      color: Theme.of(context).brightness == Brightness.dark 
                                          ? const Color(0xFFFFB74D)
                                          : const Color(0xFFF7931A),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (status == 'declined')
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFBDBDBD),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text('Declined', style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
                            )
                          else if (status == 'accepted')
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text('Accepted', style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
                            )
                          else ...[
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF19A7CE),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                              ),
                              onPressed: () async {
                                await FirebaseFirestore.instance.collection('swapRequests').doc(doc.id).update({'status': 'declined'});
                              },
                              child: const Text('Decline', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF7931A),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                              ),
                              onPressed: () async {
                                try {
                                  // Get the swap request data
                                  final date = data['date'];
                                  final time = data['time'];
                                  final platform = data['platform'];
                                  final skillToLearn = data['learn'];
                                  
                                  if (date != null && time != null && platform != null && skillToLearn != null) {
                                    // Format the date and time
                                    String meetingDate = '';
                                    String meetingTime = '';
                                    
                                    if (date is Timestamp) {
                                      final dateTime = date.toDate();
                                      meetingDate = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
                                    }
                                    meetingTime = time.toString();
                                    
                                    // Send confirmation emails
                                    // Get user data for email
                                    final requesterDoc = await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(data['requesterId'])
                                        .get();
                                    final receiverDoc = await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(data['receiverId'])
                                        .get();
                                    
                                    final requesterData = requesterDoc.data();
                                    final receiverData = receiverDoc.data();
                                    
                                    if (requesterData != null && receiverData != null) {
                                      await EmailService.sendSwapConfirmationEmail(
                                        requesterEmail: requesterData['email'] ?? '',
                                        receiverEmail: receiverData['email'] ?? '',
                                        requesterName: requesterData['name'] ?? 'User',
                                        receiverName: receiverData['name'] ?? 'User',
                                        requesterLocation: requesterData['location'] ?? 'Not specified',
                                        receiverLocation: receiverData['location'] ?? 'Not specified',
                                        meetingDate: meetingDate,
                                        meetingTime: meetingTime,
                                        platform: platform == 'google_meet' ? 'Google Meet' : 'Zoom',
                                        skillToLearn: skillToLearn,
                                      );
                                    }
                                  }
                                  
                                  // Show confirmation dialog
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Swap Accepted!'),
                                      content: const Text('Confirmation emails sent to both parties.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );
                                } catch (error) {
                                  print('Error accepting swap: $error');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error accepting swap: $error'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              child: const Text('Accept', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Build Swap Sent Tab
  Widget _buildSwapSentTab(String currentUserId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('swapRequests')
          .where('requesterId', isEqualTo: currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No swaps sent yet.',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.grey[400]
                    : Colors.grey[600],
              ),
            ),
          );
        }
        
        final requests = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data == null) return false;
          final learn = (data['learn'] ?? '').toString().toLowerCase();
          return learn.contains(_search);
        }).toList();
        
        if (requests.isEmpty) {
          return Center(
            child: Text(
              'No swaps match your search.',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.grey[400]
                    : Colors.grey[600],
              ),
            ),
          );
        }
        
        return ListView.separated(
          itemCount: requests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 18),
          itemBuilder: (context, i) {
            final doc = requests[i];
            final data = doc.data() as Map<String, dynamic>?;
            if (data == null) {
              return const SizedBox(height: 100, child: Center(child: Text('Invalid data')));
            }
            final receiverId = data['receiverId'] ?? '';
            final learn = data['learn'] ?? '';
            final status = data['status'] ?? 'pending';
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(receiverId).get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
                }
                
                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return const SizedBox.shrink(); // Hide this item instead of showing "User not found"
                }
                
                final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                final receiverName = userData?['name'] ?? 'Unknown';
                final receiverAvatar = userData?['avatarUrl'];
                
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: receiverAvatar != null ? NetworkImage(receiverAvatar) : null,
                      child: receiverAvatar == null ? Text(
                        receiverName[0], 
                        style: const TextStyle(
                          fontSize: 24, 
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        )
                      ) : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            receiverName,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              color: Theme.of(context).brightness == Brightness.dark 
                                  ? Colors.white 
                                  : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Builder(
                            builder: (context) {
                              // Get date and time information
                              String dateTimeInfo = '';
                              final date = data['date'];
                              final time = data['time'];
                              
                              if (date != null && time != null) {
                                if (date is Timestamp) {
                                  final dateTime = date.toDate();
                                  final formattedDate = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
                                  dateTimeInfo = ' • $formattedDate at $time';
                                }
                              }
                              
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'You want to learn $learn from $receiverName',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Poppins',
                                      color: Theme.of(context).brightness == Brightness.dark 
                                          ? Colors.grey[300]
                                          : Colors.grey[600],
                                    ),
                                  ),
                                  if (dateTimeInfo.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        dateTimeInfo.replaceFirst(' • ', ''),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'Poppins',
                                          color: Theme.of(context).brightness == Brightness.dark 
                                              ? const Color(0xFFFFB74D)
                                              : const Color(0xFFF7931A),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (status == 'declined')
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFBDBDBD),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text('Rejected', style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
                                )
                              else if (status == 'accepted')
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4CAF50),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text('Accepted', style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF7931A),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text('Pending', style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}