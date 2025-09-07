import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:my_app/screens/tabs/premium_home_page.dart';
import 'package:my_app/screens/tabs/enhanced_learning_page.dart'; // ✅ تعديل هنا
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

  final List<Widget> _pages = <Widget>[
    const PremiumHomePage(),
    const EnhancedLearningPage(), // ✅ استدعاء الكلاس الجديد
    const RecommendationsPage(),
    const SettingsPage(),
    const ProfilePage(),
  ];

  // ألوان التبويبات
  final List<Color> _tabColors = [
    Colors.lightBlue,    // الرئيسية
    Colors.green,        // التعلّم
    Colors.amber,        // التوصيات
    Colors.redAccent,    // الإعدادات
    Colors.white,        // حسابي
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
    );
  }
}
