import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../home/data/swap_repository.dart';
import 'package:intl/intl.dart';

class SwapPage extends StatefulWidget {
  final String? receiverId;
  const SwapPage({super.key, this.receiverId});

  @override
  State<SwapPage> createState() => _SwapPageState();
}

class _SwapPageState extends State<SwapPage> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedPlatform; // 'google_meet' or 'zoom'
  final TextEditingController _learnController = TextEditingController();
  final List<String> _learnSkills = [];
  int _selectedIndex = 0;

  bool get _canSendRequest =>
      _learnSkills.isNotEmpty &&
      _selectedDate != null &&
      _selectedTime != null &&
      _selectedPlatform != null;

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
  void dispose() {
    _learnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? receiverIdFromArgs = widget.receiverId ?? ModalRoute.of(context)?.settings.arguments as String?;

    // Colors from screenshot
    const Color primaryBlue = Color(0xFF19A7CE);
    const Color orange = Color(0xFFF7931A);
    const Color lightGrey = Color(0xFFF5F5F5);
    const Color textBlack = Color(0xFF222222);
    const Color textGrey = Color(0xFFBDBDBD);
    const Color borderGrey = Color(0xFFEAEAEA);
    const Color meetTextGrey = Color(0xFF5F6368);

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
                : Colors.black, 
            size: 22
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: null,
        centerTitle: false,
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
                        : Colors.black, 
                    size: 22
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
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 0, bottom: 10),
                child: Text(
                  'Send a Swap',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white 
                        : Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              Text(
                'What would you like to learn?',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white 
                      : textBlack,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _learnController,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Poppins',
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white 
                      : textBlack,
                ),
                decoration: InputDecoration(
                  hintText: 'Type here',
                  hintStyle: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.grey[400]
                        : textGrey, 
                    fontSize: 15, 
                    fontFamily: 'Poppins'
                  ),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark 
                      ? const Color(0xFF2A2A2A)
                      : lightGrey,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: (value) {
                  final trimmed = value.trim();
                  if (trimmed.isNotEmpty && !_learnSkills.contains(trimmed)) {
                    setState(() {
                      _learnSkills.add(trimmed);
                      _learnController.clear();
                    });
                  }
                },
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _learnSkills.map((skill) => Chip(
                  label: Text(
                    skill, 
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white 
                          : Colors.black,
                    )
                  ),
                  deleteIcon: Icon(
                    Icons.close, 
                    size: 18,
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white 
                        : Colors.black,
                  ),
                  onDeleted: () {
                    setState(() {
                      _learnSkills.remove(skill);
                    });
                  },
                  backgroundColor: Theme.of(context).brightness == Brightness.dark 
                      ? const Color(0xFF2A2A2A)
                      : lightGrey,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                )).toList(),
              ),
              const SizedBox(height: 28),
              Text(
                'When do you want to learn?',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white 
                      : textBlack,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => _selectedDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? const Color(0xFF2A2A2A)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[700]!
                                : borderGrey
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today, 
                              color: Theme.of(context).brightness == Brightness.dark 
                                  ? Colors.grey[400]
                                  : textGrey, 
                              size: 20
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _selectedDate != null
                                  ? DateFormat('MMM d, yyyy').format(_selectedDate!)
                                  : 'Select date',
                              style: TextStyle(
                                fontSize: 15,
                                color: Theme.of(context).brightness == Brightness.dark 
                                    ? Colors.white 
                                    : textBlack,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime ?? TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setState(() => _selectedTime = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? const Color(0xFF2A2A2A)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[700]!
                                : borderGrey
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time, 
                              color: Theme.of(context).brightness == Brightness.dark 
                                  ? Colors.grey[400]
                                  : textGrey, 
                              size: 20
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _selectedTime != null
                                  ? _selectedTime!.format(context)
                                  : 'Select time',
                              style: TextStyle(
                                fontSize: 15,
                                color: Theme.of(context).brightness == Brightness.dark 
                                    ? Colors.white 
                                    : textBlack,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Google Meet
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/google_meet.png',
                    height: 80,
                    width: 170,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 80),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedPlatform == 'google_meet' 
                            ? primaryBlue 
                            : (Theme.of(context).brightness == Brightness.dark 
                                ? const Color(0xFF2A2A2A)
                                : lightGrey),
                        foregroundColor: _selectedPlatform == 'google_meet' 
                            ? Colors.white 
                            : (Theme.of(context).brightness == Brightness.dark 
                                ? Colors.white 
                                : textBlack),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        elevation: 0,
                        textStyle: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      onPressed: () {
                        setState(() => _selectedPlatform = 'google_meet');
                      },
                      child: const Text('Select'),
                    ),
                  ),
                ],
              ),
              // Zoom
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/zoom.png',
                    height: 50,
                    width: 100,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 150),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedPlatform == 'zoom' 
                            ? primaryBlue 
                            : (Theme.of(context).brightness == Brightness.dark 
                                ? const Color(0xFF2A2A2A)
                                : lightGrey),
                        foregroundColor: _selectedPlatform == 'zoom' 
                            ? Colors.white 
                            : (Theme.of(context).brightness == Brightness.dark 
                                ? Colors.white 
                                : textBlack),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        elevation: 0,
                        textStyle: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      onPressed: () {
                        setState(() => _selectedPlatform = 'zoom');
                      },
                      child: const Text('Select'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        textStyle: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      onPressed: _canSendRequest
                          ? () async {
                              await _sendSwapRequest(context, receiverIdFromArgs);
                            }
                          : null,
                      child: const Text('Send Request'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
            ],
          ),
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

  Future<void> _sendSwapRequest(BuildContext context, String? receiverId) async {
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

    if (receiverId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No user selected'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedPlatform == null || _selectedDate == null || _selectedTime == null || _learnSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and select a platform'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final repository = SwapRepository();
      // Save the swap request with all info
      await repository.requestSwap(
        receiverId: receiverId,
        platform: _selectedPlatform,
        date: _selectedDate,
        time: _selectedTime,
        learn: _learnSkills.join(', '),
      );
      
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