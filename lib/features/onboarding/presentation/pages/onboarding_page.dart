import 'package:flutter/material.dart';

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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
            child: Column(
              children: [
                const SizedBox(height: 32),
                Image.asset('assets/images/logo.png', height: 250),
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
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            Image.asset(
                              page.imageAsset,
                              height: 260,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 32),
                            Text(
                              page.title,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              page.description,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF444444),
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 0, bottom: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (index) => GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: _buildDot(index),
                    )),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _skip,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey,
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: const Text('Skip'),
                      ),
                      ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF225B4B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                        ),
                        child: Text(_currentPage == _pages.length - 1 ? 'Get started' : 'Next',
                          style: const TextStyle(fontSize: 18, color: Colors.white)),
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