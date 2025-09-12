import 'package:flutter/material.dart';
import 'package:my_app/services/auth_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:my_app/screens/terms_of_service_page.dart';
import 'package:my_app/screens/privacy_policy_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> 
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;
  late AnimationController _backgroundController;
  
  late Animation<Offset> _logoSlideAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<Offset> _contentSlideAnimation;
  late Animation<double> _contentFadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _buttonHoverAnimation;

  bool _acceptedTerms = false;
  bool _isButtonHovered = false;

  @override
  void initState() {
    super.initState();
    
    // Main animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Pulse animation controller
    _pulseController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    // Background animation controller
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    // Logo animations
    _logoSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -2.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    // Content animations
    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
    ));

    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    // Pulse animation
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Background animation
    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.linear),
    );

    // Button hover animation
    _buttonHoverAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: const [
                Color(0xFF0A0A0A),
                Color(0xFF1A1A2E),
                Color(0xFF16213E),
                Color(0xFF0F0F0F),
              ],
              stops: [
                0.0,
                0.3 + 0.1 * _backgroundAnimation.value,
                0.7 + 0.2 * _backgroundAnimation.value,
                1.0,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: CustomPaint(
            painter: TradingPatternPainter(_backgroundAnimation.value),
            child: Container(),
          ),
        );
      },
    );
  }

  Widget _buildLogo() {
    return SlideTransition(
      position: _logoSlideAnimation,
      child: FadeTransition(
        opacity: _logoFadeAnimation,
        child: ScaleTransition(
          scale: _logoScaleAnimation,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Column(
                  children: [
                    // Trading Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.trending_up,
                        size: 40,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // App Name with Shimmer
                    Shimmer.fromColors(
                      baseColor: const Color(0xFFFFD700),
                      highlightColor: Colors.white,
                      period: const Duration(seconds: 3),
                      child: const Text(
                        'SignalX',
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Color(0xFFFFD700),
                              blurRadius: 15,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Subtitle with gradient
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFFFFF)],
                      ).createShader(bounds),
                      child: const Text(
                        "التطبيق الاول عربيا في اشارات التداول والتحليل الفني",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 5),
                    // Professional badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFFFD700).withOpacity(0.5),
                        ),
                      ),
                      child: const Text(
                        "PROFESSIONAL TRADING",
                        style: TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumButton({
    required String text,
    required Widget icon,
    required VoidCallback onPressed,
    required bool enabled,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: enabled
            ? const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [Colors.grey.shade700, Colors.grey.shade800],
              ),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 1,
                  offset: const Offset(0, 5),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          onHover: (hovering) {
            setState(() {
              _isButtonHovered = hovering;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 60,
            transform: Matrix4.identity()
              ..scale(_isButtonHovered && enabled ? 1.02 : 1.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon,
                  const SizedBox(width: 12),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: enabled ? const Color(0xFF1A1A2E) : Colors.grey.shade400,
                      letterSpacing: 0.5,
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

  Widget _buildTermsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFD700).withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // النص والـ Checkbox في النص
        children: [
          Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: _acceptedTerms,
              onChanged: (value) {
                setState(() {
                  _acceptedTerms = value ?? false;
                });
              },
              activeColor: const Color(0xFFFFD700),
              checkColor: const Color(0xFF1A1A2E),
              side: BorderSide(
                color: _acceptedTerms
                    ? const Color(0xFFFFD700)
                    : Colors.grey.shade500,
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Wrap(
              alignment: WrapAlignment.center, // يخلي النص في منتصف السطر
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  "أوافق على ",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TermsOfServicePage(),
                      ),
                    );
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFFFFD700),
                          width: 1.2,
                        ),
                      ),
                    ),
                    child: const Text(
                      "الأحكام والشروط",
                      style: TextStyle(
                        color: Color(0xFFFFD700),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const Text(
                  " و ",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivacyPolicyPage(),
                      ),
                    );
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFFFFD700),
                          width: 1.2,
                        ),
                      ),
                    ),
                    child: const Text(
                      "سياسة الخصوصية",
                      style: TextStyle(
                        color: Color(0xFFFFD700),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return Scaffold(
      body: Stack(
        children: [
          // Animated Background
          _buildAnimatedBackground(),
          
          // Main Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  
                  // Logo Section
                  _buildLogo(),
                  
                  const SizedBox(height: 80),
                  
                  // Content Section
                  SlideTransition(
                    position: _contentSlideAnimation,
                    child: FadeTransition(
                      opacity: _contentFadeAnimation,
                      child: Column(
                        children: [
                          // Welcome Message
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24, 
                              vertical: 12
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: const Color(0xFFFFD700).withOpacity(0.3),
                              ),
                            ),
                            child: const Text(
                              'سجل الدخول وابدأ رحلتك في التداول',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // Terms and Conditions Section
                          _buildTermsSection(),
                          
                          const SizedBox(height: 30),
                          
                          // Google Sign In Button
                          _buildPremiumButton(
                            text: "تسجيل الدخول عبر Google",
                            icon: Image.asset(
                              'assets/google_logo.png', 
                              height: 28,
                              width: 28,
                            ),
                            enabled: _acceptedTerms,
                            onPressed: _acceptedTerms
                                ? () => authService.signInWithGoogle()
                                : () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          "يجب الموافقة على الشروط والسياسة أولاً",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        backgroundColor: Colors.red.shade700,
                                        behavior: SnackBarBehavior.floating,
                                        margin: const EdgeInsets.all(20),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    );
                                  },
                          ),
                          
                          const SizedBox(height: 30),
                          
                          // Security Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16, 
                              vertical: 8
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.green.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.security,
                                  color: Colors.green,
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "تسجيل دخول آمن ومشفر",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TradingPatternPainter extends CustomPainter {
  final double animationValue;

  TradingPatternPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFD700).withOpacity(0.1)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw trading chart pattern
    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * 3.14159 / 5) + (animationValue * 2 * 3.14159);
      final x = centerX + 150 * (0.5 + 0.5 * animationValue) * 
                 (1 + 0.3 * (i % 2)) * 
                 (centerX / 200) * 
                 (0.8 + 0.2 * animationValue);
      final y = centerY + 150 * (0.5 + 0.5 * animationValue) * 
                 (1 + 0.3 * (i % 2)) * 
                 (centerY / 400) * 
                 (0.8 + 0.2 * animationValue);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    canvas.drawPath(path, paint);
    
    // Draw grid pattern
    paint.color = const Color(0xFFFFD700).withOpacity(0.05);
    for (int i = 0; i < size.width; i += 50) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble(), size.height),
        paint,
      );
    }
    
    for (int i = 0; i < size.height; i += 50) {
      canvas.drawLine(
        Offset(0, i.toDouble()),
        Offset(size.width, i.toDouble()),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}