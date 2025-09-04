import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/services/auth_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final AuthService authService = AuthService();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('الملف الشخصي', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        // --- إضافة التدرج اللوني هنا ---
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A4F46), Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  child: user?.photoURL == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
                const SizedBox(height: 20),
                Text(
                  user?.displayName ?? 'لا يوجد اسم',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white), // تعديل اللون
                ),
                const SizedBox(height: 8),
                Text(
                  user?.email ?? 'لا يوجد بريد إلكتروني',
                  style: const TextStyle(
                      fontSize: 16, color: Colors.white70), // تعديل اللون
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    authService.signOut();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: const Text('تسجيل الخروج', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}