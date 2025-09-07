import 'package:flutter/material.dart';
import 'premium_glass_card.dart';

class PremiumInfoCards extends StatefulWidget {
  final int winTrades;
  final int lossTrades;
  final int activeUsers;
  final Widget blinkingDot;
  
  const PremiumInfoCards({
    super.key,
    required this.winTrades,
    required this.lossTrades,
    required this.activeUsers,
    required this.blinkingDot,
  });

  @override
  State<PremiumInfoCards> createState() => _PremiumInfoCardsState();
}

class _PremiumInfoCardsState extends State<PremiumInfoCards>
    with TickerProviderStateMixin {
  late AnimationController _counterController;
  late Animation<double> _counterAnimation;
  
  @override
  void initState() {
    super.initState();
    _counterController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _counterAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _counterController,
      curve: Curves.elasticOut,
    ));
    
    _counterController.forward();
  }

  @override
  void dispose() {
    _counterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PremiumGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: Column(
        children: [
          // الصف الأول - الصفقات والمستخدمين
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWinLossSection(),
              _buildActiveUsersSection(),
            ],
          ),
          
          // خط فاصل مع تأثير متدرج
          Container(
            margin: const EdgeInsets.symmetric(vertical: 24),
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.3),
                  Colors.cyan.withOpacity(0.5),
                  Colors.white.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          
          // الصف الثاني - حالة الأسواق
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMarketStatus(title: 'OTC سوق', isOpen: true),
              _buildMarketStatus(title: 'السوق العالمي', isOpen: false),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildWinLossSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // العنوان مع النقطة المتحركة
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.blinkingDot,
            const SizedBox(width: 8),
            const Text(
              "صفقات اليوم",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // الصفقات الرابحة والخاسرة
        AnimatedBuilder(
          animation: _counterAnimation,
          builder: (context, child) {
            final animatedWin = (widget.winTrades * _counterAnimation.value).round();
            final animatedLoss = (widget.lossTrades * _counterAnimation.value).round();
            
            return Column(
              children: [
                // الصفقات الرابحة
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.withOpacity(0.2),
                        Colors.greenAccent.withOpacity(0.1),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.greenAccent.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.trending_up,
                        color: Colors.greenAccent,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "$animatedWin WIN",
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          shadows: [
                            Shadow(
                              blurRadius: 5.0,
                              color: Colors.green,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // الصفقات الخاسرة
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [
                        Colors.red.withOpacity(0.2),
                        Colors.redAccent.withOpacity(0.1),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.redAccent.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.trending_down,
                        color: Colors.redAccent,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "$animatedLoss LOSS",
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          shadows: [
                            Shadow(
                              blurRadius: 5.0,
                              color: Colors.red,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildActiveUsersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "المستخدمين النشطين",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        
        // عدد المستخدمين مع تأثيرات
        AnimatedBuilder(
          animation: _counterAnimation,
          builder: (context, child) {
            final animatedUsers = (widget.activeUsers * _counterAnimation.value).round();
            
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Colors.cyan.withOpacity(0.3),
                    Colors.blue.withOpacity(0.2),
                  ],
                ),
                border: Border.all(
                  color: Colors.cyan.withOpacity(0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyan.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  widget.blinkingDot,
                  const SizedBox(width: 8),
                  Text(
                    animatedUsers.toString(),
                    style: const TextStyle(
                      color: Colors.cyan,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 8.0,
                          color: Colors.cyan,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildMarketStatus({required String title, required bool isOpen}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: isOpen
              ? [
                  Colors.green.withOpacity(0.2),
                  Colors.greenAccent.withOpacity(0.1),
                ]
              : [
                  Colors.red.withOpacity(0.2),
                  Colors.redAccent.withOpacity(0.1),
                ],
        ),
        border: Border.all(
          color: isOpen
              ? Colors.greenAccent.withOpacity(0.4)
              : Colors.redAccent.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isOpen ? Icons.radio_button_checked : Icons.radio_button_off,
                color: isOpen ? Colors.greenAccent : Colors.redAccent,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                isOpen ? 'OPEN' : 'CLOSE',
                style: TextStyle(
                  color: isOpen ? Colors.greenAccent : Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  shadows: [
                    Shadow(
                      blurRadius: 5.0,
                      color: isOpen ? Colors.green : Colors.red,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}