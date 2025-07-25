import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/swap_repository.dart';
import '../../models/swap.dart';
import '../../../profile/data/profile_repository.dart';
import '../../../profile/models/user_profile.dart';
import '../../../profile/presentation/pages/user_profile_dialog.dart';

class AllSwapsPage extends StatefulWidget {
  final String? filterSkill;
  
  const AllSwapsPage({super.key, this.filterSkill});

  @override
  State<AllSwapsPage> createState() => _AllSwapsPageState();
}

class _AllSwapsPageState extends State<AllSwapsPage> {
  final SwapRepository _repository = SwapRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _showOfflineMockData = false;

  @override
  void initState() {
    super.initState();
    print('DEBUG: AllSwapsPage initState with filterSkill: ${widget.filterSkill}');
  }

  // Mock data for offline testing
  List<Swap> get _mockSwaps => [
    Swap(
      id: 'mock_1',
      userId: 'tobi_123',
      userName: 'Tobi',
      userAvatar: 'assets/images/onboarding_1.png',
      skillOffered: 'cook',
      skillWanted: 'designing flyers',
      description:
          'I am good at cooking and want to learn graphic design to create beautiful flyers for my events.',
      createdAt: DateTime.now().subtract(Duration(hours: 2)),
      location: 'Lagos, Nigeria',
      tags: ['cooking', 'graphic design', 'events'],
      isActive: true,
      views: 15,
      requests: 3,
      imageUrl: 'assets/images/onboarding_1.png',
    ),
    Swap(
      id: 'mock_2',
      userId: 'agnes_456',
      userName: 'Agnes',
      userAvatar: 'assets/images/onboarding_2.png',
      skillOffered: 'dance',
      skillWanted: 'video editing',
      description:
          'I am good at dancing and want to learn video editing to create amazing dance videos.',
      createdAt: DateTime.now().subtract(Duration(hours: 1)),
      location: 'Nairobi, Kenya',
      tags: ['dance', 'video editing', 'content creation'],
      isActive: true,
      views: 8,
      requests: 1,
      imageUrl: 'assets/images/onboarding_2.png',
    ),
    Swap(
      id: 'mock_3',
      userId: 'tobi_789',
      userName: 'Tobi',
      userAvatar: 'assets/images/onboarding_1.png',
      skillOffered: 'cook',
      skillWanted: 'designing flyers',
      description:
          'I am good at cooking and want to learn graphic design to create beautiful flyers for my events.',
      createdAt: DateTime.now().subtract(Duration(minutes: 30)),
      location: 'Lagos, Nigeria',
      tags: ['cooking', 'graphic design', 'events'],
      isActive: true,
      views: 5,
      requests: 0,
      imageUrl: 'assets/images/onboarding_3.png',
    ),
    Swap(
      id: 'mock_4',
      userId: 'agnes_012',
      userName: 'Agnes',
      userAvatar: 'assets/images/onboarding_2.png',
      skillOffered: 'dance',
      skillWanted: 'video editing',
      description:
          'I am good at dancing and want to learn video editing to create amazing dance videos.',
      createdAt: DateTime.now().subtract(Duration(minutes: 15)),
      location: 'Nairobi, Kenya',
      tags: ['dance', 'video editing', 'content creation'],
      isActive: true,
      views: 2,
      requests: 0,
      imageUrl: 'assets/images/onboarding_1.png',
    ),
  ];

