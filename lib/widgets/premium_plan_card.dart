import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../models/subscription_plan.dart';
import '../utils/app_colors.dart';

class PremiumPlanCard extends StatefulWidget {
  final SubscriptionPlan plan;
  final bool isYearly;
  final VoidCallback onSelectPlan;

  const PremiumPlanCard({
    super.key,
    required this.plan,
    required this.isYearly,
    required this.onSelectPlan,
  });

  @override
  State<PremiumPlanCard> createState() => _PremiumPlanCardState();
}

class _PremiumPlanCardState extends State<PremiumPlanCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    if (widget.plan.isRecommended) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) => setState(() => _isHovered = false),
      onTapCancel: () => setState(() => _isHovered = false),
      onTap: widget.onSelectPlan,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isHovered ? 0.98 : 1.0),
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.plan.backgroundColor.withOpacity(0.3),
                    Colors.black.withOpacity(0.4),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: widget.plan.borderColor,
                  width: widget.plan.isRecommended ? 2 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.plan.isRecommended
                        ? widget.plan.borderColor
                            .withOpacity(_glowAnimation.value * 0.5)
                        : Colors.black.withOpacity(0.3),
                    blurRadius: widget.plan.isRecommended
                        ? 20 * _glowAnimation.value
                        : 15,
                    spreadRadius: widget.plan.isRecommended
                        ? 2 * _glowAnimation.value
                        : 0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: child,
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildPricing(),
              const SizedBox(height: 20),
              _buildDivider(),
              const SizedBox(height: 20),
              _buildFeatures(),
              const SizedBox(height: 24),
              _buildActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.plan.borderColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.plan.borderColor.withOpacity(0.5),
            ),
          ),
          child: Icon(
            widget.plan.icon,
            color: widget.plan.borderColor,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.plan.title,
                style: GoogleFonts.cairo(
                  color: widget.plan.borderColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.plan.badge != null)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: widget.plan.borderColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.plan.badge!,
                    style: GoogleFonts.cairo(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (widget.plan.savings > 0 && widget.isYearly)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: Text(
              'وفر ${widget.plan.savings.toInt()}%',
              style: GoogleFonts.cairo(
                color: Colors.green,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPricing() {
    String price;
    String period;

    if (widget.plan.isFree) {
      price = widget.plan.freePrice!;
      period = 'للأبد';
    } else {
      price = widget.isYearly
          ? widget.plan.yearlyPrice
          : widget.plan.monthlyPrice;
      period = widget.isYearly ? '/ سنة' : '/ شهر';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!widget.plan.isFree && widget.isYearly)
          Text(
            widget.plan.monthlyPrice,
            style: GoogleFonts.cairo(
              color: Colors.white54,
              fontSize: 18,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        if (!widget.plan.isFree && widget.isYearly) const SizedBox(width: 8),
        Text(
          price,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            period,
            style: GoogleFonts.cairo(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            widget.plan.borderColor.withOpacity(0.5),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.plan.features.map((feature) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: widget.plan.borderColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: widget.plan.borderColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  feature,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButton() {
    if (widget.plan.isFree) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Text(
          'الخطة الحالية',
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.plan.borderColor,
            widget.plan.borderColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: widget.plan.borderColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onSelectPlan,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: widget.plan.isRecommended
                ? Shimmer.fromColors(
                    baseColor: Colors.white,
                    highlightColor: Colors.white70,
                    child: Text(
                      'اختر الخطة المميزة',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : Text(
                    'اختر هذه الخطة',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
