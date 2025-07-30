import 'package:flutter/material.dart';
import 'settings_page.dart';
import '../../../messages/presentation/pages/message_list_page.dart';
import '../../../forum/presentation/pages/forum_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import 'all_swaps_page.dart';
import 'suggested_swaps_page.dart';
import '../../../../core/widgets/theme_switch.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic>? arguments;
  
  const HomePage({super.key, this.arguments});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  int _homeTabIndex = 0;
  bool _isHeaderVisible = true;
  double _lastScrollPosition = 0;
  
  @override
  void initState() {
    super.initState();
    // Set selected tab if provided in arguments
    if (widget.arguments != null && widget.arguments!['selectedTab'] != null) {
      _selectedIndex = widget.arguments!['selectedTab'];
      print('DEBUG: Home page - Setting selected tab to: $_selectedIndex');
    }
    // Set home tab index if provided in arguments
    if (widget.arguments != null && widget.arguments!['homeTabIndex'] != null) {
      _homeTabIndex = widget.arguments!['homeTabIndex'];
      print('DEBUG: Home page - Setting home tab index to: $_homeTabIndex');
    }
    if (widget.arguments != null && widget.arguments!['filterSkill'] != null) {
      print('DEBUG: Home page - Filter skill: ${widget.arguments!['filterSkill']}');
    } else {
      print('DEBUG: Home page - No filter skill provided or arguments is null');
      print('DEBUG: Home page - Arguments: ${widget.arguments}');
    }
  }

  void _onScroll(double position) {
    // Add a small threshold to prevent jittery behavior
    const scrollThreshold = 10.0;
    
    // Show header when scrolling up, hide when scrolling down
    if (position > _lastScrollPosition + scrollThreshold && _isHeaderVisible) {
      // Scrolling down - hide header
      setState(() {
        _isHeaderVisible = false;
      });
    } else if (position < _lastScrollPosition - scrollThreshold && !_isHeaderVisible) {
      // Scrolling up - show header
      setState(() {
        _isHeaderVisible = true;
      });
    }
    
    _lastScrollPosition = position;
  }

  List<Widget> _pagesBuilder(Function(int) onTabChange) => [
    Column(
      children: [
        const SizedBox(height: 24),
        Expanded(child: Builder(
          builder: (context) {
            print('DEBUG: Home page - Passing filterSkill to HomeTabs: ${widget.arguments?['filterSkill']}');
            return HomeTabs(
              filterSkill: widget.arguments?['filterSkill'],
              initialTabIndex: _homeTabIndex,
              onScroll: _onScroll,
            );
          },
        )),
      ],
    ),
    MessageListPage(),
    ProfilePage(onBackToHome: () => onTabChange(0)),
    SettingsPage(onBackToHome: () => onTabChange(0)),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = _pagesBuilder((i) => setState(() => _selectedIndex = i));
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final padding = mediaQuery.padding;
    
    // Calculate responsive values with more precise system UI consideration
    final headerHeight = isLandscape ? 50.0 : 70.0; // Further reduced for landscape
    final bottomNavHeight = isLandscape ? 50.0 : 70.0; // Further reduced for landscape
    final extraPadding = isLandscape ? 2.0 : 4.0; // Extra padding to prevent overflow
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        top: true,
        bottom: false, // Handle bottom padding manually
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Collapsible header area with theme switch and spacing
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: _isHeaderVisible ? headerHeight : 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _isHeaderVisible ? 1.0 : 0.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ThemeSwitch(),
                    SizedBox(height: isLandscape ? 4 : 8), // Reduced spacing
                    if (_selectedIndex != 1 && _selectedIndex != 3)
                      SizedBox(height: isLandscape ? 8 : 16), // Reduced spacing
                  ],
                ),
              ),
            ),
            // Main content area with precise overflow handling
            Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  bottom: bottomNavHeight + padding.bottom + extraPadding
                ),
                child: pages[_selectedIndex],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: null,
      bottomNavigationBar: Container(
        height: bottomNavHeight + padding.bottom + extraPadding,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark 
              ? const Color(0xFF1E1E1E)
              : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF000000)
                  : const Color(0x11000000),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: padding.bottom),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: _selectedIndex,
            onTap: (i) => setState(() => _selectedIndex = i),
            selectedItemColor: Theme.of(context).brightness == Brightness.dark 
                ? const Color(0xFF3E8E7E)
                : const Color(0xFF225B4B),
            unselectedItemColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.white70
                : Colors.black,
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                activeIcon: Icon(Icons.chat_bubble),
                label: 'Messages',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeTabs extends StatefulWidget {
  final String? filterSkill;
  final int initialTabIndex;
  final Function(double) onScroll;
  
  const HomeTabs({super.key, this.filterSkill, this.initialTabIndex = 0, required this.onScroll});

  @override
  State<HomeTabs> createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _currentFilterSkill;
  bool _isTabBarVisible = true;
  double _lastScrollPosition = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _currentFilterSkill = widget.filterSkill;
    
    // Add listener to clear filter when manually switching to "All" tab
    _tabController.addListener(() {
      if (_tabController.index == 1 && _tabController.indexIsChanging) {
        // User manually switched to "All" tab, clear the filter
        setState(() {
          _currentFilterSkill = null;
        });
        print('DEBUG: HomeTabs - Manually switched to All tab, clearing filter');
      }
    });
    
    print('DEBUG: HomeTabs - Setting initial tab index to: ${widget.initialTabIndex}');
    print('DEBUG: HomeTabs - Filter skill: $_currentFilterSkill');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onScroll(double position) {
    // Add a small threshold to prevent jittery behavior
    const scrollThreshold = 10.0;
    
    // Show tab bar when scrolling up, hide when scrolling down
    if (position > _lastScrollPosition + scrollThreshold && _isTabBarVisible) {
      // Scrolling down - hide tab bar
      setState(() {
        _isTabBarVisible = false;
      });
    } else if (position < _lastScrollPosition - scrollThreshold && !_isTabBarVisible) {
      // Scrolling up - show tab bar
      setState(() {
        _isTabBarVisible = true;
      });
    }
    
    _lastScrollPosition = position;
    
    // Call the parent scroll callback for header collapse functionality
    widget.onScroll(position);
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions and orientation
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    
    // Calculate responsive values
    final tabBarHeight = isLandscape ? 50.0 : 60.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Collapsible tab bar with animation
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: _isTabBarVisible ? tabBarHeight : 0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _isTabBarVisible ? 1.0 : 0.0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.grey[800]
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFF617D8A),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  fontSize: 14,
                ),
                indicator: BoxDecoration(
                  color: const Color(0xFF225B4B),
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                onTap: (index) {
                  // Handle manual tab clicks
                  if (index == 1) { // All tab
                    if (_currentFilterSkill != null) {
                      // If there's a filter active, clear it
                      setState(() {
                        _currentFilterSkill = null;
                      });
                      print('DEBUG: HomeTabs - Manually clicked All tab, clearing filter');
                    }
                  }
                },
                tabs: const [
                  Tab(text: 'Suggested'),
                  Tab(text: 'All'),
                  Tab(text: 'Forum'),
                ],
              ),
            ),
          ),
        ),
        
        // Responsive spacing (only when tab bar is visible)
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _isTabBarVisible ? (isLandscape ? 6 : 8) : 0,
        ),
        
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              SuggestedSwapsPageWithScrollCallback(onScroll: _onScroll),
              AllSwapsPageWithScrollCallback(
                filterSkill: _currentFilterSkill,
                onScroll: _onScroll,
              ),
              // Pass scroll callback to ForumPage
              ForumPageWithScrollCallback(onScroll: _onScroll),
            ],
          ),
        ),
      ],
    );
  }
}

