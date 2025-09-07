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
  late AnimationController _waveController;
  late AnimationController _glowController;
  
  late Animation<double> _animation;
  late Animation<double> _waveAnimation;
  late Animation<double> _glowAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat();
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _waveController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(_controller);
    
    _waveAnimation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(_waveController);
    
    _glowAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _particleController.dispose();
    _waveController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // خلفية متدرجة متحركة محسنة
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
                      const Color(0xFF0D1B2A),
                      const Color(0xFF1A2332),
                      (cos(_animation.value + pi/3) + 1) / 2,
                    )!,
                    Color.lerp(
                      Colors.black,
                      const Color(0xFF0A1A2A),
                      (sin(_animation.value + pi/2) + 1) / 2,
                    )!,
                    Color.lerp(
                      const Color(0xFF0A4F46),
                      const Color(0xFF2A6F66),
                      (cos(_animation.value + pi) + 1) / 2,
                    )!,
                  ],
                  stops: const [0.0, 0.3, 0.7, 1.0],
                ),
              ),
            );
          },
        ),
        
        // طبقة الموجات المتحركة
        AnimatedBuilder(
          animation: _waveAnimation,
          builder: (context, child) {
            return CustomPaint(
              painter: WavesPainter(_waveAnimation.value),
              size: Size.infinite,
            );
          },
        ),
        
        // جسيمات متحركة محسنة
        AnimatedBuilder(
          animation: _particleController,
          builder: (context, child) {
            return CustomPaint(
              painter: EnhancedParticlesPainter(_particleController.value),
              size: Size.infinite,
            );
          },
        ),
        
        // طبقة التوهج
        AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return CustomPaint(
              painter: GlowPainter(_glowAnimation.value),
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

// رسام الموجات المتحركة
class WavesPainter extends CustomPainter {
  final double animationValue;
  
  WavesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // موجة علوية
    final path1 = Path();
    path1.moveTo(0, size.height * 0.2);
    
    for (double x = 0; x <= size.width; x += 10) {
      final y = size.height * 0.2 + 
          sin((x / size.width * 4 * pi) + (animationValue * 2 * pi)) * 30;
      path1.lineTo(x, y);
    }
    
    path1.lineTo(size.width, 0);
    path1.lineTo(0, 0);
    path1.close();
    
    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF1A5F56).withOpacity(0.3),
        Colors.transparent,
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.3));
    
    canvas.drawPath(path1, paint);
    
    // موجة سفلية
    final path2 = Path();
    path2.moveTo(0, size.height);
    path2.lineTo(0, size.height * 0.8);
    
    for (double x = 0; x <= size.width; x += 10) {
      final y = size.height * 0.8 + 
          sin((x / size.width * 3 * pi) + (animationValue * 2 * pi) + pi) * 40;
      path2.lineTo(x, y);
    }
    
    path2.lineTo(size.width, size.height);
    path2.close();
    
    paint.shader = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        const Color(0xFF0A4F46).withOpacity(0.4),
        Colors.transparent,
      ],
    ).createShader(Rect.fromLTWH(0, size.height * 0.7, size.width, size.height * 0.3));
    
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// رسام الجسيمات المحسن
class EnhancedParticlesPainter extends CustomPainter {
  final double animationValue;
  
  EnhancedParticlesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = Random(42);
    
    // جسيمات كبيرة متوهجة
    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 4 + 2;
      
      final offsetX = sin(animationValue * 2 * pi + i * 0.5) * 30;
      final offsetY = cos(animationValue * 1.5 * pi + i * 0.3) * 20;
      
      final opacity = (sin(animationValue * 3 * pi + i) + 1) / 4 + 0.1;
      
      // توهج خارجي
      paint.shader = RadialGradient(
        colors: [
          Colors.yellow.withOpacity(opacity * 0.6),
          Colors.orange.withOpacity(opacity * 0.3),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(x + offsetX, y + offsetY),
        radius: radius * 3,
      ));
      
      canvas.drawCircle(
        Offset(x + offsetX, y + offsetY),
        radius * 3,
        paint,
      );
      
      // النواة
      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(
        Offset(x + offsetX, y + offsetY),
        radius,
        paint,
      );
    }
    
    // جسيمات صغيرة سريعة
    for (int i = 0; i < 80; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 2 + 0.5;
      
      final offsetX = sin(animationValue * 4 * pi + i) * 50;
      final offsetY = cos(animationValue * 3 * pi + i) * 30;
      
      final opacity = (sin(animationValue * 6 * pi + i) + 1) / 6 + 0.05;
      
      paint.color = Colors.cyanAccent.withOpacity(opacity);
      paint.shader = null;
      
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

// رسام التوهج
class GlowPainter extends CustomPainter {
  final double animationValue;
  
  GlowPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // توهج في الزوايا
    final corners = [
      Offset(0, 0),
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ];
    
    for (int i = 0; i < corners.length; i++) {
      final opacity = (sin(animationValue * 2 * pi + i * pi/2) + 1) / 8;
      
      paint.shader = RadialGradient(
        colors: [
          Colors.yellow.withOpacity(opacity),
          Colors.orange.withOpacity(opacity * 0.5),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: corners[i],
        radius: 200,
      ));
      
      canvas.drawCircle(corners[i], 200, paint);
    }
    
    // توهج مركزي
    final centerOpacity = (sin(animationValue * pi) + 1) / 10;
    paint.shader = RadialGradient(
      colors: [
        const Color(0xFF1A5F56).withOpacity(centerOpacity),
        Colors.transparent,
      ],
    ).createShader(Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width * 0.6,
    ));
    
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.6,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}