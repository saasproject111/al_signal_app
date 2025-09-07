import 'dart:ui';
import 'package:flutter/material.dart';

class PremiumVipBanner extends StatefulWidget {
  final String message;
  final AnimationController glowController;
  final Animation<Color?> glowAnimation;
  
  const PremiumVipBanner({
    super.key,
    required this.message,
    required this.glowController,
    required this.glowAnimation,
  });

  @override
  State<PremiumVipBanner> createState() => _PremiumVipBannerState();
}

class _PremiumVipBannerState extends State<PremiumVipBanner>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;
  late AnimationController _starController;
  
  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
    
    _starController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([widget.glowController, _shimmerController, _starController]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0),
            boxShadow: [
              BoxShadow(
                color: widget.glowAnimation.value!.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 3,
              ),
              BoxShadow(
                color: Colors.amber.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.amber.withOpacity(0.2),
                      Colors.orange.withOpacity(0.1),
                      Colors.yellow.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25.0),
                  border: Border.all(
                    color: widget.glowAnimation.value!,
                    width: 2.0,
                  ),
                ),
                child: Stack(
                  children: [
                    // تأثير الشيمر
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(23.0),
                        child: AnimatedBuilder(
                          animation: _shimmerAnimation,
                          builder: (context, child) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment(_shimmerAnimation.value - 1, 0),
                                  end: Alignment(_shimmerAnimation.value, 0),
                                  colors: [
                                    Colors.transparent,
                                    Colors.white.withOpacity(0.3),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // المحتوى
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // نجوم متحركة
                        Transform.rotate(
                          angle: _starController.value * 2 * 3.14159,
                          child: const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // النص
                        Expanded(
                          child: Text(
                            widget.message,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              shadows: [
                                Shadow(
                                  blurRadius: 10.0,
                                  color: Colors.amber,
                                  offset: Offset(0, 0),
                                ),
                                Shadow(
                                  blurRadius: 5.0,
                                  color: Colors.black,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // نجمة أخرى
                        Transform.rotate(
                          angle: -_starController.value * 2 * 3.14159,
                          child: const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}