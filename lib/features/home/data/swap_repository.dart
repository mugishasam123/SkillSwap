import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import '../models/swap.dart';
import '../../profile/data/image_upload_service.dart';
import '../../profile/models/user_profile.dart';
import 'package:flutter/material.dart';

class SwapRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImageUploadService _imageUploadService = ImageUploadService();

  // Get all active swaps
  Stream<List<Swap>> getAllSwaps() {
    return _firestore
        .collection('swaps')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Swap.fromJson(doc.data(), doc.id))
              .where((swap) => swap.isActive) // Filter in memory instead
              .toList(),
        );
  }

  // Get swaps filtered by skill
  Stream<List<Swap>> getSwapsBySkill(String skill) {
    return _firestore
        .collection('swaps')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          final allSwaps = snapshot.docs
              .map((doc) => Swap.fromJson(doc.data(), doc.id))
              .where((swap) => swap.isActive)
              .toList();

          // Create skill mappings for the 4 mocked skills only
          final skillMappings = {
            // CV & Resume Writing
            'resume writing': ['resume', 'cv', 'writing', 'resume writing', 'cv writing', 'cover letter', 'job application', 'professional writing'],
            
            // Digital Freelancing
            'freelancing': ['freelance', 'freelancing', 'digital freelancing', 'online work', 'remote work', 'gig work', 'contract work', 'self-employed'],
            
            // Video Editing
            'video editing': ['video', 'editing', 'video editing', 'capcut', 'video edit', 'premiere', 'after effects', 'final cut', 'film editing', 'post production'],
            
            // UI/UX Design
            'ui/ux': ['ui', 'ux', 'ui/ux', 'design', 'figma', 'user interface', 'user experience', 'web design', 'app design', 'prototyping', 'wireframing', 'adobe xd', 'sketch'],
          };
          
          final searchSkill = skill.toLowerCase();
          final mappedSkills = skillMappings[searchSkill] ?? [searchSkill];
          
          // Filter swaps that match the skill
          final filteredSwaps = allSwaps.where((swap) {
            final swapSkillOffered = swap.skillOffered.toLowerCase();
            final swapSkillWanted = swap.skillWanted.toLowerCase();
            
            // Check if swap has any of the mapped skills
            for (String mappedSkill in mappedSkills) {
              if (swapSkillOffered.contains(mappedSkill) ||
                  swapSkillWanted.contains(mappedSkill)) {
                return true;
              }
            }
            
            return false;
          }).toList();

          print('DEBUG: Filtering swaps for skill: $skill');
          print('DEBUG: Found ${filteredSwaps.length} swaps with matching skills');
          print('DEBUG: Matching swaps: ${filteredSwaps.map((s) => '${s.userName} (offers: ${s.skillOffered}, wants: ${s.skillWanted})').toList()}');
          
          return filteredSwaps;
        });
  }

  // Get users filtered by skill (keeping for backward compatibility)
  Stream<List<Swap>> getUsersBySkill(String skill) {
    return _firestore
        .collection('users')
        .snapshots()
        .map((snapshot) {
          final allUsers = snapshot.docs
              .map((doc) => UserProfile.fromJson(doc.data(), doc.id))
              .toList();

          // Create skill mappings for the 4 mocked skills only
          final skillMappings = {
            // CV & Resume Writing
            'resume writing': ['resume', 'cv', 'writing', 'resume writing', 'cv writing', 'cover letter', 'job application', 'professional writing'],
            
            // Digital Freelancing
            'freelancing': ['freelance', 'freelancing', 'digital freelancing', 'online work', 'remote work', 'gig work', 'contract work', 'self-employed'],
            
            // Video Editing
            'video editing': ['video', 'editing', 'video editing', 'capcut', 'video edit', 'premiere', 'after effects', 'final cut', 'film editing', 'post production'],
            
            // UI/UX Design
            'ui/ux': ['ui', 'ux', 'ui/ux', 'design', 'figma', 'user interface', 'user experience', 'web design', 'app design', 'prototyping', 'wireframing', 'adobe xd', 'sketch'],
          };
          
          final searchSkill = skill.toLowerCase();
          final mappedSkills = skillMappings[searchSkill] ?? [searchSkill];
          
          print('DEBUG: Search skill: $searchSkill');
          print('DEBUG: Mapped skills: $mappedSkills');

          // Filter users who have the specified skill (more flexible matching)
          final filteredUsers = allUsers.where((userProfile) {
            // Check ALL skills in both arrays, not just the first one
            final userSkillsOffered = userProfile.skillsOffered.map((s) => s.toLowerCase()).toList();
            final userSkillsWanted = userProfile.skillsWanted.map((s) => s.toLowerCase()).toList();
            
            // Check if user has any of the mapped skills in ANY of their skills
            for (String mappedSkill in mappedSkills) {
              for (String offeredSkill in userSkillsOffered) {
                if (offeredSkill.contains(mappedSkill)) {
                  print('DEBUG: MATCH FOUND! User ${userProfile.name} has "$offeredSkill" which contains "$mappedSkill"');
                  return true;
                }
              }
              for (String wantedSkill in userSkillsWanted) {
                if (wantedSkill.contains(mappedSkill)) {
                  print('DEBUG: MATCH FOUND! User ${userProfile.name} has "$wantedSkill" which contains "$mappedSkill"');
                  return true;
                }
              }
            }
            
            return false;
          }).toList();

          print('DEBUG: Filtering for skill: $skill');
          print('DEBUG: Found ${filteredUsers.length} users with matching skills');
          print('DEBUG: Matching users: ${filteredUsers.map((u) => '${u.name} (offers: ${u.skillsOffered.isNotEmpty ? u.skillsOffered.first : "none"}, wants: ${u.skillsWanted.isNotEmpty ? u.skillsWanted.first : "none"})').toList()}');
          
          // Rank users: Priority 1 = matching skills, Priority 2 = relevant skills by swap score
          final rankedUsers = filteredUsers.map((userProfile) {
            double score = 0.0;
            bool hasMatchingSkills = false;
            
            // Check if user has matching skills (same offered AND wanted)
            if (userProfile.skillsOffered.isNotEmpty && userProfile.skillsWanted.isNotEmpty) {
              final offeredSkill = userProfile.skillsOffered.first.toLowerCase();
              final wantedSkill = userProfile.skillsWanted.first.toLowerCase();
              
              // Check if any of the mapped skills match both offered and wanted
              for (String mappedSkill in mappedSkills) {
                if (offeredSkill.contains(mappedSkill) && wantedSkill.contains(mappedSkill)) {
                  hasMatchingSkills = true;
                  score += 10000.0; // Very high priority for matching skills
                  print('DEBUG: MATCHING SKILLS! ${userProfile.name} has "$offeredSkill" offered AND wanted');
                  break;
                }
              }
            }
            
            // Add swap score as secondary ranking
            score += userProfile.swapScore;
            
            print('DEBUG: User ${userProfile.name} - Score: $score, Matching: $hasMatchingSkills, SwapScore: ${userProfile.swapScore}');
            
            return {
              'userProfile': userProfile,
              'score': score,
              'hasMatchingSkills': hasMatchingSkills,
            };
          }).toList();
          
          // Sort by score (matching skills first, then by swap score)
          rankedUsers.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
          
          // Take top 2 matching skills users first, then add other relevant users
          final topMatchingUsers = rankedUsers.where((r) => r['hasMatchingSkills'] as bool).take(2).toList();
          final otherRelevantUsers = rankedUsers.where((r) => !(r['hasMatchingSkills'] as bool)).toList();
          
          final finalUsers = [...topMatchingUsers, ...otherRelevantUsers];
          
          print('DEBUG: Top matching users: ${topMatchingUsers.map((r) => '${(r['userProfile'] as UserProfile).name}').toList()}');
          print('DEBUG: Other relevant users: ${otherRelevantUsers.map((r) => '${(r['userProfile'] as UserProfile).name}').toList()}');
          
          // Convert to Swap objects for compatibility
          return finalUsers.map((rankedUser) {
            final userProfile = rankedUser['userProfile'] as UserProfile;
            
            // Use ALL skills instead of just the first one
            final skillOffered = userProfile.skillsOffered.isNotEmpty 
                ? userProfile.skillsOffered.join(', ') 
                : 'not specified';
            final skillWanted = userProfile.skillsWanted.isNotEmpty 
                ? userProfile.skillsWanted.join(', ') 
                : 'not specified';
            
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
  }

  // Get suggested swaps based on user preferences
  Stream<List<Swap>> getSuggestedSwaps() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .snapshots()
        .asyncMap((snapshot) async {
          try {
            // Get current user's skills
            final userDoc = await _firestore.collection('users').doc(user.uid).get();
            final userData = userDoc.data();
            
            // Check what fields actually exist in the user document
            print('DEBUG: User data keys: ${userData?.keys.toList()}');
            
            // Try different possible field names
            final userSkillsOffered = List<String>.from(userData?['skillsOffered'] ?? userData?['skillLibrary'] ?? userData?['skills'] ?? []);
            final userSkillsWanted = List<String>.from(userData?['skillsWanted'] ?? userData?['wantedSkills'] ?? []);
            
            print('DEBUG: User skills offered: $userSkillsOffered');
            print('DEBUG: User skills wanted: $userSkillsWanted');

            final allUsers = snapshot.docs
                .map((doc) => UserProfile.fromJson(doc.data(), doc.id))
                .where((userProfile) => userProfile.uid != user.uid) // Exclude current user
                .toList();
                
            print('DEBUG: Total users found: ${snapshot.docs.length}');
            print('DEBUG: Users (excluding current user): ${allUsers.length}');
            print('DEBUG: All users: ${allUsers.map((u) => u.name).toList()}');

            // Ranking based on matching skills and swap score
            final rankedUsers = allUsers.map((userProfile) {
              double score = 0.0;
              
              final userSkillOffered = userProfile.skillsOffered.isNotEmpty ? userProfile.skillsOffered.first : 'not specified';
              final userSkillWanted = userProfile.skillsWanted.isNotEmpty ? userProfile.skillsWanted.first : 'not specified';
              
              print('DEBUG: Checking user - ${userProfile.name} offers "$userSkillOffered" wants "$userSkillWanted"');
              
              // Check if user has matching skills (same skill offered and wanted)
              bool hasMatchingSkills = userSkillOffered.toLowerCase() == userSkillWanted.toLowerCase() && 
                                      userSkillOffered != 'not specified' && 
                                      userSkillWanted != 'not specified';
              
              if (hasMatchingSkills) {
                score += 1000.0; // Very high base score for matching skills
                print('DEBUG: MATCHING SKILLS! ${userProfile.name} has matching skills: $userSkillOffered');
              } else {
                score += 0.0; // No score for non-matching skills
                print('DEBUG: NO MATCHING SKILLS! ${userProfile.name} has different skills');
              }
              
              // Add swap score as secondary ranking
              score += userProfile.swapScore;
              
              print('DEBUG: Final score for ${userProfile.name}: $score (matching: $hasMatchingSkills, swapScore: ${userProfile.swapScore})');
              
              return {'user': userProfile, 'score': score, 'hasMatchingSkills': hasMatchingSkills};
            }).toList();

            // Sort by score (highest first) and take top 2
            rankedUsers.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
            
            // Convert to Swap objects for compatibility
            final suggestedSwaps = rankedUsers
                .take(2)
                .map((item) {
                  final userProfile = item['user'] as UserProfile;
                  
                  // Use ALL skills instead of just the first one
                  final skillOffered = userProfile.skillsOffered.isNotEmpty 
                      ? userProfile.skillsOffered.join(', ') 
                      : 'not specified';
                  final skillWanted = userProfile.skillsWanted.isNotEmpty 
                      ? userProfile.skillsWanted.join(', ') 
                      : 'not specified';
                  
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
                })
                .toList();
            
            return suggestedSwaps;
          } catch (e) {
            print('Error in suggested swaps: $e');
            return [];
          }
        });
  }

  // Create a new swap with optional image
  Future<void> createSwap({
    required String skillOffered,
    required String skillWanted,
    required String description,
    required String location,
    required List<String> tags,
    File? imageFile, // Optional image file
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data();
    final userName = userData?['name'] ?? 'Anonymous';
    final userAvatar = userData?['avatarUrl'] ?? 'assets/images/logo.png';

    // Upload image if provided
    String? imageUrl;
    if (imageFile != null) {
      try {
        imageUrl = await _imageUploadService.uploadSwapImage(imageFile);
      } catch (e) {
        print('Error uploading swap image: $e');
        // Continue without image if upload fails
      }
    }

    await _firestore.collection('swaps').add({
      'userId': user.uid,
      'userName': userName,
      'userAvatar': userAvatar,
      'skillOffered': skillOffered,
      'skillWanted': skillWanted,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
      'location': location,
      'tags': tags,
      'isActive': true,
      'views': 0,
      'requests': 0,
      'imageUrl': imageUrl, // Include image URL if available
    });
  }

  // Request a swap
  Future<void> requestSwap({
    required String receiverId,
    String? platform,
    DateTime? date,
    TimeOfDay? time,
    String? learn,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Fetch sender's name, avatar, and skills
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data();
    final senderName = userData?['name'] ?? 'Unknown';
    final senderAvatar = userData?['avatarUrl'];
    
    // Get sender's skills
    final skillsOffered = List<String>.from(userData?['skillsOffered'] ?? []);
    final skillsWanted = List<String>.from(userData?['skillsWanted'] ?? []);
    
    // Convert skills to readable format
    final skillsOfferedText = skillsOffered.isNotEmpty ? skillsOffered.join(', ') : 'various skills';
    final skillsWantedText = skillsWanted.isNotEmpty ? skillsWanted.join(', ') : 'various skills';

    print('Debug: receiverId = $receiverId');
    print('Debug: requesterId (current user) = ${user.uid}');
    print('Debug: sender skills offered = $skillsOfferedText');
    print('Debug: sender skills wanted = $skillsWantedText');

    await _firestore.collection('swapRequests').add({
      'receiverId': receiverId,
      'requesterId': user.uid,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'senderSkillsOffered': skillsOfferedText,
      'senderSkillsWanted': skillsWantedText,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      if (platform != null) 'platform': platform,
      if (date != null) 'date': Timestamp.fromDate(date),
      if (time != null) 'time': '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      if (learn != null) 'learn': learn,
    });
  }

  // Increment view count
  Future<void> incrementViews(String swapId) async {
    try {
      await _firestore.collection('swaps').doc(swapId).update({
        'views': FieldValue.increment(1),
      });
    } catch (e) {
      // If the document doesn't exist or update fails, just log it and continue
      print('DEBUG: Failed to increment views for swapId: $swapId - $e');
    }
  }

  // Get time ago from timestamp
  String getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  // Create sample swaps for testing
  Future<void> createSampleSwaps() async {
    final sampleSwaps = [
      {
        'userName': 'Tobi',
        'userAvatar': 'assets/images/onboarding_1.png',
        'skillOffered': 'cook',
        'skillWanted': 'designing flyers',
        'description': 'I am good at cooking and want to learn graphic design to create beautiful flyers for my events.',
        'location': 'Lagos, Nigeria',
        'tags': ['cooking', 'graphic design', 'events'],
        'imageUrl': 'assets/images/onboarding_1.png', // Add sample image
      },
      {
        'userName': 'Agnes',
        'userAvatar': 'assets/images/onboarding_2.png',
        'skillOffered': 'dance',
        'skillWanted': 'video editing',
        'description': 'I am good at dancing and want to learn video editing to create amazing dance videos.',
        'location': 'Nairobi, Kenya',
        'tags': ['dance', 'video editing', 'content creation'],
        'imageUrl': 'assets/images/onboarding_2.png', // Add sample image
      },
      {
        'userName': 'Tobi',
        'userAvatar': 'assets/images/onboarding_1.png',
        'skillOffered': 'cook',
        'skillWanted': 'designing flyers',
        'description': 'I am good at cooking and want to learn graphic design to create beautiful flyers for my events.',
        'location': 'Lagos, Nigeria',
        'tags': ['cooking', 'graphic design', 'events'],
        'imageUrl': 'assets/images/onboarding_3.png', // Add sample image
      },
      {
        'userName': 'Agnes',
        'userAvatar': 'assets/images/onboarding_2.png',
        'skillOffered': 'dance',
        'skillWanted': 'video editing',
        'description': 'I am good at dancing and want to learn video editing to create amazing dance videos.',
        'location': 'Nairobi, Kenya',
        'tags': ['dance', 'video editing', 'content creation'],
        'imageUrl': 'assets/images/onboarding_1.png', // Add sample image
      },
    ];

    for (final swapData in sampleSwaps) {
      await _firestore.collection('swaps').add({
        'userId': 'sample_user_${DateTime.now().millisecondsSinceEpoch}',
        'userName': swapData['userName'],
        'userAvatar': swapData['userAvatar'],
        'skillOffered': swapData['skillOffered'],
        'skillWanted': swapData['skillWanted'],
        'description': swapData['description'],
        'createdAt': FieldValue.serverTimestamp(),
        'location': swapData['location'],
        'tags': swapData['tags'],
        'isActive': true,
        'views': 0,
        'requests': 0,
        'imageUrl': swapData['imageUrl'], // Include image URL
      });
    }
  }
} 