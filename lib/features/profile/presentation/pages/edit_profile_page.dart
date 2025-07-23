import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/profile_repository.dart';
import '../../models/user_profile.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfile userProfile;

  const EditProfilePage({super.key, required this.userProfile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ProfileRepository _repository = ProfileRepository();
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late TextEditingController _locationController;
  
  // Availability dropdown
  String? _selectedAvailability;
  
  // Predefined availability options
  static const List<String> _availabilityOptions = [
    'Mornings (6 AM - 12 PM)',
    'Afternoons (12 PM - 6 PM)',
    'Evenings (6 PM - 12 AM)',
    'Late Night (12 AM - 6 AM)',
    'Weekends Only',
    'Weekdays Only',
    'Flexible',
    'By Appointment',
  ];
  
  // Popular locations for quick selection
  static const List<String> _popularLocations = [
    'New York, USA',
    'London, UK',
    'Tokyo, Japan',
    'Paris, France',
    'Sydney, Australia',
    'Toronto, Canada',
    'Berlin, Germany',
    'Singapore',
    'Dubai, UAE',
    'Mumbai, India',
    'São Paulo, Brazil',
    'Mexico City, Mexico',
    'Cairo, Egypt',
    'Lagos, Nigeria',
    'Nairobi, Kenya',
    'Cape Town, South Africa',
    'Kigali, Rwanda',
    'Accra, Ghana',
    'Addis Ababa, Ethiopia',
    'Dar es Salaam, Tanzania',
  ];
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userProfile.name);
    _usernameController = TextEditingController(text: widget.userProfile.username ?? '');
    _bioController = TextEditingController(text: widget.userProfile.bio ?? '');
    _locationController = TextEditingController(text: widget.userProfile.location ?? '');
    
    // Set initial availability value with mapping for old values
    _selectedAvailability = _mapOldAvailabilityToNew(widget.userProfile.availability);
  }

  // Map old availability values to new ones for backward compatibility
  String? _mapOldAvailabilityToNew(String? oldAvailability) {
    if (oldAvailability == null || oldAvailability.isEmpty) {
      return null;
    }
    
    final lowerOld = oldAvailability.toLowerCase();
    
    // Map old values to new ones
    if (lowerOld.contains('evening')) {
      return 'Evenings (6 PM - 12 AM)';
    } else if (lowerOld.contains('morning')) {
      return 'Mornings (6 AM - 12 PM)';
    } else if (lowerOld.contains('afternoon') || lowerOld.contains('mid day') || lowerOld.contains('midday')) {
      return 'Afternoons (12 PM - 6 PM)';
    } else if (lowerOld.contains('night') || lowerOld.contains('late')) {
      return 'Late Night (12 AM - 6 AM)';
    } else if (lowerOld.contains('weekend')) {
      return 'Weekends Only';
    } else if (lowerOld.contains('weekday')) {
      return 'Weekdays Only';
    } else if (lowerOld.contains('flexible')) {
      return 'Flexible';
    } else if (lowerOld.contains('appointment')) {
      return 'By Appointment';
    }
    
    // If no match found, return null (will show as unselected)
    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _saveProfile,
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Color(0xFF225B4B),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture Section
              _buildProfilePictureSection(),
              const SizedBox(height: 32),

              // Basic Information
              _buildSectionTitle('Basic Information'),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _usernameController,
                label: 'Username',
                icon: Icons.alternate_email,
                hint: 'e.g., johnkinggraphics',
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    if (value.contains(' ')) {
                      return 'Username cannot contain spaces';
                    }
                    if (value.length < 3) {
                      return 'Username must be at least 3 characters';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _bioController,
                label: 'Bio',
                icon: Icons.description_outlined,
                hint: 'Tell others about yourself...',
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Location & Availability
              _buildSectionTitle('Location & Availability'),
              const SizedBox(height: 16),

              _buildLocationField(),
              const SizedBox(height: 16),

              _buildAvailabilityDropdown(),
              const SizedBox(height: 32),

              // Privacy Settings
              _buildSectionTitle('Privacy Settings'),
              const SizedBox(height: 16),
              
              _buildPrivacySettings(),
              const SizedBox(height: 32),

              // Notification Settings
              _buildSectionTitle('Notification Settings'),
              const SizedBox(height: 16),
              
              _buildNotificationSettings(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: _getProfileImage(widget.userProfile.avatarUrl),
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
                    onPressed: _changeProfilePicture,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _changeProfilePicture,
            child: const Text(
              'Change Profile Picture',
              style: TextStyle(
                color: Color(0xFF225B4B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF225B4B), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red[300]!),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _locationController,
          decoration: InputDecoration(
            labelText: 'Enter your location',
            hintText: 'e.g., Lagos, Nigeria',
            prefixIcon: const Icon(Icons.location_on_outlined, color: Colors.grey),
            suffixIcon: PopupMenuButton<String>(
              icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
              onSelected: (String location) {
                setState(() {
                  _locationController.text = location;
                });
              },
              itemBuilder: (BuildContext context) {
                return _popularLocations.map((String location) {
                  return PopupMenuItem<String>(
                    value: location,
                    child: Text(location),
                  );
                }).toList();
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF225B4B), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Or select from popular locations',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Availability',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedAvailability,
          decoration: InputDecoration(
            labelText: 'Select your availability',
            prefixIcon: const Icon(Icons.calendar_today_outlined, color: Colors.grey),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Color(0xFF225B4B), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          hint: const Text('Choose your availability'),
          items: _availabilityOptions.map((String availability) {
            return DropdownMenuItem<String>(
              value: availability,
              child: Text(availability),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedAvailability = newValue;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select your availability';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPrivacySettings() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildPrivacyOption(
            'Profile Visibility',
            'Make your profile visible to other users',
            true,
            (value) {
              // TODO: Implement privacy setting
            },
          ),
          const SizedBox(height: 16),
          _buildPrivacyOption(
            'Show Email',
            'Allow other users to see your email',
            false,
            (value) {
              // TODO: Implement privacy setting
            },
          ),
          const SizedBox(height: 16),
          _buildPrivacyOption(
            'Show Location',
            'Allow other users to see your location',
            true,
            (value) {
              // TODO: Implement privacy setting
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyOption(String title, String subtitle, bool initialValue, Function(bool) onChanged) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: initialValue,
          onChanged: onChanged,
          activeColor: const Color(0xFF225B4B),
        ),
      ],
    );
  }

  Widget _buildNotificationSettings() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildNotificationOption(
            'Push Notifications',
            'Receive notifications for new messages and swap requests',
            widget.userProfile.notificationsEnabled,
            (value) async {
              try {
                await _repository.updateNotificationSettings(value);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(value ? 'Notifications enabled' : 'Notifications disabled'),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update notification settings: $e')),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 16),
          _buildNotificationOption(
            'Email Notifications',
            'Receive email notifications for important updates',
            true,
            (value) {
              // TODO: Implement email notification setting
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationOption(String title, String subtitle, bool initialValue, Function(bool) onChanged) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: initialValue,
          onChanged: onChanged,
          activeColor: const Color(0xFF225B4B),
        ),
      ],
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
          // Refresh the page to show the new image
          setState(() {});
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

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _repository.updateProfile(
        name: _nameController.text.trim(),
        username: _usernameController.text.trim().isNotEmpty 
            ? _usernameController.text.trim() 
            : null,
        bio: _bioController.text.trim().isNotEmpty 
            ? _bioController.text.trim() 
            : null,
        location: _locationController.text.trim().isNotEmpty 
            ? _locationController.text.trim() 
            : null,
        availability: _selectedAvailability,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
} 