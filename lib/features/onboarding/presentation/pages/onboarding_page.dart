import 'package:flutter/material.dart';
import '../../../../core/widgets/theme_switch.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      title: 'Learn and Teach, Together',
      description: 'Swap your skills with others and unlock the power of peer learning.',
      imageAsset: 'assets/images/onboarding_2.png',
    ),
    _OnboardingPageData(
      title: 'Find Skills You Want to Learn',
      description: 'From coding to calligraphy — choose what excites you.',
      imageAsset: 'assets/images/onboarding_3.png',
    ),
    _OnboardingPageData(
      title: 'Swap. Learn. Level Up.',
      description: 'Teach your skills in return, make connections, and grow together.',
      imageAsset: 'assets/images/onboarding_1.png',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _goToAuth();
    }
  }

  void _skip() {
    _goToAuth();
  }

  void _goToAuth() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Image.asset('assets/images/logo.png', height: 200),
                const SizedBox(height: 4),
                // const Text(
                //   'Learn. Teach. Thrive.',
                //   style: TextStyle(
                //     fontSize: 15,
                //     color: Color(0xFF225B4B),
                //     fontWeight: FontWeight.w500,
                //   ),
                // ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      return Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(page.imageAsset, height: 200),
                            const SizedBox(height: 32),
                            Text(
                              page.title,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF225B4B),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              page.description,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // Dot indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => _buildDot(index),
                  ),
                ),
                const SizedBox(height: 24),
                // Navigation buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      if (_currentPage != _pages.length - 1)
                        Row(
                          children: [
                            TextButton(
                              onPressed: _skip,
                              child: const Text('Skip', style: TextStyle(color: Colors.grey)),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: _nextPage,
                              child: const Icon(Icons.arrow_forward, color: Colors.white),
                            ),
                          ],
                        ),
                      if (_currentPage == _pages.length - 1)
                        ElevatedButton(
                          onPressed: _goToAuth,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF225B4B),
                            padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                          ),
                          child: const Text('Get started',
                            style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    // Figma: orange for active, blue for inactive
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 18 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? const Color(0xFFFF8A00) : const Color(0xFF1DA1F2),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _OnboardingPageData {
  final String title;
  final String description;
  final String imageAsset;
  const _OnboardingPageData({required this.title, required this.description, required this.imageAsset});
} 