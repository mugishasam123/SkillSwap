import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/profile_repository.dart';
import '../../models/user_profile.dart';
import '../../../../core/widgets/theme_switch.dart';

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
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).brightness == Brightness.dark 
                        ? Colors.grey[400]!
                        : Colors.grey
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveProfile,
              child: Text(
                'Save',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? const Color(0xFF3E8E7E)
                      : const Color(0xFF225B4B),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const ThemeSwitch(),
            Expanded(
              child: SingleChildScrollView(
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
                      _buildSectionTitle('BASIC INFORMATION'),
                      const SizedBox(height: 16),

                      _buildNameField(),
                      const SizedBox(height: 16),

                      _buildUsernameField(),
                      const SizedBox(height: 16),

                      _buildBioField(),
                      const SizedBox(height: 32),

                      // Location & Availability
                      _buildSectionTitle('LOCATION & AVAILABILITY'),
                      const SizedBox(height: 16),

                      _buildLocationField(),
                      const SizedBox(height: 16),

                      _buildAvailabilityDropdown(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
            child:           Text(
            'Change Profile Picture',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF3E8E7E)
                  : const Color(0xFF225B4B),
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
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).brightness == Brightness.dark 
            ? Colors.white 
            : Colors.black,
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
      style: TextStyle(
        color: Theme.of(context).brightness == Brightness.dark 
            ? Colors.white 
            : Colors.black,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.grey[400]
              : Colors.grey[600],
        ),
        hintText: hint,
        hintStyle: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.grey[500]
              : Colors.grey[600],
        ),
        prefixIcon: Icon(
          icon, 
          color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.grey[400]
              : Colors.grey[600]
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.grey[700]!
                : Colors.grey[300]!
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.grey[700]!
                : Colors.grey[300]!
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark 
                ? const Color(0xFF3E8E7E)
                : const Color(0xFF225B4B), 
            width: 2
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red[300]!),
        ),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark 
            ? const Color(0xFF2A2A2A)
            : Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildNameField() {
    return _buildTextField(
      controller: _nameController,
      label: 'Full Name',
      icon: Icons.person_outline,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Name is required';
        }
        return null;
      },
    );
  }

  Widget _buildUsernameField() {
    return _buildTextField(
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
    );
  }

  Widget _buildBioField() {
    return _buildTextField(
      controller: _bioController,
      label: 'Bio',
      icon: Icons.description_outlined,
      hint: 'Tell others about yourself...',
      maxLines: 3,
    );
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white 
                : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _locationController,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white 
                : Colors.black,
          ),
          decoration: InputDecoration(
            labelText: 'Enter your location',
            labelStyle: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.grey[400]
                  : Colors.grey[600],
            ),
            hintText: 'e.g., Lagos, Nigeria',
            hintStyle: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.grey[500]
                  : Colors.grey[600],
            ),
            prefixIcon: Icon(
              Icons.location_on_outlined, 
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.grey[400]
                  : Colors.grey
            ),
            suffixIcon: PopupMenuButton<String>(
              icon: Icon(
                Icons.arrow_drop_down, 
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.grey[400]
                    : Colors.grey
              ),
              onSelected: (String location) {
                setState(() {
                  _locationController.text = location;
                });
              },
              itemBuilder: (BuildContext context) {
                return _popularLocations.map((String location) {
                  return PopupMenuItem<String>(
                    value: location,
                    child: Text(
                      location,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white 
                            : Colors.black,
                      ),
                    ),
                  );
                }).toList();
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.grey[700]!
                    : Colors.grey[300]!
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.grey[700]!
                    : Colors.grey[300]!
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? const Color(0xFF3E8E7E)
                    : const Color(0xFF225B4B), 
                width: 2
              ),
            ),
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark 
                ? const Color(0xFF2A2A2A)
                : Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Or select from popular locations',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.grey[400]
                : Colors.grey,
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
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white 
                : Colors.black,
          ),
          decoration: InputDecoration(
            labelText: 'Select your availability',
            labelStyle: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.grey[400]
                  : Colors.grey[600],
            ),
            prefixIcon: Icon(
              Icons.calendar_today_outlined, 
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.grey[400]
                  : Colors.grey
            ),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.grey[700]!
                    : Colors.grey
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? const Color(0xFF3E8E7E)
                    : const Color(0xFF225B4B), 
                width: 2
              ),
            ),
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark 
                ? const Color(0xFF2A2A2A)
                : Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          hint: Text(
            'Choose your availability',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.grey[500]
                  : Colors.grey[600],
            ),
          ),
          items: _availabilityOptions.map((String availability) {
            return DropdownMenuItem<String>(
              value: availability,
              child: Text(
                availability,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white 
                      : Colors.black,
                ),
              ),
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