  void _viewSwap(Swap swap) async {
    // Increment view count
    _repository.incrementViews(swap.id);

    // Fetch the full user profile for the swap's user
    final profileRepo = ProfileRepository();
    final UserProfile? userProfile = await profileRepo.getUserProfileById(swap.userId);

    if (userProfile != null && mounted) {
      showDialog(
        context: context,
        builder: (context) => UserProfileDialog(userProfile: userProfile),
      );
    } else {
      // Fallback: show swap details dialog if user profile not found
      showDialog(
        context: context,
        builder: (context) => _SwapDetailsDialog(swap: swap),
      );
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
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                widget.filterSkill != null ? 'Filtered Skills' : 'All Swaps',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                  color: Color(0xFF121717),
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            Expanded(
              child: _buildUsersList(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUsersList() {
    final profileRepo = ProfileRepository();
    
    // Use filtered stream if filterSkill is provided
    final stream = widget.filterSkill != null 
        ? _repository.getUsersBySkill(widget.filterSkill!)
        : Stream.value(<Swap>[]).asyncMap((_) async {
            final users = await profileRepo.getAllUsers().first;
            return users.map((userProfile) {
              final skillOffered = userProfile.skillsOffered.isNotEmpty ? userProfile.skillsOffered.first : 'not specified';
              final skillWanted = userProfile.skillsWanted.isNotEmpty ? userProfile.skillsWanted.first : 'not specified';
              
              return Swap(
                id: userProfile.uid,
                userId: userProfile.uid,
                userName: userProfile.name,
                userAvatar: userProfile.avatarUrl ?? 'assets/images/onboarding_1.png',
                skillOffered: skillOffered,
                skillWanted: skillWanted,
                description: '${userProfile.name} is good at $skillOffered and wants to learn $skillWanted.',
                createdAt: DateTime.now(),
                location: userProfile.location ?? '',
                tags: [],
                isActive: true,
                views: 0,
                requests: userProfile.swapScore,
                imageUrl: null,
              );
            }).toList();
          });
    
    return StreamBuilder<List<Swap>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  'Error loading users: ${snapshot.error}',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
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
            child: Text(widget.filterSkill != null 
                ? 'No users found with ${widget.filterSkill} skills.'
                : 'No users found.'),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          itemCount: swaps.length,
          itemBuilder: (context, index) {
            return _buildUserCard(swaps[index]);
          },
        );
      },
    );
  }

  Widget _buildUserCard(Swap swap) {
    final String skillOffered = swap.skillOffered;
    final String skillWanted = swap.skillWanted;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          CircleAvatar(
            radius: 28,
            backgroundImage: swap.userAvatar.startsWith('http')
                ? NetworkImage(swap.userAvatar)
                : AssetImage(swap.userAvatar),
          ),
          const SizedBox(width: 16),
          // Name, sentence, and buttons
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  swap.userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${swap.userName} is good at $skillOffered and wants to learn $skillWanted.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: ElevatedButton(
                          onPressed: () async {
                            // Create a UserProfile from the swap data
                            final userProfile = UserProfile(
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
                              swapScore: swap.requests,
                              notificationsEnabled: true,
                              privacySettings: {},
                              avatarUrl: swap.userAvatar,
                            );
                            showDialog(
                              context: context,
                              builder: (context) => UserProfileDialog(userProfile: userProfile),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1DA1F2),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: const Text(
                            'View',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/swap', arguments: swap.userId);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF8A00),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.zero,
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

  void _showMockData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mock Data'),
        content: Text('This will show sample swaps without Firebase.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _showOfflineMockData = true;
              });
            },
            child: Text('Show Mock Data'),
          ),
        ],
      ),
    );
  }

  Widget _buildMockSwapsList() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Showing mock data (offline mode)',
                  style: TextStyle(
                    color: Colors.orange[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _showOfflineMockData = false),
                child: Text(
                  'Switch to Firebase',
                  style: TextStyle(color: Colors.orange[800]),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            itemCount: _mockSwaps.length,
            itemBuilder: (context, index) {
              return _buildSwapCard(_mockSwaps[index]);
            },
          ),
        ),
      ],
    );
  }

  void _showFullScreenImage(String imageUrl, String userName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            _FullScreenImageView(imageUrl: imageUrl, userName: userName),
      ),
    );
  }

  Widget _buildSwapCard(Swap swap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage(swap.userAvatar),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      swap.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      _repository.getTimeAgo(swap.createdAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${swap.userName} is good at ${_formatSkill(swap.skillOffered)}, and ${swap.userName} wants to learn ${_formatSkill(swap.skillWanted)}.',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          // Display image if available
          if (swap.imageUrl != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _showFullScreenImage(swap.imageUrl!, swap.userName),
              child: Container(
                height: 200,
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
                                value:
                                    loadingProgress.expectedTotalBytes != null
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
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'View',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/swap', arguments: swap.userId),
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
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SwapDetailsDialog extends StatelessWidget {
  final Swap swap;

  const _SwapDetailsDialog({required this.swap});

  void _showFullScreenImage(
    BuildContext context,
    String imageUrl,
    String userName,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            _FullScreenImageView(imageUrl: imageUrl, userName: userName),
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
                        swap.location.isNotEmpty
                            ? swap.location
                            : 'Location not specified',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
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
                onTap: () => _showFullScreenImage(
                  context,
                  swap.imageUrl!,
                  swap.userName,
                ),
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
                                  value:
                                      loadingProgress.expectedTotalBytes != null
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
                children: swap.tags
                    .map(
                      (tag) => Chip(
                        label: Text(tag),
                        backgroundColor: Colors.grey[200],
                        labelStyle: TextStyle(fontSize: 12),
                      ),
                    )
                    .toList(),
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
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
            ),
          ],
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
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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

class _FullScreenImageView extends StatelessWidget {
  final String imageUrl;
  final String userName;

  const _FullScreenImageView({required this.imageUrl, required this.userName});

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
