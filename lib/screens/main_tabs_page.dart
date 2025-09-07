import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:my_app/widgets/animated_background.dart';
import 'package:my_app/screens/tabs/premium_home_page.dart';
import 'package:my_app/screens/tabs/enhanced_learning_page.dart';
import 'package:my_app/screens/tabs/profile_page.dart';
import 'package:my_app/screens/tabs/recommendations_page.dart';
import 'package:my_app/screens/tabs/settings_page.dart';

class MainTabsPage extends StatefulWidget {
  const MainTabsPage({super.key});

  @override
  State<MainTabsPage> createState() => _MainTabsPageState();
}

class _MainTabsPageState extends State<MainTabsPage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = const [
    PremiumHomePage(),
    EnhancedLearningPage(),
    RecommendationsPage(),
    SettingsPage(),
    ProfilePage(),
  ];

  final List<Color> _tabColors = [
    Colors.lightBlue,
    Colors.green,
    Colors.amber,
    Colors.redAccent,
    Colors.white,
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: PageView(
          controller: _pageController,
          children: _pages,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8.0), // علشان الشريط يطفو فوق الخلفية
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30), // دائري بالكامل
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                color: Colors.black.withOpacity(0.25), // الخلفية الفعلية للشريط فقط
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: GNav(
                    backgroundColor: Colors.transparent,
                    color: Colors.white70,
                    activeColor: _tabColors[_selectedIndex],
                    tabBackgroundColor: _tabColors[_selectedIndex].withOpacity(0.25),
                    gap: 8,
                    padding: const EdgeInsets.all(12),
                    selectedIndex: _selectedIndex,
                    onTabChange: (index) {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    tabs: const [
                      GButton(icon: Icons.dashboard_rounded, text: 'الرئيسية'),
                      GButton(icon: Icons.menu_book_rounded, text: 'التعلّم'),
                      GButton(icon: Icons.bar_chart_rounded, text: 'توصيات'),
                      GButton(icon: Icons.settings_rounded, text: 'الإعدادات'),
                      GButton(icon: Icons.account_circle_rounded, text: 'حسابي'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
