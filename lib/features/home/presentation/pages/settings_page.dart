import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatelessWidget {
  final VoidCallback? onBackToHome;
  const SettingsPage({Key? key, this.onBackToHome}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                        if (onBackToHome != null) {
                          onBackToHome!();
                        } else {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        }
                      },
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(0, 4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const CircleAvatar(
                  radius: 48,
                  backgroundImage: AssetImage('assets/images/onboarding_1.png'), // Placeholder
                ),
                const SizedBox(height: 12),
                const Text(
                  'Charlotte King',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF225B4B),
                  ),
                ),
                const Text(
                  '@johnkinggraphics',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),
                _SettingsCard(
                  icon: Icons.tune,
                  title: 'General',
                  subtitle: 'Language and input settings',
                  onTap: () {},
                ),
                _SettingsCard(
                  icon: Icons.shield_outlined,
                  title: 'Privacy',
                  subtitle: 'Language and input settings',
                  onTap: () {},
                ),
                _SettingsCard(
                  icon: Icons.notifications_none,
                  title: 'Notifications',
                  subtitle: 'Language and input settings',
                  onTap: () {},
                ),
                _SettingsCard(
                  icon: Icons.settings_outlined,
                  title: 'App Settings',
                  subtitle: 'App permissions',
                  onTap: () {},
                ),
                _SettingsCard(
                  icon: Icons.info_outline,
                  title: 'About',
                  subtitle: 'Know about the app',
                  onTap: () {},
                ),
                _SettingsCard(
                  icon: Icons.logout,
                  title: 'Log out',
                  subtitle: 'Log out from the app',
                  onTap: () => _logout(context),
                  iconColor: Colors.red,
                  textColor: Colors.red,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        shadowColor: Colors.black12,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(icon, size: 28, color: iconColor ?? const Color(0xFF225B4B)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor ?? const Color(0xFF225B4B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.black38),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 