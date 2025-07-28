import 'package:flutter/material.dart';
import '../../../../core/widgets/theme_switch.dart';

class AboutPage extends StatelessWidget {
  final VoidCallback? onBackToSettings;
  
  const AboutPage({super.key, this.onBackToSettings});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, size: 28),
                      onPressed: () {
                        if (onBackToSettings != null) {
                          onBackToSettings!();
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'About',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    shadows: [
                      Shadow(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black54
                            : Colors.black26,
                        offset: const Offset(0, 4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // App Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'SkillSwap',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF3E8E7E)
                        : const Color(0xFF225B4B),
                  ),
                ),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black54,
                  ),
                ),
                const SizedBox(height: 32),
                // About Content Cards
                _AboutCard(
                  icon: Icons.people,
                  title: 'What is SkillSwap?',
                  content: 'SkillSwap is a platform that connects people who want to learn new skills with those who can teach them. Exchange your expertise for knowledge in areas you want to explore.',
                ),
                _AboutCard(
                  icon: Icons.handshake,
                  title: 'How it Works',
                  content: 'Browse available skills, connect with mentors, and arrange skill exchanges. Build your network while expanding your knowledge base through mutual learning.',
                ),
                _AboutCard(
                  icon: Icons.star,
                  title: 'Our Mission',
                  content: 'To create a community where knowledge sharing is accessible, meaningful, and mutually beneficial. We believe everyone has something valuable to teach and learn.',
                ),
                _AboutCard(
                  icon: Icons.security,
                  title: 'Privacy & Security',
                  content: 'Your data is protected with industry-standard security measures. We respect your privacy and ensure all interactions are secure and confidential.',
                ),
                const SizedBox(height: 24),
                // Contact Information
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF1E1E1E)
                        : const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade700
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Contact Us',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF3E8E7E)
                              : const Color(0xFF225B4B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Have questions or feedback?',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'support@skillswap.com',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF3E8E7E)
                              : const Color(0xFF225B4B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Copyright
                Text(
                  '© 2025 SkillSwap. All rights reserved.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white38
                        : Colors.black38,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _AboutCard({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E1E1E)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        shadowColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black26
            : Colors.black12,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 28,
                    color: const Color(0xFF225B4B),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child:                     Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF3E8E7E)
                            : const Color(0xFF225B4B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                content,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.87)
                      : Colors.black87,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 