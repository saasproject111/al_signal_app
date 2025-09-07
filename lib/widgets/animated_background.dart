import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  
  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _particleController;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // خلفية متدرجة متحركة
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(
                      const Color(0xFF0A4F46),
                      const Color(0xFF1A5F56),
                      (sin(_animation.value) + 1) / 2,
                    )!,
                    Color.lerp(
                      Colors.black,
                      const Color(0xFF0D1B2A),
                      (cos(_animation.value) + 1) / 2,
                    )!,
                    Color.lerp(
                      const Color(0xFF0A4F46),
                      const Color(0xFF2A6F66),
                      (sin(_animation.value + pi/2) + 1) / 2,
                    )!,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            );
          },
        ),
        // جسيمات متحركة
        AnimatedBuilder(
          animation: _particleController,
          builder: (context, child) {
            return CustomPaint(
              painter: ParticlesPainter(_particleController.value),
              size: Size.infinite,
            );
          },
        ),
        // المحتوى الأساسي
        widget.child,
      ],
    );
  }
}

class ParticlesPainter extends CustomPainter {
  final double animationValue;
  
  ParticlesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final random = Random(42); // seed ثابت للحصول على نفس النمط
    
    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 3 + 1;
      
      // حركة الجسيمات
      final offsetX = sin(animationValue * 2 * pi + i) * 20;
      final offsetY = cos(animationValue * 2 * pi + i) * 15;
      
      // شفافية متغيرة
      final opacity = (sin(animationValue * 4 * pi + i) + 1) / 4 + 0.1;
      
      paint.color = Colors.white.withOpacity(opacity);
      
      canvas.drawCircle(
        Offset(x + offsetX, y + offsetY),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}