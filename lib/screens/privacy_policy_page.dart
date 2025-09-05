import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('سياسة الخصوصية', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            colors: [Color(0xFF0A4F46), Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        // --- تم حذف const من هنا ---
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('1. البيانات التي نجمعها'),
                _buildParagraph(
                  'عند تسجيلك باستخدام حساب Google، نقوم بجمع البيانات الأساسية التي توافق على مشاركتها، مثل: الاسم، البريد الإلكتروني، وصورة الملف الشخصي. كما نقوم بتخزين الإعدادات التي تختارها داخل التطبيق (مثل الدولة والمنصة) لتحسين تجربتك.'
                ),
                _buildSectionTitle('2. كيف نستخدم بياناتك'),
                _buildParagraph(
                  'نستخدم بياناتك لتخصيص تجربتك داخل التطبيق، مثل عرض اسمك، وإدارة حالة اشتراكك (مجاني/VIP)، وحفظ إعداداتك. لا نشارك بياناتك الشخصية مع أي طرف ثالث لأغراض تسويقية.'
                ),
                 _buildSectionTitle('3. أمان البيانات'),
                _buildParagraph(
                  'نحن نستخدم خدمات Firebase الآمنة من Google لتخزين بياناتك وحمايتها. نتخذ جميع الإجراءات المعقولة لحماية معلوماتك من الوصول غير المصرح به.'
                ),
                _buildSectionTitle('4. حقوقك'),
                _buildParagraph(
                  'لديك الحق في الوصول إلى بياناتك وتحديثها. يمكنك تعديل اسمك ودولتك ومنصتك من صفحة الإعدادات. لحذف حسابك وبياناتك بالكامل، يرجى التواصل مع فريق الدعم.'
                ),
                 _buildSectionTitle('5. التغييرات على هذه السياسة'),
                _buildParagraph(
                  'قد نقوم بتحديث سياسة الخصوصية هذه من وقت لآخر. سنقوم بإخطارك بأي تغييرات عن طريق نشر السياسة الجديدة في هذه الصفحة.'
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // هذه الدوال ثابتة، لذلك يمكن أن تبقى static
  static Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.tealAccent,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static Widget _buildParagraph(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 16,
        height: 1.5,
      ),
    );
  }
}