// Wrapper widget to pass scroll callback to ForumPage
class ForumPageWithScrollCallback extends StatefulWidget {
  final Function(double) onScroll;
  
  const ForumPageWithScrollCallback({super.key, required this.onScroll});

  @override
  State<ForumPageWithScrollCallback> createState() => _ForumPageWithScrollCallbackState();
}

class _ForumPageWithScrollCallbackState extends State<ForumPageWithScrollCallback> {
  @override
  Widget build(BuildContext context) {
    return ForumPage(onScrollCallback: widget.onScroll);
  }
}

// Wrapper widget to pass scroll callback to SuggestedSwapsPage
class SuggestedSwapsPageWithScrollCallback extends StatefulWidget {
  final Function(double) onScroll;
  
  const SuggestedSwapsPageWithScrollCallback({super.key, required this.onScroll});

  @override
  State<SuggestedSwapsPageWithScrollCallback> createState() => _SuggestedSwapsPageWithScrollCallbackState();
}

class _SuggestedSwapsPageWithScrollCallbackState extends State<SuggestedSwapsPageWithScrollCallback> {
  @override
  Widget build(BuildContext context) {
    return SuggestedSwapsPage(onScrollCallback: widget.onScroll);
  }
}

// Wrapper widget to pass scroll callback to AllSwapsPage
class AllSwapsPageWithScrollCallback extends StatefulWidget {
  final String? filterSkill;
  final Function(double) onScroll;
  
  const AllSwapsPageWithScrollCallback({
    super.key, 
    this.filterSkill, 
    required this.onScroll,
  });

  @override
  State<AllSwapsPageWithScrollCallback> createState() => _AllSwapsPageWithScrollCallbackState();
}

class _AllSwapsPageWithScrollCallbackState extends State<AllSwapsPageWithScrollCallback> {
  @override
  Widget build(BuildContext context) {
    return AllSwapsPage(
      filterSkill: widget.filterSkill,
      onScrollCallback: widget.onScroll,
    );
  }
}
