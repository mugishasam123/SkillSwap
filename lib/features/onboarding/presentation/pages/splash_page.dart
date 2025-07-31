import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate responsive sizes based on screen dimensions
          final screenHeight = constraints.maxHeight;
          final screenWidth = constraints.maxWidth;
          final isLandscape = screenWidth > screenHeight;
          
          // Responsive logo size
          final logoHeight = isLandscape 
              ? screenHeight * 0.4  // 40% of screen height in landscape
              : screenHeight * 0.35; // 35% of screen height in portrait
          final logoWidth = logoHeight * (500 / 350); // Maintain aspect ratio
          
          return Stack(
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
              SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Top spacer - smaller in landscape
                      SizedBox(height: isLandscape ? screenHeight * 0.05 : screenHeight * 0.1),
                      
                      // Large SkillSwap logo
                      Image.asset(
                        'assets/images/logo.png', 
                        height: logoHeight, 
                        width: logoWidth,
                        fit: BoxFit.contain,
                      ),
                      
                      SizedBox(height: isLandscape ? 20 : 40),
                      
                      // Welcome text
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                          'Welcome to SkillSwap',
                          style: TextStyle(
                            fontSize: isLandscape ? 20 : 24,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF222222),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      // Flexible spacer that adapts to available space
                      Flexible(
                        child: SizedBox(
                          height: isLandscape ? screenHeight * 0.1 : screenHeight * 0.15,
                        ),
                      ),
                      
                      // Bottom section with button
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
                              padding: EdgeInsets.symmetric(
                                vertical: isLandscape ? 14 : 18,
                              ),
                            ),
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/onboarding');
                            },
                            child: Text(
                              'Get started',
                              style: TextStyle(
                                fontSize: isLandscape ? 16 : 18, 
                                fontWeight: FontWeight.w500, 
                                color: Colors.white
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Bottom padding - smaller in landscape
                      SizedBox(height: isLandscape ? 24 : 48),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 