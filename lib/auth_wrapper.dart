import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// تعديل هنا
import 'package:my_app/screens/main_tabs_page.dart';
import 'package:my_app/screens/login_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // تعديل هنا
          return const MainTabsPage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}