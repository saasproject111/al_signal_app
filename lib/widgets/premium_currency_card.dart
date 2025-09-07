import 'dart:math';
import 'package:flutter/material.dart';
import 'premium_glass_card.dart';

class PremiumCurrencyCard extends StatefulWidget {
  final String iconPath;
  final String currency;
  final String price;
  final Color chartColor;
  
  const PremiumCurrencyCard({
    super.key,
    required this.iconPath,
    required this.currency,
    required this.price,
    required this.chartColor,
  });

  @override
  State<PremiumCurrencyCard> createState() => _PremiumCurrencyCardState();
}

class _PremiumCurrencyCardState extends State<PremiumCurrencyCard>
    with TickerProviderStateMixin {
  late AnimationController _chartController;
  late AnimationController _priceController;
  late Animation<double> _chartAnimation;
  late Animation<double> _priceAnimation;
  
  @override
  void initState() {
    super.initState();
    _chartController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _priceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _chartAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _chartController,
      curve: Curves.easeInOut,
    ));
    
    _priceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _priceController,
      curve: Curves.elasticOut,
    ));
    
    _priceController.forward();
  }

  @override
  void dispose() {
    _chartController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PremiumGlassCard(
      hasGlow: true,
      glowColor: widget.chartColor,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          // أيقونة العملة مع تأثير توهج
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.chartColor.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                widget.iconPath,
                height: 50,
                width: 50,
                errorBuilder: (context, error, stackTrace) => Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        widget.chartColor.withOpacity(0.8),
                        widget.chartColor.withOpacity(0.4),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      widget.currency[0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          // معلومات العملة
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // اسم العملة
                Text(
                  widget.currency,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 5.0,
                        color: Colors.black54,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                // السعر مع تحريك
                AnimatedBuilder(
                  animation: _priceAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _priceAnimation.value,
                      child: Text(
                        widget.price,
                        style: TextStyle(
                          color: widget.chartColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(
                              blurRadius: 8.0,
                              color: widget.chartColor.withOpacity(0.5),
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // الرسم البياني المتحرك
          SizedBox(
            width: 100,
            height: 50,
            child: AnimatedBuilder(
              animation: _chartAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: PremiumLineChartPainter(
                    widget.chartColor,
                    _chartAnimation.value,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PremiumLineChartPainter extends CustomPainter {
  final Color lineColor;
  final double animationValue;
  
  PremiumLineChartPainter(this.lineColor, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    // رسم الخلفية المتدرجة
    final backgroundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withOpacity(0.3),
          lineColor.withOpacity(0.1),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // رسم الخط الرئيسي
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // رسم التوهج
    final glowPaint = Paint()
      ..color = lineColor.withOpacity(0.5)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    // إنشاء المسار
    final path = Path();
    final glowPath = Path();
    
    // نقاط البيانات المتحركة
    final points = <Offset>[];
    for (int i = 0; i <= 20; i++) {
      final x = (i / 20) * size.width;
      final baseY = size.height * 0.5;
      final wave1 = sin((i / 20) * 4 * pi + animationValue * 2 * pi) * size.height * 0.2;
      final wave2 = cos((i / 20) * 6 * pi + animationValue * 3 * pi) * size.height * 0.1;
      final y = baseY + wave1 + wave2;
      points.add(Offset(x, y));
    }

    // رسم المسار
    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);
      glowPath.moveTo(points[0].dx, points[0].dy);
      
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
        glowPath.lineTo(points[i].dx, points[i].dy);
      }
    }

    // رسم المنطقة المملوءة
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, backgroundPaint);

    // رسم التوهج ثم الخط
    canvas.drawPath(glowPath, glowPaint);
    canvas.drawPath(path, linePaint);

    // رسم نقاط متحركة
    for (int i = 0; i < points.length; i += 5) {
      final pointPaint = Paint()
        ..color = lineColor
        ..style = PaintingStyle.fill;
      
      final glowPointPaint = Paint()
        ..color = lineColor.withOpacity(0.6)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      
      final radius = 2.0 + sin(animationValue * 2 * pi + i) * 1.0;
      
      canvas.drawCircle(points[i], radius + 2, glowPointPaint);
      canvas.drawCircle(points[i], radius, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}