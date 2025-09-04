import 'package:flutter/material.dart';
import 'package:my_app/services/auth_service.dart';
import 'package:shimmer/shimmer.dart'; // 1. استيراد حزمة اللمعان

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

// 2. إضافة SingleTickerProviderStateMixin للتحكم في الأنيميشن
class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  // 3. إنشاء متحكم للأنيميشن
  late AnimationController _controller;
  late Animation<Offset> _alSignalAnimation;
  late Animation<Offset> _traderAnimation;
  late Animation<Offset> _contentAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // 4. تهيئة متحكم الأنيميشن وتحديد مدته
    _controller = AnimationController(
      duration: const Duration(seconds: 2), // مدة الأنيميشن بالكامل
      vsync: this,
    );

    // 5. تعريف الحركات المختلفة
    // حركة "AL SIGNAL" من اليسار إلى المنتصف
    _alSignalAnimation = Tween<Offset>(
      begin: const Offset(-2.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut), // تحدث في النصف الأول من الوقت
    ));

    // حركة "TRADER" من اليمين إلى المنتصف
    _traderAnimation = Tween<Offset>(
      begin: const Offset(2.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut), // تحدث في النصف الأول من الوقت
    ));

    // حركة المحتوى السفلي من الأسفل للأعلى
    _contentAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut), // تحدث في النصف الثاني من الوقت
    ));
    
    // تأثير الظهور (Fade) للمحتوى السفلي
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    ));

    // 6. بدء الأنيميشن عند فتح الصفحة
    _controller.forward();
  }

  @override
  void dispose() {
    // 7. التخلص من المتحكم عند إغلاق الصفحة
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return Scaffold(
      backgroundColor: Colors.blueGrey[900], // خلفية داكنة
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- 8. تطبيق تأثير اللمعان وحركات النصوص ---
            Shimmer.fromColors(
              baseColor: Colors.white,
              highlightColor: Colors.tealAccent,
              period: const Duration(seconds: 3), // سرعة اللمعان
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SlideTransition(
                    position: _alSignalAnimation,
                    child: const Text('AL SIGNAL', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 10),
                  SlideTransition(
                    position: _traderAnimation,
                    child: const Text('TRADER', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),

            // --- 9. تطبيق حركة الظهور والانزلاق للمحتوى السفلي ---
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _contentAnimation,
                child: Column(
                  children: [
                    const Text(
                      'سجل الدخول للمتابعة',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: Image.asset('assets/google_logo.png', height: 24.0),
                      label: const Text(
                        'Sign in with Google',
                        style: TextStyle(fontSize: 18, color: Colors.black87),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        minimumSize: const Size(250, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      ),
                      onPressed: () {
                        authService.signInWithGoogle();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}