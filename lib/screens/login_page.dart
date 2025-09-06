import 'package:flutter/material.dart';
import 'package:my_app/services/auth_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:my_app/screens/terms_of_service_page.dart'; // ✅ استيراد صفحة الشروط

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _alSignalAnimation;
  late Animation<Offset> _traderAnimation;
  late Animation<Offset> _contentAnimation;
  late Animation<double> _fadeAnimation;

  bool _acceptedTerms = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _alSignalAnimation = Tween<Offset>(
      begin: const Offset(-2.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _traderAnimation = Tween<Offset>(
      begin: const Offset(2.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _contentAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    ));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Shimmer.fromColors(
              baseColor: Colors.white,
              highlightColor: Colors.tealAccent,
              period: const Duration(seconds: 3),
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

                    // ✅ Checkbox للموافقة على الشروط
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: _acceptedTerms,
                          onChanged: (value) {
                            setState(() {
                              _acceptedTerms = value ?? false;
                            });
                          },
                          activeColor: Colors.tealAccent,
                        ),
                        GestureDetector(
                          onTap: () {
                            // ✅ فتح صفحة الأحكام والشروط
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const TermsOfServicePage()),
                            );
                          },
                          child: const Text(
                            "أوافق على الأحكام والشروط",
                            style: TextStyle(color: Colors.white, decoration: TextDecoration.underline),
                          ),
                        ),
                      ],
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
                      onPressed: _acceptedTerms
                          ? () {
                              authService.signInWithGoogle();
                            }
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("يجب الموافقة على الأحكام والشروط أولاً"),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
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
