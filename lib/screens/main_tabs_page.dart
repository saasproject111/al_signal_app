import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:my_app/screens/tabs/home_page.dart';
import 'package:my_app/screens/tabs/learning_page.dart';
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

  // قائمة الصفحات التي سيتم عرضها
  final List<Widget> _pages = <Widget>[
    const HomePage(),
    const LearningPage(), // تم إرجاعها لـ const مؤقتًا
    const RecommendationsPage(),
    const SettingsPage(),
    const ProfilePage(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: _pages,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      bottomNavigationBar: Container(
        color: Colors.blueGrey[900],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
          child: GNav(
            backgroundColor: Colors.blueGrey[900]!,
            color: Colors.white70,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.grey.withOpacity(0.2),
            gap: 8,
            padding: const EdgeInsets.all(12),
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            },
            tabs: const [
              GButton(icon: Icons.home, text: 'الرئيسية'),
              GButton(icon: Icons.school, text: 'التعلّم'),
              GButton(icon: Icons.star, text: 'توصيات'),
              GButton(icon: Icons.settings, text: 'الإعدادات'),
              GButton(icon: Icons.person, text: 'ملفي'),
            ],
          ),
        ),
      ),
    );
  }
}