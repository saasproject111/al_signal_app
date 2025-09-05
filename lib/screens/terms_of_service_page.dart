import 'package:flutter/material.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('شروط الخدمة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            // --- تم حذف const من هنا ---
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('1. قبول الشروط'),
                _buildParagraph(
                  'باستخدامك لتطبيق SignalX ("التطبيق")، فإنك توافق على الالتزام بهذه الشروط والأحكام. إذا كنت لا توافق على أي جزء من الشروط، فلا يجوز لك استخدام التطبيق.'
                ),
                _buildSectionTitle('2. إخلاء المسؤولية المالية'),
                _buildParagraph(
                  'المعلومات والتوصيات المقدمة في هذا التطبيق هي لأغراض تعليمية وإعلامية فقط ولا تشكل نصيحة مالية أو استثمارية. التداول في الأسواق المالية ينطوي على مخاطر عالية وقد لا يكون مناسبًا لجميع المستثمرين. أنت وحدك المسؤول عن قراراتك الاستثمارية.'
                ),
                _buildSectionTitle('3. الاشتراكات والخدمات المدفوعة (VIP)'),
                _buildParagraph(
                  'بعض ميزات التطبيق تتطلب اشتراكًا مدفوعًا. يتم تجديد الاشتراكات تلقائيًا ما لم يتم إلغاؤها. يمكنك إدارة اشتراكك وإلغاء التجديد التلقائي من إعدادات حسابك في متجر التطبيقات.'
                ),
                _buildSectionTitle('4. الملكية الفكرية'),
                _buildParagraph(
                  'كل المحتوى الموجود في التطبيق، بما في ذلك النصوص والرسومات والشعارات والاستراتيجيات، هو ملك لـ SignalX ومحمي بموجب قوانين حقوق النشر.'
                ),
                _buildSectionTitle('5. تعديل الشروط'),
                _buildParagraph(
                  'نحتفظ بالحق في تعديل هذه الشروط في أي وقت. سيتم نشر أي تغييرات على هذه الصفحة، ويعتبر استمرارك في استخدام التطبيق بعد هذه التغييرات موافقة منك على الشروط الجديدة.'
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
        height: 1.5, // لتباعد الأسطر
      ),
    );
  }
}

