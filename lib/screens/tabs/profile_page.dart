import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/screens/subscription_page.dart';
import 'package:my_app/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<DocumentSnapshot> _getUserData() {
    final user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
  }

  Future<void> _launchSupportChat() async {
    final Uri url = Uri.parse('https://t.me/m/FIrEmovvOTU0'); // !! استبدل بالرابط الصحيح !!
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا يمكن فتح الرابط')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final AuthService authService = AuthService();

    // --- 1. تم تعديل هيكل الواجهة هنا لإصلاح الشريط الأبيض ---
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF0A4F46), Colors.black], begin: Alignment.topCenter, end: Alignment.bottomCenter),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // جعل Scaffold شفافًا
        appBar: AppBar(
          title: const Text('الملف الشخصي', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: FutureBuilder<DocumentSnapshot>(
            future: _getUserData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(child: Text('لا يمكن تحميل بيانات المستخدم', style: TextStyle(color: Colors.white)));
              }
              
              final userData = snapshot.data!.data() as Map<String, dynamic>;
              final bool isVip = userData['isVip'] ?? false;

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                      child: user?.photoURL == null ? const Icon(Icons.person, size: 50) : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userData['displayName'] ?? 'لا يوجد اسم',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 24),

                    _buildGlassCard(
                      child: Column(
                        children: [
                          if (isVip) _buildVipBanner(),
                          _buildInfoRow(icon: Icons.email_outlined, label: 'البريد الإلكتروني', value: userData['email'] ?? 'N/A'),
                          _buildInfoRow(icon: Icons.flag_outlined, label: 'الدولة', value: userData['country'] ?? 'غير محددة'),
                          _buildInfoRow(icon: Icons.computer_outlined, label: 'المنصة', value: userData['platform'] ?? 'غير محددة'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                     _buildGlassCard(
                      child: Column(
                        children: [
                           _buildActionButton(
                            icon: Icons.star_purple500_outlined,
                            text: 'إدارة الاشتراك',
                            onTap: () {
                               Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SubscriptionPage()));
                            }
                          ),
                          const Divider(color: Colors.white12),
                          _buildActionButton(
                            icon: Icons.support_agent,
                            text: 'التواصل مع الدعم',
                            onTap: _launchSupportChat
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    ElevatedButton(
                      onPressed: () => authService.signOut(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent.withOpacity(0.8),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('تسجيل الخروج', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                     const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
  
  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildVipBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16, top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.yellow[700]?.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.yellow[700]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star, color: Colors.yellow[700], size: 20),
          const SizedBox(width: 8),
          Text(
            'عضوية VIP نشطة',
            style: TextStyle(color: Colors.yellow[700], fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
  
  // --- 2. تم تعديل هذه الويدجت لإصلاح مشكلة تداخل النصوص ---
  Widget _buildInfoRow({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 16),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(width: 8), // مسافة صغيرة
          // استخدام Flexible للسماح للنص الطويل بالالتفاف
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String text, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
      onTap: onTap,
    );
  }
}