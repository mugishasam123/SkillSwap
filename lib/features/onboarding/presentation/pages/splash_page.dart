import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Green corner background
          Positioned(
            top: 0,
            right: 0,
            child: Image.asset(
              'assets/images/splash_corner.png',
              width: 140,
              height: 140,
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                // Large SkillSwap logo
                Image.asset('assets/images/logo.png', height: 350, width: 500),
                // const SizedBox(height: 8),
                // const Text(
                //   'Learn. Teach. Thrive',
                //   style: TextStyle(
                //     fontSize: 16,
                //     color: Color(0xFF225B4B),
                //     fontWeight: FontWeight.w500,
                //   ),
                // ),
                const SizedBox(height: 40),
                const Text(
                  'Welcome to SkillSwap',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF222222),
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(flex: 3),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF225B4B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 6,
                        shadowColor: Colors.black.withOpacity(0.12),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/onboarding');
                      },
                      child: const Text(
                        'Get started',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 