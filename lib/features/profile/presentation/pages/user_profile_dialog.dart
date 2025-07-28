import 'package:flutter/material.dart';
import '../../models/user_profile.dart';

class UserProfileDialog extends StatelessWidget {
  final UserProfile userProfile;

  const UserProfileDialog({Key? key, required this.userProfile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).brightness == Brightness.dark 
          ? const Color(0xFF2A2A2A)
          : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture and Basic Info
            Center(child: _buildProfileSection(context)),
            const SizedBox(height: 24),
            // Key Information Block
            _buildKeyInfoSection(),
            const SizedBox(height: 24),
            // Skill Library Section
            _buildSkillLibrarySection(context),
            const SizedBox(height: 24),
            // Reviews Section
            _buildReviewsSection(context),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Close',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white 
                        : Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: _getProfileImage(userProfile.avatarUrl),
        ),
        const SizedBox(height: 16),
        Text(
          userProfile.name,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white 
                : Color(0xFF225B4B),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          userProfile.username != null && userProfile.username!.isNotEmpty
              ? '@${userProfile.username}'
              : '@${userProfile.name.toLowerCase().replaceAll(' ', '')}',
          style: TextStyle(
            fontSize: 15, 
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.grey[400]
                : Colors.grey
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.swap_horiz, 
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.white 
                  : Colors.black, 
              size: 20
            ),
            const SizedBox(width: 6),
            Text(
              '${userProfile.swapScore}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white 
                    : Colors.black,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'Swap Score', 
              style: TextStyle(
                fontSize: 13, 
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.grey[400]
                    : Colors.grey
              )
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKeyInfoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF225B4B),
        borderRadius: BorderRadius.circular(14),
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
          Container(width: 1, height: 36, color: Colors.white.withOpacity(0.3)),
          Expanded(
            child: _buildInfoColumn(
              'Availability',
              userProfile.availability ?? 'Not set',
              Icons.calendar_today,
              Colors.white,
            ),
          ),
          Container(width: 1, height: 36, color: Colors.white.withOpacity(0.3)),
          Expanded(
            child: _buildInfoColumn(
              'Skills Offered',
              '${userProfile.skillsOffered.length} skills',
              Icons.library_books,
              Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String title, String value, IconData icon, Color iconColor) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(height: 6),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 11), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildSkillLibrarySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skills Offered', 
          style: TextStyle(
            fontSize: 17, 
            fontWeight: FontWeight.bold, 
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white 
                : Colors.black
          )
        ),
        const SizedBox(height: 10),
        if (userProfile.skillsOffered.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.grey[800]
                  : Colors.grey[100], 
              borderRadius: BorderRadius.circular(10)
            ),
            child: Text(
              'No skills offered yet.', 
              textAlign: TextAlign.center, 
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.grey[400]
                    : Colors.grey
              )
            ),
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: userProfile.skillsOffered.map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFF225B4B), borderRadius: BorderRadius.circular(20)),
                child: Text(skill, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
              );
            }).toList(),
          ),
        const SizedBox(height: 16),
        Text(
          'Skills Wanted', 
          style: TextStyle(
            fontSize: 17, 
            fontWeight: FontWeight.bold, 
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white 
                : Colors.black
          )
        ),
        const SizedBox(height: 10),
        if (userProfile.skillsWanted.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.grey[800]
                  : Colors.grey[100], 
              borderRadius: BorderRadius.circular(10)
            ),
            child: Text(
              'No skills wanted yet.', 
              textAlign: TextAlign.center, 
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.grey[400]
                    : Colors.grey
              )
            ),
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: userProfile.skillsWanted.map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(20)),
                child: Text(skill, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildReviewsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reviews', 
          style: TextStyle(
            fontSize: 17, 
            fontWeight: FontWeight.bold, 
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white 
                : Colors.black
          )
        ),
        const SizedBox(height: 10),
        if (userProfile.reviews.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.grey[800]
                  : Colors.grey[100], 
              borderRadius: BorderRadius.circular(10)
            ),
            child: Text(
              'No reviews yet.', 
              textAlign: TextAlign.center, 
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.grey[400]
                    : Colors.grey
              )
            ),
          )
        else
          Column(
            children: userProfile.reviews.take(2).map((review) {
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.grey[800]
                      : Colors.grey[50], 
                  borderRadius: BorderRadius.circular(10), 
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[700]!
                        : Colors.grey[200]!
                  )
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['reviewText'] ?? '', 
                      style: TextStyle(
                        fontSize: 13, 
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.grey[300]
                            : Colors.grey
                      )
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '- ${review['reviewerName'] ?? 'Anonymous'}', 
                      style: TextStyle(
                        fontSize: 11, 
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.grey[400]
                            : Colors.grey, 
                        fontWeight: FontWeight.w500
                      )
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  ImageProvider _getProfileImage(String? avatarUrl) {
    if (avatarUrl == null || avatarUrl.isEmpty) {
      return const AssetImage('assets/images/onboarding_1.png');
    }
    if (avatarUrl.startsWith('http')) {
      return NetworkImage(avatarUrl);
    }
    return AssetImage(avatarUrl);
  }
} 