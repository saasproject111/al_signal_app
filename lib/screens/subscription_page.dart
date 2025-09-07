import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/payment_methods_sheet.dart';
import '../widgets/animated_gradient_background.dart';
import '../widgets/premium_plan_card.dart';
import '../widgets/billing_toggle_widget.dart';
import '../models/subscription_plan.dart';
import '../utils/app_colors.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage>
    with TickerProviderStateMixin {
  bool _isYearly = false;
  late AnimationController _headerController;
  late AnimationController _cardsController;
  late List<Animation<double>> _cardAnimations;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _cardsController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    final plans = SubscriptionPlan.getPlans();
    _cardAnimations = List.generate(
      plans.length,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _cardsController,
          curve: Interval(
            0.2 * index,
            0.6 + 0.2 * index,
            curve: Curves.elasticOut,
          ),
        ),
      ),
    );

    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _cardsController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _cardsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: AnimatedGradientBackground(
        child: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 40),
              _buildBillingToggle(),
              const SizedBox(height: 30),
              _buildPlanCards(),
              const SizedBox(height: 40),
              _buildFooter(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _headerController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _headerController.value)),
          child: Opacity(
            opacity: _headerController.value.clamp(0.0, 1.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.glowColor.withOpacity(0.3),
                        AppColors.glowColor.withOpacity(0.1),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.glowColor.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    size: 50,
                    color: Colors.white,
                  ),
                )
                    .animate()
                    .scale(delay: 200.ms, duration: 600.ms)
                    .shimmer(delay: 800.ms, duration: 1000.ms),
                const SizedBox(height: 20),
                Text(
                  'اختر خطتك المثالية',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 600.ms)
                    .slideY(begin: 0.3, end: 0),
                const SizedBox(height: 10),
                Text(
                  'احصل على وصول غير محدود لكل الميزات المتقدمة\nوابدأ رحلتك نحو النجاح',
                  style: GoogleFonts.cairo(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(delay: 600.ms, duration: 600.ms)
                    .slideY(begin: 0.3, end: 0),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBillingToggle() {
    return BillingToggleWidget(
      isYearly: _isYearly,
      onToggle: (value) {
        setState(() {
          _isYearly = value;
        });
      },
    );
  }

  Widget _buildPlanCards() {
    final plans = SubscriptionPlan.getPlans();
    
    return Column(
      children: plans.asMap().entries.map((entry) {
        final index = entry.key;
        final plan = entry.value;
        
        return AnimatedBuilder(
          animation: _cardAnimations[index],
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 100 * (1 - _cardAnimations[index].value)),
              child: Opacity(
                opacity: _cardAnimations[index].value.clamp(0.0, 1.0),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: PremiumPlanCard(
                    plan: plan,
                    isYearly: _isYearly,
                    onSelectPlan: () => _handlePlanSelection(plan),
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.security,
                color: AppColors.glowColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'دفع آمن ومشفر 100%',
                style: GoogleFonts.cairo(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'يمكنك إلغاء الاشتراك في أي وقت',
            style: GoogleFonts.cairo(
              color: Colors.white60,
              fontSize: 12,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 1500.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  void _handlePlanSelection(SubscriptionPlan plan) {
    if (plan.isFree) {
      _showFreePlanDialog();
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PaymentMethodsSheet(
        selectedPlan: plan,
        isYearly: _isYearly,
      ),
    );
  }

  void _showFreePlanDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'الخطة المجانية',
          style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'أنت تستخدم الخطة المجانية حالياً. ترقى للحصول على مميزات أكثر!',
          style: GoogleFonts.cairo(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'حسناً',
              style: GoogleFonts.cairo(color: AppColors.glowColor),
            ),
          ),
        ],
      ),
    );
  }
}
