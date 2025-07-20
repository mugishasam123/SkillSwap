import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../home/data/swap_repository.dart';

class SwapPage extends StatelessWidget {
  final String? swapId;
  
  const SwapPage({Key? key, this.swapId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get swap ID from navigation arguments if not passed directly
    final String? swapIdFromArgs = swapId ?? ModalRoute.of(context)?.settings.arguments as String?;
    
    // Define colors to match the design
    const Color primaryBlue = Color(0xFF19A7CE);
    const Color orange = Color(0xFFF7931A);
    const Color lightGrey = Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Send a Swap',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.black),
                onPressed: () {},
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                'What would you like to learn?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Type here',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: lightGrey,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'When do you want to learn?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: const Text(
                        'Weekdays',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: const Text(
                        '3:30PM',
                        style: TextStyle(color: Colors.grey),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () {
                        // TODO: Show time picker for weekdays
                      },
                    ),
                    Divider(height: 1, color: Colors.grey.shade300),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: const Text(
                        'Weekends',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: const Text(
                        '10:00AM',
                        style: TextStyle(color: Colors.grey),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () {
                        // TODO: Show time picker for weekends
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Google Meet Option
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    // Google Meet Logo (simplified with colors)
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00AC47), Color(0xFF4285F4), Color(0xFFEA4335), Color(0xFFFBBC04)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(
                        Icons.video_call,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Google Meet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        elevation: 0,
                      ),
                      onPressed: () {
                        // TODO: Handle Google Meet booking
                      },
                      child: const Text(
                        'Book a Call',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Zoom Option
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    // Zoom Logo (simplified)
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2D8CFF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.video_call,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'zoom',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        elevation: 0,
                      ),
                      onPressed: () {
                        // TODO: Handle Zoom booking
                      },
                      child: const Text(
                        'Book a Call',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Send Request Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    // Call Firebase to send swap request
                    await _sendSwapRequest(context, swapIdFromArgs);
                  },
                  child: const Text(
                    'Send Request',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF225B4B),
        unselectedItemColor: Colors.black54,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          // TODO: Handle navigation
          if (index != 0) {
            Navigator.pushReplacementNamed(context, index == 1 ? '/messages' : index == 2 ? '/profile' : '/settings');
          }
        },
      ),
    );
  }

  Future<void> _sendSwapRequest(BuildContext context, String? swapId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to send swap requests'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (swapId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No swap selected'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final repository = SwapRepository();
      await repository.requestSwap(swapId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Swap request sent successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigate back to the previous page
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 