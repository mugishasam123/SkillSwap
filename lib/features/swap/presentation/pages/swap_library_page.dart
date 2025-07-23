import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SwapLibraryPage extends StatefulWidget {
  const SwapLibraryPage({super.key});

  @override
  State<SwapLibraryPage> createState() => _SwapLibraryPageState();
}

class _SwapLibraryPageState extends State<SwapLibraryPage> {
  String _search = '';
  int _selectedIndex = 2;

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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none, color: Colors.black),
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
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Swap Library',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Who has sent you a Swap?',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF222222),
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search here',
                hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontFamily: 'Poppins'),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
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
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('swapRequests')
                          .where('recipientId', isEqualTo: currentUser.uid)
                          .orderBy('createdAt', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text('No swaps yet.'));
                        }
                        final requests = snapshot.data!.docs.where((doc) {
                          final senderName = (doc['senderName'] ?? '').toString().toLowerCase();
                          final learn = (doc['learn'] ?? '').toString().toLowerCase();
                          return senderName.contains(_search) || learn.contains(_search);
                        }).toList();
                        if (requests.isEmpty) {
                          return const Center(child: Text('No swaps match your search.'));
                        }
                        return ListView.separated(
                          itemCount: requests.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 18),
                          itemBuilder: (context, i) {
                            final doc = requests[i];
                            final senderName = doc['senderName'] ?? 'Unknown';
                            final senderAvatar = doc['senderAvatar'];
                            final learn = doc['learn'] ?? '';
                            final status = doc['status'] ?? 'pending';
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundImage: senderAvatar != null ? NetworkImage(senderAvatar) : null,
                                  child: senderAvatar == null ? Text(senderName[0], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)) : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        senderName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '$senderName wants to learn $learn',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Poppins',
                                        ),
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
                                                // Placeholder: send email logic here
                                                await sendSwapEmail(doc);
                                                await FirebaseFirestore.instance.collection('swapRequests').doc(doc.id).update({'status': 'accepted'});
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
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x11000000),
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: _selectedIndex,
          onTap: _onTabTapped,
          selectedItemColor: const Color(0xFF225B4B),
          unselectedItemColor: Colors.black,
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

  Future<void> sendSwapEmail(QueryDocumentSnapshot doc) async {
    // TODO: Integrate actual email sending logic here
    // You can use a backend function, or an email package
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email with meeting details sent to both parties!'),
        backgroundColor: Colors.green,
      ),
    );
  }
} 