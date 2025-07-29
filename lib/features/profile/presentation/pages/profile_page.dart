import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/profile_repository.dart';
import '../../models/user_profile.dart';
import 'edit_profile_page.dart';
import '../../../swap/presentation/pages/swap_library_page.dart';
import '../../../../core/widgets/theme_switch.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback? onBackToHome;
  
  const ProfilePage({super.key, this.onBackToHome});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileRepository _repository = ProfileRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<UserProfile?>(
                stream: _repository.getCurrentUserProfile(),
                builder: (context, snapshot) {
                  try {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Error loading profile',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${snapshot.error}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => setState(() {}),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final userProfile = snapshot.data;
                    if (userProfile == null) {
                      return const Center(
                        child: Text('Profile not found'),
                      );
                    }

                    // Check if profile needs completion
                    if (userProfile.isProfileComplete == false) {
                      return _buildProfileCompletionPrompt(context, userProfile);
                    }

                    return Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          // Header with back button
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back, size: 28),
                                onPressed: () {
                                  if (widget.onBackToHome != null) {
                                    widget.onBackToHome!();
                                  } else {
                                    // Fallback to home navigation
                                    Navigator.of(context).pushReplacementNamed('/home');
                                  }
                                },
                              ),
                              const Spacer(),
                              Text(
                                'Your Profile',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 24),
                                onPressed: () => _navigateToEditProfile(userProfile),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Profile Picture and Basic Info
                          _buildProfileSection(userProfile),
                          const SizedBox(height: 24),

                          // Key Information Block
                          _buildKeyInfoSection(userProfile),
                          const SizedBox(height: 24),

                          // Skill Library Section
                          _buildSkillLibrarySection(userProfile),
                          const SizedBox(height: 24),

                          // Reviews Section
                          _buildReviewsSection(userProfile),
                          const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    );
                  } catch (e) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Something went wrong',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Error: $e',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => setState(() {}),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
      ),
    );
  }

  Widget _buildProfileSection(UserProfile userProfile) {
    return Column(
      children: [
        // Profile Picture with Edit Button
        Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: _getProfileImage(userProfile.avatarUrl),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => _changeProfilePicture(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Name
        Text(
          userProfile.name,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF3E8E7E)
                : const Color(0xFF225B4B),
          ),
        ),
        const SizedBox(height: 4),

        // Username
        Text(
          userProfile.username != null ? '@${userProfile.username}' : '@${userProfile.name.toLowerCase().replaceAll(' ', '')}',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white70
                : Colors.grey,
          ),
        ),
        const SizedBox(height: 16),

        // Swap Score
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.swap_horiz,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              '${userProfile.swapScore}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ],
        ),
        Text(
          'Swap Score',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white70
                : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildKeyInfoSection(UserProfile userProfile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF3E8E7E)
            : const Color(0xFF225B4B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildInfoColumn(
              'Location',
              userProfile.location ?? 'Not set',
              Icons.location_on,
              Colors.red,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: _buildInfoColumn(
              'Availability',
              userProfile.availability ?? 'Not set',
              Icons.calendar_today,
              Colors.white,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SwapLibraryPage()),
                );
              },
              child: _buildInfoColumn(
                'Swap Library',
                '${userProfile.skillsOffered.length + userProfile.skillsWanted.length} skills',
                Icons.library_books,
                Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String title, String value, IconData icon, Color iconColor) {
    return Column(
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSkillLibrarySection(UserProfile userProfile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Skill Library',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
        ),
        const SizedBox(height: 20),
        
        // Skills Being Offered Section
        _buildSkillsSection(
          'Skills Being Offered',
          userProfile.skillsOffered,
          Icons.upload,
          const Color(0xFF225B4B),
          () => _addSkill('offered'),
          (skill) => _removeSkill(skill, 'offered'),
        ),
        
        const SizedBox(height: 24),
        
        // Skills Wanted Section
        _buildSkillsSection(
          'Skills Wanted',
          userProfile.skillsWanted,
          Icons.download,
          const Color(0xFF4CAF50),
          () => _addSkill('wanted'),
          (skill) => _removeSkill(skill, 'wanted'),
        ),
      ],
    );
  }

  Widget _buildSkillsSection(
    String title,
    List<String> skills,
    IconData icon,
    Color color,
    VoidCallback onAdd,
    Function(String) onRemove,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(Icons.add, color: color),
              onPressed: onAdd,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (skills.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? color.withValues(alpha: 0.2)
                  : color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? color.withValues(alpha: 0.5)
                    : color.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              'No ${title.toLowerCase()} yet. Tap the + button to add!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? color.withValues(alpha: 0.9)
                    : color.withValues(alpha: 0.7),
              ),
            ),
          )
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: skills.map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      skill,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => onRemove(skill),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildReviewsSection(UserProfile userProfile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reviews',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        if (userProfile.reviews.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E1E1E)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'No reviews yet. Start swapping to get reviews!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.grey,
              ),
            ),
          )
        else
          Column(
            children: userProfile.reviews.take(2).map((review) {
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1E1E1E)
                      : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[700]!
                        : Colors.grey[200]!,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['reviewText'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '- ${review['reviewerName'] ?? 'Anonymous'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white60
                            : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  void _navigateToEditProfile(UserProfile userProfile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(userProfile: userProfile),
      ),
    );
  }

  void _changeProfilePicture() {
    _showImageSourceDialog();
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadImage(ImageSource.gallery);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Pick image
      final imageFile = await _pickImage(source);
      if (imageFile == null) {
        Navigator.pop(context); // Close loading dialog
        return;
      }

      // Upload image
      final downloadUrl = await _repository.uploadProfileImage(imageFile);
      
      Navigator.pop(context); // Close loading dialog

      if (downloadUrl != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to upload profile picture. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<File?> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  ImageProvider _getProfileImage(String? avatarUrl) {
    if (avatarUrl == null || avatarUrl.isEmpty) {
      return const AssetImage('assets/images/onboarding_1.png');
    }
    
    if (avatarUrl.startsWith('local://')) {
      // Handle local image
      final String localPath = avatarUrl.replaceFirst('local://', '');
      final File localFile = File(localPath);
      
      // Check if local file exists, if not return default image
      if (localFile.existsSync()) {
        return FileImage(localFile);
      } else {
        // Local file doesn't exist (probably cleared after emulator restart)
        // Clear the invalid URL from Firestore
        _clearInvalidAvatarUrl();
        return const AssetImage('assets/images/onboarding_1.png');
      }
    } else {
      // Handle network image
      return NetworkImage(avatarUrl);
    }
  }

  void _clearInvalidAvatarUrl() {
    // Clear invalid local URL from Firestore
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'avatarUrl': ''})
          .catchError((e) => print('Error clearing invalid avatar URL: $e'));
    }
  }

  void _addSkill(String type) {
    showDialog(
      context: context,
      builder: (context) => _AddSkillDialog(
        skillType: type,
        onSkillAdded: (skill) async {
          try {
            if (type == 'offered') {
              await _repository.addSkillOffered(skill);
            } else {
              await _repository.addSkillWanted(skill);
            }
            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Added $skill to your ${type == 'offered' ? 'skills offered' : 'skills wanted'}')),
              );
            }
          } catch (e) {
            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to add skill: $e')),
              );
            }
          }
        },
      ),
    );
  }

  void _removeSkill(String skill, String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Skill'),
        content: Text('Are you sure you want to remove "$skill" from your ${type == 'offered' ? 'skills offered' : 'skills wanted'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                if (type == 'offered') {
                  await _repository.removeSkillOffered(skill);
                } else {
                  await _repository.removeSkillWanted(skill);
                }
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Removed $skill from your ${type == 'offered' ? 'skills offered' : 'skills wanted'}')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to remove skill: $e')),
                  );
                }
              }
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCompletionPrompt(BuildContext context, UserProfile userProfile) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark 
          ? const Color(0xFF121212)
          : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person_add,
                size: 80,
                color: Color(0xFF225B4B),
              ),
              const SizedBox(height: 24),
              Text(
                'Complete Your Profile',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white 
                      : const Color(0xFF225B4B),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Welcome to SkillSwap! Please complete your profile to start swapping skills with others.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.grey[300]
                      : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF225B4B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfilePage(
                          userProfile: userProfile,
                          isNewUser: true,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Complete Profile',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // Sign out using auth bloc
                  context.read<AuthBloc>().add(const AuthSignOutRequested());
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddSkillDialog extends StatefulWidget {
  final Function(String) onSkillAdded;
  final String skillType;

  const _AddSkillDialog({required this.onSkillAdded, required this.skillType});

  @override
  State<_AddSkillDialog> createState() => _AddSkillDialogState();
}

class _AddSkillDialogState extends State<_AddSkillDialog> {
  String? _selectedSkill;
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredSkills = [];
  
  @override
  void initState() {
    super.initState();
    _filteredSkills = _predefinedSkills;
    _searchController.addListener(_filterSkills);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterSkills() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredSkills = _predefinedSkills;
      } else {
        _filteredSkills = _predefinedSkills
            .where((skill) => skill.toLowerCase().contains(query))
            .toSet() // Ensure unique values
            .toList();
      }
      // Clear selection if the selected skill is no longer in filtered list
      if (_selectedSkill != null && !_filteredSkills.contains(_selectedSkill)) {
        _selectedSkill = null;
      }
    });
  }
  
  // Comprehensive list of predefined skills (ensuring uniqueness)
  static const List<String> _predefinedSkills = [
    // Technology & Programming
    'JavaScript', 'Python', 'Java', 'C++', 'C#', 'PHP', 'Ruby', 'Swift', 'Kotlin', 'Go', 'Rust', 'TypeScript',
    'React', 'Angular', 'Vue.js', 'Node.js', 'Flutter', 'React Native', 'Django', 'Flask', 'Laravel', 'Spring Boot',
    'HTML/CSS', 'SQL', 'MongoDB', 'PostgreSQL', 'AWS', 'Docker', 'Kubernetes', 'Git', 'Linux', 'DevOps',
    
    // Creative & Design
    'Graphic Design', 'UI/UX Design', 'Web Design', 'Logo Design', 'Illustration', 'Digital Art', '3D Modeling',
    'Animation', 'Video Editing', 'Photo Editing', 'Adobe Photoshop', 'Adobe Illustrator', 'Figma', 'Sketch',
    'InDesign', 'Premiere Pro', 'After Effects', 'Blender', 'Cinema 4D', 'Typography', 'Color Theory',
    
    // Languages
    'English', 'Spanish', 'French', 'German', 'Italian', 'Portuguese', 'Russian', 'Chinese (Mandarin)', 
    'Japanese', 'Korean', 'Arabic', 'Hindi', 'Dutch', 'Swedish', 'Norwegian', 'Danish', 'Finnish', 'Polish',
    'Turkish', 'Greek', 'Hebrew', 'Thai', 'Vietnamese', 'Indonesian', 'Malay', 'Tagalog', 'Swahili',
    
    // Music & Audio
    'Guitar', 'Piano', 'Violin', 'Drums', 'Bass', 'Saxophone', 'Trumpet', 'Flute', 'Clarinet', 'Voice/Singing',
    'Music Production', 'Audio Engineering', 'Sound Design', 'DJing', 'Music Theory', 'Composition', 'Arrangement',
    
    // Sports & Fitness
    'Yoga', 'Pilates', 'CrossFit', 'Weight Training', 'Running', 'Swimming', 'Cycling', 'Tennis', 'Basketball',
    'Soccer', 'Volleyball', 'Badminton', 'Table Tennis', 'Golf', 'Rock Climbing', 'Martial Arts', 'Boxing',
    'Kickboxing', 'Jiu-Jitsu', 'Karate', 'Taekwondo', 'Dance', 'Gymnastics', 'Skateboarding', 'Surfing',
    
    // Cooking & Culinary
    'Cooking', 'Baking', 'Pastry Making', 'Grilling', 'Sushi Making', 'Italian Cuisine', 'French Cuisine',
    'Asian Cuisine', 'Mexican Cuisine', 'Indian Cuisine', 'Mediterranean Cuisine', 'Vegan Cooking', 'Meal Prep',
    'Wine Tasting', 'Coffee Brewing', 'Cocktail Making', 'Food Photography', 'Nutrition', 'Food Safety',
    
    // Arts & Crafts
    'Drawing', 'Painting', 'Watercolor', 'Oil Painting', 'Acrylic Painting', 'Sketching', 'Calligraphy',
    'Pottery', 'Ceramics', 'Sculpture', 'Woodworking', 'Carpentry', 'Knitting', 'Crocheting', 'Sewing',
    'Embroidery', 'Quilting', 'Jewelry Making', 'Glass Blowing', 'Leather Crafting', 'Origami', 'Paper Crafting',
    
    // Photography & Videography
    'Photography', 'Portrait Photography', 'Landscape Photography', 'Street Photography', 'Wedding Photography',
    'Product Photography', 'Food Photography', 'Wildlife Photography', 'Astrophotography', 'Videography',
    'Documentary Filmmaking', 'Video Production', 'Drone Photography', 'Photo Editing', 'Lightroom', 'Final Cut Pro',
    
    // Business & Professional
    'Project Management', 'Leadership', 'Public Speaking', 'Presentation Skills', 'Negotiation', 'Sales',
    'Marketing', 'Digital Marketing', 'Social Media Marketing', 'Content Creation', 'Copywriting', 'SEO',
    'Data Analysis', 'Excel', 'PowerPoint', 'Word', 'Accounting', 'Financial Planning', 'Investing',
    'Entrepreneurship', 'Business Strategy', 'Customer Service', 'Human Resources', 'Legal Research',
    
    // Education & Academic
    'Mathematics', 'Physics', 'Chemistry', 'Biology', 'History', 'Geography', 'Literature', 'Philosophy',
    'Psychology', 'Sociology', 'Economics', 'Political Science', 'Statistics', 'Research Methods', 'Essay Writing',
    'Academic Writing', 'Critical Thinking', 'Study Skills', 'Time Management', 'Note Taking',
    
    // Health & Wellness
    'Meditation', 'Mindfulness', 'Stress Management', 'Mental Health', 'Nutrition', 'Personal Training',
    'Physical Therapy', 'Massage Therapy', 'Acupuncture', 'Herbal Medicine', 'First Aid', 'CPR',
    'Health Coaching', 'Life Coaching', 'Career Counseling', 'Relationship Counseling',
    
    // Home & Lifestyle
    'Gardening', 'Indoor Plants', 'Home Organization', 'Interior Design', 'Feng Shui', 'DIY Projects',
    'Home Repair', 'Plumbing', 'Electrical Work', 'Auto Repair', 'Car Maintenance', 'Pet Training',
    'Dog Training', 'Cat Care', 'Aquarium Keeping', 'Beekeeping', 'Chicken Keeping', 'Urban Farming',
    
    // Travel & Adventure
    'Travel Planning', 'Backpacking', 'Hiking', 'Camping', 'Scuba Diving', 'Sailing',
    'Kayaking', 'Canoeing', 'Mountain Biking', 'Snowboarding', 'Skiing', 'Ice Skating', 'Paragliding',
    'Skydiving', 'Cultural Exchange', 'Language Exchange', 'Volunteering', 'Conservation',
    
    // Gaming & Entertainment
    'Game Development', 'Board Games', 'Chess', 'Poker', 'Magic Tricks', 'Juggling', 'Comedy', 'Improv',
    'Acting', 'Theater', 'Stand-up Comedy', 'Storytelling', 'Creative Writing', 'Poetry', 'Screenwriting',
    'Podcasting', 'Streaming', 'Esports', 'Speed Cubing', 'Escape Room Design',
    
    // Technical & Engineering
    'Mechanical Engineering', 'Electrical Engineering', 'Civil Engineering', 'Chemical Engineering',
    'Robotics', 'Arduino', 'Raspberry Pi', '3D Printing', 'CNC Machining', 'Welding', 'Metalworking',
    'Electronics', 'Circuit Design', 'PCB Design', 'CAD Design', 'AutoCAD', 'SolidWorks', 'Fusion 360',
    
    // Communication & Media
    'Journalism', 'Blogging', 'Vlogging', 'Radio Broadcasting', 'Voice Acting', 'Translation',
    'Interpretation', 'Technical Writing', 'Grant Writing', 'Resume Writing', 'Interview Skills',
    'Networking', 'Social Skills', 'Conflict Resolution', 'Team Building', 'Mentoring', 'Coaching',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add ${widget.skillType == 'offered' ? 'Skill to Offer' : 'Skill Wanted'}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Select a skill from the list below:',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          // Search field
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search skills...',
              hintText: 'Type to search for a skill',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            constraints: const BoxConstraints(maxHeight: 300),
            child: DropdownButtonFormField<String>(
              value: _selectedSkill,
              decoration: const InputDecoration(
                labelText: 'Choose Skill',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              hint: Text(_filteredSkills.isEmpty ? 'No skills found' : 'Select a skill...'),
              items: _filteredSkills.toSet().map((skill) {
                return DropdownMenuItem<String>(
                  value: skill,
                  child: Text(skill),
                );
              }).toList(),
              onChanged: _filteredSkills.isEmpty ? null : (value) {
                setState(() {
                  _selectedSkill = value;
                });
              },
              isExpanded: true,
              menuMaxHeight: 250,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _selectedSkill != null ? () {
            widget.onSkillAdded(_selectedSkill!);
          } : null,
          child: const Text('Add'),
        ),
      ],
    );
  }
} 