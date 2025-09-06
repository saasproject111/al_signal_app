import 'dart:ui';
import 'package:flutter/material.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'شروط الخدمة',
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
                  icon: Icons.verified_user,
                  title: '1. قبول الشروط',
                  text:
                      'باستخدامك لتطبيق SignalX ("التطبيق")، فإنك توافق على الالتزام بهذه الشروط والأحكام. إذا كنت لا توافق على أي جزء من الشروط، فلا يجوز لك استخدام التطبيق.',
                ),
                _buildGlassCard(
                  context,
                  icon: Icons.money_off_csred,
                  title: '2. إخلاء المسؤولية المالية',
                  text:
                      'المعلومات والتوصيات المقدمة في هذا التطبيق هي لأغراض تعليمية وإعلامية فقط ولا تشكل نصيحة مالية أو استثمارية. التداول في الأسواق المالية ينطوي على مخاطر عالية وقد لا يكون مناسبًا لجميع المستثمرين.',
                ),
                _buildGlassCard(
                  context,
                  icon: Icons.workspace_premium,
                  title: '3. الاشتراكات والخدمات المدفوعة (VIP)',
                  text:
                      'بعض ميزات التطبيق تتطلب اشتراكًا مدفوعًا. يتم تجديد الاشتراكات تلقائيًا ما لم يتم إلغاؤها. يمكنك إدارة اشتراكك وإلغاء التجديد التلقائي من إعدادات حسابك في متجر التطبيقات.',
                ),
                _buildGlassCard(
                  context,
                  icon: Icons.lightbulb_outline,
                  title: '4. الملكية الفكرية',
                  text:
                      'كل المحتوى الموجود في التطبيق، بما في ذلك النصوص والرسومات والشعارات والاستراتيجيات، هو ملك لـ SignalX ومحمي بموجب قوانين حقوق النشر.',
                ),
                _buildGlassCard(
                  context,
                  icon: Icons.update,
                  title: '5. تعديل الشروط',
                  text:
                      'نحتفظ بالحق في تعديل هذه الشروط في أي وقت. سيتم نشر أي تغييرات على هذه الصفحة، ويعتبر استمرارك في استخدام التطبيق بعد هذه التغييرات موافقة منك على الشروط الجديدة.',
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amberAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text(
                      "العودة",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  static Widget _buildGlassCard(BuildContext context,
      {required IconData icon,
      required String title,
      required String text}) {
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
                  Colors.white.withOpacity(0.03)
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
