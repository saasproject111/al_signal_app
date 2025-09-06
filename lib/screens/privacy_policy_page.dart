import 'dart:ui';
import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'سياسة الخصوصية',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF1E1E1E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGlassCard(
                  context,
                  icon: Icons.lock_outline,
                  title: '1. البيانات التي نجمعها',
                  text:
                      'عند تسجيلك باستخدام حساب Google، نقوم بجمع البيانات الأساسية التي توافق على مشاركتها، مثل: الاسم، البريد الإلكتروني، وصورة الملف الشخصي. كما نقوم بتخزين الإعدادات التي تختارها داخل التطبيق (مثل الدولة والمنصة) لتحسين تجربتك.',
                ),
                _buildGlassCard(
                  context,
                  icon: Icons.privacy_tip_outlined,
                  title: '2. كيف نستخدم بياناتك',
                  text:
                      'نستخدم بياناتك لتخصيص تجربتك داخل التطبيق، مثل عرض اسمك، وإدارة حالة اشتراكك (مجاني/VIP)، وحفظ إعداداتك. لا نشارك بياناتك الشخصية مع أي طرف ثالث لأغراض تسويقية.',
                ),
                _buildGlassCard(
                  context,
                  icon: Icons.security_outlined,
                  title: '3. أمان البيانات',
                  text:
                      'نحن نستخدم خدمات Firebase الآمنة من Google لتخزين بياناتك وحمايتها. نتخذ جميع الإجراءات المعقولة لحماية معلوماتك من الوصول غير المصرح به.',
                ),
                _buildGlassCard(
                  context,
                  icon: Icons.account_circle_outlined,
                  title: '4. حقوقك',
                  text:
                      'لديك الحق في الوصول إلى بياناتك وتحديثها. يمكنك تعديل اسمك ودولتك ومنصتك من صفحة الإعدادات. لحذف حسابك وبياناتك بالكامل، يرجى التواصل مع فريق الدعم.',
                ),
                _buildGlassCard(
                  context,
                  icon: Icons.update,
                  title: '5. التغييرات على هذه السياسة',
                  text:
                      'قد نقوم بتحديث سياسة الخصوصية هذه من وقت لآخر. سنقوم بإخطارك بأي تغييرات عن طريق نشر السياسة الجديدة في هذه الصفحة.',
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amberAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text(
                      'العودة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildGlassCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.08),
                  Colors.white.withOpacity(0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: Colors.amberAccent, size: 26),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
