import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/screens/login_page.dart';
import 'package:my_app/screens/main_tabs_page.dart'; // السطر المفقود

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData) {
          // MainTabsPage لم تعد const لأنها تحتوي على صفحات ديناميكية
          return const MainTabsPage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
