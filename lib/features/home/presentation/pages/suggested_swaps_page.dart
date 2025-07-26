import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/swap_repository.dart';
import '../../models/swap.dart';
import '../../../profile/data/profile_repository.dart';
import '../../../profile/models/user_profile.dart';
import '../../../profile/presentation/pages/user_profile_dialog.dart';

class SuggestedSwapsPage extends StatefulWidget {
  const SuggestedSwapsPage({super.key});

  @override
  State<SuggestedSwapsPage> createState() => _SuggestedSwapsPageState();
}

class _SuggestedSwapsPageState extends State<SuggestedSwapsPage> {
  final SwapRepository _repository = SwapRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _viewSwap(Swap swap) async {
    // Increment view count
    _repository.incrementViews(swap.id);

    print('=== SUGGESTED SWAPS DEBUG ===');
    print('DEBUG: swap.userId = ${swap.userId}');
    print('DEBUG: swap.userName = ${swap.userName}');
    print('DEBUG: swap.skillOffered = ${swap.skillOffered}');
    print('DEBUG: swap.skillWanted = ${swap.skillWanted}');

    // Fetch the full user profile for the swap's user
    final profileRepo = ProfileRepository();
    print('DEBUG: About to fetch profile for userId: ${swap.userId}');
    final UserProfile? userProfile = await profileRepo.getUserProfileById(swap.userId);

    print('DEBUG: Profile fetch result: ${userProfile != null ? "SUCCESS" : "FAILED"}');
    if (userProfile != null) {
      print('DEBUG: Fetched profile name: ${userProfile.name}');
      print('DEBUG: Fetched profile skills offered: ${userProfile.skillsOffered}');
      print('DEBUG: Fetched profile skills wanted: ${userProfile.skillsWanted}');
    }

    if (userProfile != null && mounted) {
      print('DEBUG: Showing UserProfileDialog with full profile');
      showDialog(
        context: context,
        builder: (context) => UserProfileDialog(userProfile: userProfile),
      );
    } else {
      print('DEBUG: Using fallback profile with limited skills');
      // Create a basic user profile from swap data as fallback
      final fallbackProfile = UserProfile(
        uid: swap.userId,
        name: swap.userName,
        email: '',
        username: swap.userName.toLowerCase().replaceAll(' ', ''),
        bio: swap.description,
        location: swap.location,
        availability: 'Available',
        skillsOffered: [swap.skillOffered],
        skillsWanted: [swap.skillWanted],
        reviews: [],
        swapScore: 0,
        notificationsEnabled: true,
        privacySettings: {},
        avatarUrl: swap.userAvatar,
      );
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => UserProfileDialog(userProfile: fallbackProfile),
        );
      }
    }
  }

  void _requestSwap(Swap swap) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to request swaps')),
      );
      return;
    }

    if (currentUser.uid == swap.userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot request your own swap')),
      );
      return;
    }

    try {
      await _repository.requestSwap(receiverId: swap.userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Swap request sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showFullScreenImage(String imageUrl, String userName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullScreenImageView(
          imageUrl: imageUrl,
          userName: userName,
        ),
      ),
    );
  }

  String _formatSkill(String skill) {
    // Convert skill names to proper format
    switch (skill.toLowerCase()) {
      case 'cook':
        return 'cooking';
      case 'dance':
        return 'dancing';
      case 'code':
      case 'coding':
        return 'coding';
      case 'photography':
        return 'photography';
      case 'designing flyers':
        return 'designing flyers';
      case 'video editing':
        return 'video editing';
      case 'web design':
        return 'web design';
      default:
        return skill.toLowerCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          
          // New Swaps Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Suggested Swaps',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Color(0xFF121717),
                  fontFamily: 'Poppins',
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to All tab without filter
                  Navigator.pushReplacementNamed(
                    context,
                    '/home',
                    arguments: {
                      'selectedTab': 0, // Home tab
                      'homeTabIndex': 1, // All tab within home
                    },
                  );
                },
                child: Text(
                  'View All Swaps',
                  style: TextStyle(
                    color: Color(0xFF225B4B),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // New Swaps Cards
          _buildNewSwapsSection(),
          
          const SizedBox(height: 24),
          
          // Skill/Course Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Suggested Skills',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xFF121717),
                  fontFamily: 'Poppins',
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to All tab without filter
                  Navigator.pushReplacementNamed(
                    context,
                    '/home',
                    arguments: {
                      'selectedTab': 0, // Home tab
                      'homeTabIndex': 1, // All tab within home
                    },
                  );
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: Color(0xFF225B4B),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildSkillGrid(),
          
          const SizedBox(height: 100), // Bottom padding for FAB
        ],
      ),
    );
  }

  Widget _buildNewSwapsSection() {
    return StreamBuilder<List<Swap>>(
      stream: _repository.getSuggestedSwaps(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  'Error loading new swaps',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final swaps = snapshot.data!;
        if (swaps.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.swap_horiz, size: 64, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  'No new swaps available',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        // Show only first 2 swaps for "New Swaps" section
        final newSwaps = swaps.take(2).toList();
        
        return Column(
          children: newSwaps.map((swap) => _buildNewSwapCard(swap)).toList(),
        );
      },
    );
  }

  Widget _buildNewSwapCard(Swap swap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Picture
          Column(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage(swap.userAvatar),
              ),
              const SizedBox(height: 8),
              Text(
                swap.userName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${swap.userName} is good at ${_formatSkill(swap.skillOffered)}, and ${swap.userName} wants to learn ${_formatSkill(swap.skillWanted)}.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Display image if available
                if (swap.imageUrl != null) ...[
                  GestureDetector(
                    onTap: () => _showFullScreenImage(swap.imageUrl!, swap.userName),
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[100],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: swap.imageUrl!.startsWith('http')
                            ? Image.network(
                                swap.imageUrl!,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 30,
                                      color: Colors.grey[600],
                                    ),
                                  );
                                },
                              )
                            : Image.asset(
                                swap.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 30,
                                      color: Colors.grey[600],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _viewSwap(swap),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1DA1F2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Text(
                          'View',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/swap', arguments: swap.userId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF8A00),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Request Swap',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildSkillGrid() {
    final skills = [
      {'title': 'CV & Resume Writing', 'image': 'assets/images/onboarding_1.png', 'skill': 'resume writing'},
      {'title': 'Intro to Digital Freelancing', 'image': 'assets/images/onboarding_2.png', 'skill': 'freelancing'},
      {'title': 'Video Editing with CapCut', 'image': 'assets/images/onboarding_3.png', 'skill': 'video editing'},
      {'title': 'UI/UX Basics using Figma', 'image': 'assets/images/onboarding_1.png', 'skill': 'ui/ux'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: skills.length,
      itemBuilder: (context, index) {
        final skill = skills[index];
        return GestureDetector(
          onTap: () {
            // Navigate to home page with All tab selected and skill filter
            print('DEBUG: Clicking skill: ${skill['skill']}');
            Navigator.pushReplacementNamed(
              context, 
              '/home', 
              arguments: {
                'selectedTab': 0, // Home tab
                'homeTabIndex': 1, // All tab within home
                'filterSkill': skill['skill']
              }
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      color: Colors.grey[100],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: Image.asset(
                        skill['image']!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.image_not_supported,
                              size: 30,
                              color: Colors.grey[600],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      skill['title']!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SwapDetailsDialog extends StatelessWidget {
  final Swap swap;

  const _SwapDetailsDialog({required this.swap});

  void _showFullScreenImage(BuildContext context, String imageUrl, String userName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullScreenImageView(
          imageUrl: imageUrl,
          userName: userName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: AssetImage(swap.userAvatar),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        swap.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        swap.location.isNotEmpty ? swap.location : 'Location not specified',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF225B4B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Recommended',
                    style: TextStyle(
                      fontSize: 10,
                      color: const Color(0xFF225B4B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _DetailRow(
              icon: Icons.school,
              title: 'Skill Offered',
              value: swap.skillOffered,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.psychology,
              title: 'Skill Wanted',
              value: swap.skillWanted,
              color: Colors.blue,
            ),
            // Display image if available
            if (swap.imageUrl != null) ...[
              const SizedBox(height: 16),
              Text(
                'Image',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _showFullScreenImage(context, swap.imageUrl!, swap.userName),
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[100],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: swap.imageUrl!.startsWith('http')
                        ? Image.network(
                            swap.imageUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                  color: Colors.grey[600],
                                ),
                              );
                            },
                          )
                        : Image.asset(
                            swap.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                  color: Colors.grey[600],
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (swap.description.isNotEmpty) ...[
              Text(
                'Description',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                swap.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (swap.tags.isNotEmpty) ...[
              Text(
                'Tags',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: swap.tags.map((tag) => Chip(
                  label: Text(tag),
                  backgroundColor: Colors.grey[200],
                  labelStyle: TextStyle(fontSize: 12),
                )).toList(),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Icon(Icons.remove_red_eye, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${swap.views} views',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.handshake, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${swap.requests} requests',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/swap', arguments: swap.userId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8A00),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Request Swap',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullScreenImageView extends StatelessWidget {
  final String imageUrl;
  final String userName;

  const _FullScreenImageView({
    required this.imageUrl,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '$userName\'s Image',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          child: imageUrl.startsWith('http')
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: Colors.white,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[900],
                      child: Icon(
                        Icons.image_not_supported,
                        size: 100,
                        color: Colors.grey[600],
                      ),
                    );
                  },
                )
              : Image.asset(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[900],
                      child: Icon(
                        Icons.image_not_supported,
                        size: 100,
                        color: Colors.grey[600],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
