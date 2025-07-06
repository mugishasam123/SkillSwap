import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      title: 'Find Skills You Want to Learn',
      description: 'From coding to cooking – choose what excites you.',
      imageAsset: 'assets/onboarding1.png', // Placeholder
    ),
    _OnboardingPageData(
      title: 'Swap. Learn. Level Up.',
      description: 'Teach your skills, learn new ones, and grow connections.',
      imageAsset: 'assets/onboarding2.png', // Placeholder
    ),
    _OnboardingPageData(
      title: 'Welcome to SkillSwap',
      description: 'Learn. Teach. Thrive.',
      imageAsset: 'assets/onboarding3.png', // Placeholder
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
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
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
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Placeholder for image
                        Container(
                          height: 220,
                          width: 220,
                          color: Colors.grey[200],
                          child: Center(child: Text('Image')), // Replace with Image.asset(page.imageAsset)
                        ),
                        const SizedBox(height: 32),
                        Text(
                          page.title,
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.description,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) => _buildDot(index)),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _skip,
                    child: const Text('Skip'),
                  ),
                  ElevatedButton(
                    onPressed: _nextPage,
                    child: Text(_currentPage == _pages.length - 1 ? 'Get started' : 'Next'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.deepPurple : Colors.grey[400],
        shape: BoxShape.circle,
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